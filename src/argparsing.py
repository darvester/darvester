import argparse

import cfg


class FileReadError(Exception):
    pass


def _parse_args(*kargs, **kwargs):
    argparser = argparse.ArgumentParser(
        description="Darvester - PoC Discord guild and user information " +
        "harvester"
    )
    argparser.add_argument(
        "-ig",
        "--ignore-guild",
        metavar="FILE/GUILD_ID",
        help="Either a comma separated list of guild IDs in a text file, or "
        + "a single guild ID passed. Darvester will ignore the guild(s) "
        + "specified here.",
    )
    argparser.add_argument(
        "-v", "--debug", help="Enable verbose debug messages.",
        action="store_true"
    )
    argparser.add_argument(
        "-vv",
        "--debug-discord",
        help="Enable debug messages from Discord.py (can get pretty spammy!).",
        action="store_true",
    )
    argparser.add_argument(
        "-p",
        "--enable-presence",
        help="Enable rich presence for bot and client.",
        action="store_true",
    )
    argparser.add_argument(
        "--db", metavar="harvested.db", help="The database file to log into."
    )
    argparser.add_argument(
        "-q",
        help="Enable quiet mode to suppress some info going to the console.",
        action="store_true",
    )
    argparser.add_argument(
        "--whitelist",
        "-w",
        metavar="FILE/USER_ID",
        help="Either a comma separated list of user IDs in a text file, or"
        + " a single user ID passed. Darvester will only respond to this user"
        + "when commands are issued.",
    )
    argparser.add_argument(
        "--last-scanned",
        "-ls",
        help="The amount of time (in seconds) that must pass before we "
        + "scan this user again, otherwise we skip when we encounter "
        + "this user.",
        type=int,
    )

    args = argparser.parse_args()

    if args.ignore_guild:
        try:
            cfg.IGNORE_GUILD = [int(args.ignore_guild)]
        except ValueError or TypeError:
            try:
                with open(str(args.ignore_guild)) as _f:
                    cfg.IGNORE_GUILD = [int(_ig) for _ig in _f.read().split(",")]  # noqa
                    _f.close()
            except OSError as e:
                raise FileReadError(
                    "Could not read from the file: {}".format(
                            args.ignore_guild
                        )
                ) from e

    if args.debug:
        cfg.DEBUG = True
    if args.debug_discord:
        cfg.DEBUG_DISCORD = True
    if args.enable_presence:
        cfg.ENABLE_PRESENCE = True
    if args.db:
        cfg.DB_NAME = str(args.db)
    if args.q:
        cfg.QUIET_MODE = True
    if args.whitelist:
        try:
            cfg.ID_WHITELIST = [int(args.whitelist)]
        except (ValueError, TypeError):
            try:
                with open(str(args.whitelist)) as _f:
                    cfg.ID_WHITELIST = [int(_ig) for _ig in _f.read().split(",")]  # noqa
            except OSError as e:
                raise FileReadError(
                    "Could not read from the file: {}".format(args.whitelist)
                ) from e
    if args.last_scanned:
        cfg.LAST_SCANNED_INTERVAL = args.last_scanned

    return args
