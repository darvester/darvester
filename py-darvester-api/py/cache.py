import logging
import time
from dataclasses import dataclass, field
from typing import Any, Union

logger = logging.getLogger("restful")


class Cache:
    def __init__(self, default_ttl: int = 60 * 5):
        """
        Rudimentary cache implementation designed to accustom simple cache storage and API request load bearing.

        :param default_ttl: The default TTL in seconds (default: 5 minutes)
        :type default_ttl: int
        """
        self.default_ttl: int = default_ttl
        self.ttl_store: dict = {}
        self.store: dict = {}

    @property
    def _now(self) -> int:
        """
        Get the current timestamp in seconds.

        :return: The current timestamp in seconds as an integer
        :rtype: int
        """
        return int(time.time())

    def get(self, key: Union[str, int]) -> Union[dict, bool, Any]:
        """
        Get an item from the cache.

        :param key: The Snowflake ID as an int or string
        :type key: Union[str, int]
        :return: The model, if not expired, else False
        :rtype: Union[dict, bool]
        """
        if ttl := self.ttl_store.get(str(key), False):
            if ttl < self._now:
                del self.store[str(key)]
                del self.ttl_store[str(key)]
                logger.debug(f"Deleted expired item {key} from cache.")
                return False
            logger.debug(f"Returned item {key} from cache.")
            return self.store.get(str(key), False)
        else:
            logger.debug(f"Item {key} not found in cache.")
            return False

    def set(self, key: Union[str, int], data: Union[dict, Any], ttl: int = False) -> bool:
        """
        Push an item to the cache at the specified key.

        :param key: The Snowflake ID as an int or string
        :type key: Union[str, int]
        :param data: The model data
        :type data: Union[dict, Any]
        :param ttl: The TTL in seconds
        :type ttl: int
        :return: Whether the item was set or not
        :rtype: bool
        """
        try:
            self.store[str(key)] = data
            self.ttl_store[str(key)] = self._now + (ttl if ttl else self.default_ttl)
            logger.debug(f"Set item {key} in cache with ttl {ttl if ttl else self.default_ttl}.")
            return True
        except (ValueError, AttributeError):
            logger.error(f"Failed to set item {key} in cache.", exc_info=True)
            return False


@dataclass
class Caches:
    """
    A centralized collection of caches. This is a dataclass to allow for easy initialization and organization of the
    entire cache backend. It also allows users to access items stored by the API backend.

    :param users: The users cache
    :type users: Cache
    :param guilds: The guilds cache
    :type guilds: Cache
    """

    users: Cache = field(default_factory=Cache)
    guilds: Cache = field(default_factory=Cache)
