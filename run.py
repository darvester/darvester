# flake8: ignore = E402
import os
import sys
from distutils.util import strtobool
# BEGIN user agreement
if not os.path.exists(".agreed"):
    try:
        resp = input("""
!! DISCLAIMER: !!
Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.
Do you agree? [y/N] """
                     ).strip().lower()
        if resp == '' or not strtobool(resp):
            raise ValueError
    except ValueError:
        print("Invalid input. Exiting")
        sys.exit(1)
    with open(".agreed", "x") as f:
        f.close()
    print("Continuing...")
# END user agreement

help_message = """
__Help:__
`,select [user or guild ID]` = Select and send a row in the database with \
the ID you choose (in Snowflake form)
"""

from src.argparsing import _parse_args  # noqaL ignore = E402

args = _parse_args()

import selfcord as discord  # noqa: ignore = E402
from selfcord.ext import commands  # noqa: ignore = E402
from cfg import DEBUG_DISCORD, ENABLE_PRESENCE, DB_NAME, QUIET_MODE  # noqa: ignore = E402

from src import logutil  # noqa: ignore = E402
from src.harvester import Harvester  # noqa: ignore = E402
from src.sqlutil import SQLiteNoSQL  # noqa: ignore = E402
from src.termtitle import set_title  # noqa: ignore = E402

# Commands go here
from commands import (  # noqa: ignore = E402
    select_cmd,
    filter_cmd
)

harvester = Harvester()
db = SQLiteNoSQL(DB_NAME)
db.init_fts_table("users")
db.init_fts_table("guilds")

# Setup logging
logger = logutil.initLogger()

if DEBUG_DISCORD:
    logging = logutil.getLogger("selfcord")

# BEGIN token import
try:
    from cfg import TOKEN
except ImportError:
    TOKEN = os.getenv("TOKEN")

if (TOKEN and os.getenv("TOKEN")) == "":
    logger.critical(
        "TOKEN not found. Declare TOKEN in your environment or set \
it in cfg.py"
    )
    sys.exit(1)
# END token import


if QUIET_MODE:
    logger.critical("QUIET_MODE enabled. Your console/log output will be suppressed \n \
    and sensitive data will be hidden, but this will *not* affect the data \n \
    harvested. Continuing...")
# Setup bot client
set_title("Darvester - Connecting")
logger.info("Connecting to gateway... Be patient")
client = commands.Bot(
    command_prefix=",",
    case_insensitive=True,
    activity=None if not ENABLE_PRESENCE else discord.Game("Darvester"),
    user_bot=True,
    guild_subscription_options=discord.GuildSubscriptionOptions.default(),
)  # noqa: E501


# on_ready event
@client.event
async def on_ready():
    logger.info("Attempting to start Harvester thread...")
    try:
        await harvester.thread_start(client)
    except KeyboardInterrupt:
        logger.warning("KeyboardInterrupt caught. Closing...")
        await harvester.close()


# A simple command to respond to self
@client.event
async def on_message(message: discord.Message):
    if message.content.upper() == ",HELP":
        await message.channel.send(help_message)

    if message.content.upper().startswith(",SELECT"):
        await select_cmd._main(message, db)

    if message.content.upper().startswith(",FILTER"):
        await filter_cmd._main(message, db)

# Login with bot
client.run(TOKEN)
