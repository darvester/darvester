# darvester
### PoC Discord user and guild information harvester 

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