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
    "contracts/interfaces/core/IPriceProvider.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\ninterface IPriceProvider {\n    /**\n     * @notice Get USD (or equivalent) price of an asset\n     * @param token_ The address of asset\n     * @return _priceInUsd The USD price\n     * @return _lastUpdatedAt Last updated timestamp\n     */\n    function getPriceInUsd(address token_) external view returns (uint256 _priceInUsd, uint256 _lastUpdatedAt);\n\n    /**\n     * @notice Get quote\n     * @param tokenIn_ The address of assetIn\n     * @param tokenOut_ The address of assetOut\n     * @param amountIn_ Amount of input token\n     * @return _amountOut Amount out\n     * @return _tokenInLastUpdatedAt Last updated timestamp of `tokenIn_`\n     * @return _tokenOutLastUpdatedAt Last updated timestamp of `tokenOut_`\n     */\n    function quote(\n        address tokenIn_,\n        address tokenOut_,\n        uint256 amountIn_\n    )\n        external\n        view\n        returns (\n            uint256 _amountOut,\n            uint256 _tokenInLastUpdatedAt,\n            uint256 _tokenOutLastUpdatedAt\n        );\n\n    /**\n     * @notice Get quote in USD (or equivalent) amount\n     * @param token_ The address of assetIn\n     * @param amountIn_ Amount of input token.\n     * @return amountOut_ Amount in USD\n     * @return _lastUpdatedAt Last updated timestamp\n     */\n    function quoteTokenToUsd(address token_, uint256 amountIn_)\n        external\n        view\n        returns (uint256 amountOut_, uint256 _lastUpdatedAt);\n\n    /**\n     * @notice Get quote from USD (or equivalent) amount to amount of token\n     * @param token_ The address of assetOut\n     * @param amountIn_ Input amount in USD\n     * @return _amountOut Output amount of token\n     * @return _lastUpdatedAt Last updated timestamp\n     */\n    function quoteUsdToToken(address token_, uint256 amountIn_)\n        external\n        view\n        returns (uint256 _amountOut, uint256 _lastUpdatedAt);\n}\n"
    },
    "contracts/interfaces/periphery/IOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\ninterface IOracle {\n    /**\n     * @notice Get USD (or equivalent) price of an asset\n     * @param token_ The address of asset\n     * @return _priceInUsd The USD price\n     */\n    function getPriceInUsd(address token_) external view returns (uint256 _priceInUsd);\n\n    /**\n     * @notice Get quote\n     * @param tokenIn_ The address of assetIn\n     * @param tokenOut_ The address of assetOut\n     * @param amountIn_ Amount of input token\n     * @return _amountOut Amount out\n     */\n    function quote(\n        address tokenIn_,\n        address tokenOut_,\n        uint256 amountIn_\n    ) external view returns (uint256 _amountOut);\n\n    /**\n     * @notice Get quote in USD (or equivalent) amount\n     * @param token_ The address of assetIn\n     * @param amountIn_ Amount of input token.\n     * @return amountOut_ Amount in USD\n     */\n    function quoteTokenToUsd(address token_, uint256 amountIn_) external view returns (uint256 amountOut_);\n\n    /**\n     * @notice Get quote from USD (or equivalent) amount to amount of token\n     * @param token_ The address of assetOut\n     * @param amountIn_ Input amount in USD\n     * @return _amountOut Output amount of token\n     */\n    function quoteUsdToToken(address token_, uint256 amountIn_) external view returns (uint256 _amountOut);\n}\n"
    },
    "contracts/periphery/PullOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\nimport {IOracle} from \"../interfaces/periphery/IOracle.sol\";\nimport {IPriceProvider} from \"../interfaces/core/IPriceProvider.sol\";\n\n/**\n * @title Pull oracle\n * @dev This is the same as `MainOracle` but without stale period check because pull-oracle providers already do that\n */\ncontract PullOracle is IOracle {\n    IPriceProvider public immutable provider;\n\n    constructor(IPriceProvider provider_) {\n        provider = provider_;\n    }\n\n    /// @inheritdoc IOracle\n    function getPriceInUsd(address token_) public view virtual returns (uint256 _priceInUsd) {\n        (_priceInUsd, ) = provider.getPriceInUsd(token_);\n    }\n\n    /// @inheritdoc IOracle\n    function quote(\n        address tokenIn_,\n        address tokenOut_,\n        uint256 amountIn_\n    ) public view virtual returns (uint256 _amountOut) {\n        (_amountOut, , ) = provider.quote(tokenIn_, tokenOut_, amountIn_);\n    }\n\n    /// @inheritdoc IOracle\n    function quoteTokenToUsd(address token_, uint256 amountIn_) public view virtual returns (uint256 _amountOut) {\n        (_amountOut, ) = provider.quoteTokenToUsd(token_, amountIn_);\n    }\n\n    /// @inheritdoc IOracle\n    function quoteUsdToToken(address token_, uint256 amountIn_) public view virtual returns (uint256 _amountOut) {\n        (_amountOut, ) = provider.quoteUsdToToken(token_, amountIn_);\n    }\n}\n"
    }
  }
}}