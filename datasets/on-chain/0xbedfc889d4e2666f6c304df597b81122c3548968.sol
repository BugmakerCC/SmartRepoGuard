{{
  "language": "Solidity",
  "sources": {
    "src/governance/Points.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity ^0.8.19;\n\n/// @notice Simple onchain points allocation protocol.\n/// @author nani.eth (nani.ooo)\n/// @custom:version 1.1.1\ncontract Points {\n    address public immutable owner; // Signatory.\n    uint256 public immutable rate; // Issuance.\n    mapping(address => uint256) public claimed;\n\n    IERC20 constant token = \n        IERC20(0x00000000000007C8612bA63Df8DdEfD9E6077c97);\n\n    constructor(address _owner, uint256 _rate) payable {\n        (owner, rate) = (_owner, _rate);\n    }\n\n    function check(address user, uint256 start, uint256 bonus, bytes calldata signature)\n        public\n        view\n        returns (uint256 score)\n    {\n        bytes32 hash = keccak256((abi.encodePacked(user, start, bonus)));\n        bytes32 r;\n        bytes32 s;\n        uint8 v;\n        assembly (\"memory-safe\") {\n            r := calldataload(signature.offset)\n            s := calldataload(add(signature.offset, 0x20))\n            v := byte(0, calldataload(add(signature.offset, 0x40)))\n        }\n        if (\n            Points(owner).owner() == ecrecover(_toEthSignedMessageHash(hash), v, r, s)\n                || IERC1271.isValidSignature.selector\n                    == IERC1271(owner).isValidSignature(hash, signature)\n        ) score = (bonus + (rate * (block.timestamp - start))) - claimed[user];\n    }\n\n    function claim(\n        uint256 start, \n        uint256 bonus, \n        bytes calldata signature\n    ) public payable returns (uint256 sum) {\n        unchecked {\n            sum = check(msg.sender, start, bonus, signature);\n            if (sum != 0) {\n                claimed[msg.sender] += sum;\n                assert(token.transfer(msg.sender, sum));\n            }\n        }\n    }\n\n    function _toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {\n        assembly (\"memory-safe\") {\n            mstore(0x20, hash) // Store into scratch space for keccak256.\n            mstore(0x00, \"\\x00\\x00\\x00\\x00\\x19Ethereum Signed Message:\\n32\")\n            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.\n        }\n    }\n}\n\ninterface IERC20 {\n    function transfer(address, uint256) external returns (bool);\n}\n\ninterface IERC1271 {\n    function isValidSignature(bytes32, bytes calldata) external view returns (bytes4);\n}"
    }
  },
  "settings": {
    "remappings": [
      "@solady/=lib/solady/",
      "@forge/=lib/forge-std/src/",
      "forge-std/=lib/forge-std/src/",
      "solady/=lib/solady/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 9999999
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
    "evmVersion": "cancun",
    "viaIR": false,
    "libraries": {}
  }
}}