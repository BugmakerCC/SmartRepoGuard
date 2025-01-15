{{
  "language": "Solidity",
  "sources": {
    "src/solidity/WithBatcher.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.8.20;\n\ninterface ILegacyWithdraw {\n    function withdraw(uint256 amount, address recipient) external;\n}\n\nstruct LegacyWithdrawData {\n    address bridge;\n    uint256 amount;\n    address recipient;\n}\n\nuint8 constant MAX_WITHRAWALS = 128;\n\ncontract WithBatcher {\n\n    event FailedWithdrawals(LegacyWithdrawData withdrawData);\n\n    function withdrawBatch(LegacyWithdrawData[] calldata pendingWithdrawals) external {\n        require(pendingWithdrawals.length <= MAX_WITHRAWALS);\n\n        for (uint256 i = 0; i < pendingWithdrawals.length; i++) {\n            LegacyWithdrawData memory withData = pendingWithdrawals[i];\n            address bridge = withData.bridge;\n\n            bytes memory _calldata = abi.encodeWithSelector(\n                ILegacyWithdraw(bridge).withdraw.selector,\n                withData.amount,\n                withData.recipient\n            );\n\n            (bool success,) = bridge.call(_calldata);\n            if (!success) {\n                emit FailedWithdrawals(withData);\n            }\n        }\n    }\n\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "libraries": {},
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 100
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  }
}}