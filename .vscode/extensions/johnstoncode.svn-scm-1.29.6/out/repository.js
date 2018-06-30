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
const resource_1 = require("./resource");
const decorators_1 = require("./decorators");
const statusBar_1 = require("./statusBar");
const util_1 = require("./util");
const path = require("path");
const timers_1 = require("timers");
const uri_1 = require("./uri");
const svn_1 = require("./svn");
const configuration_1 = require("./helpers/configuration");
const minimatch_1 = require("minimatch");
var RepositoryState;
(function (RepositoryState) {
    RepositoryState[RepositoryState["Idle"] = 0] = "Idle";
    RepositoryState[RepositoryState["Disposed"] = 1] = "Disposed";
})(RepositoryState = exports.RepositoryState || (exports.RepositoryState = {}));
var Operation;
(function (Operation) {
    Operation["Add"] = "Add";
    Operation["AddChangelist"] = "AddChangelist";
    Operation["CleanUp"] = "CleanUp";
    Operation["Commit"] = "Commit";
    Operation["CurrentBranch"] = "CurrentBranch";
    Operation["Ignore"] = "Ignore";
    Operation["Log"] = "Log";
    Operation["NewBranch"] = "NewBranch";
    Operation["NewCommits"] = "NewCommits";
    Operation["Patch"] = "Patch";
    Operation["Remove"] = "Remove";
    Operation["RemoveChangelist"] = "RemoveChangelist";
    Operation["Rename"] = "Rename";
    Operation["Resolve"] = "Resolve";
    Operation["Resolved"] = "Resolved";
    Operation["Revert"] = "Revert";
    Operation["Show"] = "Show";
    Operation["Status"] = "Status";
    Operation["SwitchBranch"] = "SwitchBranch";
    Operation["Update"] = "Update";
})(Operation = exports.Operation || (exports.Operation = {}));
function isReadOnly(operation) {
    switch (operation) {
        case Operation.CurrentBranch:
        case Operation.Log:
        case Operation.NewCommits:
        case Operation.Show:
            return true;
        default:
            return false;
    }
}
function shouldShowProgress(operation) {
    switch (operation) {
        case Operation.CurrentBranch:
        case Operation.NewCommits:
        case Operation.Show:
            return false;
        default:
            return true;
    }
}
class OperationsImpl {
    constructor() {
        this.operations = new Map();
    }
    start(operation) {
        this.operations.set(operation, (this.operations.get(operation) || 0) + 1);
    }
    end(operation) {
        const count = (this.operations.get(operation) || 0) - 1;
        if (count <= 0) {
            this.operations.delete(operation);
        }
        else {
            this.operations.set(operation, count);
        }
    }
    isRunning(operation) {
        return this.operations.has(operation);
    }
    isIdle() {
        const operations = this.operations.keys();
        for (const operation of operations) {
            if (!isReadOnly(operation)) {
                return false;
            }
        }
        return true;
    }
}
class Repository {
    constructor(repository) {
        this.repository = repository;
        this.changelists = new Map();
        this.statusIgnored = [];
        this.statusExternal = [];
        this.disposables = [];
        this.currentBranch = "";
        this.newCommit = 0;
        this.isIncomplete = false;
        this.needCleanUp = false;
        this._onDidChangeRepository = new vscode_1.EventEmitter();
        this.onDidChangeRepository = this._onDidChangeRepository
            .event;
        this._onDidChangeState = new vscode_1.EventEmitter();
        this.onDidChangeState = this._onDidChangeState
            .event;
        this._onDidChangeStatus = new vscode_1.EventEmitter();
        this.onDidChangeStatus = this._onDidChangeStatus.event;
        this._onDidChangeNewCommit = new vscode_1.EventEmitter();
        this.onDidChangeNewCommit = this._onDidChangeNewCommit.event;
        this._onRunOperation = new vscode_1.EventEmitter();
        this.onRunOperation = this._onRunOperation.event;
        this._onDidRunOperation = new vscode_1.EventEmitter();
        this.onDidRunOperation = this._onDidRunOperation.event;
        this._operations = new OperationsImpl();
        this._state = RepositoryState.Idle;
        const fsWatcher = vscode_1.workspace.createFileSystemWatcher("**");
        this.disposables.push(fsWatcher);
        const onWorkspaceChange = util_1.anyEvent(fsWatcher.onDidChange, fsWatcher.onDidCreate, fsWatcher.onDidDelete);
        const onRepositoryChange = util_1.filterEvent(onWorkspaceChange, uri => !/^\.\./.test(path.relative(repository.root, uri.fsPath)));
        const onRelevantRepositoryChange = util_1.filterEvent(onRepositoryChange, uri => !/[\\\/]\.svn[\\\/]tmp/.test(uri.path));
        onRelevantRepositoryChange(this.onFSChange, this, this.disposables);
        const onRelevantSvnChange = util_1.filterEvent(onRelevantRepositoryChange, uri => /[\\\/]\.svn[\\\/]/.test(uri.path));
        onRelevantSvnChange(this._onDidChangeRepository.fire, this._onDidChangeRepository, this.disposables);
        this.sourceControl = vscode_1.scm.createSourceControl("svn", "SVN", vscode_1.Uri.file(repository.workspaceRoot));
        this.sourceControl.count = 0;
        this.sourceControl.inputBox.placeholder =
            "Message (press Ctrl+Enter to commit)";
        this.sourceControl.acceptInputCommand = {
            command: "svn.commitWithMessage",
            title: "commit",
            arguments: [this.sourceControl]
        };
        this.sourceControl.quickDiffProvider = this;
        this.disposables.push(this.sourceControl);
        this.statusBar = new statusBar_1.SvnStatusBar(this);
        this.disposables.push(this.statusBar);
        this.statusBar.onDidChange(() => (this.sourceControl.statusBarCommands = this.statusBar.commands), null, this.disposables);
        this.changes = this.sourceControl.createResourceGroup("changes", "Changes");
        this.conflicts = this.sourceControl.createResourceGroup("conflicts", "conflicts");
        this.unversioned = this.sourceControl.createResourceGroup("unversioned", "Unversioned");
        this.changes.hideWhenEmpty = true;
        this.unversioned.hideWhenEmpty = true;
        this.conflicts.hideWhenEmpty = true;
        this.disposables.push(this.changes);
        this.disposables.push(this.unversioned);
        this.disposables.push(this.conflicts);
        const updateFreqNew = configuration_1.configuration.get("newCommits.checkFrequency");
        if (updateFreqNew) {
            const interval = timers_1.setInterval(() => {
                this.updateNewCommits();
            }, 1000 * 60 * updateFreqNew);
            this.disposables.push(util_1.toDisposable(() => {
                timers_1.clearInterval(interval);
            }));
        }
        this.status();
        this.updateNewCommits();
        this.disposables.push(vscode_1.workspace.onDidSaveTextDocument(document => {
            this.onDidSaveTextDocument(document);
        }));
    }
    get onDidChangeOperations() {
        return util_1.anyEvent(this.onRunOperation, this.onDidRunOperation);
    }
    get operations() {
        return this._operations;
    }
    get state() {
        return this._state;
    }
    set state(state) {
        this._state = state;
        this._onDidChangeState.fire(state);
        this.changes.resourceStates = [];
        this.unversioned.resourceStates = [];
        this.conflicts.resourceStates = [];
        this.changelists.forEach((group, changelist) => {
            group.resourceStates = [];
        });
        this.isIncomplete = false;
        this.needCleanUp = false;
    }
    get root() {
        return this.repository.root;
    }
    get workspaceRoot() {
        return this.repository.workspaceRoot;
    }
    get inputBox() {
        return this.sourceControl.inputBox;
    }
    get username() {
        return this.repository.username;
    }
    set username(username) {
        this.repository.username = username;
    }
    get password() {
        return this.repository.password;
    }
    set password(password) {
        this.repository.password = password;
    }
    updateNewCommits() {
        return __awaiter(this, void 0, void 0, function* () {
            this.run(Operation.NewCommits, () => __awaiter(this, void 0, void 0, function* () {
                const newCommits = yield this.repository.countNewCommit();
                if (newCommits !== this.newCommit) {
                    this.newCommit = newCommits;
                    this._onDidChangeNewCommit.fire();
                }
            }));
        });
    }
    onFSChange(uri) {
        const autorefresh = configuration_1.configuration.get("autorefresh");
        if (!autorefresh) {
            return;
        }
        if (!this.operations.isIdle()) {
            return;
        }
        this.eventuallyUpdateWhenIdleAndWait();
    }
    eventuallyUpdateWhenIdleAndWait() {
        this.updateWhenIdleAndWait();
    }
    updateWhenIdleAndWait() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.whenIdleAndFocused();
            yield this.status();
            yield util_1.timeout(5000);
        });
    }
    whenIdleAndFocused() {
        return __awaiter(this, void 0, void 0, function* () {
            while (true) {
                if (!this.operations.isIdle()) {
                    yield util_1.eventToPromise(this.onDidRunOperation);
                    continue;
                }
                if (!vscode_1.window.state.focused) {
                    const onDidFocusWindow = util_1.filterEvent(vscode_1.window.onDidChangeWindowState, e => e.focused);
                    yield util_1.eventToPromise(onDidFocusWindow);
                    continue;
                }
                return;
            }
        });
    }
    updateModelState() {
        return __awaiter(this, void 0, void 0, function* () {
            let changes = [];
            let unversioned = [];
            let external = [];
            let conflicts = [];
            let changelists = new Map();
            this.statusExternal = [];
            this.statusIgnored = [];
            this.isIncomplete = false;
            this.needCleanUp = false;
            const combineExternal = configuration_1.configuration.get("sourceControl.combineExternalIfSameServer", false);
            const statuses = (yield this.repository.getStatus(true, combineExternal)) || [];
            const fileConfig = vscode_1.workspace.getConfiguration("files", vscode_1.Uri.file(this.root));
            const filesToExclude = fileConfig.get("exclude");
            let excludeList = [];
            for (const pattern in filesToExclude) {
                const negate = !filesToExclude[pattern];
                excludeList.push((negate ? "!" : "") + pattern);
            }
            this.statusExternal = statuses.filter(status => status.status === svn_1.Status.EXTERNAL);
            if (combineExternal && this.statusExternal.length) {
                const repositoryUuid = yield this.repository.getRepositoryUuid();
                this.statusExternal = this.statusExternal.filter(status => repositoryUuid !== status.repositoryUuid);
            }
            const statusesRepository = statuses.filter(status => {
                if (status.status === svn_1.Status.EXTERNAL) {
                    return false;
                }
                return !this.statusExternal.some(external => util_1.isDescendant(external.path, status.path));
            });
            for (const status of statusesRepository) {
                if (status.path === ".") {
                    this.isIncomplete = status.status === svn_1.Status.INCOMPLETE;
                    this.needCleanUp = status.wcStatus.locked;
                    continue;
                }
                // If exists a switched item, the repository is incomplete
                // To simulate, run "svn switch" and kill "svn" proccess
                // After, run "svn update"
                if (status.wcStatus.switched) {
                    this.isIncomplete = true;
                }
                if (status.wcStatus.locked ||
                    status.wcStatus.switched ||
                    status.status === svn_1.Status.INCOMPLETE) {
                    // On commit, `svn status` return all locked files with status="normal" and props="none"
                    continue;
                }
                const mm = new minimatch_1.Minimatch("*");
                if (mm.matchOne([status.path], excludeList, false)) {
                    continue;
                }
                const uri = vscode_1.Uri.file(path.join(this.workspaceRoot, status.path));
                const renameUri = status.rename
                    ? vscode_1.Uri.file(path.join(this.workspaceRoot, status.rename))
                    : undefined;
                const resource = new resource_1.Resource(uri, status.status, renameUri, status.props);
                if (status.status === svn_1.Status.IGNORED) {
                    this.statusIgnored.push(status);
                }
                else if (status.status === svn_1.Status.CONFLICTED) {
                    conflicts.push(resource);
                }
                else if (status.status === svn_1.Status.UNVERSIONED) {
                    const matches = status.path.match(/(.+?)\.(mine|working|merge-\w+\.r\d+|r\d+)$/);
                    // If file end with (mine, working, merge, etc..) and has file without extension
                    if (matches &&
                        matches[1] &&
                        statuses.some(s => s.path === matches[1])) {
                        continue;
                    }
                    else {
                        unversioned.push(resource);
                    }
                }
                else {
                    if (!status.changelist) {
                        changes.push(resource);
                    }
                    else {
                        let changelist = changelists.get(status.changelist);
                        if (!changelist) {
                            changelist = [];
                        }
                        changelist.push(resource);
                        changelists.set(status.changelist, changelist);
                    }
                }
            }
            this.changes.resourceStates = changes;
            this.unversioned.resourceStates = unversioned;
            this.conflicts.resourceStates = conflicts;
            this.changelists.forEach((group, changelist) => {
                group.resourceStates = [];
            });
            const counts = [this.changes, this.conflicts];
            const countIgnoreOnCommit = configuration_1.configuration.get("sourceControl.countIgnoreOnCommit", false);
            const ignoreOnCommitList = configuration_1.configuration.get("sourceControl.ignoreOnCommit");
            changelists.forEach((resources, changelist) => {
                let group = this.changelists.get(changelist);
                if (!group) {
                    // Prefix 'changelist-' to prevent double id with 'change' or 'external'
                    group = this.sourceControl.createResourceGroup(`changelist-${changelist}`, `Changelist "${changelist}"`);
                    group.hideWhenEmpty = true;
                    this.disposables.push(group);
                    this.changelists.set(changelist, group);
                }
                group.resourceStates = resources;
                if (countIgnoreOnCommit && ignoreOnCommitList.includes(changelist)) {
                    counts.push(group);
                }
            });
            if (configuration_1.configuration.get("sourceControl.countUnversioned", false)) {
                counts.push(this.unversioned);
            }
            this.sourceControl.count = counts.reduce((a, b) => a + b.resourceStates.length, 0);
            this._onDidChangeStatus.fire();
            this.currentBranch = yield this.getCurrentBranch();
            return Promise.resolve();
        });
    }
    getResourceFromFile(uri) {
        if (typeof uri === "string") {
            uri = vscode_1.Uri.file(uri);
        }
        const groups = [
            this.changes,
            this.conflicts,
            this.unversioned,
            ...this.changelists.values()
        ];
        const uriString = uri.toString();
        for (const group of groups) {
            for (const resource of group.resourceStates) {
                if (uriString === resource.resourceUri.toString() &&
                    resource instanceof resource_1.Resource) {
                    return resource;
                }
            }
        }
        return undefined;
    }
    provideOriginalResource(uri) {
        if (uri.scheme !== "file") {
            return;
        }
        // Not has original resource for content of ".svn" folder
        if (util_1.isDescendant(path.join(this.root, ".svn"), uri.fsPath)) {
            return;
        }
        return uri_1.toSvnUri(uri, uri_1.SvnUriAction.SHOW, {}, true);
    }
    getBranches() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield this.repository.getBranches();
            }
            catch (error) {
                return [];
            }
        });
    }
    status() {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Status);
        });
    }
    show(filePath, revision) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Show, () => {
                return this.repository.show(filePath, revision);
            });
        });
    }
    addFiles(files) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Add, () => this.repository.addFiles(files));
        });
    }
    addChangelist(files, changelist) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.AddChangelist, () => this.repository.addChangelist(files, changelist));
        });
    }
    removeChangelist(files) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.RemoveChangelist, () => this.repository.removeChangelist(files));
        });
    }
    getCurrentBranch() {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.CurrentBranch, () => __awaiter(this, void 0, void 0, function* () {
                return this.repository.getCurrentBranch();
            }));
        });
    }
    branch(name) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.NewBranch, () => __awaiter(this, void 0, void 0, function* () {
                yield this.repository.branch(name);
                this.updateNewCommits();
            }));
        });
    }
    switchBranch(name) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.run(Operation.SwitchBranch, () => __awaiter(this, void 0, void 0, function* () {
                yield this.repository.switchBranch(name);
                this.updateNewCommits();
            }));
        });
    }
    updateRevision(ignoreExternals = false) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Update, () => __awaiter(this, void 0, void 0, function* () {
                const response = yield this.repository.update(ignoreExternals);
                this.updateNewCommits();
                return response;
            }));
        });
    }
    resolve(files, action) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Resolve, () => this.repository.resolve(files, action));
        });
    }
    commitFiles(message, files) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Commit, () => this.repository.commitFiles(message, files));
        });
    }
    revert(files) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Revert, () => this.repository.revert(files));
        });
    }
    patch(files) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Patch, () => this.repository.patch(files));
        });
    }
    patchChangelist(changelistName) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Patch, () => this.repository.patchChangelist(changelistName));
        });
    }
    removeFiles(files, keepLocal) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Remove, () => this.repository.removeFiles(files, keepLocal));
        });
    }
    log() {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Log, () => this.repository.log());
        });
    }
    cleanup() {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.CleanUp, () => this.repository.cleanup());
        });
    }
    finishCheckout() {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.SwitchBranch, () => this.repository.finishCheckout());
        });
    }
    addToIgnore(expressions, directory, recursive = false) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Ignore, () => this.repository.addToIgnore(expressions, directory, recursive));
        });
    }
    rename(oldFile, newFile) {
        return __awaiter(this, void 0, void 0, function* () {
            return this.run(Operation.Rename, () => this.repository.rename(oldFile, newFile));
        });
    }
    promptAuth() {
        return __awaiter(this, void 0, void 0, function* () {
            // Prevent multiple prompts for auth
            if (this.lastPromptAuth) {
                return this.lastPromptAuth;
            }
            this.lastPromptAuth = vscode_1.commands.executeCommand("svn.promptAuth");
            const result = yield this.lastPromptAuth;
            this.lastPromptAuth = undefined;
            return result;
        });
    }
    onDidSaveTextDocument(document) {
        const uriString = document.uri.toString();
        const conflict = this.conflicts.resourceStates.find(resource => resource.resourceUri.toString() === uriString);
        if (!conflict) {
            return;
        }
        const text = document.getText();
        // Check for lines begin with "<<<<<<", "=======", ">>>>>>>"
        if (!/^<{7}[^]+^={7}[^]+^>{7}/m.test(text)) {
            vscode_1.commands.executeCommand("svn.resolved", conflict.resourceUri);
        }
    }
    run(operation, runOperation = () => Promise.resolve(null)) {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.state !== RepositoryState.Idle) {
                throw new Error("Repository not initialized");
            }
            const run = () => __awaiter(this, void 0, void 0, function* () {
                this._operations.start(operation);
                this._onRunOperation.fire(operation);
                try {
                    const result = yield this.retryRun(runOperation);
                    if (!isReadOnly(operation)) {
                        yield this.updateModelState();
                    }
                    return result;
                }
                catch (err) {
                    if (err.svnErrorCode === svn_1.SvnErrorCodes.NotASvnRepository) {
                        this.state = RepositoryState.Disposed;
                    }
                    throw err;
                }
                finally {
                    this._operations.end(operation);
                    this._onDidRunOperation.fire(operation);
                }
            });
            return shouldShowProgress(operation)
                ? vscode_1.window.withProgress({ location: vscode_1.ProgressLocation.SourceControl }, run)
                : run();
        });
    }
    retryRun(runOperation = () => Promise.resolve(null)) {
        return __awaiter(this, void 0, void 0, function* () {
            let attempt = 0;
            while (true) {
                try {
                    attempt++;
                    return yield runOperation();
                }
                catch (err) {
                    if (err.svnErrorCode === svn_1.SvnErrorCodes.RepositoryIsLocked &&
                        attempt <= 10) {
                        // quatratic backoff
                        yield util_1.timeout(Math.pow(attempt, 2) * 50);
                    }
                    else if (err.svnErrorCode === svn_1.SvnErrorCodes.AuthorizationFailed &&
                        attempt <= 3) {
                        const result = yield this.promptAuth();
                        if (!result) {
                            throw err;
                        }
                    }
                    else {
                        throw err;
                    }
                }
            }
        });
    }
    dispose() {
        this.disposables = util_1.dispose(this.disposables);
    }
}
__decorate([
    decorators_1.memoize
], Repository.prototype, "onDidChangeOperations", null);
__decorate([
    decorators_1.debounce(1000)
], Repository.prototype, "updateNewCommits", null);
__decorate([
    decorators_1.debounce(1000)
], Repository.prototype, "eventuallyUpdateWhenIdleAndWait", null);
__decorate([
    decorators_1.throttle
], Repository.prototype, "updateWhenIdleAndWait", null);
__decorate([
    decorators_1.throttle
], Repository.prototype, "updateModelState", null);
__decorate([
    decorators_1.throttle
], Repository.prototype, "status", null);
exports.Repository = Repository;
//# sourceMappingURL=repository.js.map