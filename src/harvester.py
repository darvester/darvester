import asyncio
import sys
import time

import selfcord as discord

from cfg import QUIET_MODE, IGNORE_GUILD
from src import logutil
from src.presence import BotStatus, RichPresence
from src.sqlutil import SQLiteNoSQL
RichPresence = RichPresence()
RichPresence.start_thread()
logger = logutil.initLogger("harvester")

BotStatus = BotStatus()
quiet_msg = "(quiet mode enabled)"


class Harvester:
    """Main class for bot"""

    def __init__(self) -> None:
        # Define a set that will be used to check against later
        self._id_array = set()
        # Setup database
        self.db = SQLiteNoSQL("harvested.db")
        self.cur = self.db.cursor()

    async def thread_start(self, client):
        RichPresence.put(message=["Darvester", "Preparing...", ""])
        logger.info("Logged in as %s", client.user.name if not QUIET_MODE else
                    "user")
        logger.info("Starting guild ID dump...")

        await BotStatus.update(client=client,
                               state="Preparing")

        try:
            while True:
                self.db.open()
                _request_number = 0  # For our rate limiting
                # Store all guilds user is in
                _list_of_guilds = [guild.id for guild in client.guilds]

                for guildid in _list_of_guilds:
                    guild = client.get_guild(guildid)
                    if guild.unavailable:
                        logger.warning(
                            "Guild '%s' is unavailable. Skipping..."
                            % guild.name
                        )
                        continue
                    if guild.id in IGNORE_GUILD:
                        logger.warning(
                            "Guild %s ignored. Skipping..."
                            % guild.name
                        )
                        continue
                    logger.info('Now working in guild: "%s"', guild.name
                                if not QUIET_MODE else
                                "(quiet mode enabled)")
                    RichPresence.put(message=[f"Harvesting '{guild.name}'" if not QUIET_MODE else quiet_msg,  # noqa
                                              f"{len(guild.members)} members",
                                              ""])
                    await BotStatus.update(client=client,
                                           state=f'Harvesting "{guild.name}"' if not QUIET_MODE else quiet_msg,  # noqa
                                           status=discord.Status.online)

                    "Do guild harvest"
                    # Define the data
                    guild_data = {
                        "name": guild.name,
                        "icon": str(guild.icon_url),
                        "owner": {
                            "name": guild.owner.name if guild.owner else None,
                            "id": guild.owner.id if guild.owner else
                            guild.owner_id
                        },
                        "description": guild.description,
                        "features": guild.features,
                        "premium_tier": guild.premium_tier,
                    }
                    logger.info(
                        'Inserting guild "%s" = "%s"'
                        % (guild.id, guild_data["name"])
                    ) if not QUIET_MODE else logger.info(
                        "Inserting a guild...")

                    self.db.addrow(guild_data, guild.id, "guilds")
                    _request_number += 1
                    # Mark as read, as "done"
                    await guild.ack()

                    "Do member/user harvest"
                    for member in guild.members:
                        # Filter for bot and Discord system messages
                        if member.bot and member.system:
                            logger.info('User "%s" is a bot. Skipping...',
                                        member.name if not QUIET_MODE else None
                                        )
                            continue

                        # Check if we already harvested this user
                        if member.id in self._id_array:
                            logger.info('Already checked "%s"', member.name if
                                        not QUIET_MODE else None)
                            continue

                        # Check if we've reached our request limit
                        if _request_number <= 40:
                            # If not...
                            "Harvest info"

                            # Add member.id to the array to check against later
                            self._id_array.add(member.id)

                            # Check to see if we scanned this user recently
                            _d1 = self.db.find(member.id, "users",
                                               "last_scanned")
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
                                    member.name if not QUIET_MODE else None,
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
                                "created_at": int(
                                    member.created_at.timestamp()),
                                "connected_accounts":
                                _profile_object.connected_accounts,
                                "last_scanned": int(time.time()),
                            }

                            logger.info(
                                'Inserting "%s" = %s#%s :' % (member.id,
                                                              member.name,
                                                              member.discriminator)  # noqa
                            ) if not QUIET_MODE else logger.info(
                                "Inserting...")

                            # Insert harvested data
                            self.db.addrow(data, member.id, "users")

                            # Increment the request counter
                            _request_number += 1
                            await asyncio.sleep(1)

                        else:  # If request counter goes over 40
                            await BotStatus.update(client=client)
                            RichPresence.put(message=["Darvester",
                                                      "On cooldown",
                                                      "cooldown"])
                            self.db.close()
                            logger.info("On request cooldown...")
                            for _ in range(60, 0, -1):
                                sys.stdout.write("\r")
                                sys.stdout.write("{:2d} remaining".format(_))
                                sys.stdout.flush()
                                await asyncio.sleep(1)
                            print("\n")
                            RichPresence.put(message=[f"Harvesting '{guild.name}'" if not QUIET_MODE else quiet_msg,  # noqa
                                                      f"{len(guild.members)} members",  # noqa
                                                      ""])  # noqa
                            await BotStatus.update(client=client,
                                                   state=f'Harvesting "{guild.name}"' if not QUIET_MODE else quiet_msg,  # noqa
                                                   status=discord.Status.online)  # noqa

                            # Reset the request counter
                            _request_number = 0

                self.db.close()
                logger.info("That's all! Sleeping for a bit then looping")
                RichPresence.put(message=["- Discord OSINT harvester",
                                          "- Created by V3ntus",
                                          ""])
                await asyncio.sleep(1)
                for _ in range(600, 0, -1):
                    sys.stdout.write("\r")
                    sys.stdout.write("{:2d} remaining".format(_))
                    sys.stdout.flush()
                    await asyncio.sleep(1)
                # Clear the id array so we can recheck everything
                print("\n")
                self._id_array = set()

        except discord.errors.HTTPException:
            logger.critical(
                "HTTP 429 returned. You may have been temp banned! \
Try again later (may take a couple hours or as long as a day)"
            )
            sys.exit()

    async def close(self):
        await self.db.close()
