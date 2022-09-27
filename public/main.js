const { app, BrowserWindow, ipcMain } = require('electron');
const { getFirstRun, getConfigKey, getConfig, writeConfigKey } = require('./src/config');
const { askPythonVersion, createPythonVenv, installPythonRequirements } = require('./src/utils');
const { startCore, startApi, getStatus, describeProcess, sendSigInt } = require('./src/processes');
const path = require('path');

// Register handlers for ipcMain events
// utils
ipcMain.handle('utils:ask-python-version', askPythonVersion);
ipcMain.handle('utils:create-python-venv', (e, venvPath) => createPythonVenv(venvPath));
// config
ipcMain.handle('config:ask-first-run', () => getFirstRun(app));
ipcMain.handle('config:get-config-key', (e, key) => getConfigKey(key));
ipcMain.handle('config:get-config', getConfig);
ipcMain.handle('config:write-config-key', (e, key, value) => writeConfigKey(key, value));
ipcMain.handle('config:install-pip-deps', (e, venvPath) => {installPythonRequirements(venvPath)})
// processes
ipcMain.handle('processes:start-core', startCore);
ipcMain.handle('processes:start-api', startApi);
ipcMain.handle('processes:get-status', getStatus);
ipcMain.handle('processes:describe-status', (e, processName) => describeProcess(processName));
ipcMain.handle('processes:send-sigint', (e, processName) => sendSigInt(processName));

function createWindow (app) {
  // Create the browser window.
  const win = new BrowserWindow({
    backgroundColor: "#333333",
    width: 1280,
    height: 900,
    webPreferences: {
      nodeIntegration: true,
      // enableRemoteModule: true,
      // contextIsolation: false,
      frame: false,
      preload: path.join(__dirname, 'src', 'preload.js')
    }
  });

  win.removeMenu();

  //load the index.html from a url
  win.loadURL('http://localhost:3000');

  // Open the DevTools.
  // win.webContents.openDevTools()
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  createWindow(app);
});

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.