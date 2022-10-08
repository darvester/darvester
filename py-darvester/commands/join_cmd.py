from discord import HTTPException, Message, NotFound
from discord.ext.commands import Bot

from src import logutil

logger = logutil.initLogger("join_cmd")


async def main(message: Message, client: Bot):
    """
    Join a server from a server invite link

    :param message: The message object
    :type message: discord.Message
    :param client: The Discord Bot client instance
    :type client: discord.ext.commands.Bot
    :return: None
    :rtype: None
    """
    args = message.content.split(" ")
    logger.info('"%s" - initiated an invite command. args: %s', message.author.name, args)
    if len(args) > 1:
        try:
            client.guilds.append(await client.accept_invite(str(args[1])))
            await message.channel.send(f"Joined {client.guilds[-1].name}")
            logger.info(
                'New guild added to cache: "%s" = %s', client.guilds[-1].name, client.guilds[-1].id
            )
        except (NotFound, HTTPException) as e:
            await message.channel.send(
                "Failed to join the guild: HTTPException\n```py\n{}```".format(e)
            )
    else:
        await message.channel.send(
            "Please provide a valid invite link\nExample: `,join discord.gg/xxxxxx`"
        )
