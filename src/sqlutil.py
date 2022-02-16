import json
import sqlite3
import time
import traceback

from cfg import DB_NAME, QUIET_MODE
from src import logutil

logger = logutil.initLogger("sqlutil")
dbfile = DB_NAME


class DictDiffer(object):
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
        return self.set_current - self.intersect

    def removed(self):
        return self.set_past - self.intersect

    def changed(self):
        return {o for o in self.intersect if self.past_dict[o] != self.current_dict[o]}

    def unchanged(self):
        return {o for o in self.intersect if self.past_dict[o] == self.current_dict[o]}


class SQLiteNoSQL:
    """Open the database on module init"""

    def __init__(self, f: str = DB_NAME):
        self.dbfile = f
        self.db = sqlite3.connect(f)
        global dbfile
        dbfile = self.dbfile
        self.cur = self.db.cursor()
        self.cur.executescript(
            "CREATE TABLE IF NOT EXISTS "
            + "users(data TEXT UNIQUE, id INTEGER UNIQUE);"
            + "CREATE TABLE IF NOT EXISTS "
            + "guilds(data TEXT UNIQUE, id INTEGER UNIQUE);"
        )

    def open(self, f: str = dbfile):
        """Open connection"""
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()

    def cursor(self):
        return self.db.cursor()

    def close(self):
        """Close connection"""
        try:
            self.db.commit()
            self.db.close()
            logger.debug("Database closed")
        except Exception:  # noqa: E722
            logger.error("Something happened trying to close the database", exc_info=1)

    def addrow(self, d, user_id, table):
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
            self.db.execute(
                f"INSERT INTO {table} VALUES (?, ?);",
                (
                    json.dumps(d),
                    user_id,
                ),
            )
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
                self.db.execute(
                    f"""
                UPDATE {table} SET (data, id) = (?, ?) WHERE id = ?""",
                    (
                        json.dumps(d),
                        user_id,
                        user_id,
                    ),
                )
        finally:
            self.db.commit()

    def find(self, user_id, table, query: str = None):
        """
        user_id: Discord user or guild ID
        table: Table to look in
        query: optional - Extract data from specified key in query
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

    def init_fts_table(self, table: str = "users"):
        try:
            logger.debug("Initializing fts table for %s" % table)
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
                + f"USING fts5(data, id, content='{table}')"
            )
            self.db.commit()
            logger.debug("Created %s_fts" % table)

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
            logger.debug("Created %s_fts_before_update" % table)

            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_fts_before_delete "
                + f"BEFORE DELETE ON {table} BEGIN "
                + f"DELETE FROM {table}_fts WHERE rowid=old.rowid; END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_before_delete" % table)

            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_after_update "
                + f"AFTER UPDATE ON {table} BEGIN "
                + f"INSERT INTO {table}_fts(rowid, data, id) "
                + f"SELECT rowid, data, id FROM {table} WHERE "
                + f"new.rowid = {table}.rowid; "
                + "END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_after_update" % table)

            self.cur.execute(
                f"CREATE TRIGGER IF NOT EXISTS {table}_after_insert "
                + f"AFTER INSERT ON {table} BEGIN "
                + f"INSERT INTO {table}_fts(rowid, data, id) "
                + f"SELECT rowid, data, id FROM {table} WHERE "
                + f"new.rowid = {table}.rowid; "
                + "END"
            )
            self.db.commit()
            logger.debug("Created %s_fts_after_insert" % table)
            self.db.close()
        except Exception:
            logger.critical("An exception occurred", exc_info=1)

    def rebuild_fts_table(self, table: str = "users"):
        try:
            logger.debug("Rebuilding the fts table for %s" % table)
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
        try:
            self.open()

            _sql_query = f"SELECT DISTINCT id, data \
FROM {table}_fts"

            if query:
                _sql_query += f" WHERE data {query_type} ?"
            if limit > 0:
                _sql_query += f" LIMIT {limit}"

            self.cur.execute(_sql_query, (query,) if query else None)

            # self.cur.execute(
            #     "SELECT id, data " +
            #     f"FROM {table}_fts " +
            #     f"WHERE data {query_type} ? ", (query,) if query else None
            # )
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
                    logger.critical("Key not found %s" % json_lookup)
                except TypeError:
                    logger.critical("Query returned none", exc_info=1)
            return _d

        except Exception:
            traceback.print_exc()
