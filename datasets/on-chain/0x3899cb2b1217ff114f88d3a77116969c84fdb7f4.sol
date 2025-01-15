// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

// File: @openzeppelin/contracts/utils/Pausable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

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
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
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
    function verifyCallResult(
        bool success,
        bytes memory returndata
    ) internal pure returns (bytes memory) {
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

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
    error SafeERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );

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
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeCall(token.transferFrom, (from, to, value))
        );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 requestedDecrease
    ) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(
                    spender,
                    currentAllowance,
                    requestedDecrease
                );
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeCall(
            token.approve,
            (spender, value)
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeCall(token.approve, (spender, 0))
            );
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
    function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            address(token).code.length > 0;
    }
}

// File: contracts/Staking.sol

pragma solidity ^0.8.24;

interface IERC20EXT {
    function decimals() external view returns (uint8);
}

struct StructAccount {
    address selfAddress;
    uint256 totalValueStaked;
    uint256 stakingRewardsClaimed;
    uint256[] stakingIds;
    uint256 lastStakeTime;
}

struct StructStaking {
    bool isActive;
    address owner;
    uint256 stakingId;
    uint256 valueStaked;
    uint256 startTime;
    uint256 stakingRewardClaimed;
    uint256 initialRewards;
    uint256 calStartTime;
    uint256 lockPeriod;
}

contract MineAIStake is Ownable, Pausable {
    using SafeERC20 for IERC20;
    uint256 private unstakeLockPeriod = 15 days;
    uint256 private maximumStakeAmountPerWallet = 1000_000_000 ether;

    address[] private _users;
    uint256 private _totalStakingRewardsDistributed;

    uint256 private _stakingsCount;

    uint256 private _calStakingReward;
    uint256 private _valueStaked;

    uint256 private _lastTimeRewardDistributed;

    address private _stakingTokenAddress;
    address private _rewardTokenAddress;

    bool private _noReentrancy;

    mapping(address => StructAccount) private _mappingAccounts;
    mapping(uint256 => StructStaking) private _mappingStakings;

    event SelfAddressUpdated(address newAddress);

    event Stake(uint256 value, uint256 stakingId);
    event UnStake(uint256 value);

    event ClaimedStakingReward(uint256 value);
    event DistributeStakingReward(uint256 value);

    modifier noReentrancy() {
        require(!_noReentrancy, "Reentrancy attack.");
        _noReentrancy = true;
        _;
        _noReentrancy = false;
    }

    constructor(
        address initialOwner,
        address rewardTokenAddress_,
        address stakingTokenAddress_
    ) Ownable(initialOwner) {
        uint256 currentTime = block.timestamp;
        _lastTimeRewardDistributed = currentTime;
        _rewardTokenAddress = rewardTokenAddress_;
        _stakingTokenAddress = stakingTokenAddress_;
    }

    function _updateUserAddress(
        StructAccount storage _userAccount,
        address _userAddress
    ) private {
        _userAccount.selfAddress = _userAddress;
        emit SelfAddressUpdated(_userAddress);
    }

    function _updateCalStakingReward(
        StructStaking storage stakingAccount,
        uint256 _value
    ) private {
        if (_calStakingReward > 0) {
            uint256 stakingReward = (_calStakingReward * _value) / _valueStaked;

            stakingAccount.initialRewards += stakingReward;
            _calStakingReward += stakingReward;
        }
    }

    function _stake(address _userAddress, uint256 _value) private {
        require(
            _userAddress != address(0),
            "_stake(): AddressZero cannot stake."
        );
        require(_value > 0, "_stake(): Value should be greater than zero.");

        StructAccount storage userAccount = _mappingAccounts[_userAddress];
        userAccount.lastStakeTime = block.timestamp; // Update last stake time
        uint256 currentStakingId = _stakingsCount;

        if (userAccount.selfAddress == address(0)) {
            _updateUserAddress(userAccount, _userAddress);
            _users.push(_userAddress);
        }

        userAccount.stakingIds.push(currentStakingId);
        userAccount.totalValueStaked += _value;

        StructStaking storage stakingAccount = _mappingStakings[
            currentStakingId
        ];

        stakingAccount.isActive = true;
        stakingAccount.owner = _userAddress;
        stakingAccount.stakingId = currentStakingId;
        stakingAccount.valueStaked = _value;
        stakingAccount.startTime = block.timestamp;
        stakingAccount.calStartTime = _lastTimeRewardDistributed;
        stakingAccount.lockPeriod = unstakeLockPeriod;

        _updateCalStakingReward(stakingAccount, _value);

        _valueStaked += _value;
        _stakingsCount++;

        emit Stake(_value, currentStakingId);
    }

    function _stakeWithLock(
        address _userAddress,
        uint256 _value,
        uint256 _lockPeriod
    ) private {
        require(
            _userAddress != address(0),
            "_stakeWithLock(): AddressZero cannot stake."
        );
        require(
            _value > 0,
            "_stakeWithLock(): Value should be greater than zero."
        );

        StructAccount storage userAccount = _mappingAccounts[_userAddress];
        userAccount.lastStakeTime = block.timestamp;
        uint256 currentStakingId = _stakingsCount;

        if (userAccount.selfAddress == address(0)) {
            _updateUserAddress(userAccount, _userAddress);
            _users.push(_userAddress);
        }

        userAccount.stakingIds.push(currentStakingId);
        userAccount.totalValueStaked += _value;

        StructStaking storage stakingAccount = _mappingStakings[
            currentStakingId
        ];
        stakingAccount.isActive = true;
        stakingAccount.owner = _userAddress;
        stakingAccount.stakingId = currentStakingId;
        stakingAccount.valueStaked = _value;
        stakingAccount.startTime = block.timestamp;
        stakingAccount.calStartTime = _lastTimeRewardDistributed;
        stakingAccount.lockPeriod = _lockPeriod; // Set custom lock period for this staking

        _updateCalStakingReward(stakingAccount, _value);

        _valueStaked += _value;
        _stakingsCount++;

        emit Stake(_value, currentStakingId);
    }

    function stake(
        address _userAddress,
        uint256 _valueInWei
    ) external whenNotPaused {
        StructAccount storage userAccount = _mappingAccounts[_userAddress];
        require(
            (_valueInWei + userAccount.totalValueStaked) <=
                maximumStakeAmountPerWallet,
            "Maximum per stake amount hit"
        );
        IERC20(_stakingTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _toTokens(_stakingTokenAddress, _valueInWei)
        );

        _stake(_userAddress, _valueInWei);
    }

    function _getStakingRewardsById(
        StructStaking memory stakingAccount
    ) private view returns (uint256 userStakingReward) {
        if (
            _calStakingReward > 0 &&
            stakingAccount.isActive &&
            stakingAccount.calStartTime < _lastTimeRewardDistributed
        ) {
            uint256 totalReward = ((_calStakingReward *
                stakingAccount.valueStaked) / _valueStaked);
            uint256 rewardClaimed = (stakingAccount.stakingRewardClaimed +
                stakingAccount.initialRewards);
            userStakingReward = totalReward - rewardClaimed;
        }
    }

    function getStakingRewardsById(
        uint256 _stakingId
    ) external view returns (uint256 userStakingReward) {
        return _getStakingRewardsById(_mappingStakings[_stakingId]);
    }

    function _getUserAllStakingRewards(
        StructAccount memory userAccount
    ) private view returns (uint256 userTotalStakingReward) {
        uint256[] memory userStakingIds = userAccount.stakingIds;

        for (uint256 i; i < userStakingIds.length; ++i) {
            StructStaking memory stakingAccount = _mappingStakings[
                userStakingIds[i]
            ];

            if (stakingAccount.isActive) {
                uint256 userStakingReward = _getStakingRewardsById(
                    stakingAccount
                );
                userTotalStakingReward += userStakingReward;
            }
        }
    }

    function getUserStakingRewards(
        address _userAddress
    ) external view returns (uint256 userTotalStakingReward) {
        StructAccount memory userAccount = _mappingAccounts[_userAddress];

        return _getUserAllStakingRewards(userAccount);
    }

    function _claimUserStakingReward(
        address _userAddress
    ) private returns (uint256 totalRewardClaimable) {
        StructAccount storage userAccount = _mappingAccounts[_userAddress];
        require(
            userAccount.stakingIds.length > 0,
            "_claimStakingReward(): You have no stakings"
        );

        for (uint256 i; i < userAccount.stakingIds.length; ++i) {
            StructStaking storage stakingAccount = _mappingStakings[
                userAccount.stakingIds[i]
            ];

            require(
                stakingAccount.owner == _userAddress,
                "You are not the owner of this staking."
            );

            if (stakingAccount.isActive) {
                uint256 userStakingReward = _getStakingRewardsById(
                    stakingAccount
                );

                if (userStakingReward > 0) {
                    stakingAccount.stakingRewardClaimed += userStakingReward;
                    totalRewardClaimable += userStakingReward;
                }
            }
        }

        if (totalRewardClaimable > 0) {
            userAccount.stakingRewardsClaimed += totalRewardClaimable;
            emit ClaimedStakingReward(totalRewardClaimable);
        }
    }

    function claimStakingReward(address _userAddress) external noReentrancy {
        uint256 rewardClaimable = _claimUserStakingReward(_userAddress);

        require(
            rewardClaimable > 0,
            "_claimUserStakingReward(): No rewards to claim."
        );

        uint256 rewardTokenBalance = IERC20(_rewardTokenAddress).balanceOf(
            address(this)
        );

        require(
            rewardTokenBalance >=
                _toTokens(_rewardTokenAddress, rewardClaimable),
            "claimStakingReward(): Contract has insufficient balance to pay."
        );

        IERC20(_rewardTokenAddress).safeTransfer(
            _userAddress,
            _toTokens(_rewardTokenAddress, rewardClaimable)
        );
    }

    function _unStake(
        address _userAddress
    ) private returns (uint256 tokenUnStaked, uint256 stakingRewardClaimed) {
        StructAccount storage userAccount = _mappingAccounts[_userAddress];

        require(
            block.timestamp >= userAccount.lastStakeTime + unstakeLockPeriod,
            "Account is still locked for unstaking"
        );

        require(
            userAccount.stakingIds.length > 0,
            "_unStake(): You have no stakings"
        );

        uint256 rewardClaimable = _claimUserStakingReward(_userAddress);

        if (rewardClaimable > 0) {
            stakingRewardClaimed += rewardClaimable;
        }

        uint256 calRewards;

        for (uint256 i; i < userAccount.stakingIds.length; ++i) {
            StructStaking storage stakingAccount = _mappingStakings[
                userAccount.stakingIds[i]
            ];

            require(
                stakingAccount.owner == _userAddress,
                "You are not the owner of this staking."
            );

            if (
                stakingAccount.isActive &&
                block.timestamp >=
                stakingAccount.startTime + stakingAccount.lockPeriod
            ) {
                stakingAccount.isActive = false;
                tokenUnStaked += stakingAccount.valueStaked;
                calRewards += stakingAccount.stakingRewardClaimed;
                calRewards += stakingAccount.initialRewards;
            }
        }

        require(tokenUnStaked > 0, "_unStake(): No value to unStake.");

        userAccount.totalValueStaked -= tokenUnStaked;
        _calStakingReward -= calRewards;
        _valueStaked -= tokenUnStaked;

        emit UnStake(tokenUnStaked);
    }

    function unStake() external {
        address msgSender = msg.sender;
        (uint256 tokenUnStaked, uint256 stakingRewardClaimed) = _unStake(
            msgSender
        );

        if (tokenUnStaked > 0) {
            IERC20(_stakingTokenAddress).safeTransfer(
                msgSender,
                _toTokens(_stakingTokenAddress, tokenUnStaked)
            );
        }

        if (stakingRewardClaimed > 0) {
            IERC20(_rewardTokenAddress).safeTransfer(
                msgSender,
                _toTokens(_rewardTokenAddress, stakingRewardClaimed)
            );
        }
    }

    function distributeStakingRewards(uint256 _amount) external {
        require(
            _amount > 0,
            "distributeStakingRewards(): Reward must be greater than zero."
        );

        IERC20(_rewardTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _toTokens(_rewardTokenAddress, _amount)
        );

        _calStakingReward += _amount;
        _lastTimeRewardDistributed = block.timestamp;
        _totalStakingRewardsDistributed += _amount;

        emit DistributeStakingReward(_amount);
    }

    function getContractDefault()
        external
        view
        returns (address stakingTokenAddress, address rewardTokenAddress)
    {
        stakingTokenAddress = _stakingTokenAddress;
        rewardTokenAddress = _rewardTokenAddress;
    }

    function setStakingTokenAddress(
        address stakingTokenAddress_
    ) external onlyOwner {
        _stakingTokenAddress = stakingTokenAddress_;
    }

    function setRewardTokenAddress(
        address rewardTokenAddress_
    ) external onlyOwner {
        _rewardTokenAddress = rewardTokenAddress_;
    }

    function getUsersParticipatedList()
        external
        view
        returns (address[] memory)
    {
        return _users;
    }

    function getUserShare(
        address _userAddress
    ) external view returns (uint256 userShare) {
        StructAccount memory userAccount = _mappingAccounts[_userAddress];

        userShare =
            (userAccount.totalValueStaked * 100 * 1 ether) /
            _valueStaked;
    }

    function getContractAnalytics()
        external
        view
        returns (
            uint256 usersCount,
            uint256 stakingsCount,
            uint256 totalStakingRewardsDistributed,
            uint256 calStakingReward,
            uint256 valueStaked,
            uint256 lastTimeRewardDistributed
        )
    {
        usersCount = _users.length;
        stakingsCount = _stakingsCount;
        totalStakingRewardsDistributed = _totalStakingRewardsDistributed;
        calStakingReward = _calStakingReward;
        valueStaked = _valueStaked;
        lastTimeRewardDistributed = _lastTimeRewardDistributed;
    }

    function getUserAccount(
        address _userAddress
    ) external view returns (StructAccount memory) {
        return _mappingAccounts[_userAddress];
    }

    function getStakingById(
        uint256 _stakingId
    ) external view returns (StructStaking memory) {
        return _mappingStakings[_stakingId];
    }

    function _toTokens(
        address tokenAddress_,
        uint256 _valueInWei
    ) private view returns (uint256 valueInTokens) {
        valueInTokens =
            (_valueInWei * 10 ** IERC20EXT(tokenAddress_).decimals()) /
            1 ether;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function manualAdd(
        address[] memory userAddresses,
        uint256[] memory values,
        uint256[] memory lockPeriods
    ) public onlyOwner {
        require(
            userAddresses.length == values.length,
            "Mismatched input lengths"
        );
        require(
            userAddresses.length == lockPeriods.length,
            "Mismatched input lengths"
        );

        for (uint256 i = 0; i < userAddresses.length; i++) {
            _stakeWithLock(userAddresses[i], values[i], lockPeriods[i]);
        }
    }

    function updateLockPeriod(uint256 lockPeriod) external onlyOwner {
        unstakeLockPeriod = lockPeriod;
    }

    function updatePerWalletMaximumAmount(
        uint256 _maximumStakeAmountPerWallet
    ) external onlyOwner {
        maximumStakeAmountPerWallet = _maximumStakeAmountPerWallet;
    }

    function withdrawTokens(
        address _tokenContract,
        uint256 _valueInWei
    ) external onlyOwner {
        IERC20(_tokenContract).safeTransfer(owner(), _valueInWei);
    }
}