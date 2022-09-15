const pm2 = require('pm2');
const path = require('path');
const { getConfigKey } = require('./config');
const { BrowserWindow } = require('electron');

module.exports = {
    startCore: () => {
        const main_window = BrowserWindow.getAllWindows()[0];
        pm2.connect((err) => {
            if (err) {
                console.error(err);
                main_window.webContents.send('processes:core-status', {error: true, message: err});
            }

            pm2.start({
                script: path.join(__dirname, '..', '..', 'py-darvester', 'run.py'),
                name: 'darvester-core',
                cwd: path.join(getConfigKey('userData'), 'python'),
                args: '',
                interpreter: path.join(getConfigKey('pythonEnv'), 'bin', 'python'),
            }, (err, proc) => {
                if (err) {
                    console.error(err);
                    pm2.disconnect();
                    main_window.webContents.send('processes:core-status', {error: true, message: err});
                }
                main_window.webContents.send('processes:core-status', {error: false, message: proc});
            });
        })
    },
    startApi: () => {
        const main_window = BrowserWindow.getAllWindows()[0];
        pm2.connect((err) => {
            if (err) {
                console.error(err);
                main_window.webContents.send('processes:api-status', {error: true, message: err});
            }
            
            pm2.start({
                script: path.join(__dirname, '..', '..', 'py-darvester-api', 'main.py'),
                name: 'darvester-api',
                cwd: path.join(getConfigKey('userData'), 'python'),
                args: '--db ' + path.join(getConfigKey('userData'), 'harvested.db'),
                interpreter: path.join(getConfigKey('pythonEnv'), 'bin', 'python'),
            }, (err, proc) => {
                if (err) {
                    console.error(err);
                    pm2.disconnect();
                    main_window.webContents.send('processes:api-status', {error: true, message: err});
                }
                main_window.webContents.send('processes:api-status', {error: false, message: proc});
            })
        })
    },
    getStatus: () => {
        const main_window = BrowserWindow.getAllWindows()[0];
        pm2.connect((err) => {
            if (err) {
                console.error(err);
                main_window.webContents.send('processes:get-status-message', {error: true, message: err});
            }
            pm2.list((err, apps) => {
                if (err) {
                    console.error(err);
                    main_window.webContents.send('processes:get-status-message', {error: true, message: err});
                }
                main_window.webContents.send('processes:get-status-message', {error: false, message: apps});
            });
        })
    },
    describeProcess: (processName) => {
        const main_window = BrowserWindow.getAllWindows()[0];
        pm2.connect((err) => {
            if (err) {
                console.error(err);
                main_window.webContents.send('processes:get-describe-message', {error: true, message: err});
            }
            pm2.describe(processName, (err, proc) => {
                if (err) {
                    console.error(err);
                    main_window.webContents.send('processes:get-describe-message', {error: true, message: err});
                }
                main_window.webContents.send('processes:get-describe-message', {error: false, message: proc});
            })
        })
    },
    sendSigInt: (processName) => {
        const main_window = BrowserWindow.getAllWindows()[0];
        pm2.connect((err) => {
            if (err) {
                console.error(err);
                main_window.webContents.send('processes:get-sigint-message', {error: true, message: err});
            }
            pm2.sendSignalToProcessName('SIGINT', processName, (err, proc) => {
                if (err) {
                    console.error(err);
                    main_window.webContents.send('processes:get-sigint-message', {error: true, message: err});
                }
                main_window.webContents.send('processes:get-sigint-message', {error: false, message: proc});
            })
        })
    }
}
