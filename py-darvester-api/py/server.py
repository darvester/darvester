import asyncio
import logging
import sqlite3

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from time import sleep
from uvicorn import Config, Server

from py.cache import Caches
# from py.database import Database

logger = logging.getLogger("api")


class DarvesterAPI:
    def __init__(self, **kwargs):
        """
        Darvester API backend server.

        :param host: The host to bind to. (default: '0.0.0.0')
        :type host: str
        :param port: The port to listen on. (default: 8080)
        :type port: int
        :param debug: Enable debug mode. (default: false)
        :type debug: bool
        :param caches: The caches to use.
        :type caches: Caches
        """
        self._loop: asyncio.AbstractEventLoop = asyncio.get_event_loop()

        self.api: FastAPI = FastAPI()
        self.host: str = kwargs.get('host', '0.0.0.0')
        self.port: int = kwargs.get('port', 8080)
        self.debug: bool = kwargs.get('debug', False)

        self.api.add_middleware(
                CORSMiddleware,
                allow_origins=["*"],
                allow_credentials=["*"],
                allow_methods=["*"],
                allow_headers=["*"]
        )
        if self.debug:
            logging.basicConfig(level=logging.DEBUG)
            logger.debug("Debug mode enabled.")

        logger.info("Initializing API server")

        self.config: Config = Config(
            app=self.api,
            loop=self._loop,  # type: ignore
            host=self.host,
            port=self.port,
            debug=self.debug,
            log_level="debug" if self.debug else "info"
        )
        self.server: Server = Server(self.config)

        self.db_file: str = kwargs.get('db', "harvested.db")

        # Method aliases
        self.get = self.api.get
        self.post = self.api.post
        self.delete = self.api.delete
        self.put = self.api.put
        self.options = self.api.options
        self.head = self.api.head
        self.patch = self.api.patch
        self.trace = self.api.trace

        if kwargs.get("caches", False) and isinstance(kwargs.get("caches"), Caches):
            self.caches: Caches = kwargs.get("caches")
        else:
            self.caches: Caches = Caches()

    def setup(self):
        def _stop_loop():
            for task in asyncio.all_tasks(self._loop):
                while not task.cancel():
                    sleep(1)
                    logger.info(task.get_coro().__name__ + " still cancelling")
            self._loop.stop()

        # Start the uvicorn server
        self._loop.create_task(self.server.serve())

        # Prevent duplicate log messages
        # This isn't working currently
        if len(logging.getLogger("uvicorn").handlers) > 1:
            logging.getLogger("uvicorn").removeHandler(logging.getLogger("uvicorn").handlers[0])

        self.api.on_event("shutdown")(_stop_loop)
        logger.info(f"Serving Uvicorn server on: {self.host}:{self.port}")
        self._loop.run_forever()

    def db_connect(self):
        return sqlite3.connect(self.db_file)
