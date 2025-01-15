{{
  "language": "Solidity",
  "sources": {
    "contracts/interfaces/IDepositWithBeneficiary.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\n/// @title Interface for depositWithBeneficiary\ninterface IDepositWithBeneficiary {\n  /// @notice Make a token transfer that the *signer* is paying tokens but benefits are given to the *beneficiary*\n  /// @param token The contract address of the transferring token\n  /// @param amount The amount of the transfer\n  /// @param beneficiary The address that will receive benefits of this transfer\n  /// @param data Extra data passed to the contract\n  /// @return Returns true for a successful transfer.\n  function depositWithBeneficiary(address token, uint256 amount, address beneficiary, uint64 data)\n    payable external returns (bool);\n}\n"
    },
    "contracts/test/ForwardTokenContract.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"../interfaces/IERC20Minimal.sol\";\nimport \"../interfaces/IDepositWithBeneficiary.sol\";\n\ninterface IFormStakingPool {\n  function depositFor(address _token, address _for, uint256 _amount) external;\n  function depositETHFor(address _for) payable external;\n}\n\n/// @notice A sample of 3rd-party dapp that interacts with meson\n/// With `depositWithBeneficiary`, the meson contract will be able\n/// to deposit cross-chain'ed stablecoins to the 3rd-party dapp contract\n/// on behalf of the user. The user will receive the benefits corresponding\n/// to this deposit.\ncontract ForwardTokenToFormContract is IDepositWithBeneficiary {\n  address constant _formStakingPool = address(0xFa70Af4AF0Cc7cC4d767Ac6808C7E56375844D71);\n\n  function depositWithBeneficiary(\n    address token,\n    uint256 amount,\n    address beneficiary,\n    uint64 data\n  ) payable external override returns (bool) {\n    if (token == address(0)) {\n      IFormStakingPool(_formStakingPool).depositETHFor{value: amount}(beneficiary);\n    } else {\n      IERC20Minimal(token).transferFrom(msg.sender, address(this), amount);\n      IERC20Minimal(token).approve(_formStakingPool, amount);\n      IFormStakingPool(_formStakingPool).depositFor(token, beneficiary, amount);\n    }\n\n    return true;\n  }\n}\n"
    },
    "contracts/interfaces/IERC20Minimal.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.5.0;\n\n/// @title Minimal ERC20 interface for Uniswap\n/// @notice Contains a subset of the full ERC20 interface that is used in Uniswap V3\ninterface IERC20Minimal {\n  /// @notice Returns the balance of a token\n  /// @param account The account for which to look up the number of tokens it has, i.e. its balance\n  /// @return The number of tokens held by the account\n  function balanceOf(address account) external view returns (uint256);\n\n  /// @notice Transfers the amount of token from the `msg.sender` to the recipient\n  /// @param recipient The account that will receive the amount transferred\n  /// @param amount The number of tokens to send from the sender to the recipient\n  /// @return Returns true for a successful transfer, false for an unsuccessful transfer\n  function transfer(address recipient, uint256 amount) external returns (bool);\n\n  /// @notice Returns the current allowance given to a spender by an owner\n  /// @param owner The account of the token owner\n  /// @param spender The account of the token spender\n  /// @return The current allowance granted by `owner` to `spender`\n  function allowance(address owner, address spender) external view returns (uint256);\n\n  /// @notice Sets the allowance of a spender from the `msg.sender` to the value `amount`\n  /// @param spender The account which will be allowed to spend a given amount of the owners tokens\n  /// @param amount The amount of tokens allowed to be used by `spender`\n  /// @return Returns true for a successful approval, false for unsuccessful\n  function approve(address spender, uint256 amount) external returns (bool);\n\n  /// @notice Transfers `amount` tokens from `sender` to `recipient` up to the allowance given to the `msg.sender`\n  /// @param sender The account from which the transfer will be initiated\n  /// @param recipient The recipient of the transfer\n  /// @param amount The amount of the transfer\n  /// @return Returns true for a successful transfer, false for unsuccessful\n  function transferFrom(\n      address sender,\n      address recipient,\n      uint256 amount\n  ) external returns (bool);\n\n  /// @notice Event emitted when tokens are transferred from one address to another, either via `#transfer` or `#transferFrom`.\n  /// @param from The account from which the tokens were sent, i.e. the balance decreased\n  /// @param to The account to which the tokens were sent, i.e. the balance increased\n  /// @param value The amount of tokens that were transferred\n  event Transfer(address indexed from, address indexed to, uint256 value);\n\n  /// @notice Event emitted when the approval amount for the spender of a given owner's tokens changes.\n  /// @param owner The account that approved spending of its tokens\n  /// @param spender The account for which the spending allowance was modified\n  /// @param value The new allowance from the owner to the spender\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n}"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 100
    },
    "evmVersion": "istanbul",
    "viaIR": true,
    "metadata": {
      "bytecodeHash": "none"
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}