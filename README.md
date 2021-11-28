# darvester
### PoC Discord user and guild information harvester 
**Data logged for each user:**
- Users' profile created date, and first seen date
- Users' display name and discriminator
- Users' user ID
- Users' connected accounts (reddit, YouTube, Facebook, etc.)
- Users' public Discord flags (Discord Staff, Early Bot Developer, Certified Mod, etc.)
- Users' avatar URL

All as nested JSON in `harvested.db` (SQLite). Select data with `id` as user ID (Snowflake)
> Example: `SELECT data FROM users WHERE id = 503791522401381355`

---

## DISCLAIMER:
**Using this tool, you agree not to hold the contributors and developers
accountable for any damages that occur. This tool violates Discord terms of
service and may result in your access to Discord services terminated.**

---

### 1. Installing
- Clone the repository
```
git clone https://github.com/V3ntus/darvester; cd darvester
```
- Create a virtual environment and install requirements
```py
python3 -m venv env
source ./env/bin/activate
pip3 install -r requirements.txt
```
### 2. Running
## - Acquiring your Disord user token
- Login to Discord in your web browser
- Press Ctrl+Shift+I (or Cmd+Option+I on Mac) to open your developer tools
- Navigate to Application in the top navigation bar, and expand Local Storage in the left sidebar
- Type in the filter box: `token` If nothing comes up, toggle your Device Toolbar. Ctrl+Shift+M on Windows, or Cmd+Shift+M on Mac, or you can click the icon on the top left (on Chrome)
- Copy your token and define it in `cfg.py` in the root of this project
