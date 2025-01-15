{{
  "language": "Solidity",
  "sources": {
    "src/governance/xNANI.sol": {
      "content": "// ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘ ⌘\n// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity 0.8.27;\n\n/// @notice Simple nontransferable xNANI voting token.\n/// @dev Includes method for staking and unstaking NANI.\n/// @custom:lex Nani DAO is chartered as progressive DUNA\n/// (https://github.com/NaniDAO/NaniDAO)\n/// @author nani.eth (Nani DAO)\ncontract xNANI {\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n    event Approval(address indexed from, address indexed to, uint256 amount);\n\n    string public constant name = \"xNANI\";\n    string public constant symbol = \"xNANI\";\n    uint256 public constant decimals = 18;\n    address public constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;\n    \n    uint256 public totalSupply;\n\n    mapping(address => uint256) public balanceOf;\n    mapping(address => mapping(address => uint256)) public allowance;\n\n    function approve(address to, uint256 amount) public returns (bool) {\n        allowance[msg.sender][to] = amount;\n        emit Approval(msg.sender, to, amount);\n        return true;\n    }\n\n    // STAKING\n\n    function stake(uint256 amount) public {\n        uint256 totalNani = IToken(NANI).balanceOf(this);\n        uint256 totalShares = totalSupply;\n        if (totalShares == 0 || totalNani == 0) {\n            unchecked {\n                balanceOf[msg.sender] += amount;\n                totalSupply += amount;\n                emit Transfer(address(0), msg.sender, amount);\n            }\n        } else {\n            unchecked {\n                uint256 what = amount * totalShares / totalNani;\n                balanceOf[msg.sender] += what;\n                totalSupply += what;\n                emit Transfer(address(0), msg.sender, what);\n            }\n        }\n        IToken(NANI).transferFrom(msg.sender, this, amount);\n    }\n\n    function unstake(uint256 share) public {\n        uint256 what = share * IToken(NANI).balanceOf(this) / totalSupply;\n        balanceOf[msg.sender] -= share;\n        unchecked {\n            totalSupply -= share;\n        }\n        IToken(NANI).transfer(msg.sender, what);\n        emit Transfer(msg.sender, address(0), share);\n    }\n\n    function stakedBalance(address user) public view returns (uint256) {\n        return balanceOf[user] * IToken(NANI).balanceOf(this) / totalSupply;\n    }\n\n    // NONTRANSFERABLE\n\n    function transfer(address, uint256) public returns (bool) {} // Nope.\n    function transferFrom(address, address, uint256) public returns (bool) {}\n}\n\n/// @notice Simple token interaction interface.\ninterface IToken {\n    function balanceOf(xNANI) external view returns (uint256);\n    function transfer(address, uint256) external returns (bool);\n    function transferFrom(address, xNANI, uint256) external returns (bool);\n}"
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