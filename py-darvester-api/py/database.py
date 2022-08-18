import sqlite3


class Database:
    def __init__(self, dbfile: str):
        self.dbfile: str = dbfile
        self.conn: sqlite3.Connection = sqlite3.connect(self.dbfile)
        self.cursor: sqlite3.Cursor = self.conn.cursor()
