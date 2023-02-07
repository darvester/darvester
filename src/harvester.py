import asyncio
import base64
import sys
import time
from datetime import datetime
from itertools import islice

import aiohttp
import discord
import enlighten
from discord.ext.commands import Bot

from cfg import (
    DEBUG,
    DISABLE_VCS,
    IGNORE_GUILD,
    LAST_SCANNED_INTERVAL,
    QUIET_MODE,
    SWAP_IGNORE,
    TOKEN,
    USE_DISCOVERY,
)
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

if DEBUG:
    from pprint import pprint
else:
    pprint = logger.debug


class Harvester:
    """Main class for bot"""

    def __init__(self) -> None:
        # Define a set that will be used to check against later
        self._id_array = set()
        # Setup database
        self.db = SQLiteNoSQL("harvested.db")
        self.cur = self.db.cursor
        self.user_agent: str = ""
        if not DISABLE_VCS:
            self._repo = git.init_repo()

    async def grab_discoverable_guilds(self, offset: int = 0, limit: int = 10):
        logger.debug(
            "Grabbing guilds from Discover tab with offset {} and limit {}...".format(offset, limit)
        )
        async with aiohttp.ClientSession() as session:
            async with session.get(
                "https://discord.com/api/v9/discoverable-guilds?offset={}&limit={}".format(
                    offset, limit
                ),
                headers={
                    "authority": "discord.com",
                    "authorization": TOKEN,
                    "referer": "https://discord.com/guild-discovery",
                    "user-agent": self.user_agent,
                    "sec-fetch-dest": "empty",
                    "sec-fetch-mode": "cors",
                    "sec-fetch-site": "same-origin",
                    "x-discord-locale": "en-US",
                    "x-super-properties": str(
                        base64.b64encode(
                            bytes(
                                str(
                                    {
                                        "os": "Mac OS X",
                                        "browser": "Discord Client",
                                        "release_channel": "stable",
                                        "client_version": "0.0.269",
                                        "os_version": "21.6.0",
                                        "os_arch": "x64",
                                        "system_locale": "en-US",
                                        "client_build_number": 159692,
                                        "client_event_source": None,
                                    }
                                ),
                                encoding="utf-8",
                            )
                        )
                    ),
                },
            ) as resp:
                if not resp.ok:
                    logger.debug(
                        f"grab_discoverable_guilds failed with status {resp.status},"
                        + f' reason "{resp.reason}".'
                    )
                    return None
                res = await resp.json()
                logger.debug(f"Got {len(res['guilds'])} guilds from Discover:")
                pprint(res)
                return res

    async def thread_start(self, client: Bot):
        """The main entry method for the harvester"""
        term_status: enlighten.StatusBar = ui.status_bars["main"]
        member_status: enlighten.StatusBar = ui.status_bars["member"]
        guild_status: enlighten.StatusBar = ui.status_bars["guild"]
        init_counter: enlighten.Counter = ui.counters["init"]
        init_counter.update()

        RichPresence.put(message=["Darvester", "Preparing...", ""])
        set_title("Darvester - Preparing...")
        logger.info("Logged in as %s", client.user.name if not QUIET_MODE else "user")

        await BotStatus.update(client=client, state="Preparing")
        self.user_agent = client.http.user_agent

        try:
            while True:
                self.db.open()
                _request_number = 0  # For our rate limiting
                # Store all guilds bot/user is in
                _list_of_guilds = [guild.id for guild in client.guilds]
                _discovered_guilds = []

                if USE_DISCOVERY:
                    _d_guilds: dict = await self.grab_discoverable_guilds()
                    if not _d_guilds:
                        logger.warning(
                            "Could not grab guilds from Discover tab. Check debug for more details"
                        )
                    else:
                        _d_guild: dict
                        for _d_guild in _d_guilds.get("guilds", []):
                            if _d_guild["id"] not in _list_of_guilds:
                                try:
                                    client.guilds.append(await client.join_guild(_d_guild["id"]))
                                    _discovered_guilds.append(_d_guild["id"])
                                    _list_of_guilds.append(_d_guild["id"])
                                    logger.info("Joined guild from Discover: " + _d_guild["name"])
                                    await asyncio.sleep(1)
                                except discord.NotFound:
                                    logger.error(
                                        f"Error joining guild {_d_guild['name']} from Discover, guild does "
                                        "not exist or has disabled discovery"
                                    )
                                except discord.HTTPException as e:
                                    if (
                                        e.status == 400
                                        and "Maximum number of server members reached" in e.text
                                    ):
                                        logger.error(
                                            f"Error joining guild {_d_guild['name']} from Discover, server "
                                            "is full"
                                        )
                                        continue
                                    else:
                                        raise e from e
                            else:
                                logger.info(f"Skipping {_d_guild['name']} as already joined...")

                guild_counter = ui.new_counter(
                    name="guild",
                    total=len(_list_of_guilds),
                    description="Guilds",
                    unit="guilds",
                )

                for guildidx, guildid in enumerate(_list_of_guilds, start=1):
                    # Update counter
                    guild_counter.update()
                    if guildidx >= len(_list_of_guilds):
                        guild_counter.clear()

                    if (guildid in IGNORE_GUILD and not SWAP_IGNORE) or (
                        guildid not in IGNORE_GUILD and SWAP_IGNORE
                    ):
                        logger.warning(
                            "Guild %s ignored. Skipping...",
                            guildid if not QUIET_MODE else "Guild ignored. Skipping...",
                        )
                        continue

                    guild: discord.Guild = client.get_guild(guildid)

                    _should_ignore_guild: bool = False
                    for ignored_guild in IGNORE_GUILD:
                        if isinstance(ignored_guild, str):
                            if (
                                ignored_guild.lower() in guild.name.lower() and not SWAP_IGNORE
                            ) or (ignored_guild.lower() not in guild.name.lower() and SWAP_IGNORE):
                                logger.warning(
                                    'Guild "%s" ignored. Skipping...',
                                    guild.name if not QUIET_MODE else "Guild ignored. Skipping...",
                                )
                                _should_ignore_guild = True
                    if _should_ignore_guild:
                        continue

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

                    term_status.update(
                        demo=f"Harvesting {_g_name} with {len(guild.members)} members"
                    )
                    guild_status.update(demo=f"Name: {_g_name} | Description: {_g_desc}")

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

                    logger.debug('GUILD: Inserting guild "%s" = "%s"', guild.id, guild_data["name"])

                    self.db.addrow(guild_data, guild.id, "guilds")
                    _request_number += 1

                    # Mark as read, as "done"
                    await guild.ack()
                    member_counter = ui.new_counter(
                        name="member",
                        total=len(guild.members),
                        description="Members",
                        unit="members",
                        leave=False,
                    )

                    # Do member/user harvest
                    member: discord.Member
                    for memberidx, member in enumerate(guild.members, start=1):
                        # Update member counter
                        member_counter.update()
                        if memberidx >= len(guild.members):
                            member_counter.clear()

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
                                "premium_since": str(
                                    int(_profile_object.premium_since.timestamp())
                                    if _profile_object.premium_since
                                    else None
                                ),
                                "banner": str(_profile_object.banner),
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

                            member_status.update(
                                demo=f"Name: {_name}"
                                + f" | Bio: {_bio}"
                                + " | Created at: "
                                + str(datetime.fromtimestamp(int(data["created_at"])))
                                if not QUIET_MODE
                                else '"quiet mode"'
                            )

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
                            term_status.update(demo="On cooldown")
                            term_status.refresh()
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
                            term_status.update(
                                demo="Harvesting " + guild.name
                                if not QUIET_MODE
                                else "a guild" + f" with {len(guild.members)} members"
                            )
                            term_status.refresh()
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
                term_status.update(demo="Reached end of guild list")
                logger.info("That's all the guilds! Sleeping for a bit then looping")
                RichPresence.put(message=["- Discord OSINT harvester", "- Created by V3ntus", ""])
                set_title("Darvester - Created by V3ntus")
                await asyncio.sleep(1)
                term_status.refresh()

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

        except discord.errors.CaptchaRequired:
            logger.critical(
                "CaptchaRequired error hit. Please report this at https://github.com/darvester/darvester/issues",
                exc_info=DEBUG
            )
            self.close()
        except discord.errors.HTTPException as e:
            logger.critical(
                "HTTP 429 returned. You may have been temp banned. "
                "Try again later (may take a couple hours or as long as a day)"
                if int(e.status) == 429 else f"{e.status}: {e.text}",
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
        sys.exit()
