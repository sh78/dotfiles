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
function processEntry(entry, changelist) {
    if (Array.isArray(entry)) {
        let list = [];
        entry.forEach((e) => {
            const r = processEntry(e, changelist);
            if (r) {
                list.push(...r);
            }
        });
        return list;
    }
    const wcStatus = {
        locked: !!entry.wcStatus.wcLocked && entry.wcStatus.wcLocked === "true",
        switched: !!entry.wcStatus.switched && entry.wcStatus.switched === "true"
    };
    let r = {
        changelist: changelist,
        path: entry.path,
        status: entry.wcStatus.item,
        props: entry.wcStatus.props,
        wcStatus: wcStatus
    };
    if (entry.wcStatus.movedTo && r.status === "deleted") {
        return [];
    }
    if (entry.wcStatus.movedFrom && r.status === "added") {
        r.rename = entry.wcStatus.movedFrom;
    }
    if (entry.wcStatus.commit) {
        r.commit = {
            revision: entry.wcStatus.commit.revision,
            author: entry.wcStatus.commit.author,
            date: entry.wcStatus.commit.date
        };
    }
    return [r];
}
function xmlToStatus(xml) {
    const statusList = [];
    if (xml.target && xml.target.entry) {
        statusList.push(...processEntry(xml.target.entry));
    }
    if (xml.changelist) {
        if (!Array.isArray(xml.changelist)) {
            xml.changelist = [xml.changelist];
        }
        xml.changelist.forEach((change) => {
            statusList.push(...processEntry(change.entry, change.name));
        });
    }
    return statusList;
}
function parseStatusXml(content) {
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
                const statusList = xmlToStatus(result);
                resolve(statusList);
            });
        });
    });
}
exports.parseStatusXml = parseStatusXml;
//# sourceMappingURL=statusParser.js.map