# darvester

<p align="center">
<img width="50%" height="50%" align="center" src="https://user-images.githubusercontent.com/29584664/146680484-b63cbde2-5386-4feb-8cbe-f4807ea99b61.png" />
</p>
<p align="center">
  Worked on for <a href="https://wakatime.com/badge/github/V3ntus/darvester"><img src="https://wakatime.com/badge/github/V3ntus/darvester.svg" alt="wakatime"></a>
</p>

---
### PoC Discord user and guild information harvester  

<p align=center>
  Darvester aims to provide safe Discord OSINT harvesting, abiding by sane rate limiting and providing automated processing
 </p>

**Data logged for each user:**
- Profile created date, and first seen date
- Username and discriminator
- User ID (or Snowflake)
- Bio/about me
- Connected accounts (reddit, YouTube, Facebook, etc.)
- Public Discord flags (Discord Staff, Early Bot Developer, Certified Mod, etc.)
- Avatar URL

**Data logged for each guild:**
- Name
- Icon URL
- Owner name and ID
- Splash URL
- Member count
- Description
- Features (thread length, community, etc.)
- Nitro tier

All as nested JSON in `harvested.db` (SQLite). Select data with `id` as user ID (Snowflake).  
You can access this data through Discord by using the command `,select [USER ID]` (see screenshots below)

<h3 align="center">To start logging, just join a server with your user. No need to verify*</h3>
<sub>* Unless the server is using a 3rd party verification bot. For example, non-community servers using mee6 or Dyno to verify by role/reaction</sub>


## DISCLAIMER:
**Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.**

# Install

See the wiki page [here](https://github.com/V3ntus/darvester/wiki/Installing)

# Usage

> `$` `python run.py -h`
```
usage: run.py [-h] [-ig FILE/GUILD_ID] [-v] [-vv] [-p] [--db harvested.db] [-q] [--whitelist FILE/USER_ID] [--last-scanned LAST_SCANNED]

Darvester - PoC Discord guild and user information harvester

optional arguments:
  -h, --help            show this help message and exit
  -ig FILE/GUILD_ID, --ignore-guild FILE/GUILD_ID
                        Either a comma separated list of guild IDs in a text file, or a single guild ID passed. Darvester will ignore the guild(s) specified here.
  -v, --debug           Enable verbose debug messages.
  -vv, --debug-discord  Enable debug messages from Discord.py (can get pretty spammy!).
  -p, --enable-presence
                        Enable rich presence for bot and client.
  --db harvested.db     The database file to log into.
  -q                    Enable quiet mode to suppress some info going to the console.
  --whitelist FILE/USER_ID, -w FILE/USER_ID
                        Either a comma separated list of user IDs in a text file, or a single user ID passed. Darvester will only respond to this userwhen commands are issued.
  --last-scanned LAST_SCANNED, -ls LAST_SCANNED
                        The amount of time (in seconds) that must pass before we scan this user again, otherwise we skip when we encounter this user.
```

## Screenshots:
- ![image](https://user-images.githubusercontent.com/29584664/153620358-945d0829-64ba-45f8-802f-2f94deecdeef.png)

- ![Screen Shot 2022-01-01 at 16 21 22](https://user-images.githubusercontent.com/29584664/147861381-d5c48a42-3d1b-4d5f-825a-6bda4cc7b012.png)

- Slave/Harvester: ![image](https://user-images.githubusercontent.com/29584664/147799316-bae5525d-048f-4f7b-9955-574b17004637.png)

- Master: ![image](https://user-images.githubusercontent.com/29584664/147799297-3b2d489c-dfae-4b08-a68a-61d87bb900af.png)
