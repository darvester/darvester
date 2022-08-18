const path = require('path');
const { app } = require('electron');

module.exports = {
    version: app.getVersion(),
    configPath: path.join(app.getPath('userData'), 'config', 'config.json')
}