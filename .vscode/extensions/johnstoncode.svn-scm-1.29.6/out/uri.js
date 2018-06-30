"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var SvnUriAction;
(function (SvnUriAction) {
    SvnUriAction["LOG"] = "LOG";
    SvnUriAction["PATCH"] = "PATCH";
    SvnUriAction["SHOW"] = "SHOW";
})(SvnUriAction = exports.SvnUriAction || (exports.SvnUriAction = {}));
function fromSvnUri(uri) {
    return JSON.parse(uri.query);
}
exports.fromSvnUri = fromSvnUri;
function toSvnUri(uri, action, extra = {}, replaceFileExtension = false) {
    const params = {
        action: action,
        fsPath: uri.fsPath,
        extra: extra
    };
    return uri.with({
        scheme: "svn",
        path: replaceFileExtension ? uri.path + '.svn' : uri.path,
        query: JSON.stringify(params)
    });
}
exports.toSvnUri = toSvnUri;
//# sourceMappingURL=uri.js.map