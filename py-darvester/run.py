# flake8: ignore = E402
import os
import sys

if sys.platform == "win32":
    os.system("cls")
else:
    os.system("clear")

help_message = """
__Help:__
`,select [user or guild ID]` = Select and send a row in the database with \
the ID you choose (in Snowflake form)
"""

from src.argparsing import _parse_args  # noqaL ignore = E402

args = _parse_args()

import discord  # noqa: ignore = E402
from discord.ext import commands  # noqa: ignore = E402
import asyncio # noqa: ignore = E402

from cfg import DEBUG_DISCORD  # noqa: ignore = E402
from cfg import DB_NAME, DEBUG, DISABLE_VCS, ENABLE_PRESENCE, QUIET_MODE  # noqa: ignore = E402
# Commands go here
from commands import filter_cmd, join_cmd, select_cmd, info_cmd  # noqa: ignore = E402
from src import logutil # noqa: ignore = E402
from src.harvester import Harvester  # noqa: ignore = E402
from src.sqlutil import SQLiteNoSQL  # noqa: ignore = E402
from src.ui import set_title  # noqa: ignore = E402

harvester = Harvester()
db = SQLiteNoSQL(DB_NAME)
db.init_fts_table("users")
db.init_fts_table("guilds")

# Setup logging
logger = logutil.initLogger()

# BEGIN user agreement
logger.info("""
!! DISCLAIMER: !!
Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.
""")
# END user agreement

if DEBUG_DISCORD:
    logging = logutil.getLogger("selfcord")

# BEGIN token import
try:
    from cfg import TOKEN
except ImportError:
    TOKEN = os.getenv("TOKEN")

if (TOKEN and os.getenv("TOKEN")) == "":
    logger.critical("TOKEN not found. Declare TOKEN in your environment or set it in cfg.py")
    sys.exit(1)
# END token import


if QUIET_MODE:
    logger.critical(
        "QUIET_MODE enabled. Your console/log output will be suppressed \n"
        + "and sensitive data will be hidden, but this will *not* affect the data \n"
        + "harvested. Continuing..."
    )

if DISABLE_VCS:
    logger.critical(
        "VCS system is disabled. Changes will not be logged in a git repository. Continuing..."
    )


class Bot(commands.Bot):
    """Inherits the commands.Bot class and adds a close method"""
    def __init__(self, *kargs, **kwargs):
        super().__init__(*kargs, **kwargs)
        # what am i doing with my life

    async def close(self):
        """Overrides the default close method to allow for graceful shutdown"""
        harvester.close()
        await super().close()


# Setup bot client
set_title("Darvester - Connecting")
logger.info("Connecting to gateway... Be patient")
client = Bot(
    command_prefix=",",
    case_insensitive=True,
    activity=None if not ENABLE_PRESENCE else discord.Game("Darvester"),
    user_bot=True,
    # guild_subscription_options=discord.GuildSubscriptionOptions.default(),
)  # noqa: E501


# on_ready event
@client.event
async def on_ready():
    """Event handler for when the bot is ready"""
    logger.info("Attempting to start Harvester thread...")
    try:
        await harvester.thread_start(client)
    except KeyboardInterrupt:
        logger.warning("KeyboardInterrupt caught. Closing...")
        harvester.close()
    except discord.errors.HTTPException:
        logger.critical(
            "HTTP 429 returned. You may have been temp banned! \
Try again later (may take a couple hours or as long as a day)",
            exc_info=DEBUG,
        )
        harvester.close()


# A simple command to respond to self
@client.event
async def on_message(message: discord.Message):
    """
    Event handler for when a message is received.

    :param message: discord.Message
    :type message: discord.Message
    """
    if message.content.upper() == ",HELP":
        await asyncio.sleep(1)
        async with message.channel.typing():
            await asyncio.sleep(2)
        await message.channel.send(help_message)

    if message.content.upper().startswith(",SELECT"):
        await asyncio.sleep(1)
        async with message.channel.typing():
            await asyncio.sleep(2)
        await select_cmd.main(message, db)

    if message.content.upper().startswith(",FILTER"):
        await asyncio.sleep(1)
        async with message.channel.typing():
            await asyncio.sleep(2)
        await filter_cmd.main(message, db)

    if message.content.upper().startswith(",JOIN"):
        await asyncio.sleep(1)
        async with message.channel.typing():
            await asyncio.sleep(2)
        await join_cmd.main(message, client)

    if message.content.upper().startswith(",INFO"):
        await asyncio.sleep(1)
        async with message.channel.typing():
            await asyncio.sleep(2)
        await info_cmd.main(message, client, harvester.db)


# Login with bot
try:
    client.run(TOKEN)
except Exception:
    logger.critical("Could not connect to the Discord gateway", exc_info=DEBUG)
