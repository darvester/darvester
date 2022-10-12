import json
import os
import pathlib
import sqlite3
import time

from cfg import DB_NAME, DEBUG, VCS_REPO_PATH
from src import logutil
from src.gitutil import GitUtil, _default_path

logger = logutil.initLogger("sqlutil")
dbfile = DB_NAME


class SQLiteNoSQL:
    """Structured database for storing and retrieving data."""
    @staticmethod
    def _check_for_missing_cols(cur: sqlite3.Cursor, table: str, cols: list):
        logger.debug("Checking %s for missing columns...", table)
        old_cols = [i[1] for i in cur.execute(f'PRAGMA table_info("{table}")').fetchall()]
        for new_col in cols:
            if new_col not in old_cols:
                logger.debug("Found column not in database. Altering table %s, adding %s...", table, new_col)
                cur.execute('ALTER TABLE {} ADD COLUMN {} text'.format(table, new_col))

    def __init__(self, f: str = dbfile):
        """
        Initialize the database.
        :param f: The database file to open.
        :type f: str
        """
        self.dbfile = f
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()
        self._users_cols = [
            "name",
            "discriminator",
            "bio",
            "mutual_guilds",
            "avatar_url",
            "public_flags",
            "created_at",
            "connected_accounts",
            "activities",
            "status",
            "last_scanned",
            "first_seen",
            "premium",
            "premium_since",
            "banner"
        ]
        self._guilds_cols = [
            "name",
            "icon",
            "owner",
            "splash_url",
            "member_count",
            "description",
            "features",
            "premium_tier",
            "first_seen",
        ]
        self.cur.executescript(
            # users
            "CREATE TABLE IF NOT EXISTS "
            + "users(data TEXT, id INTEGER UNIQUE, "
            + " TEXT,".join(self._users_cols)
            + " TEXT); "
            # guilds
            + "CREATE TABLE IF NOT EXISTS "
            + "guilds(data TEXT, id INTEGER UNIQUE, "
            + " TEXT,".join(self._guilds_cols)
            + " TEXT); "
        )
        self._check_for_missing_cols(self.cur, "users", self._users_cols)
        self._check_for_missing_cols(self.cur, "guilds", self._guilds_cols)
        self.db.commit()
        self.git = GitUtil()

    @property
    def is_open(self) -> bool:
        """Return True if the database is open.

        :return: True if the database is open.
        :rtype: bool
        """
        try:
            self.db.cursor()
        except sqlite3.DatabaseError:
            return False
        return True

    @property
    def cursor(self) -> sqlite3.Cursor:
        """
        Return the current database cursor.

        :return: The current database cursor.
        :rtype: sqlite3.Cursor
        """
        return self.cur

    @property
    def conn(self) -> sqlite3.Connection:
        """
        Return the current database connection.

        :return: The current database connection.
        :rtype: sqlite3.Connection
        """
        return self.db

    @property
    def users_count(self) -> int:
        """
        Return the number of users in the database.

        :return: The number of users in the database.
        :rtype: int
        """
        return self.cur.execute("SELECT COUNT(*) FROM users").fetchone()[0]

    @property
    def guilds_count(self) -> int:
        """
        Return the number of guilds in the database.

        :return: The number of guilds in the database.
        :rtype: int
        """
        return self.cur.execute("SELECT COUNT(*) FROM guilds").fetchone()[0]

    def open(self, f: str = dbfile):
        """
        Open the database connection.

        :param f: The database file to open.
        :type f: str
        :return: The current database connection if any.
        :rtype: sqlite3.Connection
        """
        if not self.is_open:
            self.db = sqlite3.connect(f)
            self.cur = self.db.cursor()
        return self.db

    def close(self):
        """Close the database connection."""
        if self.is_open:
            try:
                self.db.commit()
                self.db.close()
                logger.debug("Closed database connection.")
            except (sqlite3.OperationalError, sqlite3.ProgrammingError):
                logger.error("Failed to close database connection.", exc_info=DEBUG)
        else:
            logger.debug("Database connection is already closed.")

    def commit(self):
        """Commit changes to the database."""
        try:
            self.db.commit()
            logger.debug("Committed changes to database.")
        except (sqlite3.OperationalError, sqlite3.ProgrammingError):
            if self.is_open:
                logger.error("Failed to commit changes to database.", exc_info=DEBUG)

    def addrow(self, data: dict, item_id: int, table: str):
        """
        Add a row to the database.

        :param data:
        :type data:
        :param item_id:
        :type item_id:
        :param table:
        :type table:
        :return: None
        :rtype: None
        """
        def _generate_values(_data: dict) -> list:
            """
            Generate a list of sanitized values for the database.

            :param _data: The data to sanitize.
            :type _data: dict
            :return: The sanitized data.
            :rtype: list
            """
            return [
                str(_data[key])
                .replace('"', "'")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                if _data[key] is not None or _data[key] != ""
                else '"None"'
                for key in _data
                if key in self._users_cols + self._guilds_cols and key not in ["id", "data"]
            ]

        self.open(self.dbfile)
        query = f"SELECT data FROM {table} WHERE id = '{item_id}';"
        logger.debug(query)
        self.cur.execute(query)
        row: tuple = self.cur.fetchone()

        if row is None or (row[0:1] or (None,))[0] is None:
            logger.debug(
                "Adding new row to table %s with id %s at %s.",
                table,
                item_id,
                str(int(time.time())),
            )
            data["first_seen"] = int(time.time())
        else:
            try:
                logger.debug("%s ;;; %s", data, row)
                data["first_seen"] = int(json.loads(row[0])["first_seen"])
            except (KeyError, IndexError):
                data["first_seen"] = int(time.time())

        _values = _generate_values(data)

        _query = "INSERT or REPLACE INTO {} (id, data, {}) VALUES ({}, ?, {})".format(
            table,
            ", ".join(
                [key for key in data.keys() if key in self._users_cols + self._guilds_cols]
            ),
            item_id,
            ", ".join(["?" for _ in _values]),  # noqa
        )

        logger.debug("%s, %s", _query, (json.dumps(data),) + tuple(_values))
        self.db.execute(_query, (json.dumps(data),) + tuple(_values))
        self.commit()

    def find(self, item_id: int, table: str, query: str = None) -> dict:
        """
        Find a row in the database
        :param item_id: The user id to search for
        :type item_id: int
        :param table: The table to search in
        :type table: str
        :param query: The query to use
        :type query: str
        :return: The row
        :rtype: dict
        """
        try:
            self.open(self.dbfile)
            self.cur.execute(
                f"SELECT data FROM {table} WHERE id = ?",
                (item_id,),
            )
            data = self.cur.fetchone()
            _d: dict = {}

            try:
                _d: dict = json.loads(data[0])
            except (json.decoder.JSONDecodeError, IndexError):
                for item in data:
                    _d1: dict = json.loads(item)
            except TypeError:
                pass
            if _d and query in _d.keys():
                return _d[query]
            return _d
        except sqlite3.ProgrammingError:
            logger.debug("Exception in find method", exc_info=DEBUG)

    def dump_table_to_files(self, table: str, path: str = VCS_REPO_PATH or _default_path):
        """
        Dump the table in a database to a file

        :param table: Table to dump
        :type table: str
        :param path: Path to dump to
        :type path: str
        :return: None
        :rtype: None
        """
        self.open(self.dbfile)
        if not os.path.exists(path) and not os.path.isdir(path):
            self.git.init_repo(path)
        try:
            self.cur.execute(f"SELECT data, id FROM {table}")
            data = self.cur.fetchall()
            pathlib.Path(f"{path}/{table}").mkdir(parents=True, exist_ok=True)

            _iter, _error_iter = 0, 0
            logger.debug(f"Dumping {table} to {path}/{table}...")
            for item in data:
                if _error_iter > 5:
                    logger.debug("Too many errors, aborting")
                    break
                if not item[1]:
                    continue
                _iter += 1
                if os.path.exists(f"{path}/{table}/{str(item[1])}"):
                    mode = "w"
                else:
                    mode = "x"
                try:
                    with open(os.path.join(path, table, str(item[1])), mode) as f:
                        if item[1]:
                            _ = json.loads(item[0])
                            f.write(json.dumps(_, indent=4))
                except (json.decoder.JSONDecodeError, OSError):
                    logger.debug("Exception in dump_table_to_files method", exc_info=DEBUG)
                    _error_iter += 1
        except Exception as error:
            logger.critical("DUMP: error occurred: {}".format(error))
        finally:
            self.close()

    def init_fts_table(self, table: str = "users"):
        """
        Init a table for full-text search

        :param table: table to init from
        :type table: str
        :return: None
        :rtype: None
        """
        try:
            logger.debug("Initializing fts table for %s", table)
            self.open(self.dbfile)
            self.cur.executescript(
                f"DROP TABLE IF EXISTS {table}_fts;"
                + f"DROP TRIGGER IF EXISTS {table}_fts_before_update;"
                + f"DROP TRIGGER IF EXISTS {table}_fts_before_delete;"
                + f"DROP TRIGGER IF EXISTS {table}_after_update;"
                + f"DROP TRIGGER IF EXISTS {table}_after_insert;"
            )
            self.db.commit()

            # create initial fts db
            self.cur.execute(
                f"CREATE VIRTUAL TABLE IF NOT EXISTS {table}_fts "
                + "USING fts5(id, data, {}, content='{}')".format(
                    ", ".join(getattr(self, f"_{table}_cols")), table
                )
            )
            self.db.commit()
            logger.debug("Created %s_fts", table)

            # Populate the fts table
            self.cur.execute(f"INSERT INTO {table}_fts SELECT * FROM {table}")
            self.db.commit()

            # setup triggers to update the fts db
            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_fts_before_update "
                + f"BEFORE UPDATE ON {table} BEGIN "
                + f"DELETE FROM {table}_fts WHERE rowid=old.rowid; END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_before_update", table)

            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_fts_before_delete "
                + f"BEFORE DELETE ON {table} BEGIN "
                + f"DELETE FROM {table}_fts WHERE rowid=old.rowid; END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_before_delete", table)

            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_after_update "
                + f"AFTER UPDATE ON {table} BEGIN "
                + f"INSERT INTO {table}_fts(rowid, data, id) "
                + f"SELECT rowid, data, id FROM {table} WHERE "
                + f"new.rowid = {table}.rowid; "
                + "END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_after_update", table)

            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_after_insert "
                + f"AFTER INSERT ON {table} BEGIN "
                + f"INSERT INTO {table}_fts(rowid, data, id) "
                + f"SELECT rowid, data, id FROM {table} WHERE "
                + f"new.rowid = {table}.rowid; "
                + "END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_after_insert", table)
            self.db.close()

        except (sqlite3.ProgrammingError, sqlite3.OperationalError):
            logger.critical("An exception occurred while creating the FTS tables", exc_info=DEBUG)

    def rebuild_fts_table(self, table: str = "users"):
        """
        Rebuilds the fts table for a given table

        :param table: The fts table to rebuild
        :type table: str
        """
        try:
            logger.debug("Rebuilding the fts table for %s", table)
            self.open(DB_NAME)
            self.cur.execute(f"INSERT INTO {table}_fts({table}_fts) " + "VALUES('rebuild')")
            self.db.commit()
            self.db.close()
        except (sqlite3.ProgrammingError, sqlite3.OperationalError):
            logger.critical("An exception occurred while creating the FTS tables", exc_info=DEBUG)


class DictDiffer:
    """
    Calculate the difference between two dictionaries as:
    (1) items added
    (2) items removed
    (3) keys same in both but changed values
    (4) keys same in both and unchanged values
    """

    def __init__(self, current_dict, past_dict):
        self.current_dict, self.past_dict = current_dict, past_dict
        self.set_current, self.set_past = set(current_dict.keys()), set(past_dict.keys())
        self.intersect = self.set_current.intersection(self.set_past)

    def added(self):
        """
        Return list of added items in current_dict

        :return: list of added items
        :rtype: dict
        """
        return self.set_current - self.intersect

    def removed(self):
        """
        Return list of removed items in current_dict

        :return: list of removed items
        :rtype: dict
        """
        return self.set_past - self.intersect

    def changed(self):
        """
        Return list of items in current_dict that have changed values

        :return: list of changed items
        :rtype: dict
        """
        return {o for o in self.intersect if self.past_dict[o] != self.current_dict[o]}

    def unchanged(self):
        """
        Return list of items in current_dict that have unchanged values

        :return: list of unchanged items
        :rtype: dict
        """
        return {o for o in self.intersect if self.past_dict[o] == self.current_dict[o]}
