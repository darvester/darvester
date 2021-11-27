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
import sqlite3, datetime

con = sqlite3.connect("harvested.db")
cur = con.cursor()

# Create initial table if it doesn't exist
cur.execute('''CREATE TABLE IF NOT EXISTS users (name text, user_id integer UNIQUE, public_flags text)''')

client = commands.Bot(command_prefix=",",
    case_insensitive=True,
    user_bot=False,
    guild_subscription_options=discord.GuildSubscriptionOptions.default())

@client.event
async def on_ready():
    print("Logged in as {0.user}".format(client))
    print("Starting guild ID dump...")
    for guildid in [guild.id for guild in client.guilds]:
        guild = client.get_guild(guildid)
        for member in guild.members:
            if not member.bot or not member.system:
                # if member isn't a bot or a Discord system user
                try:
                    print(f"Inserting {member.name}, {member.id}")
                    cur.execute("INSERT INTO users VALUES (?, ?, ?)",
                        (member.name,
                            member.id,
                            member.public_flags.all() # instead of all(), use value?
                        )
                            # int(member.created_at.timestamp()),
                    )
                    con.commit()
                except sqlite3.IntegrityError:
                    # try ALTER to insert guild_id
                    print(f"Already exists: {member.id} for {member.name}")
        

client.run(TOKEN)