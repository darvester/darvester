import sys, os
if not os.path.exists(".agreed"):
    x = input("""
!! DISCLAIMER: !!
Using this tool, you agree not to hold the contributors and developers accountable for any damages that occur. This tool violates Discord terms of service and may result in your access to Discord services terminated.
Do you agree? [y/N] """)
    if x.lower() != "y":
        print("Invalid input, exiting")
        sys.exit(1)
    else:
        with open(".agreed", "x") as f:
            f.close()
        print("Continuing...")

TOKEN = os.getenv("TOKEN")
from cfg import TOKEN

import selfcord as discord
from selfcord.ext import commands

client = commands.Bot(command_prefix=",",
    case_insensitive=True,
    user_bot=False,
    guild_subscription_options=discord.GuildSubscriptionOptions.default())

@client.event
async def on_ready():
    print("Logged in as {0.user}".format(client))
    print("Starting guild ID dump...")
    listofguilds = [guild.id for guild in client.guilds]
    for guildid in listofguilds:
        guild = client.get_guild(guildid)
        print(guild.members)

client.run(TOKEN)
