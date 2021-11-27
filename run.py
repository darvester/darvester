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
import sqlite3, json
from pprint import pprint

class sqlitenosql:
    def __init__(self, f):
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()
        self.cur.execute("CREATE TABLE IF NOT EXISTS main(data TEXT UNIQUE, id INTEGER UNIQUE);")

    def close(self):
        self.db.commit()
        self.db.close()

    def addrow(self, d, i):
        try:
            self.db.execute("INSERT INTO main VALUES (?, ?);", 
                (json.dumps(d), i,)
            )
        except sqlite3.IntegrityError:
            print(f"Already exists: {i}")

    def find(self, query):
        for k, v in query.items():
            if isinstance(v, str):
                query[k] = f"'{v}'"
        q = ' AND '.join(f" json_extract(data, '$.{k}') = {v}" for k, v in query.items())
        for r in self.db.execute(f"SELECT * FROM main WHERE {q}"):
            yield r[0]

db = sqlitenosql("harvested.db")

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
        for member in guild.members:
            if not member.bot and not member.system:
                post = {'name'  : member.name,
                        'id'    : member.id,
                        'public_flags': member.public_flags.all()}
                print(f"Inserting {member.id}:")
                pprint(post)
                db.addrow(post, member.id)
        db.close()

client.run(TOKEN)
