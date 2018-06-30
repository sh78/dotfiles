"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = require("fs");
const constants_1 = require("../constants");
const utils_1 = require("../utils");
function getAppUserPath(dirPath) {
    const isDev = /oss-dev/i.test(dirPath);
    const isOSS = !isDev && /oss/i.test(dirPath);
    const isInsiders = /insiders/i.test(dirPath);
    const vscodeAppName = isInsiders ? 'Code - Insiders' : isOSS ? 'Code - OSS' : isDev ? 'code-oss-dev' : 'Code';
    return utils_1.pathUnixJoin(utils_1.vscodePath(), vscodeAppName, 'User');
}
exports.getAppUserPath = getAppUserPath;
function removeVSIconsSettings(settings) {
    Reflect.ownKeys(settings)
        .map(key => key.toString())
        .filter(key => /^vsicons\..+/.test(key))
        .forEach(key => delete settings[key]);
}
exports.removeVSIconsSettings = removeVSIconsSettings;
function resetThemeSetting(settings) {
    if (settings[constants_1.constants.vscode.iconThemeSetting] === constants_1.constants.extensionName) {
        settings[constants_1.constants.vscode.iconThemeSetting] = null;
    }
}
exports.resetThemeSetting = resetThemeSetting;
function cleanUpVSCodeSettings() {
    const saveSettings = content => {
        const settings = JSON.stringify(content, null, 4);
        fs_1.writeFile(settingsFilePath, settings, err => console.error(err));
    };
    const cleanUpSettings = (err, content) => {
        if (err) {
            console.error(err);
            return;
        }
        const settings = utils_1.parseJSON(content);
        if (!settings) {
            return;
        }
        removeVSIconsSettings(settings);
        resetThemeSetting(settings);
        saveSettings(settings);
    };
    const settingsFilePath = utils_1.pathUnixJoin(getAppUserPath(__dirname), 'settings.json');
    fs_1.readFile(settingsFilePath, 'utf8', cleanUpSettings);
}
exports.cleanUpVSCodeSettings = cleanUpVSCodeSettings;
function cleanUpVSIconsSettings() {
    fs_1.unlink(utils_1.pathUnixJoin(getAppUserPath(__dirname), 'vsicons.settings.json'), err => console.error(err));
}
exports.cleanUpVSIconsSettings = cleanUpVSIconsSettings;
//# sourceMappingURL=index.js.map