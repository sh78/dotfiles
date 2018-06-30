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
const events_1 = require("events");
const cp = require("child_process");
const iconv = require("iconv-lite");
const jschardet = require("jschardet");
const svnRepository_1 = require("./svnRepository");
const infoParser_1 = require("./infoParser");
const util_1 = require("./util");
const configuration_1 = require("./helpers/configuration");
const isUtf8 = require("is-utf8");
// List: https://github.com/apache/subversion/blob/1.6.x/subversion/svn/schema/status.rnc#L33
var Status;
(function (Status) {
    Status["ADDED"] = "added";
    Status["CONFLICTED"] = "conflicted";
    Status["DELETED"] = "deleted";
    Status["EXTERNAL"] = "external";
    Status["IGNORED"] = "ignored";
    Status["INCOMPLETE"] = "incomplete";
    Status["MERGED"] = "merged";
    Status["MISSING"] = "missing";
    Status["MODIFIED"] = "modified";
    Status["NONE"] = "none";
    Status["NORMAL"] = "normal";
    Status["OBSTRUCTED"] = "obstructed";
    Status["REPLACED"] = "replaced";
    Status["UNVERSIONED"] = "unversioned";
})(Status = exports.Status || (exports.Status = {}));
var PropStatus;
(function (PropStatus) {
    PropStatus["CONFLICTED"] = "conflicted";
    PropStatus["MODIFIED"] = "modified";
    PropStatus["NONE"] = "none";
    PropStatus["NORMAL"] = "normal";
})(PropStatus = exports.PropStatus || (exports.PropStatus = {}));
exports.SvnErrorCodes = {
    AuthorizationFailed: "E170001",
    RepositoryIsLocked: "E155004",
    NotASvnRepository: "E155007",
    NotShareCommonAncestry: "E195012"
};
function getSvnErrorCode(stderr) {
    for (const name in exports.SvnErrorCodes) {
        const code = exports.SvnErrorCodes[name];
        const regex = new RegExp(`svn: ${code}`);
        if (regex.test(stderr)) {
            return code;
        }
    }
    if (/No more credentials or we tried too many times/.test(stderr)) {
        return exports.SvnErrorCodes.AuthorizationFailed;
    }
    return void 0;
}
function cpErrorHandler(cb) {
    return err => {
        if (/ENOENT/.test(err.message)) {
            err = new SvnError({
                error: err,
                message: "Failed to execute svn (ENOENT)",
                svnErrorCode: "NotASvnRepository"
            });
        }
        cb(err);
    };
}
exports.cpErrorHandler = cpErrorHandler;
class SvnError {
    constructor(data) {
        if (data.error) {
            this.error = data.error;
            this.message = data.error.message;
        }
        else {
            this.error = void 0;
        }
        this.message = data.message || "SVN error";
        this.stdout = data.stdout;
        this.stderr = data.stderr;
        this.stderrFormated = data.stderrFormated;
        this.exitCode = data.exitCode;
        this.svnErrorCode = data.svnErrorCode;
        this.svnCommand = data.svnCommand;
    }
    toString() {
        let result = this.message +
            " " +
            JSON.stringify({
                exitCode: this.exitCode,
                svnErrorCode: this.svnErrorCode,
                svnCommand: this.svnCommand,
                stdout: this.stdout,
                stderr: this.stderr
            }, null, 2);
        if (this.error) {
            result += this.error.stack;
        }
        return result;
    }
}
exports.SvnError = SvnError;
class Svn {
    constructor(options) {
        this.lastCwd = "";
        this._onOutput = new events_1.EventEmitter();
        this.svnPath = options.svnPath;
        this.version = options.version;
    }
    get onOutput() {
        return this._onOutput;
    }
    logOutput(output) {
        this._onOutput.emit("log", output);
    }
    exec(cwd, args, options = {}) {
        return __awaiter(this, void 0, void 0, function* () {
            if (cwd) {
                this.lastCwd = cwd;
                options.cwd = cwd;
            }
            if (options.log !== false) {
                const argsOut = args.map(arg => (/ |^$/.test(arg) ? `'${arg}'` : arg));
                this.logOutput(`[${this.lastCwd.split(/[\\\/]+/).pop()}]$ svn ${argsOut.join(" ")}\n`);
            }
            if (options.username) {
                args.push("--username", options.username);
            }
            if (options.password) {
                args.push("--password", options.password);
            }
            let process = cp.spawn(this.svnPath, args, options);
            const disposables = [];
            const once = (ee, name, fn) => {
                ee.once(name, fn);
                disposables.push(util_1.toDisposable(() => ee.removeListener(name, fn)));
            };
            const on = (ee, name, fn) => {
                ee.on(name, fn);
                disposables.push(util_1.toDisposable(() => ee.removeListener(name, fn)));
            };
            let [exitCode, stdout, stderr] = yield Promise.all([
                new Promise((resolve, reject) => {
                    once(process, "error", reject);
                    once(process, "exit", resolve);
                }),
                new Promise(resolve => {
                    const buffers = [];
                    on(process.stdout, "data", (b) => buffers.push(b));
                    once(process.stdout, "close", () => resolve(Buffer.concat(buffers)));
                }),
                new Promise(resolve => {
                    const buffers = [];
                    on(process.stderr, "data", (b) => buffers.push(b));
                    once(process.stderr, "close", () => resolve(Buffer.concat(buffers).toString()));
                })
            ]);
            util_1.dispose(disposables);
            let encoding = "utf8";
            // SVN with '--xml' always return 'UTF-8', and jschardet detects this encoding: 'TIS-620'
            if (!args.includes("--xml")) {
                const default_encoding = configuration_1.configuration.get("default.encoding");
                if (default_encoding) {
                    if (!iconv.encodingExists(default_encoding)) {
                        this.logOutput("svn.default.encoding: Invalid Parameter: '" +
                            default_encoding +
                            "'.\n");
                    }
                    else if (!isUtf8(stdout)) {
                        encoding = default_encoding;
                    }
                }
                else {
                    jschardet.MacCyrillicModel.mTypicalPositiveRatio += 0.001;
                    const encodingGuess = jschardet.detect(stdout);
                    if (encodingGuess.confidence > 0.8 &&
                        iconv.encodingExists(encodingGuess.encoding)) {
                        encoding = encodingGuess.encoding;
                    }
                }
            }
            stdout = iconv.decode(stdout, encoding);
            if (options.log !== false && stderr.length > 0) {
                this.logOutput(`${stderr}\n`);
            }
            if (exitCode) {
                return Promise.reject(new SvnError({
                    message: "Failed to execute svn",
                    stdout: stdout,
                    stderr: stderr,
                    stderrFormated: stderr.replace(/^svn: E\d+: +/gm, ""),
                    exitCode: exitCode,
                    svnErrorCode: getSvnErrorCode(stderr),
                    svnCommand: args[0]
                }));
            }
            return { exitCode, stdout, stderr };
        });
    }
    getRepositoryRoot(path) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield this.exec(path, ["info", "--xml"]);
                const info = yield infoParser_1.parseInfoXml(result.stdout);
                if (info && info.wcInfo && info.wcInfo.wcrootAbspath) {
                    return info.wcInfo.wcrootAbspath;
                }
                // SVN 1.6 not has "wcroot-abspath"
                return path;
            }
            catch (error) {
                console.error(error);
                throw new Error("Unable to find repository root path");
            }
        });
    }
    open(repositoryRoot, workspaceRoot) {
        return new svnRepository_1.Repository(this, repositoryRoot, workspaceRoot);
    }
}
exports.Svn = Svn;
//# sourceMappingURL=svn.js.map