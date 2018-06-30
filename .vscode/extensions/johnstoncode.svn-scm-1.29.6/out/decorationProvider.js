/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const decorators_1 = require("./decorators");
const util_1 = require("./util");
const path = require("path");
const configuration_1 = require("./helpers/configuration");
class SvnIgnoreDecorationProvider {
    constructor(repository) {
        this.repository = repository;
        this._onDidChangeDecorations = new vscode_1.EventEmitter();
        this.onDidChangeDecorations = this._onDidChangeDecorations
            .event;
        this.checkIgnoreQueue = new Map();
        this.disposables = [];
        this.disposables.push(vscode_1.window.registerDecorationProvider(this), repository.onDidChangeStatus(_ => this._onDidChangeDecorations.fire()));
    }
    dispose() {
        this.disposables.forEach(d => d.dispose());
        this.checkIgnoreQueue.clear();
    }
    provideDecoration(uri) {
        return new Promise((resolve, reject) => {
            this.checkIgnoreQueue.set(uri.fsPath, { resolve, reject });
            this.checkIgnoreSoon();
        }).then(ignored => {
            if (ignored) {
                return {
                    priority: 3,
                    color: new vscode_1.ThemeColor("gitDecoration.ignoredResourceForeground")
                };
            }
        });
    }
    checkIgnoreSoon() {
        const queue = new Map(this.checkIgnoreQueue.entries());
        this.checkIgnoreQueue.clear();
        const ignored = this.repository.statusIgnored;
        const external = this.repository.statusExternal;
        const files = ignored.map(stat => path.join(this.repository.workspaceRoot, stat.path));
        files.push(...external.map(stat => path.join(this.repository.workspaceRoot, stat.path)));
        for (const [key, value] of queue.entries()) {
            value.resolve(files.some(file => util_1.isDescendant(file, key)));
        }
    }
}
__decorate([
    decorators_1.debounce(500)
], SvnIgnoreDecorationProvider.prototype, "checkIgnoreSoon", null);
class SvnDecorationProvider {
    constructor(repository) {
        this.repository = repository;
        this._onDidChangeDecorations = new vscode_1.EventEmitter();
        this.onDidChangeDecorations = this._onDidChangeDecorations
            .event;
        this.disposables = [];
        this.decorations = new Map();
        this.disposables.push(vscode_1.window.registerDecorationProvider(this), repository.onDidRunOperation(this.onDidRunOperation, this));
    }
    onDidRunOperation() {
        let newDecorations = new Map();
        this.collectDecorationData(this.repository.changes, newDecorations);
        this.collectDecorationData(this.repository.unversioned, newDecorations);
        this.collectDecorationData(this.repository.conflicts, newDecorations);
        this.repository.changelists.forEach((group, changelist) => {
            this.collectDecorationData(group, newDecorations);
        });
        let uris = [];
        newDecorations.forEach((value, uriString) => {
            if (this.decorations.has(uriString)) {
                this.decorations.delete(uriString);
            }
            else {
                uris.push(vscode_1.Uri.parse(uriString));
            }
        });
        this.decorations.forEach((value, uriString) => {
            uris.push(vscode_1.Uri.parse(uriString));
        });
        this.decorations = newDecorations;
        this._onDidChangeDecorations.fire(uris);
    }
    collectDecorationData(group, bucket) {
        group.resourceStates.forEach(r => {
            if (r.resourceDecoration) {
                bucket.set(r.resourceUri.toString(), r.resourceDecoration);
            }
        });
    }
    provideDecoration(uri) {
        return this.decorations.get(uri.toString());
    }
    dispose() {
        this.disposables.forEach(d => d.dispose());
    }
}
class SvnDecorations {
    constructor(model) {
        this.model = model;
        this.enabled = false;
        this.modelListener = [];
        this.providers = new Map();
        this.configListener = vscode_1.workspace.onDidChangeConfiguration(() => this.update());
        this.update();
    }
    update() {
        const enabled = configuration_1.configuration.get("decorations.enabled");
        if (this.enabled === enabled) {
            return;
        }
        if (enabled) {
            this.enable();
        }
        else {
            this.disable();
        }
        this.enabled = enabled;
    }
    enable() {
        this.modelListener = [];
        this.model.onDidOpenRepository(this.onDidOpenRepository, this, this.modelListener);
        this.model.onDidCloseRepository(this.onDidCloseRepository, this, this.modelListener);
        this.model.repositories.forEach(this.onDidOpenRepository, this);
    }
    disable() {
        this.modelListener.forEach(d => d.dispose());
        this.providers.forEach(value => value.dispose());
        this.providers.clear();
    }
    onDidOpenRepository(repository) {
        const provider = new SvnDecorationProvider(repository);
        const ignoreProvider = new SvnIgnoreDecorationProvider(repository);
        this.providers.set(repository, vscode_1.Disposable.from(provider, ignoreProvider));
    }
    onDidCloseRepository(repository) {
        const provider = this.providers.get(repository);
        if (provider) {
            provider.dispose();
            this.providers.delete(repository);
        }
    }
    dispose() {
        this.configListener.dispose();
        this.disable();
    }
}
exports.SvnDecorations = SvnDecorations;
//# sourceMappingURL=decorationProvider.js.map