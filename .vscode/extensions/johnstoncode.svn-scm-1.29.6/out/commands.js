"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
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
const messages_1 = require("./messages");
const svn_1 = require("./svn");
const resource_1 = require("./resource");
const uri_1 = require("./uri");
const fs = require("fs");
const path = require("path");
const conflictItems_1 = require("./conflictItems");
const lineChanges_1 = require("./lineChanges");
const util_1 = require("./util");
const changelistItems_1 = require("./changelistItems");
const configuration_1 = require("./helpers/configuration");
const branches_1 = require("./branches");
const ignoreitems_1 = require("./ignoreitems");
const Commands = [];
function command(commandId, options = {}) {
    return (target, key, descriptor) => {
        if (!(typeof descriptor.value === "function")) {
            throw new Error("not supported");
        }
        Commands.push({ commandId, key, method: descriptor.value, options });
    };
}
class SvnCommands {
    constructor(model) {
        this.model = model;
        this.disposables = Commands.map(({ commandId, method, options }) => {
            const command = this.createCommand(method, options);
            if (options.diff && util_1.hasSupportToRegisterDiffCommand()) {
                return vscode_1.commands.registerDiffInformationCommand(commandId, command);
            }
            else {
                return vscode_1.commands.registerCommand(commandId, command);
            }
        });
    }
    createCommand(method, options) {
        const result = (...args) => {
            let result;
            if (!options.repository) {
                result = Promise.resolve(method.apply(this, args));
            }
            else {
                const repository = this.model.getRepository(args[0]);
                let repositoryPromise;
                if (repository) {
                    repositoryPromise = Promise.resolve(repository);
                }
                else if (this.model.repositories.length === 1) {
                    repositoryPromise = Promise.resolve(this.model.repositories[0]);
                }
                else {
                    repositoryPromise = this.model.pickRepository();
                }
                result = repositoryPromise.then(repository => {
                    if (!repository) {
                        return Promise.resolve();
                    }
                    return Promise.resolve(method.apply(this, [repository, ...args]));
                });
            }
            return result.catch(err => {
                console.error(err);
            });
        };
        return result;
    }
    getModel() {
        return this.model;
    }
    fileOpen(resourceUri) {
        return __awaiter(this, void 0, void 0, function* () {
            yield vscode_1.commands.executeCommand("vscode.open", resourceUri);
        });
    }
    promptAuth(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            const username = yield vscode_1.window.showInputBox({
                placeHolder: "Svn repository username",
                prompt: "Please enter your username",
                value: repository.username
            });
            if (username === undefined) {
                return false;
            }
            const password = yield vscode_1.window.showInputBox({
                placeHolder: "Svn repository password",
                prompt: "Please enter your password",
                password: true
            });
            if (username === undefined) {
                return false;
            }
            repository.username = username;
            repository.password = password;
            return true;
        });
    }
    commitWithMessage(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            const choice = yield changelistItems_1.inputCommitChangelist(repository);
            if (!choice) {
                return;
            }
            const message = yield messages_1.inputCommitMessage(repository.inputBox.value, false);
            if (message === undefined) {
                return;
            }
            const filePaths = choice.resourceGroup.resourceStates.map(state => {
                return state.resourceUri.fsPath;
            });
            // If files is renamed, the commit need previous file
            choice.resourceGroup.resourceStates.forEach(state => {
                if (state instanceof resource_1.Resource) {
                    if (state.type === svn_1.Status.ADDED && state.renameResourceUri) {
                        filePaths.push(state.renameResourceUri.fsPath);
                    }
                }
            });
            try {
                const result = yield repository.commitFiles(message, filePaths);
                vscode_1.window.showInformationMessage(result);
                repository.inputBox.value = "";
            }
            catch (error) {
                console.error(error);
                vscode_1.window.showErrorMessage(error.stderrFormated);
            }
        });
    }
    addFile(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            const uris = selection.map(resource => resource.resourceUri);
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const paths = resources.map(resource => resource.fsPath);
                try {
                    yield repository.addFiles(paths);
                }
                catch (error) {
                    console.log(error);
                    vscode_1.window.showErrorMessage("Unable to add file");
                }
            }));
        });
    }
    changelist(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            const uris = selection.map(resource => resource.resourceUri);
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                let canRemove = false;
                repository.changelists.forEach((group, changelist) => {
                    if (group.resourceStates.some(state => {
                        return resources.some(resource => {
                            return resource.path === state.resourceUri.path;
                        });
                    })) {
                        console.log("canRemove true");
                        canRemove = true;
                        return false;
                    }
                });
                const changelistName = yield changelistItems_1.inputSwitchChangelist(repository, canRemove);
                if (!changelistName && changelistName !== false) {
                    return;
                }
                const paths = resources.map(resource => resource.fsPath);
                if (changelistName === false) {
                    try {
                        yield repository.removeChangelist(paths);
                    }
                    catch (error) {
                        console.log(error);
                        vscode_1.window.showErrorMessage(`Unable to remove file "${paths.join(",")}" from changelist`);
                    }
                }
                else {
                    try {
                        yield repository.addChangelist(paths, changelistName);
                    }
                    catch (error) {
                        console.log(error);
                        vscode_1.window.showErrorMessage(`Unable to add file "${paths.join(",")}" to changelist "${changelistName}"`);
                    }
                }
            }));
        });
    }
    commit(...resources) {
        return __awaiter(this, void 0, void 0, function* () {
            if (resources.length === 0 || !(resources[0].resourceUri instanceof vscode_1.Uri)) {
                const resource = this.getSCMResource();
                if (!resource) {
                    return;
                }
                resources = [resource];
            }
            const selection = resources.filter(s => s instanceof resource_1.Resource);
            const uris = selection.map(resource => resource.resourceUri);
            selection.forEach(resource => {
                if (resource.type === svn_1.Status.ADDED && resource.renameResourceUri) {
                    uris.push(resource.renameResourceUri);
                }
            });
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const paths = resources.map(resource => resource.fsPath);
                try {
                    const message = yield messages_1.inputCommitMessage(repository.inputBox.value);
                    if (message === undefined) {
                        return;
                    }
                    repository.inputBox.value = message;
                    const result = yield repository.commitFiles(message, paths);
                    vscode_1.window.showInformationMessage(result);
                    repository.inputBox.value = "";
                }
                catch (error) {
                    console.error(error);
                    vscode_1.window.showErrorMessage(error.stderrFormated);
                }
            }));
        });
    }
    refresh(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            yield repository.status();
        });
    }
    openResourceBase(resource) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._openResource(resource, "BASE", undefined, true, false);
        });
    }
    openResourceHead(resource) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._openResource(resource, "HEAD", undefined, true, false);
        });
    }
    openFile(arg, ...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const preserveFocus = arg instanceof resource_1.Resource;
            let uris;
            if (arg instanceof vscode_1.Uri) {
                if (arg.scheme === "svn") {
                    uris = [vscode_1.Uri.file(uri_1.fromSvnUri(arg).fsPath)];
                }
                else if (arg.scheme === "file") {
                    uris = [arg];
                }
            }
            else {
                let resource = arg;
                if (!(resource instanceof resource_1.Resource)) {
                    // can happen when called from a keybinding
                    resource = this.getSCMResource();
                }
                if (resource) {
                    uris = [
                        ...resourceStates.map(r => r.resourceUri),
                        resource.resourceUri
                    ];
                }
            }
            if (!uris) {
                return;
            }
            const preview = uris.length === 1 ? true : false;
            const activeTextEditor = vscode_1.window.activeTextEditor;
            for (const uri of uris) {
                if (fs.statSync(uri.fsPath).isDirectory()) {
                    continue;
                }
                const opts = {
                    preserveFocus,
                    preview: preview,
                    viewColumn: vscode_1.ViewColumn.Active
                };
                if (activeTextEditor &&
                    activeTextEditor.document.uri.toString() === uri.toString()) {
                    opts.selection = activeTextEditor.selection;
                }
                const document = yield vscode_1.workspace.openTextDocument(uri);
                yield vscode_1.window.showTextDocument(document, opts);
            }
        });
    }
    openHEADFile(arg) {
        return __awaiter(this, void 0, void 0, function* () {
            let resource;
            if (arg instanceof resource_1.Resource) {
                resource = arg;
            }
            else if (arg instanceof vscode_1.Uri) {
                resource = this.getSCMResource(arg);
            }
            else {
                resource = this.getSCMResource();
            }
            if (!resource) {
                return;
            }
            const HEAD = this.getLeftResource(resource, "HEAD");
            const basename = path.basename(resource.resourceUri.fsPath);
            if (!HEAD) {
                vscode_1.window.showWarningMessage(`"HEAD version of '${basename}' is not available."`);
                return;
            }
            const basedir = path.dirname(resource.resourceUri.fsPath);
            const uri = HEAD.with({
                path: path.join(basedir, `(HEAD) ${basename}`) // change document title
            });
            return vscode_1.commands.executeCommand("vscode.open", uri, {
                preview: true
            });
        });
    }
    openChangeBase(arg, ...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.openChange(arg, "BASE", resourceStates);
        });
    }
    openChangeHead(arg, ...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.openChange(arg, "HEAD", resourceStates);
        });
    }
    openChange(arg, against, resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const preserveFocus = arg instanceof resource_1.Resource;
            const preserveSelection = arg instanceof vscode_1.Uri || !arg;
            let resources;
            if (arg instanceof vscode_1.Uri) {
                const resource = this.getSCMResource(arg);
                if (resource !== undefined) {
                    resources = [resource];
                }
            }
            else {
                let resource;
                if (arg instanceof resource_1.Resource) {
                    resource = arg;
                }
                else {
                    resource = this.getSCMResource();
                }
                if (resource) {
                    resources = [...resourceStates, resource];
                }
            }
            if (!resources) {
                return;
            }
            const preview = resources.length === 1 ? undefined : false;
            for (const resource of resources) {
                yield this._openResource(resource, against, preview, preserveFocus, preserveSelection);
            }
        });
    }
    _openResource(resource, against, preview, preserveFocus, preserveSelection) {
        return __awaiter(this, void 0, void 0, function* () {
            const left = this.getLeftResource(resource, against);
            const right = this.getRightResource(resource, against);
            const title = this.getTitle(resource, against);
            if (!right) {
                // TODO
                console.error("oh no");
                return;
            }
            if (fs.existsSync(right.fsPath) &&
                fs.statSync(right.fsPath).isDirectory()) {
                return;
            }
            const opts = {
                preserveFocus,
                preview,
                viewColumn: vscode_1.ViewColumn.Active
            };
            const activeTextEditor = vscode_1.window.activeTextEditor;
            if (preserveSelection &&
                activeTextEditor &&
                activeTextEditor.document.uri.toString() === right.toString()) {
                opts.selection = activeTextEditor.selection;
            }
            if (!left) {
                return vscode_1.commands.executeCommand("vscode.open", right, opts);
            }
            return vscode_1.commands.executeCommand("vscode.diff", left, right, title, opts);
        });
    }
    getLeftResource(resource, against = "") {
        if (resource.type === svn_1.Status.ADDED && resource.renameResourceUri) {
            return uri_1.toSvnUri(resource.renameResourceUri, uri_1.SvnUriAction.SHOW, {
                ref: against
            });
        }
        // Show file if has conflicts marks
        if (resource.type == svn_1.Status.CONFLICTED &&
            fs.existsSync(resource.resourceUri.fsPath)) {
            const text = fs.readFileSync(resource.resourceUri.fsPath, {
                encoding: "utf8"
            });
            // Check for lines begin with "<<<<<<", "=======", ">>>>>>>"
            if (/^<{7}[^]+^={7}[^]+^>{7}/m.test(text)) {
                return undefined;
            }
        }
        switch (resource.type) {
            case svn_1.Status.CONFLICTED:
            case svn_1.Status.MODIFIED:
            case svn_1.Status.REPLACED:
                return uri_1.toSvnUri(resource.resourceUri, uri_1.SvnUriAction.SHOW, {
                    ref: against
                });
        }
    }
    getRightResource(resource, against = "") {
        switch (resource.type) {
            case svn_1.Status.ADDED:
            case svn_1.Status.CONFLICTED:
            case svn_1.Status.IGNORED:
            case svn_1.Status.MODIFIED:
            case svn_1.Status.UNVERSIONED:
            case svn_1.Status.REPLACED:
                return resource.resourceUri;
            case svn_1.Status.DELETED:
            case svn_1.Status.MISSING:
                return uri_1.toSvnUri(resource.resourceUri, uri_1.SvnUriAction.SHOW, {
                    ref: against
                });
        }
    }
    getTitle(resource, against) {
        if (resource.type === svn_1.Status.ADDED && resource.renameResourceUri) {
            const basename = path.basename(resource.renameResourceUri.fsPath);
            const newname = path.relative(path.dirname(resource.renameResourceUri.fsPath), resource.resourceUri.fsPath);
            if (against) {
                return `${basename} -> ${newname} (${against})`;
            }
            return `${basename} -> ${newname}`;
        }
        const basename = path.basename(resource.resourceUri.fsPath);
        if (against) {
            return `${basename} (${against})`;
        }
        return "";
    }
    switchBranch(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            const branch = yield branches_1.selectBranch(repository, true);
            if (!branch) {
                return;
            }
            try {
                if (branch.isNew) {
                    yield repository.branch(branch.path);
                }
                else {
                    yield repository.switchBranch(branch.path);
                }
            }
            catch (error) {
                console.log(error);
                if (branch.isNew) {
                    vscode_1.window.showErrorMessage("Unable to create new branch");
                }
                else {
                    vscode_1.window.showErrorMessage("Unable to switch branch");
                }
            }
        });
    }
    revert(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            const yes = "Yes I'm sure";
            const answer = yield vscode_1.window.showWarningMessage("Are you sure? This will wipe all local changes.", yes);
            if (answer !== yes) {
                return;
            }
            const uris = selection.map(resource => resource.resourceUri);
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const paths = resources.map(resource => resource.fsPath);
                try {
                    yield repository.revert(paths);
                }
                catch (error) {
                    console.log(error);
                    vscode_1.window.showErrorMessage("Unable to revert");
                }
            }));
        });
    }
    update(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const ignoreExternals = configuration_1.configuration.get("update.ignoreExternals", false);
                const showUpdateMessage = configuration_1.configuration.get("showUpdateMessage", true);
                const result = yield repository.updateRevision(ignoreExternals);
                if (showUpdateMessage) {
                    vscode_1.window.showInformationMessage(result);
                }
            }
            catch (error) {
                console.error(error);
                vscode_1.window.showErrorMessage("Unable to update");
            }
        });
    }
    showDiffPath(repository, content) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const tempFile = path.join(repository.root, ".svn", "tmp", "svn.patch");
                if (fs.existsSync(tempFile)) {
                    fs.unlinkSync(tempFile);
                }
                const uri = vscode_1.Uri.file(tempFile).with({
                    scheme: "untitled"
                });
                const document = yield vscode_1.workspace.openTextDocument(uri);
                const textEditor = yield vscode_1.window.showTextDocument(document);
                yield textEditor.edit(e => {
                    // if is opened, clear content
                    e.delete(new vscode_1.Range(new vscode_1.Position(0, 0), new vscode_1.Position(Number.MAX_SAFE_INTEGER, 0)));
                    e.insert(new vscode_1.Position(0, 0), content);
                });
            }
            catch (error) {
                console.error(error);
                vscode_1.window.showErrorMessage("Unable to patch");
            }
        });
    }
    patchAll(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            const content = yield repository.patch([]);
            yield this.showDiffPath(repository, content);
        });
    }
    patch(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            const uris = selection.map(resource => resource.resourceUri);
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const files = resources.map(resource => resource.fsPath);
                const content = yield repository.patch(files);
                yield this.showDiffPath(repository, content);
            }));
        });
    }
    patchChangeList(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            const changelistName = yield changelistItems_1.getPatchChangelist(repository);
            if (!changelistName) {
                return;
            }
            const content = yield repository.patchChangelist(changelistName);
            yield this.showDiffPath(repository, content);
        });
    }
    remove(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            let keepLocal;
            const answer = yield vscode_1.window.showWarningMessage("Would you like to keep a local copy of the files?.", "Yes", "No");
            if (!answer) {
                return;
            }
            if (answer === "Yes") {
                keepLocal = true;
            }
            else {
                keepLocal = false;
            }
            const uris = selection.map(resource => resource.resourceUri);
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const paths = resources.map(resource => resource.fsPath);
                try {
                    const result = yield repository.removeFiles(paths, keepLocal);
                }
                catch (error) {
                    console.log(error);
                    vscode_1.window.showErrorMessage("Unable to remove files");
                }
            }));
        });
    }
    resolveAll(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            const conflicts = repository.conflicts.resourceStates;
            if (!conflicts.length) {
                vscode_1.window.showInformationMessage("No Conflicts");
            }
            for (const conflict of conflicts) {
                const placeHolder = `Select conflict option for ${conflict.resourceUri.path}`;
                const picks = conflictItems_1.getConflictPickOptions();
                const choice = yield vscode_1.window.showQuickPick(picks, { placeHolder });
                if (!choice) {
                    return;
                }
                try {
                    const response = yield repository.resolve([conflict.resourceUri.path], choice.label);
                    vscode_1.window.showInformationMessage(response);
                }
                catch (error) {
                    vscode_1.window.showErrorMessage(error.stderr);
                }
            }
        });
    }
    resolve(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            const picks = conflictItems_1.getConflictPickOptions();
            const choice = yield vscode_1.window.showQuickPick(picks, {
                placeHolder: "Select conflict option"
            });
            if (!choice) {
                return;
            }
            const uris = selection.map(resource => resource.resourceUri);
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const files = resources.map(resource => resource.fsPath);
                yield repository.resolve(files, choice.label);
            }));
        });
    }
    resolved(uri) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!uri) {
                return;
            }
            const autoResolve = configuration_1.configuration.get("conflict.autoResolve");
            if (!autoResolve) {
                const basename = path.basename(uri.fsPath);
                const pick = yield vscode_1.window.showWarningMessage(`Mark the conflict as resolved for "${basename}"?`, "Yes", "No");
                if (pick !== "Yes") {
                    return;
                }
            }
            const uris = [uri];
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                const files = resources.map(resource => resource.fsPath);
                yield repository.resolve(files, "working");
            }));
        });
    }
    log(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const resource = uri_1.toSvnUri(vscode_1.Uri.file(repository.workspaceRoot), uri_1.SvnUriAction.LOG);
                const uri = resource.with({
                    path: path.join(resource.path, "svn.log") // change document title
                });
                yield vscode_1.commands.executeCommand("vscode.open", uri);
            }
            catch (error) {
                console.error(error);
                vscode_1.window.showErrorMessage("Unable to log");
            }
        });
    }
    _revertChanges(textEditor, changes) {
        return __awaiter(this, void 0, void 0, function* () {
            const modifiedDocument = textEditor.document;
            const modifiedUri = modifiedDocument.uri;
            if (modifiedUri.scheme !== "file") {
                return;
            }
            const originalUri = uri_1.toSvnUri(modifiedUri, uri_1.SvnUriAction.SHOW, {
                ref: "BASE"
            });
            const originalDocument = yield vscode_1.workspace.openTextDocument(originalUri);
            const basename = path.basename(modifiedUri.fsPath);
            const message = `Are you sure you want to revert the selected changes in ${basename}?`;
            const yes = "Revert Changes";
            const pick = yield vscode_1.window.showWarningMessage(message, { modal: true }, yes);
            if (pick !== yes) {
                return;
            }
            const result = lineChanges_1.applyLineChanges(originalDocument, modifiedDocument, changes);
            const edit = new vscode_1.WorkspaceEdit();
            edit.replace(modifiedUri, new vscode_1.Range(new vscode_1.Position(0, 0), modifiedDocument.lineAt(modifiedDocument.lineCount - 1).range.end), result);
            vscode_1.workspace.applyEdit(edit);
            yield modifiedDocument.save();
        });
    }
    revertChange(uri, changes, index) {
        return __awaiter(this, void 0, void 0, function* () {
            const textEditor = vscode_1.window.visibleTextEditors.filter(e => e.document.uri.toString() === uri.toString())[0];
            if (!textEditor) {
                return;
            }
            yield this._revertChanges(textEditor, [
                ...changes.slice(0, index),
                ...changes.slice(index + 1)
            ]);
        });
    }
    revertSelectedRanges(changes) {
        return __awaiter(this, void 0, void 0, function* () {
            const textEditor = vscode_1.window.activeTextEditor;
            if (!textEditor) {
                return;
            }
            const modifiedDocument = textEditor.document;
            const selections = textEditor.selections;
            const selectedChanges = changes.filter(change => {
                const modifiedRange = change.modifiedEndLineNumber === 0
                    ? new vscode_1.Range(modifiedDocument.lineAt(change.modifiedStartLineNumber - 1).range.end, modifiedDocument.lineAt(change.modifiedStartLineNumber).range.start)
                    : new vscode_1.Range(modifiedDocument.lineAt(change.modifiedStartLineNumber - 1).range.start, modifiedDocument.lineAt(change.modifiedEndLineNumber - 1).range.end);
                return selections.every(selection => !selection.intersection(modifiedRange));
            });
            if (selectedChanges.length === changes.length) {
                return;
            }
            yield this._revertChanges(textEditor, selectedChanges);
        });
    }
    close(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            this.model.close(repository);
        });
    }
    cleanup(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            yield repository.cleanup();
        });
    }
    finishCheckout(repository) {
        return __awaiter(this, void 0, void 0, function* () {
            yield repository.finishCheckout();
        });
    }
    addFileToIgnore(...resourceStates) {
        return __awaiter(this, void 0, void 0, function* () {
            const selection = this.getResourceStates(resourceStates);
            if (selection.length === 0) {
                return;
            }
            const uris = selection.map(resource => resource.resourceUri);
            return this.addToIgnore(uris);
        });
    }
    addToIgnoreExplorer(mainUri, allUris) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!allUris || allUris.length === 0) {
                return;
            }
            return this.addToIgnore(allUris);
        });
    }
    addToIgnore(uris) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.runByRepository(uris, (repository, resources) => __awaiter(this, void 0, void 0, function* () {
                if (!repository) {
                    return;
                }
                try {
                    yield ignoreitems_1.inputIgnoreList(repository, resources);
                    vscode_1.window.showInformationMessage(`File(s) is now being ignored`);
                }
                catch (error) {
                    console.log(error);
                    vscode_1.window.showErrorMessage("Unable to set property ignore");
                }
            }));
        });
    }
    renameExplorer(repository, mainUri, allUris) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!mainUri) {
                return;
            }
            const oldName = mainUri.fsPath;
            return this.rename(repository, oldName);
        });
    }
    rename(repository, oldFile, newName) {
        return __awaiter(this, void 0, void 0, function* () {
            oldFile = util_1.fixPathSeparator(oldFile);
            if (!newName) {
                const root = util_1.fixPathSeparator(repository.workspaceRoot);
                const oldName = path.relative(root, oldFile);
                newName = yield vscode_1.window.showInputBox({
                    value: path.basename(oldFile),
                    prompt: `New name name for ${oldName}`
                });
            }
            if (!newName) {
                return;
            }
            const basepath = path.dirname(oldFile);
            newName = path.join(basepath, newName);
            yield repository.rename(oldFile, newName);
        });
    }
    getSCMResource(uri) {
        uri = uri
            ? uri
            : vscode_1.window.activeTextEditor && vscode_1.window.activeTextEditor.document.uri;
        if (!uri) {
            return undefined;
        }
        if (uri.scheme === "svn") {
            const { fsPath } = uri_1.fromSvnUri(uri);
            uri = vscode_1.Uri.file(fsPath);
        }
        if (uri.scheme === "file") {
            const repository = this.model.getRepository(uri);
            if (!repository) {
                return undefined;
            }
            return repository.getResourceFromFile(uri);
        }
    }
    getResourceStates(resourceStates) {
        if (resourceStates.length === 0 ||
            !(resourceStates[0].resourceUri instanceof vscode_1.Uri)) {
            const resource = this.getSCMResource();
            if (!resource) {
                return [];
            }
            resourceStates = [resource];
        }
        return resourceStates.filter(s => s instanceof resource_1.Resource);
    }
    runByRepository(arg, fn) {
        return __awaiter(this, void 0, void 0, function* () {
            const resources = arg instanceof vscode_1.Uri ? [arg] : arg;
            const isSingleResource = arg instanceof vscode_1.Uri;
            const groups = resources.reduce((result, resource) => {
                const repository = this.model.getRepository(resource);
                if (!repository) {
                    console.warn("Could not find Svn repository for ", resource);
                    return result;
                }
                const tuple = result.filter(p => p.repository === repository)[0];
                if (tuple) {
                    tuple.resources.push(resource);
                }
                else {
                    result.push({ repository, resources: [resource] });
                }
                return result;
            }, []);
            const promises = groups.map(({ repository, resources }) => fn(repository, isSingleResource ? resources[0] : resources));
            return Promise.all(promises);
        });
    }
    dispose() {
        this.disposables.forEach(d => d.dispose());
    }
}
__decorate([
    command("svn._getModel")
], SvnCommands.prototype, "getModel", null);
__decorate([
    command("svn.fileOpen")
], SvnCommands.prototype, "fileOpen", null);
__decorate([
    command("svn.promptAuth", { repository: true })
], SvnCommands.prototype, "promptAuth", null);
__decorate([
    command("svn.commitWithMessage", { repository: true })
], SvnCommands.prototype, "commitWithMessage", null);
__decorate([
    command("svn.add")
], SvnCommands.prototype, "addFile", null);
__decorate([
    command("svn.changelist")
], SvnCommands.prototype, "changelist", null);
__decorate([
    command("svn.commit")
], SvnCommands.prototype, "commit", null);
__decorate([
    command("svn.refresh", { repository: true })
], SvnCommands.prototype, "refresh", null);
__decorate([
    command("svn.openResourceBase")
], SvnCommands.prototype, "openResourceBase", null);
__decorate([
    command("svn.openResourceHead")
], SvnCommands.prototype, "openResourceHead", null);
__decorate([
    command("svn.openFile")
], SvnCommands.prototype, "openFile", null);
__decorate([
    command("svn.openHEADFile")
], SvnCommands.prototype, "openHEADFile", null);
__decorate([
    command("svn.openChangeBase")
], SvnCommands.prototype, "openChangeBase", null);
__decorate([
    command("svn.openChangeHead")
], SvnCommands.prototype, "openChangeHead", null);
__decorate([
    command("svn.switchBranch", { repository: true })
], SvnCommands.prototype, "switchBranch", null);
__decorate([
    command("svn.revert")
], SvnCommands.prototype, "revert", null);
__decorate([
    command("svn.update", { repository: true })
], SvnCommands.prototype, "update", null);
__decorate([
    command("svn.patchAll", { repository: true })
], SvnCommands.prototype, "patchAll", null);
__decorate([
    command("svn.patch")
], SvnCommands.prototype, "patch", null);
__decorate([
    command("svn.patchChangeList", { repository: true })
], SvnCommands.prototype, "patchChangeList", null);
__decorate([
    command("svn.remove")
], SvnCommands.prototype, "remove", null);
__decorate([
    command("svn.resolveAll", { repository: true })
], SvnCommands.prototype, "resolveAll", null);
__decorate([
    command("svn.resolve")
], SvnCommands.prototype, "resolve", null);
__decorate([
    command("svn.resolved")
], SvnCommands.prototype, "resolved", null);
__decorate([
    command("svn.log", { repository: true })
], SvnCommands.prototype, "log", null);
__decorate([
    command("svn.revertChange")
], SvnCommands.prototype, "revertChange", null);
__decorate([
    command("svn.revertSelectedRanges", { diff: true })
], SvnCommands.prototype, "revertSelectedRanges", null);
__decorate([
    command("svn.close", { repository: true })
], SvnCommands.prototype, "close", null);
__decorate([
    command("svn.cleanup", { repository: true })
], SvnCommands.prototype, "cleanup", null);
__decorate([
    command("svn.finishCheckout", { repository: true })
], SvnCommands.prototype, "finishCheckout", null);
__decorate([
    command("svn.addToIgnoreSCM")
], SvnCommands.prototype, "addFileToIgnore", null);
__decorate([
    command("svn.addToIgnoreExplorer")
], SvnCommands.prototype, "addToIgnoreExplorer", null);
__decorate([
    command("svn.renameExplorer", { repository: true })
], SvnCommands.prototype, "renameExplorer", null);
__decorate([
    command("svn.rename", { repository: true })
], SvnCommands.prototype, "rename", null);
exports.SvnCommands = SvnCommands;
//# sourceMappingURL=commands.js.map