import json
import os
import pathlib
import sqlite3
import time
import traceback
from os.path import dirname as dn
from sqlite3 import Connection, Cursor

from cfg import DB_NAME, QUIET_MODE, VCS_REPO_PATH
from src import logutil
from src.gitutil import GitUtil

logger = logutil.initLogger("sqlutil")
dbfile = DB_NAME


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


class SQLiteNoSQL:
    """Open the database on module init"""

    def __init__(self, f: str = DB_NAME):
        self.dbfile = f
        self.db = sqlite3.connect(f)
        dbfile = self.dbfile
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
            "first_seen",
            "last_scanned",
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
        ]
        self.cur.executescript(
            # users
            "CREATE TABLE IF NOT EXISTS "
            + "users(data TEXT UNIQUE, id INTEGER UNIQUE, "
            + "name TEXT, discriminator TEXT, bio TEXT, "
            + "mutual_guilds TEXT, avatar_url TEXT, "
            + "public_flags TEXT, created_at TEXT, "
            + "connected_accounts TEXT, first_seen TEXT, last_scanned TEXT); "
            # guilds
            + "CREATE TABLE IF NOT EXISTS "
            + "guilds(data TEXT UNIQUE, id INTEGER UNIQUE, "
            + "name TEXT, icon TEXT, owner TEXT splash_url TEXT, "
            + "member_count TEXT, description TEXT, "
            + "features TEXT, premium_tier TEXT);"
        )
        self.cur.execute("PRAGMA table_info(users)")
        _pragma_users = self.cur.fetchall()
        self.cur.execute("PRAGMA table_info(guilds)")
        _pragma_guilds = self.cur.fetchall()
        if not (
            any(word in _pragma_users for word in self._users_cols)
            and any(word in _pragma_guilds for word in self._guilds_cols)
        ):
            logger.debug("Missing columns detected. Altering table...")
            for _col in self._users_cols:
                try:
                    self.cur.executescript(f"ALTER TABLE users ADD {_col} TEXT")
                    logger.debug(f'Adding: "{_col} TEXT" to users...')
                except sqlite3.OperationalError:
                    pass
            for _col in self._guilds_cols:
                try:
                    self.cur.execute(f"ALTER TABLE guilds ADD {_col} TEXT")
                    logger.debug(f'Adding: "{_col} TEXT" to guilds...')
                except sqlite3.OperationalError:
                    pass
        self.git = GitUtil()

    def open(self, f: str = dbfile):
        """Open connection"""
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()

    @property
    def conn(self) -> Connection:
        return self.db

    @property
    def cursor(self) -> Cursor:
        return self.db.cursor()

    def close(self):
        """Close connection"""
        try:
            self.db.commit()
            self.db.close()
            logger.debug("Database closed")
        except Exception:  # noqa: E722
            logger.error("Something happened trying to close the database", exc_info=1)

    # TODO: rename `user_id` to a proper name now that we log guilds
    def addrow(self, d: dict, user_id, table):
        """Add row to database"""
        # Check if row already exists for user_id
        try:
            self.cur.execute(f"SELECT data FROM {table} WHERE id = ?", (user_id,))
            data = self.cur.fetchone()

            # If data returned is none, try to append a first_seen
            if data is None:
                logger.debug("User is first_seen " + str(int(time.time())))
                d["first_seen"] = int(time.time())

            # Else, this code will throw IntegrityError and continue flow below
            _query = "INSERT INTO {} ({}) VALUES ({})".format(
                table,
                ", ".join(
                    [
                        str(_k).replace('"', "'").replace("\\", "\\\\")
                        for _k in d
                        if _k in self._users_cols + self._guilds_cols
                    ]
                ),
                ", ".join(
                    [
                        '"' + str(d[_k]).replace('"', "'").replace("\\", "\\\\") + '"'
                        for _k in d
                        if _k in self._users_cols + self._guilds_cols
                    ]
                ),
            )

            logger.debug(_query)
            self.db.execute(_query)
        except sqlite3.ProgrammingError:
            # Sometimes, the database closes prematurely
            # My code sucks
            logger.warning("Reopening database...")
            self.open(self.dbfile)
        except sqlite3.IntegrityError:
            # Process an already existent row
            logger.debug(
                f"Already exists: {user_id if not QUIET_MODE else None}" + " -- Updating info..."
            )

            # Use the 'data' from our try
            try:
                for item in data:
                    diff1 = json.loads(item[0])
            except json.decoder.JSONDecodeError:
                for item in data:
                    diff1 = json.loads(item)

            # Don't override first_seen
            d["first_seen"] = diff1["first_seen"]

            # Update row
            # Check for changes
            if diff1 == d:
                logger.debug("Nothing changed. Not updating data")
            else:
                _diff = DictDiffer(diff1, d)
                logger.debug("Info updated --------------")
                if _diff.added():
                    logger.debug("Added: " + ", ".join(_diff.added()))
                if _diff.removed():
                    logger.debug("Removed: " + ", ".join(_diff.removed()))
                if _diff.changed():
                    logger.debug("Changed: " + str(_diff.changed()))
                logger.debug("--------------")

                query = "UPDATE {} SET ({}) = ({}) WHERE id = {}".format(
                    table,
                    ", ".join(
                        [
                            str(_k).replace('"', "'").replace("\\", "\\\\")
                            for _k in d
                            if _k in self._users_cols + self._guilds_cols
                        ]
                    ),
                    ", ".join(
                        [
                            '"' + str(d[_k]).replace('"', "'").replace("\\", "\\\\") + '"'
                            for _k in d
                            if _k in self._users_cols + self._guilds_cols
                        ]
                    ),
                    user_id,
                )

                self.db.execute(query)
        finally:
            self.db.commit()

    def find(self, user_id, table, query: str = None):
        """
        Find a row in the database
        :param user_id: The user id to search for
        :type user_id: int
        :param table: The table to search in
        :type table: str
        :param query: The query to use
        :type query: str
        :return: The row
        :rtype: dict
        """
        try:
            self.open(DB_NAME)
            # execute SELECT to grab data
            self.cur.execute(
                f"SELECT data FROM {table} WHERE id = ?",
                (user_id,),
            )
            data = self.cur.fetchone()
            _d = None
            # try to load the json
            try:
                for _item in data:
                    _d = json.loads(_item[0])
            except json.decoder.JSONDecodeError:
                for _item in data:
                    _d = json.loads(_item)
            except TypeError:
                logger.debug("json load failed. Probably first seen?")
            if query:
                try:
                    return _d[query]
                except KeyError:
                    if query != "last_scanned":
                        logger.debug('Query "%s" failed. May not be harmful', query)
                except TypeError:
                    logger.debug("Query data returned None. Probably first seen?")
            # return as json
            return _d
        except sqlite3.ProgrammingError:
            logger.error("ProgrammingError raised", exc_info=1)
            self.close()
            self.open(self.dbfile)

    def dump_table_to_files(self, table: str, path: str = VCS_REPO_PATH):
        """

        :param table: Table to dump
        :type table: str
        :param path: Path to dump to
        :type path: str
        """
        if not path:
            path = dn(os.path.dirname(__file__)) + "/.darvester"
        if not os.path.exists(path) and not os.path.isdir(path):
            self.git.init_repo(path)
        try:
            self.open(DB_NAME)
            self.cur.execute(f"SELECT id, data FROM {table}")
            data = self.cur.fetchall()

            pathlib.Path(f"{path}/{table}").mkdir(parents=True, exist_ok=True)

            __iter = 0
            for piece in data:
                if not piece[0]:  # why does this return None sometimes
                    continue  # TODO: fix this >:(
                __iter += 1
                try:
                    if os.path.exists(f"{path}/{table}/{str(piece[0])}"):
                        mode = "w"
                    else:
                        mode = "x"

                    with open(f"{path}/{table}/{str(piece[0])}", mode) as f:
                        logger.debug("DUMP: Writing to %s/%s...", path, str(piece[0]))
                        if piece[1]:
                            f.write(piece[1].strip() + "\n")
                        f.close()
                except:  # noqa
                    logger.critical("DUMP: Error occurred writing data", exc_info=True)
            logger.debug("Finished dumping %s items to commit to VCS", __iter)
        except Exception as error:
            logger.critical("DUMP: Error occurred")
            raise error from error
        finally:
            self.close()

    def init_fts_table(self, table: str = "users"):
        """
        Initialize a table for full-text search
        :param table: Table to initialize from
        :type table: str
        """
        try:
            logger.debug("Initializing fts table for %s", table)
            self.open(DB_NAME)
            # Drop things if they exist
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
        except Exception:
            logger.critical("An exception occurred", exc_info=1)

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
        except Exception:
            logger.critical("An exception occurred", exc_info=1)

    def find_from_fts(
        self,
        query: str = None,
        json_lookup: str = None,
        table: str = "users",
        query_type: str = "MATCH",
        limit: int = 40,
    ):
        """
        Finds data from the fts table
        :param query: The query to search for
        :type query: str
        :param json_lookup: The key to return (if exists)
        :type json_lookup: str
        :param table: The table to search in (defaults to users)
        :type table: str
        :param query_type: The query type (defaults to MATCH)
        :type query_type: str
        :param limit: The limit of results to return (defaults to 40)
        :type limit: int
        :return: The results in a list
        :rtype: list
        """
        try:
            self.open()

            _sql_query = f"SELECT DISTINCT id, data \
FROM {table}_fts"

            if query:
                _sql_query += f" WHERE data {query_type} ?"
            if limit > 0:
                _sql_query += f" LIMIT {limit}"

            self.cur.execute(_sql_query, (query,) if query else None)

            _returned = self.cur.fetchall()

            _d = []
            try:
                for _ in range(len(_returned) - 1):
                    _d.extend(json.loads(_item[1]) for _item in _returned)
            except json.decoder.JSONDecodeError:
                for _item in _returned:
                    _d = json.loads(_item)
            except TypeError:
                logger.critical("JSON load failed", exc_info=1)

            if json_lookup:
                try:
                    return [_d[_][json_lookup] for _ in range(len(_d))]
                except KeyError:
                    logger.critical("Key not found %s", json_lookup)
                except TypeError:
                    logger.critical("Query returned none", exc_info=1)
            return _d

        except Exception:
            traceback.print_exc()
