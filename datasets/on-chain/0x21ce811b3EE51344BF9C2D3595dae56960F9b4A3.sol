{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 5000
    },
    "remappings": [],
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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"
    },
    "contracts/interfaces/external/bloom/IBloomPool.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\nimport \"@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol\";\n\ninterface IBloomPool is IERC20Metadata {\n    enum State {\n        Other,\n        Commit,\n        ReadyPreHoldSwap,\n        PendingPreHoldSwap,\n        Holding,\n        ReadyPostHoldSwap,\n        PendingPostHoldSwap,\n        EmergencyExit,\n        FinalWithdraw\n    }\n\n    function POOL_PHASE_END() external view returns (uint256);\n\n    function state() external view returns (State);\n\n    function getDistributionInfo()\n        external\n        view\n        returns (\n            uint128 borrowerDistribution,\n            uint128 totalBorrowerShares,\n            uint128 lenderDistribution,\n            uint128 totalLenderShares\n        );\n\n    function UNDERLYING_TOKEN() external view returns (IERC20Metadata);\n}\n"
    },
    "contracts/interfaces/external/bloom/IExchangeRateRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\ninterface IExchangeRateRegistry {\n    function getExchangeRate(address token) external view returns (uint256);\n}\n"
    },
    "contracts/interfaces/periphery/IOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\ninterface IOracle {\n    /**\n     * @notice Get USD (or equivalent) price of an asset\n     * @param token_ The address of asset\n     * @return _priceInUsd The USD price\n     */\n    function getPriceInUsd(address token_) external view returns (uint256 _priceInUsd);\n\n    /**\n     * @notice Get quote\n     * @param tokenIn_ The address of assetIn\n     * @param tokenOut_ The address of assetOut\n     * @param amountIn_ Amount of input token\n     * @return _amountOut Amount out\n     */\n    function quote(\n        address tokenIn_,\n        address tokenOut_,\n        uint256 amountIn_\n    ) external view returns (uint256 _amountOut);\n\n    /**\n     * @notice Get quote in USD (or equivalent) amount\n     * @param token_ The address of assetIn\n     * @param amountIn_ Amount of input token.\n     * @return amountOut_ Amount in USD\n     */\n    function quoteTokenToUsd(address token_, uint256 amountIn_) external view returns (uint256 amountOut_);\n\n    /**\n     * @notice Get quote from USD (or equivalent) amount to amount of token\n     * @param token_ The address of assetOut\n     * @param amountIn_ Input amount in USD\n     * @return _amountOut Output amount of token\n     */\n    function quoteUsdToToken(address token_, uint256 amountIn_) external view returns (uint256 _amountOut);\n}\n"
    },
    "contracts/interfaces/periphery/ITokenOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\ninterface ITokenOracle {\n    /**\n     * @notice Get USD (or equivalent) price of an asset\n     * @param token_ The address of asset\n     * @return _priceInUsd The USD price\n     */\n    function getPriceInUsd(address token_) external view returns (uint256 _priceInUsd);\n}\n"
    },
    "contracts/periphery/tokens/TBYOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\nimport \"../../interfaces/periphery/ITokenOracle.sol\";\nimport \"../../interfaces/periphery/IOracle.sol\";\nimport \"../../interfaces/external/bloom/IBloomPool.sol\";\nimport \"../../interfaces/external/bloom/IExchangeRateRegistry.sol\";\n\n/**\n * @title Oracle for TBY tokens\n */\ncontract TBYOracle is ITokenOracle {\n    uint256 public constant ONE_USD = 1e18;\n\n    IExchangeRateRegistry public immutable exchangeRateRegistry;\n\n    constructor(IExchangeRateRegistry exchangeRateRegistry_) {\n        exchangeRateRegistry = exchangeRateRegistry_;\n    }\n\n    /**\n     * Note: Until the maturity, we use the exchange rate to calculate TBY price\n     * When it enters the withdraw phase, exchange rate isn't accurate because:\n     * 1) Interest rate may vary and that could impact TBY price even after the maturity\n     * 2) After the maturity the actual TBY price is the redeemable USDC amount\n     */\n    function getPriceInUsd(address token_) external view returns (uint256) {\n        IBloomPool _tby = IBloomPool(token_);\n        IERC20Metadata _underlying = _tby.UNDERLYING_TOKEN(); // i.e., USDC\n        IOracle _masterOracle = IOracle(msg.sender);\n        uint256 _underlyingPrice = _masterOracle.getPriceInUsd(address(_underlying));\n\n        if (_tby.state() == IBloomPool.State.FinalWithdraw) {\n            (, , uint128 lenderDistribution, uint128 totalLenderShares) = _tby.getDistributionInfo();\n            uint256 _oneShare = 10 ** _tby.decimals();\n            uint256 _underlyingAmountPerShare = (_oneShare * lenderDistribution) / totalLenderShares;\n            return (_underlyingPrice * _underlyingAmountPerShare) / _underlying.decimals();\n        }\n\n        return (_underlyingPrice * exchangeRateRegistry.getExchangeRate(token_)) / ONE_USD;\n    }\n}\n"
    }
  }
}}