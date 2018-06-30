"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const cp = require("child_process");
const svn_1 = require("./svn");
function parseVersion(raw) {
    const match = raw.match(/(\d+\.\d+\.\d+ \(r\d+\))/);
    if (match && match[0]) {
        return match[0];
    }
    return raw.split(/[\r\n]+/)[0];
}
exports.parseVersion = parseVersion;
class SvnFinder {
    findSvn(hint) {
        const first = hint ? this.findSpecificSvn(hint) : Promise.reject(null);
        return first
            .then(void 0, () => {
            switch (process.platform) {
                case "darwin":
                    return this.findSvnDarwin();
                case "win32":
                    return this.findSvnWin32();
                default:
                    return this.findSpecificSvn("svn");
            }
        })
            .then(null, () => Promise.reject(new Error("Svn installation not found.")));
    }
    findSvnWin32() {
        return this.findSystemSvnWin32(process.env["ProgramW6432"])
            .then(void 0, () => this.findSystemSvnWin32(process.env["ProgramFiles(x86)"]))
            .then(void 0, () => this.findSystemSvnWin32(process.env["ProgramFiles"]))
            .then(void 0, () => this.findSpecificSvn("svn"));
    }
    findSystemSvnWin32(base) {
        if (!base) {
            return Promise.reject("Not found");
        }
        return this.findSpecificSvn(path.join(base, "TortoiseSVN", "bin", "svn.exe"));
    }
    findSvnDarwin() {
        return new Promise((c, e) => {
            cp.exec("which svn", (err, svnPathBuffer) => {
                if (err) {
                    return e("svn not found");
                }
                const path = svnPathBuffer.toString().replace(/^\s+|\s+$/g, "");
                function getVersion(path) {
                    // make sure svn executes
                    cp.exec("svn --version", (err, stdout) => {
                        if (err) {
                            return e("svn not found");
                        }
                        return c({ path, version: parseVersion(stdout.trim()) });
                    });
                }
                if (path !== "/usr/bin/svn") {
                    return getVersion(path);
                }
                // must check if XCode is installed
                cp.exec("xcode-select -p", (err) => {
                    if (err && err.code === 2) {
                        // svn is not installed, and launching /usr/bin/svn
                        // will prompt the user to install it
                        return e("svn not found");
                    }
                    getVersion(path);
                });
            });
        });
    }
    findSpecificSvn(path) {
        return new Promise((c, e) => {
            const buffers = [];
            const child = cp.spawn(path, ["--version"]);
            child.stdout.on("data", (b) => buffers.push(b));
            child.on("error", svn_1.cpErrorHandler(e));
            child.on("exit", code => code
                ? e(new Error("Not found"))
                : c({
                    path,
                    version: parseVersion(Buffer.concat(buffers)
                        .toString("utf8")
                        .trim())
                }));
        });
    }
}
exports.SvnFinder = SvnFinder;
//# sourceMappingURL=svnFinder.js.map