import sqlite3
import time
import json

from src import logutil

logger = logutil.initLogger("sqlutil")


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
        self.set_current, self.set_past = set(current_dict.keys()),set(past_dict.keys())  # noqa
        self.intersect = self.set_current.intersection(self.set_past)

    def added(self):
        return self.set_current - self.intersect

    def removed(self):
        return self.set_past - self.intersect

    def changed(self):
        return {o for o in self.intersect if self.past_dict[o] != self.current_dict[o]}  # noqa

    def unchanged(self):
        return {o for o in self.intersect if self.past_dict[o] == self.current_dict[o]}  # noqa


class SQLiteNoSQL:
    """Open the database on module init"""
    def __init__(self, f):
        self.dbfile = f
        self.db = sqlite3.connect(f)
        self.cur = self.db.cursor()
        self.cur.execute("""
            CREATE TABLE IF NOT EXISTS \
                users(data TEXT UNIQUE, id INTEGER UNIQUE);""")

    def open(self, f):
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
            logger.info("Database closed")
        except:  # noqa: E722
            logger.error("Something happened trying to close the database")

    def addrow(self, d, id, table):
        """Add row to database"""
        # Check if row already exists for user_id
        try:
            self.cur.execute(f"SELECT data FROM {table} WHERE id = ?", (id,))
            data = self.cur.fetchone()

            # If data returned is none, try to append a first_seen
            if data is None:
                print("User is first_seen " + str(int(time.time())))
                d["first_seen"] = int(time.time())

            # Else, this code will throw IntegrityError and continue flow below
            self.db.execute(f"INSERT INTO {table} VALUES (?, ?);",
                            (json.dumps(d), id,))
        except sqlite3.ProgrammingError:
            # Sometimes, the database closes prematurely
            # My code sucks
            logger.warning("Reopenning database...")
            self.open(self.dbfile)
        except sqlite3.IntegrityError:
            # Process an already existent row
            logger.info(f"Already exists: {id}\nUpdating info...")

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
                logger.info("Nothing changed. Not updating data")
            else:
                _diff = DictDiffer(diff1, d)
                logger.info("Info updated --------------")
                logger.info("Added: " + ', '.join(_diff.added()))
                logger.info("Removed: " + ', '.join(_diff.removed()))
                logger.info("Changed: " + str(_diff.changed()))
                self.db.execute(f"""
                UPDATE {table} SET (data, id) = (?, ?) WHERE id = ?""",
                                (json.dumps(d), id, id,))
        finally:
            self.db.commit()

    def find(self, id, table, query: str = None):
        """
        id: Discord ID
        table: Table to look in
        query: optional - Extract data from specified key in query
        """

        try:
            # execute SELECT to grab data
            self.cur.execute(f"\
                SELECT data FROM {table} WHERE id = ?", (id,))
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
            # print(_d1['last_scanned'])
            # print(int(time.time()))
            if query:
                try:
                    return _d[query]
                except KeyError:
                    if query is not "last_scanned":
                        logger.debug("Query \"%s\" failed. May not be harmful",
                                   query)
                except TypeError:
                    logger.debug("Query data returned None. Probably first seen?")
            # return as json
            return _d
        except sqlite3.ProgrammingError:
            logger.error("ProgrammingError raised")
            self.close()
            self.open(self.dbfile)
