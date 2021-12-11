import selfcord as discord
from selfcord.ext import commands
from src.sqlutil import SQLiteNoSQL
from src import logutil

logger = logutil.initLogger("harvester")


class Harvester:
    """Main class for bot"""
    def __init__(self) -> None:
        # Define a set that will be used to check against later
        self._id_array = set()
        # Setup database
        self.db = SQLiteNoSQL("harvested.db")
        self.cur = self.db.cursor()

    async def harvest():
        pass

    async def thread_start(self):
        pass

    async def close(self):
        await self.db.close()
