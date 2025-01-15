{{
  "language": "Solidity",
  "sources": {
    "src/QorpoBuySpin.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.25;\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"./utils/TokenAccessControl.sol\";\n\n\ncontract QorpoBuySpin is TokenAccessControl {\n\n    address public paymentTokenAddress;\n    uint256 public spinPrice;\n    address public treasuryAddress;\n    IERC20 private paymentToken;\n\n    constructor(address paymentTokenAddress_, uint256 spinPrice_, address treasuryAddress_) {\n        paymentTokenAddress = paymentTokenAddress_;\n        spinPrice = spinPrice_;\n        treasuryAddress = treasuryAddress_;\n        paymentToken = IERC20(paymentTokenAddress);\n\n    }\n\n    event BuySpin(address indexed toAddress, uint256 amount);\n    event BuySpinCustomPrice(address indexed toAddress, uint256 amount, uint256 customPrice);\n\n    function setPaymentTokenAddress(address _paymentTokenAddress) public onlyOwner {\n        paymentTokenAddress = _paymentTokenAddress;\n        paymentToken = IERC20(paymentTokenAddress);\n    }\n\n    function setSpinPrice(uint256 _spinPrice) public onlyOwner {\n        spinPrice = _spinPrice;\n    }\n\n    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {\n        treasuryAddress = _treasuryAddress;\n    }\n\n    function buySpin(address _toAddress, uint256 _amount) public ifNotPaused{\n        require(_amount > 0, \"QorpoBuySpin: amount must be greater than 0\");\n        require(paymentToken.transferFrom(msg.sender, treasuryAddress, spinPrice * _amount), \"QorpoBuySpin: transfer failed\");\n        // Since Spin is not on-chain asset, the assigement of Spin is done off-chain based on the emitted event\n        emit BuySpin(_toAddress, _amount);\n    }\n\n    function buySpinCustomPrice(address _toAddress, uint256 _amount, uint256 _customPrice) public ifNotPaused{\n        require(paymentToken.transferFrom(msg.sender, treasuryAddress, _customPrice * _amount), \"QorpoBuySpin: transfer failed\");\n         // Since Spin is not on-chain asset, the assigement of Spin is done off-chain based on the emitted event\n         // Check if user is eligible for custom price is also done off-chain and if not, spin will be not assigned\n        emit BuySpinCustomPrice(_toAddress, _amount, _customPrice);\n    }\n}"
    },
    "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the value of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the value of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves a `value` amount of tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 value) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the\n     * caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 value) external returns (bool);\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to` using the\n     * allowance mechanism. `value` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n}\n"
    },
    "src/utils/TokenAccessControl.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.7.0 <0.9.0;\n\ncontract TokenAccessControl {\n    bool public paused = false;\n    address public owner;\n    address public newContractOwner;\n    mapping(address => bool) public authorizedContracts;\n\n    event SetPause(bool pause);\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n    event AuthorizedUserSet(address indexed operator, bool approve);\n\n    constructor() {\n        owner = msg.sender;\n    }\n\n    modifier ifNotPaused() {\n        require(!paused, \"contract is paused\");\n        _;\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"caller is not an owner\");\n        _;\n    }\n\n    modifier onlyAuthorizedUser() {\n        require(\n            authorizedContracts[msg.sender],\n            \"caller is not an authorized user\"\n        );\n        _;\n    }\n\n    modifier onlyOwnerOrAuthorizedUser() {\n        require(\n            authorizedContracts[msg.sender] || msg.sender == owner,\n            \"caller is not an authorized user or an owner\"\n        );\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(owner, address(0));\n        owner = address(0);\n    }\n\n    function transferOwnership(address _newOwner) public onlyOwner {\n        require(_newOwner != address(0));\n        newContractOwner = _newOwner;\n    }\n\n    function acceptOwnership() public ifNotPaused {\n        require(msg.sender == newContractOwner);\n        emit OwnershipTransferred(owner, newContractOwner);\n        owner = newContractOwner;\n        newContractOwner = address(0);\n    }\n\n    function setAuthorizedUser(\n        address _operator,\n        bool _approve\n    ) public onlyOwner {\n        if (_approve) {\n            authorizedContracts[_operator] = true;\n        } else {\n            delete authorizedContracts[_operator];\n        }\n        emit AuthorizedUserSet(_operator, _approve);\n    }\n\n    function setPause(bool _paused) public onlyOwner {\n        paused = _paused;\n        if (paused) {\n            emit SetPause(paused);\n        }\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "forge-std/=lib/forge-std/src/",
      "@openzeppelin/=lib/openzeppelin-contracts/",
      "@layerzerolabs/=node_modules/@layerzerolabs/",
      "solidity-bytes-utils/=node_modules/solidity-bytes-utils/",
      "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
      "ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/"
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