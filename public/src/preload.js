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
    onVenvStatus: (callback) => ipcRenderer.on('utils:venv-status', callback),
    // Processes
    startCore: () => ipcRenderer.invoke('processes:start-core'),
    startApi: () => ipcRenderer.invoke('processes:start-api'),
    getStatus: () => ipcRenderer.invoke('processes:get-status'),
    describeProcess: (processName) => ipcRenderer.invoke('processes:describe-status', processName),
    sendSigInt: (processName) => ipcRenderer.invoke('processes:send-sigint', processName),
    onGetStatus: (callback) => ipcRenderer.on('processes:get-status-message', callback),
    onDescribeStatus: (callback) => ipcRenderer.on('processes:get-describe-status', callback),
    onCoreStatus: (callback) => ipcRenderer.on('processes:core-status', callback),
    onApiStatus: (callback) => ipcRenderer.on('processes:api-status', callback),
});