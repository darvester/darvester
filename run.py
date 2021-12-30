import asyncio
import os
import sys
import traceback
from datetime import datetime

import selfcord as discord
from selfcord.ext import commands

from src import logutil
from src.harvester import Harvester
from src.sqlutil import SQLiteNoSQL

harvester = Harvester()
db = SQLiteNoSQL("harvested.db")

# Setup logging
logger = logutil.initLogger()

# BEGIN token import
try:
    from cfg import TOKEN
except ImportError:
    TOKEN = os.getenv("TOKEN")

if TOKEN and os.getenv("TOKEN") == "":
    logger.critical(
        "TOKEN not found. Declare TOKEN in your environment or set \
it in cfg.py"
    )
    sys.exit(1)
# END token import


# BEGIN user agreement
if not os.path.exists(".agreed"):
    x = input(
        """
!! DISCLAIMER: !!
Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.
Do you agree? [y/N] """
    )
    if x.lower() != "y" or "yes":
        print("Invalid input, exiting")
        sys.exit(1)
    else:
        with open(".agreed", "x") as f:
            f.close()
        print("Continuing...")
# END user agreement

# Setup bot client
logger.info("Connecting to gateway... Be patient")
client = commands.Bot(
    command_prefix=",",
    case_insensitive=True,
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
        await message.channel.send("Help: `,select [USER ID HERE]`")

    if not message.content.upper().startswith(",SELECT"):
        return
    logger.info('"%s" - initiated a select command', message.author.name)
    if len(message.content) > 7:
        try:
            data = db.find(
                message.content[7:].lstrip().rstrip(),
                "users",
            )
            if data:
                _connected_accounts = "".join(
                    f"- {i['type']} - {i['name']}\n"
                    for i in data["connected_accounts"]
                )

                _message = f"""
Name: `{data["name"]}#{data["discriminator"]}`
Bio: ```{data["bio"]}```
Mutual Guilds: `{data["mutual_guilds"]["guilds"]}`
Avatar: {data["avatar_url"]}
Account Created At: `{datetime.fromtimestamp(data["created_at"])}`
Connected Accounts:
```
{_connected_accounts}
```
"""
                logger.info(
                    'Found "%s" requested by user "%s"',
                    (data["name"], message.author.name),
                )
                await message.channel.send(_message)
            else:
                await message.channel.send(
                    "Query returned empty. User not\
found"
                )
        except Exception as e:  # noqa
            logger.warning(",select triggered exception")
            traceback.print_exc()
            await message.channel.send(
                "Something wrong happened:```py \
%s \
```"
                % (e)
            )
            await asyncio.sleep(2)
            await message.channel.send("```%s```" % traceback.format_exc())
    else:
        await message.channel.send("Please include a user ID")


# Load cogs here
# Login with bot
client.run(TOKEN)
