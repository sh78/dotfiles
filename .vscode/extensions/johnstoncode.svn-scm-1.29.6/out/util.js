"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const path_1 = require("path");
function done(promise) {
    return promise.then(() => void 0);
}
exports.done = done;
function anyEvent(...events) {
    return (listener, thisArgs = null, disposables) => {
        const result = combinedDisposable(events.map(event => event((i) => listener.call(thisArgs, i))));
        if (disposables) {
            disposables.push(result);
        }
        return result;
    };
}
exports.anyEvent = anyEvent;
function filterEvent(event, filter) {
    return (listener, thisArgs = null, disposables) => event((e) => filter(e) && listener.call(thisArgs, e), null, disposables);
}
exports.filterEvent = filterEvent;
function dispose(disposables) {
    disposables.forEach(disposable => disposable.dispose());
    return [];
}
exports.dispose = dispose;
function combinedDisposable(disposables) {
    return toDisposable(() => dispose(disposables));
}
exports.combinedDisposable = combinedDisposable;
function toDisposable(dispose) {
    return { dispose };
}
exports.toDisposable = toDisposable;
function onceEvent(event) {
    return (listener, thisArgs = null, disposables) => {
        const result = event((e) => {
            result.dispose();
            return listener.call(thisArgs, e);
        }, null, disposables);
        return result;
    };
}
exports.onceEvent = onceEvent;
function eventToPromise(event) {
    return new Promise(c => onceEvent(event)(c));
}
exports.eventToPromise = eventToPromise;
const regexNormalizePath = new RegExp(path_1.sep === "/" ? "\\\\" : "/", "g");
const regexNormalizeWindows = new RegExp("^\\\\(\\w:)", "g");
function fixPathSeparator(file) {
    file = file.replace(regexNormalizePath, path_1.sep);
    file = file.replace(regexNormalizeWindows, "$1"); // "\t:\test" => "t:\test"
    return file;
}
exports.fixPathSeparator = fixPathSeparator;
function isDescendant(parent, descendant) {
    parent = parent.replace(/[\\\/]/g, path_1.sep);
    descendant = descendant.replace(/[\\\/]/g, path_1.sep);
    // IF Windows
    if (path_1.sep === "\\") {
        parent = parent.replace(/^\\/, "").toLowerCase();
        descendant = descendant.replace(/^\\/, "").toLowerCase();
    }
    if (parent === descendant) {
        return true;
    }
    if (parent.charAt(parent.length - 1) !== path_1.sep) {
        parent += path_1.sep;
    }
    return descendant.startsWith(parent);
}
exports.isDescendant = isDescendant;
function camelcase(name) {
    return name
        .replace(/(?:^\w|[A-Z]|\b\w)/g, function (letter, index) {
        return index === 0 ? letter.toLowerCase() : letter.toUpperCase();
    })
        .replace(/[\s\-]+/g, "");
}
exports.camelcase = camelcase;
let hasDecorationProvider = false;
function hasSupportToDecorationProvider() {
    return hasDecorationProvider;
}
exports.hasSupportToDecorationProvider = hasSupportToDecorationProvider;
try {
    const fake = {
        onDidChangeDecorations: (value) => toDisposable(() => { }),
        provideDecoration: (uri, token) => { }
    };
    const disposable = vscode_1.window.registerDecorationProvider(fake);
    hasDecorationProvider = true;
    // disposable.dispose(); // Not dispose to prevent: Cannot read property 'provideDecoration' of undefined
}
catch (error) { }
let hasRegisterDiffCommand = false;
function hasSupportToRegisterDiffCommand() {
    return hasRegisterDiffCommand;
}
exports.hasSupportToRegisterDiffCommand = hasSupportToRegisterDiffCommand;
try {
    const disposable = vscode_1.commands.registerDiffInformationCommand("svn.testDiff", () => { });
    hasRegisterDiffCommand = true;
    disposable.dispose();
}
catch (error) { }
function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
exports.timeout = timeout;
//# sourceMappingURL=util.js.map