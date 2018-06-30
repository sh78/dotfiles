// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const activationService_1 = require("./activationService");
const analysis_1 = require("./analysis");
const classic_1 = require("./classic");
const types_1 = require("./types");
function registerTypes(serviceManager) {
    serviceManager.addSingleton(types_1.IExtensionActivationService, activationService_1.ExtensionActivationService);
    serviceManager.add(types_1.IExtensionActivator, classic_1.ClassicExtensionActivator, types_1.ExtensionActivators.Jedi);
    serviceManager.add(types_1.IExtensionActivator, analysis_1.AnalysisExtensionActivator, types_1.ExtensionActivators.DotNet);
}
exports.registerTypes = registerTypes;
//# sourceMappingURL=serviceRegistry.js.map