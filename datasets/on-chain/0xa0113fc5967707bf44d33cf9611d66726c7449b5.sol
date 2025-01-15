{{
  "language": "Solidity",
  "sources": {
    "src/Registry.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause-Clear\npragma solidity ^0.8.4;\n\n/// @title Registry\n/// @notice Allows registering Infernet contracts for inter-contract discovery\n/// @dev Requires deploy-time decleration of contract addresses\n/// @dev Immutable with no upgradeability; used only for discovery\ncontract Registry {\n    /*//////////////////////////////////////////////////////////////\n                               IMMUTABLE\n    //////////////////////////////////////////////////////////////*/\n\n    /// @notice Coordinator address\n    address public immutable COORDINATOR;\n\n    /// @notice Inbox address\n    address public immutable INBOX;\n\n    /// @notice Reader address\n    address public immutable READER;\n\n    /// @notice Fee registry address\n    address public immutable FEE;\n\n    /// @notice Wallet factory address\n    address public immutable WALLET_FACTORY;\n\n    /*//////////////////////////////////////////////////////////////\n                              CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    /// @notice Initializes new Registry\n    /// @dev Requires pre-computing expected deployed addresses\n    /// @param coordinator Coordinator address\n    /// @param inbox Inbox address\n    /// @param reader Reader address\n    /// @param fee Fee registry address\n    /// @param walletFactory Wallet factory address\n    constructor(address coordinator, address inbox, address reader, address fee, address walletFactory) {\n        COORDINATOR = coordinator;\n        INBOX = inbox;\n        READER = reader;\n        FEE = fee;\n        WALLET_FACTORY = walletFactory;\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "solady/=lib/solady/src/",
      "forge-std/=lib/forge-std/src/",
      "weird-erc20/=lib/weird-erc20/src/",
      "ds-test/=lib/forge-std/lib/ds-test/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 1000000
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
    "viaIR": true,
    "libraries": {}
  }
}}