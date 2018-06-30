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
const xml2js = require("xml2js");
const util_1 = require("./util");
var SvnKindType;
(function (SvnKindType) {
    SvnKindType["FILE"] = "file";
    SvnKindType["DIR"] = "dir";
})(SvnKindType = exports.SvnKindType || (exports.SvnKindType = {}));
function parseSvnList(content) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => {
            xml2js.parseString(content, {
                mergeAttrs: true,
                explicitRoot: false,
                explicitArray: false,
                attrNameProcessors: [util_1.camelcase],
                tagNameProcessors: [util_1.camelcase]
            }, (err, result) => {
                if (err) {
                    reject();
                }
                if (result.list && result.list.entry) {
                    if (!Array.isArray(result.list.entry)) {
                        result.list.entry = [result.list.entry];
                    }
                    resolve(result.list.entry);
                }
                else {
                    resolve([]);
                }
            });
        });
    });
}
exports.parseSvnList = parseSvnList;
//# sourceMappingURL=listParser.js.map