"use strict";
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
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
const inversify_1 = require("inversify");
const path = require("path");
const vscode_languageclient_1 = require("vscode-languageclient");
const types_1 = require("../common/application/types");
const constants_1 = require("../common/constants");
const helpers_1 = require("../common/helpers");
const types_2 = require("../common/platform/types");
const stopWatch_1 = require("../common/stopWatch");
const types_3 = require("../common/types");
const contracts_1 = require("../interpreter/contracts");
const types_4 = require("../ioc/types");
const constants_2 = require("../telemetry/constants");
const telemetry_1 = require("../telemetry/telemetry");
const downloader_1 = require("./downloader");
const interpreterDataService_1 = require("./interpreterDataService");
const platformData_1 = require("./platformData");
const PYTHON = 'python';
const dotNetCommand = 'dotnet';
const languageClientName = 'Python Tools';
const analysisEngineFolder = 'analysis';
const loadExtensionCommand = 'python._loadLanguageServerExtension';
let AnalysisExtensionActivator = class AnalysisExtensionActivator {
    constructor(services) {
        this.services = services;
        this.sw = new stopWatch_1.StopWatch();
        this.disposables = [];
        this.interpreterHash = '';
        this.context = this.services.get(types_3.IExtensionContext);
        this.configuration = this.services.get(types_3.IConfigurationService);
        this.appShell = this.services.get(types_1.IApplicationShell);
        this.output = this.services.get(types_3.IOutputChannel, constants_1.STANDARD_OUTPUT_CHANNEL);
        this.fs = this.services.get(types_2.IFileSystem);
        this.platformData = new platformData_1.PlatformData(services.get(types_2.IPlatformService), this.fs);
        this.interpreterService = this.services.get(contracts_1.IInterpreterService);
        this.workspace = this.services.get(types_1.IWorkspaceService);
        // Currently only a single root. Multi-root support is future.
        this.root = this.workspace && this.workspace.hasWorkspaceFolders
            ? this.workspace.workspaceFolders[0].uri : undefined;
        this.startupCompleted = helpers_1.createDeferred();
        const commandManager = this.services.get(types_1.ICommandManager);
        this.disposables.push(commandManager.registerCommand(loadExtensionCommand, (args) => __awaiter(this, void 0, void 0, function* () {
            if (this.languageClient) {
                yield this.startupCompleted.promise;
                this.languageClient.sendRequest('python/loadExtension', args);
            }
            else {
                this.loadExtensionArgs = args;
            }
        })));
    }
    activate() {
        return __awaiter(this, void 0, void 0, function* () {
            this.sw.reset();
            const clientOptions = yield this.getAnalysisOptions();
            if (!clientOptions) {
                return false;
            }
            this.disposables.push(this.interpreterService.onDidChangeInterpreter(() => this.restartLanguageServer()));
            return this.startLanguageServer(clientOptions);
        });
    }
    deactivate() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.languageClient) {
                // Do not await on this
                this.languageClient.stop();
            }
            for (const d of this.disposables) {
                d.dispose();
            }
        });
    }
    restartLanguageServer() {
        return __awaiter(this, void 0, void 0, function* () {
            if (!this.context) {
                return;
            }
            const ids = new interpreterDataService_1.InterpreterDataService(this.context, this.services);
            const idata = yield ids.getInterpreterData();
            if (!idata || idata.hash !== this.interpreterHash) {
                this.interpreterHash = idata ? idata.hash : '';
                yield this.deactivate();
                yield this.activate();
            }
        });
    }
    startLanguageServer(clientOptions) {
        return __awaiter(this, void 0, void 0, function* () {
            // Determine if we are running MSIL/Universal via dotnet or self-contained app.
            const reporter = telemetry_1.getTelemetryReporter();
            reporter.sendTelemetryEvent(constants_2.PYTHON_ANALYSIS_ENGINE_ENABLED);
            const settings = this.configuration.getSettings();
            if (!settings.downloadCodeAnalysis) {
                // Depends on .NET Runtime or SDK. Typically development-only case.
                this.languageClient = this.createSimpleLanguageClient(clientOptions);
                yield this.startLanguageClient();
                return true;
            }
            const mscorlib = path.join(this.context.extensionPath, analysisEngineFolder, 'mscorlib.dll');
            if (!(yield this.fs.fileExists(mscorlib))) {
                const downloader = new downloader_1.AnalysisEngineDownloader(this.services, analysisEngineFolder);
                yield downloader.downloadAnalysisEngine(this.context);
                reporter.sendTelemetryEvent(constants_2.PYTHON_ANALYSIS_ENGINE_DOWNLOADED);
            }
            const serverModule = path.join(this.context.extensionPath, analysisEngineFolder, this.platformData.getEngineExecutableName());
            this.languageClient = this.createSelfContainedLanguageClient(serverModule, clientOptions);
            try {
                yield this.startLanguageClient();
                return true;
            }
            catch (ex) {
                this.appShell.showErrorMessage(`Language server failed to start. Error ${ex}`);
                reporter.sendTelemetryEvent(constants_2.PYTHON_ANALYSIS_ENGINE_ERROR, { error: 'Failed to start (platform)' });
                return false;
            }
        });
    }
    startLanguageClient() {
        return __awaiter(this, void 0, void 0, function* () {
            this.languageClient.onReady()
                .then(() => {
                this.startupCompleted.resolve();
                if (this.loadExtensionArgs) {
                    this.languageClient.sendRequest('python/loadExtension', this.loadExtensionArgs);
                    this.loadExtensionArgs = undefined;
                }
            })
                .catch(error => this.startupCompleted.reject(error));
            this.context.subscriptions.push(this.languageClient.start());
            if (constants_1.isTestExecution()) {
                yield this.startupCompleted.promise;
            }
        });
    }
    createSimpleLanguageClient(clientOptions) {
        const commandOptions = { stdio: 'pipe' };
        const serverModule = path.join(this.context.extensionPath, analysisEngineFolder, this.platformData.getEngineDllName());
        const serverOptions = {
            run: { command: dotNetCommand, args: [serverModule], options: commandOptions },
            debug: { command: dotNetCommand, args: [serverModule, '--debug'], options: commandOptions }
        };
        return new vscode_languageclient_1.LanguageClient(PYTHON, languageClientName, serverOptions, clientOptions);
    }
    createSelfContainedLanguageClient(serverModule, clientOptions) {
        const options = { stdio: 'pipe' };
        const serverOptions = {
            run: { command: serverModule, rgs: [], options: options },
            debug: { command: serverModule, args: ['--debug'], options }
        };
        return new vscode_languageclient_1.LanguageClient(PYTHON, languageClientName, serverOptions, clientOptions);
    }
    getAnalysisOptions() {
        return __awaiter(this, void 0, void 0, function* () {
            // tslint:disable-next-line:no-any
            const properties = new Map();
            let interpreterData;
            let pythonPath = '';
            try {
                const interpreterDataService = new interpreterDataService_1.InterpreterDataService(this.context, this.services);
                interpreterData = yield interpreterDataService.getInterpreterData();
            }
            catch (ex) {
                this.appShell.showErrorMessage('Unable to determine path to the Python interpreter. IntelliSense will be limited.');
            }
            this.interpreterHash = interpreterData ? interpreterData.hash : '';
            if (interpreterData) {
                pythonPath = path.dirname(interpreterData.path);
                // tslint:disable-next-line:no-string-literal
                properties['InterpreterPath'] = interpreterData.path;
                // tslint:disable-next-line:no-string-literal
                properties['Version'] = interpreterData.version;
                // tslint:disable-next-line:no-string-literal
                properties['PrefixPath'] = interpreterData.prefix;
            }
            let searchPaths = interpreterData ? interpreterData.searchPaths : '';
            const settings = this.configuration.getSettings();
            if (settings.autoComplete) {
                const extraPaths = settings.autoComplete.extraPaths;
                if (extraPaths && extraPaths.length > 0) {
                    searchPaths = `${searchPaths};${extraPaths.join(';')}`;
                }
            }
            // tslint:disable-next-line:no-string-literal
            properties['DatabasePath'] = path.join(this.context.extensionPath, analysisEngineFolder);
            // Make sure paths do not contain multiple slashes so file URIs
            // in VS Code (Node.js) and in the language server (.NET) match.
            // Note: for the language server paths separator is always ;
            searchPaths = searchPaths.split(path.delimiter).map(p => path.normalize(p)).join(';');
            // tslint:disable-next-line:no-string-literal
            properties['SearchPaths'] = `${searchPaths};${pythonPath}`;
            const selector = [{ language: PYTHON, scheme: 'file' }];
            const excludeFiles = this.getExcludedFiles();
            // Options to control the language client
            return {
                // Register the server for Python documents
                documentSelector: selector,
                synchronize: {
                    configurationSection: PYTHON
                },
                outputChannel: this.output,
                initializationOptions: {
                    interpreter: {
                        properties
                    },
                    displayOptions: {
                        preferredFormat: 1,
                        trimDocumentationLines: false,
                        maxDocumentationLineLength: 0,
                        trimDocumentationText: false,
                        maxDocumentationTextLength: 0
                    },
                    asyncStartup: true,
                    excludeFiles: excludeFiles,
                    testEnvironment: constants_1.isTestExecution()
                }
            };
        });
    }
    getExcludedFiles() {
        const list = ['**/Lib/**', '**/site-packages/**'];
        this.getVsCodeExcludeSection('search.exclude', list);
        this.getVsCodeExcludeSection('files.exclude', list);
        this.getVsCodeExcludeSection('files.watcherExclude', list);
        this.getPythonExcludeSection('linting.ignorePatterns', list);
        this.getPythonExcludeSection('workspaceSymbols.exclusionPattern', list);
        return list;
    }
    getVsCodeExcludeSection(setting, list) {
        const states = this.workspace.getConfiguration(setting, this.root);
        if (states) {
            Object.keys(states)
                .filter(k => (k.indexOf('*') >= 0 || k.indexOf('/') >= 0) && states[k])
                .forEach(p => list.push(p));
        }
    }
    getPythonExcludeSection(setting, list) {
        const pythonSettings = this.configuration.getSettings(this.root);
        const paths = pythonSettings && pythonSettings.linting ? pythonSettings.linting.ignorePatterns : undefined;
        if (paths && Array.isArray(paths)) {
            paths
                .filter(p => p && p.length > 0)
                .forEach(p => list.push(p));
        }
    }
};
AnalysisExtensionActivator = __decorate([
    inversify_1.injectable(),
    __param(0, inversify_1.inject(types_4.IServiceContainer))
], AnalysisExtensionActivator);
exports.AnalysisExtensionActivator = AnalysisExtensionActivator;
//# sourceMappingURL=analysis.js.map