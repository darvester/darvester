import json

from py.server import DarvesterAPI


def setup(api: DarvesterAPI):
    @api.get("/search/{query}")
    def search(query: str, limit: int = 0, offset: int = 0):
        """
        Search for a user.
        """
        limit = f" LIMIT {str(limit)} " if int(limit) > 0 else ""
        offset = f" OFFSET {str(offset)}" if int(offset) > 0 else ""
        with api.db_connect() as db:
            users_rows = db.execute(f"SELECT data, id FROM users WHERE data LIKE ? {limit} {offset}",
                                    ("%" + query + "%",)).fetchall()
            for idx, row in enumerate(users_rows):
                _user: dict = json.loads(row[0])
                _user["id"] = row[1]
                api.caches.users.set(row[1], _user)
                users_rows[idx] = _user

            guilds_rows = db.execute(f"SELECT data, id FROM guilds WHERE data LIKE ? {limit} {offset}",
                                     ("%" + query + "%",)).fetchall()
            for idx, row in enumerate(guilds_rows):
                _guild: dict = json.loads(row[0])
                _guild["id"] = row[1]
                api.caches.guilds.set(row[1], _guild)
                guilds_rows[idx] = _guild
            return {"users": users_rows, "guilds": guilds_rows}
