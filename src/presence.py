import asyncio
from queue import Queue
import threading
import time
import pypresence
import selfcord as discord
# from threading import Thread

from src.logutil import initLogger
from cfg import ENABLE_PRESENCE
rp_logger = initLogger("RichPresence")
bs_logger = initLogger("BotStatus")
# You shouldn't change this, unless you know what you're doing
APPLICATION_ID = 926180199501025342

# try:
#     from cfg import ENABLE_PRESENCE
# except ImportError:
#     os.getenv("ENABLE_PRESENCE")

# if ENABLE_PRESENCE and os.getenv("ENABLE_PRESENCE") == "":
#     logger.critical("ENABLE_PRESENCE not set. Presence staying off...")
#     ENABLE_PRESENCE = False


class RichPresence():
    def __init__(self) -> None:
        if ENABLE_PRESENCE:
            q = Queue()
            rp_logger.debug("Queue created")
            self.queue = q

    def _thread_run(self, queue):
        rp_logger.info("RichPresenceThread started")
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        _logger = initLogger("rpc_thread")
        try:
            RPC = pypresence.Presence(APPLICATION_ID, pipe=0)
            RPC.connect()
            RPC.update(state="Idle",
                       details="Harvesting with Darvester",
                       start=int(time.time()),
                       large_image="darvester_1-1",
                       buttons=[
                        {
                            "label": "Get Darvester",
                            "url":
                            "https://github.com/V3ntus/darvester"
                        },
                        {
                            "label": "V3ntus' Website",
                            "url":
                            "https://v3ntus.github.io"
                        }
                        ]
                       )
            while True:
                _logger.debug("Waiting for queue presence message...")
                message = queue.get()
                _logger.debug("Got " + ", ".join(message))
                RPC.update(state=message[1],
                           details=message[0],
                           start=int(time.time()),
                           end=int(time.time() + 60) if message[2] == "cooldown" else None,  # noqa
                           large_image="darvester_1-1",
                           buttons=[
                                {
                                    "label": "Get Darvester",
                                    "url":
                                    "https://github.com/V3ntus/darvester"
                                },
                                {
                                    "label": "V3ntus' Website",
                                    "url":
                                    "https://v3ntus.github.io"
                                }
                            ]
                           )
                _logger.info("Updated presence")
                queue.task_done()
                while not queue.empty():
                    try:
                        queue.get(False)
                    except queue.Empty:
                        continue
                    queue.task_done()
                _logger.debug("Cleared queue")
                # time.sleep(15)
        except:  # noqa
            _logger.critical("Exception happened", exc_info=1)

    def get_queue(self) -> Queue:
        return self.queue if ENABLE_PRESENCE else None

    def start_thread(self):
        if ENABLE_PRESENCE:
            _t = threading.Thread(target=self._thread_run,
                                  args=(self.queue,))
            _t.start()
        else:
            rp_logger.warning(
                "ENABLE_PRESENCE is False. Not starting a thread")

    def put(self, message):
        if ENABLE_PRESENCE:
            rp_logger.debug("Put " + ", ".join(message))
            self.queue.put_nowait(message)


class BotStatus():
    """Bot custom status class"""
    "This is for the bot"
    def __init__(self) -> None:
        bs_logger.debug("BotStatus init")
        self._ts_now = int(time.time())

    async def update(self, client,
                     activity: object = discord.Game,
                     state: str = None,
                     status: discord.Status = discord.Status.idle):
        """Update status

        Args:
            client (discord.Client): the client instance
            activity (object, optional): Defaults to discord.Game.
            state (str, optional): Defaults to "Idle".
            status (discord.Status, optional): Defaults to discord.Status.idle.
        """

        # Change the presence
        if ENABLE_PRESENCE:
            bs_logger.info("Changing presence...")
            bs_logger.debug("{'activity': %s, 'state': '%s', 'status': %s}" %
                            (activity, state, status))
            state = "Darvester - Idle" if state is None else "Darvester - " + state  # noqa

            await client.change_presence(
                activity=discord.activity.CustomActivity(
                    state,
                    emoji="⛏️"
                )
            )
            await client.change_presence(activity=discord.Game("Darvester"),
                                         status=status)
