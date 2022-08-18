const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    version: '2.0.0',
    // Config
    askFirstRun: () => ipcRenderer.invoke('config:ask-first-run'),
    getConfigKey: (key) => ipcRenderer.invoke('config:get-config-key', key),
    getConfig: () => ipcRenderer.invoke('config:get-config'),
    writeConfigKey: (key, value) => ipcRenderer.invoke('config:write-config-key', key, value),
    // Utils
    askPythonVersion: () => ipcRenderer.invoke('utils:ask-python-version'),
    createPythonVenv: (venvPath) => ipcRenderer.invoke('utils:create-python-venv', venvPath),
    installPythonRequirements: (venvPath) => ipcRenderer.invoke('config:install-pip-deps', venvPath),
    onVenvStatus: (callback) => ipcRenderer.on('utils:venv-status', callback)
});