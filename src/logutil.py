"""
Custom logging script

taken from:
https://github.com/V3ntus/repo-finder-bot/blob/main/utils/logutil.py
"""

import logging

from cfg import DEBUG, DEBUG_DISCORD, LOG_LEVEL


def getLogger(name):
    """Function to get a logger
    Useful for modules that have already initialized a logger,
    such as discord.py
    """
    __logger = logging.getLogger(name)
    __logger.setLevel(logging.DEBUG if DEBUG_DISCORD else LOG_LEVEL)
    __ch = logging.StreamHandler()
    __ch.setFormatter(CustomFormatter())
    __logger.addHandler(__ch)
    return __logger


def initLogger(name="root"):
    """Function to create a designated logger for separate modules"""
    __logger = logging.Logger(name)
    __ch = logging.StreamHandler()
    __ch.setLevel(logging.DEBUG if DEBUG else logging.INFO)
    __ch.setFormatter(CustomFormatter())
    __logger.addHandler(__ch)
    return __logger


class CustomFormatter(logging.Formatter):
    """Custom formatter class"""

    grey = "\x1b[38;1m"
    green = "\x1b[42;1m"
    yellow = "\x1b[43;1m"
    red = "\x1b[41;1m"
    bold_red = "\x1b[31;1m"
    reset = "\x1b[0m"

    format = "[%(levelname)-7s][%(name)-14s] \
[%(lineno)4s] %(message)s"
    FORMATS = (
        {
            logging.DEBUG: green
            + f"{reset}[%(asctime)s]{green}[%(levelname)-7s] \
[%(name)-14s]{reset}[{red}%(lineno)4s{reset}] %(message)s"
            + reset,
            logging.INFO: grey
            + f"{reset}[%(asctime)s]{grey}[%(levelname)-7s] \
[%(name)-14s]{reset}[{red}%(lineno)4s{reset}] %(message)s"
            + reset,
            logging.WARNING: yellow
            + f"[%(asctime)s][%(levelname)-7s][%(name)-14s] \
[{red}%(lineno)4s{reset}{yellow}] %(message)s"
            + reset,
            logging.ERROR: red
            + "[%(asctime)s][%(levelname)-7s][%(name)-14s] \
[%(lineno)4s] %(message)s"
            + reset,
            logging.CRITICAL: bold_red
            + "[%(asctime)s][%(levelname)-7s][%(name)-14s] \
[%(lineno)4s] %(message)s"
            + reset,
        }
        if DEBUG
        else {
            logging.DEBUG: reset,
            logging.INFO: grey + "[%(levelname)7s] %(message)s" + reset,
            logging.WARNING: yellow + "[%(levelname)7s] %(message)s" + reset,
            logging.ERROR: red + "[%(levelname)7s] %(message)s" + reset,
            logging.CRITICAL: bold_red + "[%(levelname)7s] %(message)s" + reset,
        }
    )
    # Documenting my dwindling sanity here

    def format(self, record):
        """Format the log message"""
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt, datefmt="%I:%M.%S%p")
        return formatter.format(record)
