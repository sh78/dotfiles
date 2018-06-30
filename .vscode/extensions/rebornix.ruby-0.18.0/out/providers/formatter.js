"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const rubyFormat_1 = require("../format/rubyFormat");
function registerFormatter(ctx) {
    new rubyFormat_1.RubyDocumentFormattingEditProvider().register(ctx);
}
exports.registerFormatter = registerFormatter;
//# sourceMappingURL=formatter.js.map