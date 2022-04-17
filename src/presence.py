import asyncio
import threading
import time
from queue import Queue

import pypresence
import selfcord as discord

from cfg import DEBUG, ENABLE_PRESENCE
from src.logutil import initLogger

rp_logger = initLogger("RichPresence")
bs_logger = initLogger("BotStatus")
# You shouldn't change this, unless you know what you're doing
APPLICATION_ID = 926180199501025342


class RichPresence:
    """RichPresence class"""
    def __init__(self) -> None:
        if ENABLE_PRESENCE:
            q = Queue()
            rp_logger.debug("Queue created")
            self.queue = q

    @staticmethod
    def _thread_run(queue):
        """
        Method to start the presence thread.
        :param queue: The queue used by the thread.
        :type queue: Queue
        """
        rp_logger.info("RichPresenceThread started")
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        _logger = initLogger("rpc_thread")
        try:
            RPC = pypresence.Presence(APPLICATION_ID, pipe=0)
            RPC.connect()
            RPC.update(
                state="Idle",
                details="Harvesting with Darvester",
                start=int(time.time()),
                large_image="darvester_1-1",
                buttons=[
                    {
                        "label": "Get Darvester",
                        "url": "https://github.com/V3ntus/darvester",
                    },
                    {"label": "V3ntus' Website", "url": "https://v3ntus.github.io"},
                ],
            )
            while True:
                _logger.debug("Waiting for queue presence message...")
                message = queue.get()
                if message == "RP_QUIT":
                    _logger.info("Got stop command. Breaking the rich presence loop...")
                    break
                _logger.debug("Got " + ", ".join(message))
                RPC.update(
                    state=message[1],
                    details=message[0],
                    start=int(time.time()),
                    end=int(time.time() + 60) if message[2] == "cooldown" else None,
                    large_image="darvester_1-1",
                    buttons=[
                        {
                            "label": "Get Darvester",
                            "url": "https://github.com/V3ntus/darvester",
                        },
                        {"label": "V3ntus' Website", "url": "https://v3ntus.github.io"},
                    ],
                )
                _logger.debug("Updated presence: {}".format(message))
                queue.task_done()
                while not queue.empty():
                    try:
                        queue.get(False)
                    except queue.Empty:
                        continue
                    queue.task_done()
                _logger.debug("Cleared queue")
        except ConnectionRefusedError:
            _logger.critical(
                "Could not connect to your Discord client " + "for rich presence. Is it running?"
            )
        except pypresence.exceptions.DiscordError:
            _logger.critical("A Discord error occurred while connecting to RPC", exc_info=DEBUG)
        except Exception:  # noqa
            _logger.critical("Exception happened", exc_info=1)

    @property
    def get_queue(self) -> Queue:
        """
        Returns the queue used by the rich presence thread.
        :return: The queue used by the rich presence thread.
        :rtype: Queue
        """
        return self.queue if ENABLE_PRESENCE else None

    def start_thread(self) -> threading.Thread:
        """
        Starts the rich presence thread.
        :return: The thread object if presence is enabled.
        :rtype: threading.Thread
        """
        if ENABLE_PRESENCE:
            _t = threading.Thread(target=self._thread_run, args=(self.queue,))
            _t.start()
            return _t
        else:
            rp_logger.warning("ENABLE_PRESENCE is False. Not starting a thread")

    def put(self, message):
        """
        Put a message in the presence thread queue.
        :param message:
        :type message:
        """
        if ENABLE_PRESENCE:
            rp_logger.debug("Put " + ", ".join(message))
            self.queue.put_nowait(message)


class BotStatus:
    """Bot custom status class"""
    def __init__(self) -> None:
        bs_logger.debug("BotStatus init")
        self._ts_now = int(time.time())

    @staticmethod
    async def update(
        client,
        activity: object = discord.Game,
        state: str = None,
        status: discord.Status = discord.Status.idle,
    ):
        """
        Update the bot's status

        :param client: discord.Client
        :type client: discord.Client
        :param activity: discord.Game
        :type activity: discord.Game
        :param state: The state to change to
        :type state: str
        :param status: The status to change to
        :type status: discord.Status
        """
        # Change the presence
        if ENABLE_PRESENCE:
            bs_logger.debug("Changing presence...")
            bs_logger.debug(
                "{'activity': %s, 'state': '%s', 'status': %s}", activity, state, status
            )
            state = "Darvester - Idle" if state is None else f"Darvester - {state}"

            await client.change_presence(
                activity=discord.activity.CustomActivity(state, emoji="⛏️")
            )
            await client.change_presence(activity=discord.Game("Darvester"), status=status)
