// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.26;

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
abstract contract ReentrancyGuard {
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

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

event ReplaceImplementationStarted(address indexed previousImplementation, address indexed newImplementation);
event ReplaceImplementation(address indexed previousImplementation, address indexed newImplementation);
error Unauthorized();

/**
 * @title Upgradeable2Step
 * @notice This contract implements a two-step process for upgrading the implementation address. It provides security by allowing the owner to propose a new implementation and the implementation to accept itself.
 * @dev Inherits from `Ownable2Step`, allowing the contract owner to initiate the upgrade process, which must then be accepted by the proposed implementation.
 */
contract Upgradeable2Step is Ownable2Step {

    /// @notice The slot containing the address of the pending implementation contract.
    bytes32 public constant PENDING_IMPLEMENTATION_SLOT = keccak256("PENDING_IMPLEMENTATION_SLOT");

    /// @notice The slot containing the address of the current implementation contract.
    bytes32 public constant IMPLEMENTATION_SLOT = keccak256("IMPLEMENTATION_SLOT");

    /**
     * @dev Emitted when a new implementation is proposed.
     * @param previousImplementation The address of the previous implementation.
     * @param newImplementation The address of the new implementation proposed.
     */
    event ReplaceImplementationStarted(address indexed previousImplementation, address indexed newImplementation);

    /**
     * @dev Emitted when a new implementation is accepted and becomes active.
     * @param previousImplementation The address of the previous implementation.
     * @param newImplementation The address of the new active implementation.
     */
    event ReplaceImplementation(address indexed previousImplementation, address indexed newImplementation);

    /**
     * @dev Thrown when an unauthorized account attempts to execute a restricted function.
     */
    error Unauthorized();
      
    /**
     * @notice Initializes the contract and sets the deployer as the initial owner.
     * @dev Passes the deployer address to the `Ownable2Step` constructor.
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @notice Starts the implementation replacement process by setting a new pending implementation address.
     * @dev Can only be called by the owner. Emits the `ReplaceImplementationStarted` event.
     * @param impl_ The address of the new implementation contract to be set as pending.
     */
    function replaceImplementation(address impl_) public onlyOwner {
        bytes32 slot_pending = PENDING_IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot_pending, impl_)
        }
        emit ReplaceImplementationStarted(implementation(), impl_);
    }

    /**
     * @notice Completes the implementation replacement process by accepting the pending implementation.
     * @dev Can only be called by the pending implementation itself. Emits the `ReplaceImplementation` event and updates the `implementation` state.
     *      Deletes the `pendingImplementation` address upon successful acceptance.
     */
    function acceptImplementation() public {
        if (msg.sender != pendingImplementation()) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        emit ReplaceImplementation(implementation(), msg.sender);

        bytes32 slot_pending = PENDING_IMPLEMENTATION_SLOT;
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot_pending, 0)
            sstore(slot, caller())
        }
    }

    /**
     * @notice Allows a new implementation to become the active implementation in a proxy contract.
     * @dev Can only be called by the owner of the specified proxy contract. Calls `acceptImplementation` on the proxy contract.
     * @param proxy The proxy contract where the new implementation should be accepted.
     */
    function becomeImplementation(Upgradeable2Step proxy) public {
        if (msg.sender != proxy.owner()) {
            revert Unauthorized();
        }
        proxy.acceptImplementation();
    }

    /**
     * @notice Returns the pending implementation address
     * @return The pending implementation address
     */
    function pendingImplementation() public view returns (address) {
        address pendingImplementation_;
        bytes32 slot_pending = PENDING_IMPLEMENTATION_SLOT;
        assembly {
            pendingImplementation_ := sload(slot_pending)
        }
        return pendingImplementation_;
    }

    /**
     * @notice Returns the current implementation address
     * @return The current implementation address
     */
    function implementation() public view returns (address) {
        address implementation_;
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementation_ := sload(slot)
        }
        return implementation_;
    }
}

interface IBridgeHub {
    struct L2TransactionRequestDirect {
        uint256 chainId;
        uint256 mintValue;
        address l2Contract;
        uint256 l2Value;
        bytes l2Calldata;
        uint256 l2GasLimit;
        uint256 l2GasPerPubdataByteLimit;
        bytes[] factoryDeps;
        address refundRecipient;
    }

    struct L2TransactionRequestTwoBridgesOuter {
        uint256 chainId;
        uint256 mintValue;
        uint256 l2Value;
        uint256 l2GasLimit;
        uint256 l2GasPerPubdataByteLimit;
        address refundRecipient;
        address secondBridgeAddress;
        uint256 secondBridgeValue;
        bytes secondBridgeCalldata;
    }

    function requestL2TransactionDirect(L2TransactionRequestDirect calldata _request) external payable returns (bytes32 canonicalTxHash);
    function requestL2TransactionTwoBridges(L2TransactionRequestTwoBridgesOuter calldata _request) external payable returns (bytes32 canonicalTxHash);
}

abstract contract Rescuable {
    using SafeERC20 for IERC20;

    /**
     * @notice Override this function in inheriting contracts to set appropriate permissions
     */
    function _requireRescuerRole() internal view virtual;

    /**
     * @notice Allows the rescue of ERC20 tokens held by the contract
     * @param token The ERC20 token to be rescued
     */
    function rescue(IERC20 token) external {
        _requireRescuerRole();
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, balance);
    }

    /**
     * @notice Allows the rescue of Ether held by the contract
     */
    function rescueEth() external{
        _requireRescuerRole();
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}

/**
 * @title BridgeHubWrapper
 * @notice This contract serves as a wrapper for the BridgeHub contract, allowing users to request L2 transactions with additional functionalities such as fee management and token handling.
 * @dev Inherits from Upgradeable2Step and uses SafeERC20 for safe token transfers.
 */

contract BridgeHubWrapper is Upgradeable2Step, ReentrancyGuard, Rescuable {
    using SafeERC20 for IERC20;

    /**
     * @notice Emitted when the maximum fee is updated.
     * @param newFee The new maximum fee set by the contract owner.
     */
    event SetMaxFee(uint256 newFee);

    /**
     * @notice Emitted when the refund recipient address is updated.
     * @param newRecipient The new address designated to receive refunds.
     */
    event SetRefundRecipient(address indexed newRecipient);

    /**
     * @notice Emitted when the maximum fee is updated.
     * @param oldFee The previous maximum fee.
     * @param newFee The new maximum fee.
     */
    event SetMaxFee(uint256 oldFee, uint256 newFee);

    /**
     * @notice Emitted when the refund recipient is updated.
     * @param oldRecipient The previous refund recipient address.
     * @param newRecipient The new refund recipient address.
     */
    event SetRefundRecipient(address indexed oldRecipient, address indexed newRecipient);

    /**
     * @notice Emitted when a shared bridge is toggled.
     * @param sharedBridge The address of the shared bridge.
     * @param isEnabled Whether the shared bridge is enabled or disabled.
     */
    event ToggleSharedBridge(address indexed sharedBridge, bool indexed isEnabled);

    /// @notice The offset for L2 aliased addresses.
    uint160 constant offset = uint160(0x1111000000000000000000000000000000001111);

    /// @notice The chain ID that this contract is deployed on.
    uint256 public immutable chainId;

    /// @notice The instance of the BridgeHub contract.
    IBridgeHub public immutable bridgeHub;

    /// @notice The ERC20 token used for fees and transfers.
    IERC20 public immutable sophonToken;

    /// @notice The maximum fee allowed for L2 transactions.
    uint256 public maxFee;

    /// @notice The address that receives any refunds from transactions.
    address public refundRecipient;

    /// @notice Mapping of allowed shared bridges and their enabled status.
    mapping (address => bool) public allowedBridges;

    /**
     * @notice Initializes the BridgeHubWrapper contract with the specified parameters.
     * @param chainId_ The chain ID of the deployment network.
     * @param bridgeHub_ The address of the BridgeHub contract.
     * @param sophonToken_ The address of the Sophon ERC20 token.
     */
    constructor(uint256 chainId_, IBridgeHub bridgeHub_, IERC20 sophonToken_) {
        require(address(bridgeHub_) != address(0), "bridgeHub_ is zero address");
        require(address(sophonToken_) != address(0), "sophonToken_ is zero address");

        chainId = chainId_;
        bridgeHub = bridgeHub_;
        sophonToken = sophonToken_;
    }

    /**
     * @notice Initializes the max fee and refund recipient.
     * @dev Can only be called by the owner.
     * @param maxFee_ The maximum fee allowed for transactions.
     * @param refundRecipient_ The address to receive refunds.
     */
    function initialize(uint256 maxFee_, address refundRecipient_) external onlyOwner {
        require(refundRecipient_ != address(0), "Invalid refund recipient address");
        require(maxFee_ > 0, "Max fee must be greater than zero");
        maxFee = maxFee_;
        refundRecipient = refundRecipient_;
        emit SetMaxFee(maxFee_);
        emit SetRefundRecipient(refundRecipient_);
    }


    function _requireRescuerRole() internal view override {
        _checkOwner();
    }

    /**
     * @notice Toggles the enabled status of a shared bridge.
     * @dev Approves or revokes approval for the shared bridge to spend Sophon tokens.
     * @param sharedBridge_ The address of the shared bridge to toggle.
     * @param isEnabled_ True to enable, false to disable the shared bridge.
     */
    function toggleSharedBridge(address sharedBridge_, bool isEnabled_) public onlyOwner {
        allowedBridges[sharedBridge_] = isEnabled_;
        if (isEnabled_) {
            sophonToken.forceApprove(sharedBridge_, type(uint256).max);
        } else {
            sophonToken.forceApprove(sharedBridge_, 0);
        }
        emit ToggleSharedBridge(sharedBridge_, isEnabled_);
    }

    /**
     * @notice Requests an L2 transaction using two bridges.
     * @dev Validates the request parameters, handles token transfers, and interacts with the BridgeHub contract.
     *      - Requires that the request's chainId matches this contract's chainId.
     *      - Requires that the second bridge address is allowed.
     *      - Ensures the correct amount of ETH is sent if needed.
     *      - Validates that the mintValue is greater than or equal to l2Value, and the fee is within maxFee.
     *      - Transfers the l2Value amount of Sophon tokens from the sender.
     *      - Decodes the second bridge calldata and handles token transfers or ETH accordingly.
     *      - Sets the refund recipient to the contract's refundRecipient.
     *      - Calls the BridgeHub's requestL2TransactionTwoBridges function with the prepared request.
     * @param _request The L2 transaction request parameters.
     * @return canonicalTxHash The canonical transaction hash of the L2 transaction.
     */
    function requestL2TransactionTwoBridges(IBridgeHub.L2TransactionRequestTwoBridgesOuter memory _request) external payable nonReentrant returns (bytes32 canonicalTxHash) {
        require(_request.chainId == chainId, "invalid chainId");
        require(allowedBridges[_request.secondBridgeAddress], "invalid secondBridgeAddress");
        require(msg.value == 0 || _request.secondBridgeValue == msg.value, "invalid secondBridgeValue");
        require(_request.mintValue >= _request.l2Value, "invalid mintValue");
        require(_request.mintValue - _request.l2Value <= maxFee, "fee too high");

        if (_request.l2Value != 0) {
            sophonToken.safeTransferFrom(msg.sender, address(this), _request.l2Value);
        }
        require(sophonToken.balanceOf(address(this)) >= _request.mintValue, "not enough fee token");

        _request.refundRecipient = refundRecipient;

        (address _l1Token, uint256 _depositAmount, /*address _l2Receiver*/) = abi.decode(
            _request.secondBridgeCalldata,
            (address, uint256, address)
        );
        if (msg.value != 0) {
            require (_l1Token == address(1) && _depositAmount == 0, "invalid secondBridgeCalldata");
        } else {
            IERC20(_l1Token).safeTransferFrom(msg.sender, address(this), _depositAmount);
            if (IERC20(_l1Token).allowance(address(this), _request.secondBridgeAddress) < _depositAmount) {
                IERC20(_l1Token).forceApprove(_request.secondBridgeAddress, type(uint256).max);
            }
        }

        return bridgeHub.requestL2TransactionTwoBridges{value: msg.value}(_request);
    }

    /**
     * @notice Requests an L2 transaction directly without using a second bridge.
     * @dev Validates the request parameters, handles token transfers, and interacts with the BridgeHub contract.
     *      - Requires that the request's chainId matches this contract's chainId.
     *      - Validates that the mintValue is greater than or equal to l2Value, and the fee is within maxFee.
     *      - Transfers the l2Value amount of Sophon tokens from the sender.
     *      - Sets the refund recipient to the contract's refundRecipient.
     *      - Calls the BridgeHub's requestL2TransactionDirect function with the prepared request.
     * @param _request The L2 transaction request parameters.
     * @return canonicalTxHash The canonical transaction hash of the L2 transaction.
     */
    function requestL2TransactionDirect(IBridgeHub.L2TransactionRequestDirect memory _request) external nonReentrant returns (bytes32 canonicalTxHash) {
        require(_request.chainId == chainId, "invalid chainId");
        require(_request.mintValue >= _request.l2Value, "invalid mintValue");
        require(_request.mintValue - _request.l2Value <= maxFee, "fee too high");

        if (_request.l2Value != 0) {
            sophonToken.safeTransferFrom(msg.sender, address(this), _request.l2Value);
        }
        require(sophonToken.balanceOf(address(this)) >= _request.mintValue, "not enough fee token");

        _request.refundRecipient = refundRecipient;

        return bridgeHub.requestL2TransactionDirect(_request);
    }

    /**
     * @notice Updates the maximum fee allowed for L2 transactions.
     * @dev Can only be called by the owner.
     * @param maxFee_ The new maximum fee.
     */
    function setMaxFee(uint256 maxFee_) external onlyOwner {
        emit SetMaxFee(maxFee, maxFee_);
        maxFee = maxFee_;
    }

    /**
     * @notice Updates the refund recipient address.
     * @dev Can only be called by the owner.
     * @param refundRecipient_ The new refund recipient address.
     */
    function setRefundRecipient(address refundRecipient_) external onlyOwner {
        require(refundRecipient_ != address(0), "Invalid refund recipient address");
        emit SetRefundRecipient(refundRecipient, refundRecipient_);
        refundRecipient = refundRecipient_;
    }

    /**
     * @notice Computes the L2 alias address of this contract.
     * @return The L2 alias address.
     */
    function l2Address() public view returns (address) {
        return getL2Alias(address(this));
    }

    /**
     * @notice Computes the L2 alias address for a given L1 address.
     * @param l1Address The L1 address to compute the alias for.
     * @return l2Addr The computed L2 alias address.
     */
    function getL2Alias(address l1Address) public pure returns (address l2Addr) {
        unchecked {
            l2Addr = address(uint160(l1Address) + offset);
        }
    }

    /**
     * @notice Forwards any unknown function calls and ETH to the BridgeHub contract.
     * @dev Uses assembly to perform a low-level call to the BridgeHub contract.
     */
    fallback() external payable {
        address bridgeHub_ = address(bridgeHub);
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := call(gas(), bridgeHub_, callvalue(), 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @notice Fallback function that receives Ether when no data is sent.
     * @dev Reverts when Ether is sent without data.
     */
    receive() external payable {
        revert("ether sent");
    }
}