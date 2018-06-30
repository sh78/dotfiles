'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const utils = require("./utils");
const completion_1 = require("./providers/completion");
const formatter_1 = require("./providers/formatter");
const highlight_1 = require("./providers/highlight");
const intellisense_1 = require("./providers/intellisense");
const linters_1 = require("./providers/linters");
const rake_1 = require("./task/rake");
function activate(context) {
    const subs = context.subscriptions;
    // register language config
    vscode_1.languages.setLanguageConfiguration('ruby', {
        indentationRules: {
            increaseIndentPattern: /^(\s*(module|class|((private|protected)\s+)?def|unless|if|else|elsif|case|when|begin|rescue|ensure|for|while|until|(?=.*?\b(do|begin|case|if|unless)\b)("(\\.|[^\\"])*"|'(\\.|[^\\'])*'|[^#"'])*(\s(do|begin|case)|[-+=&|*/~%^<>~]\s*(if|unless)))\b(?![^;]*;.*?\bend\b)|("(\\.|[^\\"])*"|'(\\.|[^\\'])*'|[^#"'])*(\((?![^\)]*\))|\{(?![^\}]*\})|\[(?![^\]]*\]))).*$/,
            decreaseIndentPattern: /^\s*([}\]]([,)]?\s*(#|$)|\.[a-zA-Z_]\w*\b)|(end|rescue|ensure|else|elsif|when)\b)/,
        },
        wordPattern: /(-?\d+(?:\.\d+))|(:?[A-Za-z][^-`~@#%^&()=+[{}|;:'",<>/.*\]\s\\!?]*[!?]?)/,
    });
    // Register providers
    highlight_1.registerHighlightProvider(context);
    linters_1.registerLinters(context);
    completion_1.registerCompletionProvider(context);
    formatter_1.registerFormatter(context);
    intellisense_1.registerIntellisenseProvider(context);
    rake_1.registerTaskProvider(context);
    utils.loadEnv();
}
exports.activate = activate;
//# sourceMappingURL=ruby.js.map