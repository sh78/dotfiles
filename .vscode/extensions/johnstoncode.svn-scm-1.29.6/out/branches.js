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
const listParser_1 = require("./listParser");
const vscode_1 = require("vscode");
const configuration_1 = require("./helpers/configuration");
const decorators_1 = require("./decorators");
function getBranchName(folder) {
    const confs = [
        "layout.trunkRegex",
        "layout.branchesRegex",
        "layout.tagsRegex"
    ];
    for (const conf of confs) {
        const layout = configuration_1.configuration.get(conf);
        if (!layout) {
            continue;
        }
        const group = configuration_1.configuration.get(`${conf}Name`, 1) + 2;
        const regex = new RegExp(`(^|/)(${layout})$`);
        const matches = folder.match(regex);
        if (matches && matches[2] && matches[group]) {
            return {
                path: matches[2],
                name: matches[group]
            };
        }
    }
}
exports.getBranchName = getBranchName;
class FolderItem {
    constructor(_dir, _parent) {
        this._dir = _dir;
        this._parent = _parent;
    }
    get label() {
        if (this.branch) {
            return `$(git-branch) ${this._dir.name}`;
        }
        return `$(file-directory) ${this._dir.name}`;
    }
    get description() {
        return `r${this._dir.commit.revision} | ${this._dir.commit.author} | ${new Date(this._dir.commit.date).toLocaleString()}`;
    }
    get path() {
        if (this._parent) {
            return `${this._parent}/${this._dir.name}`;
        }
        return this._dir.name;
    }
    get branch() {
        return getBranchName(this.path);
    }
}
__decorate([
    decorators_1.memoize
], FolderItem.prototype, "branch", null);
exports.FolderItem = FolderItem;
class NewFolderItem {
    constructor(_parent) {
        this._parent = _parent;
    }
    get label() {
        return `$(plus) Create new branch`;
    }
    get description() {
        return `Create new branch in "${this._parent}"`;
    }
}
exports.NewFolderItem = NewFolderItem;
class ParentFolderItem {
    constructor(path) {
        this.path = path;
    }
    get label() {
        return `$(arrow-left) back to /${this.path}`;
    }
    get description() {
        return `Back to parent`;
    }
}
exports.ParentFolderItem = ParentFolderItem;
function selectBranch(repository, allowNew = false, folder) {
    return __awaiter(this, void 0, void 0, function* () {
        const promise = repository.repository.list(folder);
        vscode_1.window.withProgress({ location: vscode_1.ProgressLocation.Window, title: "Checking remote branches" }, () => promise);
        const list = yield promise;
        const dirs = list.filter(item => item.kind === listParser_1.SvnKindType.DIR);
        const picks = [];
        if (folder) {
            const parts = folder.split("/");
            parts.pop();
            const parent = parts.join("/");
            picks.push(new ParentFolderItem(parent));
        }
        if (allowNew && folder && !!getBranchName(`${folder}/test`)) {
            picks.push(new NewFolderItem(folder));
        }
        picks.push(...dirs.map(dir => new FolderItem(dir, folder)));
        const choice = yield vscode_1.window.showQuickPick(picks);
        if (!choice) {
            return;
        }
        if (choice instanceof ParentFolderItem) {
            return selectBranch(repository, allowNew, choice.path);
        }
        if (choice instanceof FolderItem) {
            if (choice.branch) {
                return choice.branch;
            }
            return selectBranch(repository, allowNew, choice.path);
        }
        if (choice instanceof NewFolderItem) {
            const result = yield vscode_1.window.showInputBox({
                prompt: "Please provide a branch name",
                ignoreFocusOut: true
            });
            if (!result) {
                return;
            }
            const name = result.replace(/^\.|\/\.|\.\.|~|\^|:|\/$|\.lock$|\.lock\/|\\|\*|\s|^\s*$|\.$/g, "-");
            const newBranch = getBranchName(`${folder}/${name}`);
            if (newBranch) {
                newBranch.isNew = true;
            }
            return newBranch;
        }
    });
}
exports.selectBranch = selectBranch;
//# sourceMappingURL=branches.js.map