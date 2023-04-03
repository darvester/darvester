# Darvester GEN2
<p align="center">
<img width="50%" height="50%" align="center" src="https://user-images.githubusercontent.com/29584664/146680484-b63cbde2-5386-4feb-8cbe-f4807ea99b61.png" />
</p>

[![wakatime](https://wakatime.com/badge/user/5695f814-ebe9-4e6d-83fd-211468aa6597/project/2a6edb4f-b63b-4fcf-9726-3ef343694a2f.svg)](https://wakatime.com/badge/user/5695f814-ebe9-4e6d-83fd-211468aa6597/project/2a6edb4f-b63b-4fcf-9726-3ef343694a2f)

## 🖥️ PoC Discord user and guild information harvester
Darvester aims to provide safe Discord OSINT harvesting, abiding by sane rate limiting and providing automated processing - _now written in Dart/Flutter_

## ✨ Features

- Rate-limit/soft ban avoidance
- Automated processing
- Flexible configuration
- ~~Utilization of the Git version control system to provide chronological data~~ Planned!
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
- Nitro tier

## 💾 Data logged for each guild
- Name
- Icon URL
- Owner name and ID
- Splash URL
- Member count
- Description
- Features (thread length, community, etc.)
- Nitro tier


## ⚠️ Disclaimer  
> Using this tool, you agree not to hold the contributors and developers accountable for any damages that may occur. This tool violates Discord terms of service and may result in your access to Discord services terminated.

## What does Darvester do?  
> Darvester is meant to be the all-in-one solution for open-source intelligence on the Discord platform. With the recent GEN2 releases, Darvester now provides an easy-to-use frontend UI along with new features such as multiple harvesting instances, or **Isolates**, for individual tokens, a refreshed Material 3 UI, and an all-in-one packaged app - no more Python dependencies and virtual environments!

> Darvester is built on a custom fork of [nyxx](https://github.com/nyxx-discord/nyxx) named [nyxx-self](https://github.com/V3ntus/nyxx-self), maintained by the author of Darvester
