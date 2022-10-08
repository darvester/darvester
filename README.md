
# Darvester

<p align="center">
<img width="50%" height="50%" align="center" src="https://user-images.githubusercontent.com/29584664/146680484-b63cbde2-5386-4feb-8cbe-f4807ea99b61.png" />
</p>
<p align="center">
  Worked on for <a href="https://wakatime.com/badge/github/V3ntus/darvester"><img src="https://wakatime.com/badge/github/V3ntus/darvester.svg" alt="wakatime"></a>
</p>

## 🖥️ PoC Discord user and guild information harvester
Darvester aims to provide safe Discord OSINT harvesting, abiding by sane rate limiting and providing automated processing



## ✨ Features

- Rate-limit/soft ban avoidance
- Automated processing
- Flexible configuration
- Utilization of the Git version control system to provide chronological data
- Detailed logging
- and more


## 💽 Data logged for each user

- Profile created date, and first seen date
- Username and discriminator
- User ID (or Snowflake)
- Bio/about me
- Connected accounts (reddit, YouTube, Facebook, etc.)
- Public Discord flags (Discord Staff, Early Bot Developer, Certified Mod, etc.)
- Avatar URL
- Status/Activity ("Playing", "Listening to", etc.)


## 💾 Data logged for each guild
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

## 🗄️ API and Frontend
Prior to recent additions, there has been no easy way to retrieve data out of the database.  
**NEW:** Check out this recent [discussion](https://github.com/V3ntus/darvester/discussions/39) concerning easy ways to interact with this database, including a web frontend and a REST API backend.

<h3 align="center">To start logging, just join a server with your user. No need to verify*</h3>
<sub>* Unless the server is using a 3rd party verification bot. For example, non-community servers using mee6 or Dyno to verify by role/reaction</sub>
## ⚠️ Disclaimer

Using this tool, you agree not to hold the contributors and developers accountable for any damages that occur. This tool violates Discord terms of service and may result in your access to Discord services terminated.
## 📈 Install
See the wiki page [here](https://github.com/V3ntus/darvester/wiki/Installing)
## 🏎️ Usage

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
  --disable-vcs, -dv    Disable the VCS data tracking system
```
## Screenshots
![2](https://user-images.githubusercontent.com/25264755/194698744-271d5276-0791-429f-8536-4dd830bfe8f7.png)
![3](https://user-images.githubusercontent.com/25264755/194698745-51e1e104-0fac-4a37-bd4c-86839ad50a39.png)
![4](https://user-images.githubusercontent.com/25264755/194698748-33078a57-e46d-4fe6-833a-8ed78b5203eb.png)
![5](https://user-images.githubusercontent.com/25264755/194698742-4b908548-ee1f-4c82-82b8-19983c7b0416.png)
