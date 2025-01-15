{{
  "language": "Solidity",
  "sources": {
    "src/L1GovernanceRelay.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\n\n// Copyright (C) 2024 Dai Foundation\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity ^0.8.21;\n\ninterface CrossDomainMessengerLike {\n    function sendMessage(address _target, bytes calldata _message, uint32 _minGasLimit) external payable;\n}\n\ninterface L2GovernanceRelayLike {\n    function relay(address target, bytes calldata targetData) external;\n}\n\n// Relay a message from L1 to L2GovernanceRelay\ncontract L1GovernanceRelay {\n    // --- storage variables ---\n\n    mapping(address => uint256) public wards;\n\n    // --- immutables ---\n\n    address public immutable l2GovernanceRelay;\n    CrossDomainMessengerLike public immutable messenger;\n\n    // --- events ---\n\n    event Rely(address indexed usr);\n    event Deny(address indexed usr);\n\n    // --- modifiers ---\n\n    modifier auth() {\n        require(wards[msg.sender] == 1, \"L1GovernanceRelay/not-authorized\");\n        _;\n    }\n\n    // --- constructor ---\n\n    constructor(\n        address _l2GovernanceRelay,\n        address _l1Messenger \n    ) {\n        l2GovernanceRelay = _l2GovernanceRelay;\n        messenger = CrossDomainMessengerLike(_l1Messenger);\n        wards[msg.sender] = 1;\n        emit Rely(msg.sender);\n    }\n\n    // --- administration ---\n\n    function rely(address usr) external auth {\n        wards[usr] = 1;\n        emit Rely(usr);\n    }\n\n    function deny(address usr) external auth {\n        wards[usr] = 0;\n        emit Deny(usr);\n    }\n\n    // --- relay ---\n\n    function relay(address target, bytes calldata targetData, uint32 minGasLimit) external auth {\n        messenger.sendMessage({\n            _target: l2GovernanceRelay,\n            _message: abi.encodeCall(L2GovernanceRelayLike.relay, (target, targetData)),\n            _minGasLimit: minGasLimit\n        });\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/",
      "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
      "forge-std/=lib/dss-test/lib/forge-std/src/",
      "ds-test/=lib/openzeppelin-contracts-upgradeable/lib/forge-std/lib/ds-test/src/",
      "dss-interfaces/=lib/dss-test/lib/dss-interfaces/src/",
      "dss-test/=lib/dss-test/src/",
      "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
      "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/",
      "openzeppelin-foundry-upgrades/=lib/openzeppelin-foundry-upgrades/src/",
      "solidity-stringutils/=lib/openzeppelin-foundry-upgrades/lib/solidity-stringutils/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "metadata": {
      "useLiteralContent": false,
      "bytecodeHash": "ipfs",
      "appendCBOR": true
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "evmVersion": "paris",
    "viaIR": false,
    "libraries": {}
  }
}}