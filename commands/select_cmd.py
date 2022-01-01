import random
from datetime import datetime
import traceback
from src import logutil, parser
parse = parser.ConnectedAccounts()

logger = logutil.initLogger("select_cmd")


async def _do_guild_lookup(db, id, ctx):
    try:
        data = db.find(id, "guilds")
        if data:
            _features = ", ".join(data["features"])
            _message = f"""
__Guild Name__: `{data["name"]}`
__Guild Icon__: {data["icon"]}
__Guild Owner__: `{data["owner"]["name"]} = {data["owner"]["id"]}`
__Description__:
```
{data["description"]}
```
__Boosts__: `{data["premium_tier"]}`
"""
            if data["features"] != []:
                _message += f"""
__Features__: {_features}"""

            await ctx.channel.send(_message)
        else:
            await ctx.channel.send("Guild not found either")
    except Exception as e:
        logger.error(",select guild lookup raised exception", exc_info=1)
        await ctx.channel.send("Something wrong happened: ```\n%s```" % e)


async def _main(message, db):
    logger.info('"%s" - initiated a select command', message.author.name)
    _hello_there = [
        "Oh hey there. I'll get that right out for you...",
        "Gotcha. Give me a second to look that up",
        "Oh cool. One sec...",
        "Nice I'll check it out...",
        "Hm lemme see if I have that",
        "Hold on, let me see..."
    ]
    await message.channel.send(random.choice(_hello_there))
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
                    "Query returned empty. User not \
found. Trying to find guild..."
                )
                await _do_guild_lookup(db,
                                       message.content[7:].lstrip().rstrip(),
                                       message)
        except Exception as e:  # noqa
            logger.warning(",select triggered exception")
            traceback.print_exc()
            await message.channel.send(
                "Something wrong happened:```py\n \
%s \
```"
                % (e)
            )
