# darvester

<p align="center">
<img width="50%" height="50%" align="center" src="https://user-images.githubusercontent.com/29584664/146680484-b63cbde2-5386-4feb-8cbe-f4807ea99b61.png" />
</p>

---
### PoC Discord user and guild information harvester 
**Data logged for each user:**
- Users' profile created date, and first seen date
- Users' display name and discriminator
- Users' user ID
- Users' connected accounts (reddit, YouTube, Facebook, etc.)
- Users' public Discord flags (Discord Staff, Early Bot Developer, Certified Mod, etc.)
- Users' avatar URL

All as nested JSON in `harvested.db` (SQLite). Select data with `id` as user ID (Snowflake)
- You can access this data through Discord by using the command `,select [USER ID]` (see screenshots below)
> Example: `SELECT data FROM users WHERE id = 503791522401381355`

---

<h3 align="center">To start logging, just join a server with your user. No need to verify*</h3>
<sub>* Unless the server is using a 3rd party verification bot. For example, non-community servers using mee6 or Dyno to verify by role/reaction</sub>

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

Copy `cfg.py.template` as `cfg.py` in the root folder, paste your token in that file, and run `python run.py`. It should get going automatically

---

## Screenshots:
- ![image](https://user-images.githubusercontent.com/29584664/146631888-bc3bd222-6a0e-4543-9977-94e88db96b09.png)

- ![image](https://user-images.githubusercontent.com/29584664/146631952-e14d8afb-ed88-4735-afa6-cce14887cf1f.png)

- ![image](https://user-images.githubusercontent.com/29584664/146631996-31be95fe-67e9-4e14-b3b8-1818cf32e614.png)

