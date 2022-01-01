from datetime import datetime
import traceback
import asyncio
from src import logutil

logger = logutil.initLogger("select_cmd")


async def _main(message, db):
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
__Name__: `{data["name"]}#{data["discriminator"]}`
__Bio__: ```{data["bio"]}```
__Mutual Guilds__: `{data["mutual_guilds"]["guilds"]}`
__Avatar__: {data["avatar_url"]}
___Account Created At__: `{datetime.fromtimestamp(data["created_at"])}`
__Connected Accounts__:
```
{_connected_accounts}
```
"""  # TODO print name of guild (log guild to database)
                logger.info(
                    'Found "%s" requested by user "%s"' %
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
