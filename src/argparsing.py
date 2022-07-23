import argparse

import cfg


class FileReadError(Exception):
    """Custom exception to handle file read errors."""

    pass


def _parse_args():
    """
    Parse arguments from command line.

    :return: Parsed arguments
    :rtype:
    """
    argparser = argparse.ArgumentParser(
        description="Darvester - PoC Discord guild and user information " + "harvester"
    )
    argparser.add_argument(
        "-ig",
        "--ignore-guild",
        metavar="FILE/GUILD_ID_OR_NAME",
        help="Either a comma separated list of guild IDs or strings in a text file, or "
        + "a single guild ID or string passed. Darvester will ignore the guild(s) "
        + "specified here.",
    )
    argparser.add_argument(
        "-v", "--debug", help="Enable verbose debug messages.", action="store_true"
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
    argparser.add_argument("--db", metavar="harvested.db", help="The database file to log into.")
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
    argparser.add_argument(
        "--disable-vcs",
        "-dv",
        help="Disable the VCS tracking system",
        action="store_true",
    )

    args = argparser.parse_args()

    if args.ignore_guild:
        if not cfg.IGNORE_GUILD:  # if IGNORE_GUILD is empty
            cfg.IGNORE_GUILD = [int(args.ignore_guild)]
        elif isinstance(args.ignore_guild, int):  # if ignore_guild arg is a single guild ID
            cfg.IGNORE_GUILD.append(args.ignore_guild)
        elif isinstance(args.ignore_guild, str) and str(args.ignore_guild).isnumeric():
            # if ignore_guild arg is a string guild ID
            cfg.IGNORE_GUILD.append(int(args.ignore_guild))
        else:  # else, ignore_guild arg must be a file name
            try:
                with open(str(args.ignore_guild)) as _f:
                    cfg.IGNORE_GUILD = [int(_ig) for _ig in _f.read().split(",")]
                    _f.close()
            except OSError as e:
                raise FileReadError(
                    "Could not read from the file: {}".format(args.ignore_guild)
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
                    cfg.ID_WHITELIST = [int(_ig) for _ig in _f.read().split(",")]
            except OSError as e:
                raise FileReadError(
                    "Could not read from the file: {}".format(args.whitelist)
                ) from e
    if args.last_scanned:
        cfg.LAST_SCANNED_INTERVAL = args.last_scanned
    if args.disable_vcs:
        cfg.DISABLE_VCS = True

    return args
