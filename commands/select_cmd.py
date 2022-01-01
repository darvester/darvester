from datetime import datetime
import traceback
from src import logutil, parser
parse = parser.ConnectedAccounts()

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
                _bio = data["bio"].replace("`", "-")

                _connected_accounts = []
                for _i in data["connected_accounts"]:
                    _p = await parse.parse(
                        type=_i["type"],
                        name=_i["name"],
                        id=_i["id"]
                    )
                    _connected_accounts.append(
                        f"`{_i['type']} - {_i['name']}`\n{_p}\n ---"
                    )

                _connected_accounts = "\n".join(_connected_accounts)

                _mutual_guilds = []
                for _i in data["mutual_guilds"]["guilds"]:
                    _result = db.find(_i, "guilds", "name")
                    if _result is not None:
                        _mutual_guilds.append(_result)
                    else:
                        _mutual_guilds.append(str(_i))

                _mutual_guilds = "\n".join(_mutual_guilds)

                _message = f"""
__Name__: `{data["name"]}#{data["discriminator"]}`
__Bio__: ```{_bio}```
__Avatar__: {data["avatar_url"]}
__Account Created At__: `{datetime.fromtimestamp(data["created_at"])}`
"""  # TODO print name of guild (log guild to database)
                if _mutual_guilds != "\n":
                    _message += f"""
__Mutual Guilds__: ```
{_mutual_guilds}
```"""
                if _connected_accounts != "\n":
                    _message += f"""
__Connected Accounts__:
{_connected_accounts}"""
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
                "Something wrong happened:```py\n \
%s \
```"
                % (e)
            )
