import sys
import os
import asyncio
from src.sqlutil import SQLiteNoSQL
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


db = SQLiteNoSQL("harvested.db")
cur = db.cursor()

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
                if request_number <= 50:
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
                        await asyncio.sleep(1)
                    request_number = 0

        """
        Do guild harvest
        """
        """
        for guild in listofguilds:
            print()
        """

    db.close()


@client.command()
async def get_member_by_id(ctx, id: str):
    print("yes")

client.run(TOKEN)
