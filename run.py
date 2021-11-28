import sys
import os
import sqlite3
import json
import time
# from pprint import pprint
import selfcord as discord
from selfcord.ext import commands
from cfg import TOKEN
# TOKEN = os.getenv("TOKEN")

if not os.path.exists(".agreed"):
    x = input("""
!! DISCLAIMER: !!
Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.
Do you agree? [y/N] """)
    if x.lower() != "y":
        print("Invalid input, exiting")
        sys.exit(1)
    else:
        with open(".agreed", "x") as f:
            f.close()
        print("Continuing...")


class DictDiffer(object):
    """
    Calculate the difference between two dictionaries as:
    (1) items added
    (2) items removed
    (3) keys same in both but changed values
    (4) keys same in both and unchanged values
    """
    def __init__(self, current_dict, past_dict):
        self.current_dict, self.past_dict = current_dict, past_dict
        self.set_current, self.set_past = set(current_dict.keys()),set(past_dict.keys())  # noqa
        self.intersect = self.set_current.intersection(self.set_past)

    def added(self):
        return self.set_current - self.intersect

    def removed(self):
        return self.set_past - self.intersect

    def changed(self):
        return {o for o in self.intersect if self.past_dict[o] != self.current_dict[o]}  # noqa

    def unchanged(self):
        return {o for o in self.intersect if self.past_dict[o] == self.current_dict[o]}  # noqa


class SQLiteNoSQL:
    """Open the database on module init"""
    def __init__(self, f):
        self.dbfile = f
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()
        self.cur.execute("""
            CREATE TABLE IF NOT EXISTS \
                users(data TEXT UNIQUE, id INTEGER UNIQUE);""")

    def open(self, f):
        """Open connection"""
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()

    def close(self):
        """Close connection"""
        try:
            self.db.commit()
            self.db.close()
            print("Database closed")
        except:  # noqa: E722
            print("Something happened trying to close the database")

    def addrow(self, d, id, table):
        """Add row to database"""
        # Check if row already exists for user_id
        try:
            self.cur.execute(f"SELECT data FROM {table} WHERE id = ?", (id,))
            data = self.cur.fetchone()

            # If data returned is none, try to append a first_seen
            if data is None:
                print("User is first_seen " + str(int(time.time())))
                d["first_seen"] = int(time.time())

            # Else, this code will throw IntegrityError and continue flow below
            self.db.execute(f"INSERT INTO {table} VALUES (?, ?);",
                            (json.dumps(d), id,))
        except sqlite3.ProgrammingError:
            # Sometimes, the database closes prematurely
            # My code sucks
            print("Reopenning database...")
            self.open(self.dbfile)
        except sqlite3.IntegrityError:
            # Process an already existent row
            print(f"Already exists: {id}\nUpdating info...")

            # Use the 'data' from our try
            try:
                for item in data:
                    diff1 = json.loads(item[0])
            except json.decoder.JSONDecodeError:
                for item in data:
                    diff1 = json.loads(item)

            # Don't override first_seen
            d["first_seen"] = diff1["first_seen"]

            # Update row
            self.db.execute(f"""
            UPDATE OR IGNORE {table} SET (data, id) = (?, ?) WHERE id = ?""",
                            (json.dumps(d), id, id,))

            # Check for changes
            if diff1 == d:
                print("Nothing changed")
            else:
                _diff = DictDiffer(diff1, d)
                print("Info updated\n--------------")
                print("Added: ", _diff.added())
                print("Removed: ", _diff.removed())
                print("Changed: ", _diff.changed())

    def find(self, query):
        for k, v in query.items():
            if isinstance(v, str):
                query[k] = f"'{v}'"
        q = ' AND '.join(f" json_extract(data, '$.{k}') = \
            {v}"for k, v in query.items())
        for r in self.db.execute(f"SELECT * FROM main WHERE {q}"):
            yield r[0]


db = SQLiteNoSQL("harvested.db")


client = commands.Bot(command_prefix=",",
                      case_insensitive=True,
                      user_bot=True,
                      guild_subscription_options=discord.GuildSubscriptionOptions.default())  # noqa: E501


@client.event
async def on_ready():
    print(f"Logged in as {client.user}")
    print("Starting guild ID dump...")
    request_number = 0
    listofguilds = [guild.id for guild in client.guilds]
    for guildid in listofguilds:
        guild = client.get_guild(guildid)
        print("Now working in guild: " + guild.name)
        """
        Do member/users harvest
        """
        for member in guild.members:
            # Filter for bot and Discord system messages
            if not member.bot and not member.system:
                if request_number <= 100:
                    profileobj = await client.fetch_user_profile(member.id)
                    """
                    guilds {
                        {
                            id: 1294710923,
                            joined_at: 123920948
                        },
                        {
                            id: 438721983742,
                            joined_at: 397298734
                        },
                    }
                    """
                    ug = {"guilds": []}
                    for mguild in profileobj.mutual_guilds:
                        ug["guilds"].append(mguild.id)

                    post = {'name': member.name,
                            'discriminator': member.discriminator,
                            # Simple implementation of mutual guilds
                            'mutual_guilds': [ug],
                            'avatar_url': str(member.avatar_url),
                            'public_flags': member.public_flags.all(),
                            # 'first_seen': int(time.time()),
                            'created_at': int(member.created_at.timestamp()),
                            'connected_accounts': profileobj.connected_accounts,  # noqa
                            }
                    print(f"""
Inserting {member.id} & {member.name}#{member.discriminator}:""")
                    db.addrow(post, member.id, "users")
                    request_number += 1
                else:
                    db.close()  # Commit changes
                    print("Request cooldown...")
                    for i in range(60, 0, -1):
                        sys.stdout.write('\r')
                        sys.stdout.write("{:2d} remaining".format(i))
                        sys.stdout.flush()
                        time.sleep(1)

        """
        Do guild harvest
        """
        """
        for guild in listofguilds:
            print()
        """

    db.close()
client.run(TOKEN)
