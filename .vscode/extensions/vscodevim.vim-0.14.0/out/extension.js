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
/**
 * Extension.ts is a lightweight wrapper around ModeHandler. It converts key
 * events to their string names and passes them on to ModeHandler via
 * handleKeyEvent().
 */
require("./src/actions/include-all");
const _ = require("lodash");
const vscode = require("vscode");
const configuration_1 = require("./src/configuration/configuration");
const commandLine_1 = require("./src/cmd_line/commandLine");
const position_1 = require("./src/common/motion/position");
const editorIdentity_1 = require("./src/editorIdentity");
const globals_1 = require("./src/globals");
const mode_1 = require("./src/mode/mode");
const neovim_1 = require("./src/neovim/neovim");
const notation_1 = require("./src/configuration/notation");
const statusBar_1 = require("./src/statusBar");
const taskQueue_1 = require("./src/taskQueue");
const modeHandlerMap_1 = require("./src/mode/modeHandlerMap");
const logger_1 = require("./src/util/logger");
const compositionState_1 = require("./src/state/compositionState");
let extensionContext;
let previousActiveEditorId = new editorIdentity_1.EditorIdentity();
function getAndUpdateModeHandler() {
    return __awaiter(this, void 0, void 0, function* () {
        const prevHandler = modeHandlerMap_1.ModeHandlerMap.get(previousActiveEditorId.toString());
        const activeEditorId = new editorIdentity_1.EditorIdentity(vscode.window.activeTextEditor);
        let [curHandler, isNewModeHandler] = yield modeHandlerMap_1.ModeHandlerMap.getOrCreate(activeEditorId.toString());
        if (isNewModeHandler) {
            if (configuration_1.configuration.enableNeovim) {
                const neovim = new neovim_1.Neovim();
                yield neovim.initialize();
                curHandler.vimState.nvim = neovim;
            }
            extensionContext.subscriptions.push(curHandler);
        }
        curHandler.vimState.editor = vscode.window.activeTextEditor;
        if (!prevHandler || curHandler.vimState.identity !== prevHandler.vimState.identity) {
            curHandler.syncCursors();
        }
        if (previousActiveEditorId.hasSameBuffer(activeEditorId)) {
            if (!previousActiveEditorId.isEqual(activeEditorId)) {
                // We have opened two editors, working on the same file.
                previousActiveEditorId = activeEditorId;
            }
        }
        else {
            previousActiveEditorId = activeEditorId;
            yield curHandler.updateView(curHandler.vimState, { drawSelection: false, revealRange: false });
        }
        if (prevHandler && curHandler.vimState.focusChanged) {
            curHandler.vimState.focusChanged = false;
            prevHandler.vimState.focusChanged = true;
        }
        return curHandler;
    });
}
exports.getAndUpdateModeHandler = getAndUpdateModeHandler;
function activate(context) {
    return __awaiter(this, void 0, void 0, function* () {
        logger_1.logger.debug('Extension: activating vscodevim.');
        extensionContext = context;
        let compositionState = new compositionState_1.CompositionState();
        extensionContext.subscriptions.push(statusBar_1.StatusBar);
        logger_1.logger.debug('Extension: registering event handlers.');
        // workspace events
        vscode.workspace.onDidChangeConfiguration(() => {
            logger_1.logger.debug('onDidChangeConfiguration: reloading configuration');
            configuration_1.configuration.reload();
        });
        vscode.workspace.onDidChangeTextDocument(event => {
            if (configuration_1.configuration.disableExt) {
                return;
            }
            // Change from vscode editor should set document.isDirty to true but they initially don't!
            // There is a timing issue in vscode codebase between when the isDirty flag is set and
            // when registered callbacks are fired. https://github.com/Microsoft/vscode/issues/11339
            let contentChangeHandler = (modeHandler) => {
                if (modeHandler.vimState.currentMode === mode_1.ModeName.Insert) {
                    if (modeHandler.vimState.historyTracker.currentContentChanges === undefined) {
                        modeHandler.vimState.historyTracker.currentContentChanges = [];
                    }
                    modeHandler.vimState.historyTracker.currentContentChanges = modeHandler.vimState.historyTracker.currentContentChanges.concat(event.contentChanges);
                }
            };
            if (globals_1.Globals.isTesting) {
                contentChangeHandler(globals_1.Globals.mockModeHandler);
            }
            else {
                _.filter(modeHandlerMap_1.ModeHandlerMap.getAll(), modeHandler => modeHandler.vimState.identity.fileName === event.document.fileName).forEach(modeHandler => {
                    contentChangeHandler(modeHandler);
                });
            }
            setTimeout(() => {
                if (!event.document.isDirty && !event.document.isUntitled && event.contentChanges.length) {
                    handleContentChangedFromDisk(event.document);
                }
            }, 0);
        });
        vscode.workspace.onDidCloseTextDocument(() => __awaiter(this, void 0, void 0, function* () {
            const documents = vscode.workspace.textDocuments;
            // Delete modehandler once all tabs of this document have been closed
            for (let editorIdentity of modeHandlerMap_1.ModeHandlerMap.getKeys()) {
                let modeHandler = yield modeHandlerMap_1.ModeHandlerMap.get(editorIdentity);
                if (modeHandler == null ||
                    modeHandler.vimState.editor === undefined ||
                    documents.indexOf(modeHandler.vimState.editor.document) === -1) {
                    modeHandlerMap_1.ModeHandlerMap.delete(editorIdentity);
                }
            }
        }));
        // window events
        vscode.window.onDidChangeActiveTextEditor(handleActiveEditorChange, this);
        // override vscode commands
        overrideCommand(context, 'type', (args) => __awaiter(this, void 0, void 0, function* () {
            taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
                const mh = yield getAndUpdateModeHandler();
                if (compositionState.isInComposition) {
                    compositionState.composingText += args.text;
                }
                else {
                    yield mh.handleKeyEvent(args.text);
                }
            }));
        }));
        overrideCommand(context, 'replacePreviousChar', (args) => __awaiter(this, void 0, void 0, function* () {
            taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
                const mh = yield getAndUpdateModeHandler();
                if (compositionState.isInComposition) {
                    compositionState.composingText =
                        compositionState.composingText.substr(0, compositionState.composingText.length - args.replaceCharCnt) + args.text;
                }
                else {
                    yield vscode.commands.executeCommand('default:replacePreviousChar', {
                        text: args.text,
                        replaceCharCnt: args.replaceCharCnt,
                    });
                    mh.vimState.cursorPosition = position_1.Position.FromVSCodePosition(mh.vimState.editor.selection.start);
                    mh.vimState.cursorStartPosition = position_1.Position.FromVSCodePosition(mh.vimState.editor.selection.start);
                }
            }));
        }));
        overrideCommand(context, 'compositionStart', (args) => __awaiter(this, void 0, void 0, function* () {
            taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
                compositionState.isInComposition = true;
            }));
        }));
        overrideCommand(context, 'compositionEnd', (args) => __awaiter(this, void 0, void 0, function* () {
            taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
                const mh = yield getAndUpdateModeHandler();
                let text = compositionState.composingText;
                compositionState.reset();
                yield mh.handleMultipleKeyEvents(text.split(''));
            }));
        }));
        // register extension commands
        registerCommand(context, 'vim.remap', (args) => __awaiter(this, void 0, void 0, function* () {
            taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
                const mh = yield getAndUpdateModeHandler();
                if (args.after) {
                    for (const key of args.after) {
                        yield mh.handleKeyEvent(notation_1.Notation.NormalizeKey(key, configuration_1.configuration.leader));
                    }
                    return;
                }
                if (args.commands) {
                    for (const command of args.commands) {
                        // Check if this is a vim command by looking for :
                        if (command.command.slice(0, 1) === ':') {
                            yield commandLine_1.commandLine.Run(command.command.slice(1, command.command.length), mh.vimState);
                            yield mh.updateView(mh.vimState);
                        }
                        else {
                            yield vscode.commands.executeCommand(command.command, command.args);
                        }
                    }
                }
            }));
        }));
        registerCommand(context, 'toggleVim', () => __awaiter(this, void 0, void 0, function* () {
            configuration_1.configuration.disableExt = !configuration_1.configuration.disableExt;
            toggleExtension(configuration_1.configuration.disableExt, compositionState);
        }));
        for (const boundKey of configuration_1.configuration.boundKeyCombinations) {
            registerCommand(context, boundKey.command, () => handleKeyEvent(`${boundKey.key}`));
        }
        // Initialize mode handler for current active Text Editor at startup.
        if (vscode.window.activeTextEditor) {
            let mh = yield getAndUpdateModeHandler();
            mh.updateView(mh.vimState, { drawSelection: false, revealRange: false });
        }
        // This is called last because getAndUpdateModeHandler() will change cursor
        toggleExtension(configuration_1.configuration.disableExt, compositionState);
    });
}
exports.activate = activate;
/**
 * Toggles the VSCodeVim extension between Enabled mode and Disabled mode. This
 * function is activated by calling the 'toggleVim' command from the Command Palette.
 *
 * @param isDisabled if true, sets VSCodeVim to Disabled mode; else sets to enabled mode
 */
function toggleExtension(isDisabled, compositionState) {
    return __awaiter(this, void 0, void 0, function* () {
        yield vscode.commands.executeCommand('setContext', 'vim.active', !isDisabled);
        let mh = yield getAndUpdateModeHandler();
        if (isDisabled) {
            yield mh.handleKeyEvent('<ExtensionDisable>');
            compositionState.reset();
            modeHandlerMap_1.ModeHandlerMap.clear();
        }
        else {
            yield mh.handleKeyEvent('<ExtensionEnable>');
        }
    });
}
function overrideCommand(context, command, callback) {
    const disposable = vscode.commands.registerCommand(command, (args) => __awaiter(this, void 0, void 0, function* () {
        if (configuration_1.configuration.disableExt) {
            yield vscode.commands.executeCommand('default:' + command, args);
            return;
        }
        if (!vscode.window.activeTextEditor) {
            return;
        }
        if (vscode.window.activeTextEditor.document &&
            vscode.window.activeTextEditor.document.uri.toString() === 'debug:input') {
            yield vscode.commands.executeCommand('default:' + command, args);
            return;
        }
        callback(args);
    }));
    context.subscriptions.push(disposable);
}
function registerCommand(context, command, callback) {
    let disposable = vscode.commands.registerCommand(command, (args) => __awaiter(this, void 0, void 0, function* () {
        if (!vscode.window.activeTextEditor) {
            return;
        }
        callback(args);
    }));
    context.subscriptions.push(disposable);
}
function handleKeyEvent(key) {
    return __awaiter(this, void 0, void 0, function* () {
        const mh = yield getAndUpdateModeHandler();
        taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
            yield mh.handleKeyEvent(key);
        }));
    });
}
function handleContentChangedFromDisk(document) {
    _.filter(modeHandlerMap_1.ModeHandlerMap.getAll(), modeHandler => modeHandler.vimState.identity.fileName === document.fileName).forEach(modeHandler => {
        modeHandler.vimState.historyTracker.clear();
    });
}
function handleActiveEditorChange() {
    return __awaiter(this, void 0, void 0, function* () {
        if (configuration_1.configuration.disableExt) {
            return;
        }
        // Don't run this event handler during testing
        if (globals_1.Globals.isTesting) {
            return;
        }
        taskQueue_1.taskQueue.enqueueTask(() => __awaiter(this, void 0, void 0, function* () {
            if (vscode.window.activeTextEditor !== undefined) {
                const mh = yield getAndUpdateModeHandler();
                mh.updateView(mh.vimState, { drawSelection: false, revealRange: false });
            }
        }));
    });
}
process.on('unhandledRejection', function (reason, p) {
    logger_1.logger.error(`Unhandled Rejection at: Promise ${p}. Reason: ${reason}.`);
});

//# sourceMappingURL=extension.js.map
