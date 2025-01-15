// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

// src/contracts/access-control/LendingPoolRole.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== LendingPoolRole =========================
// ====================================================================
// Access control for the Lending Pool

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans

// Reviewer(s) / Contributor(s)
// Travis Moore: https://github.com/FortisFortuna
// Dennis: https://github.com/denett

abstract contract LendingPoolRole {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    LendingPool public lendingPool;

    /// @notice constructor
    /// @param _lendingPool Address of Lending Pool
    constructor(address payable _lendingPool) {
        lendingPool = LendingPool(_lendingPool);
    }

    // ==============================================================================
    // Configuration Setters
    // ==============================================================================

    /// @notice Sets a new Lending Pool
    /// @param _lendingPool Address for the new Lending Pool.
    function _setLendingPool(address payable _lendingPool) internal {
        emit SetLendingPool(address(lendingPool), _lendingPool);
        lendingPool = LendingPool(_lendingPool);
    }

    // ==============================================================================
    // Internal Checks
    // ==============================================================================

    /// @notice Checks if an address is the Lending Pool
    /// @param _address Address to test
    function _isLendingPool(address _address) internal view returns (bool) {
        return (_address == address(lendingPool));
    }

    /// @notice Reverts if the address is not the Lending Pool
    /// @param _address Address to test
    function _requireIsLendingPool(address _address) internal view {
        if (!_isLendingPool(_address)) {
            revert AddressIsNotLendingPool(address(lendingPool), _address);
        }
    }

    /// @notice Reverts if msg.sender is not the Lending Pool
    function _requireSenderIsLendingPool() internal view {
        _requireIsLendingPool(msg.sender);
    }

    // ==============================================================================
    // Events
    // ==============================================================================

    /// @notice The ```SetLendingPool``` event fires when the Lending Pool address changes
    /// @param oldLendingPool The old address
    /// @param newLendingPool The new address
    event SetLendingPool(address indexed oldLendingPool, address indexed newLendingPool);

    // ==============================================================================
    // Errors
    // ==============================================================================

    /// @notice Emitted when the test address is not the Lending Pool
    error AddressIsNotLendingPool(address lendingPoolAddress, address actualAddress);
}

// src/contracts/access-control/RedemptionQueueV2Role.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ======================== RedemptionQueueV2Role =======================
// ====================================================================
// Access control for the Frax Ether Redemption Queue

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett

abstract contract RedemptionQueueV2Role {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    FraxEtherRedemptionQueueV2 public redemptionQueue;

    /// @notice constructor
    /// @param _redemptionQueue Address of Redemption Queue
    constructor(address payable _redemptionQueue) {
        redemptionQueue = FraxEtherRedemptionQueueV2(_redemptionQueue);
    }

    // ==============================================================================
    // Configuration Setters
    // ==============================================================================

    /// @notice Sets a new Redemption Queue
    /// @param _redemptionQueue Address for the new Redemption Queue.
    function _setFraxEtherRedemptionQueueV2(address payable _redemptionQueue) internal {
        emit SetFraxEtherRedemptionQueueV2(address(redemptionQueue), _redemptionQueue);
        redemptionQueue = FraxEtherRedemptionQueueV2(_redemptionQueue);
    }

    // ==============================================================================
    // Internal Checks
    // ==============================================================================

    /// @notice Checks if an address is the Redemption Queue
    /// @param _address Address to test
    function _isFraxEtherRedemptionQueueV2(address _address) internal view returns (bool) {
        return (_address == address(redemptionQueue));
    }

    /// @notice Reverts if the address is not the Redemption Queue
    /// @param _address Address to test
    function _requireIsFraxEtherRedemptionQueueV2(address _address) internal view {
        if (!_isFraxEtherRedemptionQueueV2(_address)) {
            revert AddressIsNotFraxEtherRedemptionQueueV2(address(redemptionQueue), _address);
        }
    }

    /// @notice Reverts if msg.sender is not the Redemption Queue
    function _requireSenderIsFraxEtherRedemptionQueueV2() internal view {
        _requireIsFraxEtherRedemptionQueueV2(msg.sender);
    }

    // ==============================================================================
    // Events
    // ==============================================================================

    /// @notice The ```SetFraxEtherRedemptionQueueV2``` event fires when the Redemption Queue address changes
    /// @param oldFraxEtherRedemptionQueueV2 The old address
    /// @param newFraxEtherRedemptionQueueV2 The new address
    event SetFraxEtherRedemptionQueueV2(
        address indexed oldFraxEtherRedemptionQueueV2,
        address indexed newFraxEtherRedemptionQueueV2
    );

    // ==============================================================================
    // Errors
    // ==============================================================================

    /// @notice Emitted when the test address is not the Redemption Queue
    error AddressIsNotFraxEtherRedemptionQueueV2(address redemptionQueueAddress, address actualAddress);
}

// node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// node_modules/@openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// node_modules/@openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// node_modules/@openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// node_modules/@openzeppelin/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}

// node_modules/@openzeppelin/contracts/utils/math/SignedMath.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// node_modules/frax-standard-solidity/src/access-control/v2/OperatorRole.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== OperatorRole ===========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// Reviewers
// Dennis: https://github.com/denett
// Travis Moore: https://github.com/FortisFortuna

// ====================================================================

abstract contract OperatorRole {
    // ============================================================================================
    // Storage & Constructor
    // ============================================================================================

    /// @notice The current operator address
    address public operatorAddress;

    constructor(address _operatorAddress) {
        operatorAddress = _operatorAddress;
    }

    // ============================================================================================
    // Functions: Internal Actions
    // ============================================================================================

    /// @notice The ```OperatorTransferred``` event is emitted when the operator transfer is completed
    /// @param previousOperator The address of the previous operator
    /// @param newOperator The address of the new operator
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    /// @notice The ```_setOperator``` function sets the operator address
    /// @dev This function is to be implemented by a public function
    /// @param _newOperator The address of the new operator
    function _setOperator(address _newOperator) internal {
        emit OperatorTransferred(operatorAddress, _newOperator);
        operatorAddress = _newOperator;
    }

    // ============================================================================================
    // Functions: Internal Checks
    // ============================================================================================

    /// @notice The ```_isOperator``` function checks if _address is current operator address
    /// @param _address The address to check against the operator
    /// @return Whether or not msg.sender is current operator address
    function _isOperator(address _address) internal view returns (bool) {
        return _address == operatorAddress;
    }

    /// @notice The ```AddressIsNotOperator``` error is used for validation of the operatorAddress
    /// @param operatorAddress The expected operatorAddress
    /// @param actualAddress The actual operatorAddress
    error AddressIsNotOperator(address operatorAddress, address actualAddress);

    /// @notice The ```_requireIsOperator``` function reverts if _address is not current operator address
    /// @param _address The address to check against the operator
    function _requireIsOperator(address _address) internal view {
        if (!_isOperator(_address)) revert AddressIsNotOperator(operatorAddress, _address);
    }

    /// @notice The ```_requireSenderIsOperator``` function reverts if msg.sender is not current operator address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsOperator() internal view {
        _requireIsOperator(msg.sender);
    }
}

// node_modules/frax-standard-solidity/src/access-control/v2/PublicReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

// NOTE: This file has been modified from the original to make the _status an internal item so that it can be exposed by consumers.
// This allows us to prevent global reentrancy across different

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract PublicReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 internal _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// node_modules/frax-standard-solidity/src/access-control/v2/Timelock2Step.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== Timelock2Step ===========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// Reviewers
// Dennis: https://github.com/denett

// ====================================================================

/// @title Timelock2Step
/// @author Drake Evans (Frax Finance) https://github.com/drakeevans
/// @dev Inspired by OpenZeppelin's Ownable2Step contract
/// @notice  An abstract contract which contains 2-step transfer and renounce logic for a timelock address
abstract contract Timelock2Step {
    /// @notice The pending timelock address
    address public pendingTimelockAddress;

    /// @notice The current timelock address
    address public timelockAddress;

    constructor(address _timelockAddress) {
        timelockAddress = _timelockAddress;
    }

    // ============================================================================================
    // Functions: External Functions
    // ============================================================================================

    /// @notice The ```transferTimelock``` function initiates the timelock transfer
    /// @dev Must be called by the current timelock
    /// @param _newTimelock The address of the nominated (pending) timelock
    function transferTimelock(address _newTimelock) external virtual {
        _requireSenderIsTimelock();
        _transferTimelock(_newTimelock);
    }

    /// @notice The ```acceptTransferTimelock``` function completes the timelock transfer
    /// @dev Must be called by the pending timelock
    function acceptTransferTimelock() external virtual {
        _requireSenderIsPendingTimelock();
        _acceptTransferTimelock();
    }

    /// @notice The ```renounceTimelock``` function renounces the timelock after setting pending timelock to current timelock
    /// @dev Pending timelock must be set to current timelock before renouncing, creating a 2-step renounce process
    function renounceTimelock() external virtual {
        _requireSenderIsTimelock();
        _requireSenderIsPendingTimelock();
        _transferTimelock(address(0));
        _setTimelock(address(0));
    }

    // ============================================================================================
    // Functions: Internal Actions
    // ============================================================================================

    /// @notice The ```_transferTimelock``` function initiates the timelock transfer
    /// @dev This function is to be implemented by a public function
    /// @param _newTimelock The address of the nominated (pending) timelock
    function _transferTimelock(address _newTimelock) internal {
        pendingTimelockAddress = _newTimelock;
        emit TimelockTransferStarted(timelockAddress, _newTimelock);
    }

    /// @notice The ```_acceptTransferTimelock``` function completes the timelock transfer
    /// @dev This function is to be implemented by a public function
    function _acceptTransferTimelock() internal {
        pendingTimelockAddress = address(0);
        _setTimelock(msg.sender);
    }

    /// @notice The ```_setTimelock``` function sets the timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _newTimelock The address of the new timelock
    function _setTimelock(address _newTimelock) internal {
        emit TimelockTransferred(timelockAddress, _newTimelock);
        timelockAddress = _newTimelock;
    }

    // ============================================================================================
    // Functions: Internal Checks
    // ============================================================================================

    /// @notice The ```_isTimelock``` function checks if _address is current timelock address
    /// @param _address The address to check against the timelock
    /// @return Whether or not msg.sender is current timelock address
    function _isTimelock(address _address) internal view returns (bool) {
        return _address == timelockAddress;
    }

    /// @notice The ```_requireIsTimelock``` function reverts if _address is not current timelock address
    /// @param _address The address to check against the timelock
    function _requireIsTimelock(address _address) internal view {
        if (!_isTimelock(_address)) revert AddressIsNotTimelock(timelockAddress, _address);
    }

    /// @notice The ```_requireSenderIsTimelock``` function reverts if msg.sender is not current timelock address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsTimelock() internal view {
        _requireIsTimelock(msg.sender);
    }

    /// @notice The ```_isPendingTimelock``` function checks if the _address is pending timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _address The address to check against the pending timelock
    /// @return Whether or not _address is pending timelock address
    function _isPendingTimelock(address _address) internal view returns (bool) {
        return _address == pendingTimelockAddress;
    }

    /// @notice The ```_requireIsPendingTimelock``` function reverts if the _address is not pending timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _address The address to check against the pending timelock
    function _requireIsPendingTimelock(address _address) internal view {
        if (!_isPendingTimelock(_address)) revert AddressIsNotPendingTimelock(pendingTimelockAddress, _address);
    }

    /// @notice The ```_requirePendingTimelock``` function reverts if msg.sender is not pending timelock address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsPendingTimelock() internal view {
        _requireIsPendingTimelock(msg.sender);
    }

    // ============================================================================================
    // Functions: Events
    // ============================================================================================

    /// @notice The ```TimelockTransferStarted``` event is emitted when the timelock transfer is initiated
    /// @param previousTimelock The address of the previous timelock
    /// @param newTimelock The address of the new timelock
    event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);

    /// @notice The ```TimelockTransferred``` event is emitted when the timelock transfer is completed
    /// @param previousTimelock The address of the previous timelock
    /// @param newTimelock The address of the new timelock
    event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);

    // ============================================================================================
    // Functions: Errors
    // ============================================================================================

    /// @notice Emitted when timelock is transferred
    error AddressIsNotTimelock(address timelockAddress, address actualAddress);

    /// @notice Emitted when pending timelock is transferred
    error AddressIsNotPendingTimelock(address pendingTimelockAddress, address actualAddress);
}

// node_modules/solmate/src/utils/SSTORE2.sol

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1; // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.

    /*//////////////////////////////////////////////////////////////
                               WRITE LOGIC
    //////////////////////////////////////////////////////////////*/

    function write(bytes memory data) internal returns (address pointer) {
        // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        bytes memory creationCode = abi.encodePacked(
            //---------------------------------------------------------------------------------------------------------------//
            // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
            //---------------------------------------------------------------------------------------------------------------//
            // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
            // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
            // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
            // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
            // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
            // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
            // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
            // 0xf3    |  0xf3               | RETURN       |                                                                //
            //---------------------------------------------------------------------------------------------------------------//
            hex"60_0B_59_81_38_03_80_92_59_39_F3", // Returns all code in the contract except for the first 11 (0B in hex) bytes.
            runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
        );

        /// @solidity memory-safe-assembly
        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), "DEPLOYMENT_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                               READ LOGIC
    //////////////////////////////////////////////////////////////*/

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory) {
        start += DATA_OFFSET;

        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        require(pointer.code.length >= end, "OUT_OF_BOUNDS");

        return readBytecode(pointer, start, end - start);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}

// src/contracts/curve-amo/WhitelistedExecutor.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ======================== WhitelistedExecutor =======================
// ====================================================================
// Can send arbitratry calldata to a whitelisted target with a whitelisted selector
// Frax Finance: https://github.com/FraxFinance

abstract contract WhitelistedExecutor {
    /* ============================================= STATE VARIABLES ==================================================== */

    // Whitelisted Execute
    /// @notice The execution target contracts and their whitelist status
    mapping(address => bool) public executeTargets;

    /// @notice The selector's status for an execution target
    mapping(address => mapping(bytes4 => bool)) public executeSelectors;

    /* ====================================== RESTRICTED GOVERNANCE FUNCTIONS =========================================== */

    /// @notice Add / Remove an execution target address
    /// @param _targetAddress Target address
    /// @param _enabled Whether the target address as a whole is enabled or disabled
    function _setExecuteTarget(address _targetAddress, bool _enabled) internal {
        executeTargets[_targetAddress] = _enabled;

        emit SetExecuteTarget(_targetAddress, _enabled);
    }

    /// @notice Add / Remove a function selector for an execution target address
    /// @param _targetAddress Target address
    /// @param _selector The selector
    /// @param _enabled Whether the selector is enabled or disabled
    function _setExecuteSelector(address _targetAddress, bytes4 _selector, bool _enabled) internal {
        if (!executeTargets[_targetAddress]) revert UnauthorizedTarget();
        executeSelectors[_targetAddress][_selector] = _enabled;

        emit SetExecuteSelector(_targetAddress, _selector, _enabled);
    }

    /// @notice Whitelisted calls
    /// @param _to Target address
    /// @param _value ETH value transferred, if any
    /// @param _data The calldata
    function _whitelistedExecute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) internal returns (bool, bytes memory) {
        // Make sure the target is allowed
        if (!executeTargets[_to]) revert UnauthorizedTarget();

        // Extract the selector and make sure it is valid
        bytes4 selector = bytes4(_data[:4]);
        if (!executeSelectors[_to][selector]) revert UnauthorizedSelector();

        (bool success, bytes memory result) = _to.call{ value: _value }(_data);

        emit WhitelistedExecute(_to, _value, _data);

        return (success, result);
    }

    /* ================================================= ERRORS ========================================================= */

    /// @notice If the selector is not whitelisted
    error UnauthorizedSelector();

    /// @notice If the target address is not whitelisted
    error UnauthorizedTarget();

    /* ================================================= EVENTS ========================================================= */

    /// @notice The ```SetTarget``` event fires when a target address for the executor is added or removed
    /// @param _targetAddress The target address
    /// @param _enabled Whether the target is enabled or disabled
    event SetExecuteTarget(address _targetAddress, bool _enabled);

    /// @notice The ```SetOperator``` event fires when the operatorAddress is set
    /// @param _targetAddress The target address
    /// @param _selector The function selector
    /// @param _enabled Whether the target's specific selector is enabled or disabled
    event SetExecuteSelector(address _targetAddress, bytes4 _selector, bool _enabled);

    /// @notice The ```whitelistedExecute``` event fires when whitelistedExecute is called
    /// @param _to Target address
    /// @param _value ETH value transferred, if any
    /// @param _data The calldata
    event WhitelistedExecute(address _to, uint256 _value, bytes _data);
}

// src/contracts/curve-amo/interfaces/convex/IConvexBaseRewardPool.sol

interface IConvexBaseRewardPool {
    function addExtraReward(address _reward) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function clearExtraRewards() external;

    function currentRewards() external view returns (uint256);

    function donate(uint256 _amount) external returns (bool);

    function duration() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function extraRewards(uint256) external view returns (address);

    function extraRewardsLength() external view returns (uint256);

    function getReward() external returns (bool);

    function getReward(address _account, bool _claimExtras) external returns (bool);

    function historicalRewards() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function newRewardRatio() external view returns (uint256);

    function operator() external view returns (address);

    function periodFinish() external view returns (uint256);

    function pid() external view returns (uint256);

    function queueNewRewards(uint256 _rewards) external returns (bool);

    function queuedRewards() external view returns (uint256);

    function rewardManager() external view returns (address);

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewardToken() external view returns (address);

    function rewards(address) external view returns (uint256);

    function stake(uint256 _amount) external returns (bool);

    function stakeAll() external returns (bool);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function stakingToken() external view returns (address);

    function totalSupply() external view returns (uint256);

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external;

    function withdrawAllAndUnwrap(bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);
}

// src/contracts/curve-amo/interfaces/convex/IConvexBooster.sol

interface IConvexBooster {
    function FEE_DENOMINATOR() external view returns (uint256);

    function MaxFees() external view returns (uint256);

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns (bool);

    function claimRewards(uint256 _pid, address _gauge) external returns (bool);

    function crv() external view returns (address);

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns (bool);

    function depositAll(uint256 _pid, bool _stake) external returns (bool);

    function distributionAddressId() external view returns (uint256);

    function earmarkFees() external returns (bool);

    function earmarkIncentive() external view returns (uint256);

    function earmarkRewards(uint256 _pid) external returns (bool);

    function feeDistro() external view returns (address);

    function feeManager() external view returns (address);

    function feeToken() external view returns (address);

    function gaugeMap(address) external view returns (bool);

    function isShutdown() external view returns (bool);

    function lockFees() external view returns (address);

    function lockIncentive() external view returns (uint256);

    function lockRewards() external view returns (address);

    function minter() external view returns (address);

    function owner() external view returns (address);

    function platformFee() external view returns (uint256);

    function poolInfo(
        uint256
    )
        external
        view
        returns (address lptoken, address token, address gauge, address crvRewards, address stash, bool shutdown);

    function poolLength() external view returns (uint256);

    function poolManager() external view returns (address);

    function registry() external view returns (address);

    function rewardArbitrator() external view returns (address);

    function rewardClaimed(uint256 _pid, address _address, uint256 _amount) external returns (bool);

    function rewardFactory() external view returns (address);

    function setArbitrator(address _arb) external;

    function setFactories(address _rfactory, address _sfactory, address _tfactory) external;

    function setFeeInfo() external;

    function setFeeManager(address _feeM) external;

    function setFees(uint256 _lockFees, uint256 _stakerFees, uint256 _callerFees, uint256 _platform) external;

    function setGaugeRedirect(uint256 _pid) external returns (bool);

    function setOwner(address _owner) external;

    function setPoolManager(address _poolM) external;

    function setRewardContracts(address _rewards, address _stakerRewards) external;

    function setTreasury(address _treasury) external;

    function setVoteDelegate(address _voteDelegate) external;

    function shutdownPool(uint256 _pid) external returns (bool);

    function shutdownSystem() external;

    function staker() external view returns (address);

    function stakerIncentive() external view returns (uint256);

    function stakerRewards() external view returns (address);

    function stashFactory() external view returns (address);

    function tokenFactory() external view returns (address);

    function treasury() external view returns (address);

    function vote(uint256 _voteId, address _votingAddress, bool _support) external returns (bool);

    function voteDelegate() external view returns (address);

    function voteGaugeWeight(address[] memory _gauge, uint256[] memory _weight) external returns (bool);

    function voteOwnership() external view returns (address);

    function voteParameter() external view returns (address);

    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

    function withdrawAll(uint256 _pid) external returns (bool);

    function withdrawTo(uint256 _pid, uint256 _amount, address _to) external returns (bool);
}

// src/contracts/curve-amo/interfaces/convex/IConvexClaimZap.sol

interface IConvexClaimZap {
    function chefRewards() external view returns (address);

    function claimRewards(
        address[] calldata rewardContracts,
        uint256[] calldata chefIds,
        bool claimCvx,
        bool claimCvxStake,
        bool claimcvxCrv,
        uint256 depositCrvMaxAmount,
        uint256 depositCvxMaxAmount
    ) external;

    function crv() external view returns (address);

    function crvDeposit() external view returns (address);

    function cvx() external view returns (address);

    function cvxCrv() external view returns (address);

    function cvxCrvRewards() external view returns (address);

    function cvxRewards() external view returns (address);

    function owner() external view returns (address);

    function setApprovals() external;

    function setChefRewards(address _rewards) external;
}

// src/contracts/curve-amo/interfaces/convex/IConvexFxsBooster.sol

interface IConvexFxsBooster {
    function acceptPendingOwner() external;

    function addPool(address _implementation, address _stakingAddress, address _stakingToken) external;

    function addProxyOwner(address _proxy, address _owner) external;

    function castVote(address _votingContract, uint256 _proposalId, bool _support) external;

    function checkpointFeeRewards(address _distroContract) external;

    function claimFees(address _distroContract, address _token) external;

    function claimOperatorRoles() external;

    function createVault(uint256 _pid) external returns (address);

    function deactivatePool(uint256 _pid) external;

    function feeClaimMap(address, address) external view returns (bool);

    function feeQueue() external view returns (address);

    function feeRegistry() external view returns (address);

    function feeclaimer() external view returns (address);

    function fxs() external view returns (address);

    function isShutdown() external view returns (bool);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function poolManager() external view returns (address);

    function poolRegistry() external view returns (address);

    function proxy() external view returns (address);

    function proxyOwners(address) external view returns (address);

    function recoverERC20(address _tokenAddress, uint256 _tokenAmount, address _withdrawTo) external;

    function recoverERC20FromProxy(address _tokenAddress, uint256 _tokenAmount, address _withdrawTo) external;

    function rewardManager() external view returns (address);

    function setDelegate(address _delegateContract, address _delegate, bytes32 _space) external;

    function setFeeClaimPair(address _claimAddress, address _token, bool _active) external;

    function setFeeClaimer(address _claimer) external;

    function setFeeQueue(address _queue) external;

    function setOnChainDelegate(address _delegateContract, address _delegate) external;

    function setPendingOwner(address _po) external;

    function setPoolFeeDeposit(address _deposit) external;

    function setPoolFees(uint256 _cvxfxs, uint256 _cvx, uint256 _platform) external;

    function setPoolManager(address _pmanager) external;

    function setPoolRewardImplementation(address _impl) external;

    function setRewardActiveOnCreation(bool _active) external;

    function setRewardManager(address _rmanager) external;

    function setVeFXSProxy(address _vault, address _newproxy) external;

    function shutdownSystem() external;

    function voteDelegate() external view returns (address);

    function voteGaugeWeight(address _controller, address[] memory _gauge, uint256[] memory _weight) external;
}

// src/contracts/curve-amo/interfaces/convex/IFxsPersonalVault.sol

interface IFxsPersonalVault {
    function FEE_DENOMINATOR() external view returns (uint256);

    function changeRewards(address _rewardsAddress) external;

    function checkpointRewards() external;

    function convexCurveBooster() external view returns (address);

    function convexDepositToken() external view returns (address);

    function crv() external view returns (address);

    function curveLpToken() external view returns (address);

    function cvx() external view returns (address);

    function earned() external view returns (address[] memory token_addresses, uint256[] memory total_earned);

    function feeRegistry() external view returns (address);

    function fxs() external view returns (address);

    function getReward() external;

    function getReward(bool _claim, address[] memory _rewardTokenList) external;

    function getReward(bool _claim) external;

    function initialize(
        address _owner,
        address _stakingAddress,
        address _stakingToken,
        address _rewardsAddress
    ) external;

    function lockAdditional(bytes32 _kek_id, uint256 _addl_liq) external;

    function lockAdditionalConvexToken(bytes32 _kek_id, uint256 _addl_liq) external;

    function lockAdditionalCurveLp(bytes32 _kek_id, uint256 _addl_liq) external;

    function lockLonger(bytes32 _kek_id, uint256 new_ending_ts) external;

    function owner() external view returns (address);

    function poolRegistry() external view returns (address);

    function rewards() external view returns (address);

    function setVeFXSProxy(address _proxy) external;

    function stakeLocked(uint256 _liquidity, uint256 _secs) external returns (bytes32 kek_id);

    function stakeLockedConvexToken(uint256 _liquidity, uint256 _secs) external returns (bytes32 kek_id);

    function stakeLockedCurveLp(uint256 _liquidity, uint256 _secs) external returns (bytes32 kek_id);

    function stakingAddress() external view returns (address);

    function stakingToken() external view returns (address);

    function usingProxy() external view returns (address);

    function vaultType() external pure returns (uint8);

    function vaultVersion() external pure returns (uint256);

    function vefxsProxy() external view returns (address);

    function withdrawLocked(bytes32 _kek_id) external;

    function withdrawLockedAndUnwrap(bytes32 _kek_id) external;
}

// src/contracts/curve-amo/interfaces/convex/IVirtualBalanceRewardPool.sol

interface IVirtualBalanceRewardPool {
    function balanceOf(address account) external view returns (uint256);

    function currentRewards() external view returns (uint256);

    function deposits() external view returns (address);

    function donate(uint256 _amount) external returns (bool);

    function duration() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getReward() external;

    function getReward(address _account) external;

    function historicalRewards() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function newRewardRatio() external view returns (uint256);

    function operator() external view returns (address);

    function periodFinish() external view returns (uint256);

    function queueNewRewards(uint256 _rewards) external;

    function queuedRewards() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewardToken() external view returns (address);

    function rewards(address) external view returns (uint256);

    function stake(address _account, uint256 amount) external;

    function totalSupply() external view returns (uint256);

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function withdraw(address _account, uint256 amount) external;
}

// src/contracts/curve-amo/interfaces/convex/IcvxRewardPool.sol

interface IcvxRewardPool {
    function FEE_DENOMINATOR() external view returns (uint256);

    function addExtraReward(address _reward) external;

    function balanceOf(address account) external view returns (uint256);

    function clearExtraRewards() external;

    function crvDeposits() external view returns (address);

    function currentRewards() external view returns (uint256);

    function cvxCrvRewards() external view returns (address);

    function cvxCrvToken() external view returns (address);

    function donate(uint256 _amount) external returns (bool);

    function duration() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function extraRewards(uint256) external view returns (address);

    function extraRewardsLength() external view returns (uint256);

    function getReward(bool _stake) external;

    function getReward(address _account, bool _claimExtras, bool _stake) external;

    function historicalRewards() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function newRewardRatio() external view returns (uint256);

    function operator() external view returns (address);

    function periodFinish() external view returns (uint256);

    function queueNewRewards(uint256 _rewards) external;

    function queuedRewards() external view returns (uint256);

    function rewardManager() external view returns (address);

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewardToken() external view returns (address);

    function rewards(address) external view returns (uint256);

    function stake(uint256 _amount) external;

    function stakeAll() external;

    function stakeFor(address _for, uint256 _amount) external;

    function stakingToken() external view returns (address);

    function totalSupply() external view returns (uint256);

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function withdraw(uint256 _amount, bool claim) external;

    function withdrawAll(bool claim) external;
}

// src/contracts/curve-amo/interfaces/curve/I2PoolNoLendingNG.sol

interface I2PoolNoLendingNG {
    function initialize(
        string memory _name,
        string memory _symbol,
        address[4] memory _coins,
        uint256[4] memory _rate_multipliers,
        uint256 _A,
        uint256 _fee
    ) external;

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (bool);

    function last_price() external view returns (uint256);

    function ema_price() external view returns (uint256);

    function stored_rates() external view returns (uint256[2] memory);

    function balances(uint256 i) external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function get_p() external view returns (uint256);

    function price_oracle() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external returns (uint256);

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver) external returns (uint256);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[2] memory _min_amounts
    ) external returns (uint256[2] memory);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[2] memory _min_amounts,
        address _receiver
    ) external returns (uint256[2] memory);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount
    ) external returns (uint256);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount,
        address _receiver
    ) external returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received,
        address _receiver
    ) external returns (uint256);

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function stop_ramp_A() external;

    function withdraw_admin_fees() external;

    function commit_new_fee(uint256 _new_fee) external;

    function apply_new_fee() external;

    function set_ma_exp_time(uint256 _ma_exp_time) external;

    function set_oracle(bytes4 _method_id, address _oracle) external;

    function version() external view returns (string memory);

    function coins(uint256 arg0) external view returns (address);

    function admin_balances(uint256 arg0) external view returns (uint256);

    function fee() external view returns (uint256);

    function future_fee() external view returns (uint256);

    function admin_action_deadline() external view returns (uint256);

    function initial_A() external view returns (uint256);

    function future_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    function oracle_method() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address arg0) external view returns (uint256);

    function allowance(address arg0, address arg1) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address arg0) external view returns (uint256);

    function ma_exp_time() external view returns (uint256);

    function ma_last_time() external view returns (uint256);
}

// src/contracts/curve-amo/interfaces/curve/IMinCurvePool.sol

interface IMinCurvePool {
    function get_virtual_price() external view returns (uint256);

    function coins(uint256 arg0) external view returns (address);

    function balances(uint256 arg0) external view returns (uint256);

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

    function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount) external;

    function remove_liquidity(uint256 _burn_amount, uint256[2] memory _min_amounts) external;

    function remove_liquidity(uint256 _burn_amount, uint256[3] memory _min_amounts) external;

    // USD Pools
    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);

    function calc_token_amount(uint256[] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

    function remove_liquidity_one_coin(uint256 _burn_amount, int128 i, uint256 _min_received) external;

    // function remove_liquidity_one_coin ( uint256 _burn_amount, int128 i, uint256 _min_received ) external returns ( uint256 );
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;

    // metapool
    function get_dy(int128 i, int128 j, uint256 dx, uint256[] memory _balances) external view returns (uint256);

    // Crypto Pool
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns (uint256);

    function price_oracle() external view returns (uint256);

    function lp_price() external view returns (uint256);

    function calc_token_amount(uint256[] memory _amounts) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i) external view returns (uint256);

    function remove_liquidity_one_coin(uint256 token_amount, uint256 i, uint256 min_amount) external returns (uint256);

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external returns (uint256);
}

// src/contracts/curve-amo/interfaces/curve/IPool2Crypto.sol

// Volatile Pool for two crypto assets, which may or may not be LSDs
// Universal implementation which can use both ETH and ERC20s
// Example ankrETH/frxETH
// Pool: https://etherscan.io/address/0x41ea4045de2676727883aa0b4e43d7e32261f559#code
// LP: https://etherscan.io/address/0xa8e14f03124ea156a4fc416537c82ff91a647d50
// [0]: ankrETH, [1]: frxETH
// Convex Vault (BaseRewardPool): 0xc18695D5824C49cF50E054953B3A5910c45597A0

interface IPool2Crypto {
    function A() external view returns (uint256);

    function D() external view returns (uint256);

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns (uint256);

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount, bool use_eth) external returns (uint256);

    function add_liquidity(
        uint256[2] memory amounts,
        uint256 min_mint_amount,
        bool use_eth,
        address receiver
    ) external returns (uint256);

    function adjustment_step() external view returns (uint256);

    function admin_actions_deadline() external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function allowed_extra_profit() external view returns (uint256);

    function apply_new_parameters() external;

    function balances(uint256 arg0) external view returns (uint256);

    function calc_token_amount(uint256[2] memory amounts) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);

    function claim_admin_fees() external;

    function coins(uint256 arg0) external view returns (address);

    function commit_new_parameters(
        uint256 _new_mid_fee,
        uint256 _new_out_fee,
        uint256 _new_admin_fee,
        uint256 _new_fee_gamma,
        uint256 _new_allowed_extra_profit,
        uint256 _new_adjustment_step,
        uint256 _new_ma_half_time
    ) external;

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external returns (uint256);

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy,
        bool use_eth,
        address receiver
    ) external returns (uint256);

    function exchange_extended(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy,
        bool use_eth,
        address sender,
        address receiver,
        bytes32 cb
    ) external returns (uint256);

    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function exchange_underlying(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);

    function factory() external view returns (address);

    function fee() external view returns (uint256);

    function fee_gamma() external view returns (uint256);

    function future_A_gamma() external view returns (uint256);

    function future_A_gamma_time() external view returns (uint256);

    function future_adjustment_step() external view returns (uint256);

    function future_admin_fee() external view returns (uint256);

    function future_allowed_extra_profit() external view returns (uint256);

    function future_fee_gamma() external view returns (uint256);

    function future_ma_half_time() external view returns (uint256);

    function future_mid_fee() external view returns (uint256);

    function future_out_fee() external view returns (uint256);

    function gamma() external view returns (uint256);

    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function initial_A_gamma() external view returns (uint256);

    function initial_A_gamma_time() external view returns (uint256);

    function initialize(
        uint256 A,
        uint256 gamma,
        uint256 mid_fee,
        uint256 out_fee,
        uint256 allowed_extra_profit,
        uint256 fee_gamma,
        uint256 adjustment_step,
        uint256 admin_fee,
        uint256 ma_half_time,
        uint256 initial_price,
        address _token,
        address[2] memory _coins,
        uint256 _precisions
    ) external;

    function last_prices() external view returns (uint256);

    function last_prices_timestamp() external view returns (uint256);

    function lp_price() external view returns (uint256);

    function ma_half_time() external view returns (uint256);

    function mid_fee() external view returns (uint256);

    function out_fee() external view returns (uint256);

    function price_oracle() external view returns (uint256);

    function price_scale() external view returns (uint256);

    function ramp_A_gamma(uint256 future_A, uint256 future_gamma, uint256 future_time) external;

    function remove_liquidity(uint256 _amount, uint256[2] memory min_amounts) external;

    function remove_liquidity(uint256 _amount, uint256[2] memory min_amounts, bool use_eth) external;

    function remove_liquidity(uint256 _amount, uint256[2] memory min_amounts, bool use_eth, address receiver) external;

    function remove_liquidity_one_coin(uint256 token_amount, uint256 i, uint256 min_amount) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 token_amount,
        uint256 i,
        uint256 min_amount,
        bool use_eth
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 token_amount,
        uint256 i,
        uint256 min_amount,
        bool use_eth,
        address receiver
    ) external returns (uint256);

    function revert_new_parameters() external;

    function stop_ramp_A_gamma() external;

    function token() external view returns (address);

    function virtual_price() external view returns (uint256);

    function xcp_profit() external view returns (uint256);

    function xcp_profit_a() external view returns (uint256);
}

// src/contracts/curve-amo/interfaces/curve/IPool2LSDStable.sol

// Stable Pool for two LSDs
// Example stETH/frxETH
// Pool: https://etherscan.io/address/0x4d9f9d15101eec665f77210cb999639f760f831e#code
// LP: https://etherscan.io/address/0x4d9f9d15101eec665f77210cb999639f760f831e#code
// [0]: stETH, [1]: frxETH
// Convex Vault (BaseRewardPool): 0xC3D0B8170E105d6476fE407934492930CAc3BDAC

interface IPool2LSDStable {
    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);

    function admin_balances(uint256 arg0) external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function allowance(address arg0, address arg1) external view returns (uint256);

    function approve(address _spender, uint256 _value) external returns (bool);

    function balanceOf(address arg0) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);

    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);

    function coins(uint256 arg0) external view returns (address);

    function decimals() external view returns (uint256);

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external returns (uint256);

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver) external returns (uint256);

    function fee() external view returns (uint256);

    function future_A() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    function get_balances() external view returns (uint256[2] memory);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function initial_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function initialize(
        string memory _name,
        string memory _symbol,
        address[4] memory _coins,
        uint256[4] memory _rate_multipliers,
        uint256 _A,
        uint256 _fee
    ) external;

    function name() external view returns (string memory);

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[2] memory _min_amounts
    ) external returns (uint256[2] memory);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[2] memory _min_amounts,
        address _receiver
    ) external returns (uint256[2] memory);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount
    ) external returns (uint256);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount,
        address _receiver
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received,
        address _receiver
    ) external returns (uint256);

    function stop_ramp_A() external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function withdraw_admin_fees() external;
}

// src/contracts/curve-amo/interfaces/curve/IPoolLSDETH.sol

// Pool for an LSD and ETH
// Example frxETH/ETH
// Pool: https://etherscan.io/address/0xa1f8a6807c402e4a15ef4eba36528a3fed24e577#code
// LP: https://etherscan.io/address/0xf43211935c781d5ca1a41d2041f397b8a7366c7a
// [0]: ETH, [1]: frxETH
// Convex Booster: 0xF403C135812408BFbE8713b5A23a04b3D48AAE31
// Convex BaseRewardPool: 0xbD5445402B0a287cbC77cb67B2a52e2FC635dce4
// Convex PID: 36
// Curve PID: 128

interface IPoolLSDETH {
    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external payable returns (uint256);

    function admin_actions_deadline() external view returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function apply_new_fee() external;

    function apply_transfer_ownership() external;

    function balances(uint256 arg0) external view returns (uint256);

    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

    function coins(uint256 arg0) external view returns (address);

    function commit_new_fee(uint256 _new_fee, uint256 _new_admin_fee) external;

    function commit_transfer_ownership(address _owner) external;

    function donate_admin_fees() external;

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external payable returns (uint256);

    function fee() external view returns (uint256);

    function future_A() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    function future_admin_fee() external view returns (uint256);

    function future_fee() external view returns (uint256);

    function future_owner() external view returns (address);

    function get_dy(int128 i, int128 j, uint256 _dx) external view returns (uint256);

    function get_p() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function initial_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function kill_me() external;

    function lp_token() external view returns (address);

    function ma_exp_time() external view returns (uint256);

    function ma_last_time() external view returns (uint256);

    function owner() external view returns (address);

    function price_oracle() external view returns (uint256);

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function remove_liquidity(uint256 _amount, uint256[2] memory _min_amounts) external returns (uint256[2] memory);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount
    ) external returns (uint256);

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 _min_amount) external returns (uint256);

    function revert_new_parameters() external;

    function revert_transfer_ownership() external;

    function set_ma_exp_time(uint256 _ma_exp_time) external;

    function stop_ramp_A() external;

    function transfer_ownership_deadline() external view returns (uint256);

    function unkill_me() external;

    function withdraw_admin_fees() external;
}

// src/contracts/curve-amo/interfaces/curve/IstETHETH.sol

interface IstETHETH {
    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns (uint256);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function remove_liquidity(uint256 _amount, uint256[2] memory _min_amounts) external returns (uint256[2] memory);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount
    ) external returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 _min_amount) external returns (uint256);

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function stop_ramp_A() external;

    function commit_new_fee(uint256 new_fee, uint256 new_admin_fee) external;

    function apply_new_fee() external;

    function revert_new_parameters() external;

    function commit_transfer_ownership(address _owner) external;

    function apply_transfer_ownership() external;

    function revert_transfer_ownership() external;

    function withdraw_admin_fees() external;

    function donate_admin_fees() external;

    function kill_me() external;

    function unkill_me() external;

    function coins(uint256 arg0) external view returns (address);

    function admin_balances(uint256 arg0) external view returns (uint256);

    function fee() external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function owner() external view returns (address);

    function lp_token() external view returns (address);

    function initial_A() external view returns (uint256);

    function future_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    function admin_actions_deadline() external view returns (uint256);

    function transfer_ownership_deadline() external view returns (uint256);

    function future_fee() external view returns (uint256);

    function future_admin_fee() external view returns (uint256);

    function future_owner() external view returns (address);
}

// src/contracts/curve-amo/interfaces/frax/IFraxFarm.sol

interface IFraxFarm {
    struct LockedStake {
        bytes32 kek_id;
        uint256 start_timestamp;
        uint256 liquidity;
        uint256 ending_timestamp;
        uint256 lock_multiplier; // 6 decimals of precision. 1x = 1000000
    }

    function acceptOwnership() external;

    function calcCurCombinedWeight(
        address account
    ) external view returns (uint256 old_combined_weight, uint256 new_vefxs_multiplier, uint256 new_combined_weight);

    function calcCurrLockMultiplier(
        address account,
        uint256 stake_idx
    ) external view returns (uint256 midpoint_lock_multiplier);

    function changeTokenManager(address reward_token_address, address new_manager_address) external;

    function combinedWeightOf(address account) external view returns (uint256);

    function curvePool() external view returns (address);

    function curveToken() external view returns (address);

    function earned(address account) external view returns (uint256[] memory new_earned);

    function fraxPerLPStored() external view returns (uint256);

    function fraxPerLPToken() external view returns (uint256);

    function getAllRewardTokens() external view returns (address[] memory);

    function getProxyFor(address addr) external view returns (address);

    function getReward(address destination_address) external returns (uint256[] memory);

    function getReward2(address destination_address, bool claim_extra_too) external returns (uint256[] memory);

    function getRewardExtraLogic(address destination_address) external;

    function getRewardForDuration() external view returns (uint256[] memory rewards_per_duration_arr);

    function isTokenManagerFor(address caller_addr, address reward_token_addr) external view returns (bool);

    function lastRewardClaimTime(address) external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function lockAdditional(bytes32 kek_id, uint256 addl_liq) external;

    function lockLonger(bytes32 kek_id, uint256 new_ending_ts) external;

    function lockMultiplier(uint256 secs) external view returns (uint256);

    function lock_max_multiplier() external view returns (uint256);

    function lock_time_for_max_multiplier() external view returns (uint256);

    function lock_time_min() external view returns (uint256);

    function lockedLiquidityOf(address account) external view returns (uint256);

    function lockedStakes(
        address,
        uint256
    )
        external
        view
        returns (
            bytes32 kek_id,
            uint256 start_timestamp,
            uint256 liquidity,
            uint256 ending_timestamp,
            uint256 lock_multiplier
        );

    function lockedStakesOf(address account) external view returns (LockedStake[] memory);

    function lockedStakesOfLength(address account) external view returns (uint256);

    function maxLPForMaxBoost(address account) external view returns (uint256);

    function minVeFXSForMaxBoost(address account) external view returns (uint256);

    function minVeFXSForMaxBoostProxy(address proxy_address) external view returns (uint256);

    function nominateNewOwner(address _owner) external;

    function nominatedOwner() external view returns (address);

    function owner() external view returns (address);

    function periodFinish() external view returns (uint256);

    function proxyStakedFrax(address proxy_address) external view returns (uint256);

    function proxyToggleStaker(address staker_address) external;

    function proxy_lp_balances(address) external view returns (uint256);

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

    function rewardManagers(address) external view returns (address);

    function rewardRates(uint256 token_idx) external view returns (uint256 rwd_rate);

    function rewardTokenAddrToIdx(address) external view returns (uint256);

    function rewardsDuration() external view returns (uint256);

    function rewardsPerToken() external view returns (uint256[] memory newRewardsPerTokenStored);

    function setMiscVariables(uint256[6] memory _misc_vars) external;

    function setPauses(
        bool _stakingPaused,
        bool _withdrawalsPaused,
        bool _rewardsCollectionPaused,
        bool _collectRewardsOnWithdrawalPaused
    ) external;

    function setRewardVars(
        address reward_token_address,
        uint256 _new_rate,
        address _gauge_controller_address,
        address _rewards_distributor_address
    ) external;

    function stakeLocked(uint256 liquidity, uint256 secs) external returns (bytes32);

    function stakerSetVeFXSProxy(address proxy_address) external;

    function staker_designated_proxies(address) external view returns (address);

    function stakesUnlocked() external view returns (bool);

    function stakingToken() external view returns (address);

    function sync() external;

    function sync_gauge_weights(bool force_update) external;

    function toggleValidVeFXSProxy(address _proxy_addr) external;

    function totalCombinedWeight() external view returns (uint256);

    function totalLiquidityLocked() external view returns (uint256);

    function unlockStakes() external;

    function userStakedFrax(address account) external view returns (uint256);

    function veFXSMultiplier(address account) external view returns (uint256 vefxs_multiplier);

    function vefxs_boost_scale_factor() external view returns (uint256);

    function vefxs_max_multiplier() external view returns (uint256);

    function vefxs_per_frax_for_max_boost() external view returns (uint256);

    function withdrawLocked(bytes32 kek_id, address destination_address, bool claim_rewards) external returns (uint256);
}

// src/contracts/curve-amo/interfaces/frax/IFrxEthEthCurvePool.sol

// solhint-disable

interface IFrxEthEthCurvePool {
    event AddLiquidity(
        address indexed provider,
        uint256[2] token_amounts,
        uint256[2] fees,
        uint256 invariant,
        uint256 token_supply
    );
    event CommitNewAdmin(uint256 indexed deadline, address indexed admin);
    event CommitNewFee(uint256 indexed deadline, uint256 fee, uint256 admin_fee);
    event NewAdmin(address indexed admin);
    event NewFee(uint256 fee, uint256 admin_fee);
    event RampA(uint256 old_A, uint256 new_A, uint256 initial_time, uint256 future_time);
    event RemoveLiquidity(address indexed provider, uint256[2] token_amounts, uint256[2] fees, uint256 token_supply);
    event RemoveLiquidityImbalance(
        address indexed provider,
        uint256[2] token_amounts,
        uint256[2] fees,
        uint256 invariant,
        uint256 token_supply
    );
    event RemoveLiquidityOne(address indexed provider, uint256 token_amount, uint256 coin_amount, uint256 token_supply);
    event StopRampA(uint256 A, uint256 t);
    event TokenExchange(
        address indexed buyer,
        int128 sold_id,
        uint256 tokens_sold,
        int128 bought_id,
        uint256 tokens_bought
    );

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external payable returns (uint256);

    function admin_actions_deadline() external view returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function apply_new_fee() external;

    function apply_transfer_ownership() external;

    function balances(uint256 arg0) external view returns (uint256);

    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

    function coins(uint256 arg0) external view returns (address);

    function commit_new_fee(uint256 _new_fee, uint256 _new_admin_fee) external;

    function commit_transfer_ownership(address _owner) external;

    function donate_admin_fees() external;

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external payable returns (uint256);

    function fee() external view returns (uint256);

    function future_A() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    function future_admin_fee() external view returns (uint256);

    function future_fee() external view returns (uint256);

    function future_owner() external view returns (address);

    function get_dy(int128 i, int128 j, uint256 _dx) external view returns (uint256);

    function get_p() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function initial_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function kill_me() external;

    function lp_token() external view returns (address);

    function ma_exp_time() external view returns (uint256);

    function ma_last_time() external view returns (uint256);

    function owner() external view returns (address);

    function price_oracle() external view returns (uint256);

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function remove_liquidity(uint256 _amount, uint256[2] memory _min_amounts) external returns (uint256[2] memory);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount
    ) external returns (uint256);

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 _min_amount) external returns (uint256);

    function revert_new_parameters() external;

    function revert_transfer_ownership() external;

    function set_ma_exp_time(uint256 _ma_exp_time) external;

    function stop_ramp_A() external;

    function transfer_ownership_deadline() external view returns (uint256);

    function unkill_me() external;

    function withdraw_admin_fees() external;
}

// src/contracts/curve-amo/interfaces/frax/ISfrxEthUsdDualOracle.sol

interface ISfrxEthUsdDualOracle {
    function BASE_TOKEN_0() external view returns (address);
    function BASE_TOKEN_0_DECIMALS() external view returns (uint256);
    function BASE_TOKEN_1() external view returns (address);
    function BASE_TOKEN_1_DECIMALS() external view returns (uint256);
    function CURVE_POOL_EMA_PRICE_ORACLE() external view returns (address);
    function CURVE_POOL_EMA_PRICE_ORACLE_PRECISION() external view returns (uint256);
    function ETH_USD_CHAINLINK_FEED_ADDRESS() external view returns (address);
    function ETH_USD_CHAINLINK_FEED_DECIMALS() external view returns (uint8);
    function ETH_USD_CHAINLINK_FEED_PRECISION() external view returns (uint256);
    function FRAX_USD_CHAINLINK_FEED_ADDRESS() external view returns (address);
    function FRAX_USD_CHAINLINK_FEED_DECIMALS() external view returns (uint8);
    function FRAX_USD_CHAINLINK_FEED_PRECISION() external view returns (uint256);
    function NORMALIZATION_0() external view returns (int256);
    function NORMALIZATION_1() external view returns (int256);
    function ORACLE_PRECISION() external view returns (uint256);
    function QUOTE_TOKEN_0() external view returns (address);
    function QUOTE_TOKEN_0_DECIMALS() external view returns (uint256);
    function QUOTE_TOKEN_1() external view returns (address);
    function QUOTE_TOKEN_1_DECIMALS() external view returns (uint256);
    function SFRXETH_ERC4626() external view returns (address);
    function TWAP_PRECISION() external view returns (uint128);
    function UNISWAP_V3_TWAP_BASE_TOKEN() external view returns (address);
    function UNISWAP_V3_TWAP_QUOTE_TOKEN() external view returns (address);
    function UNI_V3_PAIR_ADDRESS() external view returns (address);
    function acceptTransferTimelock() external;
    function addRoundData(address _fraxOracle) external;
    function calculatePrices(
        uint256 _wethPerFrxEthCurveEma,
        uint256 _fraxPerFrxEthTwap,
        bool _isBadDataEthUsdChainlink,
        uint256 _usdPerEthChainlink,
        bool _isBadDataFraxUsdChainlink,
        uint256 _usdPerFraxChainlink,
        uint256 _frxEthPerSfrxEth
    ) external view returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh);
    function decimals() external pure returns (uint8);
    function getCurvePoolToken1EmaPrice() external view returns (uint256 _emaPrice);
    function getEthUsdChainlinkPrice() external view returns (bool _isBadData, uint256 _updatedAt, uint256 _usdPerEth);
    function getFraxPerFrxEthUniV3Twap() external view returns (uint256 _fraxPerFrxEthTwap);
    function getFraxUsdChainlinkPrice()
        external
        view
        returns (bool _isBadData, uint256 _updatedAt, uint256 _usdPerFrax);
    function getFrxEthPerSfrxEthErc4626Vault() external view returns (uint256 _frxEthPerSfrxEth);
    function getPrices() external view returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh);
    function getPricesNormalized()
        external
        view
        returns (bool _isBadDataNormal, uint256 _priceLowNormal, uint256 _priceHighNormal);
    function getUniswapV3Twap() external view returns (uint256 _twap);
    function getUsdPerEthChainlink() external view returns (bool _isBadData, uint256 _usdPerEth);
    function getUsdPerFraxChainlink() external view returns (bool _isBadData, uint256 _usdPerFrax);
    function getWethPerFrxEthCurveEma() external view returns (uint256 _wethPerFrxEth);
    function maximumCurvePoolEma() external view returns (uint256);
    function maximumEthUsdOracleDelay() external view returns (uint256);
    function maximumFraxUsdOracleDelay() external view returns (uint256);
    function minimumCurvePoolEma() external view returns (uint256);
    function name() external pure returns (string memory _name);
    function pendingTimelockAddress() external view returns (address);
    function renounceTimelock() external;
    function setMaximumCurvePoolEma(uint256 _maximumPrice) external;
    function setMaximumEthUsdOracleDelay(uint256 _newMaxOracleDelay) external;
    function setMaximumFraxUsdOracleDelay(uint256 _newMaxOracleDelay) external;
    function setMinimumCurvePoolEma(uint256 _minimumPrice) external;
    function setTwapDuration(uint32 _newTwapDuration) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function timelockAddress() external view returns (address);
    function transferTimelock(address _newTimelock) external;
    function twapDuration() external view returns (uint32);
    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch);
}

// src/contracts/curve-amo/interfaces/lsd/IstETH.sol

interface IstETH {
    function resume() external;

    function name() external pure returns (string memory);

    function stop() external;

    function hasInitialized() external view returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function STAKING_CONTROL_ROLE() external view returns (bytes32);

    function totalSupply() external view returns (uint256);

    function getSharesByPooledEth(uint256 _ethAmount) external view returns (uint256);

    function isStakingPaused() external view returns (bool);

    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

    function getEVMScriptExecutor(bytes memory _script) external view returns (address);

    function setStakingLimit(uint256 _maxStakeLimit, uint256 _stakeLimitIncreasePerBlock) external;

    function RESUME_ROLE() external view returns (bytes32);

    function finalizeUpgrade_v2(address _lidoLocator, address _eip712StETH) external;

    function decimals() external pure returns (uint8);

    function getRecoveryVault() external view returns (address);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function getTotalPooledEther() external view returns (uint256);

    function unsafeChangeDepositedValidators(uint256 _newDepositedValidators) external;

    function PAUSE_ROLE() external view returns (bytes32);

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);

    function getTreasury() external view returns (address);

    function isStopped() external view returns (bool);

    function getBufferedEther() external view returns (uint256);

    function initialize(address _lidoLocator, address _eip712StETH) external payable;

    function receiveELRewards() external payable;

    function getWithdrawalCredentials() external view returns (bytes32);

    function getCurrentStakeLimit() external view returns (uint256);

    function getStakeLimitFullInfo()
        external
        view
        returns (
            bool isStakingPaused,
            bool isStakingLimitSet,
            uint256 currentStakeLimit,
            uint256 maxStakeLimit,
            uint256 maxStakeLimitGrowthBlocks,
            uint256 prevStakeLimit,
            uint256 prevStakeBlockNumber
        );

    function transferSharesFrom(address _sender, address _recipient, uint256 _sharesAmount) external returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function resumeStaking() external;

    function getFeeDistribution()
        external
        view
        returns (uint16 treasuryFeeBasisPoints, uint16 insuranceFeeBasisPoints, uint16 operatorsFeeBasisPoints);

    function receiveWithdrawals() external payable;

    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);

    function allowRecoverability(address token) external view returns (bool);

    function nonces(address owner) external view returns (uint256);

    function appId() external view returns (bytes32);

    function getOracle() external view returns (address);

    function eip712Domain()
        external
        view
        returns (string memory name, string memory version, uint256 chainId, address verifyingContract);

    function getContractVersion() external view returns (uint256);

    function getInitializationBlock() external view returns (uint256);

    function transferShares(address _recipient, uint256 _sharesAmount) external returns (uint256);

    function symbol() external pure returns (string memory);

    function getEIP712StETH() external view returns (address);

    function transferToVault(address) external;

    function canPerform(address _sender, bytes32 _role, uint256[] memory _params) external view returns (bool);

    function submit(address _referral) external payable returns (uint256);

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);

    function getEVMScriptRegistry() external view returns (address);

    function transfer(address _recipient, uint256 _amount) external returns (bool);

    function deposit(uint256 _maxDepositsCount, uint256 _stakingModuleId, bytes calldata _depositCalldata) external;

    function UNSAFE_CHANGE_DEPOSITED_VALIDATORS_ROLE() external view returns (bytes32);

    function getBeaconStat()
        external
        view
        returns (uint256 depositedValidators, uint256 beaconValidators, uint256 beaconBalance);

    function removeStakingLimit() external;

    function handleOracleReport(
        uint256 _reportTimestamp,
        uint256 _timeElapsed,
        uint256 _clValidators,
        uint256 _clBalance,
        uint256 _withdrawalVaultBalance,
        uint256 _elRewardsVaultBalance,
        uint256 _sharesRequestedToBurn,
        uint256[] memory _withdrawalFinalizationBatches,
        uint256 _simulatedShareRate
    ) external returns (uint256[4] memory postRebaseAmounts);

    function getFee() external view returns (uint16 totalFee);

    function kernel() external view returns (address);

    function getTotalShares() external view returns (uint256);

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function allowance(address _owner, address _spender) external view returns (uint256);

    function isPetrified() external view returns (bool);

    function getLidoLocator() external view returns (address);

    function canDeposit() external view returns (bool);

    function STAKING_PAUSE_ROLE() external view returns (bytes32);

    function getDepositableEther() external view returns (uint256);

    function sharesOf(address _account) external view returns (uint256);

    function pauseStaking() external;

    function getTotalELRewardsCollected() external view returns (uint256);
}

// src/contracts/ether-router/interfaces/IfrxEthV2AMO.sol

// Minimum function set that a frxETH_V2 AMO needs to have
interface IfrxEthV2AMO {
    struct ShowAmoBalancedAllocsPacked {
        uint96 amoEthFree;
        uint96 amoEthInLpBalanced;
        uint96 amoEthTotalBalanced;
        uint96 amoFrxEthFree;
        uint96 amoFrxEthInLpBalanced;
    }

    function amoHelper() external view returns (address);

    function depositEther() external payable;

    function requestEtherByRouter(uint256 _ethRequested) external returns (uint256 _ethOut, uint256 _remainingEth);
}

// src/contracts/ether-router/interfaces/IfrxEthV2AMOHelper.sol

interface IfrxEthV2AMOHelper {
    struct PoolInfo {
        bool hasCvxVault; // If there is a cvxLP vault
        bool hasStkCvxFxsVault; // If there is a stkcvxLP vault
        uint8 frxEthIndex; // coins() index of frxETH/sfrxETH
        uint8 ethIndex; // coins() index of ETH/stETH/WETH
        address rewardsContractAddress; // Address for the Convex BaseRewardPool for the cvxLP
        address fxsPersonalVaultAddress; // Address for the stkcvxLP vault, if present
        address poolAddress; // Where the actual tokens are in the pool
        address lpTokenAddress; // The LP token address. Sometimes the same as poolAddress
        address[2] poolCoins; // The addresses of the coins in the pool
        uint32 lpDepositPid; // _convexBaseRewardPool.pid
        LpAbiType lpAbiType; // General pool parameter
        FrxSfrxType frxEthType; // frxETH and sfrxETH
        EthType ethType; // ETH, WETH, and LSDs
        uint256 lpDeposited; // Total LP deposited
        uint256 lpMaxAllocation; // Max LP allowed for this AMO
    }

    struct ShowAmoBalancedAllocsPacked {
        uint96 amoEthFree;
        uint96 amoEthInLpBalanced;
        uint96 amoEthTotalBalanced;
        uint96 amoFrxEthFree;
        uint96 amoFrxEthInLpBalanced;
    }

    enum LpAbiType {
        LSDETH, // frxETH/ETH, rETH/ETH using IPoolLSDETH
        TWOLSDSTABLE, // frxETH/rETH using IPool2LSDStable
        TWOCRYPTO, // ankrETH/frxETH using IPool2Crypto
        LSDWETH // frxETH/WETH using IPoolLSDWETH
    }

    enum FrxSfrxType {
        NONE, // neither frxETH or sfrxETH
        FRXETH, // frxETH
        SFRXETH // sfrxETH
    }

    enum EthType {
        NONE, // ankrETH/frxETH
        RAWETH, // frxETH/ETH
        STETH, // frxETH/stETH
        WETH // frxETH/WETH
    }

    function acceptOwnership() external;

    function calcBalancedFullLPExit(address _curveAmoAddress) external view returns (uint256[2] memory _withdrawables);

    function calcBalancedFullLPExitWithParams(
        address _curveAmo,
        address _poolAddress,
        PoolInfo memory _poolInfo
    ) external view returns (uint256[2] memory _withdrawables);

    function calcMiscBalancedInfo(
        address _curveAmoAddress,
        uint256 _desiredCoinIdx,
        uint256 _desiredCoinAmt
    )
        external
        view
        returns (
            uint256 _lpAmount,
            uint256 _undesiredCoinAmt,
            uint256[2] memory _coinAmounts,
            uint256[2] memory _lpPerCoinsBalancedE18,
            uint256 _lp_virtual_price
        );

    function calcMiscBalancedInfoWithParams(
        address _curveAmoAddress,
        address _poolAddress,
        PoolInfo memory _poolInfo,
        uint256 _desiredCoinIdx,
        uint256 _desiredCoinAmt
    )
        external
        view
        returns (
            uint256 _lpAmount,
            uint256 _undesiredCoinAmt,
            uint256[2] memory _coinAmounts,
            uint256[2] memory _lpPerCoinsBalancedE18,
            uint256 _lp_virtual_price
        );

    function calcOneCoinsFullLPExit(address _curveAmoAddress) external view returns (uint256[2] memory _withdrawables);

    function calcOneCoinsFullLPExitWithParams(
        address _curveAmo,
        address _poolAddress,
        PoolInfo memory _poolInfo
    ) external view returns (uint256[2] memory _withdrawables);

    function calcTknsForLPBalanced(
        address _curveAmoAddress,
        uint256 _lpAmount
    ) external view returns (uint256[2] memory _withdrawables);

    function calcTknsForLPBalancedWithParams(
        address _poolAddress,
        PoolInfo memory _poolInfo,
        uint256 _lpAmount
    ) external view returns (uint256[2] memory _withdrawables);

    function chainlinkEthUsdDecimals() external view returns (uint256);

    function oracleFrxEthUsdDecimals() external view returns (uint256);

    function getCurveInfoPack(
        address _curveAmoAddress
    ) external view returns (address _curveAmo, address _poolAddress, PoolInfo memory _poolInfo);

    function getEstLpPriceEthOrUsdE18(
        address _curveAmoAddress
    ) external view returns (uint256 _inEthE18, uint256 _inUsdE18);

    function getEstLpPriceEthOrUsdE18WithParams(
        address _curveAmo,
        address _poolAddress,
        PoolInfo memory _poolInfo
    ) external view returns (uint256 _inEthE18, uint256 _inUsdE18);

    function getEthPriceE18() external view returns (uint256);

    function getFrxEthPriceE18() external view returns (uint256);

    function lpInVaults(
        address _curveAmoAddress
    ) external view returns (uint256 inCvxRewPool, uint256 inStkCvxFarm, uint256 totalVaultLP);

    function lpInVaultsWithParams(
        address _curveAmo,
        PoolInfo memory _poolInfo
    ) external view returns (uint256 inCvxRewPool, uint256 inStkCvxFarm, uint256 totalVaultLP);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function priceFeedEthUsd() external view returns (address);

    function priceFeedfrxEthUsd() external view returns (address);

    function renounceOwnership() external;

    function setOracles(address _frxethOracle, address _ethOracle) external;

    function showAllocationsSkipOneCoin(
        address _curveAmoAddress
    ) external view returns (uint256[10] memory _allocations);

    function showAllocationsWithParams(
        address _curveAmo,
        address _poolAddress,
        PoolInfo memory _poolInfo,
        bool _skipOneCoinCalcs
    ) external view returns (uint256[10] memory _allocations);

    function showAmoMaxLP(address _curveAmoAddress) external view returns (uint256 _lpMaxAllocation);

    function showAmoMaxLPWithParams(PoolInfo memory _poolInfo) external view returns (uint256 _lpMaxAllocation);

    function showCVXRewards(address _curveAmoAddress) external view returns (uint256 _cvxRewards);

    function showPoolAccounting(
        address _curveAmoAddress
    )
        external
        view
        returns (uint256[] memory _freeCoinBalances, uint256 _depositedLp, uint256[5] memory _poolAndVaultAllocations);

    function showPoolAccountingWithParams(
        address _curveAmo,
        address _poolAddress,
        PoolInfo memory _poolInfo
    )
        external
        view
        returns (uint256[] memory _freeCoinBalances, uint256 _depositedLp, uint256[5] memory _poolAndVaultAllocations);

    function showPoolFreeCoinBalances(
        address _curveAmoAddress
    ) external view returns (uint256[] memory _freeCoinBalances);

    function showPoolFreeCoinBalancesWithParams(
        address _curveAmoAddress,
        address _poolAddress,
        PoolInfo memory _poolInfo
    ) external view returns (uint256[] memory _freeCoinBalances);

    function showPoolLPTokenAddress(address _curveAmoAddress) external view returns (address _lpTokenAddress);

    function showPoolLPTokenAddressWithParams(
        PoolInfo memory _poolInfo
    ) external view returns (address _lpTokenAddress);

    function showPoolRewards(
        address _curveAmoAddress
    )
        external
        view
        returns (
            uint256 _crvReward,
            uint256[] memory _extraRewardAmounts,
            address[] memory _extraRewardTokens,
            uint256 _extraRewardsLength
        );

    function showPoolRewardsWithParams(
        address _curveAmo,
        PoolInfo memory _poolInfo
    )
        external
        view
        returns (
            uint256 _crvReward,
            uint256[] memory _extraRewardAmounts,
            address[] memory _extraRewardTokens,
            uint256 _extraRewardsLength
        );

    function showPoolVaults(
        address _curveAmoAddress
    ) external view returns (uint256 _lpDepositPid, address _rewardsContractAddress, address _fxsPersonalVaultAddress);

    function showPoolVaultsWithParams(
        PoolInfo memory _poolInfo
    ) external view returns (uint256 _lpDepositPid, address _rewardsContractAddress, address _fxsPersonalVaultAddress);

    function transferOwnership(address newOwner) external;

    function showAllocations(address _curveAmoAddress) external view returns (uint256[10] memory);

    function dollarBalancesOfEths(
        address _curveAmoAddress
    ) external view returns (uint256 frxETHValE18, uint256 ethValE18, uint256 ttlValE18);

    function getConsolidatedEthFrxEthBalance(
        address _curveAmoAddress
    ) external view returns (uint256, uint256, uint256, uint256, uint256);

    function getConsolidatedEthFrxEthBalancePacked(
        address _curveAmoAddress
    ) external view returns (ShowAmoBalancedAllocsPacked memory);
}

// src/contracts/frxeth-redemption-queue-v2/interfaces/IFrxEth.sol

interface IFrxEth_0 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function acceptOwnership() external;

    function addMinter(address minter_address) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function minter_burn_from(address b_address, uint256 b_amount) external;

    function minter_mint(address m_address, uint256 m_amount) external;

    function minters(address) external view returns (bool);

    function minters_array(uint256) external view returns (address);

    function name() external view returns (string memory);

    function nominateNewOwner(address _owner) external;

    function nominatedOwner() external view returns (address);

    function nonces(address owner) external view returns (uint256);

    function owner() external view returns (address);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function removeMinter(address minter_address) external;

    function setTimelock(address _timelock_address) external;

    function symbol() external view returns (string memory);

    function timelock_address() external view returns (address);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// src/contracts/frxeth-redemption-queue-v2/interfaces/ISfrxEth.sol

interface ISfrxEth_0 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function allowance(address, address) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function asset() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function convertToAssets(uint256 shares) external view returns (uint256);

    function convertToShares(uint256 assets) external view returns (uint256);

    function decimals() external view returns (uint8);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function depositWithSignature(
        uint256 assets,
        address receiver,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 shares);

    function lastRewardAmount() external view returns (uint192);

    function lastSync() external view returns (uint32);

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256);

    function maxRedeem(address owner) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);

    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function previewDeposit(uint256 assets) external view returns (uint256);

    function previewMint(uint256 shares) external view returns (uint256);

    function previewRedeem(uint256 shares) external view returns (uint256);

    function previewWithdraw(uint256 assets) external view returns (uint256);

    function pricePerShare() external view returns (uint256);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    function rewardsCycleEnd() external view returns (uint32);

    function rewardsCycleLength() external view returns (uint32);

    function symbol() external view returns (string memory);

    function syncRewards() external;

    function totalAssets() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
}

// src/contracts/interfaces/IDepositContract.sol
// ┏━━━┓━┏┓━┏┓━━┏━━━┓━━┏━━━┓━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━┏┓━━━━━┏━━━┓━━━━━━━━━┏┓━━━━━━━━━━━━━━┏┓━
// ┃┏━━┛┏┛┗┓┃┃━━┃┏━┓┃━━┃┏━┓┃━━━━┗┓┏┓┃━━━━━━━━━━━━━━━━━━┏┛┗┓━━━━┃┏━┓┃━━━━━━━━┏┛┗┓━━━━━━━━━━━━┏┛┗┓
// ┃┗━━┓┗┓┏┛┃┗━┓┗┛┏┛┃━━┃┃━┃┃━━━━━┃┃┃┃┏━━┓┏━━┓┏━━┓┏━━┓┏┓┗┓┏┛━━━━┃┃━┗┛┏━━┓┏━┓━┗┓┏┛┏━┓┏━━┓━┏━━┓┗┓┏┛
// ┃┏━━┛━┃┃━┃┏┓┃┏━┛┏┛━━┃┃━┃┃━━━━━┃┃┃┃┃┏┓┃┃┏┓┃┃┏┓┃┃━━┫┣┫━┃┃━━━━━┃┃━┏┓┃┏┓┃┃┏┓┓━┃┃━┃┏┛┗━┓┃━┃┏━┛━┃┃━
// ┃┗━━┓━┃┗┓┃┃┃┃┃┃┗━┓┏┓┃┗━┛┃━━━━┏┛┗┛┃┃┃━┫┃┗┛┃┃┗┛┃┣━━┃┃┃━┃┗┓━━━━┃┗━┛┃┃┗┛┃┃┃┃┃━┃┗┓┃┃━┃┗┛┗┓┃┗━┓━┃┗┓
// ┗━━━┛━┗━┛┗┛┗┛┗━━━┛┗┛┗━━━┛━━━━┗━━━┛┗━━┛┃┏━┛┗━━┛┗━━┛┗┛━┗━┛━━━━┗━━━┛┗━━┛┗┛┗┛━┗━┛┗┛━┗━━━┛┗━━┛━┗━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┗┛━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// This interface is designed to be compatible with the Vyper version.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
interface IDepositContract {
    /// @notice A processed deposit event.
    event DepositEvent(bytes pubkey, bytes withdrawal_credentials, bytes amount, bytes signature, bytes index);

    /// @notice Submit a Phase 0 DepositData object.
    /// @param pubkey A BLS12-381 public key.
    /// @param withdrawal_credentials Commitment to a public key for withdrawals.
    /// @param signature A BLS12-381 signature.
    /// @param deposit_data_root The SHA-256 hash of the SSZ-encoded DepositData object.
    /// Used as a protection against malformed input.
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;

    /// @notice Query the current deposit root hash.
    /// @return The deposit root hash.
    function get_deposit_root() external view returns (bytes32);

    /// @notice Query the current deposit count.
    /// @return The deposit count encoded as a little endian 64-bit number.
    function get_deposit_count() external view returns (bytes memory);
}

// Based on official specification in https://eips.ethereum.org/EIPS/eip-165
interface ERC165_0 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceId` and
    ///  `interfaceId` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external pure returns (bool);
}

// This is a rewrite of the Vyper Eth2.0 deposit contract in Solidity.
// It tries to stay as close as possible to the original source code.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
contract DepositContract is IDepositContract, ERC165_0 {
    uint256 constant DEPOSIT_CONTRACT_TREE_DEPTH = 32;
    // NOTE: this also ensures `deposit_count` will fit into 64-bits
    uint256 constant MAX_DEPOSIT_COUNT = 2 ** DEPOSIT_CONTRACT_TREE_DEPTH - 1;

    bytes32[DEPOSIT_CONTRACT_TREE_DEPTH] branch;
    uint256 deposit_count;

    bytes32[DEPOSIT_CONTRACT_TREE_DEPTH] zero_hashes;

    constructor() public {
        // Compute hashes in empty sparse Merkle tree
        for (uint256 height = 0; height < DEPOSIT_CONTRACT_TREE_DEPTH - 1; height++) {
            zero_hashes[height + 1] = sha256(abi.encodePacked(zero_hashes[height], zero_hashes[height]));
        }
    }

    function get_deposit_root() external view override returns (bytes32) {
        bytes32 node;
        uint256 size = deposit_count;
        for (uint256 height = 0; height < DEPOSIT_CONTRACT_TREE_DEPTH; height++) {
            if ((size & 1) == 1) {
                node = sha256(abi.encodePacked(branch[height], node));
            } else {
                node = sha256(abi.encodePacked(node, zero_hashes[height]));
            }
            size /= 2;
        }
        return sha256(abi.encodePacked(node, to_little_endian_64(uint64(deposit_count)), bytes24(0)));
    }

    function get_deposit_count() external view override returns (bytes memory) {
        return to_little_endian_64(uint64(deposit_count));
    }

    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable override {
        // Extended ABI length checks since dynamic types are used.
        require(pubkey.length == 48, "DepositContract: invalid pubkey length");
        require(withdrawal_credentials.length == 32, "DepositContract: invalid withdrawal_credentials length");
        require(signature.length == 96, "DepositContract: invalid signature length");

        // Check deposit amount
        require(msg.value >= 1 ether, "DepositContract: deposit value too low");
        require(msg.value % 1 gwei == 0, "DepositContract: deposit value not multiple of gwei");
        uint256 deposit_amount = msg.value / 1 gwei;
        require(deposit_amount <= type(uint64).max, "DepositContract: deposit value too high");

        // Emit `DepositEvent` log
        bytes memory amount = to_little_endian_64(uint64(deposit_amount));
        emit DepositEvent(
            pubkey,
            withdrawal_credentials,
            amount,
            signature,
            to_little_endian_64(uint64(deposit_count))
        );

        // Compute deposit data root (`DepositData` hash tree root)
        bytes32 pubkey_root = sha256(abi.encodePacked(pubkey, bytes16(0)));
        bytes32 signature_root = sha256(
            abi.encodePacked(
                sha256(abi.encodePacked(signature[:64])),
                sha256(abi.encodePacked(signature[64:], bytes32(0)))
            )
        );
        bytes32 node = sha256(
            abi.encodePacked(
                sha256(abi.encodePacked(pubkey_root, withdrawal_credentials)),
                sha256(abi.encodePacked(amount, bytes24(0), signature_root))
            )
        );

        // Verify computed and expected deposit data roots match
        require(
            node == deposit_data_root,
            "DepositContract: reconstructed DepositData does not match supplied deposit_data_root"
        );

        // Avoid overflowing the Merkle tree (and prevent edge case in computing `branch`)
        require(deposit_count < MAX_DEPOSIT_COUNT, "DepositContract: merkle tree full");

        // Add deposit data root to Merkle tree (update a single `branch` node)
        deposit_count += 1;
        uint256 size = deposit_count;
        for (uint256 height = 0; height < DEPOSIT_CONTRACT_TREE_DEPTH; height++) {
            if ((size & 1) == 1) {
                branch[height] = node;
                return;
            }
            node = sha256(abi.encodePacked(branch[height], node));
            size /= 2;
        }
        // As the loop should always end prematurely with the `return` statement,
        // this code should be unreachable. We assert `false` just to be safe.
        assert(false);
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(ERC165_0).interfaceId || interfaceId == type(IDepositContract).interfaceId;
    }

    function to_little_endian_64(uint64 value) internal pure returns (bytes memory ret) {
        ret = new bytes(8);
        bytes8 bytesValue = bytes8(value);
        // Byteswapping during copying to bytes.
        ret[0] = bytesValue[7];
        ret[1] = bytesValue[6];
        ret[2] = bytesValue[5];
        ret[3] = bytesValue[4];
        ret[4] = bytesValue[3];
        ret[5] = bytesValue[2];
        ret[6] = bytesValue[1];
        ret[7] = bytesValue[0];
    }
}

// src/contracts/interfaces/IFrxEth.sol

interface IFrxEth_1 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function acceptOwnership() external;

    function addMinter(address minter_address) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function minter_burn_from(address b_address, uint256 b_amount) external;

    function minter_mint(address m_address, uint256 m_amount) external;

    function minters(address) external view returns (bool);

    function minters_array(uint256) external view returns (address);

    function name() external view returns (string memory);

    function nominateNewOwner(address _owner) external;

    function nominatedOwner() external view returns (address);

    function nonces(address owner) external view returns (uint256);

    function owner() external view returns (address);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function removeMinter(address minter_address) external;

    function setTimelock(address _timelock_address) external;

    function symbol() external view returns (string memory);

    function timelock_address() external view returns (address);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// src/contracts/interfaces/ISfrxEth.sol

// Primarily added to prevent ERC20 name collisions in frxETHMinter.sol
interface ISfrxEth_1 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function allowance(address, address) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function asset() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function convertToAssets(uint256 shares) external view returns (uint256);

    function convertToShares(uint256 assets) external view returns (uint256);

    function decimals() external view returns (uint8);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function depositWithSignature(
        uint256 assets,
        address receiver,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 shares);

    function lastRewardAmount() external view returns (uint192);

    function lastSync() external view returns (uint32);

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256);

    function maxRedeem(address owner) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);

    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function previewDeposit(uint256 assets) external view returns (uint256);

    function previewMint(uint256 shares) external view returns (uint256);

    function previewRedeem(uint256 shares) external view returns (uint256);

    function previewWithdraw(uint256 assets) external view returns (uint256);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    function rewardsCycleEnd() external view returns (uint32);

    function rewardsCycleLength() external view returns (uint32);

    function symbol() external view returns (string memory);

    function syncRewards() external;

    function totalAssets() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
}

// src/contracts/interfaces/IWETH.sol

interface IWETH {
    function name() external view returns (string memory);

    function approve(address guy, uint256 wad) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function symbol() external view returns (string memory);

    function transfer(address dst, uint256 wad) external returns (bool);

    function deposit() external payable;

    function allowance(address, address) external view returns (uint256);
}

// src/contracts/lending-pool/IInterestRateCalculator.sol

interface IInterestRateCalculator {
    function name() external view returns (string memory);

    function version() external view returns (uint256, uint256, uint256);

    function getNewRate(
        uint256 _deltaTime,
        uint256 _utilization,
        uint64 _maxInterest
    ) external view returns (uint64 _newRatePerSec, uint64 _newMaxInterest);
}

// src/contracts/lending-pool/interfaces/ILendingPool.sol

// interface ILendingPool {
//     event AddInterest(uint256 interestEarned, uint256 rate, uint256 feesAmount, uint256 feesShare);
//     event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
//     event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
//     event Erc20Recovered(address token, uint256 amount);
//     event EtherRecovered(uint256 amount);
//     event FeesCollected(address _recipient, uint96 _collectAmt);
//     event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
//     event RedemptionQueueEntered(
//         address redeemer,
//         uint256 nftId,
//         uint256 amount,
//         uint32 maturityTimestamp,
//         uint96 redemptionFeeAmount
//     );
//     event RedemptionTicketNftRedeemed(address sender, address recipient, uint256 nftId, uint96 amountOut);
//     event SetBeaconOracle(address indexed oldBeaconOracle, address indexed newBeaconOracle);
//     event SetEtherRouter(address indexed oldEtherRouter, address indexed newEtherRouter);
//     event SetMaxOperatorQueueLength(uint32 _newMaxQueueLength);
//     event SetQueueLength(uint32 _newLength);
//     event SetRedemptionFee(uint32 _newFee);
//     event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);
//     event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);
//     event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
//     event UpdateRate(
//         uint256 oldRatePerSec,
//         uint256 oldFullUtilizationRate,
//         uint256 newRatePerSec,
//         uint256 newFullUtilizationRate
//     );

//     struct CurrentRateInfo {
//         uint64 lastTimestamp;
//         uint64 ratePerSec;
//         uint64 fullUtilizationRate;
//     }

//     struct VaultAccount {
//         uint256 amount;
//         uint256 shares;
//     }

//     function DEFAULT_CREDIT_PER_VALIDATOR_I48_E12() external view returns (uint256);

//     function ETH2_DEPOSIT_CONTRACT() external view returns (address);

//     function FEE_PRECISION() external view returns (uint32);

//     function INTEREST_RATE_PRECISION() external view returns (uint256);

//     function UTILIZATION_PRECISION() external view returns (uint256);

//     function acceptTransferTimelock() external;

//     function addInterest(
//         bool _returnAccounting
//     )
//         external
//         returns (
//             uint256 _interestEarned,
//             uint256 _feesAmount,
//             uint256 _feesShare,
//             CurrentRateInfo memory _currentRateInfo,
//             VaultAccount memory _totalBorrow
//         );

//     function approve(address to, uint256 tokenId) external;

//     function approveValidator(bytes memory _validatorPublicKey) external;

//     function balanceOf(address owner) external view returns (uint256);

//     function beaconOracle() external view returns (address);

//     function borrow(address _recipient, uint256 _borrowAmount) external;

//     function collectRedemptionFees(address _recipient, uint96 _collectAmt) external;

//     function currentRateInfo()
//         external
//         view
//         returns (uint64 lastTimestamp, uint64 ratePerSec, uint64 fullUtilizationRate);

//     function deployValidatorPool(address _validatorPoolOwnerAddress) external returns (address _pairAddress);

//     function enterRedemptionQueue(address _recipient, uint96 _amountToRedeem) external;

//     function enterRedemptionQueueWithPermit(
//         uint96 _amountToRedeem,
//         address _recipient,
//         uint256 _deadline,
//         uint8 _v,
//         bytes32 _r,
//         bytes32 _s
//     ) external;

//     function etherRouter() external view returns (address);

//     function finalDepositValidator(
//         bytes memory _validatorPublicKey,
//         bytes memory _withdrawalCredentials,
//         bytes memory _validatorSignature,
//         bytes32 _depositDataRoot
//     ) external;

//     function frxEth() external view returns (address);

//     function getApproved(uint256 tokenId) external view returns (address);

//     function getUtilization() external view returns (uint256 _utilization);

//     function initialDepositValidator(bytes memory _validatorPublicKey, uint256 _depositAmount) external;

//     function interestAccrued() external view returns (uint256);

//     function interestAvailableForWithdrawal() external view returns (uint256);

//     function rateCalculator() external view returns (address);

//     function isApprovedForAll(address owner, address operator) external view returns (bool);

//     function isSolvent(address _validatorPool) external view returns (bool _isSolvent);

//     function liquidate(address _validatorPoolAddress, uint256 _amountToLiquidate) external;

//     function maxOperatorQueueLength() external view returns (uint32);

//     function name() external view returns (string memory);

//     function nftInformation(uint256 nftId) external view returns (bool hasBeenRedeemed, uint32 maturity, uint96 amount);

//     function operatorAddress() external view returns (address);

//     function ownerOf(uint256 tokenId) external view returns (address);

//     function pendingTimelockAddress() external view returns (address);

//     function previewAddInterest()
//         external
//         view
//         returns (
//             uint256 _interestEarned,
//             uint256 _feesAmount,
//             uint256 _feesShare,
//             CurrentRateInfo memory _newCurrentRateInfo,
//             VaultAccount memory _totalBorrow
//         );

//     function recoverErc20(address _tokenAddress, uint256 _tokenAmount) external;

//     function recoverEther(uint256 amount) external;

//     function redeemRedemptionTicketNft(uint256 _nftId, address _recipient) external;

//     function redemptionQueueState() external view returns (uint32 nextNftId, uint32 queueLength, uint32 redemptionFee);

//     function renounceTimelock() external;

//     function repay(address _targetPool) external payable;

//     function safeTransferFrom(address from, address to, uint256 tokenId) external;

//     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;

//     function setApprovalForAll(address operator, bool approved) external;

//     function setCreationCode(bytes memory _creationCode) external;

//     function setMaxOperatorQueueLength(uint32 _newMaxQueueLength) external;

//     function setOperator() external;

//     function setOperator(address _newOperator) external;

//     function setQueueLength(uint32 _newLength) external;

//     function setRedemptionFee(uint32 _newFee) external;

//     function setVPoolBorrowAllowance(address _validatorPoolAddress, uint128 _newBorrowAllowance) external;

//     function setVPoolCreditPerValidatorI48_E12(
//         address _validatorPoolAddress,
//         uint48 _newCreditPerValidatorI48_E12
//     ) external;

//     function setVPoolValidatorCount(address _validatorPoolAddress, uint32 _newValidatorCount) external;

//     function supportsInterface(bytes4 interfaceId) external view returns (bool);

//     function symbol() external view returns (string memory);

//     function timelockAddress() external view returns (address);

//     function toBorrowAmount(address _validatorPool, uint256 _shares) external view returns (uint256 _borrowAmount);

//     function tokenURI(uint256 tokenId) external view returns (string memory);

//     function totalBorrow() external view returns (uint256 amount, uint256 shares);

//     function transferFrom(address from, address to, uint256 tokenId) external;

//     function transferTimelock(address _newTimelock) external;

//     function validatorDepositInfo(
//         bytes memory _validatorPublicKey
//     ) external view returns (uint32 whenValidatorApproved, uint96 userDepositedEther, uint96 lendingPoolDepositedEther);

//     function validatorPoolAccounts(
//         address _validatorPool
//     )
//         external
//         view
//         returns (
//             bool isInitialized,
//             bool wasLiquidated,
//             uint32 lastWithdrawal,
//             uint32 validatorCount,
//             uint48 creditPerValidatorI48_E12,
//             uint128 borrowAllowance,
//             uint256 borrowShares
//         );

//     function validatorPoolCreationCodeAddress() external view returns (address);
// }
interface ILendingPool {
    struct CurrentRateInfo {
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
    }

    struct VaultAccount {
        uint256 amount;
        uint256 shares;
    }

    function DEFAULT_CREDIT_PER_VALIDATOR_I48_E12() external view returns (uint48);
    function ETH2_DEPOSIT_CONTRACT() external view returns (address);
    function INTEREST_RATE_PRECISION() external view returns (uint256);
    function MAXIMUM_CREDIT_PER_VALIDATOR_I48_E12() external view returns (uint48);
    function MAX_WITHDRAWAL_FEE() external view returns (uint256);
    function MINIMUM_BORROW_AMOUNT() external view returns (uint256);
    function MISSING_CREDPERVAL_MULT() external view returns (uint256);
    function UTILIZATION_PRECISION() external view returns (uint256);
    function acceptTransferTimelock() external;
    function addInterest(
        bool _returnAccounting
    )
        external
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo,
            VaultAccount memory _totalBorrow
        );
    function beaconOracle() external view returns (address);
    function borrow(address _recipient, uint256 _borrowAmount) external;
    function currentRateInfo()
        external
        view
        returns (uint64 lastTimestamp, uint64 ratePerSec, uint64 fullUtilizationRate);
    function deployValidatorPool(
        address _validatorPoolOwnerAddress,
        bytes32 _extraSalt
    ) external returns (address _poolAddress);
    function entrancyStatus() external view returns (bool _isEntered);
    function etherRouter() external view returns (address);
    function finalDepositValidator(
        bytes memory _validatorPublicKey,
        bytes memory _withdrawalCredentials,
        bytes memory _validatorSignature,
        bytes32 _depositDataRoot
    ) external;
    function frxETH() external view returns (address);
    function getLastWithdrawalTimestamp(
        address _validatorPoolAddress
    ) external returns (uint32 _lastWithdrawalTimestamp);
    function getLastWithdrawalTimestamps(
        address[] memory _validatorPoolAddresses
    ) external returns (uint32[] memory _lastWithdrawalTimestamps);
    function getMaxBorrow() external view returns (uint256 _maxBorrow);
    function getUtilization(bool _forceLive, bool _updateCache) external returns (uint256 _utilization);
    function getUtilizationView() external view returns (uint256 _utilization);
    function initialDepositValidator(bytes memory _validatorPublicKey, uint256 _depositAmount) external;
    function interestAccrued() external view returns (uint256);
    function isLiquidator(address _addr) external view returns (bool _canLiquidate);
    function isSolvent(address _validatorPoolAddress) external view returns (bool _isSolvent);
    function isValidatorApproved(bytes memory _publicKey) external view returns (bool _isApproved);
    function liquidate(address _validatorPoolAddress, uint256 _amountToLiquidate) external;
    function pendingTimelockAddress() external view returns (address);
    function previewAddInterest()
        external
        view
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _newCurrentRateInfo,
            VaultAccount memory _totalBorrow
        );
    function previewValidatorAccounts(address _validatorPoolAddress) external view returns (VaultAccount memory);
    function rateCalculator() external view returns (address);
    function recoverStrandedEth() external returns (uint256 _amountRecovered);
    function redemptionQueue() external view returns (address);
    function registerWithdrawal(address _endRecipient, uint256 _sentBackAmount, uint256 _feeAmount) external;
    function renounceTimelock() external;
    function repay(address _targetPool) external payable;
    function setBeaconOracleAddress(address _newBeaconOracleAddress) external;
    function setCreationCode(bytes memory _creationCode) external;
    function setEtherRouterAddress(address _newEtherRouterAddress) external;
    function setInterestRateCalculator(address _calculatorAddress) external;
    function setLiquidator(address _liquidatorAddress, bool _canLiquidate) external;
    function setRedemptionQueueAddress(address _newRedemptionQueue) external;
    function setVPoolCreditsPerValidator(
        address[] memory _validatorPoolAddresses,
        uint48[] memory _newCreditsPerValidator
    ) external;
    function setVPoolValidatorCountsAndBorrowAllowances(
        address[] memory _validatorPoolAddresses,
        bool _setValidatorCounts,
        bool _setBorrowAllowances,
        uint32[] memory _newValidatorCounts,
        uint128[] memory _newBorrowAllowances,
        uint32[] memory _lastWithdrawalTimestamps
    ) external;
    function setVPoolWithdrawalFee(uint256 _newFee) external;
    function setValidatorApprovals(
        bytes[] memory _validatorPublicKeys,
        address[] memory _validatorPoolAddresses,
        uint32[] memory _whenApprovedArr,
        uint32[] memory _lastWithdrawalTimestamps
    ) external;
    function timelockAddress() external view returns (address);
    function toBorrowAmount(uint256 _shares) external view returns (uint256 _borrowAmount);
    function toBorrowAmountOptionalRoundUp(
        uint256 _shares,
        bool _roundUp
    ) external view returns (uint256 _borrowAmount);
    function totalBorrow() external view returns (uint256 amount, uint256 shares);
    function transferTimelock(address _newTimelock) external;
    function utilizationStored() external view returns (uint256);
    function vPoolWithdrawalFee() external view returns (uint256);
    function validatorDepositInfo(
        bytes memory _validatorPublicKey
    )
        external
        view
        returns (
            uint32 whenValidatorApproved,
            bool wasFullDepositOrFinalized,
            address validatorPoolAddress,
            uint96 userDepositedEther,
            uint96 lendingPoolDepositedEther
        );
    function validatorPoolAccounts(
        address _validatorPool
    )
        external
        view
        returns (
            bool isInitialized,
            bool wasLiquidated,
            uint32 lastWithdrawal,
            uint32 validatorCount,
            uint48 creditPerValidatorI48_E12,
            uint128 borrowAllowance,
            uint256 borrowShares
        );
    function validatorPoolCreationCodeAddress() external view returns (address);
    function wasLiquidated(address _validatorPoolAddress) external view returns (bool _wasLiquidated);
    function wouldBeSolvent(
        address _validatorPoolAddress,
        bool _accrueInterest,
        uint256 _addlValidators,
        uint256 _addlBorrowAmount
    ) external view returns (bool _wouldBeSolvent, uint256 _borrowAmount, uint256 _creditAmount);
}

// src/contracts/libraries/SafeCastLibrary.sol

/// @title SafeCast Library
/// @author velodrome.finance
/// @notice Safely convert unsigned and signed integers without overflow / underflow
library SafeCastLibrary {
    error SafeCastOverflow();
    error SafeCastUnderflow();

    /// @dev Safely convert uint256 to int128
    function toInt128(uint256 value) internal pure returns (int128) {
        if (value > uint128(type(int128).max)) revert SafeCastOverflow();
        return int128(uint128(value));
    }

    /// @dev Safely convert int128 to uint256
    function toUint256(int128 value) internal pure returns (uint256) {
        if (value < 0) revert SafeCastUnderflow();
        return uint256(int256(value));
    }
}

// src/contracts/libraries/VaultAccountingLibrary.sol

struct VaultAccount {
    uint256 amount; // Total amount, analogous to market cap
    uint256 shares; // Total shares, analogous to shares outstanding
}

/// @title VaultAccount Library
/// @author Drake Evans (Frax Finance) github.com/drakeevans, modified from work by @Boring_Crypto github.com/boring_crypto
/// @notice Provides a library for use with the VaultAccount struct, provides convenient math implementations
/// @dev Uses uint128 to save on storage
library VaultAccountingLibrary {
    /// @notice Calculates the shares value in relationship to `amount` and `total`. Optionally rounds up.
    /// @dev Given an amount, return the appropriate number of shares
    function _toShares(
        VaultAccount memory _total,
        uint256 _amount,
        bool _roundUp
    ) internal pure returns (uint256 _shares) {
        if (_total.amount == 0) {
            _shares = _amount;
        } else {
            // May round down to 0 temporarily
            _shares = (_amount * _total.shares) / _total.amount;

            // Optionally round up to prevent certain attacks.
            if (_roundUp && (_shares * _total.amount < _amount * _total.shares)) {
                _shares = _shares + 1;
            }
        }
    }

    /// @notice Calculates the amount value in relationship to `shares` and `total`
    /// @dev Given a number of shares, returns the appropriate amount
    function _toAmount(
        VaultAccount memory _total,
        uint256 _shares,
        bool _roundUp
    ) internal pure returns (uint256 _amount) {
        // bool _roundUp = false;
        if (_total.shares == 0) {
            _amount = _shares;
        } else {
            // Rounds down for safety
            _amount = (_shares * _total.amount) / _total.shares;

            // Optionally round up to prevent certain attacks.
            if (_roundUp && (_amount * _total.shares < _shares * _total.amount)) {
                _amount = _amount + 1;
            }
        }
    }
}

// node_modules/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165_1 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// node_modules/@openzeppelin/contracts/access/Ownable2Step.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}

// node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// node_modules/@openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// src/contracts/ValidatorPool.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== ValidatorPool ==========================
// ====================================================================
// Deposits ETH to earn collateral credit for borrowing on the LendingPool
// Controlled by the depositor

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

// import { console } from "frax-std/FraxTest.sol";
// import { Logger } from "frax-std/Logger.sol";

/// @title Deposits ETH to earn collateral credit for borrowing on the LendingPool
/// @author Frax Finance
/// @notice Controlled by the depositor
contract ValidatorPool is Ownable2Step, PublicReentrancyGuard {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    /// @notice Track amount of ETH sent to deposit contract, but pubkey
    mapping(bytes validatorPubKey => uint256 amtDeposited) public depositedAmts;

    /// @notice Withdrawal creds for the validators
    bytes32 public immutable withdrawalCredentials;

    /// @notice The Eth lending pool
    ILendingPool public immutable lendingPool;

    /// @notice The official Eth2 deposit contract
    IDepositContract public immutable ETH2_DEPOSIT_CONTRACT;

    /// @notice Constructor
    /// @param _ownerAddress The owner of the validator pool
    /// @param _lendingPoolAddress Address of the lending pool
    /// @param _eth2DepositAddress Address of the Eth2 deposit contract
    constructor(
        address _ownerAddress,
        address payable _lendingPoolAddress,
        address payable _eth2DepositAddress
    ) Ownable(_ownerAddress) {
        lendingPool = ILendingPool(_lendingPoolAddress);
        bytes32 _bitMask = 0x0100000000000000000000000000000000000000000000000000000000000000;
        bytes32 _address = bytes32(uint256(uint160(address(this))));
        withdrawalCredentials = _bitMask | _address;

        ETH2_DEPOSIT_CONTRACT = IDepositContract(_eth2DepositAddress);
    }

    // ==============================================================================
    // Eth Handling
    // ==============================================================================

    /// @notice Accept Eth
    receive() external payable {}

    // ==============================================================================
    // Check Functions
    // ==============================================================================

    /// @notice Make sure the sender is the validator pool owner
    function _requireSenderIsOwner() internal view {
        if (msg.sender != owner()) revert SenderMustBeOwner();
    }

    /// @notice Make sure the sender is either the validator pool owner or the owner
    function _requireSenderIsOwnerOrLendingPool() internal view {
        if (msg.sender == owner() || msg.sender == address(lendingPool)) {
            // Do nothing
        } else {
            revert SenderMustBeOwnerOrLendingPool();
        }
    }

    /// @notice Make sure the supplied pubkey has been used (deposited to) by this validator before
    /// @param _pubKey The pubkey you want to test
    function _requireValidatorIsUsed(bytes memory _pubKey) internal view {
        if (depositedAmts[_pubKey] == 0) revert ValidatorIsNotUsed();
    }

    // ==============================================================================
    // View Functions
    // ==============================================================================

    /// @notice Get the amount of Eth borrowed by this validator pool
    /// @param _amtEthBorrowed The amount of ETH this pool has borrowed
    function getAmountBorrowed() public view returns (uint256 _amtEthBorrowed) {
        // Fetch the borrowShares
        (, , , , , , uint256 borrowShares) = lendingPool.validatorPoolAccounts(address(this));

        // Return the amount of ETH borrowed
        return lendingPool.toBorrowAmountOptionalRoundUp(borrowShares, true);
    }

    // ==============================================================================
    // Deposit Functions
    // ==============================================================================

    /// @notice When the validator pool makes a deposit
    /// @param _validatorPool The validator pool making the deposit
    /// @param _pubkey Public key of the validator.
    /// @param _amount Amount of Eth being deposited
    /// @dev The ETH2 emits a Deposit event, but this is for Beacon Oracle / offchain tracking help
    event ValidatorPoolDeposit(address _validatorPool, bytes _pubkey, uint256 _amount);

    /// @notice Deposit a specified amount of ETH into the ETH2 deposit contract
    /// @param pubkey Public key of the validator
    /// @param signature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    /// @param _depositAmount The amount to deposit
    function _deposit(
        bytes calldata pubkey,
        bytes calldata signature,
        bytes32 _depositDataRoot,
        uint256 _depositAmount
    ) internal {
        bytes memory _withdrawalCredentials = abi.encodePacked(withdrawalCredentials);
        // Deposit one batch
        ETH2_DEPOSIT_CONTRACT.deposit{ value: _depositAmount }(
            pubkey,
            _withdrawalCredentials,
            signature,
            _depositDataRoot
        );

        // Increment the amount deposited
        depositedAmts[pubkey] += _depositAmount;

        emit ValidatorPoolDeposit(address(this), pubkey, _depositAmount);
    }

    // /// @notice Deposit 32 ETH into the ETH2 deposit contract
    // /// @param pubkey Public key of the validator
    // /// @param signature Signature from the validator
    // /// @param _depositDataRoot Part of the deposit message
    // function fullDeposit(
    //     bytes calldata pubkey,
    //     bytes calldata signature,
    //     bytes32 _depositDataRoot
    // ) external payable nonReentrant {
    //     _requireSenderIsOwner();

    //     // Deposit the ether in the ETH 2.0 deposit contract
    //     // Use this contract's stored withdrawal_credentials
    //     require((msg.value + address(this).balance) >= 32 ether, "Need 32 ETH");
    //     _deposit(pubkey, signature, _depositDataRoot, 32 ether);

    //     lendingPool.initialDepositValidator(pubkey, 32 ether);
    // }

    // /// @notice Deposit a partial amount of ETH into the ETH2 deposit contract
    // /// @param _validatorPublicKey Public key of the validator
    // /// @param _validatorSignature Signature from the validator
    // /// @param _depositDataRoot Part of the deposit message
    // /// @dev This is not a full deposit and will have to be completed later
    // function partialDeposit(
    //     bytes calldata _validatorPublicKey,
    //     bytes calldata _validatorSignature,
    //     bytes32 _depositDataRoot
    // ) external payable nonReentrant {
    //     _requireSenderIsOwner();

    //     // Deposit the ether in the ETH 2.0 deposit contract
    //     require((msg.value + address(this).balance) >= 8 ether, "Need 8 ETH");
    //     _deposit(_validatorPublicKey, _validatorSignature, _depositDataRoot, 8 ether);

    //     lendingPool.initialDepositValidator(_validatorPublicKey, 8 ether);
    // }

    /// @notice Deposit ETH into the ETH2 deposit contract. Only msg.value / sender funds can be used
    /// @param _validatorPublicKey Public key of the validator
    /// @param _validatorSignature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    /// @dev Forcing msg.value only prevents users from seeding an external validator and depositing exited funds into there,
    /// which they can then further exit and steal
    function deposit(
        bytes calldata _validatorPublicKey,
        bytes calldata _validatorSignature,
        bytes32 _depositDataRoot
    ) external payable nonReentrant {
        _requireSenderIsOwner();

        // Make sure an integer amount of 1 Eth is being deposited
        // Avoids a case where < 1 Eth is borrowed to finalize a deposit, only to have it fail at the Eth 2.0 contract
        // Also avoids the 1 gwei minimum increment issue at the Eth 2.0 contract
        if ((msg.value % (1 ether)) != 0) revert MustBeIntegerMultipleOf1Eth();

        // Deposit the ether in the ETH 2.0 deposit contract
        // This will reject if the deposit amount isn't at least 1 ETH + a multiple of 1 gwei
        _deposit(_validatorPublicKey, _validatorSignature, _depositDataRoot, msg.value);

        // Register the deposit with the lending pool
        // Will revert if you go over 32 ETH
        lendingPool.initialDepositValidator(_validatorPublicKey, msg.value);
    }

    /// @notice Finalizes an incomplete ETH2 deposit made earlier, borrowing any remainder from the lending pool
    /// @param _validatorPublicKey Public key of the validator
    /// @param _validatorSignature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    /// @dev You don't necessarily need credit here because the collateral is secured by the exit message. You pay the interest rate.
    /// Not part of the normal borrow credit system, this is separate.
    /// Useful for leveraging your position if the borrow rate is low enough
    function requestFinalDeposit(
        bytes calldata _validatorPublicKey,
        bytes calldata _validatorSignature,
        bytes32 _depositDataRoot
    ) external nonReentrant {
        _requireSenderIsOwner();
        _requireValidatorIsUsed(_validatorPublicKey);

        // Reverts if deposits not allowed or Validator Pool does not have enough credit/allowance
        lendingPool.finalDepositValidator(
            _validatorPublicKey,
            abi.encodePacked(withdrawalCredentials),
            _validatorSignature,
            _depositDataRoot
        );
    }

    // ==============================================================================
    // Borrow Functions
    // ==============================================================================

    /// @notice Borrow ETH from the Lending Pool and give to the recipient
    /// @param _recipient Recipient of the borrowed funds
    /// @param _borrowAmount Amount being borrowed
    function borrow(address payable _recipient, uint256 _borrowAmount) public nonReentrant {
        _requireSenderIsOwner();

        // Borrow ETH from the Lending Pool and give to the recipient
        lendingPool.borrow(_recipient, _borrowAmount);
    }

    // ==============================================================================
    // Repay Functions
    // ==============================================================================

    /// @notice Repay a loan with msg.value ETH
    function repayWithValue() external payable nonReentrant {
        // On liquidation lending pool will call this function to repay the debt
        _requireSenderIsOwnerOrLendingPool();

        // Take ETH from this contract and give to the Lending Pool to repay any loans
        lendingPool.repay{ value: msg.value }(address(this));
    }

    /// @notice Repay a loan, specifing the ETH amount
    /// @param _repayAmount Amount of ETH to repay
    function repayAmount(uint256 _repayAmount) external nonReentrant {
        // On liquidation lending pool will call this function to repay the debt
        _requireSenderIsOwnerOrLendingPool();

        // Take ETH from this contract and give to the Lending Pool to repay any loans
        lendingPool.repay{ value: _repayAmount }(address(this));
    }

    /// @notice Repay a loan, specifing the shares amount
    /// @param _repayShares Amount of shares to repay
    function repayShares(uint256 _repayShares) external nonReentrant {
        _requireSenderIsOwnerOrLendingPool();
        uint256 _repayAmount = lendingPool.toBorrowAmountOptionalRoundUp(_repayShares, true);
        lendingPool.repay{ value: _repayAmount }(address(this));
    }

    // ==============================================================================
    // Withdraw Functions
    // ==============================================================================

    /// @notice Withdraw ETH from this contract. Must not have any outstanding loans.
    /// @param _recipient Recipient of the ETH
    /// @param _withdrawAmount Amount to withdraw
    /// @dev Even assuming the exited ETH is dumped back in here before the Beacon Oracle registers that, and if the user
    /// tried to borrow again, their collateral would be this exited ETH now that is "trapped" until the loan is repaid,
    /// rather than being in a validator, so it is still ok. borrow() would increase borrowShares, which would still need to be paid off first
    function withdraw(address payable _recipient, uint256 _withdrawAmount) external nonReentrant {
        _requireSenderIsOwner();

        // Calculate the withdrawal fee amount
        uint256 _withdrawalFeeAmt = (_withdrawAmount * lendingPool.vPoolWithdrawalFee()) / 1e6;
        uint256 _postFeeAmt = _withdrawAmount - _withdrawalFeeAmt;

        // Register the withdrawal on the lending pool
        // Will revert unless all debts are paid off first
        lendingPool.registerWithdrawal(_recipient, _postFeeAmt, _withdrawalFeeAmt);

        // Give the fee to the Ether Router first, to cover any fees/slippage from LP movements
        (bool sent, ) = payable(lendingPool.etherRouter()).call{ value: _withdrawalFeeAmt }("");
        if (!sent) revert InvalidEthTransfer();

        // Withdraw ETH from this validator pool and give to the recipient
        (sent, ) = payable(_recipient).call{ value: _postFeeAmt }("");
        if (!sent) revert InvalidEthTransfer();
    }

    // ==============================================================================
    // Errors
    // ==============================================================================

    /// @notice External contract should not have been entered previously
    error ExternalContractAlreadyEntered();

    /// @notice When there is not enough Eth in msg.sender + this pool
    error InsufficientSenderAndPoolEth();

    /// @notice Invalid ETH transfer during recoverEther
    error InvalidEthTransfer();

    /// @notice When you are trying to deposit a non integer multiple of 1 ether
    error MustBeIntegerMultipleOf1Eth();

    /// @notice Sender must be the lending pool
    error SenderMustBeLendingPool();

    /// @notice Sender must be the owner
    error SenderMustBeOwner();

    /// @notice Sender must be the owner or the lendingPool
    error SenderMustBeOwnerOrLendingPool();

    /// @notice Validator is not approved
    error ValidatorIsNotUsed();

    /// @notice Wrong Ether deposit amount
    error WrongEthDepositAmount();
}

// node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ERC721 is Context, ERC165_1, IERC721, IERC721Metadata, IERC721Errors {
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;

    mapping(address owner => uint256) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165_1, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}

// src/contracts/BeaconOracle.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== BeaconOracle ===========================
// ====================================================================
// Tracks frxETHV2 ValidatorPools. Controlled by Frax governance / bots

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

/// @title Tracks frxETHV2 ValidatorPools
/// @author Frax Finance
/// @notice Controlled by Frax governance / bots
contract BeaconOracle is LendingPoolRole, OperatorRole, Timelock2Step {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    /// @notice Constructor for the beacon oracle
    /// @param _timelockAddress The timelock address
    /// @param _operatorAddress The operator address
    constructor(
        address _timelockAddress,
        address _operatorAddress
    ) LendingPoolRole(payable(address(0))) OperatorRole(_operatorAddress) Timelock2Step(_timelockAddress) {}

    // ==============================================================================
    // Operator (and Timelock) Check Functions
    // ==============================================================================

    /// @notice Checks if msg.sender is the timelock address or the operator
    function _requireIsTimelockOrOperator() internal view {
        if (!((msg.sender == timelockAddress) || (msg.sender == operatorAddress))) revert NotTimelockOrOperator();
    }

    // ==============================================================================
    // Beacon Functions
    // ==============================================================================

    /// @notice Set the approval status for a single validator's pubkey
    /// @param _validatorPublicKey The pubkey being set
    /// @param _validatorPoolAddress The validator pool associated with the pubkey
    /// @param _whenApproved When the pubkey was approved. 0 if it is not
    /// @param _lastWithdrawalTimestamp Should be the timestamp of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setValidatorApproval(
        bytes calldata _validatorPublicKey,
        address _validatorPoolAddress,
        uint32 _whenApproved,
        uint32 _lastWithdrawalTimestamp
    ) external {
        _requireIsTimelockOrOperator();

        // Set arrays
        bytes[] memory tmpArr0 = new bytes[](1);
        tmpArr0[0] = _validatorPublicKey;
        address[] memory tmpArr1 = new address[](1);
        tmpArr1[0] = _validatorPoolAddress;
        uint32[] memory tmpArr2 = new uint32[](1);
        tmpArr2[0] = _whenApproved;
        uint32[] memory lwTimestampTmpArr = new uint32[](1);
        lwTimestampTmpArr[0] = _lastWithdrawalTimestamp;

        // Set the approvals
        lendingPool.setValidatorApprovals(tmpArr0, tmpArr1, tmpArr2, lwTimestampTmpArr);
    }

    /// @notice Set the approval status for a multiple validator pubkeys
    /// @param _validatorPublicKeys The pubkeys being set
    /// @param _validatorPoolAddresses The validator pools associated with the pubkeys
    /// @param _whenApprovedArr When the validators were approved. 0 if they were not
    /// @param _lastWithdrawalTimestamps Should be the timestamps of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setValidatorApprovals(
        bytes[] calldata _validatorPublicKeys,
        address[] calldata _validatorPoolAddresses,
        uint32[] calldata _whenApprovedArr,
        uint32[] calldata _lastWithdrawalTimestamps
    ) external {
        _requireIsTimelockOrOperator();

        // Set the approvals
        lendingPool.setValidatorApprovals(
            _validatorPublicKeys,
            _validatorPoolAddresses,
            _whenApprovedArr,
            _lastWithdrawalTimestamps
        );
    }

    /// @notice Set the borrow allowance for a single validator pool
    /// @param _validatorPoolAddress The validator pool being set
    /// @param _newBorrowAllowance The new borrow allowance
    /// @param _lastWithdrawalTimestamp Should be the timestamp of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setVPoolBorrowAllowance(
        address _validatorPoolAddress,
        uint128 _newBorrowAllowance,
        uint32 _lastWithdrawalTimestamp
    ) external {
        _requireIsTimelockOrOperator();

        // Set arrays
        address[] memory vpAddrTmpArr = new address[](1);
        vpAddrTmpArr[0] = _validatorPoolAddress;
        uint128[] memory nbaTmpArr = new uint128[](1);
        nbaTmpArr[0] = _newBorrowAllowance;
        uint32[] memory emptyArr = new uint32[](0);
        uint32[] memory lwTimestampTmpArr = new uint32[](1);
        lwTimestampTmpArr[0] = _lastWithdrawalTimestamp;

        // Set the borrow allowance only, for a single validator pool
        lendingPool.setVPoolValidatorCountsAndBorrowAllowances(
            vpAddrTmpArr,
            false,
            true,
            emptyArr,
            nbaTmpArr,
            lwTimestampTmpArr
        );
    }

    /// @notice Set the borrow allowances for a multiple validator pools
    /// @param _validatorPoolAddresses The validator pools being set
    /// @param _newBorrowAllowances The new borrow allowances
    /// @param _lastWithdrawalTimestamps Should be the timestamps of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setVPoolBorrowAllowances(
        address[] calldata _validatorPoolAddresses,
        uint128[] calldata _newBorrowAllowances,
        uint32[] calldata _lastWithdrawalTimestamps
    ) external {
        _requireIsTimelockOrOperator();
        uint32[] memory emptyArr = new uint32[](0);

        // Set the borrow allowances only, for a multiple validator pools
        lendingPool.setVPoolValidatorCountsAndBorrowAllowances(
            _validatorPoolAddresses,
            false,
            true,
            emptyArr,
            _newBorrowAllowances,
            _lastWithdrawalTimestamps
        );
    }

    /// @notice Set the credits per validator for a single validator pool
    /// @param _validatorPoolAddress The validator pool being set
    /// @param _newCreditPerValidatorI48_E12 The ETH credit per validator this pool should be given
    function setVPoolCreditPerValidatorI48_E12(
        address _validatorPoolAddress,
        uint48 _newCreditPerValidatorI48_E12
    ) external {
        _requireIsTimelockOrOperator();

        // Set arrays
        address[] memory vpAddrTmpArr = new address[](1);
        vpAddrTmpArr[0] = _validatorPoolAddress;
        uint48[] memory ncpvTmpArr = new uint48[](1);
        ncpvTmpArr[0] = _newCreditPerValidatorI48_E12;

        lendingPool.setVPoolCreditsPerValidator(vpAddrTmpArr, ncpvTmpArr);
    }

    /// @notice Set the credits per validator for a multiple validator pools
    /// @param _validatorPoolAddresses The validator pools being set
    /// @param _newCreditsPerValidator The ETH credits per validator each pool should be given
    function setVPoolCreditsPerValidator(
        address[] calldata _validatorPoolAddresses,
        uint48[] calldata _newCreditsPerValidator
    ) external {
        _requireIsTimelockOrOperator();
        lendingPool.setVPoolCreditsPerValidator(_validatorPoolAddresses, _newCreditsPerValidator);
    }

    /// @notice Set the number of validators for a single validator pool
    /// @param _validatorPoolAddress The validator pool being set
    /// @param _newValidatorCount The new total number of validators for the pool
    /// @param _lastWithdrawalTimestamp Should be the timestamp of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setVPoolValidatorCount(
        address _validatorPoolAddress,
        uint32 _newValidatorCount,
        uint32 _lastWithdrawalTimestamp
    ) external {
        _requireIsTimelockOrOperator();

        // Set arrays
        address[] memory vpAddrTmpArr = new address[](1);
        vpAddrTmpArr[0] = _validatorPoolAddress;
        uint32[] memory nvcTmpArr = new uint32[](1);
        nvcTmpArr[0] = _newValidatorCount;
        uint128[] memory emptyArr = new uint128[](0);
        uint32[] memory lwTimestampTmpArr = new uint32[](1);
        lwTimestampTmpArr[0] = _lastWithdrawalTimestamp;

        // Set the count only, for a single validator pool
        lendingPool.setVPoolValidatorCountsAndBorrowAllowances(
            vpAddrTmpArr,
            true,
            false,
            nvcTmpArr,
            emptyArr,
            lwTimestampTmpArr
        );
    }

    /// @notice Set the number of validators for multiple validator pools
    /// @param _validatorPoolAddresses The validator pools being set
    /// @param _newValidatorCounts The new total number of validators for the pools
    /// @param _lastWithdrawalTimestamps Should be the timestamps of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setVPoolValidatorCounts(
        address[] calldata _validatorPoolAddresses,
        uint32[] calldata _newValidatorCounts,
        uint32[] calldata _lastWithdrawalTimestamps
    ) external {
        _requireIsTimelockOrOperator();
        uint128[] memory emptyArr = new uint128[](0);

        // Set the counts only, for multiple validator pools
        lendingPool.setVPoolValidatorCountsAndBorrowAllowances(
            _validatorPoolAddresses,
            true,
            false,
            _newValidatorCounts,
            emptyArr,
            _lastWithdrawalTimestamps
        );
    }

    /// @notice Set the number of validators and the borrow allowance for a single validator pools
    /// @param _validatorPoolAddress The validator pool being set
    /// @param _newValidatorCount The new total number of validators for the pool
    /// @param _newBorrowAllowance The new borrow allowance
    /// @param _lastWithdrawalTimestamp Should be the timestamp of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setVPoolValidatorCountAndBorrowAllowance(
        address _validatorPoolAddress,
        uint32 _newValidatorCount,
        uint128 _newBorrowAllowance,
        uint32 _lastWithdrawalTimestamp
    ) external {
        _requireIsTimelockOrOperator();

        // Set arrays
        address[] memory vpAddrTmpArr = new address[](1);
        vpAddrTmpArr[0] = _validatorPoolAddress;
        uint32[] memory nvcTmpArr = new uint32[](1);
        nvcTmpArr[0] = _newValidatorCount;
        uint128[] memory nbaTmpArr = new uint128[](1);
        nbaTmpArr[0] = _newBorrowAllowance;
        uint32[] memory lwTimestampTmpArr = new uint32[](1);
        lwTimestampTmpArr[0] = _lastWithdrawalTimestamp;

        // Set both the count and borrow allowance for a single validator pool
        lendingPool.setVPoolValidatorCountsAndBorrowAllowances(
            vpAddrTmpArr,
            true,
            true,
            nvcTmpArr,
            nbaTmpArr,
            lwTimestampTmpArr
        );
    }

    /// @notice Set the number of validators, as well as their allowances, for multiple validator pools
    /// @param _validatorPoolAddresses The validator pools being set
    /// @param _newValidatorCounts The new total number of validators for the pools
    /// @param _newBorrowAllowances The new borrow allowances
    /// @param _lastWithdrawalTimestamps Should be the timestamps of when the user last withdrew. Function will revert if user withdraws after this function is enqueued.
    function setVPoolValidatorCountsAndBorrowAllowances(
        address[] calldata _validatorPoolAddresses,
        uint32[] calldata _newValidatorCounts,
        uint128[] calldata _newBorrowAllowances,
        uint32[] calldata _lastWithdrawalTimestamps
    ) external {
        _requireIsTimelockOrOperator();

        // Set both the counts and borrow allowances for multiple validator pools
        lendingPool.setVPoolValidatorCountsAndBorrowAllowances(
            _validatorPoolAddresses,
            true,
            true,
            _newValidatorCounts,
            _newBorrowAllowances,
            _lastWithdrawalTimestamps
        );
    }

    // ==============================================================================
    // Restricted Functions
    // ==============================================================================

    /// @notice Set the lending pool address
    /// @param _newLendingPoolAddress The new address of the lending pool
    function setLendingPool(address payable _newLendingPoolAddress) external {
        _requireSenderIsTimelock();
        _setLendingPool(_newLendingPoolAddress);
    }

    /// @notice Change the Operator address
    /// @param _newOperatorAddress Operator address
    function setOperatorAddress(address _newOperatorAddress) external {
        _requireSenderIsTimelock();
        _setOperator(_newOperatorAddress);
    }

    // ====================================
    // Errors
    // ====================================

    /// @notice Thrown if the sender is not the timelock or the operator
    error NotTimelockOrOperator();
}

// src/contracts/access-control/BeaconOracleRole.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================= BeaconOracleRole =========================
// ====================================================================
// Access control for the Beacon Oracle

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans

// Reviewer(s) / Contributor(s)
// Travis Moore: https://github.com/FortisFortuna
// Dennis: https://github.com/denett

abstract contract BeaconOracleRole {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    BeaconOracle public beaconOracle;

    /// @notice constructor
    /// @param _beaconOracle Address of Beacon Oracle
    constructor(address _beaconOracle) {
        beaconOracle = BeaconOracle(_beaconOracle);
    }

    // ==============================================================================
    // Configuration Setters
    // ==============================================================================

    /// @notice Sets a new Beacon Oracle
    /// @param _beaconOracle Address for the new Beacon Oracle
    function _setBeaconOracle(address _beaconOracle) internal {
        emit SetBeaconOracle(address(beaconOracle), _beaconOracle);
        beaconOracle = BeaconOracle(_beaconOracle);
    }

    // ==============================================================================
    // Internal Checks
    // ==============================================================================

    /// @notice Checks if an address is the Beacon Oracle
    /// @param _address Address to test
    function _isBeaconOracle(address _address) internal view returns (bool) {
        return (_address == address(beaconOracle));
    }

    /// @notice Reverts if the address is not the Beacon Oracle
    /// @param _address Address to test
    function _requireIsBeaconOracle(address _address) internal view {
        if (!_isBeaconOracle(_address)) {
            revert AddressIsNotBeaconOracle(address(beaconOracle), _address);
        }
    }

    /// @notice Reverts if msg.sender is not the Beacon Oracle
    function _requireSenderIsBeaconOracle() internal view {
        _requireIsBeaconOracle(msg.sender);
    }

    // ==============================================================================
    // Events
    // ==============================================================================

    /// @notice The ```SetBeaconOracle``` event fires when the Beacon Oracle address changes
    /// @param oldBeaconOracle The old address
    /// @param newBeaconOracle The new address
    event SetBeaconOracle(address indexed oldBeaconOracle, address indexed newBeaconOracle);

    // ==============================================================================
    // Errors
    // ==============================================================================

    /// @notice Emitted when the test address is not the Beacon Oracle
    error AddressIsNotBeaconOracle(address beaconOracleAddress, address actualAddress);
}

// src/contracts/access-control/EtherRouterRole.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== EtherRouterRole =========================
// ====================================================================
// Access control for the Ether Router

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans

// Reviewer(s) / Contributor(s)
// Travis Moore: https://github.com/FortisFortuna
// Dennis: https://github.com/denett

abstract contract EtherRouterRole {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    EtherRouter public etherRouter;

    /// @notice constructor
    /// @param _etherRouter Address of Ether Router
    constructor(address payable _etherRouter) {
        etherRouter = EtherRouter(_etherRouter);
    }

    // ==============================================================================
    // Configuration Setters
    // ==============================================================================

    /// @notice Sets a new Ether Router
    /// @param _etherRouter Address for the new Ether Router.
    function _setEtherRouter(address payable _etherRouter) internal {
        emit SetEtherRouter(address(etherRouter), _etherRouter);
        etherRouter = EtherRouter(_etherRouter);
    }

    // ==============================================================================
    // Internal Checks
    // ==============================================================================

    /// @notice Checks if an address is the Ether Router
    /// @param _address Address to test
    function _isEtherRouter(address _address) internal view returns (bool) {
        return (_address == address(etherRouter));
    }

    /// @notice Reverts if the address is not the Ether Router
    /// @param _address Address to test
    function _requireIsEtherRouter(address _address) internal view {
        if (!_isEtherRouter(_address)) {
            revert AddressIsNotEtherRouter(address(etherRouter), _address);
        }
    }

    /// @notice Reverts if msg.sender is not the Ether Router
    function _requireSenderIsEtherRouter() internal view {
        _requireIsEtherRouter(msg.sender);
    }

    // ==============================================================================
    // Events
    // ==============================================================================

    /// @notice The ```SetEtherRouter``` event fires when the Ether Router address changes
    /// @param oldEtherRouter The old address
    /// @param newEtherRouter The new address
    event SetEtherRouter(address indexed oldEtherRouter, address indexed newEtherRouter);

    // ==============================================================================
    // Errors
    // ==============================================================================

    /// @notice Emitted when the test address is not the Ether Router
    error AddressIsNotEtherRouter(address etherRouterAddress, address actualAddress);
}

// src/contracts/ether-router/EtherRouter.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== EtherRouter ============================
// ====================================================================
// Manages ETH and ETH-like tokens (frxETH, rETH, stETH, etc) in different AMOs and moves them between there
// and the Lending Pool
// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

/// @title Recieves and gives back ETH from the lending pool. Distributes idle ETH to various AMOs for use, such as LP formation.
/// @author Frax Finance
/// @notice Controlled by Frax governance
contract EtherRouter is LendingPoolRole, RedemptionQueueV2Role, OperatorRole, Timelock2Step, PublicReentrancyGuard {
    // ========================================================
    // STATE VARIABLES
    // ========================================================

    // AMO addresses
    /// @notice Array of AMOs
    address[] public amosArray;

    /// @notice Mapping is also used for faster verification
    mapping(address => bool) public amos; //

    /// @notice For caching getConsolidatedEthFrxEthBalance
    // mapping(address => bool) public staleStatusCEFEBals;
    mapping(address => CachedConsEFxBalances) public cachedConsEFxEBals;

    /// @notice Address where all ETH deposits will go to
    address public depositToAmoAddr;

    /// @notice Address where requestEther will pull from first
    address public primaryWithdrawFromAmoAddr;

    /// @notice Address of frxETH
    ERC20 public immutable frxETH;

    // ========================================================
    // STRUCTS
    // ========================================================

    /// @notice Get frxETH/sfrxETH and ETH/LSD/WETH balances
    /// @param isStale If the cache is stale or not
    /// @param amoAddress Address of the AMO for this cache
    /// @param ethFree Free and clear ETH/LSD/WETH
    /// @param ethInLpBalanced ETH/LSD/WETH in LP (balanced withdrawal)
    /// @param ethTotalBalanced Free and clear ETH/LSD/WETH + ETH/LSD/WETH in LP (balanced withdrawal)
    /// @param frxEthFree Free and clear frxETH/sfrxETH
    /// @param frxEthInLpBalanced frxETH/sfrxETH in LP (balanced withdrawal)
    struct CachedConsEFxBalances {
        bool isStale;
        address amoAddress;
        uint96 ethFree;
        uint96 ethInLpBalanced;
        uint96 ethTotalBalanced;
        uint96 frxEthFree;
        uint96 frxEthInLpBalanced;
    }

    // ========================================================
    // CONSTRUCTOR
    // ========================================================

    /// @notice Constructor for the EtherRouter
    /// @param _timelockAddress The timelock address
    /// @param _operatorAddress The operator address
    /// @param _frxEthAddress The address of the frxETH ERC20
    constructor(
        address _timelockAddress,
        address _operatorAddress,
        address _frxEthAddress
    )
        RedemptionQueueV2Role(payable(address(0)))
        LendingPoolRole(payable(address(0)))
        OperatorRole(_operatorAddress)
        Timelock2Step(_timelockAddress)
    {
        frxETH = ERC20(_frxEthAddress);
    }

    // ====================================
    // INTERNAL FUNCTIONS
    // ====================================

    /// @notice Checks if msg.sender is current timelock address or the operator
    function _requireIsTimelockOrOperator() internal view {
        if (!((msg.sender == timelockAddress) || (msg.sender == operatorAddress))) revert NotTimelockOrOperator();
    }

    /// @notice Checks if msg.sender is the lending pool or the redemption queue
    function _requireSenderIsLendingPoolOrRedemptionQueue() internal view {
        if (!((msg.sender == address(lendingPool)) || (msg.sender == address(redemptionQueue)))) {
            revert NotLendingPoolOrRedemptionQueue();
        }
    }

    // ========================================================
    // VIEWS
    // ========================================================

    /// @notice Get frxETH/sfrxETH and ETH/LSD/WETH balances
    /// @param _forceLive Force a live recalculation of the AMO values
    /// @param _previewUpdateCache Calculate, but do not write, updated cache values
    /// @return _rtnTtlBalances frxETH/sfrxETH and ETH/LSD/WETH balances
    /// @return _cachesToUpdate Caches to be updated, if specified in _previewUpdateCache
    function _getConsolidatedEthFrxEthBalanceViewCore(
        bool _forceLive,
        bool _previewUpdateCache
    )
        internal
        view
        returns (CachedConsEFxBalances memory _rtnTtlBalances, CachedConsEFxBalances[] memory _cachesToUpdate)
    {
        // Initialize _cachesToUpdate
        CachedConsEFxBalances[] memory _cachesToUpdateLocal = new CachedConsEFxBalances[](amosArray.length);

        // Add ETH sitting in this contract first
        // frxETH/sfrxETH should never be here
        // _rtnTtlBalances.isStale = false
        _rtnTtlBalances.ethFree += uint96(address(this).balance);
        _rtnTtlBalances.ethTotalBalanced += uint96(address(this).balance);

        // Loop through all the AMOs and sum
        for (uint256 i = 0; i < amosArray.length; ) {
            address _amoAddress = amosArray[i];
            // Skip removed AMOs
            if (_amoAddress != address(0)) {
                // Pull the cache entry
                CachedConsEFxBalances memory _cacheEntry = cachedConsEFxEBals[_amoAddress];

                // If the caller wants to force a live calc, or the cache is stale
                if (_cacheEntry.isStale || _forceLive) {
                    IfrxEthV2AMOHelper.ShowAmoBalancedAllocsPacked memory _packedBals = IfrxEthV2AMOHelper(
                        IfrxEthV2AMO(_amoAddress).amoHelper()
                    ).getConsolidatedEthFrxEthBalancePacked(_amoAddress);

                    // Add to the return totals
                    _rtnTtlBalances.ethFree += _packedBals.amoEthFree;
                    _rtnTtlBalances.ethInLpBalanced += _packedBals.amoEthInLpBalanced;
                    _rtnTtlBalances.ethTotalBalanced += _packedBals.amoEthTotalBalanced;
                    _rtnTtlBalances.frxEthFree += _packedBals.amoFrxEthFree;
                    _rtnTtlBalances.frxEthInLpBalanced += _packedBals.amoFrxEthInLpBalanced;

                    // If the cache should be updated (per the input params)
                    if (_previewUpdateCache) {
                        // Push to the return array
                        // Would have rather wrote to storage here, but the compiler complained about the view "mutability"
                        _cachesToUpdateLocal[i] = CachedConsEFxBalances(
                            false,
                            _amoAddress,
                            _packedBals.amoEthFree,
                            _packedBals.amoEthInLpBalanced,
                            _packedBals.amoEthTotalBalanced,
                            _packedBals.amoFrxEthFree,
                            _packedBals.amoFrxEthInLpBalanced
                        );
                    }
                } else {
                    // Otherwise, just read from the cache
                    _rtnTtlBalances.ethFree += _cacheEntry.ethFree;
                    _rtnTtlBalances.ethInLpBalanced += _cacheEntry.ethInLpBalanced;
                    _rtnTtlBalances.ethTotalBalanced += _cacheEntry.ethTotalBalanced;
                    _rtnTtlBalances.frxEthFree += _cacheEntry.frxEthFree;
                    _rtnTtlBalances.frxEthInLpBalanced += _cacheEntry.frxEthInLpBalanced;
                }
            }
            unchecked {
                ++i;
            }
        }

        // Update the return value
        _cachesToUpdate = _cachesToUpdateLocal;
    }

    /// @notice Get frxETH/sfrxETH and ETH/LSD/WETH balances
    /// @param _forceLive Force a live recalculation of the AMO values
    /// @param _updateCache Whether to update the cache
    /// @return _rtnBalances frxETH/sfrxETH and ETH/LSD/WETH balances
    function getConsolidatedEthFrxEthBalance(
        bool _forceLive,
        bool _updateCache
    ) external returns (CachedConsEFxBalances memory _rtnBalances) {
        CachedConsEFxBalances[] memory _cachesToUpdate;
        // Determine the route
        if (_updateCache) {
            // Fetch the return balances as well as the new balances to cache
            (_rtnBalances, _cachesToUpdate) = _getConsolidatedEthFrxEthBalanceViewCore(_forceLive, true);

            // Loop through the caches and store them
            for (uint256 i = 0; i < _cachesToUpdate.length; ) {
                // Get the address of the AMO
                address _amoAddress = _cachesToUpdate[i].amoAddress;

                // Skip caches that don't need to be updated
                if (_amoAddress != address(0)) {
                    // Update storage
                    cachedConsEFxEBals[_amoAddress] = _cachesToUpdate[i];
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            // Don't care about updating the cache, so return early
            (_rtnBalances, ) = _getConsolidatedEthFrxEthBalanceViewCore(_forceLive, false);
        }
    }

    /// @notice Get frxETH/sfrxETH and ETH/LSD/WETH balances
    /// @param _forceLive Force a live recalculation of the AMO values
    /// @return _rtnBalances frxETH/sfrxETH and ETH/LSD/WETH balances
    function getConsolidatedEthFrxEthBalanceView(
        bool _forceLive
    ) external view returns (CachedConsEFxBalances memory _rtnBalances) {
        // Return the view-only component
        (_rtnBalances, ) = _getConsolidatedEthFrxEthBalanceViewCore(_forceLive, false);
    }

    // ========================================================
    // CALLED BY LENDING POOL
    // ========================================================

    /// @notice Lending Pool or Minter or otherwise -> ETH -> This Ether Router
    function depositEther() external payable {
        // Do nothing for now except accepting the ETH
    }

    /// @notice Use a private transaction. Router will deposit ETH first into the redemption queue, if there is a shortage. Any leftover ETH goes to the default depositToAmoAddr.
    /// @param _amount Amount to sweep. Will use contract balance if = 0
    /// @param _depositAndVault Whether you want to just dump the ETH in the Curve AMO, or if you want to wrap and vault it too
    function sweepEther(uint256 _amount, bool _depositAndVault) external {
        _requireIsTimelockOrOperator();

        // Add interest first
        lendingPool.addInterest(false);

        // Use the entire contract balance if _amount is 0
        if (_amount == 0) _amount = address(this).balance;

        // See if the redemption queue has a shortage
        (, uint256 _rqShortage) = redemptionQueue.ethShortageOrSurplus();

        // Take care of any shortage first
        if (_amount <= _rqShortage) {
            // Give all you can to help address the shortage
            (bool sent, ) = payable(redemptionQueue).call{ value: _amount }("");
            if (!sent) revert EthTransferFailedER(0);

            emit EtherSwept(address(redemptionQueue), _amount);
        } else {
            // First fulfill the shortage, if any
            if (_rqShortage > 0) {
                (bool sent, ) = payable(redemptionQueue).call{ value: _rqShortage }("");
                if (!sent) revert EthTransferFailedER(1);

                emit EtherSwept(address(redemptionQueue), _rqShortage);
            }

            // Calculate the remaining ETH
            uint256 _remainingEth = _amount - _rqShortage;

            // Make sure the AMO is not the zero address, then deposit to it
            if (depositToAmoAddr != address(0)) {
                // Send ETH to the AMO. Either 1) Leave it alone, or 2) Deposit it into cvxLP + vault it
                if (_depositAndVault) {
                    // Drop in, deposit, and vault
                    IfrxEthV2AMO(depositToAmoAddr).depositEther{ value: _remainingEth }();
                } else {
                    // Drop in only
                    (bool sent, ) = payable(depositToAmoAddr).call{ value: _remainingEth }("");
                    if (!sent) revert EthTransferFailedER(2);
                }

                // Mark the getConsolidatedEthFrxEthBalance cache as stale for this AMO
                cachedConsEFxEBals[depositToAmoAddr].isStale = true;
            }

            emit EtherSwept(depositToAmoAddr, _remainingEth);
        }
    }

    /// @notice See how ETH would flow if requestEther were called
    /// @param _ethRequested Amount of ETH requested
    /// @return _currEthInRouter How much ETH is currently in this contract
    /// @return _rqShortage How much the ETH shortage in the redemption queue is, if any
    /// @return _pullFromAmosAmount How much ETH would need to be pulled from various AMO(s)
    function previewRequestEther(
        uint256 _ethRequested
    ) public view returns (uint256 _currEthInRouter, uint256 _rqShortage, uint256 _pullFromAmosAmount) {
        // See how much ETH is already in this contract
        _currEthInRouter = address(this).balance;

        // See if the redemption queue has a shortage
        (, _rqShortage) = redemptionQueue.ethShortageOrSurplus();

        // Determine where to get the ETH from
        if ((_ethRequested + _rqShortage) <= _currEthInRouter) {
            // Do nothing, the ETH will be pulled from existing funds in this contract
        } else {
            // Calculate the extra amount needed from various AMO(s)
            _pullFromAmosAmount = _ethRequested + _rqShortage - _currEthInRouter;
        }
    }

    /// @notice AMO(s) -> ETH -> (Lending Pool or Redemption Queue). Instruct the router to get ETH from various AMO(s) (free and vaulted)
    /// @param _recipient Recipient of the ETH
    /// @param _ethRequested Amount of ETH requested
    /// @param _bypassFullRqShortage If someone wants to redeem and _rqShortage is too large, send back what you can
    /// @dev Need to pay off any shortage in the redemption queue first
    function requestEther(
        address payable _recipient,
        uint256 _ethRequested,
        bool _bypassFullRqShortage
    ) external nonReentrant {
        _requireSenderIsLendingPoolOrRedemptionQueue();

        // See where the ETH is and where it needs to go
        (uint256 _currEthInRouter, uint256 _rqShortage, uint256 _pullFromAmosAmount) = previewRequestEther(
            _ethRequested
        );

        // Pull the extra amount needed from the AMO(s) first, if necessary
        uint256 _remainingEthToPull = _pullFromAmosAmount;

        // If _bypassFullRqShortage is true, we don't care about the full RQ shortage
        if (_bypassFullRqShortage) {
            if (_ethRequested <= _currEthInRouter) {
                // The ETH will be pulled from existing funds in this contract
                _remainingEthToPull = 0;
            } else {
                // Calculate the extra amount needed from various AMO(s)
                _remainingEthToPull = _ethRequested - _currEthInRouter;
            }
        }

        // Start pulling from the AMOs, with primaryWithdrawFromAmoAddr being preferred
        if (_remainingEthToPull > 0) {
            // Order the amos
            address[] memory _sortedAmos = new address[](amosArray.length);

            // Handle primaryWithdrawFromAmoAddr
            if (primaryWithdrawFromAmoAddr != address(0)) {
                // primaryWithdrawFromAmoAddr should be first
                _sortedAmos[0] = primaryWithdrawFromAmoAddr;

                // Loop through all the AMOs and fill _sortedAmos
                uint256 _nextIdx = 1; // [0] is always primaryWithdrawFromAmoAddr
                for (uint256 i = 0; i < amosArray.length; ++i) {
                    // Don't double add primaryWithdrawFromAmoAddr
                    if (amosArray[i] == primaryWithdrawFromAmoAddr) continue;

                    // Push the remaining AMOs in
                    _sortedAmos[_nextIdx] = amosArray[i];

                    // Increment the next index to insert at
                    ++_nextIdx;
                }
            } else {
                _sortedAmos = amosArray;
            }

            // Loop through the AMOs and pull out ETH
            for (uint256 i = 0; i < _sortedAmos.length; ) {
                if (_sortedAmos[i] != address(0)) {
                    // Pull Ether from an AMO. May return a 0, partial, or full amount
                    (uint256 _ethOut, ) = IfrxEthV2AMO(_sortedAmos[i]).requestEtherByRouter(_remainingEthToPull);

                    // Account for the collected Ether
                    _remainingEthToPull -= _ethOut;

                    // If ETH was removed, mark the getConsolidatedEthFrxEthBalance cache as stale for this AMO
                    if (_ethOut > 0) cachedConsEFxEBals[_sortedAmos[i]].isStale = true;

                    // Stop looping if it collected enough
                    if (_remainingEthToPull == 0) break;
                    unchecked {
                        ++i;
                    }
                }
            }
        }

        // Fail early if you didn't manage to collect enough, but see if it is a dust amount first
        if (_remainingEthToPull > 0) revert NotEnoughEthPulled(_remainingEthToPull);

        // Give the shortage ETH to the redemption queue, if necessary and not bypassed
        if (!_bypassFullRqShortage && (_rqShortage > 0)) {
            (bool sent, ) = payable(redemptionQueue).call{ value: _rqShortage }("");
            if (!sent) revert EthTransferFailedER(2);
        }

        // Give remaining ETH to the recipient (could be the redemption queue)
        (bool sent, ) = payable(_recipient).call{ value: _ethRequested }("");
        if (!sent) revert EthTransferFailedER(3);

        emit EtherRequested(payable(_recipient), _ethRequested, _rqShortage);
    }

    /// @notice Needs to be here to receive ETH
    receive() external payable {
        // Do nothing for now.
    }

    // ========================================================
    // RESTRICTED GOVERNANCE FUNCTIONS
    // ========================================================

    // Adds an AMO
    /// @param _amoAddress Address of the AMO to add
    function addAmo(address _amoAddress) external {
        _requireSenderIsTimelock();
        if (_amoAddress == address(0)) revert ZeroAddress();

        // Need to make sure at least that getConsolidatedEthFrxEthBalance is present
        // This will revert if it isn't there
        IfrxEthV2AMOHelper(IfrxEthV2AMO(_amoAddress).amoHelper()).getConsolidatedEthFrxEthBalance(_amoAddress);

        // Make sure the AMO isn't already here
        if (amos[_amoAddress]) revert AmoAlreadyExists();

        // Update state
        amos[_amoAddress] = true;
        amosArray.push(_amoAddress);

        emit FrxEthAmoAdded(_amoAddress);
    }

    // Removes an AMO
    /// @param _amoAddress Address of the AMO to remove
    function removeAmo(address _amoAddress) external {
        _requireSenderIsTimelock();
        if (_amoAddress == address(0)) revert ZeroAddress();
        if (!amos[_amoAddress]) revert AmoAlreadyOffOrMissing();

        // Delete from the mapping
        delete amos[_amoAddress];

        // 'Delete' from the array by setting the address to 0x0
        for (uint256 i = 0; i < amosArray.length; ) {
            if (amosArray[i] == _amoAddress) {
                amosArray[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
            unchecked {
                ++i;
            }
        }

        emit FrxEthAmoRemoved(_amoAddress);
    }

    /// @notice Set preferred AMO addresses to deposit to / withdraw from
    /// @param _depositToAddress New address for the ETH deposit destination
    /// @param _withdrawFromAddress New address for the primary ETH withdrawal source
    function setPreferredDepositAndWithdrawalAMOs(address _depositToAddress, address _withdrawFromAddress) external {
        _requireIsTimelockOrOperator();

        // Make sure they are actually AMOs
        if (!amos[_depositToAddress] || !amos[_withdrawFromAddress]) revert InvalidAmo();

        // Set the addresses
        depositToAmoAddr = _depositToAddress;
        primaryWithdrawFromAmoAddr = _withdrawFromAddress;

        emit PreferredDepositAndWithdrawalAmoAddressesSet(_depositToAddress, _withdrawFromAddress);
    }

    /// @notice Sets the lending pool, where ETH is taken from / given to
    /// @param _newAddress New address for the lending pool
    function setLendingPool(address _newAddress) external {
        _requireSenderIsTimelock();
        _setLendingPool(payable(_newAddress));
    }

    /// @notice Change the Operator address
    /// @param _newOperatorAddress Operator address
    function setOperatorAddress(address _newOperatorAddress) external {
        _requireSenderIsTimelock();
        _setOperator(_newOperatorAddress);
    }

    /// @notice Sets the redemption queue, where frxETH is redeemed for ETH. Only callable once
    /// @param _newAddress New address for the redemption queue
    function setRedemptionQueue(address _newAddress) external {
        _requireSenderIsTimelock();

        // Only can set once
        if (payable(redemptionQueue) != payable(0)) revert RedemptionQueueAddressAlreadySet();

        _setFraxEtherRedemptionQueueV2(payable(_newAddress));
    }

    // ========================================================
    // ERRORS
    // ========================================================

    /// @notice When you are trying to add an AMO that already exists
    error AmoAlreadyExists();

    /// @notice When you are trying to remove an AMO that is already removed or doesn't exist
    error AmoAlreadyOffOrMissing();

    /// @notice When an Ether transfer fails
    /// @param step A marker in the code where it is failing
    error EthTransferFailedER(uint256 step);

    /// @notice When you are trying to interact with an invalid AMO
    error InvalidAmo();

    /// @notice If requestEther was unable to pull enough ETH from AMOs to satify a request
    /// @param remainingEth The amount remaining that was unable to be pulled
    error NotEnoughEthPulled(uint256 remainingEth);

    /// @notice Thrown if the sender is not the lending pool or the redemption queue
    error NotLendingPoolOrRedemptionQueue();

    /// @notice Thrown if the sender is not the timelock or the operator
    error NotTimelockOrOperator();

    /// @notice Thrown if the redemption queue address was already set
    error RedemptionQueueAddressAlreadySet();

    /// @notice When an provided address is address(0)
    error ZeroAddress();

    // ========================================================
    // EVENTS
    // ========================================================

    /// @notice When the preferred AMO addresses to deposit to / withdraw from are set
    /// @param depositToAddress Which AMO incoming ETH should be sent to
    /// @param withdrawFromAddress New address for the primary ETH withdrawal source
    event PreferredDepositAndWithdrawalAmoAddressesSet(address depositToAddress, address withdrawFromAddress);

    /// @notice When Ether is requested and sent out
    /// @param requesterAddress Address of the requester
    /// @param amountToRequester Amount of ETH sent to the requester
    /// @param amountToRedemptionQueue Amount of ETH sent to the redemption queue
    event EtherRequested(address requesterAddress, uint256 amountToRequester, uint256 amountToRedemptionQueue);

    /// @notice When Ether is moved from this contract into the redemption queue or AMO(s)
    /// @param destAddress Where the ETH was swept into
    /// @param amount Amount of the swept ETH
    event EtherSwept(address destAddress, uint256 amount);

    /// @notice When an AMO is added
    /// @param amoAddress The address of the added AMO
    event FrxEthAmoAdded(address amoAddress);

    /// @notice When an AMO is removed
    /// @param amoAddress The address of the removed AMO
    event FrxEthAmoRemoved(address amoAddress);
}

// src/contracts/frxeth-redemption-queue-v2/FraxEtherRedemptionQueueCore.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ===================== FraxEtherRedemptionQueue =====================
// ====================================================================
// Users wishing to exchange frxETH for ETH 1-to-1 will need to deposit their frxETH and wait to redeem it.
// When they do the deposit, they get an NFT with a maturity time as well as an amount.

// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

/// @notice Used by the constructor
/// @param timelockAddress Address of the timelock, which the main owner of the this contract
/// @param operatorAddress Address of the operator, which does other tasks
/// @param frxEthAddress Address of frxEth Erc20
/// @param sfrxEthAddress Address of sfrxEth Erc20
/// @param initialQueueLengthSecondss Initial length of the queue, in seconds
struct FraxEtherRedemptionQueueCoreParams {
    address timelockAddress;
    address operatorAddress;
    address frxEthAddress;
    address sfrxEthAddress;
    uint32 initialQueueLengthSeconds;
}

contract FraxEtherRedemptionQueueCore is ERC721, Timelock2Step, OperatorRole, PublicReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeCast for *;

    // ==============================================================================
    // Storage
    // ==============================================================================

    // Contracts
    // ================
    /// @notice The Ether Router
    EtherRouter public immutable etherRouter;

    // Tokens
    // ================
    /// @notice The frxETH token
    IFrxEth_0 public immutable FRX_ETH;

    /// @notice The sfrxETH token
    ISfrxEth_0 public immutable SFRX_ETH;

    // Version
    // ================
    string public version = "1.0.2";

    // Queue-Related
    // ================
    /// @notice State of Frax's frxETH redemption queue
    /// @param etherLiabilities How much ETH is currently under request to be redeemed
    /// @param nextNftId Autoincrement for the NFT id
    /// @param queueLengthSecs Current wait time (in seconds) a new redeemer would have. Should be close to Beacon.
    /// @param redemptionFee Redemption fee given as a percentage with 1e6 precision
    /// @param ttlEthRequested Cumulative total amount of ETH requested for redemption
    /// @param ttlEthServed Cumulative total amount of ETH and/or frxETH actually sent back to redeemers. ETH in the case of a mature redeem
    struct RedemptionQueueState {
        uint64 nextNftId;
        uint64 queueLengthSecs;
        uint64 redemptionFee;
        uint120 ttlEthRequested;
        uint120 ttlEthServed;
    }

    /// @notice State of Frax's frxETH redemption queue
    RedemptionQueueState public redemptionQueueState;

    /// @param etherLiabilities How much ETH would need to be paid out if every NFT holder could claim immediately
    /// @param unclaimedFees Earned fees that the protocol has not collected yet
    /// @param pendingFees Amount of fees expected if all outstanding NFTs were redeemed fully
    struct RedemptionQueueAccounting {
        uint120 etherLiabilities;
        uint120 unclaimedFees;
        uint120 pendingFees;
    }

    /// @notice Accounting of Frax's frxETH redemption queue
    RedemptionQueueAccounting public redemptionQueueAccounting;

    /// @notice Information about a user's redemption ticket NFT
    mapping(uint256 nftId => RedemptionQueueItem) public nftInformation;

    /// @notice The ```RedemptionQueueItem``` struct provides metadata information about each Nft
    /// @param hasBeenRedeemed boolean for whether the NFT has been redeemed
    /// @param amount How much ETH is claimable
    /// @param maturity Unix timestamp when they can claim their ETH
    /// @param redemptionFee redemptionFee (E6) at time of NFT mint
    /// @param ttlEthRequestedSnapshot ttlEthServed + (available ETH) must be >= ttlEthRequestedSnapshot. ttlEthRequestedSnapshot is redemptionQueueState.ttlEthRequested + (the amount of ETH you put in your redemption request) at the time of the enterRedemptionQueue call
    struct RedemptionQueueItem {
        bool hasBeenRedeemed;
        uint64 maturity;
        uint120 amount;
        uint64 redemptionFee;
        uint120 ttlEthRequestedSnapshot;
    }

    /// @notice Maximum queue length the operator can set, given in seconds
    uint256 public maxQueueLengthSeconds = 100 days;

    /// @notice Precision of the redemption fee
    uint64 public constant FEE_PRECISION = 1e6;

    /// @notice Maximum settable fee for redeeming
    uint64 public constant MAX_REDEMPTION_FEE = 20_000; // 2% max

    /// @notice Maximum amount of frxETH that can be used to create an NFT
    /// @dev If it were too large, the user could get stuck for a while until loans get paid back, or more people deposit ETH for frxETH
    uint120 public constant MAX_FRXETH_PER_NFT = 1000 ether;

    /// @notice The fee recipient for various fees
    address public feeRecipient;

    // ==============================================================================
    // Constructor
    // ==============================================================================

    /// @notice Constructor
    /// @param _params The contructor FraxEtherRedemptionQueueCoreParams params
    constructor(
        FraxEtherRedemptionQueueCoreParams memory _params,
        address payable _etherRouterAddress
    )
        payable
        ERC721("FrxETH Redemption Queue Ticket V2", "FrxETHRedemptionTicketV2")
        OperatorRole(_params.operatorAddress)
        Timelock2Step(_params.timelockAddress)
    {
        // Initialize some state variables
        if (_params.initialQueueLengthSeconds > maxQueueLengthSeconds) {
            revert ExceedsMaxQueueLengthSecs(_params.initialQueueLengthSeconds, maxQueueLengthSeconds);
        }
        redemptionQueueState.queueLengthSecs = _params.initialQueueLengthSeconds;
        FRX_ETH = IFrxEth_0(_params.frxEthAddress);
        SFRX_ETH = ISfrxEth_0(_params.sfrxEthAddress);
        etherRouter = EtherRouter(_etherRouterAddress);

        // Default the fee recipient to the operator (can be changed later)
        feeRecipient = _params.operatorAddress;
    }

    /// @notice Allows contract to receive Eth
    receive() external payable {
        // Do nothing except take in the Eth
    }

    // =============================================================================================
    // Configurations / Privileged functions
    // =============================================================================================

    /// @notice When the accrued redemption fees are collected
    /// @param recipient The address to receive the fees
    /// @param collectAmount Amount of fees collected
    event CollectRedemptionFees(address recipient, uint120 collectAmount);

    /// @notice Collect all redemption fees (in frxETH)
    function collectAllRedemptionFees() external returns (uint120 _collectedAmount) {
        // Call the internal function
        return _collectRedemptionFees(0, true);
    }

    /// @notice Collect a specified amount of redemption fees (in frxETH)
    /// @param _collectAmount Amount of frxEth to collect
    function collectRedemptionFees(uint120 _collectAmount) external returns (uint120 _collectedAmount) {
        // Call the internal function
        _collectRedemptionFees(_collectAmount, false);
    }

    /// @notice Collect redemption fees (in frxETH).
    /// @param _collectAmount Amount of frxEth to collect.
    /// @param _collectAllOverride If true, _collectAmount is overriden with redemptionQueueAccounting.unclaimedFees and all available fees are collected
    function _collectRedemptionFees(
        uint120 _collectAmount,
        bool _collectAllOverride
    ) internal returns (uint120 _collectedAmount) {
        // Make sure the sender is either the timelock, operator, or fee recipient
        _requireIsTimelockOperatorOrFeeRecipient();

        // Get the amount of unclaimed fees
        uint120 _unclaimedFees = redemptionQueueAccounting.unclaimedFees;

        // See if there is the override
        if (_collectAllOverride) _collectAmount = _unclaimedFees;

        // Make sure you are not taking too much
        if (_collectAmount > _unclaimedFees) revert ExceedsCollectedFees(_collectAmount, _unclaimedFees);

        // Decrement the unclaimed fee amount
        redemptionQueueAccounting.unclaimedFees -= _collectAmount;

        // Interactions: Transfer frxEth fees to the recipient
        IERC20(address(FRX_ETH)).safeTransfer({ to: feeRecipient, value: _collectAmount });

        emit CollectRedemptionFees({ recipient: feeRecipient, collectAmount: _collectAmount });

        return _collectAmount;
    }

    /// @notice When the timelock or operator recovers ERC20 tokens mistakenly sent here
    /// @param recipient Address of the recipient
    /// @param token Address of the erc20 token
    /// @param amount Amount of the erc20 token recovered
    event RecoverErc20(address recipient, address token, uint256 amount);

    /// @notice Recovers ERC20 tokens mistakenly sent to this contract
    /// @param _tokenAddress Address of the token
    /// @param _tokenAmount Amount of the token
    function recoverErc20(address _tokenAddress, uint256 _tokenAmount) external {
        _requireSenderIsTimelock();
        IERC20(_tokenAddress).safeTransfer({ to: msg.sender, value: _tokenAmount });
        emit RecoverErc20({ recipient: msg.sender, token: _tokenAddress, amount: _tokenAmount });
    }

    /// @notice The EtherRecovered event is emitted when recoverEther is called
    /// @param recipient Address of the recipient
    /// @param amount Amount of the ether recovered
    event RecoverEther(address recipient, uint256 amount);

    /// @notice Recover ETH when someone mistakenly directly sends ETH here
    /// @param _amount Amount of ETH to recover
    function recoverEther(uint256 _amount) external {
        _requireSenderIsTimelock();

        (bool _success, ) = address(msg.sender).call{ value: _amount }("");
        if (!_success) revert InvalidEthTransfer();

        emit RecoverEther({ recipient: msg.sender, amount: _amount });
    }

    /// @notice When the redemption fee is set
    /// @param oldRedemptionFee Old redemption fee
    /// @param newRedemptionFee New redemption fee
    event SetRedemptionFee(uint64 oldRedemptionFee, uint64 newRedemptionFee);

    /// @notice Sets the fee for redeeming
    /// @param _newFee New redemption fee given in percentage terms, using 1e6 precision
    function setRedemptionFee(uint64 _newFee) external {
        _requireSenderIsTimelock();
        if (_newFee > MAX_REDEMPTION_FEE) revert ExceedsMaxRedemptionFee(_newFee, MAX_REDEMPTION_FEE);

        emit SetRedemptionFee({ oldRedemptionFee: redemptionQueueState.redemptionFee, newRedemptionFee: _newFee });

        redemptionQueueState.redemptionFee = _newFee;
    }

    /// @notice When the current wait time (in seconds) of the queue is set
    /// @param oldQueueLength Old queue length in seconds
    /// @param newQueueLength New queue length in seconds
    event SetQueueLengthSeconds(uint64 oldQueueLength, uint64 newQueueLength);

    /// @notice Sets the current wait time (in seconds) a new redeemer would have
    /// @param _newLength New queue time, in seconds
    function setQueueLengthSeconds(uint64 _newLength) external {
        _requireIsTimelockOrOperator();
        if (msg.sender != timelockAddress && _newLength > maxQueueLengthSeconds) {
            revert ExceedsMaxQueueLengthSecs(_newLength, maxQueueLengthSeconds);
        }

        emit SetQueueLengthSeconds({
            oldQueueLength: redemptionQueueState.queueLengthSecs,
            newQueueLength: _newLength
        });

        redemptionQueueState.queueLengthSecs = _newLength;
    }

    /// @notice When the max queue length the operator can set is changed
    /// @param oldMaxQueueLengthSecs Old max queue length in seconds
    /// @param newMaxQueueLengthSecs New max queue length in seconds
    event SetMaxQueueLengthSeconds(uint256 oldMaxQueueLengthSecs, uint256 newMaxQueueLengthSecs);

    /// @notice Sets the maximum queue length the operator can set
    /// @param _newMaxQueueLengthSeconds New maximum queue length
    function setMaxQueueLengthSeconds(uint256 _newMaxQueueLengthSeconds) external {
        _requireSenderIsTimelock();

        emit SetMaxQueueLengthSeconds({
            oldMaxQueueLengthSecs: maxQueueLengthSeconds,
            newMaxQueueLengthSecs: _newMaxQueueLengthSeconds
        });

        maxQueueLengthSeconds = _newMaxQueueLengthSeconds;
    }

    /// @notice Sets the operator (bot) that updates the queue length
    /// @param _newOperator New bot address
    function setOperator(address _newOperator) external {
        _requireSenderIsTimelock();
        _setOperator(_newOperator);
    }

    /// @notice When the fee recipient is set
    /// @param oldFeeRecipient Old fee recipient address
    /// @param newFeeRecipient New fee recipient address
    event SetFeeRecipient(address oldFeeRecipient, address newFeeRecipient);

    /// @notice Where redemption fees go
    /// @param _newFeeRecipient New fee recipient address
    function setFeeRecipient(address _newFeeRecipient) external {
        _requireSenderIsTimelock();

        emit SetFeeRecipient({ oldFeeRecipient: feeRecipient, newFeeRecipient: _newFeeRecipient });

        feeRecipient = _newFeeRecipient;
    }

    // ==============================================================================
    // Helper views
    // ==============================================================================

    /// @notice See if you can redeem the given NFT.
    /// @param _nftId The ID of the FrxEthRedemptionTicket NFT
    /// @param _partialAmount The partial amount you want to redeem. Leave as 0 for a full redemption test
    /// @param _revertIfFalse If true, will revert if false
    /// @return _isRedeemable If the NFT can be redeemed with the specified _partialAmount
    /// @return _maxAmountRedeemable The max amount you can actually redeem. Will be <= your full position amount. May be 0 if your queue position or something else is wrong.
    function canRedeem(
        uint256 _nftId,
        uint120 _partialAmount,
        bool _revertIfFalse
    ) public view returns (bool _isRedeemable, uint120 _maxAmountRedeemable) {
        // Get NFT information
        RedemptionQueueItem memory _redemptionQueueItem = nftInformation[_nftId];

        // Different routes depending on the _partialAmount input
        if (_partialAmount > 0) {
            // Call the internal function
            (_isRedeemable, _maxAmountRedeemable) = _canRedeem(_redemptionQueueItem, _partialAmount, _revertIfFalse);
        } else {
            // Call the internal function
            (_isRedeemable, _maxAmountRedeemable) = _canRedeem(
                _redemptionQueueItem,
                _redemptionQueueItem.amount,
                _revertIfFalse
            );
        }
    }

    /// @notice See if you can partially redeem the given NFT.
    /// @param _redemptionQueueItem The ID of the FrxEthRedemptionTicket NFT
    /// @param _amountRequested The amount you want to redeem
    /// @param _revertIfFalse If true, will revert if false. Otherwise returns a boolean
    /// @return _isRedeemable If the NFT can be redeemed with the specified _amountRequested
    /// @return _maxAmountRedeemable The max amount you can actually redeem. Will be <= your full position amount. May be 0 if your queue position or something else is wrong.
    /// @dev A partial redeem can not be used to 'cut' in line for the queue. Your queue position is always as if you tried to redeem fully
    function _canRedeem(
        RedemptionQueueItem memory _redemptionQueueItem,
        uint120 _amountRequested,
        bool _revertIfFalse
    ) internal view returns (bool _isRedeemable, uint120 _maxAmountRedeemable) {
        // Check Maturity
        // -----------------------------------------------------------
        // See if the maturity has been reached and it hasn't already been redeemed
        if (block.timestamp >= _redemptionQueueItem.maturity && !_redemptionQueueItem.hasBeenRedeemed) {
            // So far so good
            _isRedeemable = true;
        } else {
            // Either revert or mark _isRedeemable as false
            if (_revertIfFalse) {
                revert NotMatureYet({ currentTime: block.timestamp, maturity: _redemptionQueueItem.maturity });
            } else {
                // Return early
                return (false, 0);
            }
        }

        // Check for full redeem
        // Special case if _amountRequested is 0, then set it to _redemptionQueueItem.amount
        if (_amountRequested == 0) _amountRequested = _redemptionQueueItem.amount;

        // Calculate how much ETH is present and/or pullable
        // -----------------------------------------------------------
        // Get the actual amount of ETH needed, accounting for the fee
        uint120 _amountReqMinusFee = _amountRequested -
            ((uint256(_amountRequested) * uint256(_redemptionQueueItem.redemptionFee)) / FEE_PRECISION).toUint120();

        // Get the ETH balance in this contract
        uint120 _localBal = uint120(address(this).balance);

        // Get the amount of ETH pullable from the Ether Router
        EtherRouter.CachedConsEFxBalances memory _cachedBals = etherRouter.getConsolidatedEthFrxEthBalanceView(true);
        uint120 _pullableBal = uint120(_cachedBals.ethTotalBalanced);
        uint120 _availableBal = _localBal + _pullableBal;

        // See if enough is present and/or pullable to satisfy the NFT
        // -----------------------------------------------------------

        // If the NFT amount is more than the local Eth and the pullable Eth, you cannot redeem
        if (_amountReqMinusFee > _availableBal) {
            // Either revert or mark _isRedeemable as false
            if (_revertIfFalse) {
                revert InsufficientEth({ requested: _amountReqMinusFee, available: _availableBal });
            } else {
                // Don't return yet
                _isRedeemable = false;
            }
        }

        // Check queue position.
        // -----------------------------------------------------------
        // Get queue information
        RedemptionQueueState memory _redemptionQueueState = redemptionQueueState;

        // What ttlEthServed would be if everyone redeemed who could, with the available balance from contracts, AMOs, etc.
        uint120 _maxTtlEthServed = _redemptionQueueState.ttlEthServed + _availableBal;

        // The max amount of ETH that can be used to serve YOU specifically
        uint120 _maxTtlEthServeableToYou;
        if (_maxTtlEthServed >= _redemptionQueueItem.ttlEthRequestedSnapshot) {
            _maxTtlEthServeableToYou = _maxTtlEthServed - _redemptionQueueItem.ttlEthRequestedSnapshot;
        } else {
            (_maxTtlEthServeableToYou = 0);
        }

        // _amountReqMinusFee must be <= _maxTtlEthServeableToYou
        if (_amountReqMinusFee <= _maxTtlEthServeableToYou) {
            // Do nothing since _isRedeemable is already true
        } else {
            // Either revert or mark _isRedeemable as false
            if (_revertIfFalse) {
                revert QueuePosition({
                    ttlEthRequestedSnapshot: _redemptionQueueItem.ttlEthRequestedSnapshot,
                    requestedAmount: _amountReqMinusFee,
                    maxTtlEthServed: _maxTtlEthServed
                });
            } else {
                // Don't return yet
                _isRedeemable = false;
            }
        }

        // Update _maxAmountRedeemable
        // -----------------------------------------------------------
        // For starters, it should never be more than your actual position
        _maxAmountRedeemable = _redemptionQueueItem.amount;

        // Lower _maxAmountRedeemable if there isn't enough ETH
        if (_maxAmountRedeemable > _availableBal) _maxAmountRedeemable = _availableBal;

        // Lower _maxAmountRedeemable again if there is some ETH, but you cannot have it because others are in front of you
        if (_maxAmountRedeemable > _maxTtlEthServeableToYou) _maxAmountRedeemable = _maxTtlEthServeableToYou;

        // You cannot request more than you are entitled too
        // -----------------------------------------------------------

        // See if you are requesting more than you should
        if (_amountRequested > _redemptionQueueItem.amount) {
            // Either revert or mark _isRedeemable as false
            if (_revertIfFalse) {
                revert RedeemingTooMuch({ requested: _amountRequested, entitledTo: _redemptionQueueItem.amount });
            } else {
                // Don't return yet
                _isRedeemable = false;
            }
        }
    }

    /// @notice Get the entrancy status
    /// @return _isEntered If the contract has already been entered
    function entrancyStatus() external view returns (bool _isEntered) {
        _isEntered = _status == 2;
    }

    /// @notice How much shortage or surplus (to cover upcoming redemptions) this contract has
    /// @return _netEthBalance int256 Positive or negative balance of ETH
    /// @return _shortage uint256 The remaining amount of ETH needed to cover all redemptions. 0 if there is no shortage or a surplus.
    function ethShortageOrSurplus() external view returns (int256 _netEthBalance, uint256 _shortage) {
        // // Protect against reentrancy (not entered yet)
        // require(_status == 1, "ethShortageOrSurplus reentrancy");

        // Current ETH balance of this contract
        int256 _currBalance = int256(address(this).balance);

        // Total amount of ETH needed to cover all outstanding redemptions
        int256 _currLiabilities = int256(uint256(redemptionQueueAccounting.etherLiabilities));

        // Subtract pending fees since these technically will part of a surplus
        _currLiabilities -= int256(uint256(redemptionQueueAccounting.pendingFees));

        // Calculate the shortage or surplus
        _netEthBalance = _currBalance - _currLiabilities;

        // If there is a shortage, convert it to uint256
        if (_netEthBalance < 0) _shortage = uint256(-_netEthBalance);
    }

    // =============================================================================================
    // Queue Functions
    // =============================================================================================

    /// @notice When someone enters the redemption queue
    /// @param nftId The ID of the NFT
    /// @param sender The address of the msg.sender, who is redeeming frxEth
    /// @param recipient The recipient of the NFT
    /// @param amountFrxEthRedeemed The amount of frxEth requested to be redeemed
    /// @param maturityTimestamp The date of maturity, upon which redemption is allowed
    /// @param redemptionFee The redemption fee (E6) at the time of minting
    /// @param ttlEthRequestedSnapshot ttlEthRequested + amountFrxEthRedeemed at the time of the enterRedemptionQueue
    event EnterRedemptionQueue(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint256 amountFrxEthRedeemed,
        uint64 maturityTimestamp,
        uint64 redemptionFee,
        uint120 ttlEthRequestedSnapshot
    );

    /// @notice Enter the queue for redeeming frxEth 1-to-1 for Eth, without the need to approve first (EIP-712 / EIP-2612)
    /// @notice Will generate a FrxEthRedemptionTicket NFT that can be redeemed for the actual Eth later.
    /// @param _amountToRedeem Amount of frxETH to redeem. Must be < MAX_FRXETH_PER_NFT
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _deadline Deadline for this signature
    /// @param _nftId The ID of the FrxEthRedemptionTicket NFT
    function enterRedemptionQueueWithPermit(
        uint120 _amountToRedeem,
        address _recipient,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint256 _nftId) {
        // Call the permit
        FRX_ETH.permit({
            owner: msg.sender,
            spender: address(this),
            value: _amountToRedeem,
            deadline: _deadline,
            v: _v,
            r: _r,
            s: _s
        });

        // Do the redemption
        _nftId = enterRedemptionQueue({ _recipient: _recipient, _amountToRedeem: _amountToRedeem });
    }

    /// @notice Enter the queue for redeeming sfrxEth to frxETH at the current rate, then frxETH to Eth 1-to-1, without the need to approve first (EIP-712 / EIP-2612)
    /// @notice Will generate a FrxEthRedemptionTicket NFT that can be redeemed for the actual Eth later.
    /// @param _sfrxEthAmount Amount of sfrxETH to redeem (in shares / balanceOf). Resultant frxETH amount must be < MAX_FRXETH_PER_NFT
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _deadline Deadline for this signature
    /// @param _nftId The ID of the FrxEthRedemptionTicket NFT
    function enterRedemptionQueueWithSfrxEthPermit(
        uint120 _sfrxEthAmount,
        address _recipient,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint256 _nftId) {
        // Call the permit
        SFRX_ETH.permit({
            owner: msg.sender,
            spender: address(this),
            value: _sfrxEthAmount,
            deadline: _deadline,
            v: _v,
            r: _r,
            s: _s
        });

        // Do the redemption
        _nftId = enterRedemptionQueueViaSfrxEth({ _recipient: _recipient, _sfrxEthAmount: _sfrxEthAmount });
    }

    /// @notice Enter the queue for redeeming sfrxEth to frxETH at the current rate, then frxETH to ETH 1-to-1. Must have approved or permitted first.
    /// @notice Will generate a FrxETHRedemptionTicket NFT that can be redeemed for the actual ETH later.
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _sfrxEthAmount Amount of sfrxETH to redeem (in shares / balanceOf). Resultant frxETH amount must be < MAX_FRXETH_PER_NFT
    /// @param _nftId The ID of the FrxEthRedemptionTicket NFT
    /// @dev Must call approve/permit on frxEth contract prior to this call
    function enterRedemptionQueueViaSfrxEth(
        address _recipient,
        uint120 _sfrxEthAmount
    ) public returns (uint256 _nftId) {
        // Pull in the sfrxETH
        SFRX_ETH.transferFrom({ from: msg.sender, to: address(this), amount: uint256(_sfrxEthAmount) });

        // Exchange the sfrxETH for frxETH
        uint256 _frxEthAmount = SFRX_ETH.redeem(_sfrxEthAmount, address(this), address(this));

        // Enter the queue with the frxETH you just obtained
        _nftId = _enterRedemptionQueueCore(_recipient, uint120(_frxEthAmount));
    }

    /// @notice Enter the queue for redeeming frxETH 1-to-1. Must approve first. Internal only so payor can be set
    /// @notice Will generate a FrxETHRedemptionTicket NFT that can be redeemed for the actual ETH later.
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _amountToRedeem Amount of frxETH to redeem.
    /// @param _nftId The ID of the FrxEthRedemptionTicket NFT
    /// @dev Must call approve/permit on frxEth contract prior to this call
    function _enterRedemptionQueueCore(
        address _recipient,
        uint120 _amountToRedeem
    ) internal nonReentrant returns (uint256 _nftId) {
        // Don't allow too much frxETH per NFT, otherwise it can get hard to redeem later if borrow activity is high
        if (_amountToRedeem > MAX_FRXETH_PER_NFT) revert ExceedsMaxFrxEthPerNFT();

        // Get queue information
        RedemptionQueueState memory _redemptionQueueState = redemptionQueueState;
        RedemptionQueueAccounting memory _redemptionQueueAccounting = redemptionQueueAccounting;

        // Calculations: increment ether liabilities by the amount of ether owed to the user
        _redemptionQueueAccounting.etherLiabilities += _amountToRedeem;

        // Calculations: increment pending fees that will eventually be taken
        _redemptionQueueAccounting.pendingFees += ((uint256(_amountToRedeem) *
            uint256(_redemptionQueueState.redemptionFee)) / FEE_PRECISION).toUint120();

        // Calculations: maturity timestamp
        uint64 _maturityTimestamp = uint64(block.timestamp) + _redemptionQueueState.queueLengthSecs;

        // Effects: Initialize the redemption ticket NFT information
        nftInformation[_redemptionQueueState.nextNftId] = RedemptionQueueItem({
            amount: _amountToRedeem,
            maturity: _maturityTimestamp,
            hasBeenRedeemed: false,
            redemptionFee: _redemptionQueueState.redemptionFee,
            ttlEthRequestedSnapshot: _redemptionQueueState.ttlEthRequested // pre-increment
        });

        // Effects: Mint the redemption ticket NFT. Make sure the recipient supports ERC721.
        _safeMint({ to: _recipient, tokenId: _redemptionQueueState.nextNftId });

        // Emit here, before the state change
        _nftId = _redemptionQueueState.nextNftId;
        emit EnterRedemptionQueue({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            amountFrxEthRedeemed: _amountToRedeem,
            maturityTimestamp: _maturityTimestamp,
            redemptionFee: _redemptionQueueState.redemptionFee,
            ttlEthRequestedSnapshot: _redemptionQueueState.ttlEthRequested // pre-increment
        });

        // Calculations: Increment the ttlEthRequested.
        _redemptionQueueState.ttlEthRequested += _amountToRedeem;

        // Calculations: Increment the autoincrement
        ++_redemptionQueueState.nextNftId;

        // Effects: Write all of the state changes to storage
        redemptionQueueState = _redemptionQueueState;

        // Effects: Write all of the accounting changes to storage
        redemptionQueueAccounting = _redemptionQueueAccounting;
    }

    /// @notice Enter the queue for redeeming frxETH 1-to-1. Must approve or permit first.
    /// @notice Will generate a FrxETHRedemptionTicket NFT that can be redeemed for the actual ETH later.
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _amountToRedeem Amount of frxETH to redeem. Must be < MAX_FRXETH_PER_NFT
    /// @param _nftId The ID of the FrxEthRedemptionTicket NFT
    /// @dev Must call approve/permit on frxEth contract prior to this call
    function enterRedemptionQueue(address _recipient, uint120 _amountToRedeem) public returns (uint256 _nftId) {
        // Do all of the NFT-generating and accounting logic
        _nftId = _enterRedemptionQueueCore(_recipient, _amountToRedeem);

        // Interactions: Transfer frxEth in from the sender
        IERC20(address(FRX_ETH)).safeTransferFrom({ from: msg.sender, to: address(this), value: _amountToRedeem });
    }

    /// @notice When someone redeems their NFT for ETH
    /// @param nftId the if of the nft redeemed
    /// @param sender the msg.sender
    /// @param recipient the recipient of the ether
    /// @param amountOut the amount of ether sent to the recipient
    /// @param isPartial If it was a partial burn
    event BurnRedemptionTicketNft(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint120 amountOut,
        bool isPartial
    );

    /// @notice Redeems a FrxETHRedemptionTicket NFT for ETH. (Pre-ETH send)
    /// @param _nftId The ID of the NFT
    /// @param _redeemAmt The amount to redeem
    /// @return _redemptionQueueItem The RedemptionQueueItem
    function _handleRedemptionTicketNftPre(
        uint256 _nftId,
        uint120 _redeemAmt
    ) internal returns (RedemptionQueueItem memory _redemptionQueueItem) {
        // Checks: ensure proper NFT ownership
        if (!_isAuthorized({ owner: _requireOwned(_nftId), spender: msg.sender, tokenId: _nftId })) {
            revert Erc721CallerNotOwnerOrApproved();
        }

        // Get NFT information
        _redemptionQueueItem = nftInformation[_nftId];

        // Checks: Make sure maturity was reached
        // Will revert if it was not
        _canRedeem(_redemptionQueueItem, _redeemAmt, true);

        // Different paths for full vs partial
        if (_redeemAmt == 0 || _redeemAmt == _redemptionQueueItem.amount) {
            // Full Redeem
            // ---------------------------------------

            // Effects: burn the NFT
            _burn(_nftId);

            // Effects: Increment the ttlEthServed
            // Not including fees here so ttlEthRequested gets canceled out
            redemptionQueueState.ttlEthServed += _redemptionQueueItem.amount;

            // Effects: Zero the amount remaining in the NFT
            nftInformation[_nftId].amount = 0;

            // Effects: Mark NFT as redeemed
            nftInformation[_nftId].hasBeenRedeemed = true;
        } else {
            // Partial Redeem
            // ---------------------------------------

            // Effects: Increment the ttlEthServed
            // Not including fees here so ttlEthRequested gets canceled out
            redemptionQueueState.ttlEthServed += _redeemAmt;

            // Effects: Lower amount remaining in the NFT
            nftInformation[_nftId].amount -= _redeemAmt;
        }

        // IMPORTANT!!!
        // NOTE: Make sure redemptionQueueAccounting.etherLiabilities is accounted for somewhere down the line

        // IMPORTANT!!!
        // NOTE: Make sure to burn the frxETH somewhere down the line
    }

    // ====================================
    // Internal Functions
    // ====================================

    /// @notice Checks if msg.sender is current timelock address or the operator
    function _requireIsTimelockOrOperator() internal view {
        if (!((msg.sender == timelockAddress) || (msg.sender == operatorAddress))) revert NotTimelockOrOperator();
    }

    /// @notice Checks if msg.sender is current timelock address, operator, or fee recipient
    function _requireIsTimelockOperatorOrFeeRecipient() internal view {
        if (!((msg.sender == timelockAddress) || (msg.sender == operatorAddress) || (msg.sender == feeRecipient))) {
            revert NotTimelockOperatorOrFeeRecipient();
        }
    }

    /// @notice ERC721: caller is not token owner or approved
    error Erc721CallerNotOwnerOrApproved();

    /// @notice When timelock/operator tries collecting more fees than they are due
    /// @param collectAmount How much fee the ounsender is trying to collect
    /// @param accruedAmount How much fees are actually collectable
    error ExceedsCollectedFees(uint128 collectAmount, uint128 accruedAmount);

    /// @notice When someone tries setting the queue length above the max
    /// @param providedLength The provided queue length
    /// @param maxLength The maximum queue length
    error ExceedsMaxQueueLengthSecs(uint64 providedLength, uint256 maxLength);

    /// @notice When someone tries to create a redemption NFT using too much frxETH
    error ExceedsMaxFrxEthPerNFT();

    /// @notice When someone tries setting the redemption fee above MAX_REDEMPTION_FEE
    /// @param providedFee The provided redemption fee
    /// @param maxFee The maximum redemption fee
    error ExceedsMaxRedemptionFee(uint64 providedFee, uint64 maxFee);

    /// @notice Not enough ETH locally + Ether Router + AMOs to do the redemption
    /// @param available The amount of ETH actually available
    /// @param requested The amount of ETH requested
    error InsufficientEth(uint120 requested, uint120 available);

    /// @notice Invalid ETH transfer during recoverEther
    error InvalidEthTransfer();

    /// @notice NFT is not mature enough to redeem yet
    /// @param currentTime Current time.
    /// @param maturity Time of maturity
    error NotMatureYet(uint256 currentTime, uint64 maturity);

    /// @notice Thrown if the sender is not the timelock, operator, or fee recipient
    error NotTimelockOperatorOrFeeRecipient();

    /// @notice Thrown if the sender is not the timelock or the operator
    error NotTimelockOrOperator();

    /// @notice Other (earlier) people are ahead of you in the queue. ttlEthServed + (available ETH) must be >= ttlEthRequestedSnapshot + requestedAmount
    /// @param ttlEthRequestedSnapshot The NFT's snapshot of ttlEthRequested
    /// @param requestedAmount The actual amount being requested
    /// @param maxTtlEthServed What ttlEthServed would be if everyone redeemed who could, with the available balance from contracts, AMOs, etc.
    error QueuePosition(uint120 ttlEthRequestedSnapshot, uint120 requestedAmount, uint120 maxTtlEthServed);

    /// @notice When you try to redeem more than the NFT entitles you to
    /// @param requested The amount of ETH requested
    /// @param entitledTo The amount of ETH the NFT entitles you to
    error RedeemingTooMuch(uint120 requested, uint120 entitledTo);
}

// src/contracts/frxeth-redemption-queue-v2/FraxEtherRedemptionQueueV2.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ==================== FraxEtherRedemptionQueueV2 ====================
// ====================================================================
// Users wishing to exchange frxETH for ETH 1-to-1 will need to deposit their frxETH and wait to redeem it.
// When they do the deposit, they get an NFT with a maturity time as well as an amount.
// V2: Used in tandem with frxETH V2's Lending Pool

// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

contract FraxEtherRedemptionQueueV2 is FraxEtherRedemptionQueueCore {
    using SafeCast for *;

    constructor(
        FraxEtherRedemptionQueueCoreParams memory _params,
        address payable _etherRouterAddress
    ) FraxEtherRedemptionQueueCore(_params, _etherRouterAddress) {}

    // ==============================================================================
    // FraxEtherRedemptionQueue overrides
    // ==============================================================================

    /// @notice When someone redeems their NFT for ETH, burning it if it is a full redemption
    /// @param nftId the if of the nft redeemed
    /// @param sender the msg.sender
    /// @param recipient the recipient of the ether
    /// @param amountToRedeemer the amount fee kept
    /// @param amountToRedeemer the amount of ether sent to the recipient
    /// @param isPartial If it was a partial redemption
    event NftTicketRedemption(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint120 feeAmt,
        uint120 amountToRedeemer,
        bool isPartial
    );

    /// @notice Fully redeems a FrxETHRedemptionTicket NFT for ETH. Must have reached the maturity date first.
    /// @param _nftId The ID of the NFT
    /// @param _recipient The recipient of the redeemed ETH
    function fullRedeemNft(
        uint256 _nftId,
        address payable _recipient
    ) external nonReentrant returns (uint120 _amountEtherPaidToUser, uint120 _redemptionFeeAmount) {
        // Burn the NFT and update the state
        RedemptionQueueItem memory _redemptionQueueItem = _handleRedemptionTicketNftPre(_nftId, 0);

        // Calculations: redemption fee
        _redemptionFeeAmount = ((uint256(_redemptionQueueItem.amount) * uint256(_redemptionQueueItem.redemptionFee)) /
            FEE_PRECISION).toUint120();

        // Calculations: amount of ETH owed to the user
        _amountEtherPaidToUser = _redemptionQueueItem.amount - _redemptionFeeAmount;

        // Calculations: increment unclaimed fees by the redemption fee taken
        redemptionQueueAccounting.unclaimedFees += _redemptionFeeAmount;

        // Calculations: decrement pending fees by the redemption fee taken
        redemptionQueueAccounting.pendingFees -= _redemptionFeeAmount;

        // Effects: Burn frxEth 1:1. Unburnt amount stays as the fee
        FRX_ETH.burn(_amountEtherPaidToUser);

        // If you don't have enough ETH in this contract, pull in the missing amount from the Ether Router
        if (_amountEtherPaidToUser > payable(this).balance) {
            // See how much ETH you actually are missing
            uint256 _missingEth = _amountEtherPaidToUser - payable(this).balance;

            // Pull only what is needed and not the entire RQ shortage
            // If there is still not enough, the entire fullRedeemNft function will revert and the user should try partialRedeemNft
            etherRouter.requestEther(payable(this), _missingEth, true);
        }

        // Effects: Subtract the amount from total liabilities
        // Uses _redemptionQueueItem.amount vs _amountEtherPaidToUser here
        redemptionQueueAccounting.etherLiabilities -= _redemptionQueueItem.amount;

        // Transfer ETH to recipient, minus the fee, if any
        (bool sent, ) = payable(_recipient).call{ value: _amountEtherPaidToUser }("");
        if (!sent) revert InvalidEthTransfer();

        emit NftTicketRedemption({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            feeAmt: _redemptionFeeAmount,
            amountToRedeemer: _amountEtherPaidToUser,
            isPartial: false
        });
    }

    /// @notice Partially redeems a FrxETHRedemptionTicket NFT for ETH. Must have reached the maturity date first.
    /// @param _nftId The ID of the NFT
    /// @param _recipient The recipient of the redeemed ETH
    /// @param _redeemAmt The amount you want to redeem
    function partialRedeemNft(uint256 _nftId, address payable _recipient, uint120 _redeemAmt) external nonReentrant {
        // 0 is reserved for full redeems only
        if (_redeemAmt == 0) revert CannotRedeemZero();

        // Modify the NFT and update the state
        RedemptionQueueItem memory _redemptionQueueItem = _handleRedemptionTicketNftPre(_nftId, _redeemAmt);

        // Calculations: redemption fee
        uint120 _redemptionFeeAmount = ((uint256(_redeemAmt) * uint256(_redemptionQueueItem.redemptionFee)) /
            FEE_PRECISION).toUint120();

        // Calculations: amount of ETH owed to the user
        uint120 _amountEtherOwedToUser = _redeemAmt - _redemptionFeeAmount;

        // Calculations: increment unclaimed fees by the redemption fee taken
        redemptionQueueAccounting.unclaimedFees += _redemptionFeeAmount;

        // Calculations: decrement pending fees by the redemption fee taken
        redemptionQueueAccounting.pendingFees -= _redemptionFeeAmount;

        // Effects: Burn frxEth 1:1. Unburnt amount stays as the fee
        FRX_ETH.burn(_amountEtherOwedToUser);

        // Get the ETH
        // If you don't have enough ETH in this contract, pull in the missing amount from the Ether Router
        if (_amountEtherOwedToUser > payable(this).balance) {
            // See how much ETH you actually are missing
            uint256 _missingEth = _amountEtherOwedToUser - payable(this).balance;

            // Pull only what is needed and not the entire RQ shortage
            // If there is still not enough, the entire partialRedeemNft function will revert here and the user should resubmit with a lower _redeemAmt
            etherRouter.requestEther(payable(this), _missingEth, true);
        }

        // Effects: Subtract the amount from total liabilities
        // Uses _redeemAmt vs _amountEtherOwedToUser here
        redemptionQueueAccounting.etherLiabilities -= _redeemAmt;

        // Transfer ETH to recipient, minus the fee, if any
        (bool sent, ) = payable(_recipient).call{ value: _amountEtherOwedToUser }("");
        if (!sent) revert InvalidEthTransfer();

        emit NftTicketRedemption({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            feeAmt: _redemptionFeeAmount,
            amountToRedeemer: _amountEtherOwedToUser,
            isPartial: true
        });
    }

    // ====================================
    // Errors
    // ====================================

    /// @notice Cannot redeem zero
    error CannotRedeemZero();
}

// src/contracts/lending-pool/LendingPoolCore.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================= LendingPoolCore ==========================
// ====================================================================
// Recieves and gives out ETH to ValidatorPools for lending and borrowing (core code)

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

// import { console } from "frax-std/FraxTest.sol";

/// @notice Constructor information for the lending pool core
/// @param frxEthAddress Address of the frxETH token
/// @param timelockAddress The address of the governance timelock
/// @param etherRouterAddress The Ether Router address
/// @param beaconOracleAddress The Beacon Oracle address
/// @param redemptionQueueAddress The Redemption Queue address
/// @param interestRateCalculatorAddress Address used for interest rate calculations
/// @param eth2DepositAddress Address of the Eth2 deposit contract
/// @param fullUtilizationRate The interest rate at full utilization
struct LendingPoolCoreParams {
    address frxEthAddress;
    address timelockAddress;
    address payable etherRouterAddress;
    address beaconOracleAddress;
    address payable redemptionQueueAddress;
    address interestRateCalculatorAddress;
    address payable eth2DepositAddress;
    uint64 fullUtilizationRate;
}

/// @title Recieves and gives out ETH to ValidatorPools for lending and borrowing
/// @author Frax Finance
/// @notice Controlled by Frax governance and validator pools
abstract contract LendingPoolCore is
    EtherRouterRole,
    BeaconOracleRole,
    RedemptionQueueV2Role,
    Timelock2Step,
    PublicReentrancyGuard
{
    using SafeCast for uint256;
    using VaultAccountingLibrary for VaultAccount;

    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    /// @notice frxETH
    IFrxEth_1 public immutable frxETH;

    /// @notice The official Eth2 deposit contract
    IDepositContract public immutable ETH2_DEPOSIT_CONTRACT;

    /// @notice Precision for the utilization ratio
    uint256 public constant UTILIZATION_PRECISION = 1e5;

    /// @notice Precision for the interest rate
    uint256 public constant INTEREST_RATE_PRECISION = 1e18;

    /// @notice Total amount of ETH currently borrowed
    VaultAccount public totalBorrow;

    /// @notice Total amount of ETH interest accrued from lending out the ETH
    uint256 public interestAccrued;

    /// @notice Stored utilization rate, to mitigate manipulation. Updated with addInterest.
    uint256 public utilizationStored;

    /// @notice Contract for interest rate calculations
    IInterestRateCalculator public rateCalculator;

    /// @notice Multiplier for credits per vault calculations
    uint256 public immutable MISSING_CREDPERVAL_MULT = 1e6;

    /// @notice Minimum borrow amount (used to help with share rounding / prevent share manipulation)
    uint256 public constant MINIMUM_BORROW_AMOUNT = 1000 gwei;

    /// @notice ValidatorPool state information
    /// @param isInitialialized If the validator pool is initialized
    /// @param wasLiquidated If the validator pool is currently being liquidated
    /// @param lastWithdrawal The last time the validator pool made a withdrawal
    /// @param validatorCount The number of validators the pool has
    /// @param creditPerValidatorI48_E12 The amount of lending credit per validator. 12 decimals of precision. Max is ~281e12
    /// @param borrowShares How many shares the pool is currently borrowing
    struct ValidatorPoolAccount {
        bool isInitialized;
        bool wasLiquidated;
        uint32 lastWithdrawal;
        uint32 validatorCount;
        uint48 creditPerValidatorI48_E12;
        uint128 borrowAllowance;
        uint256 borrowShares;
    }

    /// @notice Validator pool account information
    mapping(address _validatorPool => ValidatorPoolAccount) public validatorPoolAccounts;

    /// @notice ValidatorPool pubkey deposit information
    /// @param whenValidatorApproved When the pubkey was approved by the beacon oracle. 0 if it was not
    /// @param wasFullDepositOrFinalized If the pubkey was either a full 32 ETH deposit, or if it was a partial that was finalized.
    /// @param validatorPoolAddress The validator pool associated with the pubkey
    /// @param userDepositedEther The amount of Eth the validator pool contributed. Will be less than 32 Eth for a partial deposit
    /// @param lendingPoolDepositedEther The amount of Eth the lending pool loaned to complete this deposit. Will be > 0 for a partial deposit.
    /// @dev Useful for tracking full vs partial deposits
    struct ValidatorDepositInfo {
        uint32 whenValidatorApproved;
        bool wasFullDepositOrFinalized;
        address validatorPoolAddress;
        uint96 userDepositedEther;
        uint96 lendingPoolDepositedEther;
    }

    /// @notice Validator pool deposit information
    mapping(bytes _validatorPublicKey => ValidatorDepositInfo) public validatorDepositInfo;

    /// @notice Current interest rate information (storage variable)
    CurrentRateInfo public currentRateInfo;

    /// @notice Current interest rate information (struct)
    /// @param lastTimestamp Timestamp of the last state update
    /// @param ratePerSec Interest rate, in e18 per second
    /// @param fullUtilizationRate The rate at full utilization
    struct CurrentRateInfo {
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
    }

    /// @notice Allowed liquidators
    mapping(address _addr => bool _canLiquidate) public isLiquidator;

    // ==============================================================================
    // Constructor
    // ==============================================================================

    /// @notice Constructor
    /// @param _params The LendingPoolCoreParams
    constructor(
        LendingPoolCoreParams memory _params
    )
        Timelock2Step(_params.timelockAddress)
        RedemptionQueueV2Role(_params.redemptionQueueAddress)
        EtherRouterRole(_params.etherRouterAddress)
        BeaconOracleRole(_params.beaconOracleAddress)
    {
        frxETH = IFrxEth_1(_params.frxEthAddress);
        rateCalculator = IInterestRateCalculator(_params.interestRateCalculatorAddress);
        currentRateInfo.fullUtilizationRate = _params.fullUtilizationRate;
        currentRateInfo.lastTimestamp = uint64(block.timestamp - 1);

        ETH2_DEPOSIT_CONTRACT = IDepositContract(_params.eth2DepositAddress);
    }

    // ==============================================================================
    // Check functions
    // ==============================================================================

    /// @notice Reverts if the pubkey is not associated with the validator pool address supplied
    /// @param _address The address of the validator pool that should be associated with the pubkey
    /// @param _publicKey The pubkey to check
    function _requireAddressAssociatedWithPubkey(address _address, bytes calldata _publicKey) internal view {
        if (validatorDepositInfo[_publicKey].validatorPoolAddress != _address) revert ValidatorPoolKeyMismatch();
    }

    /// @notice Reverts if the address cannot liquidate
    /// @param _address The address to check
    /// @dev Either an allowed liquidator, the timelock, or the beacon oracle
    function _requireAddressCanLiquidate(address _address) internal view {
        if (!(isLiquidator[_address] || (_address == timelockAddress) || (_address == address(beaconOracle)))) {
            revert NotAllowedLiquidator();
        }
    }

    /// @notice Reverts if the validator pubkey is not approved
    /// @param _publicKey The pubkey to check
    function _requireValidatorApproved(bytes calldata _publicKey) internal view {
        if (!isValidatorApproved(_publicKey)) revert ValidatorIsNotApprovedLP();
    }

    /// @notice Reverts if the validator pubkey is not initialized
    /// @param _publicKey The pubkey to check
    function _requireValidatorInitialized(bytes calldata _publicKey) internal view {
        if (validatorDepositInfo[_publicKey].userDepositedEther == 0) revert ValidatorIsNotInitialized();
    }

    /// @notice Reverts if the validator pool is not initialized
    /// @param _address The address of the validator pool to check
    function _requireValidatorPoolInitialized(address _address) internal view {
        if (!validatorPoolAccounts[_address].isInitialized) revert InvalidValidatorPool();
    }

    /// @notice Reverts if the validator pool is insolvent
    /// @param _validatorPool The validator pool address
    function _requireValidatorPoolIsSolvent(address _validatorPool) internal view {
        if (!isSolvent(_validatorPool)) revert ValidatorPoolIsNotSolvent();
    }

    /// @notice Reverts if the validator pool is in liquidation
    /// @param _address The address of the validator pool to check
    function _requireValidatorPoolNotLiquidated(address _address) internal view {
        if (validatorPoolAccounts[_address].wasLiquidated) revert ValidatorPoolWasLiquidated();
    }

    // ==============================================================================
    // Helper Functions
    // ==============================================================================

    /// @notice Get the last withdrawal time for an address
    /// @param _validatorPoolAddress The validator pool being looked up
    /// @return _lastWithdrawalTimestamp The timestamp of the last withdrawal
    function getLastWithdrawalTimestamp(
        address _validatorPoolAddress
    ) public view returns (uint32 _lastWithdrawalTimestamp) {
        // Get the timestamp
        _lastWithdrawalTimestamp = validatorPoolAccounts[_validatorPoolAddress].lastWithdrawal;
    }

    /// @notice Get the last withdrawal times for a given set of addresses
    /// @param _validatorPoolAddresses The validator pools being looked up
    /// @return _lastWithdrawalTimestamps The timestamps of the last withdrawals
    function getLastWithdrawalTimestamps(
        address[] calldata _validatorPoolAddresses
    ) public view returns (uint32[] memory _lastWithdrawalTimestamps) {
        // Initialize the return array
        _lastWithdrawalTimestamps = new uint32[](_validatorPoolAddresses.length);

        // Loop through the addresses
        // --------------------------------------------------------
        for (uint256 i = 0; i < _validatorPoolAddresses.length; ) {
            // Add the timestamp to the return array
            _lastWithdrawalTimestamps[i] = validatorPoolAccounts[_validatorPoolAddresses[i]].lastWithdrawal;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Return the current utilization
    /// @param _cachedBals AMO values from getConsolidatedEthFrxEthBalance
    /// @return _utilization The current utilization
    /// @dev ETH in LP on the Curve AMO is considered "utilized" and thus a "liability"
    function _getUtilizationPostCore(
        EtherRouter.CachedConsEFxBalances memory _cachedBals
    ) internal view returns (uint256 _utilization) {
        // Check for reentrancy
        require(!redemptionQueue.entrancyStatus());

        // Check the shortage or surplus of ETH in the redemption queue
        (int256 _netEthBalance, ) = redemptionQueue.ethShortageOrSurplus();

        // Return 100% utilization if there would be an underflow due to an ETH shortage in the redemption queue
        int256 denominator = int256(totalBorrow.amount) +
            int256(uint256(_cachedBals.ethTotalBalanced)) +
            _netEthBalance;
        if (denominator <= 0) return UTILIZATION_PRECISION;

        // console.log("_getUtilizationPostCore (numerator): %s", totalBorrow.amount * UTILIZATION_PRECISION);
        // console.log("_getUtilizationPostCore (totalBorrow.amount): %s", totalBorrow.amount);
        // console.log("_getUtilizationPostCore (_cachedBals.ethTotalBalanced): %s", _cachedBals.ethTotalBalanced);
        // console.log("_getUtilizationPostCore (_netEthBalance): %s", _netEthBalance);
        // console.log("_getUtilizationPostCore (denominator): %s", denominator);

        // Calculate the utilization
        _utilization = (totalBorrow.amount * UTILIZATION_PRECISION) / (uint256(denominator));

        // console.log("_utilization (uncapped): %s", _utilization);

        // Cap the utilization at 100%
        if (_utilization > UTILIZATION_PRECISION) _utilization = UTILIZATION_PRECISION;
    }

    /// @notice Return the current utilization. Calculates live AMO values
    /// @param _forceLive Force a live recalculation of the AMO values
    /// @param _updateCache Update the cached AMO values, if they were stale
    /// @return _utilization The current utilization
    /// @dev ETH in LP on the Curve AMO is considered "utilized" and thus a "liability"
    function getUtilization(bool _forceLive, bool _updateCache) public returns (uint256 _utilization) {
        EtherRouter.CachedConsEFxBalances memory _cachedBals = etherRouter.getConsolidatedEthFrxEthBalance(
            _forceLive,
            _updateCache
        );
        return _getUtilizationPostCore(_cachedBals);
    }

    /// @notice Return the current utilization. Calculates live AMO values
    /// @return _utilization The current utilization
    /// @dev ETH in LP on the Curve AMO is considered "utilized" and thus a "liability"
    function getUtilizationView() public view returns (uint256 _utilization) {
        EtherRouter.CachedConsEFxBalances memory _cachedBals = etherRouter.getConsolidatedEthFrxEthBalanceView(true);
        return _getUtilizationPostCore(_cachedBals);
    }

    /// @notice Return the max amount of ETH available to borrow
    /// @return _maxBorrow The amount of ETH available to borrow
    function getMaxBorrow() external view returns (uint256 _maxBorrow) {
        EtherRouter.CachedConsEFxBalances memory _cachedBals = etherRouter.getConsolidatedEthFrxEthBalanceView(true);
        (, uint256 _rqShortage) = redemptionQueue.ethShortageOrSurplus();

        // If there is a shortage, you have to subtract it from the available borrow
        if (_cachedBals.ethTotalBalanced >= _rqShortage) {
            _maxBorrow = (_cachedBals.ethTotalBalanced - _rqShortage);
        } else {
            // _maxBorrow = 0; // Redundant set
        }
    }

    /// @notice Whether the provided validator pool is solvent, accounting just for accrued interest
    /// @param _validatorPoolAddress The validator pool address
    /// @return _isSolvent Whether the provided validator pool is solvent
    function isSolvent(address _validatorPoolAddress) public view returns (bool _isSolvent) {
        (_isSolvent, , ) = wouldBeSolvent(_validatorPoolAddress, true, 0, 0);
    }

    /// @notice Returns whether the public key has been approved by the beacon oracle
    /// @param _publicKey The pubkey to check
    /// @return _isApproved Whether the provided validator pool is solvent
    function isValidatorApproved(bytes calldata _publicKey) public view returns (bool _isApproved) {
        // Get the deposit info for the validator
        ValidatorDepositInfo memory _validatorDepositInfo = validatorDepositInfo[_publicKey];

        // Return early if it was never approved at all
        if (_validatorDepositInfo.whenValidatorApproved == 0) return false;

        // Fetch the validator pool info
        ValidatorPoolAccount memory _poolAcc = validatorPoolAccounts[_validatorDepositInfo.validatorPoolAddress];

        // A validator can only be approved if a withdrawal (if it ever happened in the first place)
        // occured before the beacon approval timestamp
        _isApproved = (_poolAcc.lastWithdrawal < _validatorDepositInfo.whenValidatorApproved);
    }

    /// @notice Convert borrow shares to Eth amount. Defaults to rounding up
    /// @param _shares Amount of borrow shares
    /// @return _borrowAmount The amount of Eth borrowed
    function toBorrowAmount(uint256 _shares) public view returns (uint256 _borrowAmount) {
        _borrowAmount = totalBorrow._toAmount(_shares, true);
    }

    /// @notice Convert borrow shares to Eth amount. Optionally rounds up
    /// @param _shares Amount of borrow shares
    /// @param _roundUp Amount of borrow shares
    /// @return _borrowAmount The amount of Eth borrowed
    function toBorrowAmountOptionalRoundUp(uint256 _shares, bool _roundUp) public view returns (uint256 _borrowAmount) {
        _borrowAmount = totalBorrow._toAmount(_shares, _roundUp);
    }

    /// @notice Helper method to check if the validator pool is/was liquidated
    /// @param _validatorPoolAddress The validator pool address
    /// @return _wasLiquidated Whether the validator pool is/was liquidated
    function wasLiquidated(address _validatorPoolAddress) public view returns (bool _wasLiquidated) {
        // Get the validator pool account info
        ValidatorPoolAccount memory _validatorPoolAccount = validatorPoolAccounts[_validatorPoolAddress];
        _wasLiquidated = _validatorPoolAccount.wasLiquidated;
    }

    /// @notice Solvency details for a validator pool, accounting for accrued interest.
    /// @param _validatorPoolAddress The validator pool address
    /// @param _accrueInterest Whether to accrue interest first. Should be true in most cases. False if you did it before somewhere and want to save gas
    /// @param _addlValidators Additional validators to test solvency for. Can be zero.
    /// @param _addlBorrowAmount Additional borrow amount to test solvency for. Can be zero.
    /// @return _wouldBeSolvent Whether the provided validator pool would be solvent given the interest accrual and additional borrow, if any.
    /// @return _borrowAmount Borrowed amount for the specified validator pool
    /// @return _creditAmount Credit amount for the specified validator pool
    function wouldBeSolvent(
        address _validatorPoolAddress,
        bool _accrueInterest,
        uint256 _addlValidators,
        uint256 _addlBorrowAmount
    ) public view returns (bool _wouldBeSolvent, uint256 _borrowAmount, uint256 _creditAmount) {
        // Get the validator pool account info
        ValidatorPoolAccount memory _validatorPoolAccount = validatorPoolAccounts[_validatorPoolAddress];

        // Accrue interest (non-write) first
        // Normally true, but false if you already did it previously in the same call and want to save gas
        VaultAccount memory _totalBorrow;
        if (_accrueInterest) {
            (, , , , _totalBorrow) = previewAddInterest();
        } else {
            _totalBorrow = totalBorrow;
        }

        // Get the borrowed amount for the validator pool, adding the new borrow amount if applicable
        _borrowAmount = _addlBorrowAmount + _totalBorrow._toAmount(_validatorPoolAccount.borrowShares, true);

        // Get the credit amount for the validator pool
        _creditAmount =
            _validatorPoolAccount.creditPerValidatorI48_E12 *
            MISSING_CREDPERVAL_MULT *
            (_validatorPoolAccount.validatorCount + _addlValidators);

        // Check if it is solvent, or if it was liquidated
        if ((_creditAmount >= _borrowAmount) && !_validatorPoolAccount.wasLiquidated) _wouldBeSolvent = true;
    }

    // ============================================================================================
    // Functions: Interest Accumulation and Adjustment
    // ============================================================================================

    /// @notice The ```AddInterest``` event is emitted when interest is accrued by borrowers
    /// @param interestEarned The total interest accrued by all borrowers
    /// @param rate The interest rate used to calculate accrued interest
    /// @param feesAmount The amount of fees paid to protocol
    /// @param feesShare The amount of shares distributed to protocol
    event AddInterest(uint256 interestEarned, uint256 rate, uint256 feesAmount, uint256 feesShare);

    /// @notice The ```UpdateRate``` event is emitted when the interest rate is updated
    /// @param oldRatePerSec The old interest rate (per second)
    /// @param oldFullUtilizationRate The old full utilization rate
    /// @param newRatePerSec The new interest rate (per second)
    /// @param newFullUtilizationRate The new full utilization rate
    event UpdateRate(
        uint256 oldRatePerSec,
        uint256 oldFullUtilizationRate,
        uint256 newRatePerSec,
        uint256 newFullUtilizationRate
    );

    /// @notice The ```addInterest``` function is a public implementation of _addInterest and allows 3rd parties to trigger interest accrual
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _feesAmount The amount of fees paid to protocol
    /// @return _feesShare The amount of shares distributed to protocol
    /// @return _currentRateInfo The new rate info struct
    /// @return _totalBorrow The new total borrow struct
    function addInterest(
        bool _returnAccounting
    )
        external
        nonReentrant
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo,
            VaultAccount memory _totalBorrow
        )
    {
        (, _interestEarned, _feesAmount, _feesShare, _currentRateInfo) = _addInterest();
        if (_returnAccounting) {
            _totalBorrow = totalBorrow;
        }
    }

    /// @notice Preview adding interest
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _feesAmount The amount of fees paid to protocol
    /// @return _feesShare The amount of shares distributed to protocol
    /// @return _newCurrentRateInfo The new rate info struct
    /// @return _totalBorrow The new total borrow struct
    function previewAddInterest()
        public
        view
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _newCurrentRateInfo,
            VaultAccount memory _totalBorrow
        )
    {
        _newCurrentRateInfo = currentRateInfo;

        // Write return values
        // InterestCalculationResults memory _results = _calculateInterestView(_newCurrentRateInfo);
        InterestCalculationResults memory _results = _calculateInterestWithStored(_newCurrentRateInfo);

        if (_results.isInterestUpdated) {
            _interestEarned = _results.interestEarned;

            _newCurrentRateInfo.ratePerSec = _results.newRate;
            _newCurrentRateInfo.fullUtilizationRate = _results.newFullUtilizationRate;

            _totalBorrow = _results.totalBorrow;
        } else {
            _totalBorrow = totalBorrow;
        }
    }

    struct InterestCalculationResults {
        bool isInterestUpdated;
        uint64 newRate;
        uint64 newFullUtilizationRate;
        uint256 interestEarned;
        VaultAccount totalBorrow;
    }

    /// @notice Calculates the interest to be accrued and the new interest rate info
    /// @param _currentRateInfo The current rate info
    /// @return _results The results of the interest calculation
    function _calculateInterestCore(
        CurrentRateInfo memory _currentRateInfo,
        uint256 _utilizationRate
    ) internal view returns (InterestCalculationResults memory _results) {
        // Short circuit if interest already calculated this block OR if interest is paused
        if (_currentRateInfo.lastTimestamp != block.timestamp) {
            // Indicate that interest is updated and calculated
            _results.isInterestUpdated = true;

            // Write return values and use these to save gas
            _results.totalBorrow = totalBorrow;

            // Time elapsed since last interest update
            uint256 _deltaTime = block.timestamp - _currentRateInfo.lastTimestamp;

            // Request new interest rate and full utilization rate from the rate calculator
            (_results.newRate, _results.newFullUtilizationRate) = rateCalculator.getNewRate(
                _deltaTime,
                _utilizationRate,
                _currentRateInfo.fullUtilizationRate
            );

            // Calculate interest accrued
            _results.interestEarned =
                (_deltaTime * _results.totalBorrow.amount * _results.newRate) /
                INTEREST_RATE_PRECISION;

            // Accrue interest (if any) and fees iff no overflow
            if (
                _results.interestEarned > 0 &&
                _results.interestEarned + _results.totalBorrow.amount <= type(uint128).max
            ) {
                // Increment totalBorrow by interestEarned
                _results.totalBorrow.amount += (_results.interestEarned).toUint128();
            }
        }
    }

    /// @notice Calculates the interest to be accrued and the new interest rate info. May update cached getConsolidatedEthFrxEthBalance values if stale
    /// @param _currentRateInfo The current rate info
    /// @return _results The results of the interest calculation
    function _calculateInterestWithStored(
        CurrentRateInfo memory _currentRateInfo
    ) internal view returns (InterestCalculationResults memory _results) {
        // // Get the potentially mutated utilization rate
        // uint256 _utilizationRate = getUtilization({ _forceLive: false, _updateCache: true });

        // Calculate the interest using the stored utilization rate
        return _calculateInterestCore(_currentRateInfo, utilizationStored);
    }

    // /// @notice Calculates the interest to be accrued and the new interest rate info. Will not update cached getConsolidatedEthFrxEthBalance values if stale
    // /// @param _currentRateInfo The current rate info
    // /// @return _results The results of the interest calculation
    // function _calculateInterestLiveView(
    //     CurrentRateInfo memory _currentRateInfo
    // ) internal view returns (InterestCalculationResults memory _results) {
    //     // Get the live utilization rate
    //     uint256 _utilizationRate = getUtilization({ _forceLive: true, _updateCache: false });

    //     // Calculate the interest
    //     return _calculateInterestCore(_currentRateInfo, _utilizationRate);
    // }

    /// @notice The ```_addInterest``` function is invoked prior to every external function and is used to accrue interest and update interest rate
    /// @dev Can only called once per block
    /// @return _isInterestUpdated True if interest was calculated
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _feesAmount The amount of fees paid to protocol
    /// @return _feesShare The amount of shares distributed to protocol
    /// @return _currentRateInfo The new rate info struct
    function _addInterest()
        internal
        returns (
            bool _isInterestUpdated,
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo
        )
    {
        // Pull from storage and set default return values
        _currentRateInfo = currentRateInfo;

        // Calc interest
        InterestCalculationResults memory _results = _calculateInterestWithStored(_currentRateInfo);

        // Write return values only if interest was updated and calculated
        if (_results.isInterestUpdated) {
            _isInterestUpdated = _results.isInterestUpdated;
            _interestEarned = _results.interestEarned;

            // Emit here so that we have access to the old values
            emit UpdateRate(
                _currentRateInfo.ratePerSec,
                _currentRateInfo.fullUtilizationRate,
                _results.newRate,
                _results.newFullUtilizationRate
            );
            emit AddInterest(_interestEarned, _results.newRate, _feesAmount, _feesShare);

            // Overwrite original values
            _currentRateInfo.ratePerSec = _results.newRate;
            _currentRateInfo.fullUtilizationRate = _results.newFullUtilizationRate;
            _currentRateInfo.lastTimestamp = uint64(block.timestamp);

            // Effects: write to state
            currentRateInfo = _currentRateInfo;
            totalBorrow = _results.totalBorrow;
            interestAccrued += _interestEarned;
        }

        // Update the utilization
        utilizationStored = getUtilization(true, true);
    }

    // ==============================================================================
    // Repay Functions
    // ==============================================================================

    /// @notice When a repayment is made for a validator pool
    /// @param _payorAddress The address paying, usually the validator pool
    /// @param _targetPoolAddress The validator pool getting repaid
    /// @param _repayAmount Amount of Eth being repaid
    event Repay(address indexed _payorAddress, address _targetPoolAddress, uint256 _repayAmount);

    /// @notice Repay a given validator pool with the provided msg.value Eth. Anyone can call and pay off on behalf of another.
    /// @param _targetPool The validator pool getting repaid
    function repay(address _targetPool) external payable nonReentrant {
        // Make sure the validator pool is initialized
        _requireValidatorPoolInitialized(_targetPool);

        // Accrue interest first
        _addInterest();

        // Do repay accounting for the target validator pool
        _repay(_targetPool, msg.value);

        // Give the repaid Ether to the Ether Router for investing
        etherRouter.depositEther{ value: msg.value }();
    }

    /// @notice Repay a given validator pool
    /// @param _targetPoolAddress The validator pool getting repaid
    /// @param _repayAmount Amount of Eth being repaid
    function _repay(address _targetPoolAddress, uint256 _repayAmount) internal {
        // Calculations
        (ValidatorPoolAccount memory _validatorPoolAccount, VaultAccount memory _totalBorrow) = _previewRepay(
            _targetPoolAddress,
            _repayAmount
        );

        // Effects
        validatorPoolAccounts[_targetPoolAddress] = _validatorPoolAccount;
        totalBorrow = _totalBorrow;

        emit Repay(msg.sender, _targetPoolAddress, _repayAmount);
    }

    /// @notice Preview repaying a validator pool
    /// @param _targetPoolAddress The validator pool getting repaid
    /// @param _repayAmount Amount of Eth being repaid
    /// @return _newValidatorPoolAccount The new state of the pool after the repayment
    /// @return _newTotalBorrow The new total amount of borrowed Eth after the repayment
    function _previewRepay(
        address _targetPoolAddress,
        uint256 _repayAmount
    )
        internal
        view
        returns (ValidatorPoolAccount memory _newValidatorPoolAccount, VaultAccount memory _newTotalBorrow)
    {
        // Copy dont mutate

        _newValidatorPoolAccount = validatorPoolAccounts[_targetPoolAddress];
        _newTotalBorrow = totalBorrow;

        // Calculate repaid share
        uint256 _sharesToRepay = _newTotalBorrow._toShares(_repayAmount, false);

        // Set values
        if (_sharesToRepay > _newValidatorPoolAccount.borrowShares) revert RepayingTooMuch();
        _newValidatorPoolAccount.borrowShares -= _sharesToRepay; // <<< HERE
        _newTotalBorrow.shares -= _sharesToRepay;
        _newTotalBorrow.amount -= _repayAmount;
    }

    // ==============================================================================
    // Borrow Functions
    // ==============================================================================

    /// @notice When the validator pool borrows from the lending pool
    /// @param _validatorPool The validator pool whose borrowing credit will be used
    /// @param _recipient The recipient of the Eth.
    /// @param _borrowAmount Amount of Eth being borrowed
    event Borrow(address indexed _validatorPool, address _recipient, uint256 _borrowAmount);

    /// @notice Borrow Eth from the lending pool (callable by a validator pool only)
    /// @param _recipient The recipient of the Eth
    /// @param _borrowAmount Amount of Eth being borrowed
    /// @dev The Eth is sourced from the EtherRouter
    function borrow(address payable _recipient, uint256 _borrowAmount) external nonReentrant {
        // Make sure the validator pool is initialized
        _requireValidatorPoolInitialized(msg.sender);

        // Accrue interest first
        _addInterest();

        // Do borrow accounting for the validator
        _borrow(msg.sender, _recipient, _borrowAmount, _borrowAmount);

        // Make sure the validator is still solvent after doing the accounting
        _requireValidatorPoolIsSolvent(msg.sender);

        // Pull Eth from the Ether Router and give it to the recipient (not necessarily the validator pool)
        etherRouter.requestEther(_recipient, _borrowAmount, false);
    }

    /// @notice Borrow Eth (internal)
    /// @param _validatorPoolAddress The validator pool address
    /// @param _recipient The recipient of the Eth
    /// @param _borrowAmount Amount of Eth being borrowed
    /// @param _allowanceAmount Validator pool's borrowing allowance
    function _borrow(
        address _validatorPoolAddress,
        address _recipient,
        uint256 _borrowAmount,
        uint256 _allowanceAmount
    ) internal {
        // Make sure the minimum borrow amount is met
        if (_borrowAmount < MINIMUM_BORROW_AMOUNT) revert MinimumBorrowAmount();

        // Calculations
        (ValidatorPoolAccount memory _validatorPoolAccount, VaultAccount memory _totalBorrow) = _previewBorrow(
            _validatorPoolAddress,
            _borrowAmount,
            _allowanceAmount
        );

        // Effects
        validatorPoolAccounts[_validatorPoolAddress] = _validatorPoolAccount;
        totalBorrow = _totalBorrow;

        // Make sure the validator is still solvent after doing the accounting
        // SKIPPED HERE as finalDepositValidator() would revert. Checked after the fact in external borrow()

        // Make sure the validator has not been liquidated
        _requireValidatorPoolNotLiquidated(msg.sender);

        emit Borrow(_validatorPoolAddress, _recipient, _borrowAmount);
    }

    /// @notice Preview borrowing some Eth
    /// @param _validatorPoolAddress The validator pool doing the borrowing
    /// @param _borrowAmount Amount of Eth being borrowed
    /// @return _newValidatorPoolAccount The new state of the pool after the borrow
    /// @return _newTotalBorrow The new total amount of borrowed Eth after the borrow
    function _previewBorrow(
        address _validatorPoolAddress,
        uint256 _borrowAmount,
        uint256 _allowanceAmount
    )
        internal
        view
        returns (ValidatorPoolAccount memory _newValidatorPoolAccount, VaultAccount memory _newTotalBorrow)
    {
        // Copy dont mutate
        _newValidatorPoolAccount = validatorPoolAccounts[_validatorPoolAddress];
        _newTotalBorrow = totalBorrow;

        // Set return values
        _newValidatorPoolAccount.borrowShares += _newTotalBorrow._toShares(_borrowAmount, true);
        if (_allowanceAmount.toUint128() > _newValidatorPoolAccount.borrowAllowance) revert AllowanceWouldBeNegative();
        else _newValidatorPoolAccount.borrowAllowance -= _allowanceAmount.toUint128();
        _newTotalBorrow.shares += _newTotalBorrow._toShares(_borrowAmount, true);
        _newTotalBorrow.amount += _borrowAmount;
    }

    // ==============================================================================
    // Deposit Functions
    // ==============================================================================

    /// @notice When a validator pool initially deposits
    /// @param _validatorPoolAddress Address of the validator pool
    /// @param _validatorPublicKey The public key of the validator
    /// @param _depositAmount The deposit amount of the validator
    event InitialDeposit(
        address payable indexed _validatorPoolAddress,
        bytes _validatorPublicKey,
        uint256 _depositAmount
    );

    /// @notice When a validator pool finalizes a deposit
    /// @param _validatorPoolAddress Address of the validator pool
    /// @param _validatorPublicKey The public key of the validator
    /// @param _poolSuppliedAmount The amount the validator pool supplied
    /// @param _borrowedAmount The amount borrowed in order to complete the deposit
    event DepositFinalized(
        address payable indexed _validatorPoolAddress,
        bytes _validatorPublicKey,
        uint256 _poolSuppliedAmount,
        uint96 _borrowedAmount
    );

    /// @notice Perform accounting for the first deposit for a given validator. May be either partial or full
    /// @param _validatorPublicKey Public key of the validator
    /// @param _depositAmount Amount being deposited
    function initialDepositValidator(bytes calldata _validatorPublicKey, uint256 _depositAmount) external nonReentrant {
        // Make sure the validator pool is initialized
        _requireValidatorPoolInitialized(msg.sender);

        // Accrue interest beforehand
        _addInterest();

        // Fetch the deposit info
        ValidatorDepositInfo storage _depositInfo = validatorDepositInfo[_validatorPublicKey];

        // Make sure the pubkey isn't already complete/finalized
        if (_depositInfo.wasFullDepositOrFinalized) revert PubKeyAlreadyFinalized();

        // Make sure the pubkey is either associated with the msg.sender validator pool, or not associated at all
        // Helps against validators altering data for other pubkeys as well as front-running
        if (!(_depositInfo.validatorPoolAddress == msg.sender || _depositInfo.validatorPoolAddress == address(0))) {
            revert ValidatorPoolKeyMismatch();
        }

        // Liquidated validator pools need to be emptied and abandoned, and should not be able to add any new validators
        // If you are mid-way through a partial deposit and liquidation happens, you will need to manually complete the 32 ETH
        // with an EOA or something, then exit
        _requireValidatorPoolNotLiquidated(msg.sender);

        // Update individual validator accounting
        _depositInfo.userDepositedEther += uint96(_depositAmount);

        // (Special case) If this came in as a full 32 Eth deposit all at once, or a final partial deposit with no borrow,
        // mark it as complete.
        if (_depositInfo.userDepositedEther == 32 ether) {
            // Verify that adding 1 validator would keep the validator pool solvent
            // You already accrued interest above so can leave false to save gas
            // _addlBorrowAmount is 0 since you came in full 32 all at once
            // Does not actually write these changes, just checks
            {
                (bool _wouldBeSolvent, uint256 _ttlBorrow, uint256 _ttlCredit) = wouldBeSolvent(
                    msg.sender,
                    false,
                    1,
                    0
                );
                if (!_wouldBeSolvent) revert ValidatorPoolIsNotSolventDetailed(_ttlBorrow, _ttlCredit);
            }

            // Mark the deposit as finalized
            _depositInfo.wasFullDepositOrFinalized = true;
        }

        // Mark the sender as the first validator so front-running attempts to alter the withdrawal address
        // will revert
        _depositInfo.validatorPoolAddress = msg.sender;

        // Make sure you are not depositing more than 32 Eth for this pubkey
        if (_depositInfo.userDepositedEther > 32 ether) revert CannotDepositMoreThan32Eth();

        emit InitialDeposit(payable(msg.sender), _validatorPublicKey, _depositAmount);
    }

    /// @notice Finalizes an incomplete ETH2 deposit made earlier, borrowing any remainder from the lending pool
    /// @param _validatorPublicKey Public key of the validator
    /// @param _withdrawalCredentials Withdrawal credentials for the validator
    /// @param _validatorSignature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    function finalDepositValidator(
        bytes calldata _validatorPublicKey,
        bytes calldata _withdrawalCredentials,
        bytes calldata _validatorSignature,
        bytes32 _depositDataRoot
    ) external nonReentrant {
        _requireValidatorInitialized(_validatorPublicKey);
        _requireValidatorApproved(_validatorPublicKey);
        _requireValidatorPoolInitialized(msg.sender);
        _requireAddressAssociatedWithPubkey(msg.sender, _validatorPublicKey);

        // Fetch the deposit info
        ValidatorDepositInfo memory _depositInfo = validatorDepositInfo[_validatorPublicKey];

        // Make sure the pubkey wasn't used yet
        if (_depositInfo.wasFullDepositOrFinalized) revert PubKeyAlreadyFinalized();

        // Calculate the borrow amount and make sure it is nonzero
        uint96 _borrowAmount = 32 ether - _depositInfo.userDepositedEther;
        if (_borrowAmount == 0) revert NoDepositToFinalize();

        // Update the deposit info
        _depositInfo.lendingPoolDepositedEther += _borrowAmount;
        _depositInfo.wasFullDepositOrFinalized = true;
        validatorDepositInfo[_validatorPublicKey] = _depositInfo;

        // Accrue interest beforehand
        _addInterest();

        // You can borrow even if you don't have credit, assuming you can still pay the interest rate
        // Your partial deposit (at least 8 ETH here for anon due to 24 ETH credit),
        // plus the fact that exited ETH is trapped in the validator pool (until debts are paid),
        // is essentially the collateral
        _borrow({
            _validatorPoolAddress: msg.sender,
            _recipient: msg.sender,
            _borrowAmount: uint256(_borrowAmount),
            _allowanceAmount: 0
        });

        // Request the needed Eth
        etherRouter.requestEther(payable(address(this)), uint256(_borrowAmount), false);

        // Complete the deposit
        ETH2_DEPOSIT_CONTRACT.deposit{ value: uint256(_borrowAmount) }(
            _validatorPublicKey,
            _withdrawalCredentials,
            _validatorSignature,
            _depositDataRoot
        );

        // Verify that accruing interest and adding 1 validator would keep the validator pool solvent
        // You already accrued interest above so can leave false to save gas
        // BorrowAmount already increased by _borrowAmount so no need to put it in wouldBeSolvent()
        // Does not actually write these changes, just checks
        {
            (bool _wouldBeSolvent, uint256 _ttlBorrow, uint256 _ttlCredit) = wouldBeSolvent(msg.sender, false, 1, 0);
            if (!_wouldBeSolvent) revert ValidatorPoolIsNotSolventDetailed(_ttlBorrow, _ttlCredit);
        }

        // // Increment the validator count, but NOT the borrow allowance. This prevents immediate liquidation.
        // // TODO: Check to make sure this cannot be manipulated to never allow a liquidation.
        // validatorPoolAccounts[msg.sender].validatorCount++;

        emit DepositFinalized(payable(msg.sender), _validatorPublicKey, _depositInfo.userDepositedEther, _borrowAmount);
    }

    // ==============================================================================
    // Withdraw Functions
    // ==============================================================================

    /// @notice When a validator pool withdraws ETH
    /// @param _validatorPoolAddress Address of the validator pool
    /// @param _endRecipient The ultimate recipient of the ETH
    /// @param _sentBackAmount Amount of Eth actually given back (requested - fee)
    /// @param _feeAmount Amount of Eth kept as the withdrawal fee (sent to the Ether Router)
    event WithdrawalRegistered(
        address payable indexed _validatorPoolAddress,
        address payable _endRecipient,
        uint256 _sentBackAmount,
        uint256 _feeAmount
    );

    /// @notice Registers that a validator pool is withdrawing and resets the borrowAllowance to 0 until the next beacon update.
    /// @param _endRecipient The ultimate recipient of the Eth. msg.sender (the validator pool) should get any ETH first
    /// @param _sentBackAmount Amount of Eth actually given back (requested - fee)
    /// @param _feeAmount Amount of Eth kept as the withdrawal fee (sent to the Ether Router)
    /// @dev This prevents syncing issues between when the ETH comes back from a Beacon Chain exit (dumped into the validator pool)
    /// and letting the validator pool borrow "for free" with lesser collateral (since there was just an exit)
    /// Once the Beacon Oracle actually registers the beacon chain exit, borrowAllowance
    /// will simply be (# validators) * (credit per validator) and the validator pool can borrow normally again
    /// with the new, correct number of total validators
    function registerWithdrawal(
        address payable _endRecipient,
        uint256 _sentBackAmount,
        uint256 _feeAmount
    ) external nonReentrant {
        _requireValidatorPoolInitialized(msg.sender);

        // Catch up the interest
        _addInterest();

        // Fetch the validator pool info
        ValidatorPoolAccount memory _validatorPoolAccount = validatorPoolAccounts[msg.sender];

        // Make sure debts have been paid off first
        if (_validatorPoolAccount.borrowShares == 0) {
            // 0 balance turns off borrowing until next oracle update, to prevent front running
            _validatorPoolAccount.borrowAllowance = 0;
        } else {
            revert BorrowBalanceMustBeZero();
        }

        // Mark this withdrawal timestamp. Important to prevent beacon frontrunning and other attacks
        _validatorPoolAccount.lastWithdrawal = uint32(block.timestamp);

        // Update the validator pool struct
        validatorPoolAccounts[msg.sender] = _validatorPoolAccount;

        emit WithdrawalRegistered(payable(msg.sender), _endRecipient, _sentBackAmount, _feeAmount);
    }

    // ==============================================================================
    // Liquidate Functions
    // ==============================================================================

    /// @notice When a validator pool is liquidated
    /// @param _validatorPoolAddress Address of the validator pool
    /// @param _amountToLiquidate Amount of Eth to liquidate
    event Liquidate(address indexed _validatorPoolAddress, uint256 _amountToLiquidate);

    /// @notice Liquidate a specified amount of Eth for a validator pool. Callable only by an allowed liquidator, the timelock, or the beacon oracle
    /// @param _validatorPoolAddress Address of the validator pool
    /// @param _amountToLiquidate Amount of Eth to liquidate
    /// @dev Marks the pool as "wasLiquidated = true", which will prevent new borrows and deposits
    function liquidate(address payable _validatorPoolAddress, uint256 _amountToLiquidate) external {
        // Make sure the caller is allowed
        _requireAddressCanLiquidate(msg.sender);

        // Accrue interest
        _addInterest();

        // Don't liquidate if the position is healthy
        if (isSolvent(_validatorPoolAddress)) {
            revert ValidatorPoolIsSolvent();
        }

        // Mark the validator pool as being in liquidation
        validatorPoolAccounts[_validatorPoolAddress].wasLiquidated = true;

        // Force the validator pool to pay back its loan
        ValidatorPool(_validatorPoolAddress).repayAmount(_amountToLiquidate);

        emit Liquidate(_validatorPoolAddress, _amountToLiquidate);
    }

    // ==============================================================================
    // ETH Handling
    // ==============================================================================

    /// @notice Allows contract to receive Eth
    receive() external payable {
        // Do nothing except take in the Eth
    }

    /// @notice When the lending pool sends stranded ETH to the Ether Router
    /// @param _amountRecovered Amount of ETH recovered
    event StrandedEthRecovered(uint256 _amountRecovered);

    /// @notice Pushes ETH back into the Ether Router, in case ETH gets stuck in this contract somehow
    /// @dev Under normal operations, ETH is only in this contract transiently.
    function recoverStrandedEth() external returns (uint256 _amountRecovered) {
        _requireSenderIsTimelock();

        // Save the balance before
        _amountRecovered = address(this).balance;

        // Give the ETH to the Ether Router
        (bool _success, ) = address(etherRouter).call{ value: _amountRecovered }("");
        require(_success, "ETH transfer failed (recoverStrandedEth ETH)");

        emit StrandedEthRecovered(_amountRecovered);
    }

    // ==============================================================================
    // Restricted Functions
    // ==============================================================================

    /// @notice When the interest rate calculator is set
    /// @param addr Address being set
    event InterestRateCalculatorSet(address addr);

    /// @notice Set the address for the interest rate calculator
    /// @param _calculatorAddress Address to set
    function setInterestRateCalculator(address _calculatorAddress) external {
        _requireSenderIsTimelock();

        // Set the status
        rateCalculator = IInterestRateCalculator(_calculatorAddress);

        emit InterestRateCalculatorSet(_calculatorAddress);
    }

    /// @notice When an address is allowed/disallowed to liquidate
    /// @param addr Address being set
    /// @param canLiquidate Whether it can liquidate or not
    event LiquidatorSet(address addr, bool canLiquidate);

    /// @notice Allow/disallow an address to perform liquidations
    /// @param _liquidatorAddress Address to set
    /// @param _canLiquidate Whether it can liquidate or not
    function setLiquidator(address _liquidatorAddress, bool _canLiquidate) external {
        _requireSenderIsTimelock();

        // Set the status
        isLiquidator[_liquidatorAddress] = _canLiquidate;

        emit LiquidatorSet(_liquidatorAddress, _canLiquidate);
    }

    /// @notice Change the Beacon Oracle address
    /// @param _newBeaconOracleAddress Beacon Oracle address
    function setBeaconOracleAddress(address _newBeaconOracleAddress) external {
        _requireSenderIsTimelock();
        _setBeaconOracle(_newBeaconOracleAddress);
    }

    /// @notice Change the Ether Router address
    /// @param _newEtherRouterAddress Ether Router address
    function setEtherRouterAddress(address payable _newEtherRouterAddress) external {
        _requireSenderIsTimelock();
        _setEtherRouter(_newEtherRouterAddress);
    }

    /// @notice Change the Redemption Queue address
    /// @param _newRedemptionQueue Redemption Queue address
    function setRedemptionQueueAddress(address payable _newRedemptionQueue) external {
        _requireSenderIsTimelock();
        _setFraxEtherRedemptionQueueV2(_newRedemptionQueue);
    }

    // ==============================================================================
    // Errors
    // ==============================================================================
    /// @notice If the borrow allowance trying to be set would be negative
    error AllowanceWouldBeNegative();

    /// @notice Cannot withdraw with nonzero borrow balance
    error BorrowBalanceMustBeZero();

    /// @notice Cannot exit pool
    error CannotExitPool();

    /// @notice When you are trying to deposit more than 32 ETH
    error CannotDepositMoreThan32Eth();

    /// @notice When certain supplied arrays parameters have differing lengths
    error InputArrayLengthMismatch();

    /// @notice Invalid validator pool
    error InvalidValidatorPool();

    /// @notice If you are trying to finalize an already completed deposit
    error NoDepositToFinalize();

    /// @notice If the caller is not allowed to liquidate
    error NotAllowedLiquidator();

    /// @notice When you are trying to borrow less than the minimum amount
    error MinimumBorrowAmount();

    /// @notice Must repay debt first
    error MustRepayDebtFirst();

    /// @notice Prevent trying to cycle pubkeys and get more debt
    error PubKeyAlreadyFinalized();

    /// @notice When you try to repay too much
    error RepayingTooMuch();

    /// @notice Validator is not approved
    error ValidatorIsNotApprovedLP();

    /// @notice Validator is not initialized
    error ValidatorIsNotInitialized();

    /// @notice Supplied pubkey not associated with the supplied validator pool address
    error ValidatorPoolKeyMismatch();

    /// @notice Validator pool is liquidated
    error ValidatorPoolWasLiquidated();

    /// @notice Validator pool is not solvent
    error ValidatorPoolIsNotSolvent();

    /// @notice Validator pool is not solvent (detailed)
    error ValidatorPoolIsNotSolventDetailed(uint256 _ttlBorrow, uint256 _ttlCredit);

    /// @notice Validator pool is solvent
    error ValidatorPoolIsSolvent();

    /// @notice Withdrawal timestamp mismatch
    error WithdrawalTimestampMismatch(uint32 _suppliedTimestamp, uint32 _actualTimestamp);
}

// src/contracts/lending-pool/LendingPool.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== LendingPool ============================
// ====================================================================
// Receives and gives out ETH to ValidatorPools for lending and borrowing

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna
// Drake Evans: https://github.com/DrakeEvans

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

// import "frax-std/FraxTest.sol";

/// @notice Constructor information for the lending pool
/// @param frxEthAddress Address of the frxETH token
/// @param timelockAddress The address of the governance timelock
/// @param etherRouterAddress The Ether Router address
/// @param beaconOracleAddress The Beacon Oracle address
/// @param redemptionQueueAddress The Redemption Queue address
/// @param interestRateCalculatorAddress Address used for interest rate calculations
/// @param eth2DepositAddress Address of the Eth2 deposit contract
/// @param fullUtilizationRate The interest rate at full utilization
// / @param validatorPoolCreationCode Bytecode for the validator pool (for create2)
struct LendingPoolParams {
    address frxEthAddress;
    address timelockAddress;
    address payable etherRouterAddress;
    address beaconOracleAddress;
    address payable redemptionQueueAddress;
    address interestRateCalculatorAddress;
    address payable eth2DepositAddress;
    uint64 fullUtilizationRate;
}
// bytes validatorPoolCreationCode;

/// @title Receives and gives out ETH to ValidatorPools for lending and borrowing
/// @author Frax Finance
/// @notice Controlled by Frax governance and validator pools
contract LendingPool is LendingPoolCore {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    /// @notice Where the bytecode for the validator pool factory to look at is
    address public validatorPoolCreationCodeAddress;

    // The default credit given to a validator pool, per validator (i.e. per 32 Eth)
    // 12 decimal precision, up to about ~281 Eth
    uint48 public constant DEFAULT_CREDIT_PER_VALIDATOR_I48_E12 = 24e12;

    // The maximum credit given to a validator pool, per validator (i.e. per 32 Eth)
    // 12 decimal precision, up to about ~281 Eth
    uint48 public constant MAXIMUM_CREDIT_PER_VALIDATOR_I48_E12 = 31e12;

    // Fee taken when a validator pool withdraws funds
    uint256 public vPoolWithdrawalFee; // 1e6 precision. Used to help cover slippage, LP fees, and beacon gas
    uint256 public constant MAX_WITHDRAWAL_FEE = 3000; // 0.3%

    /// @notice Constructor
    /// @param _params The LendingPoolParams
    constructor(
        LendingPoolParams memory _params
    )
        LendingPoolCore(
            LendingPoolCoreParams({
                frxEthAddress: _params.frxEthAddress,
                timelockAddress: _params.timelockAddress,
                etherRouterAddress: _params.etherRouterAddress,
                beaconOracleAddress: _params.beaconOracleAddress,
                redemptionQueueAddress: _params.redemptionQueueAddress,
                interestRateCalculatorAddress: _params.interestRateCalculatorAddress,
                eth2DepositAddress: _params.eth2DepositAddress,
                fullUtilizationRate: _params.fullUtilizationRate
            })
        )
    {
        // _setCreationCode(_params.validatorPoolCreationCode);
        _setCreationCode(type(ValidatorPool).creationCode);
    }

    // ==============================================================================
    // Global Configuration Setters
    // ==============================================================================

    // ------------------------------------------------------------------------
    /// @notice When someone tries setting the withdrawal fee above the max (100%)
    /// @param providedFee The provided withdrawal fee
    /// @param maxFee The maximum withdrawal fee
    error ExceedsMaxWithdrawalFee(uint256 providedFee, uint256 maxFee);

    /// @notice When the withdrawal fee for validator pools is set
    /// @param _newFee The new withdrawal fee
    event VPoolWithdrawalFeeSet(uint256 _newFee);

    /// @notice Sets the fee for when a validator pool withdraws
    /// @param _newFee New withdrawal fee given in percentage terms, using 1e6 precision
    /// @dev Mainly used to prevent griefing and handle the Curve LP fees.
    function setVPoolWithdrawalFee(uint256 _newFee) external {
        _requireSenderIsTimelock();
        if (_newFee > MAX_WITHDRAWAL_FEE) revert ExceedsMaxWithdrawalFee(_newFee, MAX_WITHDRAWAL_FEE);

        emit VPoolWithdrawalFeeSet(_newFee);

        vPoolWithdrawalFee = _newFee;
    }

    // ==============================================================================
    // Validator Pool State Setters
    // ==============================================================================

    // ------------------------------------------------------------------------

    /// @notice If the borrow allowance trying to be set is wrong
    error IncorrectBorrowAllowance(uint256 _maxAllowance, uint256 _newAllowance);

    /// @notice When some validator pools have both their total validator counts and/or borrow allowances set
    /// @param _validatorPoolAddresses The addresses of the validator pools
    /// @param _setValidatorCounts Whether to set the validator counts
    /// @param _setBorrowAllowances Whether to set the borrow allowances
    /// @param _newValidatorCounts The new total validator count for each pool
    /// @param _newBorrowAllowances The new borrow allowances for the validators
    /// @param _lastWithdrawalTimestamps validatorPoolAccounts's lastWithdrawal. When this function eventually is called, after a frxGov delay, _lastWithdrawalTimestamps need to match.
    event VPoolValidatorCountsAndBorrowAllowancesSet(
        address[] _validatorPoolAddresses,
        bool _setValidatorCounts,
        bool _setBorrowAllowances,
        uint32[] _newValidatorCounts,
        uint128[] _newBorrowAllowances,
        uint32[] _lastWithdrawalTimestamps
    );

    /// @notice Set the total validator count and/or the borrow allowance for each pool
    /// @param _validatorPoolAddresses The addresses of the validator pools
    /// @param _setValidatorCounts Whether to set the validator counts
    /// @param _setBorrowAllowances Whether to set the borrow allowances
    /// @param _newValidatorCounts The new total validator count for each pool
    /// @param _newBorrowAllowances The new borrow allowances for the validators
    /// @param _lastWithdrawalTimestamps validatorPoolAccounts's lastWithdrawal. When this function eventually is called, after a frxGov delay, _lastWithdrawalTimestamps need to match. Prevents the user from withdrawing immediately after depositing to earn a fake borrow allowance and steal funds.
    function setVPoolValidatorCountsAndBorrowAllowances(
        address[] calldata _validatorPoolAddresses,
        bool _setValidatorCounts,
        bool _setBorrowAllowances,
        uint32[] calldata _newValidatorCounts,
        uint128[] calldata _newBorrowAllowances,
        uint32[] calldata _lastWithdrawalTimestamps
    ) external {
        _requireSenderIsBeaconOracle();

        // Check that the _lastWithdrawalTimestamps array length matches _validatorPoolAddresses
        if (_validatorPoolAddresses.length != _lastWithdrawalTimestamps.length) revert InputArrayLengthMismatch();

        // Check that the _newValidatorCounts array length matches _validatorPoolAddresses
        if (_setValidatorCounts && (_validatorPoolAddresses.length != _newValidatorCounts.length)) {
            revert InputArrayLengthMismatch();
        }

        // Check that the _newBorrowAllowances array length matches _validatorPoolAddresses
        if (_setBorrowAllowances && (_validatorPoolAddresses.length != _newBorrowAllowances.length)) {
            revert InputArrayLengthMismatch();
        }

        // Accumulate interest
        _addInterest();

        for (uint256 i = 0; i < _validatorPoolAddresses.length; ) {
            // Fetch the address of the validator pool
            address _validatorPoolAddr = _validatorPoolAddresses[i];

            // Fetch the validator pool account
            ValidatorPoolAccount memory _validatorPoolAccount = validatorPoolAccounts[_validatorPoolAddr];

            // Make sure the validator pool is initialized
            _requireValidatorPoolInitialized(_validatorPoolAddr);

            // Make sure the user did not withdraw in the meantime
            if (_lastWithdrawalTimestamps[i] != _validatorPoolAccount.lastWithdrawal) {
                revert WithdrawalTimestampMismatch(_lastWithdrawalTimestamps[i], _validatorPoolAccount.lastWithdrawal);
            }

            // Set the validators, if specified
            if (_setValidatorCounts) {
                // Set the validator count
                _validatorPoolAccount.validatorCount = _newValidatorCounts[i];
            }

            // Set the borrow allowances, if specified
            if (_setBorrowAllowances) {
                // Calculate the optimistic amount of credit, assuming no borrowing
                uint256 _optimisticAllowance = (uint256(_validatorPoolAccount.validatorCount) *
                    (uint256(_validatorPoolAccount.creditPerValidatorI48_E12) * MISSING_CREDPERVAL_MULT));

                // Calculate the maximum allowance
                uint256 _maxAllowance;
                uint256 _borrowedAmount = toBorrowAmountOptionalRoundUp(_validatorPoolAccount.borrowShares, true);
                if (_optimisticAllowance == 0) {
                    // This may hit if a liquidated user welches on interest if the validator exits are not enough to cover the borrow + interest.
                    _maxAllowance = 0;
                } else if (_borrowedAmount > _optimisticAllowance) {
                    // New allowance should not be negative
                    revert AllowanceWouldBeNegative();
                } else {
                    // Calculate the maximum allowance. Could use unchecked here but meh
                    _maxAllowance = _optimisticAllowance - _borrowedAmount;
                }

                // Revert if you are trying to set above the maximum allowance
                if (_newBorrowAllowances[i] > _maxAllowance) {
                    revert IncorrectBorrowAllowance(_maxAllowance, _newBorrowAllowances[i]);
                }

                // Set the borrow allowance
                _validatorPoolAccount.borrowAllowance = _newBorrowAllowances[i];
            }

            // Write to storage
            validatorPoolAccounts[_validatorPoolAddr] = _validatorPoolAccount;

            // Increment
            unchecked {
                ++i;
            }
        }

        // Emit
        emit VPoolValidatorCountsAndBorrowAllowancesSet(
            _validatorPoolAddresses,
            _setValidatorCounts,
            _setBorrowAllowances,
            _newValidatorCounts,
            _newBorrowAllowances,
            _lastWithdrawalTimestamps
        );
    }

    // ------------------------------------------------------------------------
    /// @notice When some validator pools have their credits per validator set
    /// @param _validatorPoolAddresses The addresses of the validator pools
    /// @param _newCreditsPerValidator The new total number of credits per validator
    event VPoolCreditsPerPoolSet(address[] _validatorPoolAddresses, uint48[] _newCreditsPerValidator);

    /// @notice Set the amount of Eth credit per validator pool
    /// @param _validatorPoolAddresses The addresses of the validator pools
    /// @param _newCreditsPerValidator The new total number of credits per validator
    function setVPoolCreditsPerValidator(
        address[] calldata _validatorPoolAddresses,
        uint48[] calldata _newCreditsPerValidator
    ) external {
        _requireSenderIsBeaconOracle();

        // Check that the input arrays have the same length
        if (_validatorPoolAddresses.length != _newCreditsPerValidator.length) revert InputArrayLengthMismatch();

        for (uint256 i = 0; i < _validatorPoolAddresses.length; ) {
            // Make sure the validator pool is initialized
            _requireValidatorPoolInitialized(_validatorPoolAddresses[i]);

            // Make sure you are not setting the credit per validator to over MAXIMUM_CREDIT_PER_VALIDATOR_I48_E12 (31 ETH)
            require(
                _newCreditsPerValidator[i] <= MAXIMUM_CREDIT_PER_VALIDATOR_I48_E12,
                "Credit per validator > MAXIMUM_CREDIT_PER_VALIDATOR_I48_E12"
            );

            // Set the credit
            validatorPoolAccounts[_validatorPoolAddresses[i]].creditPerValidatorI48_E12 = _newCreditsPerValidator[i];

            // Increment
            unchecked {
                ++i;
            }
        }

        emit VPoolCreditsPerPoolSet(_validatorPoolAddresses, _newCreditsPerValidator);
    }

    // ------------------------------------------------------------------------
    /// @notice When approval statuses for a multiple validator pubkeys are set
    /// @param _validatorPublicKeys The pubkeys being set
    /// @param _validatorPoolAddresses The validator pools associated with the pubkeys being set
    /// @param _whenApprovedArr When the pubkeys were approved. 0 if they were not
    event VPoolApprovalsSet(bytes[] _validatorPublicKeys, address[] _validatorPoolAddresses, uint32[] _whenApprovedArr);

    /// @notice Set the approval statuses for a multiple validator pubkeys
    /// @param _validatorPublicKeys The pubkeys being set
    /// @param _validatorPoolAddresses The validator pools associated with the pubkeys being set
    /// @param _whenApprovedArr When the pubkeys were approved. 0 if they were not
    /// @param _lastWithdrawalTimestamps validatorPoolAccounts's lastWithdrawal. When this function eventually is called, after a frxGov delay, _lastWithdrawalTimestamps need to match. Prevents the user from withdrawing immediately after depositing to earn a fake borrow allowance and steal funds.
    function setValidatorApprovals(
        bytes[] calldata _validatorPublicKeys,
        address[] calldata _validatorPoolAddresses,
        uint32[] calldata _whenApprovedArr,
        uint32[] calldata _lastWithdrawalTimestamps
    ) external {
        _requireSenderIsBeaconOracle();

        // Check that the input arrays have the same length
        {
            uint256 _arrLength = _validatorPublicKeys.length;
            if (
                (_validatorPoolAddresses.length != _arrLength) ||
                (_whenApprovedArr.length != _arrLength) ||
                (_lastWithdrawalTimestamps.length != _arrLength)
            ) revert InputArrayLengthMismatch();
        }

        for (uint256 i = 0; i < _validatorPublicKeys.length; ) {
            // Fetch the address of the validator pool
            address _validatorPoolAddr = _validatorPoolAddresses[i];

            // Fetch the validator pool account
            ValidatorPoolAccount memory _validatorPoolAccount = validatorPoolAccounts[_validatorPoolAddr];

            // Make sure the user did not withdraw in the meantime
            if (_lastWithdrawalTimestamps[i] != _validatorPoolAccount.lastWithdrawal) {
                revert WithdrawalTimestampMismatch(_lastWithdrawalTimestamps[i], _validatorPoolAccount.lastWithdrawal);
            }

            // Revert if the provided validator pool address doesn't match the first depositor set in initialDepositValidator()
            // It should never be address(0) because the Beacon Oracle check cannot happen before the initial deposit
            if (validatorDepositInfo[_validatorPublicKeys[i]].validatorPoolAddress != _validatorPoolAddr) {
                revert ValidatorPoolKeyMismatch();
            }

            // Set the validator approval state
            validatorDepositInfo[_validatorPublicKeys[i]].whenValidatorApproved = _whenApprovedArr[i];

            // Increment
            unchecked {
                ++i;
            }
        }

        emit VPoolApprovalsSet(_validatorPublicKeys, _validatorPoolAddresses, _whenApprovedArr);
    }

    // ==============================================================================
    // Validator Pool Factory Functions
    // ==============================================================================

    /// @notice The ```setCreationCode``` function sets the bytecode for the ValidatorPool
    /// @dev splits the data if necessary to accommodate creation code that is slightly larger than 24kb
    /// @param _creationCode The creationCode for the ValidatorPool
    function setCreationCode(bytes memory _creationCode) external {
        _requireSenderIsTimelock();
        _setCreationCode(_creationCode);
    }

    /// @notice The ```setCreationCode``` function sets the bytecode for the ValidatorPool
    /// @dev splits the data if necessary to accommodate creation code that is slightly larger than 24kb
    /// @param _creationCode The creationCode for the ValidatorPool
    function _setCreationCode(bytes memory _creationCode) internal {
        validatorPoolCreationCodeAddress = SSTORE2.write(_creationCode);
    }

    // ------------------------------------------------------------------------
    /// @notice When a validator pool is created
    /// @param _validatorPoolOwnerAddress The owner of the validator pool
    /// @return _poolAddress The address of the validator pool that was created
    event VPoolDeployed(address _validatorPoolOwnerAddress, address _poolAddress);

    /// @notice Deploy a validator pool (callable by anyone)
    /// @param _validatorPoolOwnerAddress The owner of the validator pool
    /// @param _extraSalt An extra salt bytes32 provided by the user
    /// @return _poolAddress The address of the validator pool that was created
    function deployValidatorPool(
        address _validatorPoolOwnerAddress,
        bytes32 _extraSalt
    ) public returns (address payable _poolAddress) {
        // Get creation code
        bytes memory _creationCode = SSTORE2.read(validatorPoolCreationCodeAddress);

        // Get bytecode
        bytes memory bytecode = abi.encodePacked(
            _creationCode,
            abi.encode(_validatorPoolOwnerAddress, payable(address(this)), payable(address(ETH2_DEPOSIT_CONTRACT)))
        );

        bytes32 _salt = keccak256(abi.encodePacked(msg.sender, _validatorPoolOwnerAddress, _extraSalt));

        /// @solidity memory-safe-assembly
        assembly {
            _poolAddress := create2(0, add(bytecode, 32), mload(bytecode), _salt)
        }
        if (_poolAddress == address(0)) revert("create2 failed");

        // Mark validator pool as approved
        validatorPoolAccounts[_poolAddress].isInitialized = true;
        validatorPoolAccounts[_poolAddress].creditPerValidatorI48_E12 = DEFAULT_CREDIT_PER_VALIDATOR_I48_E12;

        emit VPoolDeployed(_validatorPoolOwnerAddress, _poolAddress);
    }

    // ==============================================================================
    // Preview Interest Functions
    // ==============================================================================

    /// @notice Get information about a validator pool
    /// @param _validatorPoolAddress The validator pool in question
    function previewValidatorAccounts(
        address _validatorPoolAddress
    ) external view returns (ValidatorPoolAccount memory) {
        return validatorPoolAccounts[_validatorPoolAddress];
    }

    // ==============================================================================
    // Reentrancy View Function
    // ==============================================================================

    /// @notice Get the entrancy status
    /// @return _isEntered If the contract has already been entered
    function entrancyStatus() external view returns (bool _isEntered) {
        _isEntered = _status == 2;
    }
}



// src/contracts/curve-amo/CurveLsdAmo.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== CurveLsdAmo ============================
// ====================================================================
// Invests ETH and frxETH provided by the Lending Pool (via the Ether Router) on Convex to earn yield for the IncentivesPool
// IMPORTANT: Make sure the Curve Pair does not have the remove_liquidity raw_call for ETH [https://chainsecurity.com/curve-lp-oracle-manipulation-post-mortem/]
// or if it does, the read reentrancy is handled properly
// Only handles these types of pairs, with 2 tokens (LSD = rETH, frxETH, stETH, etc):
// 1) <A LSD>/ETH
// 2) <A LSD>/<Another LSD>
// One LP/cvxLP/stkcvxLP set per AMO

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna
// Amirnader Aghayeghazvini: https://github.com/amirnader-ghazvini

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

// import "forge-std/console2.sol";

/// @notice Used for the constructor
/// @param timelockAddress Address of the governance timelock
/// @param operatorAddress Address of the operator
/// @param amoHelperAddress Address of the Curve AMO Helper
/// @param frxEthMinterAddress Address of the frxETH Minter
/// @param etherRouter Address of the Ether Router
/// @param poolConfigData Pool config data for the Curve LP
/// @param cvxAndStkcvxData Config data for the cvxLP and stkcvxLP
struct CurveLsdAmoConstructorParams {
    address timelockAddress;
    address operatorAddress;
    address amoHelperAddress;
    address frxEthMinterAddress;
    address payable etherRouterAddress;
    bytes poolConfigData;
    bytes cvxAndStkcvxData;
}

contract CurveLsdAmo is EtherRouterRole, OperatorRole, Timelock2Step, WhitelistedExecutor, PublicReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeCastLibrary for int128; // Compiler complained about the comma in `using SafeCastLibrary for int128, uint256;`
    using SafeCastLibrary for uint256;

    /* ============================================= STATE VARIABLES ==================================================== */

    // Addresses
    address public frxEthMinterAddress;
    address public poolAddress;
    address private constant CVXCRV_ADDRESS = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address private constant CRV_ADDRESS = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant FXS_ADDRESS = 0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0;

    // Slippages and Max Pool Ratio
    uint256 public depositWithdrawSlippageRouterE6 = 600; // 600 / 1000000 = 0.06%
    uint256 public depositWithdrawSlippageTimelockOperatorE6 = 1000; // 1000 / 1000000 = 0.1% (Slightly more forgiving)
    uint256 public extraWithdrawalLpPctE6 = 100; // 100 / 1000000 = 0.01% (Mainly for rounding issues)
    uint256 public swapSlippageE6 = 600; // 600 / 1000000 = 0.06%
    uint256 public minTkn0ToTkn1RatioE6 = 150_000; // 15% (e.g. 15 tkn0 to 85 tkn1). Used to limit sandwiching in _depositToCurveLP
    uint256 public maxTkn0ToTkn1RatioE6 = 850_000; // 85% (e.g. 85 tkn0 to 15 tkn1). Used to limit sandwiching in _depositToCurveLP

    // Token Instances
    CurveLsdAmoHelper public amoHelper;
    IMinCurvePool public pool;
    IFrxEth_1 private constant frxETH = IFrxEth_1(0x5E8422345238F34275888049021821E8E08CAa1f);
    ISfrxEth_1 private constant sfrxETH = ISfrxEth_1(0xac3E018457B222d93114458476f3E3416Abbe38F);
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IstETH private constant stETH = IstETH(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IERC20 private constant CVX = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);

    // Convex-related
    IConvexBooster private convexBooster = IConvexBooster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    IConvexFxsBooster private convexFXSBooster = IConvexFxsBooster(0xD8Bd5Cdd145ed2197CB16ddB172DF954e3F28659);
    IConvexClaimZap private convexClaimZap = IConvexClaimZap(0x4890970BB23FCdF624A0557845A29366033e6Fa2);

    enum LpAbiType {
        LSDETH, // frxETH/ETH, rETH/ETH using IPoolLSDETH
        TWOLSDSTABLE, // frxETH/rETH using IPool2LSDStable
        TWOCRYPTO, // ankrETH/frxETH using IPool2Crypto
        LSDWETH // frxETH/WETH using IPoolLSDWETH
    }

    enum FrxSfrxType {
        NONE, // neither frxETH or sfrxETH
        FRXETH, // frxETH
        SFRXETH // sfrxETH
    }

    enum EthType {
        NONE, // ankrETH/frxETH
        RAWETH, // frxETH/ETH
        STETH, // frxETH/stETH
        WETH // frxETH/WETH
    }

    struct PoolInfo {
        bool hasCvxVault; // If there is a cvxLP vault
        bool hasStkCvxFxsVault; // If there is a stkcvxLP vault
        uint8 frxEthIndex; // coins() index of frxETH/sfrxETH
        uint8 ethIndex; // coins() index of ETH/stETH/WETH
        address rewardsContractAddress; // Address for the Convex BaseRewardPool for the cvxLP
        address fxsPersonalVaultAddress; // Address for the stkcvxLP vault, if present
        // address poolAddress; // Where the actual tokens are in the pool
        address lpTokenAddress; // The LP token address. Sometimes the same as poolAddress
        address[2] poolCoins; // The addresses of the coins in the pool
        uint32 lpDepositPid; // _convexBaseRewardPool.pid
        LpAbiType lpAbiType; // General pool parameter
        FrxSfrxType frxEthType; // frxETH and sfrxETH
        EthType ethType; // ETH, WETH, and LSDs
        uint256 lpDeposited; // Total LP
        uint256 lpMaxAllocation; // Max token allocation per pool
    }

    // PoolInfo struct
    PoolInfo private poolInfo;

    // FXS Personal Vault
    bytes32[] private vaultKekIds;
    mapping(bytes32 => uint256) public kekIdTotalDeposit;

    /* =============================================== CONSTRUCTOR ====================================================== */

    /// @notice constructor
    /// @param _params CurveLsdAmoConstructorParams
    constructor(
        CurveLsdAmoConstructorParams memory _params
    )
        OperatorRole(_params.operatorAddress)
        Timelock2Step(_params.timelockAddress)
        EtherRouterRole(_params.etherRouterAddress)
    {
        frxEthMinterAddress = _params.frxEthMinterAddress;
        amoHelper = CurveLsdAmoHelper(_params.amoHelperAddress);

        // Configure the pool
        _addOrSetPool(_params.poolConfigData);

        // Decode
        (address _baseRewardPoolAddress, uint256 _convexPid) = abi.decode(_params.cvxAndStkcvxData, (address, uint256));

        // Configure the cvxLP vault (not stkcvxLP)
        if (_baseRewardPoolAddress != address(0)) {
            // Configure the cvxLP vault
            _setPoolVault(_baseRewardPoolAddress);

            // Configure the stkcvx vault (not cvxLP)
            _createFxsVault(_convexPid);
        }

        // Make sure get_virtual_price() exists on the pool
        pool.get_virtual_price();
    }

    /* ================================================ MODIFIERS ======================================================= */

    /// @notice Makes sure the function ends within the budget
    modifier onBudget() {
        _;
        PoolInfo memory p = poolInfo;
        if (p.lpDeposited > p.lpMaxAllocation) {
            revert OverLpBudget();
        }
    }

    /* ============================================== INTERNAL FUNCTIONS =================================================== */

    /// @notice Checks if msg.sender is the timelock address, operator, or Ether Router
    function _requireIsTimelockOperatorOrEthRouter() internal view {
        if (
            !((msg.sender == timelockAddress) ||
                (msg.sender == operatorAddress) ||
                (msg.sender == address(etherRouter)))
        ) revert NotTimelockOperatorOrEtherRouter();
    }

    /// @notice Checks if msg.sender is the timelock address or the operator
    function _requireIsTimelockOrOperator() internal view {
        if (!((msg.sender == timelockAddress) || (msg.sender == operatorAddress))) revert NotTimelockOrOperator();
    }

    /// @notice Checks if the CVX vault exists
    function _requireHasCVXVault() internal view {
        if (!poolInfo.hasCvxVault) revert PoolNoCVXVault();
    }

    /// @notice Checks if the FXS vault exists
    function _requirehasStkCvxFxsVault() internal view {
        if (!poolInfo.hasStkCvxFxsVault) revert PoolNoFXSVault();
    }

    /* ========================================================================================================== */
    /* ================================================== VIEWS ================================================= */
    /* ========================================================================================================== */

    /// @notice Show full Curve Pool parameters
    function getFullPoolInfo() external view returns (PoolInfo memory) {
        return poolInfo;
    }

    /// @notice Get the array of kek_ids
    function getVaultKekIds() external view returns (bytes32[] memory) {
        return vaultKekIds;
    }

    /* ========================================================================================================== */
    /* ============================================ DEPOSIT FUNCTIONS =========================================== */
    /* ========================================================================================================== */

    /// @notice Ether Router sends ETH and it will be invested into the defaultFXSVault's cvxLP booster
    /// @dev If you want to do this manually, do depositToCurveLP() first, then depositToCvxLPVault()
    function depositEther() external payable {
        // Deposit in the default strategy
        // Also checks to make sure only the Ether Router is sending this to avoid griefs and confusion
        _investEthInDefaultCvxLPVault(msg.value, false);
    }

    /// @notice (Internal) Curve LP -> cvxLP (in Convex's vault). Deposit Pool LP tokens, convert them to Convex LP, and deposit into their vault
    /// @param _poolLpIn Amount of LP for deposit
    function _depositCurveLPToVaultedCvxLP(uint256 _poolLpIn) internal {
        _requireHasCVXVault();

        // Approve the isMetaPool LP tokens for the vault contract
        ERC20 _poolLpToken = ERC20(poolInfo.lpTokenAddress);
        _poolLpToken.approve(address(convexBooster), _poolLpIn);

        // Deposit the isMetaPool LP into the vault contract
        convexBooster.deposit(poolInfo.lpDepositPid, _poolLpIn, true);

        emit DepositToCvxLPVault(_poolLpIn);
    }

    /// @notice Curve LP direct to -> stkcvxLP (in the Frax farm). Deposit Pool LP tokens, convert them to Convex LP, and deposit into their vault
    /// @param _poolLpIn Amount of LP for deposit
    /// @param _kekId The kek_id to deposit more into. Leave as 0x if you want to create a new one.
    /// @return _kekIdReturned lock stake ID
    function depositCurveLPToVaultedStkCvxLP(
        uint256 _poolLpIn,
        bytes32 _kekId
    ) external returns (bytes32 _kekIdReturned) {
        _requireIsTimelockOrOperator();
        _requirehasStkCvxFxsVault();

        // Approve the LP tokens for the vault contract
        ERC20 _poolLpToken = ERC20(poolInfo.lpTokenAddress);
        _poolLpToken.approve(poolInfo.fxsPersonalVaultAddress, _poolLpIn);

        // Instantiate the FXS vault contract
        IFxsPersonalVault _fxsVault = IFxsPersonalVault(poolInfo.fxsPersonalVaultAddress);

        // Either create a new kek_id or add to an existing one
        if (_kekId == bytes32(0)) {
            // Use a new kek_id
            // Only stake for the minimum lock time
            uint256 _minSecs = IFraxFarm(_fxsVault.stakingAddress()).lock_time_min();

            // Need to lock for at least 1 second or there could be divide-by-zero problems down the road
            if (_minSecs == 0) _minSecs = 1;

            // Create a new kek_id
            _kekIdReturned = _fxsVault.stakeLockedCurveLp(_poolLpIn, _minSecs);
            vaultKekIds.push(_kekIdReturned);
            kekIdTotalDeposit[_kekIdReturned] = _poolLpIn;
        } else {
            // Use the existing kek_id
            _kekIdReturned = _kekId;

            // Add to an existing stake
            if (_poolLpIn > 0) {
                kekIdTotalDeposit[_kekId] += _poolLpIn;
                _fxsVault.lockAdditionalCurveLp(_kekId, _poolLpIn);
            }
        }
    }

    /// @notice (External) 2 coins -> LP. Function to deposit tokens to specific Curve Pool
    /// @param _ethIn Amount of Eth to deposit
    /// @param _useOneCoin Whether to use balanced (false), or oneCoin (true) withdrawal routes
    /// @return _lpOut The actual amount of LP out
    /// @return _nonEthUsed The amount of the non-ETH token used
    function depositToCurveLP(uint256 _ethIn, bool _useOneCoin) public returns (uint256 _lpOut, uint256 _nonEthUsed) {
        _requireIsTimelockOrOperator();
        return _depositToCurveLP(msg.sender, _ethIn, _useOneCoin);
    }

    /// @notice (Internal) Function to deposit tokens to specific Curve Pool
    /// @param _caller Address that originally called the deposit flow. Affects slippage
    /// @param _ethIn Amount of Eth (or LSD/WETH) to deposit
    /// @param _useOneCoin Whether to use balanced (false), or oneCoin (true) withdrawal routes
    /// @return _lpOutActual The actual amount of LP out
    /// @return _nonEthUsed The amount of the non-ETH token used
    function _depositToCurveLP(
        address _caller,
        uint256 _ethIn,
        bool _useOneCoin
    ) internal onBudget returns (uint256 _lpOutActual, uint256 _nonEthUsed) {
        // Helper variable
        uint256 _ethIndex = poolInfo.ethIndex;

        // Need to estimate the amount of LP generated
        // --------------------------------------------------------
        // Calculate the balanced info (info used by both routes)
        (
            uint256 _lpMinOut,
            ,
            uint256[2] memory _coinsInBalanced,
            uint256[2] memory _lpPerCoinsBalancedE18,
            uint256 _lp_virtual_price
        ) = amoHelper.calcMiscBalancedInfoWithParams(address(this), poolAddress, poolInfo, _ethIndex, _ethIn);

        // console2.log("_coinsInBalanced[0]: %s", _coinsInBalanced[0]);
        // console2.log("_coinsInBalanced[1]: %s", _coinsInBalanced[1]);
        // console2.log("ratio: %s", (_coinsInBalanced[0] * 1e6) / (_coinsInBalanced[0] + _coinsInBalanced[1]));

        // Make sure the pool imbalance is tolerable
        {
            // Get the ratio of token0 to token1
            uint256 _ratioE6 = (_coinsInBalanced[0] * 1e6) / (_coinsInBalanced[0] + _coinsInBalanced[1]);

            // Revert if the ratio is out of acceptable bounds
            if ((_ratioE6 < minTkn0ToTkn1RatioE6) || (_ratioE6 > maxTkn0ToTkn1RatioE6)) revert PoolTooImbalanced();
        }

        // Choose the route
        uint256[2] memory _coinsInToUse;
        if (_useOneCoin) {
            // OneCoin
            _coinsInToUse[_ethIndex] = _ethIn;

            // _lpMinOut should be at least as good as if you were depositing balanced
            _lpMinOut = (_ethIn * 1e18) / _lp_virtual_price;
        } else {
            // Do nothing else, _lpMinOut is already good
            _coinsInToUse = _coinsInBalanced;
        }

        // Account for our extra buffer slippage
        if (_caller == address(etherRouter)) {
            _lpMinOut = _lpMinOut - ((_lpMinOut * depositWithdrawSlippageRouterE6) / (1e6));
        } else {
            _lpMinOut = _lpMinOut - ((_lpMinOut * depositWithdrawSlippageTimelockOperatorE6) / (1e6));
        }

        // If WETH or stETH is part of the pool, instead of ETH
        if (poolInfo.ethType == EthType.WETH) {
            // See how much WETH you currently have
            uint256 _currWeth = WETH.balanceOf(address(this));

            // Use existing WETH first
            if (_currWeth >= _ethIn) {
                // Do nothing and use existing WETH
            } else {
                // Convert ETH to WETH as needed

                // ETH -> WETH
                WETH.deposit{ value: _ethIn - _currWeth }();
            }
        } else if (poolInfo.ethType == EthType.STETH) {
            // ETH -> stETH

            // See how much stETH you already have
            uint256 _existingStEth = stETH.balanceOf(address(this));

            // See how much ETH you need to convert to stETH
            if (_existingStEth >= _ethIn) {
                // Do nothing, you have enough stETH already
            } else {
                // Exchange for what you need
                // Account for rebasing
                _coinsInToUse[_ethIndex] = convertEthToStEth(_ethIn - _existingStEth);
            }
        }

        // Do approvals
        // --------------------------------------------------------
        for (uint256 i = 0; i < 2; ) {
            // Only do approvals for ERC20s, not ETH
            if (!(poolInfo.ethType == EthType.RAWETH && (i == poolInfo.ethIndex))) {
                ERC20 _token = ERC20(poolInfo.poolCoins[i]);
                if (_coinsInToUse[i] > 0) {
                    _token.approve(poolAddress, 0); // For USDT and others
                    _token.approve(poolAddress, _coinsInToUse[i]);
                }
            }
            unchecked {
                ++i;
            }
        }

        // Avoid stack too deep
        {
            // Check for ETH
            // --------------------------------------------------------
            uint256 eth_value = 0;
            if (poolInfo.ethType == EthType.RAWETH) {
                eth_value = _coinsInToUse[poolInfo.ethIndex];
            }

            // ABIs are slightly different when ETH is involved
            // --------------------------------------------------------
            if (poolInfo.lpAbiType == LpAbiType.LSDETH) {
                _lpOutActual = IPoolLSDETH(poolAddress).add_liquidity{ value: eth_value }(_coinsInToUse, _lpMinOut);
            } else {
                // LSD/LSD Stable and LSD/LSD Volatile have similar ABIs for add_liquidity
                _lpOutActual = IPool2LSDStable(poolAddress).add_liquidity(_coinsInToUse, _lpMinOut);
            }
        }

        // Mark the _nonEthUsed
        // --------------------------------------------------------
        if (_ethIndex == 0) {
            _nonEthUsed = _coinsInToUse[1];
        } else {
            _nonEthUsed = _coinsInToUse[0];
        }

        // Increment the total LP deposited
        // --------------------------------------------------------
        poolInfo.lpDeposited += _lpOutActual;

        emit DepositToPool(_coinsInToUse, _lpOutActual, _caller != address(etherRouter));
    }

    /// @notice (External) (Curve LP -> cvxLP). Deposit Pool LP tokens, convert them to Convex LP, and deposit into their vault
    /// @param _poolLpIn Amount of LP for deposit
    function depositToCvxLPVault(uint256 _poolLpIn) external {
        _requireIsTimelockOrOperator();
        _depositCurveLPToVaultedCvxLP(_poolLpIn);
    }

    /// @notice Invest ETH in the designated default FXS vault's cvxLP (convexBooster)
    /// @param _ethIn The amount of ETH to invest
    /// @param _useOneCoin Whether to use balanced (false), or oneCoin (true) withdrawal routes
    /// @param _curve_lp_generated How much vanilla Curve LP was generated
    /// @param _frxEthUsed How much frxEth was used
    function _investEthInDefaultCvxLPVault(
        uint256 _ethIn,
        bool _useOneCoin
    ) internal returns (uint256 _curve_lp_generated, uint256 _frxEthUsed) {
        // Make sure only the Ether Router is sending this to avoid griefs and confusion
        _requireSenderIsEtherRouter();

        // Make the deposit
        (_curve_lp_generated, _frxEthUsed) = _depositToCurveLP(msg.sender, _ethIn, _useOneCoin);

        // Deposit the LP into the cvxLP vault
        // Note: We don't automatically want to go to the stkcvxLP personal vault as too many kekIds would be generated
        // stkcvxLP vaulting should be done manually, and not for the entire portion of "ready" funds.
        _depositCurveLPToVaultedCvxLP(_curve_lp_generated);
    }

    /// @notice Needs to be here to receive ETH
    receive() external payable {
        // Do nothing for now.
    }

    /* ========================================================================================================== */
    /* =========================================== WITHDRAW FUNCTIONS =========================================== */
    /* ========================================================================================================== */

    /// @notice Ether Router can pull out ETH by unwinding vaults and/or FXS Vaulted LP
    /// @param _caller The address that originally called for the request
    /// @param _recipient Recipient of the ETH
    /// @param _ethRequested ETH amount
    /// @param _useOneCoin Whether to use balanced (false), or oneCoin (true) withdrawal routes
    /// @return _ethOut Amount of ETH generated. Ignores LSDs
    /// @return _remainingEth Unfulfilled amount of ETH that the recipient still needs to get from somewhere else. Should be _ethRequested - _ethOut
    function _requestEther(
        address _caller,
        address payable _recipient,
        uint256 _ethRequested,
        bool _useOneCoin
    ) internal nonReentrant returns (uint256 _ethOut, uint256 _remainingEth) {
        // Set helper variable
        uint256 _ethIndex = poolInfo.ethIndex;

        // Look for free ETH/LSD/WETH first
        _remainingEth = _ethRequested;

        // Check how much free ETH you have first
        uint256 _currentEthBalance = address(this).balance;

        // If there is enough free ETH, send that, otherwise start scrounging in more places
        if (_ethRequested <= _currentEthBalance) {
            // Send the free ETH to the recipient directly
            // Should not fail unless recipient is not payable
            (bool sent, ) = payable(_recipient).call{ value: _ethRequested }("");
            if (!sent) revert EthTransferFailedAMO(0);

            // Account for the free ETH sent out
            _ethOut = _ethRequested;
            _remainingEth = 0;
        } else {
            // Send ANY free ETH first, even if it is partial
            if (_currentEthBalance > 0) {
                // Send the free ETH to the recipient directly
                (bool sent, ) = payable(_recipient).call{ value: _currentEthBalance }("");
                if (!sent) revert EthTransferFailedAMO(1);

                // Account for the ETH sent out
                _ethOut += _currentEthBalance;
                _remainingEth -= _currentEthBalance;
            }

            // If you have WETH or non-FRAX LSDs, convert them to ETH
            {
                // Start scrounging
                // Scrounge a little more than you need to account for dust
                uint256 _scroungedOut = scroungeEthFromEquivalents((_remainingEth * 1e6) / (1e6 - swapSlippageE6));
                // _remainingEth + ((_remainingEth * swapSlippageE6) / (1e6))

                // If there is excess ETH, just let it sit in contract. It can be used for subsequent actions
                if (_scroungedOut > _remainingEth) {
                    _scroungedOut = _remainingEth;
                }

                // Account for the ETH sent out
                _ethOut += _scroungedOut;
                _remainingEth -= _scroungedOut;

                // Send the free ETH to the recipient directly
                (bool sent, ) = payable(_recipient).call{ value: _scroungedOut }("");
                if (!sent) revert EthTransferFailedAMO(2);
            }

            // If you still need ETH, start unwinding LPs
            if (_remainingEth > 0) {
                // Calculate actual LP needed
                // ----------------------------------------------------------------------
                // Instantiate variables
                uint256 _lpNeeded;
                uint256 _withdrawnEth;
                uint256[2] memory _coinsOutMinToUse;
                uint256[2] memory _coinsOutActual;

                // Use the specified route (oneCoin vs balanced)
                if (_useOneCoin) {
                    // Calculate the amount of LP needed
                    // Assume stETH:ETH is 1:1
                    _coinsOutMinToUse[_ethIndex] = _remainingEth;
                    _lpNeeded = IPoolLSDETH(poolAddress).calc_token_amount(_coinsOutMinToUse, false);

                    // Don't need to use _coinsOutMinToUse for the oneCoin route as it will be lower bound in _withdrawOneCoin
                    // Do nothing
                } else {
                    // Get balanced information
                    uint256[2] memory _lpPerCoinsBalancedE18;
                    (_lpNeeded, , , _lpPerCoinsBalancedE18, ) = amoHelper.calcMiscBalancedInfoWithParams(
                        address(this),
                        poolAddress,
                        poolInfo,
                        _ethIndex,
                        _remainingEth
                    );

                    // See how much ETH equivalents are expected out
                    // _coinsOutMinToUse[_ethIndex] = (_lpNeeded * 1e18) / _lpPerCoinsBalancedE18[_ethIndex];
                }

                // Apply the extra LP amount (helps with rounding issues)
                _lpNeeded = _lpNeeded + ((_lpNeeded * extraWithdrawalLpPctE6) / (1e6));

                // Check free LP
                uint256 _freeLP = ERC20(poolInfo.lpTokenAddress).balanceOf(address(this));

                // Check cvxLP
                // Note: Ignore stkcvxLP as it will have to be manually unwound
                uint256 _cvxLP = IConvexBaseRewardPool(poolInfo.rewardsContractAddress).balanceOf(address(this));

                // Cap the amount of LP to withdraw based on how much is actually accessible
                if (_lpNeeded > (_freeLP + _cvxLP)) _lpNeeded = (_freeLP + _cvxLP);

                // Withdraw
                // ----------------------------------------------------------------------
                {
                    // Use as much LP as you can, even if it is < _lpNeeded
                    if (_lpNeeded > 0) {
                        // Determine how much cvxLP needs to be unwound
                        // Use free LP first
                        uint256 _cvxLpToUnwind;
                        if (_freeLP >= _lpNeeded) {
                            // You have enough free LP and don't need to unwind any cvxLP
                        } else {
                            // Use up what free LP you can and unwrap the rest
                            _cvxLpToUnwind = _lpNeeded - _freeLP;
                        }

                        // Unwrap cvxLP if needed
                        // Do the unwrap (vaulted cvxLP -> coins). Skip reward claim to save gas
                        if (_cvxLpToUnwind > 0) _withdrawAndUnwrapVaultedCvxLP(_cvxLpToUnwind, false);

                        // Do the LP withdrawal (LP -> coins)
                        if (_useOneCoin) {
                            // Do the withdrawal (oneCoin)
                            // Min out of 0 here will get corrected to the slippage-allowable amount downstream
                            _coinsOutActual = _withdrawOneCoin(_caller, _lpNeeded, _ethIndex, 0);
                        } else {
                            // Do the withdrawal (balanced)
                            // Min outs of [0, 0] here will get corrected to the slippage-allowable amount downstream
                            _coinsOutActual = _withdrawBalanced(_caller, _lpNeeded, _coinsOutMinToUse);
                        }

                        // Note the amount of ETH withdrawn
                        _withdrawnEth = _coinsOutActual[_ethIndex];
                    }
                }

                // Unwrap WETH or swap out LSDs for ETH
                // ----------------------------------------------------------------------
                if (poolInfo.ethType == EthType.WETH) {
                    // Unwrap any WETH that came out, if applicable
                    WETH.withdraw(_withdrawnEth);
                } else if (poolInfo.ethType == EthType.STETH) {
                    // Convert any stETH to ETH
                    uint256 _ethFromLsdConversion = convertStEthToEth(_withdrawnEth, false);

                    // Update _withdrawnEth to account for the conversion slippage
                    _withdrawnEth = _ethFromLsdConversion;
                }

                // Account for the ETH sent out
                // ----------------------------------------------------------------------
                if (_withdrawnEth >= _remainingEth) {
                    // Let any profit dust accumulate here. It will be sent out with the next requestEther anyways
                    // Otherwise under/overflows can start to appear
                    uint256 _remainingEthBefore = _remainingEth;
                    _ethOut += _remainingEth;
                    _remainingEth = 0;

                    // Give the ETH to the recipient
                    (bool sent, ) = payable(_recipient).call{ value: _remainingEthBefore }("");
                    if (!sent) revert EthTransferFailedAMO(3);
                } else {
                    // Give out as much as you can
                    _ethOut += _withdrawnEth;
                    _remainingEth -= _withdrawnEth;

                    // Give the ETH to the recipient
                    (bool sent, ) = payable(_recipient).call{ value: _withdrawnEth }("");
                    if (!sent) revert EthTransferFailedAMO(4);
                }
            }
        }

        // Sanity check
        if (_remainingEth != (_ethRequested - _ethOut)) {
            revert RequestEtherSanityCheck(_remainingEth, (_ethRequested - _ethOut));
        }
    }

    /// @notice Ether Router can pull out ETH by unwinding vaults and/or FXS Vaulted LP. Callable only by the Ether Router
    /// @param _ethRequested ETH amount
    /// @return _ethOut Amount of ETH generated. Ignores LSDs
    /// @return _remainingEth Unfulfilled amount of ETH that the recipient still needs to get from somewhere else. Should be _ethRequested - _ethOut
    function requestEtherByRouter(uint256 _ethRequested) external returns (uint256 _ethOut, uint256 _remainingEth) {
        _requireSenderIsEtherRouter();

        // Use balanced by default
        return _requestEther(msg.sender, payable(etherRouter), _ethRequested, false);
    }

    /// @notice Ether Router can pull out ETH by unwinding vaults and/or FXS Vaulted LP. Callable only by the timelock/operator
    /// @param _recipient Recipient of the ETH
    /// @param _ethRequested ETH amount
    /// @param _useOneCoin Whether to use balanced (false), or oneCoin (true) withdrawal routes
    /// @return _ethOut Amount of ETH generated. Ignores LSDs
    /// @return _remainingEth Unfulfilled amount of ETH that the recipient still needs to get from somewhere else. Should be _ethRequested - _ethOut
    function requestEtherByTimelockOrOperator(
        address payable _recipient,
        uint256 _ethRequested,
        bool _useOneCoin
    ) external returns (uint256 _ethOut, uint256 _remainingEth) {
        _requireIsTimelockOrOperator();

        // Recipient can only be timelock or operator
        if (!(_recipient == timelockAddress || _recipient == operatorAddress)) {
            revert InvalidRecipient();
        }

        // Can be balanced or oneCoin
        return _requestEther(msg.sender, _recipient, _ethRequested, _useOneCoin);
    }

    /// @notice stkcvxLP -> Curve LP. Withdraw Convex LP, convert it back to Pool LP tokens, and give them back to the sender
    /// @param _kekId lock stake ID
    /// @param _claimFxsToo Whether to claim FXS too
    function withdrawAndUnwrapFromFxsVault(bytes32 _kekId, bool _claimFxsToo) external {
        _requireIsTimelockOrOperator();
        _requirehasStkCvxFxsVault();

        kekIdTotalDeposit[_kekId] = 0;
        IFxsPersonalVault fxsVault = IFxsPersonalVault(poolInfo.fxsPersonalVaultAddress);
        fxsVault.withdrawLockedAndUnwrap(_kekId);

        // Optionally claim FXS
        if (_claimFxsToo) claimRewards(false, true);
    }

    /// @notice (cvxLP -> Curve LP). Internal for: Withdraw Convex LP, convert it back to Pool LP tokens, and give them back to the amo
    /// @param _amount Amount of cvxLP for withdraw
    /// @param _claim if claim rewards or not
    function _withdrawAndUnwrapVaultedCvxLP(uint256 _amount, bool _claim) internal {
        IConvexBaseRewardPool _convexBaseRewardPool = IConvexBaseRewardPool(poolInfo.rewardsContractAddress);

        _convexBaseRewardPool.withdrawAndUnwrap(_amount, _claim);

        emit WithdrawFromVault(_amount);
    }

    /// @notice (cvxLP -> Curve LP). External for: Withdraw Convex LP, convert it back to Pool LP tokens, and give them back to the amo
    /// @param _amount Amount of cvxLP for withdraw
    /// @param _claim if claim rewards or not
    function withdrawAndUnwrapVaultedCvxLP(uint256 _amount, bool _claim) external {
        _requireIsTimelockOrOperator();
        _requireHasCVXVault();
        _withdrawAndUnwrapVaultedCvxLP(_amount, _claim);
    }

    /// @notice Function to withdraw tokens from specific Curve Pool based on current pool ratio
    /// @param _lpIn Amount of LP token
    /// @param _minAmounts Min amounts of coin out
    /// @return _amountsReceived Coin amounts received
    function withdrawBalanced(
        uint256 _lpIn,
        uint256[2] memory _minAmounts
    ) external returns (uint256[2] memory _amountsReceived) {
        _requireIsTimelockOrOperator();

        // Call the internal function
        _amountsReceived = _withdrawBalanced(msg.sender, _lpIn, _minAmounts);
    }

    /// @notice Function to withdraw all tokens from specific Curve Pool based on current pool ratio
    /// @param _minAmounts Min amounts of coin out
    /// @param _useOneCoin If true, withdrawOneCoin would be used
    /// @return _amountsReceived Coin amounts received
    function withdrawAll(
        uint256[2] memory _minAmounts,
        bool _useOneCoin
    ) external returns (uint256[2] memory _amountsReceived) {
        _requireIsTimelockOrOperator();

        // Get this contracts LP token balance
        ERC20 _lpToken = ERC20(poolInfo.lpTokenAddress);
        uint256 _allLP = _lpToken.balanceOf(address(this));

        // Different routes
        if (_useOneCoin) {
            // Determine the coin index and minOut
            uint256 _minAmountOutFromUser;
            uint256 _oneCoinIndex;
            if ((_minAmounts[0] > 0 && _minAmounts[1] > 0) || (_minAmounts[0] == 0 && _minAmounts[1] == 0)) {
                // _minAmounts should be either [<value>, 0] or [0, <value>]
                revert MinAmountsIncorrect();
            } else if (_minAmounts[0] > 0) {
                _oneCoinIndex = 0;
                _minAmountOutFromUser = _minAmounts[0];
            } else {
                _oneCoinIndex = 1;
                _minAmountOutFromUser = _minAmounts[1];
            }

            // Call the internal function
            _amountsReceived = _withdrawOneCoin(msg.sender, _allLP, _oneCoinIndex, _minAmountOutFromUser);
        } else {
            // Call the internal function
            _amountsReceived = _withdrawBalanced(msg.sender, _allLP, _minAmounts);
        }
    }

    /// @notice Function to withdraw tokens from specific Curve Pool based on current pool ratio
    /// @param _caller Originating caller
    /// @param _lpIn Amount of LP token
    /// @param _minAmountsFromUser Min amounts of coin out
    /// @return _amountsReceived Coin amounts received
    function _withdrawBalanced(
        address _caller,
        uint256 _lpIn,
        uint256[2] memory _minAmountsFromUser
    ) internal returns (uint256[2] memory _amountsReceived) {
        // Check permissions
        _requireIsTimelockOperatorOrEthRouter();

        // Get the index for ETH/LSDs/WETH
        uint256 _ethIndex = poolInfo.ethIndex;

        // ABI for TWOCRYPTO doesn't return coin amounts on remove_liquidity so need to check it with balanceOfs
        uint256[] memory _freeCoinBalancesBefore;
        if (poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.TWOCRYPTO) {
            // Snapshot balances before
            _freeCoinBalancesBefore = amoHelper.showPoolFreeCoinBalancesWithParams(
                address(this),
                poolAddress,
                poolInfo
            );
        }

        // Different routes for Ether Router vs Timelock/Operator
        uint256[2] memory _minAmountsToUse; // 2 coins
        if (_caller == address(etherRouter)) {
            // Ether Router
            // -------------------------------------

            // Should be safe to use 0/0 minOuts here (per Dennis). A manipulated pool should give more value anyways than a non-manipulated one
            // Redundant for clarity
            _minAmountsToUse[0] = 0;
            _minAmountsToUse[1] = 0;
        } else {
            // Timelock/Operator
            // -------------------------------------

            // Min out should at least adhere to the max slippage
            // ----------------------------------------------------------------------

            // Calculate LP per coins
            (, , , uint256[2] memory _lpPerCoinsBalancedE18, ) = amoHelper.calcMiscBalancedInfoWithParams(
                address(this),
                poolAddress,
                poolInfo,
                0, // not used
                0 // not used
            );

            // Get the zero slippage min out for ETH/LSDs/WETH
            uint256 _absMinOutEth = (_lpIn * 1e18) / _lpPerCoinsBalancedE18[_ethIndex];

            // We don't care about frxETH or sfrxETH slippage when withdrawing balanced. If it is frontrun, it will always be favorable
            _minAmountsToUse[poolInfo.frxEthIndex] = 0;

            // Get the absolute smallest min out
            _absMinOutEth = _absMinOutEth - ((_absMinOutEth * depositWithdrawSlippageTimelockOperatorE6) / (1e6));

            // Override the min out if the user-supplied value is less than that from the contract slippage settings
            // E.g. user can be more strict, but not less, than the contract max slippage
            if (_absMinOutEth > _minAmountsFromUser[_ethIndex]) _minAmountsToUse[_ethIndex] = _absMinOutEth;
            else _minAmountsToUse[_ethIndex] = _minAmountsFromUser[_ethIndex];
        }

        // Remove the liquidity
        if (poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.TWOCRYPTO) {
            // remove_liquidity does not have a return value here
            pool.remove_liquidity(_lpIn, _minAmountsToUse);

            // Snapshot balances after
            uint256[] memory _freeCoinBalancesAfter = amoHelper.showPoolFreeCoinBalancesWithParams(
                address(this),
                poolAddress,
                poolInfo
            );

            // Track the change in asset balances
            for (uint256 i = 0; i < 2; ) {
                _amountsReceived[i] = _freeCoinBalancesAfter[i] - _freeCoinBalancesBefore[i];
                unchecked {
                    ++i;
                }
            }
        } else {
            // remove_liquidity returns uint256[2]
            _amountsReceived = IPoolLSDETH(address(pool)).remove_liquidity(_lpIn, _minAmountsToUse);
        }

        // Track the change in LP
        if (_lpIn > poolInfo.lpDeposited) poolInfo.lpDeposited = 0;
        else poolInfo.lpDeposited -= _lpIn;

        emit WithdrawFromPool(_lpIn, _amountsReceived, _caller != address(etherRouter));
    }

    /// @notice Function to withdraw one token from specific Curve Pool
    /// @param _lpIn Amount of LP token
    /// @param _coinIndex Curve Pool target/output coin index
    /// @param _minAmountOutFromUser Min amount of target coin out. Will be overidden to contract level min (based on depositWithdrawSlippageRouterE6) if too low
    /// @return _amountsOut Coin amounts out
    function withdrawOneCoin(
        uint256 _lpIn,
        uint256 _coinIndex,
        uint256 _minAmountOutFromUser
    ) external returns (uint256[2] memory _amountsOut) {
        _requireIsTimelockOrOperator();

        // Call the internal function
        return _withdrawOneCoin(msg.sender, _lpIn, _coinIndex, _minAmountOutFromUser);
    }

    /// @notice Function to withdraw one token from specific Curve Pool
    /// @param _caller The originating caller of the request
    /// @param _lpIn Amount of LP token
    /// @param _coinIndex Curve Pool target/output coin index
    /// @param _minAmountOutFromUser Min amount of target coin out. Will be overidden to contract level min (based on depositWithdrawSlippageRouterE6) if too low
    /// @return _amountsOut Coin amounts out
    function _withdrawOneCoin(
        address _caller,
        uint256 _lpIn,
        uint256 _coinIndex,
        uint256 _minAmountOutFromUser
    ) internal returns (uint256[2] memory _amountsOut) {
        uint256[2] memory _minAmountsToUse; // 2 coins

        // Min out should at least adhere to the max slippage
        // ----------------------------------------------------------------------

        // Calculate LP per coins
        // (, , , uint256[2] memory _lpPerCoinsBalancedE18, ) = amoHelper.calcMiscBalancedInfoWithParams(
        //     address(this),
        //     poolAddress,
        //     poolInfo,
        //     _coinIndex,
        //     0 // not used
        // );

        // Get the amount of coins expected from the input lp
        // ABIs are slightly different
        uint256 _absMinCoinOut;
        if (
            poolInfo.lpAbiType == LpAbiType.LSDETH ||
            poolInfo.lpAbiType == LpAbiType.TWOLSDSTABLE ||
            poolInfo.lpAbiType == LpAbiType.LSDWETH
        ) {
            _absMinCoinOut = pool.calc_withdraw_one_coin(_lpIn, int128(int256(_coinIndex)));
        } else {
            _absMinCoinOut = pool.calc_withdraw_one_coin(_lpIn, _coinIndex);
        }

        // // Get the zero slippage min outs
        // uint256 _absMinCoinOut = (_lpIn * 1e18) / _lpPerCoinsBalancedE18[_coinIndex];

        // Get the absolute smallest min out based on the contract slippage settings. Depends on the caller
        if (_caller == address(etherRouter)) {
            _absMinCoinOut = _absMinCoinOut - ((_absMinCoinOut * depositWithdrawSlippageRouterE6) / (1e6));
        } else {
            _absMinCoinOut = _absMinCoinOut - ((_absMinCoinOut * depositWithdrawSlippageTimelockOperatorE6) / (1e6));
        }

        // Override the min out if the user-supplied value is less than that from the contract slippage settings
        // E.g. user can be more strict, but not less, than the contract max slippage
        // NOTE: If _minAmountOutFromUser has zero slippage, this may revert due to the Curve fee
        if (_absMinCoinOut > _minAmountOutFromUser) _minAmountsToUse[_coinIndex] = _absMinCoinOut;
        else _minAmountsToUse[_coinIndex] = _minAmountOutFromUser;

        // ABIs are slightly different
        if (
            poolInfo.lpAbiType == LpAbiType.LSDETH ||
            poolInfo.lpAbiType == LpAbiType.TWOLSDSTABLE ||
            poolInfo.lpAbiType == LpAbiType.LSDWETH
        ) {
            // Use int128 for index
            IPoolLSDETH pool = IPoolLSDETH(poolAddress);

            // Uses int128
            int128 _index = _coinIndex.toInt128();
            _amountsOut[_coinIndex] = pool.remove_liquidity_one_coin(_lpIn, _index, _minAmountsToUse[_coinIndex]);
        } else {
            IPool2Crypto pool = IPool2Crypto(poolAddress);

            // Uses uint256
            _amountsOut[_coinIndex] = pool.remove_liquidity_one_coin(_lpIn, _coinIndex, _minAmountsToUse[_coinIndex]);
        }

        // Account for the used LP
        if (_lpIn > poolInfo.lpDeposited) poolInfo.lpDeposited = 0;
        else poolInfo.lpDeposited -= _lpIn;

        emit WithdrawFromPool(_lpIn, _amountsOut, false);

        return _amountsOut;
    }

    /* ========================================================================================================== */
    /* ====================================== SWAPS, CONVERSIONS, and BURNS ===================================== */
    /* ========================================================================================================== */

    /// @notice Burns excess frxETH
    /// @param _frxEthIn Amount of frxETH to burn
    function burnFrxEth(uint256 _frxEthIn) external {
        _requireIsTimelockOrOperator();

        // Burn the frxETH
        frxETH.burn(_frxEthIn);
    }

    /// @notice Converts ETH to WETH
    /// @param _ethIn Amount of ETH in
    function wrapEthToWeth(uint256 _ethIn) external payable {
        _requireIsTimelockOperatorOrEthRouter();

        // Make sure the pool uses WETH
        if (poolInfo.ethType != EthType.WETH) revert InvalidPoolOperation();

        // ETH -> WETH
        WETH.deposit{ value: _ethIn }();
    }

    /// @notice Converts WETH to ETH
    /// @param _wethIn Amount of WETH in
    function unwrapWethToEth(uint256 _wethIn) external payable {
        _requireIsTimelockOperatorOrEthRouter();

        // Make sure the pool uses WETH
        if (poolInfo.ethType != EthType.WETH) revert InvalidPoolOperation();

        // WETH -> ETH
        WETH.withdraw(_wethIn);
    }

    /// @notice Converts ETH to stETH
    /// @param _ethIn Amount of ETH in
    /// @return _stEthOutActual Actual amount of output stETH
    function convertEthToStEth(uint256 _ethIn) public payable returns (uint256 _stEthOutActual) {
        _requireIsTimelockOperatorOrEthRouter();

        // Make sure the pool uses stETH
        if (poolInfo.ethType != EthType.STETH) revert InvalidPoolOperation();

        // ETH -> stETH
        // ====================================================
        uint256 _stETHBalBefore = stETH.balanceOf(address(this));
        {
            stETH.submit{ value: _ethIn }(address(this));
        }
        uint256 _stETHBalAfter = stETH.balanceOf(address(this));

        // Check slippage, should be 1:1 but sometimes it can be off by a few wei
        uint256 _absoluteMinOut = ((_ethIn * (1e6 - swapSlippageE6)) / 1e6);
        _stEthOutActual = _stETHBalAfter - _stETHBalBefore;
        if (_stEthOutActual < _absoluteMinOut) {
            revert EthLsdConversionSlippage(_stETHBalAfter - _stETHBalBefore, _absoluteMinOut);
        }
    }

    /// @notice Converts stETH to ETH. Chooses between 2 pre-set Curve pools. May not convert anything if the prices are bad
    /// @param _stEthIn Amount of stETH in
    /// @param _revertInsteadOfNoOp If true, this function will revert (instead of no-op) if the slippage is too bad
    /// @return _ethOutActual Actual amount of output Eth
    function convertStEthToEth(uint256 _stEthIn, bool _revertInsteadOfNoOp) public returns (uint256 _ethOutActual) {
        _requireIsTimelockOperatorOrEthRouter();

        // Make sure the pool uses stETH
        if (poolInfo.ethType != EthType.STETH) revert InvalidPoolOperation();

        // stETH -> ETH
        // ====================================================
        {
            // Info
            // --------
            // Route 0
            // Curve stETH/ETH Original [IstETHETH]: 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022
            // Coin0 = ETH, Coin1 = stETH
            // --------
            // Route 1
            // Curve stETH/ETH NG [I2PoolNoLendingNG]: 0x21E27a5E5513D6e65C4f830167390997aA84843a
            // Coin0 = ETH, Coin1 = stETH

            // See which route gives the best proceeds
            uint256[2] memory _ethOutEstimated;
            _ethOutEstimated[0] = IstETHETH(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022).get_dy(1, 0, _stEthIn);
            _ethOutEstimated[1] = I2PoolNoLendingNG(0x21E27a5E5513D6e65C4f830167390997aA84843a).get_dy(1, 0, _stEthIn);

            // // Apply slippage
            // _ethOutEstimated[0] = (_ethOutEstimated[0] * (1e6 - swapSlippageE6)) / 1e6;
            // _ethOutEstimated[1] = (_ethOutEstimated[1] * (1e6 - swapSlippageE6)) / 1e6;

            // Get the 1:1 min out assuming slippage only
            uint256 _absoluteMinOut = ((_stEthIn * (1e6 - swapSlippageE6)) / 1e6);

            // TODO
            // _absoluteMinOut MIGHT BE WRONG HERE. YOU SET A LOOSE SLIPPAGE IN THE TEST AND IT STILL FAILED
            // EITHER THAT, OR SOME LOGIC BELOW IS WRONG

            // Go with the better pool, or skip altogether if you would get a bad price
            if ((_absoluteMinOut > _ethOutEstimated[0]) && (_absoluteMinOut > _ethOutEstimated[1])) {
                // If the slippage is too bad, either revert or no-op
                if (_revertInsteadOfNoOp) {
                    if (_ethOutEstimated[0] > _ethOutEstimated[1]) {
                        // _ethOutEstimated[0] is higher
                        revert EthLsdConversionSlippage(_ethOutEstimated[0], _absoluteMinOut);
                    } else {
                        // _ethOutEstimated[1] is higher
                        revert EthLsdConversionSlippage(_ethOutEstimated[1], _absoluteMinOut);
                    }
                } else {
                    // Do nothing. Do not execute the trade.
                }
            } else if (_ethOutEstimated[0] > _ethOutEstimated[1]) {
                // Go with route 0
                // Approve
                stETH.approve(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022, _stEthIn);

                // Do the exchange
                _ethOutActual = IstETHETH(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022).exchange(
                    1,
                    0,
                    _stEthIn,
                    _ethOutEstimated[0]
                );
            } else {
                // Go with route 1
                // Approve
                stETH.approve(0x21E27a5E5513D6e65C4f830167390997aA84843a, _stEthIn);

                // Do the exchange
                _ethOutActual = I2PoolNoLendingNG(0x21E27a5E5513D6e65C4f830167390997aA84843a).exchange(
                    1,
                    0,
                    _stEthIn,
                    _ethOutEstimated[1]
                );
            }
        }
    }

    /// @notice Swaps frxETH for sfrxETH or vice versa
    /// @param _tknsIn Amount of input token
    /// @param _frxEthIsInput If frxETH is the input token. If false, sfrxETH is.
    /// @return _tknsOut Amount of output tokens
    function exchangeFrxEthSfrxEth(uint256 _tknsIn, bool _frxEthIsInput) public returns (uint256 _tknsOut) {
        _requireIsTimelockOperatorOrEthRouter();

        // Make sure the pool uses sfrxETH
        if (poolInfo.frxEthType != FrxSfrxType.SFRXETH) revert InvalidPoolOperation();

        // Determine the route
        if (_frxEthIsInput) {
            // Approve
            frxETH.approve(address(sfrxETH), _tknsIn);

            // Stake for sfrxETH
            _tknsOut = sfrxETH.deposit(_tknsIn, address(this));
        } else {
            // Unstake sfrxETH for frxETH
            _tknsOut = sfrxETH.redeem(_tknsIn, address(this), address(this));
        }
    }

    /// @notice Function to use Curve Pool to swap two tokens
    /// @param _inIndex256 Curve Pool input coin index
    /// @param _outIndex256 Curve Pool output coin index
    /// @param _inAmount Amount of input coin
    /// @param _actualOut Actual amount of output coin
    /// @param _minOutFromUser User-supplied minOut. Cannot be less than the minOut calculated from the contract's swapSlippageE6
    function poolSwap(
        uint256 _inIndex256,
        uint256 _outIndex256,
        uint256 _inAmount,
        uint256 _minOutFromUser
    ) external returns (uint256 _actualOut) {
        _requireIsTimelockOrOperator();

        // Instantiate variables
        uint256 _minOutToUse;

        // Some ABIs use int128
        int128 _inIndex128 = _inIndex256.toInt128();
        int128 _outIndex128 = _outIndex256.toInt128();

        // ABI differences, plus payability
        if (poolInfo.lpAbiType == LpAbiType.LSDETH) {
            // Instantiate the pool
            IPoolLSDETH _pool = IPoolLSDETH(poolAddress);

            // Calculate _minOutToUse, and add in the acceptable slippage
            // Market price: manipulatable
            // _minOutToUse = _pool.get_dy(_inIndex128, _outIndex128, _inAmount); // DO NOT USE
            // Assume 1:1 ETH to LSD for this check
            _minOutToUse = (_inAmount * (1e6 - swapSlippageE6)) / 1e6;

            // User minOut can be more strict, but not less, than the contract max slippage
            if (_minOutFromUser >= _minOutToUse) _minOutToUse = _minOutFromUser;
            else revert PoolSwapMinOut(_minOutFromUser, _minOutToUse);

            // If you are selling ETH for frxETH
            if (_inIndex256 == poolInfo.ethIndex) {
                // Do the exchange with value
                _actualOut = _pool.exchange{ value: _inAmount }(_inIndex128, _outIndex128, _inAmount, _minOutToUse);
            } else {
                // Approve the "in" token
                ERC20 _token = ERC20(poolInfo.poolCoins[_inIndex256]);
                _token.approve(poolAddress, 0); // For USDT and others
                _token.approve(poolAddress, _inAmount);

                // Do the exchange without value
                // Shown for clarity
                _actualOut = _pool.exchange{ value: 0 }(_inIndex128, _outIndex128, _inAmount, _minOutToUse);
            }
        } else if (poolInfo.lpAbiType == LpAbiType.TWOLSDSTABLE || poolInfo.lpAbiType == LpAbiType.LSDWETH) {
            // Instantiate the pool
            IPool2LSDStable _pool = IPool2LSDStable(poolAddress);

            // Calculate _minOutToUse, and add in the acceptable slippage
            // _minOutToUse = _pool.get_dy(_inIndex128, _outIndex128, _inAmount);
            // Assume 1:1 pricing for the two tokens in this check
            _minOutToUse = (_inAmount * (1e6 - swapSlippageE6)) / 1e6;

            // User minOut can be more strict, but not less, than the contract max slippage
            if (_minOutFromUser >= _minOutToUse) _minOutToUse = _minOutFromUser;
            else revert PoolSwapMinOut(_minOutFromUser, _minOutToUse);

            // Approve the "in" token
            ERC20 _token = ERC20(poolInfo.poolCoins[_inIndex256]);
            _token.approve(poolAddress, 0); // For USDT and others
            _token.approve(poolAddress, _inAmount);

            // Do the exchange. Not payable so cannot recycle into above "if" statement
            _actualOut = _pool.exchange(_inIndex128, _outIndex128, _inAmount, _minOutToUse);
        } else if (poolInfo.lpAbiType == LpAbiType.TWOCRYPTO) {
            // Instantiate the pool
            IPool2Crypto _pool = IPool2Crypto(poolAddress);

            // Calculate _minOutToUse, and add in the acceptable slippage
            _minOutToUse = _pool.get_dy(_inIndex256, _outIndex256, _inAmount);
            _minOutToUse = (_minOutToUse * (1e6 - swapSlippageE6)) / 1e6;

            // User minOut can be more strict, but not less, than the contract max slippage
            if (_minOutFromUser >= _minOutToUse) _minOutToUse = _minOutFromUser;
            else revert PoolSwapMinOut(_minOutFromUser, _minOutToUse);

            // Approve the "in" token
            ERC20 _token = ERC20(poolInfo.poolCoins[_inIndex256]);
            _token.approve(poolAddress, 0); // For USDT and others
            _token.approve(poolAddress, _inAmount);

            // Do the exchange
            _actualOut = _pool.exchange(_inIndex256, _outIndex256, _inAmount, _minOutToUse);
        }

        emit Swap(_inIndex256, _outIndex256, _inAmount, _minOutToUse);
    }

    /// @notice Unwind WETH or LSDs for ETH
    /// @param _desiredEth The amount of ETH you are seeking
    /// @return _actualOut The amount of ETH that was successfully scrounged
    function scroungeEthFromEquivalents(uint256 _desiredEth) public returns (uint256 _actualOut) {
        _requireIsTimelockOperatorOrEthRouter();

        // Determine what to look for
        if (poolInfo.ethType == EthType.WETH) {
            // See how much WETH you actually have
            uint256 _bal = WETH.balanceOf(address(this));

            // Either withdraw all of it, or a partial amount
            if (_bal >= _desiredEth) {
                // You have enough, only withdraw what you need
                WETH.withdraw(_desiredEth);

                // WETH -> ETH is always 1:1
                _actualOut = _desiredEth;
            } else {
                // Withdraw all you have
                WETH.withdraw(_bal);

                // WETH -> ETH is always 1:1
                _actualOut = _bal;
            }
        } else if (poolInfo.ethType == EthType.STETH) {
            // See how much stETH you actually have
            uint256 _bal = stETH.balanceOf(address(this));

            // Either withdraw all of it, or a partial amount
            // Assume 1:1 stETH/ETH for this check
            if (_bal >= _desiredEth) {
                // You have enough, only exchange for what you need
                _actualOut = convertStEthToEth(_desiredEth, false);
            } else {
                // Exchange all you can
                _actualOut = convertStEthToEth(_bal, false);
            }

            // For _bal >= _desiredEth: You will probably have either a small shortage or profit due to slippage
            // If there is excess ETH, just let it sit in contract. It can be used for subsequent actions
            if (_actualOut > _desiredEth) {
                _actualOut = _desiredEth;
            }
        }
    }

    /* ========================================================================================================== */
    /* ============================================= REWARDS RELATED ============================================ */
    /* ========================================================================================================== */

    /// @notice Claim CVX, CRV, and FXS rewards
    /// @param _claimCvxLPVault Claim convex vault rewards (vaulted cvxLP)
    /// @param _claimStkCvxLPVault Claim FXS personal vault rewards (vaulted stkcvxLP)
    function claimRewards(bool _claimCvxLPVault, bool _claimStkCvxLPVault) public {
        _requireIsTimelockOrOperator();

        if (_claimCvxLPVault) {
            address[] memory rewardContracts = new address[](1);
            rewardContracts[0] = poolInfo.rewardsContractAddress;
            uint256[] memory chefIds = new uint256[](0);

            convexClaimZap.claimRewards(rewardContracts, chefIds, false, false, false, 0, 0);
        }
        if (_claimStkCvxLPVault) {
            if (poolInfo.hasStkCvxFxsVault) {
                IFxsPersonalVault fxsVault = IFxsPersonalVault(poolInfo.fxsPersonalVaultAddress);
                fxsVault.getReward();
            }
        }
    }

    /// @notice Withdraw rewards
    /// @param _crvAmount CRV Amount to withdraw
    /// @param _cvxAmount CVX Amount to withdraw
    /// @param _cvxCRVAmount cvxCRV Amount to withdraw
    /// @param _fxsAmount FXS Amount to withdraw
    /// @param _recipient Recipient address for the rewards
    function withdrawRewards(
        uint256 _crvAmount,
        uint256 _cvxAmount,
        uint256 _cvxCRVAmount,
        uint256 _fxsAmount,
        address _recipient
    ) external {
        _requireIsTimelockOrOperator();
        if (!(_recipient == timelockAddress || _recipient == operatorAddress)) {
            revert InvalidRecipient();
        }
        if (_crvAmount > 0) IERC20(CRV_ADDRESS).safeTransfer(_recipient, _crvAmount);
        if (_cvxAmount > 0) IERC20(address(CVX)).safeTransfer(_recipient, _cvxAmount);
        if (_cvxCRVAmount > 0) IERC20(CVXCRV_ADDRESS).safeTransfer(_recipient, _cvxCRVAmount);
        if (_fxsAmount > 0) IERC20(FXS_ADDRESS).safeTransfer(_recipient, _fxsAmount);
    }

    /* ========================================================================================================== */
    /* ======================================= INTERNAL SETTERS & CREATORS ====================================== */
    /* ========================================================================================================== */

    /// @notice Add new Curve Pool
    /// @param _poolConfigData config data for a new pool
    function _addOrSetPool(bytes memory _poolConfigData) internal {
        (
            uint8 _frxEthIndex,
            uint8 _ethIndex,
            address _poolAddress,
            address _lpTokenAddress,
            LpAbiType _lpAbiType,
            FrxSfrxType _frxEthType,
            EthType _ethType
        ) = abi.decode(_poolConfigData, (uint8, uint8, address, address, LpAbiType, FrxSfrxType, EthType));

        {
            poolAddress = _poolAddress;
            pool = IMinCurvePool(poolAddress);
            address[2] memory _poolCoins;
            _poolCoins[0] = pool.coins(0);
            _poolCoins[1] = pool.coins(1);
            poolInfo = PoolInfo({
                hasCvxVault: false,
                hasStkCvxFxsVault: false,
                frxEthIndex: _frxEthIndex,
                ethIndex: _ethIndex,
                rewardsContractAddress: address(0),
                fxsPersonalVaultAddress: address(0),
                // poolAddress: _poolAddress,
                lpTokenAddress: _lpTokenAddress,
                poolCoins: _poolCoins,
                lpDepositPid: 0,
                lpAbiType: _lpAbiType,
                frxEthType: _frxEthType,
                ethType: _ethType,
                lpDeposited: 0,
                lpMaxAllocation: 0
            });
        }
    }

    /// @notice Create a personal vault for that pool (i.e. the stkcvxLP personal vault address)
    /// @param _pid Pool id in FXS booster pool registry
    /// @return _fxsPersonalVaultAddress The address of the created vault
    function _createFxsVault(uint256 _pid) internal returns (address _fxsPersonalVaultAddress) {
        _requireHasCVXVault();
        poolInfo.hasStkCvxFxsVault = true;
        _fxsPersonalVaultAddress = convexFXSBooster.createVault(_pid);
        poolInfo.fxsPersonalVaultAddress = _fxsPersonalVaultAddress;
        IFxsPersonalVault fxsVault = IFxsPersonalVault(_fxsPersonalVaultAddress);
        if (poolInfo.lpTokenAddress != fxsVault.curveLpToken()) revert LPNotMatchingFromPID();
    }

    /// @notice Set Curve Pool Convex vault (i.e. the cvxLP address)
    /// @param _rewardsContractAddress Convex Rewards Contract Address (BaseRewardPool)
    function _setPoolVault(address _rewardsContractAddress) internal {
        poolInfo.hasCvxVault = true;
        IConvexBaseRewardPool _convexBaseRewardPool = IConvexBaseRewardPool(_rewardsContractAddress);
        poolInfo.lpDepositPid = uint32(_convexBaseRewardPool.pid());
        poolInfo.rewardsContractAddress = _rewardsContractAddress;
    }

    /* ========================================================================================================== */
    /* ===================================== RESTRICTED GOVERNANCE FUNCTIONS ==================================== */
    /* ========================================================================================================== */

    /// @notice Add / Remove a function selector for an execution target address
    /// @param _targetAddress Target address
    /// @param _selector The selector
    /// @param _enabled Whether the selector is enabled or disabled
    function setExecuteSelector(address _targetAddress, bytes4 _selector, bool _enabled) external {
        _requireSenderIsTimelock();

        _setExecuteSelector(_targetAddress, _selector, _enabled);
    }

    /// @notice Add / Remove an execution target address
    /// @param _targetAddress Target address
    /// @param _enabled Whether the target address as a whole is enabled or disabled
    function setExecuteTarget(address _targetAddress, bool _enabled) external {
        _requireSenderIsTimelock();

        _setExecuteTarget(_targetAddress, _enabled);
    }

    /// @notice Change the Operator address
    /// @param _newOperatorAddress Operator address
    function setOperatorAddress(address _newOperatorAddress) external {
        _requireSenderIsTimelock();
        _setOperator(_newOperatorAddress);
    }

    /// @notice Set Curve Pool max LP
    /// @param _maxLP Maximum LP the AMO can have
    function setMaxLP(uint256 _maxLP) external {
        _requireSenderIsTimelock();

        // Set the max
        poolInfo.lpMaxAllocation = _maxLP;

        emit PoolAllocationsSet(poolInfo.lpMaxAllocation);
    }

    /// @notice Set Curve Pool accounting params for LP transfer
    /// @param _lpAmount Amount of LP
    /// @param _isDeposit is this a LP deposit or withdraw
    function setPoolManualLPTrans(uint256 _lpAmount, bool _isDeposit) external onBudget {
        _requireSenderIsTimelock();

        // Either add or subtract
        if (_isDeposit) {
            poolInfo.lpDeposited += _lpAmount;
        } else {
            poolInfo.lpDeposited -= _lpAmount;
        }

        // Dummy coin amounts
        uint256[2] memory _coinAmounts;

        // Emit events, marking them as manually set tx's
        if (_isDeposit) {
            emit DepositToPool(_coinAmounts, _lpAmount, true);
        } else {
            emit WithdrawFromPool(_lpAmount, _coinAmounts, true);
        }
    }

    /// @notice Set the default slippages
    /// @param _depositWithdrawSlippageRouterE6 Max slippage for the Ether Router. E.g. 100000 = 10%, 100 = 0.01%
    /// @param _depositWithdrawSlippageTimelockOperatorE6 Max slippage for the Timelock or Operator. E.g. 100000 = 10%, 100 = 0.01%
    /// @param _extraWithdrawalLpPctE6 Extra percent of LP to use when withdrawing. Helps with rounding issues. E.g. 100000 = 10%, 100 = 0.01%
    /// @param _swapSlippageE6 Max swap slippage plus fee. E.g. 100000 = 10%, 100 = 0.01%
    /// @param _minTkn0ToTkn1RatioE6 Minimum ratio of token0 to token1 for _depositToCurveLP. Used to limit sandwiching. (e.g. 150000 -> 15 tkn0 to 85 tkn1).
    /// @param _maxTkn0ToTkn1RatioE6 Max ratio of token0 to token1 for _depositToCurveLP. Used to limit sandwiching. (e.g. 850000 -> 85 tkn0 to 15 tkn1).
    function setSlippages(
        uint256 _depositWithdrawSlippageRouterE6,
        uint256 _depositWithdrawSlippageTimelockOperatorE6,
        uint256 _extraWithdrawalLpPctE6,
        uint256 _swapSlippageE6,
        uint256 _minTkn0ToTkn1RatioE6,
        uint256 _maxTkn0ToTkn1RatioE6
    ) external {
        _requireSenderIsTimelock();
        depositWithdrawSlippageRouterE6 = _depositWithdrawSlippageRouterE6;
        depositWithdrawSlippageTimelockOperatorE6 = _depositWithdrawSlippageTimelockOperatorE6;
        extraWithdrawalLpPctE6 = _extraWithdrawalLpPctE6;
        swapSlippageE6 = _swapSlippageE6;
        minTkn0ToTkn1RatioE6 = _minTkn0ToTkn1RatioE6;
        maxTkn0ToTkn1RatioE6 = _maxTkn0ToTkn1RatioE6;
    }

    /// @notice Arbitrary execute. Must be approved by governance.
    /// @param _to Target address
    /// @param _value ETH value transferred, if any
    /// @param _data The calldata
    function whitelistedExecute(address _to, uint256 _value, bytes calldata _data) external returns (bytes memory) {
        _requireSenderIsTimelock();

        (bool _success, bytes memory _returnData) = _whitelistedExecute(_to, _value, _data);
        require(_success, "whitelisted transaction failed");

        return _returnData;
    }

    /* ========================================================================================================== */
    /* ================================================= EVENTS ================================================= */
    /* ========================================================================================================== */

    /// @notice The ```DepositToPool``` event fires when a deposit happens to a pair
    /// @param _coinsUsed Coins used to generate the LP
    /// @param _lpGenerated Actual amount of LP deposited
    /// @param _isManualTx Whether this accounting was set manually by the operator (true) or through an actual pool deposit (false)
    event DepositToPool(uint256[2] _coinsUsed, uint256 _lpGenerated, bool _isManualTx);

    /// @notice The ```DepositToCvxLPVault``` event fires when a deposit happens to a pair
    /// @param _lp Deposited LP amount
    event DepositToCvxLPVault(uint256 _lp);

    /// @notice The ```PoolAllocationsSet``` event fires when the max LP is set
    /// @param _maxLP Max allowed LP for the AMO
    event PoolAllocationsSet(uint256 _maxLP);

    /// @param _inIndex Curve Pool input coin index
    /// @param _outIndex Curve Pool output coin index
    /// @param _inAmount Amount of input coin
    /// @param _minOutAmount Min amount of output coin
    event Swap(uint256 _inIndex, uint256 _outIndex, uint256 _inAmount, uint256 _minOutAmount);

    /// @notice The ```WithdrawFromPool``` event fires when a withdrawal happens from a pool
    /// @param _lpUsed LP consumed for the withdrawal
    /// @param _coinsOut The coin amounts withdrawn
    /// @param _isManualTx Whether this accounting was set manually by the operator (true) or through an actual pool withdrawal (false)
    event WithdrawFromPool(uint256 _lpUsed, uint256[2] _coinsOut, bool _isManualTx);

    /// @notice The ```WithdrawFromVault``` event fires when a withdrawal happens from a pool
    /// @param _lp Withdrawn LP amount
    event WithdrawFromVault(uint256 _lp);

    /* ========================================================================================================== */
    /* ================================================= ERRORS ================================================= */
    /* ========================================================================================================== */

    /// @notice When your ETH <> LSD conversion output was not enough
    /// @param actualOut The actual out
    /// @param minOut The minOut based on contract slippage settings
    error EthLsdConversionSlippage(uint256 actualOut, uint256 minOut);

    /// @notice When an Ether transfer fails in requestEther
    /// @param step A marker in the code where it is failing
    error EthTransferFailedAMO(uint256 step);

    /// @notice When you are trying to perform an operation that this pool does not support
    error InvalidPoolOperation();

    /// @notice When the recipient of rewards, ether, etc is invalid or not authorized
    error InvalidRecipient();

    /// @notice When the LP address generated in createFxsVault's fxsVault.curveLpToken() doesn't match the one you supplied as an argument
    error LPNotMatchingFromPID();

    /// @notice When an action would put a constituent token of an LP over the budgeted amount
    error OverLpBudget();

    /// @notice When minAmounts has 2 nonzero entries or 2 zero entries for a oneCoin operation
    error MinAmountsIncorrect();

    /// @notice When msg.sender is not the owner, operator, or Ether Router
    error NotTimelockOperatorOrEtherRouter();

    /// @notice Thrown if the sender is not the timelock or the operator
    error NotTimelockOrOperator();

    /// @notice When the pool is too imbalanced (maxTkn0ToTkn1RatioE6)
    error PoolTooImbalanced();

    /// @notice When the cvxLP vault address was not provided previously with setPoolVault
    error PoolNoCVXVault();

    /// @notice When the stkcvxLP vault address was not generated previously with createFxsVault
    error PoolNoFXSVault();

    /// @notice When the provide LP pool has not been approved yet
    error PoolNotApproved();

    /// @notice When your poolSwap minOut was not enough
    /// @param minOutFromUser The user supplied minOut
    /// @param minOut The minOut based on contract slippage settings
    error PoolSwapMinOut(uint256 minOutFromUser, uint256 minOut);

    /// @notice When the requestEther function return values look wrong
    /// @param remainingEth0 _remainingEth
    /// @param remainingEth1 (_ethRequested - _ethOut)
    error RequestEtherSanityCheck(uint256 remainingEth0, uint256 remainingEth1);
}

// src/contracts/curve-amo/CurveLsdAmoHelper.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ======================== CurveLsdAmoHelper =========================
// ====================================================================

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna
// Amirnader Aghayeghazvini: https://github.com/amirnader-ghazvini

// Reviewer(s) / Contributor(s)
// Drake Evans: https://github.com/DrakeEvans
// Dennis: https://github.com/denett

// import "forge-std/console2.sol";

/// @notice Get frxETH/sfrxETH and ETH/LSD/WETH balances
/// @param amoEthFree Free and clear ETH/LSD/WETH
/// @param amoEthInLpBalanced ETH/LSD/WETH in LP (balanced withdrawal)
/// @param amoEthTotalBalanced Free and clear ETH/LSD/WETH + ETH/LSD/WETH in LP (balanced withdrawal)
/// @param amoFrxEthFree Free and clear frxETH/sfrxETH
/// @param amoFrxEthInLpBalanced frxETH/sfrxETH in LP (balanced withdrawal)
struct ShowAmoBalancedAllocsPacked {
    uint96 amoEthFree;
    uint96 amoEthInLpBalanced;
    uint96 amoEthTotalBalanced;
    uint96 amoFrxEthFree;
    uint96 amoFrxEthInLpBalanced;
}

contract CurveLsdAmoHelper is Ownable2Step {
    /* ============================================= STATE VARIABLES ==================================================== */

    // Constants (ERC20)
    IFrxEth_1 private constant frxETH = IFrxEth_1(0x5E8422345238F34275888049021821E8E08CAa1f);
    ISfrxEth_1 private constant sfrxETH = ISfrxEth_1(0xac3E018457B222d93114458476f3E3416Abbe38F);
    ERC20 private constant stETH = ERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    ERC20 private constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Curve AMO
    IcvxRewardPool private constant CVX_REWARD_POOL = IcvxRewardPool(0xCF50b810E57Ac33B91dCF525C6ddd9881B139332);

    // Oracles
    ISfrxEthUsdDualOracle public priceFeedfrxEthUsd;
    AggregatorV3Interface public priceFeedEthUsd;
    uint256 public oracleFrxEthUsdDecimals;
    uint256 public chainlinkEthUsdDecimals;
    uint256 public oracleTimeTolerance = 126_144_000; // 4 years (for tests)
    // uint256 public oracleTimeTolerance = 21600; // 6 hours

    /* ============================================= CONSTRUCTOR ==================================================== */

    /// @notice constructor
    /// @param _ownerAddress Address of CurveAMO Operator
    constructor(address _ownerAddress) Ownable(_ownerAddress) {
        // frxETH (Use ETH for now until the real chainlink one is live)
        priceFeedfrxEthUsd = ISfrxEthUsdDualOracle(0x3d3D868522b5a4035ADcb67BF0846D61597A6a6F);
        oracleFrxEthUsdDecimals = priceFeedfrxEthUsd.decimals();

        // ETH
        priceFeedEthUsd = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        chainlinkEthUsdDecimals = priceFeedEthUsd.decimals();
    }

    /* ================================================== VIEWS ========================================================= */

    // ----------------------- ALLOCATIONS -----------------------

    /// @notice Lending pool can pull out ETH/LSD/WETH by unwinding vaults and/or FXS Vaulted LP
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _amoEthFree Free and clear ETH/LSD/WETH
    /// @return _amoEthInLp ETH/LSD/WETH locked up in LP (balanced withdrawal)
    /// @return _amoEthTotalBalanced ETH/LSD/WETH locked up in LP (balanced withdrawal)
    /// @return _amoFrxEthFree Free and clear frxETH/sfrxETH
    /// @return _amoFrxEthInLpBalanced frxETH/sfrxETH in LP (balanced withdrawal)
    /// @dev used by the lending pool to determine utilization rates
    function getConsolidatedEthFrxEthBalance(
        address _curveAmoAddress
    )
        external
        view
        returns (
            uint256 _amoEthFree,
            uint256 _amoEthInLp,
            uint256 _amoEthTotalBalanced,
            uint256 _amoFrxEthFree,
            uint256 _amoFrxEthInLpBalanced
        )
    {
        uint256[10] memory allocs = showAllocationsSkipOneCoin(_curveAmoAddress);
        return (allocs[1], allocs[7], allocs[1] + allocs[7], allocs[0], allocs[6]);
    }

    /// @notice Lending pool can pull out ETH/LSD/WETH by unwinding vaults and/or FXS Vaulted LP. Uint96 / packed version
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _allocsPacked Returned allocations in condensed form
    /// @dev used by the lending pool to determine utilization rates
    function getConsolidatedEthFrxEthBalancePacked(
        address _curveAmoAddress
    ) external view returns (ShowAmoBalancedAllocsPacked memory _allocsPacked) {
        uint256[10] memory allocs = showAllocationsSkipOneCoin(_curveAmoAddress);
        _allocsPacked = ShowAmoBalancedAllocsPacked(
            uint96(allocs[1]),
            uint96(allocs[7]),
            uint96(allocs[1] + allocs[7]),
            uint96(allocs[0]),
            uint96(allocs[6])
        );
    }

    /// @notice Total USD value of frxETH/sfrxETH and ETH/LSD/WETH held. Uses CURRENT RATIO in LPs
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _frxETHValE18 frxETH value in USD
    /// @return _ethValE18 ETH/LSD/WETH value in USD
    /// @return _ttlValE18 Sum value
    function dollarBalancesOfEths(
        address _curveAmoAddress
    ) external view returns (uint256 _frxETHValE18, uint256 _ethValE18, uint256 _ttlValE18) {
        // Get the allocations
        uint256[10] memory allocations = showAllocations(_curveAmoAddress);

        // Get return values
        // showAllocations() already "converts" sfrxETH to equivalent frxETH at the proper ratio
        _frxETHValE18 = (allocations[8] * getFrxEthPriceE18()) / (1e18);
        _ethValE18 = (allocations[9] * getEthPriceE18()) / (1e18);
        _ttlValE18 = _frxETHValE18 + _ethValE18;
    }

    // ----------------------- ORACLE RELATED -----------------------

    /// @notice Gets the price of frxETH
    /// @return uint256 USD price in E18
    function getFrxEthPriceE18() public view returns (uint256) {
        // Fetch the USD per ETH price
        (, uint256 _updatedAt, uint256 _usdPerEth) = priceFeedfrxEthUsd.getEthUsdChainlinkPrice();
        if (!(_usdPerEth >= 0 && ((_updatedAt + oracleTimeTolerance) > block.timestamp))) revert InvalidOraclePrice();

        // console2.log("_isBadData: %s", _isBadData);
        // console2.log("_updatedAt: %s", _updatedAt);
        // console2.log("_usdPerEth: %s", _usdPerEth);
        // console2.log("block.timestamp: %s", block.timestamp);
        // console2.log("(_updatedAt + oracleTimeTolerance) > block.timestamp): %s", (_updatedAt + oracleTimeTolerance) > block.timestamp);

        // Update the _usdPerEth price to E18
        _usdPerEth = (_usdPerEth * (10 ** (18 - priceFeedfrxEthUsd.FRAX_USD_CHAINLINK_FEED_DECIMALS())));

        // Calculate the frxETH price
        return (priceFeedfrxEthUsd.getWethPerFrxEthCurveEma() * _usdPerEth) / priceFeedfrxEthUsd.decimals();
    }

    /// @notice Gets the price of ETH
    /// @return uint256 USD price in E18
    function getEthPriceE18() public view returns (uint256) {
        (uint80 _roundId, int256 _price, , uint256 _updatedAt, uint80 _answeredInRound) = priceFeedEthUsd
            .latestRoundData();
        if (!(_price >= 0 && ((_updatedAt + oracleTimeTolerance) > block.timestamp))) revert InvalidOraclePrice();

        return (uint256(_price) * 1e18) / (10 ** chainlinkEthUsdDecimals);
    }

    /// @notice Gets the estimated price of an LP token, in USD and in ETH. Assumes 1 ETH = 1 frxETH. Same as getEstLpPriceEthOrUsdE18WithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _inEthE18 LP price in ETH, E18
    /// @return _inUsdE18 LP price in USD, E18
    function getEstLpPriceEthOrUsdE18(
        address _curveAmoAddress
    ) public view returns (uint256 _inEthE18, uint256 _inUsdE18) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(
            _curveAmoAddress
        );

        // Get the estimated LP price
        return getEstLpPriceEthOrUsdE18WithParams(_curveAmo, _poolAddress, _poolInfo);
    }

    /// @notice Gets the estimated price of an LP token, in USD and in ETH. Assumes 1 ETH = 1 frxETH
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _inEthE18 LP price in ETH, E18
    /// @return _inUsdE18 LP price in USD, E18
    function getEstLpPriceEthOrUsdE18WithParams(
        CurveLsdAmo _curveAmo,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256 _inEthE18, uint256 _inUsdE18) {
        // Estimate the LP price
        if (
            _poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.LSDETH ||
            _poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.TWOLSDSTABLE ||
            _poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.LSDWETH
        ) {
            _inEthE18 = IPoolLSDETH(_poolAddress).get_virtual_price();
            _inUsdE18 = (_inEthE18 * getEthPriceE18()) / (1e18);
        } else if (_poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.TWOCRYPTO) {
            _inEthE18 = IPool2Crypto(_poolAddress).lp_price();
            _inUsdE18 = (_inEthE18 * getEthPriceE18()) / (1e18);
        } else {
            revert InvalidLpAbiType();
        }
    }

    // --------------------------------------------------------------

    /// @notice Get Curve AMO struct, the pool address, and the pool info
    /// @param _curveAmoAddress Address of the Curve AMO
    function getCurveInfoPack(
        address _curveAmoAddress
    ) public view returns (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) {
        // Fetch the Curve AMO
        _curveAmo = CurveLsdAmo(payable(_curveAmoAddress));

        // Fetch the pool address
        _poolAddress = _curveAmo.poolAddress();

        // Fetch the pool info
        _poolInfo = _curveAmo.getFullPoolInfo();
    }

    /// @notice Show allocations of a Curve AMO in frxETH and ETH. Same as showAllocationsWithParams but fetches info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _allocations [Free frxETH in AMO, Free ETH in AMO, Total frxETH Deposited into Pools, Total ETH + WETH deposited into Pools, Total frxETH One Coin Withdrawable, Total ETH One Coin Withdrawable, Total frxETH Balanced Withdrawable, Total ETH Balanced Withdrawable, Total frxETH, Total ETH]
    function showAllocations(address _curveAmoAddress) public view returns (uint256[10] memory _allocations) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(
            _curveAmoAddress
        );

        // Get the allocations
        return showAllocationsWithParams(_curveAmo, _poolAddress, _poolInfo, false);
    }

    /// @notice Show allocations of a Curve AMO in frxETH and ETH. Ignores oneCoin values (set to 0)
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _allocations [Free frxETH in AMO, Free ETH in AMO, Total frxETH Deposited into Pools, Total ETH + WETH deposited into Pools, Total frxETH One Coin Withdrawable, Total ETH One Coin Withdrawable, Total frxETH Balanced Withdrawable, Total ETH Balanced Withdrawable, Total frxETH, Total ETH]
    function showAllocationsSkipOneCoin(
        address _curveAmoAddress
    ) public view returns (uint256[10] memory _allocations) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(
            _curveAmoAddress
        );

        // Get the allocations
        return showAllocationsWithParams(_curveAmo, _poolAddress, _poolInfo, true);
    }

    /// @notice Show allocations of a Curve AMO in frxETH and ETH/LSD/WETH
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @param _skipOneCoinCalcs Save gas if you don't need oneCoin values
    /// @return _allocations [{0} Free frxETH/sfrxETH in AMO, {1} Free ETH/LSD/WETH in AMO, {2} Total frxETH/sfrxETH Deposited into Pools, {3} Total ETH/LSD/WETH deposited into Pools, {4} Total frxETH/sfrxETH One Coin Withdrawable, {5} Total ETH/LSD/WETH One Coin Withdrawable, {6} Total frxETH/sfrxETH Balanced Withdrawable, {7} Total ETH/LSD/WETH Balanced Withdrawable, {8} Total frxETH/sfrxETH, {9} Total ETH/LSD/WETH]
    function showAllocationsWithParams(
        CurveLsdAmo _curveAmo,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo,
        bool _skipOneCoinCalcs
    ) public view returns (uint256[10] memory _allocations) {
        // ------------Free frxETH/sfrxETH------------
        // [0] Free frxETH/sfrxETH in the AMO
        // Always look for frxETH
        _allocations[0] = frxETH.balanceOf(payable(_curveAmo));

        // Add in sfrxETH if applicable
        if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.SFRXETH) {
            // Convert to frxETH equivalent
            _allocations[0] += sfrxETH.convertToAssets(sfrxETH.balanceOf(payable(_curveAmo)));
        }

        // ------------Free ETH/LSD/WETH------------
        // [1] Free ETH/LSD/WETH in the AMO
        // Always look for ETH
        _allocations[1] = payable(_curveAmo).balance;

        // Add in LSD/WETH if applicable, assume 1:1 with ETH
        if (_poolInfo.ethType == CurveLsdAmo.EthType.STETH) _allocations[1] += stETH.balanceOf(payable(_curveAmo));
        else if (_poolInfo.ethType == CurveLsdAmo.EthType.WETH) _allocations[1] += WETH.balanceOf(payable(_curveAmo));

        // ------------Withdrawables------------
        {
            // DISUSED
            // // Get the amount deposited into LPs
            // (, uint256[] memory _depositedAmounts, ) = showPoolAccountingWithParams(_curveAmo, _poolAddress, _poolInfo);
            // {
            //     // Account for frxETH/sfrxETH
            //     // [2] Total frxETH/sfrxETH deposited into Pools
            //     // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            //     if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.FRXETH) {
            //         // frxETH
            //         _allocations[2] += _depositedAmounts[_poolInfo.frxEthIndex];
            //     } else if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.SFRXETH) {
            //         // sfrxETH: convert to frxETH equivalent
            //         _allocations[2] += sfrxETH.convertToAssets(_depositedAmounts[_poolInfo.frxEthIndex]);
            //     }

            //     // Account for ETH/LSD/WETH
            //     // [3] Total ETH/LSD/WETH deposited into Pools
            //     // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            //     if (
            //         _poolInfo.ethType == CurveLsdAmo.EthType.RAWETH ||
            //         _poolInfo.ethType == CurveLsdAmo.EthType.STETH ||
            //         _poolInfo.ethType == CurveLsdAmo.EthType.WETH
            //     ) {
            //         _allocations[3] += _depositedAmounts[_poolInfo.ethIndex];
            //     }
            // }

            // Need to see if these will fail
            // Optionally skip if you want to save gas and don't need these
            if (!_skipOneCoinCalcs) {
                // ------------One Coin Withdrawables------------
                // Get the amount withdrawable from LPs assuming you pull out all IN ONE COIN
                uint256[2] memory _withdrawablesOne = calcOneCoinsFullLPExitWithParams(
                    _curveAmo,
                    _poolAddress,
                    _poolInfo
                );

                // Account for frxETH/sfrxETH
                // [4] Total withdrawable frxETH/sfrxETH from LPs as ONE COIN
                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.FRXETH) {
                    // frxETH
                    _allocations[4] += _withdrawablesOne[_poolInfo.frxEthIndex];
                } else if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.SFRXETH) {
                    // sfrxETH: convert to frxETH equivalent
                    _allocations[4] += sfrxETH.convertToAssets(_withdrawablesOne[_poolInfo.frxEthIndex]);
                }

                // Account for ETH/LSD/WETH
                // [5] Total withdrawable ETH/LSD/WETH from LPs as ONE COIN
                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                if (
                    _poolInfo.ethType == CurveLsdAmo.EthType.RAWETH ||
                    _poolInfo.ethType == CurveLsdAmo.EthType.STETH ||
                    _poolInfo.ethType == CurveLsdAmo.EthType.WETH
                ) {
                    _allocations[5] += _withdrawablesOne[_poolInfo.ethIndex];
                }
            }

            {
                // ------------Balanced Withdrawables------------
                // Get the amount withdrawable from LPs assuming you pull out all AT THE CURRENT RATIO / BALANCED
                uint256[2] memory _withdrawablesBalanced = calcBalancedFullLPExitWithParams(
                    _curveAmo,
                    _poolAddress,
                    _poolInfo
                );

                // Account for frxETH/sfrxETH
                // [6] Total withdrawable frxETH/sfrxETH from LPs as BALANCED
                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.FRXETH) {
                    // frxETH
                    _allocations[6] += _withdrawablesBalanced[_poolInfo.frxEthIndex];
                } else if (_poolInfo.frxEthType == CurveLsdAmo.FrxSfrxType.SFRXETH) {
                    // sfrxETH: convert to frxETH equivalent
                    _allocations[6] += sfrxETH.convertToAssets(_withdrawablesBalanced[_poolInfo.frxEthIndex]);
                }

                // Account for ETH/LSD/WETH
                // [7] Total withdrawable ETH/LSD/WETH from LPs as BALANCED
                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                if (
                    _poolInfo.ethType == CurveLsdAmo.EthType.RAWETH ||
                    _poolInfo.ethType == CurveLsdAmo.EthType.STETH ||
                    _poolInfo.ethType == CurveLsdAmo.EthType.WETH
                ) {
                    _allocations[7] += _withdrawablesBalanced[_poolInfo.ethIndex];
                }
            }
        }

        // [8] Total frxETH/sfrxETH. Use BALANCED amounts
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        _allocations[8] = _allocations[0] + _allocations[6];
        // _allocations[2] = _allocations[8];

        // [9] Total ETH/LSD/WETH. Use BALANCED amounts
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        _allocations[9] = _allocations[1] + _allocations[7];
        // _allocations[3] = _allocations[9];
    }

    /// @notice Show allocations of CurveAMO into Curve Pool. Same as showPoolFreeCoinBalancesWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _freeCoinBalances Balance of free coins (or ETH) in the AMO. Not in any LP
    function showPoolFreeCoinBalances(
        address _curveAmoAddress
    ) public view returns (uint256[] memory _freeCoinBalances) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Get the constituent asset balances
        return showPoolFreeCoinBalancesWithParams(_curveAmoAddress, _poolAddress, _poolInfo);
    }

    /// @notice Show balances of a Curve LP's constituent tokens sitting in the CurveAMO uninvested
    /// @notice Used for before/after token balance checking during withdrawals
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _freeCoinBalances Balances of constituent coins that are in the CurveAMO
    function showPoolFreeCoinBalancesWithParams(
        address _curveAmoAddress,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256[] memory _freeCoinBalances) {
        // Get the balances for the constituent tokens in the LP
        _freeCoinBalances = new uint256[](2);
        IMinCurvePool _pool = IMinCurvePool(_poolAddress);
        for (uint256 i = 0; i < 2; ) {
            address token_addr = _pool.coins(i);
            if (
                ((_poolInfo.ethType == CurveLsdAmo.EthType.RAWETH && (i == _poolInfo.ethIndex))) ||
                token_addr == ETH_ADDRESS
            ) {
                _freeCoinBalances[i] = _curveAmoAddress.balance;
            } else {
                ERC20 _token = ERC20(token_addr);
                _freeCoinBalances[i] = _token.balanceOf(_curveAmoAddress);
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Show pool accounting info. Same as showPoolAccountingWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _freeCoinBalances Balance of free coins (or ETH) in the AMO. Not in any LP
    /// @return _depositedLp LP deposited into the pool
    /// @return _poolAndVaultAllocations [Vanilla Curve LP balance, cvxLP in booster, stkcvxLP in farm, total in vaults, total of all]
    /// @dev At no point should naked cvxLP or stkcvxLP be sitting in the AMO. Only vanilla curve LP
    function showPoolAccounting(
        address _curveAmoAddress
    )
        public
        view
        returns (uint256[] memory _freeCoinBalances, uint256 _depositedLp, uint256[5] memory _poolAndVaultAllocations)
    {
        // Fetch the Curve AMO, the pool address, and the pool info
        (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(
            _curveAmoAddress
        );

        // Get the pool accounting
        return showPoolAccountingWithParams(_curveAmo, _poolAddress, _poolInfo);
    }

    /// @notice Show pool accounting info
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _freeCoinBalances Balance of free coins (or ETH) in the AMO. Not in any LP
    /// @return _depositedLp LP deposited
    /// @return _poolAndVaultAllocations [Vanilla Curve LP balance, cvxLP in booster, stkcvxLP in farm, total in vaults, total of all]
    /// @dev At no point should naked cvxLP or stkcvxLP be sitting in the AMO. Only vanilla curve LP
    function showPoolAccountingWithParams(
        CurveLsdAmo _curveAmo,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo
    )
        public
        view
        returns (uint256[] memory _freeCoinBalances, uint256 _depositedLp, uint256[5] memory _poolAndVaultAllocations)
    {
        // Get the asset balances
        _freeCoinBalances = showPoolFreeCoinBalancesWithParams(address(_curveAmo), _poolAddress, _poolInfo);
        _depositedLp = _poolInfo.lpDeposited;

        ERC20 _lpToken = ERC20(_poolInfo.lpTokenAddress);
        _poolAndVaultAllocations[0] = _lpToken.balanceOf(payable(_curveAmo)); // Current LP balance

        (uint256 inCvxRewPool, uint256 inStkCvxFarm, uint256 totalInVaults) = lpInVaultsWithParams(
            _curveAmo,
            _poolInfo
        ); // cvxLP in booster + stkcvxLP in farm
        _poolAndVaultAllocations[1] = inCvxRewPool;
        _poolAndVaultAllocations[2] = inStkCvxFarm;
        _poolAndVaultAllocations[3] = totalInVaults;
        _poolAndVaultAllocations[4] = _poolAndVaultAllocations[0] + totalInVaults;
    }

    /// @notice Show lp tokens deposited in Convex BaseRewardPool and Frax FXS farm. Same as lpInVaultsWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return inCvxRewPool cvxLP in the Convex BaseRewardPool contract
    /// @return inStkCvxFarm stkcvxLP in the Frax FXS farm contract
    /// @return totalVaultLP Total cvxLP and stkcvxLP in their respective vaults
    function lpInVaults(
        address _curveAmoAddress
    ) public view returns (uint256 inCvxRewPool, uint256 inStkCvxFarm, uint256 totalVaultLP) {
        // Fetch the Curve AMO and the pool info
        (CurveLsdAmo _curveAmo, , CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Get the lp vault info
        return lpInVaultsWithParams(_curveAmo, _poolInfo);
    }

    /// @notice Show lp tokens deposited in Convex BaseRewardPool and Frax FXS farm
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return inCvxRewPool cvxLP in the Convex BaseRewardPool contract
    /// @return inStkCvxFarm stkcvxLP in the Frax FXS farm contract
    /// @return totalVaultLP Total cvxLP and stkcvxLP in their respective vaults
    function lpInVaultsWithParams(
        CurveLsdAmo _curveAmo,
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256 inCvxRewPool, uint256 inStkCvxFarm, uint256 totalVaultLP) {
        // cvxLP
        if (_poolInfo.hasCvxVault) {
            IConvexBaseRewardPool _convexBaseRewardPool = IConvexBaseRewardPool(_poolInfo.rewardsContractAddress);
            inCvxRewPool = _convexBaseRewardPool.balanceOf(address(_curveAmo));
        }

        // stkcvxLP
        if (_poolInfo.hasStkCvxFxsVault) {
            // bytes32[] memory _theseKeks = _curveAmo.getVaultKekIds();
            // for (uint256 i = 0; i < _theseKeks.length; ) {
            //     inStkCvxFarm += _curveAmo.kekIdTotalDeposit(_theseKeks[i]);
            //     unchecked {
            //         ++i;
            //     }
            // }
            IFxsPersonalVault fxsVault = IFxsPersonalVault(_poolInfo.fxsPersonalVaultAddress);
            IFraxFarm farm = IFraxFarm(fxsVault.stakingAddress());
            inStkCvxFarm = farm.lockedLiquidityOf(_poolInfo.fxsPersonalVaultAddress);
        }
        totalVaultLP = inCvxRewPool + inStkCvxFarm;
    }

    /// @notice Calculate expected token amounts if this AMO fully withdraws/exits from the indicated LP. Same as calcOneCoinsFullLPExitWithParams but will pre-fetch pool info for you
    /// @notice Using ONLY the indicated token 100%
    /// @notice NOT the same as calcBalancedFullLPExit because you are ignoring / not withdrawing other tokens
    /// @notice NOT necessarily frxETH and ETH/LSD/WETH
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _withdrawables Total withdrawable token0 directly from pool, Total withdrawable token1 directly from pool]
    function calcOneCoinsFullLPExit(address _curveAmoAddress) public view returns (uint256[2] memory _withdrawables) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(
            _curveAmoAddress
        );

        // Calculate the token amounts
        return calcOneCoinsFullLPExitWithParams(_curveAmo, _poolAddress, _poolInfo);
    }

    /// @notice Calculate expected token amounts if this AMO fully withdraws/exits from the indicated LP.
    /// @notice Using ONLY the indicated token 100%
    /// @notice NOT the same as calcBalancedFullLPExit because you are ignoring / not withdrawing other tokens
    /// @notice NOT necessarily frxETH and ETH/LSD/WETH
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _withdrawables Total withdrawable token0 directly from pool, Total withdrawable token1 directly from pool]
    function calcOneCoinsFullLPExitWithParams(
        CurveLsdAmo _curveAmo,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256[2] memory _withdrawables) {
        // Get the LP token balance
        (, , uint256[5] memory _poolAndVaultAllocations) = showPoolAccountingWithParams(
            _curveAmo,
            _poolAddress,
            _poolInfo
        );
        uint256 _oneStepBurningLp = _poolAndVaultAllocations[4];

        // Different ABIs should not matter here
        if (_oneStepBurningLp == 0) {
            _withdrawables[0] = 0;
            _withdrawables[1] = 0;
        } else if (_poolInfo.lpAbiType == CurveLsdAmo.LpAbiType.TWOCRYPTO) {
            // Use uint256
            IPool2Crypto pool = IPool2Crypto(_poolAddress);
            _withdrawables[0] = pool.calc_withdraw_one_coin(_oneStepBurningLp, 0);
            _withdrawables[1] = pool.calc_withdraw_one_coin(_oneStepBurningLp, 1);
        } else {
            // Use int128
            IPoolLSDETH pool = IPoolLSDETH(_poolAddress);
            _withdrawables[0] = pool.calc_withdraw_one_coin(_oneStepBurningLp, 0);
            _withdrawables[1] = pool.calc_withdraw_one_coin(_oneStepBurningLp, 1);
        }
    }

    /// @notice Calculate expected token amounts if this AMO fully withdraws/exits from the indicated LP. Same as calcBalancedFullLPExitWithParams but will pre-fetch pool info for you
    /// @notice NOT necessarily frxETH and ETH/LSD/WETH
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _withdrawables Recieving amount of each token after full withdrawal based on current pool ratio
    function calcBalancedFullLPExit(address _curveAmoAddress) public view returns (uint256[2] memory _withdrawables) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (CurveLsdAmo _curveAmo, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(
            _curveAmoAddress
        );

        // Calculate the token amounts
        return calcBalancedFullLPExitWithParams(_curveAmo, _poolAddress, _poolInfo);
    }

    /// @notice Calculate expected token amounts if this AMO fully withdraws/exits from the indicated LP
    /// @notice NOT necessarily frxETH and ETH/LSD/WETH
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _withdrawables Recieving amount of each token after full withdrawal based on current pool ratio
    function calcBalancedFullLPExitWithParams(
        CurveLsdAmo _curveAmo,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256[2] memory _withdrawables) {
        // Get the LP token balance
        (, , uint256[5] memory _poolAndVaultAllocations) = showPoolAccountingWithParams(
            _curveAmo,
            _poolAddress,
            _poolInfo
        );
        uint256 _oneStepBurningLp = _poolAndVaultAllocations[4];

        // Get the withdrawables
        _withdrawables = calcTknsForLPBalancedWithParams(_poolAddress, _poolInfo, _oneStepBurningLp);
    }

    // /// @notice Show Curve Pool parameters. Same as showPoolPartialInfoWithParams but will pre-fetch pool info for you
    // /// @param _curveAmoAddress Address of the Curve AMO
    // /// @return _lpAbiType ABI type of the pool
    // /// @return _frxEthType frxETH vs sfrxETH vs neither
    // /// @return _frxEthIndex The coin index of frxETH, if present
    // /// @return _ethType ETH vs LSD vs WETH vs neither
    // /// @return _ethIndex The coin index of ETH/LSD/WETH, if present
    // /// @return _hasCvxVault If there is a cvxLP vault
    // function showPoolPartialInfo(
    //     address _curveAmoAddress
    // )
    //     public
    //     view
    //     returns (
    //         CurveLsdAmo.LpAbiType _lpAbiType,
    //         CurveLsdAmo.FrxSfrxType _frxEthType,
    //         uint256 _frxEthIndex,
    //         CurveLsdAmo.EthType _ethType,
    //         uint256 _ethIndex,
    //         bool _hasCvxVault
    //     )
    // {
    //     // Fetch the pool info
    //     (, , CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

    //     // Return the partial pool info
    //     return showPoolPartialInfoWithParams(_poolInfo);
    // }

    // /// @notice Show Curve Pool parameters
    // /// @param _poolInfo PoolInfo struct of the _poolAddress
    // /// @return _lpAbiType ABI type of the pool
    // /// @return _frxEthType If frxETH is present
    // /// @return _frxEthIndex The coin index of frxETH, if present
    // /// @return _ethType ETH vs LSD vs WETH vs neither
    // /// @return _ethIndex The coin index of ETH/LSD/WETH, if present
    // /// @return _hasCvxVault If there is a cvxLP vault
    // function showPoolPartialInfoWithParams(
    //     CurveLsdAmo.PoolInfo memory _poolInfo
    // )
    //     public
    //     view
    //     returns (
    //         CurveLsdAmo.LpAbiType _lpAbiType,
    //         CurveLsdAmo.FrxSfrxType _frxEthType,
    //         uint256 _frxEthIndex,
    //         CurveLsdAmo.EthType _ethType,
    //         uint256 _ethIndex,
    //         bool _hasCvxVault
    //     )
    // {
    //     _lpAbiType = _poolInfo.lpAbiType;
    //     _frxEthType = _poolInfo.frxEthType;
    //     _frxEthIndex = _poolInfo.frxEthIndex;
    //     _ethType = _poolInfo.ethType;
    //     _ethIndex = _poolInfo.ethIndex;
    //     _hasCvxVault = _poolInfo.hasCvxVault;
    // }

    /// @notice Show max LP for the AMO. Same as showAmoMaxLPWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _lpMaxAllocation  Maximum LP the AMO can have
    function showAmoMaxLP(address _curveAmoAddress) public view returns (uint256 _lpMaxAllocation) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (, , CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Return the max allocations
        return showAmoMaxLPWithParams(_poolInfo);
    }

    /// @notice Show max LP for the AMO
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _lpMaxAllocation Maximum LP the AMO can have
    function showAmoMaxLPWithParams(
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256 _lpMaxAllocation) {
        _lpMaxAllocation = _poolInfo.lpMaxAllocation;
    }

    /// @notice Show Pool LP Token Address. Same as showPoolLPTokenAddressWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _lpTokenAddress Address of the LP token for the provided Curve AMOs LP pool. Might be the same address as the pool
    function showPoolLPTokenAddress(address _curveAmoAddress) public view returns (address _lpTokenAddress) {
        // Fetch the Curve AMO, the pool address, and the pool info
        (, , CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Get the LP token address
        return showPoolLPTokenAddressWithParams(_poolInfo);
    }

    /// @notice Show Pool LP Token Address
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _lpTokenAddress Address of the LP token for the provided Curve AMOs LP pool. Might be the same address as the pool
    function showPoolLPTokenAddressWithParams(
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (address _lpTokenAddress) {
        _lpTokenAddress = _poolInfo.lpTokenAddress;
    }

    /// @notice Show all rewards of CurveAMO. Same as showPoolRewardsWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _crvReward Pool CRV rewards
    /// @return _extraRewardAmounts [CRV claimable, CVX claimable, cvxCRV claimable]
    /// @return _extraRewardTokens [Token Address]
    /// @return _extraRewardsLength Length of the extra reward arrays
    function showPoolRewards(
        address _curveAmoAddress
    )
        public
        view
        returns (
            uint256 _crvReward,
            uint256[] memory _extraRewardAmounts,
            address[] memory _extraRewardTokens,
            uint256 _extraRewardsLength
        )
    {
        // Fetch the Curve AMO and the pool info
        (CurveLsdAmo _curveAmo, , CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Return the pool rewards
        return showPoolRewardsWithParams(_curveAmo, _poolInfo);
    }

    /// @notice Show all rewards of CurveAMO
    /// @param _curveAmo Address of the Curve AMO
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _crvReward Pool CRV rewards
    /// @return _extraRewardAmounts [CRV claimable, CVX claimable, cvxCRV claimable]
    /// @return _extraRewardTokens [Token Address]
    /// @return _extraRewardsLength Length of the extra reward arrays
    function showPoolRewardsWithParams(
        CurveLsdAmo _curveAmo,
        CurveLsdAmo.PoolInfo memory _poolInfo
    )
        public
        view
        returns (
            uint256 _crvReward,
            uint256[] memory _extraRewardAmounts,
            address[] memory _extraRewardTokens,
            uint256 _extraRewardsLength
        )
    {
        // Get the Base Reward pool
        IConvexBaseRewardPool _convexBaseRewardPool = IConvexBaseRewardPool(_poolInfo.rewardsContractAddress);

        // Calculate the amount of CRV claimable
        _crvReward = _convexBaseRewardPool.earned(address(_curveAmo));

        // Handle extra rewards
        _extraRewardsLength = _convexBaseRewardPool.extraRewardsLength();

        // Initialize the arrays
        _extraRewardAmounts = new uint256[](_extraRewardsLength);
        _extraRewardTokens = new address[](_extraRewardsLength);

        // Loop through the extra rewards
        for (uint256 i = 0; i < _extraRewardsLength; ) {
            IVirtualBalanceRewardPool _convexExtraRewardsPool = IVirtualBalanceRewardPool(
                _convexBaseRewardPool.extraRewards(i)
            );
            _extraRewardAmounts[i] = _convexExtraRewardsPool.earned(address(_curveAmo));
            _extraRewardTokens[i] = _convexExtraRewardsPool.rewardToken();
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Show all CVX rewards
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _cvxRewards
    function showCVXRewards(address _curveAmoAddress) public view returns (uint256 _cvxRewards) {
        _cvxRewards = CVX_REWARD_POOL.earned(_curveAmoAddress); // cvxCRV claimable
    }

    /// @notice Show Curve Pool parameters regarding vaults. Same as showPoolVaultsWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @return _lpDepositPid
    /// @return _rewardsContractAddress
    /// @return _fxsPersonalVaultAddress
    function showPoolVaults(
        address _curveAmoAddress
    ) public view returns (uint256 _lpDepositPid, address _rewardsContractAddress, address _fxsPersonalVaultAddress) {
        // Fetch the pool info
        (, , CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Return the pool vault info
        return showPoolVaultsWithParams(_poolInfo);
    }

    /// @notice Show Curve Pool parameters regarding vaults
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @return _lpDepositPid
    /// @return _rewardsContractAddress
    /// @return _fxsPersonalVaultAddress
    function showPoolVaultsWithParams(
        CurveLsdAmo.PoolInfo memory _poolInfo
    ) public view returns (uint256 _lpDepositPid, address _rewardsContractAddress, address _fxsPersonalVaultAddress) {
        // Get the struct info
        _lpDepositPid = _poolInfo.lpDepositPid;
        _rewardsContractAddress = _poolInfo.rewardsContractAddress;
        _fxsPersonalVaultAddress = _poolInfo.fxsPersonalVaultAddress;
    }

    /// @notice Info for depositing/withdrawing a given amount of one coin, assuming you deposit/withdraw at the current ratio. Same as calcMiscBalancedInfoWithParams but will pre-fetch pool info for you
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @param _desiredCoinIdx The index of the token you have/want
    /// @param _desiredCoinAmt Amount of token you have/want
    /// @return _lpAmount LP Amount generated/needed
    /// @return _undesiredCoinAmt Amount of undesired coins needed/generated
    /// @return _coinAmounts _desiredCoinAmt and _undesiredCoinAmt in their proper indices
    /// @return _lpPerCoinsBalancedE18 Amount of LP pet each token (coin 0 and coin 1). Useful for checking add/remove liquidity oneCoin positive vs negative slippage
    /// @return _lp_virtual_price The virtual price of the LP token
    function calcMiscBalancedInfo(
        address _curveAmoAddress,
        uint256 _desiredCoinIdx,
        uint256 _desiredCoinAmt
    )
        public
        view
        returns (
            uint256 _lpAmount,
            uint256 _undesiredCoinAmt,
            uint256[2] memory _coinAmounts,
            uint256[2] memory _lpPerCoinsBalancedE18,
            uint256 _lp_virtual_price
        )
    {
        // Fetch the pool address and the pool info
        (, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Get the LP and undesired coin amounts
        return
            calcMiscBalancedInfoWithParams(_curveAmoAddress, _poolAddress, _poolInfo, _desiredCoinIdx, _desiredCoinAmt);
    }

    /// @notice Info for depositing/withdrawing a given amount of one coin, assuming you deposit/withdraw at the current ratio
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @param _desiredCoinIdx The index of the token you need/want
    /// @param _desiredCoinAmt Amount of token you have/expect
    /// @return _lpAmount LP Amount generated/needed
    /// @return _undesiredCoinAmt Amount of undesired coin needed or generated
    /// @return _coinAmounts Helper array with the coin amounts needed
    /// @return _lpPerCoinsBalancedE18 Amount of LP that each token (coin 0 and coin 1). Useful for checking add/remove liquidity oneCoin positive vs negative slippage
    /// @return _lp_virtual_price The virtual price of the LP token
    function calcMiscBalancedInfoWithParams(
        address _curveAmoAddress,
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo,
        uint256 _desiredCoinIdx,
        uint256 _desiredCoinAmt
    )
        public
        view
        returns (
            uint256 _lpAmount,
            uint256 _undesiredCoinAmt,
            uint256[2] memory _coinAmounts,
            uint256[2] memory _lpPerCoinsBalancedE18,
            uint256 _lp_virtual_price
        )
    {
        // Fetch the pool
        IMinCurvePool pool = IMinCurvePool(_poolAddress);

        // Get the total LP supply
        uint256 _lpTotalSupply = ERC20(_poolInfo.lpTokenAddress).totalSupply();

        // Get the undesired token index
        uint256 _undesiredCoinIdx = _desiredCoinIdx == 0 ? 1 : 0;

        // Calculate the amount of undesired tokens
        _undesiredCoinAmt = (_desiredCoinAmt * pool.balances(_undesiredCoinIdx)) / (pool.balances(_desiredCoinIdx));

        // Fill in the amount of LP per token
        // I.e. if you put in 1 coin0 AND <BALANCED X AMT> coin1, how much LP do you get. And vice versa.
        _lpPerCoinsBalancedE18[0] = (_lpTotalSupply * 1e18) / pool.balances(0);
        _lpPerCoinsBalancedE18[1] = (_lpTotalSupply * 1e18) / pool.balances(1);

        // Fill in the return array. Included as a shortcut for various downstream functions
        _coinAmounts[_desiredCoinIdx] = _desiredCoinAmt;
        _coinAmounts[_undesiredCoinIdx] = _undesiredCoinAmt;

        // Return the virtual_price too
        _lp_virtual_price = pool.get_virtual_price();

        // Calculate the amount of LP
        // OLD METHOD
        _lpAmount =
            (_desiredCoinAmt * (ERC20(_poolInfo.lpTokenAddress).totalSupply())) /
            (pool.balances(_desiredCoinIdx));
        // NEW METHOD
        // _lpAmount = ((_desiredCoinAmt + _undesiredCoinAmt) * 1e18) / _lp_virtual_price;
    }

    // Example with 1 ETH and 3.31... frxETH
    // USE BLOCK 19000000 FOR https://etherscan.io/address/0x9c3b46c0ceb5b9e304fcd6d88fc50f7dd24b31bc#code
    // -------------------------------------
    // balances(0) = 10180818140651672236120
    // balances(1) = 33743836110495904554204
    // get_virtual_price() = 1000405078153916664
    // totalSupply() = 43898012684596754787230
    // (0) -> (1) ratio = 301708973079233384 = 0.301708973079233384
    // (1) -> (0) ratio = 3314452300818327750 = 3.31445230081832775
    // _undesiredCoinAmt = 3314452300818327750
    // -------------------------------------
    // _lpPerCoinsBalancedE18[0] = (43898012684596754787230 * 1e18) / 10180818140651672236120;
    // = 4311835461367631435 = 4.31183546136763143579

    // _lpPerCoinsBalancedE18[1] = (43898012684596754787230 * 1e18) / 33743836110495904554204;
    // = 1300919449135850574 = 1.300919449135850574

    // -------------------------------------
    // calc_token_amount([1000000000000000000, 0], true) (all WETH)
    // 1000860158890189845 LP

    // calc_token_amount([1000000000000000000, 0], true) (all frxETH)
    // 998858143934587105 LP

    // calc_token_amount([1000000000000000000, 3314452300818327750], true) (1 WETH, 3.31...e18 frxETH (Balanced remainder))
    // 4311835461367631435 LP

    // -------------------------------------
    // OLD METHOD, 1 ETH BALANCED
    // _lpAmount =
    //         (_desiredCoinAmt * (ERC20(_poolInfo.lpTokenAddress).totalSupply())) /
    //         (pool.balances(_desiredCoinIdx));
    // _lpAmount =
    //         (1e18 * 43898012684596754787230) /
    //         (10180818140651672236120);
    // = 4311835461367631435 = 4.31183546136763143579

    // -------------------------------------
    // NEW METHOD (balance vs lpPerCoinsBalanced), 1 ETH BALANCED
    // _lpAmount = (_desiredCoinAmt + _undesiredCoinAmt) / _lp_virtual_price;
    // _lpAmount = ((1000000000000000000 + 3314452300818327750) * 1e18) / 1000405078153916664;
    // = 4312705318109681301 = 4.312705318109681301

    /// @notice Get the balances of the underlying tokens for the given amount of LP, assuming you withdraw at the current ratio. Same as calcTknsForLPBalancedWithParams but will pre-fetch pool info for you
    /// @notice May not necessarily = balanceOf(<underlying token address>) due to accumulated fees
    /// @param _curveAmoAddress Address of the Curve AMO
    /// @param _lpAmount LP Amount
    /// @return _withdrawables Amount of each token expected
    function calcTknsForLPBalanced(
        address _curveAmoAddress,
        uint256 _lpAmount
    ) public view returns (uint256[2] memory _withdrawables) {
        // Fetch the pool address and the pool info
        (, address _poolAddress, CurveLsdAmo.PoolInfo memory _poolInfo) = getCurveInfoPack(_curveAmoAddress);

        // Get the token balances
        return calcTknsForLPBalancedWithParams(_poolAddress, _poolInfo, _lpAmount);
    }

    /// @notice Get the balances of the underlying tokens for the given amount of LP, assuming you withdraw at the current ratio
    /// @notice May not necessarily = balanceOf(<underlying token address>) due to accumulated fees
    /// @param _poolAddress Address of the Curve pool
    /// @param _poolInfo PoolInfo struct of the _poolAddress
    /// @param _lpAmount LP Amount
    /// @return _withdrawables Amount of each token expected
    function calcTknsForLPBalancedWithParams(
        address _poolAddress,
        CurveLsdAmo.PoolInfo memory _poolInfo,
        uint256 _lpAmount
    ) public view returns (uint256[2] memory _withdrawables) {
        // Get the total LP supply
        ERC20 _lpToken = ERC20(_poolInfo.lpTokenAddress);
        uint256 _lpTotalSupply = _lpToken.totalSupply();

        // Get the Curve pool
        IMinCurvePool pool = IMinCurvePool(_poolAddress);

        // Force an entrance to prevent a read reentrancy
        pool.get_virtual_price();

        for (uint256 i = 0; i < 2; ) {
            _withdrawables[i] = (pool.balances(i) * _lpAmount) / _lpTotalSupply;
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Set the frxETH and ETH oracles
    /// @param _frxethOracle Address of the frxETH oracle
    /// @param _ethOracle Address of the ETH oracle
    function setOracles(address _frxethOracle, address _ethOracle) external onlyOwner {
        priceFeedfrxEthUsd = ISfrxEthUsdDualOracle(_frxethOracle);
        priceFeedEthUsd = AggregatorV3Interface(_ethOracle);

        // Set the Chainlink oracle decimals
        oracleFrxEthUsdDecimals = priceFeedfrxEthUsd.decimals();
        chainlinkEthUsdDecimals = priceFeedEthUsd.decimals();
    }

    /// @notice Sets max acceptable time since the updatedAt for the oracles
    /// @param _secsTolerance Tolerance in seconds
    function setOracleTimeTolerance(uint256 _secsTolerance) external onlyOwner {
        oracleTimeTolerance = _secsTolerance;
    }

    /* =========================================== ERRORS =========================================== */

    /// @notice When the oracle returns an invalid price
    error InvalidOraclePrice();

    /// @notice When getEstLpPriceEthOrUsdE18() is provided with an invalid LP to price
    error InvalidLpAbiType();
}