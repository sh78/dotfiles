"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
var terminal;
function getTerminal() {
    if (!terminal) {
        terminal = vscode.window.createTerminal('Docker');
    }
    return terminal;
}
exports.getTerminal = getTerminal;
//# sourceMappingURL=terminal.js.map