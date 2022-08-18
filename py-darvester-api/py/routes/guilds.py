import json

from fastapi import HTTPException
from py.server import DarvesterAPI


def setup(api: DarvesterAPI):
    """
    Setup API routes for guilds

    :param api: The API server.
    :type api: DarvesterAPI
    """

    @api.get("/guilds")
    def get_guilds(limit: int = 0, offset: int = 0):
        """
        Get all guilds.
        """
        limit = f" LIMIT {str(limit)} " if int(limit) > 0 else ""
        offset = f" OFFSET {str(offset)}" if int(offset) > 0 else ""
        with api.db_connect() as db:
            rows = db.execute("SELECT data, id FROM guilds {} {}".format(limit, offset)).fetchall()
            for idx, row in enumerate(rows):
                _guild: dict = json.loads(row[0])
                _guild["id"] = row[1]
                api.caches.guilds.set(row[1], _guild)
                rows[idx] = _guild
            return {"guilds": rows}

    @api.get("/guilds/{guild_id}")
    def get_guild(guild_id: int):
        """
        Get a guild.
        """
        if guild := api.caches.guilds.get(guild_id):
            return guild
        with api.db_connect() as db:
            row = db.execute("SELECT data, id FROM guilds WHERE id = ?", (guild_id,)).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Guild not found.")
            guild = json.loads(row[0])
            api.caches.guilds.set(guild_id, guild)
            guild["id"] = row[1]
            return guild

    @api.post("/guilds/{guild_id}")
    def post_guild(guild_id: int, data: dict):
        """
        Create a guild.
        """
        with api.db_connect() as db:
            db.execute("INSERT INTO guilds (id, data) VALUES (?, ?)", (guild_id, json.dumps(data)))
            api.caches.guilds.set(guild_id, data)
            return data

    @api.get("/guilds/{guild_id}/members")
    def get_guild_members(guild_id: int):
        """
        Get members in a guild

        :param guild_id: The guild ID
        :type guild_id: int
        :return:
        :rtype:
        """
        with api.db_connect() as db:
            members = db.execute("SELECT data, id FROM users WHERE mutual_guilds LIKE ?",
                                 (f"%{str(guild_id)}%", )).fetchall()
            if not members:
                raise HTTPException(status_code=404, detail="No members found or guild not found")
            for idx, member in enumerate(members):
                _member: dict = json.loads(member[0])
                _member["id"] = member[1]
                api.caches.users.set(member[1], _member)
                members[idx] = _member
            return {"members": members}

    @api.get("/guilds/{guild_id}/{field}")
    def get_guild_field(guild_id: int, field: str):
        """
        Get a guild field.
        """
        if guild := api.caches.guilds.get(guild_id):
            if field in guild:
                return guild[field]
            else:
                raise HTTPException(status_code=404, detail=f"Guild field '{field}' not found.")
        else:
            with api.db_connect() as db:
                row = db.execute("SELECT data FROM guilds WHERE id = ?", (guild_id,)).fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="Guild not found.")
                if field in json.loads(row[0]):
                    return json.loads(row[0])[field]
                else:
                    raise HTTPException(status_code=404, detail=f"Guild field '{field}' not found.")
        raise HTTPException(status_code=404, detail="Guild not found.")

    @api.post("/guilds/{guild_id}/{field}")
    def post_guild_field(guild_id: int, field: str, value: str):
        """
        Set a guild field.
        :param guild_id: The guild ID.
        :type guild_id: int
        :param field: The field to set.
        :type field: str
        :param value: The value to set.
        :type value: str
        """
        with api.db_connect() as db:
            _guild = json.loads(db.execute("SELECT data FROM guilds WHERE id = ?", (guild_id,)).fetchone()[0])
            if field in _guild:
                _guild[field] = value
                db.execute("UPDATE guilds SET data = ? WHERE id = ?", (json.dumps(_guild), guild_id))
                api.caches.guilds.set(guild_id, _guild)
                return _guild[field]
            else:
                raise HTTPException(status_code=404, detail=f"Guild field '{field}' not found.")
