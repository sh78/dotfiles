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
const svn_1 = require("./svn");
const statusParser_1 = require("./statusParser");
const infoParser_1 = require("./infoParser");
const decorators_1 = require("./decorators");
const path = require("path");
const fs = require("fs");
const util_1 = require("./util");
const configuration_1 = require("./helpers/configuration");
const listParser_1 = require("./listParser");
const branches_1 = require("./branches");
class Repository {
    constructor(svn, root, workspaceRoot) {
        this.svn = svn;
        this.root = root;
        this.workspaceRoot = workspaceRoot;
        this._info = {};
    }
    exec(args, options = {}) {
        return __awaiter(this, void 0, void 0, function* () {
            options.username = this.username;
            options.password = this.password;
            return this.svn.exec(this.workspaceRoot, args, options);
        });
    }
    removeAbsolutePath(file) {
        file = util_1.fixPathSeparator(file);
        file = path.relative(this.workspaceRoot, file);
        // Fix Peg Revision Algorithm (http://svnbook.red-bean.com/en/1.8/svn.advanced.pegrevs.html)
        if (/@/.test(file)) {
            file += "@";
        }
        return file;
    }
    getStatus(includeIgnored = false, includeExternals = true) {
        return __awaiter(this, void 0, void 0, function* () {
            let args = ["stat", "--xml"];
            if (includeIgnored) {
                args.push("--no-ignore");
            }
            if (!includeExternals) {
                args.push("--ignore-externals");
            }
            const result = yield this.exec(args);
            const status = yield statusParser_1.parseStatusXml(result.stdout);
            for (const s of status) {
                if (s.status === svn_1.Status.EXTERNAL) {
                    try {
                        const info = yield this.getInfo(s.path);
                        s.repositoryUuid = info.repository.uuid;
                    }
                    catch (error) { }
                }
            }
            return status;
        });
    }
    resetInfo(file = "") {
        delete this._info[file];
    }
    getInfo(file = "") {
        return __awaiter(this, void 0, void 0, function* () {
            if (this._info[file]) {
                return this._info[file];
            }
            const args = ["info", "--xml"];
            if (file) {
                file = util_1.fixPathSeparator(file);
                args.push(file);
            }
            const result = yield this.exec(args);
            this._info[file] = yield infoParser_1.parseInfoXml(result.stdout);
            // Cache for 2 minutes
            setTimeout(() => {
                this.resetInfo(file);
            }, 2 * 60 * 1000);
            return this._info[file];
        });
    }
    show(file, revision, options = {}) {
        return __awaiter(this, void 0, void 0, function* () {
            file = this.removeAbsolutePath(file);
            const args = ["cat", file];
            if (revision) {
                args.push("-r", revision);
            }
            const result = yield this.exec(args);
            return result.stdout;
        });
    }
    commitFiles(message, files) {
        return __awaiter(this, void 0, void 0, function* () {
            files = files.map(file => this.removeAbsolutePath(file));
            const args = ["commit", ...files];
            if (fs.existsSync(path.join(this.workspaceRoot, message))) {
                args.push("--force-log");
            }
            args.push("-m", message);
            const result = yield this.exec(args);
            const matches = result.stdout.match(/Committed revision (.*)\./i);
            if (matches && matches[0]) {
                return matches[0];
            }
            return result.stdout;
        });
    }
    addFiles(files) {
        files = files.map(file => this.removeAbsolutePath(file));
        return this.exec(["add", ...files]);
    }
    addChangelist(files, changelist) {
        files = files.map(file => this.removeAbsolutePath(file));
        return this.exec(["changelist", changelist, ...files]);
    }
    removeChangelist(files) {
        files = files.map(file => this.removeAbsolutePath(file));
        return this.exec(["changelist", "--remove", ...files]);
    }
    getCurrentBranch() {
        return __awaiter(this, void 0, void 0, function* () {
            const info = yield this.getInfo();
            const branch = branches_1.getBranchName(info.url);
            if (branch) {
                const showFullName = configuration_1.configuration.get("layout.showFullName");
                if (showFullName) {
                    return branch.path;
                }
                else {
                    return branch.name;
                }
            }
            return "";
        });
    }
    getRepositoryUuid() {
        return __awaiter(this, void 0, void 0, function* () {
            const info = yield this.getInfo();
            return info.repository.uuid;
        });
    }
    getRepoUrl() {
        return __awaiter(this, void 0, void 0, function* () {
            const info = yield this.getInfo();
            const branch = branches_1.getBranchName(info.url);
            if (!branch) {
                return info.repository.root;
            }
            let regex = new RegExp(branch.path + "$");
            return info.url.replace(regex, "").replace(/\/$/, "");
        });
    }
    getBranches() {
        return __awaiter(this, void 0, void 0, function* () {
            const trunkLayout = configuration_1.configuration.get("layout.trunk");
            const branchesLayout = configuration_1.configuration.get("layout.branches");
            const tagsLayout = configuration_1.configuration.get("layout.tags");
            const repoUrl = yield this.getRepoUrl();
            let branches = [];
            let promises = [];
            if (trunkLayout) {
                promises.push(new Promise((resolve) => __awaiter(this, void 0, void 0, function* () {
                    try {
                        let trunkExists = yield this.exec([
                            "ls",
                            repoUrl + "/" + trunkLayout,
                            "--depth",
                            "empty"
                        ]);
                        resolve([trunkLayout]);
                    }
                    catch (error) {
                        resolve([]);
                    }
                })));
            }
            let trees = [];
            if (branchesLayout) {
                trees.push(branchesLayout);
            }
            if (tagsLayout) {
                trees.push(tagsLayout);
            }
            for (const tree of trees) {
                promises.push(new Promise((resolve) => __awaiter(this, void 0, void 0, function* () {
                    const branchUrl = repoUrl + "/" + tree;
                    try {
                        const result = yield this.exec(["ls", branchUrl]);
                        const list = result.stdout
                            .trim()
                            .replace(/\/|\\/g, "")
                            .split(/[\r\n]+/)
                            .filter((x) => !!x)
                            .map((i) => tree + "/" + i);
                        resolve(list);
                    }
                    catch (error) {
                        resolve([]);
                    }
                })));
            }
            const all = yield Promise.all(promises);
            all.forEach(list => {
                branches.push(...list);
            });
            return branches;
        });
    }
    branch(name) {
        return __awaiter(this, void 0, void 0, function* () {
            const repoUrl = yield this.getRepoUrl();
            const newBranch = repoUrl + "/" + name;
            const info = yield this.getInfo();
            const currentBranch = info.url;
            const result = yield this.exec([
                "copy",
                currentBranch,
                newBranch,
                "-m",
                `Created new branch ${name}`
            ]);
            yield this.switchBranch(name);
            return true;
        });
    }
    switchBranch(ref) {
        return __awaiter(this, void 0, void 0, function* () {
            const repoUrl = yield this.getRepoUrl();
            const branchUrl = repoUrl + "/" + ref;
            try {
                yield this.exec(["switch", branchUrl]);
            }
            catch (error) {
                yield this.exec(["switch", branchUrl, "--ignore-ancestry"]);
            }
            this.resetInfo();
            return true;
        });
    }
    revert(files) {
        return __awaiter(this, void 0, void 0, function* () {
            files = files.map(file => this.removeAbsolutePath(file));
            const result = yield this.exec(["revert", ...files]);
            return result.stdout;
        });
    }
    update(ignoreExternals = true) {
        return __awaiter(this, void 0, void 0, function* () {
            const args = ["update"];
            if (ignoreExternals) {
                args.push("--ignore-externals");
            }
            const result = yield this.exec(args);
            this.resetInfo();
            const message = result.stdout
                .trim()
                .split(/\r?\n/)
                .pop();
            if (message) {
                return message;
            }
            return result.stdout;
        });
    }
    patch(files) {
        return __awaiter(this, void 0, void 0, function* () {
            files = files.map(file => this.removeAbsolutePath(file));
            const result = yield this.exec(["diff", ...files]);
            const message = result.stdout;
            return message;
        });
    }
    patchChangelist(changelistName) {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield this.exec(["diff", "--changelist", changelistName]);
            const message = result.stdout;
            return message;
        });
    }
    removeFiles(files, keepLocal) {
        return __awaiter(this, void 0, void 0, function* () {
            files = files.map(file => this.removeAbsolutePath(file));
            const args = ["remove"];
            if (keepLocal) {
                args.push("--keep-local");
            }
            args.push(...files);
            const result = yield this.exec(args);
            return result.stdout;
        });
    }
    resolve(files, action) {
        return __awaiter(this, void 0, void 0, function* () {
            files = files.map(file => this.removeAbsolutePath(file));
            const result = yield this.exec(["resolve", "--accept", action, ...files]);
            return result.stdout;
        });
    }
    log() {
        return __awaiter(this, void 0, void 0, function* () {
            const logLength = configuration_1.configuration.get("log.length") || "50";
            const result = yield this.exec([
                "log",
                "-r",
                "HEAD:1",
                "--limit",
                logLength
            ]);
            return result.stdout;
        });
    }
    countNewCommit(revision = "BASE:HEAD") {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield this.exec(["log", "-r", revision, "-q", "--xml"]);
            const matches = result.stdout.match(/<logentry/g);
            if (matches && matches.length > 0) {
                // Every return current commit
                return matches.length - 1;
            }
            return 0;
        });
    }
    cleanup() {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield this.exec(["cleanup"]);
            return result.stdout;
        });
    }
    finishCheckout() {
        return __awaiter(this, void 0, void 0, function* () {
            const info = yield this.getInfo();
            const result = yield this.exec(["switch", info.url]);
            return result.stdout;
        });
    }
    list(folder) {
        return __awaiter(this, void 0, void 0, function* () {
            let url = yield this.getRepoUrl();
            if (folder) {
                url += "/" + folder;
            }
            const result = yield this.exec(["list", url, "--xml"]);
            return listParser_1.parseSvnList(result.stdout);
        });
    }
    getCurrentIgnore(directory) {
        return __awaiter(this, void 0, void 0, function* () {
            directory = this.removeAbsolutePath(directory);
            let currentIgnore = "";
            try {
                const args = ["propget", "svn:ignore"];
                if (directory) {
                    args.push(directory);
                }
                const currentIgnoreResult = yield this.exec(args);
                currentIgnore = currentIgnoreResult.stdout.trim();
            }
            catch (error) { }
            const ignores = currentIgnore.split(/[\r\n]+/);
            return ignores;
        });
    }
    addToIgnore(expressions, directory, recursive = false) {
        return __awaiter(this, void 0, void 0, function* () {
            const ignores = yield this.getCurrentIgnore(directory);
            directory = this.removeAbsolutePath(directory);
            ignores.push(...expressions);
            const newIgnore = [...new Set(ignores)]
                .filter(v => !!v)
                .sort()
                .join("\n");
            const args = ["propset", "svn:ignore", newIgnore];
            if (directory) {
                args.push(directory);
            }
            else {
                args.push(".");
            }
            if (recursive) {
                args.push("--recursive");
            }
            const result = yield this.exec(args);
            return result.stdout;
        });
    }
    rename(oldName, newName) {
        return __awaiter(this, void 0, void 0, function* () {
            oldName = this.removeAbsolutePath(oldName);
            newName = this.removeAbsolutePath(newName);
            const args = ["rename", oldName, newName];
            const result = yield this.exec(args);
            return result.stdout;
        });
    }
}
__decorate([
    decorators_1.sequentialize
], Repository.prototype, "getInfo", null);
exports.Repository = Repository;
//# sourceMappingURL=svnRepository.js.map