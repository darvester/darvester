import asyncio
import sys
import time

import selfcord as discord

from src import logutil
from src.sqlutil import SQLiteNoSQL

logger = logutil.initLogger("harvester")


class Harvester:
    """Main class for bot"""

    def __init__(self) -> None:
        # Define a set that will be used to check against later
        self._id_array = set()
        # Setup database
        self.db = SQLiteNoSQL("harvested.db")
        self.cur = self.db.cursor()

    async def thread_start(self, client):
        logger.info("Logged in as %s", client.user.name)
        logger.info("Starting guild ID dump...")

        try:
            _request_number = 0  # For our rate limiting
            # Store all guilds user is in
            _list_of_guilds = [guild.id for guild in client.guilds]

            for guildid in _list_of_guilds:
                guild = client.get_guild(guildid)
                logger.info('Now working in guild: "%s"', guild.name)

                "Do member/user harvest"
                for member in guild.members:
                    # Filter for bot and Discord system messages
                    if member.bot and member.system:
                        logger.info('User "%s" is a bot. Skipping...',
                                    member.name)
                        continue

                    # Check if we already harvested this user
                    if member.id in self._id_array:
                        logger.info('Already checked "%s"', member.name)
                        continue

                    # Check if we've reached our request limit
                    if _request_number <= 40:
                        # If not...
                        "Harvest info"

                        # Add member.id to the array to check against later
                        self._id_array.add(member.id)

                        # Check to see if we scanned this user recently
                        _d1 = self.db.find(member.id, "users", "last_scanned")
                        if not isinstance(_d1, (str, int, bytes)):
                            try:
                                _d1 = _d1["last_scanned"]
                            except Exception:
                                logger.debug(
                                    "\
_d1 assigned to None due to last_scanned query error"
                                )
                                _d1 = None  # last_scanned was not appended

                        if (
                            _d1 is not None
                            and (int(time.time()) - int(_d1)) < 600
                        ):
                            logger.info(
                                'User "%s" scanned in the last \
ten minutes. Skipping...',
                                member.name,
                            )
                            continue

                        # Grab the user profile object of member
                        _profile_object = await client.fetch_user_profile(
                            member.id
                        )

                        # Append mutual guilds
                        _user_guilds = {"guilds": []}
                        for _ in _profile_object.mutual_guilds:
                            _user_guilds["guilds"].append(_.id)

                        # Build harvested data structure
                        data = {
                            "name": member.name,
                            "discriminator": member.discriminator,
                            "bio": _profile_object.bio,
                            "mutual_guilds": _user_guilds,
                            "avatar_url": str(member.avatar_url),
                            "public_flags": member.public_flags.all(),
                            "created_at": int(member.created_at.timestamp()),
                            "connected_accounts":
                            _profile_object.connected_accounts,
                            "last_scanned": int(time.time()),
                        }

                        logger.info(
                            '\
Inserting "%s" = %s#%s :'
                            % (member.id, member.name, member.discriminator)
                        )

                        # Insert harvested data
                        self.db.addrow(data, member.id, "users")

                        # Increment the request counter
                        _request_number += 1
                        await asyncio.sleep(1)

                    else:  # If request counter goes over 40
                        self.db.close()
                        logger.info("On request cooldown...")
                        for _ in range(60, 0, -1):
                            sys.stdout.write("\r")
                            sys.stdout.write("{:2d} remaining".format(_))
                            sys.stdout.flush()
                            await asyncio.sleep(1)
                            print("\n")

                        # Reset the request counter
                        _request_number = 0

            self.db.close()

        except discord.errors.HTTPException:
            logger.critical(
                "HTTP 429 returned. You may have been temp banned! \
Try again later (may take a couple hours or as long as a day)"
            )
            sys.exit()

    async def close(self):
        await self.db.close()
