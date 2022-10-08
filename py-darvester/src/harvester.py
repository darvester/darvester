import asyncio
import time
from datetime import datetime
from itertools import islice

import discord
from discord.ext.commands import Bot

from cfg import DISABLE_VCS, IGNORE_GUILD, LAST_SCANNED_INTERVAL, QUIET_MODE, DEBUG
from src import logutil, ui
from src.gitutil import GitUtil
from src.presence import BotStatus, RichPresence
from src.sqlutil import SQLiteNoSQL
from src.ui import set_title

RichPresence = RichPresence()
_rp_thread = RichPresence.start_thread()
BotStatus = BotStatus()
if not DISABLE_VCS:
    git = GitUtil()

logger = logutil.initLogger("harvester")
quiet_msg = "(quiet mode enabled)"


class Harvester:
    """Main class for bot"""

    def __init__(self) -> None:
        # Define a set that will be used to check against later
        self._id_array = set()
        # Setup database
        self.db = SQLiteNoSQL("harvested.db")
        self.cur = self.db.cursor
        if not DISABLE_VCS:
            self._repo = git.init_repo()

    async def thread_start(self, client: Bot):
        """The main entry method for the harvester"""

        RichPresence.put(message=["Darvester", "Preparing...", ""])
        set_title("Darvester - Preparing...")
        logger.info("Logged in as %s", client.user.name if not QUIET_MODE else "user")

        await BotStatus.update(client=client, state="Preparing")

        try:
            while True:
                self.db.open()
                _request_number = 0  # For our rate limiting
                # Store all guilds bot/user is in
                _list_of_guilds = [guild.id for guild in client.guilds]

                for guildidx, guildid in enumerate(_list_of_guilds, start=1):

                    if guildid in IGNORE_GUILD:
                        logger.warning(
                            "Guild %s ignored. Skipping...",
                            guildid if not QUIET_MODE else "Guild ignored. Skipping...",
                        )
                        continue

                    guild: discord.Guild = client.get_guild(guildid)

                    if len(guild.members) != guild.member_count:
                        # This code should get the top five channels that contain a good amount of members
                        if guild.member_count < 100:
                            _limit = 10
                        else:
                            _limit = 100
                        _good_channels = [
                            channel
                            for channel in guild.channels
                            if channel.type == discord.ChannelType.text
                            and len(channel.members) > _limit
                        ]
                        _good_channels = sorted(
                            list(islice(_good_channels, 5)),
                            key=lambda x: len(x.members),
                            reverse=True,
                        )
                        if guild.member_count >= 1000:
                            logger.warning(
                                'Delay incoming! Fetching members for guild "%s"...', guild.name
                            )
                            await guild.fetch_members(channels=_good_channels)
                        elif guild.member_count < 1000:
                            logger.warning(
                                'Delay incoming! Chunking members for guild "%s"...', guild.name
                            )
                            await guild.chunk(
                                discord.Object(
                                    _good_channels[0].id
                                    if _good_channels
                                    else sorted(
                                        guild.channels, key=lambda x: len(x.members), reverse=True
                                    )[0].id
                                )
                            )
                    _g_name = guild.name if not QUIET_MODE else '"quiet mode"'
                    _g_desc = guild.description if not QUIET_MODE else '"quiet mode"'

                    if guild.unavailable:
                        logger.warning(
                            "Guild '%s' is unavailable. Skipping...",
                            guild.name if not QUIET_MODE else "Guild unavailable. Skipping...",
                        )
                        continue

                    logger.info(
                        'Now working in guild: "%s"',
                        guild.name
                        if not QUIET_MODE
                        else "Now working in guild: (quiet mode enabled)",
                    )

                    set_title(
                        f"Darvester - Harvesting {_g_name}" + f" with {len(guild.members)} members"
                    )
                    RichPresence.put(
                        message=[
                            f"Harvesting '{guild.name}'" if not QUIET_MODE else quiet_msg,
                            f"{len(guild.members)} members",
                            "",
                        ]
                    )
                    await BotStatus.update(
                        client=client,
                        state=f'Harvesting "{guild.name}"' if not QUIET_MODE else quiet_msg,
                        status=discord.Status.online,
                    )

                    # Do guild harvest
                    # Define the data
                    guild_data = {
                        "name": str(guild.name),
                        "icon": str(guild.icon),
                        "owner": {
                            "name": str(guild.owner.name) if guild.owner else None,
                            "id": guild.owner.id if guild.owner else guild.owner_id,
                        },
                        "splash_url": str(guild.splash),
                        "member_count": guild.member_count,
                        "description": str(guild.description),
                        "features": guild.features,
                        "premium_tier": guild.premium_tier,
                    }

                    logger.debug(
                        'GUILD: Inserting guild "%s" = "%s"', guild.id, guild_data["name"]
                    )

                    self.db.addrow(guild_data, guild.id, "guilds")
                    _request_number += 1

                    # Mark as read, as "done"
                    await guild.ack()

                    # Do member/user harvest
                    member: discord.Member
                    for memberidx, member in enumerate(guild.members, start=1):

                        # Filter for bot and Discord system messages
                        if member.bot or member.system:
                            logger.info(
                                'User "%s" is a bot. Skipping...',
                                member.name if not QUIET_MODE else None,
                            )
                            continue

                        # Check if we already harvested this user
                        if member.id in self._id_array:
                            logger.debug(
                                'Already checked "%s"',
                                member.name,
                            )
                            continue

                        # Check if we've reached our request limit
                        if _request_number <= 40:
                            # If not...
                            # Harvest info

                            # Add member.id to the array to check against later
                            self._id_array.add(member.id)

                            # Check to see if we scanned this user recently
                            _d1 = self.db.find(member.id, "users", "last_scanned")
                            if not isinstance(_d1, (str, int, bytes)):
                                try:
                                    _d1 = _d1["last_scanned"]
                                except (KeyError, TypeError):
                                    _d1 = None  # last_scanned was not appended

                            if (
                                _d1 is not None
                                and (int(time.time()) - int(_d1)) < LAST_SCANNED_INTERVAL
                            ):
                                logger.debug(
                                    'User "%s" scanned in the last %s. Skipping...',
                                    member.name if not QUIET_MODE else None,
                                    str(int(LAST_SCANNED_INTERVAL / 60)) + " minutes"
                                    if int(LAST_SCANNED_INTERVAL / 60) != 0
                                    else str(int(LAST_SCANNED_INTERVAL)) + " seconds",
                                )
                                continue

                            # Grab the user profile object of member
                            _profile_object: discord.UserProfile = await client.fetch_user_profile(
                                member.id
                            )

                            # Append mutual guilds
                            _user_guilds = {"guilds": []}
                            for _ in _profile_object.mutual_guilds:
                                _user_guilds["guilds"].append(_.id)

                            _activities_modeled = []
                            for _ in member.activities:
                                if _.type == discord.ActivityType.unknown:
                                    _type = "unknown"
                                elif _.type == discord.ActivityType.playing:
                                    _type = "playing"
                                elif _.type == discord.ActivityType.streaming:
                                    _type = "streaming"
                                elif _.type == discord.ActivityType.listening:
                                    _type = "listening"
                                elif _.type == discord.ActivityType.watching:
                                    _type = "watching"
                                elif _.type == discord.ActivityType.custom:
                                    _type = "custom"
                                else:
                                    _type = "unknown"

                                _e: discord.PartialEmoji
                                if _e := getattr(_, "emoji", None):
                                    _emoji = {
                                        "name": _e.name,
                                        "id": _e.id,
                                        "url": str(_e.url),
                                    }
                                else:
                                    _emoji = None

                                def _timestamp(_entry: str):
                                    _dt: datetime
                                    if type(_dt := getattr(_, _entry, None)) is datetime:
                                        return _dt.timestamp()
                                    else:
                                        return None

                                _activities_modeled.append(
                                    {
                                        "type": _type,
                                        "name": str(getattr(_, "name", None)),
                                        "details": str(getattr(_, "details", None)),
                                        "url": getattr(_, "url", None),
                                        "application_id": getattr(_, "application_id", None),
                                        "emoji": _emoji,
                                        "start": _timestamp("start"),
                                        "end": _timestamp("end"),
                                        "game": str(getattr(_, "game", None)),
                                        "twitch_name": str(getattr(_, "twitch_name", None)),
                                    }
                                )

                            # Build harvested data structure
                            data = {
                                "name": str(member.name),
                                "discriminator": member.discriminator,
                                "bio": str(_profile_object.bio),
                                "mutual_guilds": _user_guilds,
                                "avatar_url": str(member.avatar),
                                "public_flags": member.public_flags.all(),
                                "created_at": int(member.created_at.timestamp()),
                                "connected_accounts": [
                                    {
                                        "type": connection.type,
                                        "id": connection.id,
                                        "name": connection.name,
                                        "verified": connection.verified,
                                    }
                                    for connection in _profile_object.connections
                                ],
                                "last_scanned": int(time.time()),
                                "activities": _activities_modeled,
                                "status": str(member.status),
                                "premium": str("True" if _profile_object.premium else "False"),
                                "premium_since": str(int(_profile_object.premium_since.timestamp())
                                                     if _profile_object.premium_since else None),
                            }

                            logger.debug(
                                'USER: Inserting "%s" = %s#%s :',
                                member.id,
                                member.name,
                                member.discriminator,
                            )

                            # Insert harvested data
                            self.db.addrow(data, member.id, "users")

                            _bio = data["bio"]
                            if _bio and len(_bio) >= 30 and not QUIET_MODE:
                                _bio = _bio[:27].replace("\n", " ") + "..."
                            else:
                                _bio = "None"

                            _name = data["name"] + "#" + data["discriminator"]
                            if QUIET_MODE:
                                _name = '"quiet mode"'

                            # Increment the request counter
                            _request_number += 1
                            await asyncio.sleep(1)

                        else:  # If request counter goes over 40
                            await BotStatus.update(client=client)
                            RichPresence.put(
                                message=[
                                    "{:,} users in database".format(self.db.users_count),
                                    "On cooldown",
                                    "cooldown",
                                ]
                            )
                            set_title("Darvester - On cooldown")
                            self.db.close()

                            cooldown_counter = ui.new_counter(
                                name="cooldown",
                                total=60,
                                description="Cooldown",
                                unit="s",
                                leave=False,
                                counter_format="{desc}{desc_pad} {elapsed}",
                            )

                            logger.debug("COOLDOWN: On request cooldown...")
                            for _ in range(60, 0, -1):
                                cooldown_counter.update()
                                await asyncio.sleep(1)
                            cooldown_counter.close(clear=True)
                            set_title(
                                f"Darvester - Harvesting {guild.name} "
                                + f"with {len(guild.members)} members"
                            )
                            RichPresence.put(
                                message=[
                                    f"Harvesting '{guild.name if not QUIET_MODE else quiet_msg}'",
                                    f"{memberidx} of {len(guild.members)} members",
                                    "",
                                ]
                            )  # noqa
                            await BotStatus.update(
                                client=client,
                                state=f'Harvesting "{guild.name if not QUIET_MODE else quiet_msg}"',
                                status=discord.Status.online,
                            )  # noqa

                            # Reset the request counter
                            _request_number = 0

                self.db.close()
                if not DISABLE_VCS:
                    for table in ["users", "guilds"]:
                        self.db.dump_table_to_files(table=table)
                    git.commit()
                logger.info("That's all the guilds! Sleeping for a bit then looping")
                RichPresence.put(message=["- Discord OSINT harvester", "- Created by V3ntus", ""])
                set_title("Darvester - Created by V3ntus")
                await asyncio.sleep(1)

                cooldown_counter = ui.new_counter(
                    name="cooldown",
                    total=600,
                    description="Cooldown",
                    unit="s",
                    leave=False,
                    counter_format="{desc}{desc_pad} {elapsed}",
                )

                for _ in range(180, 0, -1):
                    cooldown_counter.update()
                    await asyncio.sleep(1)
                cooldown_counter.close(clear=True)
                # Clear the id array so we can recheck everything
                self._id_array = set()

        except discord.errors.HTTPException:
            logger.critical(
                "HTTP 429 returned. You may have been temp banned! \
Try again later (may take a couple hours or as long as a day)",
                exc_info=DEBUG,
            )
            self.close()

    def close(self):
        """Gracefully close and clean up the harvester thread"""
        logger.info("Caught a closing signal. Cleaning up...")
        self.db.commit()
        RichPresence.queue.put("RP_QUIT")
        if not DISABLE_VCS:
            for table in ["users", "guilds"]:
                self.db.dump_table_to_files(table=table)
            git.commit()
        else:
            self.db.close()
        logger.info("Bye!")
