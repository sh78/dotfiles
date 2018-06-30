"use strict";
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const analysisEngineHashes_1 = require("./analysisEngineHashes");
class PlatformData {
    constructor(platform, fs) {
        this.platform = platform;
    }
    getPlatformName() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.platform.isWindows) {
                return this.platform.is64bit ? 'win-x64' : 'win-x86';
            }
            if (this.platform.isMac) {
                return 'osx-x64';
            }
            if (this.platform.isLinux) {
                if (!this.platform.is64bit) {
                    throw new Error('Python Analysis Engine does not support 32-bit Linux.');
                }
                return 'linux-x64';
            }
            throw new Error('Unknown OS platform.');
        });
    }
    getEngineDllName() {
        return 'Microsoft.PythonTools.VsCode.dll';
    }
    getEngineExecutableName() {
        return this.platform.isWindows
            ? 'Microsoft.PythonTools.VsCode.exe'
            : 'Microsoft.PythonTools.VsCode.VsCode';
    }
    getExpectedHash() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.platform.isWindows) {
                return this.platform.is64bit ? analysisEngineHashes_1.analysis_engine_win_x64_sha512 : analysisEngineHashes_1.analysis_engine_win_x86_sha512;
            }
            if (this.platform.isMac) {
                return analysisEngineHashes_1.analysis_engine_osx_x64_sha512;
            }
            if (this.platform.isLinux && this.platform.is64bit) {
                return analysisEngineHashes_1.analysis_engine_linux_x64_sha512;
            }
            throw new Error('Unknown platform.');
        });
    }
}
exports.PlatformData = PlatformData;
//# sourceMappingURL=platformData.js.map