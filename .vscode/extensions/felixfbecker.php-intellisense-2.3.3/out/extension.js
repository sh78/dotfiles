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
const path = require("path");
const child_process_1 = require("mz/child_process");
const vscode = require("vscode");
const vscode_languageclient_1 = require("vscode-languageclient");
const semver = require("semver");
const net = require("net");
const url = require("url");
function activate(context) {
    return __awaiter(this, void 0, void 0, function* () {
        const conf = vscode.workspace.getConfiguration('php');
        const executablePath = conf.get('executablePath') || 'php';
        const memoryLimit = conf.get('memoryLimit') || '4095M';
        if (memoryLimit !== '-1' && !/^\d+[KMG]?$/.exec(memoryLimit)) {
            const selected = yield vscode.window.showErrorMessage('The memory limit you\'d provided is not numeric, nor "-1" nor valid php shorthand notation!', 'Open settings');
            if (selected === 'Open settings') {
                yield vscode.commands.executeCommand('workbench.action.openGlobalSettings');
            }
            return;
        }
        // Check path (if PHP is available and version is ^7.0.0)
        let stdout;
        try {
            [stdout] = yield child_process_1.execFile(executablePath, ['--version']);
        }
        catch (err) {
            if (err.code === 'ENOENT') {
                const selected = yield vscode.window.showErrorMessage('PHP executable not found. Install PHP 7 and add it to your PATH or set the php.executablePath setting', 'Open settings');
                if (selected === 'Open settings') {
                    yield vscode.commands.executeCommand('workbench.action.openGlobalSettings');
                }
            }
            else {
                vscode.window.showErrorMessage('Error spawning PHP: ' + err.message);
                console.error(err);
            }
            return;
        }
        // Parse version and discard OS info like 7.0.8--0ubuntu0.16.04.2
        const match = stdout.match(/^PHP ([^\s]+)/m);
        if (!match) {
            vscode.window.showErrorMessage('Error parsing PHP version. Please check the output of php --version');
            return;
        }
        let version = match[1].split('-')[0];
        // Convert PHP prerelease format like 7.0.0rc1 to 7.0.0-rc1
        if (!/^\d+.\d+.\d+$/.test(version)) {
            version = version.replace(/(\d+.\d+.\d+)/, '$1-');
        }
        if (semver.lt(version, '7.0.0')) {
            vscode.window.showErrorMessage('The language server needs at least PHP 7 installed. Version found: ' + version);
            return;
        }
        const serverOptions = () => new Promise((resolve, reject) => {
            // Use a TCP socket because of problems with blocking STDIO
            const server = net.createServer(socket => {
                // 'connection' listener
                console.log('PHP process connected');
                socket.on('end', () => {
                    console.log('PHP process disconnected');
                });
                server.close();
                resolve({ reader: socket, writer: socket });
            });
            // Listen on random port
            server.listen(0, '127.0.0.1', () => {
                // The server is implemented in PHP
                const childProcess = child_process_1.spawn(executablePath, [
                    context.asAbsolutePath(path.join('vendor', 'felixfbecker', 'language-server', 'bin', 'php-language-server.php')),
                    '--tcp=127.0.0.1:' + server.address().port,
                    '--memory-limit=' + memoryLimit
                ]);
                childProcess.stderr.on('data', (chunk) => {
                    console.error(chunk + '');
                });
                childProcess.stdout.on('data', (chunk) => {
                    console.log(chunk + '');
                });
                return childProcess;
            });
        });
        // Options to control the language client
        const clientOptions = {
            // Register the server for php documents
            documentSelector: [
                { scheme: 'file', language: 'php' },
                { scheme: 'untitled', language: 'php' }
            ],
            uriConverters: {
                // VS Code by default %-encodes even the colon after the drive letter
                // NodeJS handles it much better
                code2Protocol: uri => url.format(url.parse(uri.toString(true))),
                protocol2Code: str => vscode.Uri.parse(str)
            },
            synchronize: {
                // Synchronize the setting section 'php' to the server
                configurationSection: 'php',
                // Notify the server about changes to PHP files in the workspace
                fileEvents: vscode.workspace.createFileSystemWatcher('**/*.php')
            }
        };
        // Create the language client and start the client.
        const disposable = new vscode_languageclient_1.LanguageClient('PHP Language Server', serverOptions, clientOptions).start();
        // Push the disposable to the context's subscriptions so that the
        // client can be deactivated on extension deactivation
        context.subscriptions.push(disposable);
    });
}
exports.activate = activate;
//# sourceMappingURL=extension.js.map