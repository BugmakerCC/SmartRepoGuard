{{
  "language": "Solidity",
  "sources": {
    "src/EthForward.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract EthForward {\n    error ForwardFailed(address from, address receiver, uint256 value);\n\n    event Forwarded(address indexed from, address indexed receiver, uint256 value);\n\n    function forward(address payable receiver) external payable {\n        (bool success,) = receiver.call{value: msg.value}(\"\");\n        if (!success) {\n            revert ForwardFailed(msg.sender, receiver, msg.value);\n        }\n        emit Forwarded(msg.sender, receiver, msg.value);\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "forge-std/=lib/forge-std/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "evmVersion": "shanghai",
    "viaIR": true,
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