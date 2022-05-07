import json
from discord import Message
from discord.ext.commands import Bot

from src.sqlutil import SQLiteNoSQL
from src import logutil

logger = logutil.initLogger(__name__)


async def main(message: Message, client: Bot, db: SQLiteNoSQL):
    if message.author.id == client.user.id:
        return

    logger.debug(f"{message.author.name} - initiated the info command")
    _user_data = [json.loads(i[0]) for i in db.cur.execute("SELECT data FROM users;").fetchall()]
    _connected_accounts = len([i for a in _user_data for i in a["connected_accounts"] if a])
    _info_msg = f"**Info:**\nTotal users: `{db.users_count}`\nTotal guilds: `{db.guilds_count}`\n"
    _info_msg += f"Connected accounts: `{_connected_accounts}`\n"
    _nitro_users: int = 0
    for i in _user_data:
        try:
            _nitro_users += 1 if i["premium"] else 0
        except KeyError:
            pass

    _info_msg += f"Nitro users: `{_nitro_users}`\n"

    await message.channel.send(_info_msg)
