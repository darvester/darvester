const { spawnSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const pm2 = require('pm2');
const { BrowserWindow } = require('electron');

// const { getConfigKey } = require('./config');

module.exports = {
    fixPath: () => {
        if (process.platform === 'win32') return process.env;
        
        try {
            let stdout = spawnSync(process.env.SHELL, ['-ilc', 'echo -n "_SHELL_ENV_DELIMITER_"; env; echo -n "_SHELL_ENV_DELIMITER_"; exit'], {DISABLE_AUTO_UPDATE: 'true'});
            stdout = stdout.stdout.toString().split("_SHELL_ENV_DELIMITER_")[1];
            let returnVal = {};
            let returnArr = [];
            const regex = new RegExp([
                '[\\u001B\\u009B][[\\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]+)*|[a-zA-Z\\d]+(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]*)*)?\\u0007)',
                '(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-nq-uy=><~]))'
            ].join('|'), 'g');
            for (const line of stdout.replace(regex, '').split('\n').filter((line) => Boolean(line))) {
                const [key, ...values] = line.split('=');
                returnVal[key] = values.join('=');
            }
            returnArr.push(`PATH=${returnVal.PATH}`);

            process.env.PATH = [
                './node_modules/.bin',
                '/.nodebrew/current/bin',
                '/usr/local/bin',
                ...returnArr
            ].join(':');
        } catch (e) {
            console.log(e);
            return false;
        }
    },
    askPythonVersion: () => {
        try {
            module.exports.fixPath();
            let cmd = process.platform === 'win32' ? 'py' : 'python3';
            let args = process.platform === 'win32' ? ['-3', '--version'] : ['--version'];
            const python = spawnSync(cmd, args);
            console.log("Looking for suitable Python versions...");
            if (python.status === 0 && (!python.stdout.length && !python.stderr.length)) {
                console.log("No Python distributions found");
                return {found: false, error: true, message: 'No Python versions found'}
            }
            const major = (python.stderr.toString().trim() || python.stdout.toString().trim()).split(" ")[1].split(".")[0];
            const minor = (python.stderr.toString().trim() || python.stdout.toString().trim()).split(" ")[1].split(".")[1];
            if (parseInt(major) >= 3 && parseInt(minor) >= 6) {
                console.log("Found supported Python version", major, minor);
                return {found: true, error: false, message: python.toString().trim(), version: [major, minor]}
            } else {
                console.log("Found unsupported Python version", major, minor);
                return {found: false, error: true, message: `Python version ${major}.${minor} is not supported. Please upgrade to 3.8 or higher.`, version: null}
            }
        } catch (error) {
            return {found: false, error: true, message: `${error.code}: ${error.message}`, version: null};
        }
    },
    createPythonVenv: (venvPath) => {
        console.log("Creating Python venv at path", venvPath);
        try {
            if (fs.existsSync(venvPath)) {
                console.log("Python venv already seems to exists at:", venvPath);
                if (!fs.existsSync(path.join(venvPath, "bin", "activate"))) {
                    console.log(`Python env at "${venvPath}" looks corrupted`);
                    return {error: true, message: "Environment already seems to exist, but is corrupted.", corrupted: true}
                } else {
                    return {error: false, message: "Environment already seems to exist.", done: true}
                }
            }
            try {
                fs.mkdirSync(venvPath, {recursive: true});
            } catch (e) {
                console.log(e);
            }
            const cmd = process.platform === 'win32' ? 'py' : 'python3';
            const args = process.platform === 'win32' ? ['-3', '-m', 'venv', '.'] : ['-m', 'venv', '.'];
            const venv_process = spawnSync(cmd, args, {cwd: venvPath});
            if (!venv_process.stdout.length || !venv_process.stderr.length) {
                console.log("Python venv created at:", venvPath);
                return {error: false, message: "Python virtual environment created at: " + venvPath, done: true}
            } else {
                console.log("Unexpected output received", (venv_process.stdout.toString().trim() || venv_process.stderr.toString().trim()));
                return {error: true, message: (venv_process.stdout.toString().trim() || venv_process.stderr.toString().trim())}
            }
        } catch (error) {
            console.log("Error creating virtual environment at: ", venvPath, error);
            return {error: true, message: "Error creating virtual environment: "}
        }
    },
    installPythonRequirements: (venvPath) => {
        console.log("Installing Python requirements at", venvPath);
        try {
            const venv_status = spawn(path.join(venvPath, 'bin', 'pip'), ['install', '-r', 'requirements.txt'], {cwd: path.join('.', 'py-darvester')});
            const main_window = BrowserWindow.getAllWindows()[0];

            venv_status.on('close', (code) => {
                console.log('close', code.toString().trim());
                main_window.webContents.send('utils:venv-status', {message: 'process ended, code ' + code, code: code, closed: true});
            });
            venv_status.on('error', (err) => {
                console.log('err', err.toString().trim());
                main_window.webContents('utils:venv-status', {message: err.message, code: err.code, closed: false});
            });
            venv_status.stdout.on('data', (data) => {
                console.log('stdout', data.toString().trim());
                main_window.webContents.send('utils:venv-status', {message: data.toString().trim(), code: null, closed: false});
            });
            venv_status.stderr.on('data', (data) => {
                console.log('stderr', data.toString().trim());
                main_window.webContents.send('utils:venv-status', {message: data.toString().trim(), code: 1, closed: false});
            });
            return {error: false, message: "Installing requirements..."}
            
            // pm2.connect(true, (err) => {
            //     if (err) {
            //         throw err
            //     }

            //     pm2.start({
            //         name: 'dep-darvester',
            //         cwd: venvPath,
            //         script: path.join(venvPath, 'bin', 'pip'),
            //         args: 'freeze',
            //         interpreter: null,
            //         interpreter_args: null,
            //     }, (err) => {
            //         if (err) {
            //             console.log(err)
            //             return pm2.disconnect()
            //         }
            //     });
            // });
        } catch (error) {
            console.log("Error installing requirements at: ", venvPath, error);
            return {error: true, message: "Error installing requirements: " + error}
        }
    }
}