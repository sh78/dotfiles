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
const vscode_1 = require("vscode");
const svn_1 = require("./svn");
const svnFinder_1 = require("./svnFinder");
const svnContentProvider_1 = require("./svnContentProvider");
const commands_1 = require("./commands");
const model_1 = require("./model");
const util_1 = require("./util");
const configuration_1 = require("./helpers/configuration");
function init(context, outputChannel, disposables) {
    return __awaiter(this, void 0, void 0, function* () {
        vscode_1.commands.executeCommand("setContext", "svnOpenRepositoryCount", "0");
        const pathHint = configuration_1.configuration.get("path");
        const svnFinder = new svnFinder_1.SvnFinder();
        const info = yield svnFinder.findSvn(pathHint);
        const svn = new svn_1.Svn({ svnPath: info.path, version: info.version });
        const model = new model_1.Model(svn);
        const contentProvider = new svnContentProvider_1.SvnContentProvider(model);
        const svnCommands = new commands_1.SvnCommands(model);
        disposables.push(model, contentProvider, svnCommands);
        // First, check the vscode has support to DecorationProvider
        if (util_1.hasSupportToDecorationProvider()) {
            Promise.resolve().then(() => require("./decorationProvider")).then(provider => {
                const decoration = new provider.SvnDecorations(model);
                disposables.push(decoration);
            });
        }
        const onRepository = () => vscode_1.commands.executeCommand("setContext", "svnOpenRepositoryCount", `${model.repositories.length}`);
        model.onDidOpenRepository(onRepository, null, disposables);
        model.onDidCloseRepository(onRepository, null, disposables);
        onRepository();
        vscode_1.commands.executeCommand("setContext", "svnHasSupportToRegisterDiffCommand", util_1.hasSupportToRegisterDiffCommand() ? "1" : "0");
        outputChannel.appendLine(`Using svn "${info.version}" from "${info.path}"`);
        const onOutput = (str) => outputChannel.append(str);
        svn.onOutput.addListener("log", onOutput);
        disposables.push(util_1.toDisposable(() => svn.onOutput.removeListener("log", onOutput)));
    });
}
function _activate(context, disposables) {
    return __awaiter(this, void 0, void 0, function* () {
        const outputChannel = vscode_1.window.createOutputChannel("Svn");
        vscode_1.commands.registerCommand("svn.showOutput", () => outputChannel.show());
        disposables.push(outputChannel);
        const showOutput = configuration_1.configuration.get("showOutput");
        if (showOutput) {
            outputChannel.show();
        }
        try {
            yield init(context, outputChannel, disposables);
        }
        catch (err) {
            if (!/Svn installation not found/.test(err.message || "")) {
                throw err;
            }
            const shouldIgnore = configuration_1.configuration.get("ignoreMissingSvnWarning") === true;
            if (shouldIgnore) {
                return;
            }
            console.warn(err.message);
            outputChannel.appendLine(err.message);
            outputChannel.show();
            const download = "Download SVN";
            const neverShowAgain = "Don't Show Again";
            const choice = yield vscode_1.window.showWarningMessage("SVN not found. Install it or configure it using the 'svn.path' setting.", download, neverShowAgain);
            if (choice === download) {
                vscode_1.commands.executeCommand("vscode.open", vscode_1.Uri.parse("https://subversion.apache.org/packages.html"));
            }
            else if (choice === neverShowAgain) {
                yield configuration_1.configuration.update("ignoreMissingSvnWarning", true);
            }
        }
    });
}
function activate(context) {
    return __awaiter(this, void 0, void 0, function* () {
        const disposables = [];
        context.subscriptions.push(new vscode_1.Disposable(() => vscode_1.Disposable.from(...disposables).dispose()));
        yield _activate(context, disposables).catch(err => console.error(err));
    });
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map