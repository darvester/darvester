import json

from fastapi import HTTPException
from py.server import DarvesterAPI


def setup(api: DarvesterAPI):
    """
    Setup API routes for users
    :param api: The API server.
    :type api: DarvesterAPI
    """

    @api.get("/users")
    def get_users(limit: int = 0, offset: int = 0):
        """
        Get all users.
        """
        limit = f" LIMIT {str(limit)} " if int(limit) > 0 else ""
        offset = f" OFFSET {str(offset)}" if int(offset) > 0 else ""
        with api.db_connect() as db:
            rows = db.execute("SELECT data, id FROM users {} {}".format(limit, offset)).fetchall()
            for idx, row in enumerate(rows):
                _user: dict = json.loads(row[0])
                _user["id"] = row[1]
                api.caches.users.set(row[1], _user)
                rows[idx] = _user
            return {"users": rows}

    @api.get("/users/{user_id}")
    def get_user(user_id: int):
        """
        Get a user.
        """
        if user := api.caches.users.get(user_id):
            return user
        with api.db_connect() as db:
            row = db.execute("SELECT data, id FROM users WHERE id = ?", (user_id,)).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="User not found.")
            user = json.loads(row[0])
            api.caches.users.set(user_id, user)
            user["id"] = row[1]
            return user

    @api.post("/users/{user_id}")
    def post_user(user_id: int, data: dict):
        """
        Create a user.
        """
        with api.db_connect() as db:
            db.execute("INSERT INTO users (id, data) VALUES (?, ?)", (user_id, json.dumps(data)))
            api.caches.users.set(user_id, data)
            return data

    @api.get("/users/{user_id}/{field}")
    def get_user_field(user_id: int, field: str):
        """
        Get a user field.
        """
        if user := api.caches.users.get(user_id):
            if field in user:
                return user[field]
            else:
                raise HTTPException(status_code=404, detail=f"User field '{field}' not found.")
        else:
            with api.db_connect() as db:
                row = db.execute("SELECT data FROM users WHERE id = ?", (user_id,)).fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="User not found.")
                if field in json.loads(row[0]):
                    return json.loads(row[0])[field]
                else:
                    raise HTTPException(status_code=404, detail=f"User field '{field}' not found.")
        raise HTTPException(status_code=404, detail="User not found.")

    @api.post("/users/{user_id}/{field}")
    def post_user_field(user_id: int, field: str, value: str):
        """
        Set a user field.
        :param user_id: The user ID.
        :type user_id: int
        :param field: The field to set.
        :type field: str
        :param value: The value to set.
        :type value: str
        """
        with api.db_connect() as db:
            _user = json.loads(db.execute("SELECT data FROM users WHERE id = ?", (user_id,)).fetchone()[0])
            if field in _user:
                _user[field] = value
                db.execute("UPDATE users SET data = ? WHERE id = ?", (json.dumps(_user), user_id))
                api.caches.users.set(user_id, _user)
                return _user[field]
            else:
                raise HTTPException(status_code=404, detail=f"User field '{field}' not found.")
