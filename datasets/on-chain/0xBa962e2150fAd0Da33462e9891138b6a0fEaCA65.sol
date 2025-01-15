{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "paris",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "remappings": [],
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
  },
  "sources": {
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/layer2/LegacySystemConfig.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport { Ownable } from \"@openzeppelin/contracts/access/Ownable.sol\";\n\nimport \"./LegacySystemConfigStorage.sol\";\n\n\ncontract LegacySystemConfig is Ownable, LegacySystemConfigStorage {\n\n    /* ========== CONSTRUCTOR ========== */\n    constructor() {\n    }\n\n    modifier nonZero(uint256 value) {\n        require(value != 0, \"zero\");\n        _;\n    }\n\n    /* ========== onlyOwner ========== */\n\n    function setAddresses(string memory _name, Addresses memory _addresses, address _l1BridgeRegistry) external onlyOwner {\n        name = _name;\n        addresses = _addresses;\n        l1BridgeRegistry = _l1BridgeRegistry;\n    }\n\n    /* ========== onlyL1Bridge ========== */\n\n\n    /* ========== view ========== */\n\n    function l1CrossDomainMessenger() external view returns (address addr_) {\n        addr_ = addresses.l1CrossDomainMessenger;\n    }\n\n    function l1ERC721Bridge() external view returns (address addr_) {\n        addr_ = addresses.l1ERC721Bridge;\n    }\n\n    function l1StandardBridge() external view returns (address addr_) {\n        addr_ = addresses.l1StandardBridge;\n    }\n\n    function l2OutputOracle() external view returns (address addr_) {\n        addr_ = addresses.l2OutputOracle;\n    }\n\n    function optimismPortal() external view returns (address addr_) {\n        addr_ = addresses.optimismPortal;\n    }\n\n    function optimismMintableERC20Factory() external view returns (address addr_) {\n        addr_ = addresses.optimismMintableERC20Factory;\n    }\n\n}"
    },
    "contracts/layer2/LegacySystemConfigStorage.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\ncontract LegacySystemConfigStorage {\n\n    /// @notice Struct representing the addresses of L1 system contracts. These should be the\n    ///         proxies and will differ for each OP Stack chain.\n    struct Addresses {\n        address l1CrossDomainMessenger;\n        address l1ERC721Bridge;\n        address l1StandardBridge;\n        address l2OutputOracle;\n        address optimismPortal;\n        address optimismMintableERC20Factory;\n    }\n\n    address public proxyOwner;\n\n    Addresses public addresses;\n    // address public l2Ton;\n    string public name;\n\n    address public l1BridgeRegistry;\n\n}\n"
    }
  }
}}