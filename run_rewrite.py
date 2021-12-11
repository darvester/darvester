import sys
import os
import asyncio
import time

from selfcord.ext import commands
import selfcord as discord
from src.sqlutil import SQLiteNoSQL
from src import logutil
from src.harvester import Harvester

# Setup logging
logger = logutil.initLogger()

# BEGIN token import
try:
    from cfg import TOKEN
except ImportError:
    TOKEN = os.getenv("TOKEN")

if TOKEN and os.getenv("TOKEN") is not None:
    logger.critical("TOKEN not found. Declare TOKEN in your environment or set \
it in cfg.py")
    sys.exit(1)
# END token import


# BEGIN user agreement
if not os.path.exists(".agreed"):
    x = input("""
!! DISCLAIMER: !!
Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.
Do you agree? [y/N] """)
    if x.lower() != "y" or "yes":
        print("Invalid input, exiting")
        sys.exit(1)
    else:
        with open(".agreed", "x") as f:
            f.close()
        print("Continuing...")
# END user agreement

# Setup bot client
client = commands.Bot(command_prefix=",",
                      case_insensitive=True,
                      user_bot=True,
                      guild_subscription_options=discord.GuildSubscriptionOptions.default())  # noqa: E501


# on_ready event
@client.event
async def on_ready():
    try:
        await Harvester.thread_start()
    except KeyboardInterrupt:
        await Harvester.close()

# Load cogs here
# Login with bot
client.run(TOKEN)
