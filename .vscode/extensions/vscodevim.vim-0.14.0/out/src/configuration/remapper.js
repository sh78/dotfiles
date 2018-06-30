"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const _ = require("lodash");
const vscode = require("vscode");
const commandLine_1 = require("../cmd_line/commandLine");
const configuration_1 = require("../configuration/configuration");
const mode_1 = require("../mode/mode");
const logger_1 = require("../util/logger");
class Remappers {
    constructor() {
        this.remappers = [
            new InsertModeRemapper(true),
            new NormalModeRemapper(true),
            new VisualModeRemapper(true),
            new InsertModeRemapper(false),
            new NormalModeRemapper(false),
            new VisualModeRemapper(false),
        ];
    }
    get isPotentialRemap() {
        return _.some(this.remappers, r => r.isPotentialRemap);
    }
    sendKey(keys, modeHandler, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            let handled = false;
            for (let remapper of this.remappers) {
                handled = handled || (yield remapper.sendKey(keys, modeHandler, vimState));
            }
            return handled;
        });
    }
}
exports.Remappers = Remappers;
class Remapper {
    constructor(configKey, remappedModes, recursive) {
        this._isPotentialRemap = false;
        this._configKey = configKey;
        this._recursive = recursive;
        this._remappedModes = remappedModes;
    }
    get isPotentialRemap() {
        return this._isPotentialRemap;
    }
    sendKey(keys, modeHandler, vimState) {
        return __awaiter(this, void 0, void 0, function* () {
            this._isPotentialRemap = false;
            if (this._remappedModes.indexOf(vimState.currentMode) === -1) {
                return false;
            }
            const userDefinedRemappings = configuration_1.configuration[this._configKey];
            for (let userDefinedRemapping of userDefinedRemappings) {
                logger_1.logger.debug(`Remapper: ${this._configKey}. loaded remappings. before=${userDefinedRemapping.before}. after=${userDefinedRemapping.after}. commands=${userDefinedRemapping.commands}.`);
            }
            // Check to see if the keystrokes match any user-specified remapping.
            let remapping;
            if (vimState.currentMode === mode_1.ModeName.Insert) {
                // In insert mode, we allow users to precede remapped commands
                // with extraneous keystrokes (e.g. "hello world jj")
                const longestKeySequence = Remapper._getLongestedRemappedKeySequence(userDefinedRemappings);
                for (let sliceLength = 1; sliceLength <= longestKeySequence; sliceLength++) {
                    const slice = keys.slice(-sliceLength);
                    const result = _.find(userDefinedRemappings, map => map.before.join('') === slice.join(''));
                    if (result) {
                        remapping = result;
                        break;
                    }
                }
            }
            else {
                // In other modes, we have to precisely match the entire keysequence
                remapping = _.find(userDefinedRemappings, map => {
                    return map.before.join('') === keys.join('');
                });
            }
            if (remapping) {
                logger_1.logger.debug(`Remapper: ${this._configKey}. match found. before=${remapping.before}. after=${remapping.after}. command=${remapping.commands}.`);
                if (!this._recursive) {
                    vimState.isCurrentlyPerformingRemapping = true;
                }
                // Record length of remapped command
                vimState.recordedState.numberOfRemappedKeys += remapping.before.length;
                const numToRemove = remapping.before.length - 1;
                // Revert previously inserted characters
                // (e.g. jj remapped to esc, we have to revert the inserted "jj")
                if (vimState.currentMode === mode_1.ModeName.Insert) {
                    // Revert every single inserted character.
                    // We subtract 1 because we haven't actually applied the last key.
                    yield vimState.historyTracker.undoAndRemoveChanges(Math.max(0, numToRemove * vimState.allCursors.length));
                    vimState.cursorPosition = vimState.cursorPosition.getLeft(numToRemove);
                }
                // We need to remove the keys that were remapped into different keys
                // from the state.
                vimState.recordedState.actionKeys = vimState.recordedState.actionKeys.slice(0, -numToRemove);
                vimState.keyHistory = vimState.keyHistory.slice(0, -numToRemove);
                if (remapping.after) {
                    const count = vimState.recordedState.count || 1;
                    vimState.recordedState.count = 0;
                    for (let i = 0; i < count; i++) {
                        yield modeHandler.handleMultipleKeyEvents(remapping.after);
                    }
                }
                if (remapping.commands) {
                    for (const command of remapping.commands) {
                        // Check if this is a vim command by looking for :
                        if (command.command.slice(0, 1) === ':') {
                            yield commandLine_1.commandLine.Run(command.command.slice(1, command.command.length), modeHandler.vimState);
                            yield modeHandler.updateView(modeHandler.vimState);
                        }
                        else {
                            yield vscode.commands.executeCommand(command.command, command.args);
                        }
                    }
                }
                vimState.isCurrentlyPerformingRemapping = false;
                return true;
            }
            // Check to see if a remapping could potentially be applied when more keys are received
            for (let remap of userDefinedRemappings) {
                if (keys.join('') === remap.before.slice(0, keys.length).join('')) {
                    this._isPotentialRemap = true;
                    break;
                }
            }
            return false;
        });
    }
    static _getLongestedRemappedKeySequence(remappings) {
        if (remappings.length === 0) {
            return 1;
        }
        return _.maxBy(remappings, map => map.before.length).before.length;
    }
}
class InsertModeRemapper extends Remapper {
    constructor(recursive) {
        super('insertModeKeyBindings' + (recursive ? '' : 'NonRecursive'), [mode_1.ModeName.Insert, mode_1.ModeName.Replace], recursive);
    }
}
class NormalModeRemapper extends Remapper {
    constructor(recursive) {
        super('normalModeKeyBindings' + (recursive ? '' : 'NonRecursive'), [mode_1.ModeName.Normal], recursive);
    }
}
class VisualModeRemapper extends Remapper {
    constructor(recursive) {
        super('visualModeKeyBindings' + (recursive ? '' : 'NonRecursive'), [mode_1.ModeName.Visual, mode_1.ModeName.VisualLine, mode_1.ModeName.VisualBlock], recursive);
    }
}

//# sourceMappingURL=remapper.js.map
