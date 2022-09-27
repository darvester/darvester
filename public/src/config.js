const fs = require('fs');
const path = require('path');
const log = require('electron-log');

// const { safeStorage } = require('electron');

const configPath = require('./const').configPath;

module.exports = {
    getBaseConfig: (app) => {
        return ({
            version: app.getVersion(),
            userData: app.getPath("userData"),
            pythonPath: "",
            pythonEnv: path.join(app.getPath("userData"), "python", ".env"),
            pythonVersion: "",
            databaseMethod: 'rest',
            host: 'localhost',
            port: '8000',
            // Core settings
            token: '',
            core_ignore_guilds: [],
            core_swap_ignore: false,
            core_debug: true,
            core_enable_presence: false,
            core_db_path: path.join(app.getPath("userData"), "python", "harvested.db"),
            core_quiet_mode: false,
            core_user_whitelist: [],
            core_last_scanned_interval: 600,
            core_log_level: 30,
            core_disable_vcs: false,
            core_vcs_path: path.join(app.getPath("userData"), "python", ".darvester")
        })
    },
    getConfig: () => {
        try {
            let config = fs.readFileSync(configPath);
            config = JSON.parse(config);
            return config;
        } catch (e) {
            log.error(e);
            return false;
        }
    },
    getConfigKey: (key) => {
        log.info("Key requested from config", key);
        try {
            let config = fs.readFileSync(configPath);
            config = JSON.parse(config);
            log.info("Returning key", key, "with value", config[key]);
            return config[key];
        } catch (e) {
            log.error(e);
            return null;
        }
    },
    validateConfig: (app) => {
        let config = JSON.parse(fs.readFileSync(configPath));
        let flag = false;
        log.info("Validate: Current config is:", config);
        for (let key in module.exports.getBaseConfig(app)) {
            if (!config.hasOwnProperty(key)) {
                log.info("Config key '" + key + "' not found. Writing default value...");
                config[key] = module.exports.getBaseConfig(app)[key];
                flag = true;
            }
        }
        if (flag) {
            log.info("Writing validated config...");
            fs.writeFileSync(configPath, JSON.stringify(config));
        }
        log.info("Validate: Done validating config:", config);
    },
    writeConfigKey: (key, value) => {
        const inner = new Promise((resolve, reject) => {
            let config = fs.readFileSync(configPath);
            config = JSON.parse(config);
            config[key] = value;
            fs.writeFileSync(configPath, JSON.stringify(config));
            log.info(`Wrote config key ${key} with value: ${value}`)
            return resolve(true);
        });
        return inner;
    },
    writeConfig: async (config) => {
        try {
            fs.writeFileSync(configPath, JSON.stringify(config));
            return true;
        } catch (e) {
            log.error(e);
            return false
        }
    },
    eraseConfig: async () => {
        try {
            fs.rmSync(configPath);
            return true;
        } catch (e) {
            log.error(e);
            return false;
        }
    },
    eraseConfigKey: (key) => {
        try {
            let config = fs.readFileSync(configPath);
            config = JSON.parse(config);
            delete config[key];
            fs.writeFileSync(configPath, JSON.stringify(config));
            return true;
        } catch (e) {
            log.error(e);
            return false;
        }
    },
    getFirstRun: (app) => {
        // Return true on error or if config file does not exist
        // False if config file exists and is valid
        if (!fs.existsSync(configPath)) {
            log.info("Darvester is configuring for the first run");
            try {
                try {
                    fs.mkdirSync(path.join(app.getPath('userData'), 'config'));
                } catch (e) {log.warn(e)}
                log.info("Detected platform: " + process.platform);
                log.info("Writing base config to " + configPath);
                fs.writeFileSync(configPath, JSON.stringify(module.exports.getBaseConfig(app)));
                return true;
            } catch (e) {
                log.error(e.message);
                return true;
            }
        }
        module.exports.validateConfig(app);
        return false;
    }
}
