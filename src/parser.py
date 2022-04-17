import aiohttp

from src import logutil

logger = logutil.initLogger("parser")


class ConnectedAccounts:
    """ConnectedAccounts class"""
    async def _parse_github(self):
        """
        https://developer.github.com/v3/users/#get-a-single-user
        :return: The formatted GitHub profile url
        :rtype: str
        """
        logger.debug("Attempting to parse github...")
        try:
            _url = f"https://api.github.com/user/{self._id}"
            async with aiohttp.ClientSession() as _session, _session.get(_url) as _resp:
                _resp = await _resp.json()
                return _resp["html_url"]
        except Exception:  # noqa
            logger.warning("Falling back to inaccurate Github URL", exc_info=1)
            return f"https://github.com/{self._name}"

    def __init__(self, **kwargs) -> None:
        self._type = kwargs.pop("type", None)
        self._id = kwargs.pop("id", None)
        self._name = kwargs.pop("name", None)

    async def parse(self, **kwargs):
        """
        Parse connected account data

        :param kwargs:
        :type kwargs:
        :return: The formatted URL or name of the connected account
        :rtype: str
        """
        self._type = kwargs.pop("type", None)
        self._id = kwargs.pop("id", None)
        self._name = kwargs.pop("name", None)

        logger.debug("Parsing type: %s, id: %s, name: %s", self._type, self._id, self._name)

        if self._type == "battlenet":
            return self._name  # no api(?)
        elif self._type == "facebook":
            return f"https://facebook.com/{self._id}"
        elif self._type == "github":
            return await self._parse_github()
        elif self._type == "reddit":
            return f"https://reddit.com/u/{self._name}"  # no api(id)
        elif self._type == "spotify":
            return f"https://open.spotify.com/user/{self._id}"
        elif self._type == "steam":
            return f"https://steamcommunity.com/id/{self._id}"
        elif self._type == "twitch":
            return f"https://twitch.tv/{self._name}"  # avoid api
        elif self._type == "twitter":
            return f"https://twitter.com/{self._name}"  # avoid api
        elif self._type == "xbox":
            return self._name  # no api(?)
        elif self._type == "youtube":
            return f"https://youtube.com/channel/{self._id}"
        else:
            return self._name
