// Sources flattened with hardhat v2.22.13 https://hardhat.org

// SPDX-License-Identifier: GPL-2.0-or-later AND MIT

pragma abicoder v2;

// File @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// File @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
interface IERC20PermitUpgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20Upgradeable token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && AddressUpgradeable.isContract(address(token));
    }
}


// File @openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
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
            require(denominator > prod1, "Math: mulDiv overflow");

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
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
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/math/SignedMathUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMathUpgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;


/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
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
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
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
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


// File @openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}


// File @uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol@v1.0.1

// Original license: SPDX_License_Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}


// File @uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol@v1.4.4

// Original license: SPDX_License_Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
// Original pragma directive: pragma abicoder v2

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}


// File contracts/AddressUtils.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;

library AddressUtils {
    modifier onlyContract(address account_) {
        requireNonZeroAddress(account_);

        require(isContract(account_), 'AddressUtils: Only contracts allowed');
        _;
    }

    modifier notContract(address account_) {
        requireNonZeroAddress(account_);

        require(!isContract(account_), 'AddressUtils: Contracts not allowed');
        _;
    }

    function isContract(address account_) internal view returns (bool) {
        return account_.code.length > 0;
    }

    function requireNonZeroAddress(address account_) internal pure {
        require(
            account_ != address(0),
            'AddressUtils: Zero address not allowed'
        );
    }

    function requireZeroAddress(address account_) internal pure {
        require(
            account_ == address(0),
            'AddressUtils: Non Zero address'
        );
    }

    function requireIsContract(address account_) internal view {
        requireNonZeroAddress(account_);
        require(
            isContract(account_),
            'AddressUtils: Account is not a contract'
        );
    }

    function requireNotContract(address account_) internal view {
        requireNonZeroAddress(account_);
        require(!isContract(account_), 'AddressUtils: Account is a contract');
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                0,
                'AddressUtils: low-level call failed'
            );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            'AddressUtils: insufficient balance for call'
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                requireIsContract(target);
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(
        bytes memory returndata,
        string memory errorMessage
    ) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// File contracts/Admin.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Admin is Initializable {
    using AddressUtils for address;

    address private _admin;

    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    function __Admin_init(address admin_) internal onlyInitializing {
        admin_.requireNotContract();
        _admin = admin_;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, 'MemoContract: caller is not admin');
        _;
    }

    function getAdmin() public view returns (address) {
        return _admin;
    }

    function changeAdmin(address newAdmin_) external onlyAdmin {
        newAdmin_.requireNotContract();
        emit AdminChanged(_admin, newAdmin_);
        _admin = newAdmin_;
    }
}


// File contracts/IERC20Extended.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20Extended {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
}


// File contracts/ERC20Utils.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;



struct PermitData {
    address owner;
    address spender;
    uint256 value;
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

library ERC20Utils {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * Permits the specified spender to spend the specified amount of tokens on behalf of the owner.
     *
     * @param token_ The address of the ERC20 token contract.
     * @param data_ The permit data, including the owner, spender, value, deadline, and signature parameters.
     */
    function _permitWithAuthorization(
        address token_,
        PermitData calldata data_
    ) internal {
        IERC20Extended token = IERC20Extended(token_);

        try token.nonces(data_.owner) returns (uint256 nonceBefore) {
            token.permit(
                data_.owner,
                data_.spender,
                data_.value,
                data_.deadline,
                data_.v,
                data_.r,
                data_.s
            );
            uint256 nonceAfter = token.nonces(data_.owner);
            require(nonceAfter == nonceBefore + 1, 'Permit failed, nonce mismatch');
        } catch {
            revert('Permit token does not support nonces');
        }
    }

    function _erc20BalanceOf(
        address token_,
        address account_
    ) internal view returns (uint256) {
        return IERC20Upgradeable(token_).balanceOf(account_);
    }

    function _erc20Approve(
        address token_,
        address spender_,
        uint256 amount_
    ) internal {
        IERC20Upgradeable(token_).safeApprove(spender_, amount_);
    }

    function _transferErc20TokensFromContract(
        address token_,
        address recipient_,
        uint256 amount_
    ) internal {
        IERC20Upgradeable(token_).safeTransfer(recipient_, amount_);
    }

    function _transferErc20TokensFromSender(
        address token_,
        address recipient_,
        uint256 amount_
    ) internal {
        IERC20Upgradeable(token_).safeTransferFrom(
            msg.sender,
            recipient_,
            amount_
        );
    }

    function _safeTransferFrom(
        address token_,
        address owner_,
        address recipient_,
        uint256 amount_
    ) internal {
        IERC20Upgradeable(token_).safeTransferFrom(
            owner_,
            recipient_,
            amount_
        );
    }

    function _getErc20Allowance(
        address token_,
        address owner_,
        address spender_
    ) internal view returns (uint256) {
        return IERC20Upgradeable(token_).allowance(owner_, spender_);
    }
}


// File contracts/IWETH.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;

interface IWETH {
    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint wad) external;
}


// File contracts/BaseContract.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;


abstract contract BaseContract is Initializable, Admin {
    uint8 internal _initializedVersion;

    function getContractInitVersion() public view returns (uint8) {
        return _initializedVersion;
    }
}


// File contracts/TokenWhitelist.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;



abstract contract TokenWhitelist is BaseContract {
    using AddressUtils for address;

    mapping(address => address) internal _outputTokenToWithdrawers;

    function isValidOutputToken(address token_) public view returns (bool) {
        return getWithdrawerWallet(token_) != address(0);
    }

    function whitelistOutputToken(
        address token_,
        address withdrawer_
    ) external onlyAdmin returns (bool) {
        withdrawer_.requireNotContract();
        require(
            getWithdrawerWallet(token_) == address(0),
            'MemoContract: Output token already whitelisted'
        );
        _outputTokenToWithdrawers[token_] = withdrawer_;
        return true;
    }

    function removeOutputToken(address token_) external onlyAdmin returns (bool) {
        require(
            getWithdrawerWallet(token_) != address(0),
            'MemoContract: Output token not whitelisted'
        );
        delete _outputTokenToWithdrawers[token_];
        return true;
    }

    function getWithdrawerWallet(address token_) public view returns (address) {
        token_.requireIsContract();
        return _outputTokenToWithdrawers[token_];
    }
}


// File contracts/SwapFee.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;


abstract contract SwapFee is TokenWhitelist {
    using AddressUtils for address;

    address internal _swapFeeWallet;
    uint256 internal _swapFeeBps;

    event SwapFeeWalletChanged(
        address indexed oldWallet,
        address indexed newWallet
    );

    event SwapFeeBpsChanged(
        uint256 oldFee,
        uint256 newFee
    );

    function setSwapFeeWallet(
        address swapFeeWallet_
    ) external onlyAdmin returns (bool) {
        return _setSwapFeeWallet(swapFeeWallet_);
    }

    function _setSwapFeeWallet(
        address swapFeeWallet_
    ) internal returns (bool) {
        swapFeeWallet_.requireNotContract();
        emit SwapFeeWalletChanged(_swapFeeWallet, swapFeeWallet_);
        _swapFeeWallet = swapFeeWallet_;
        return true;
    }

    function getSwapFeeWallet() external view returns (address) {
        return _swapFeeWallet;
    }

    function setSwapFee(uint256 swapFeeBps_) external onlyAdmin returns (bool) {
        return _setSwapFeeBps(swapFeeBps_);
    }

    function _setSwapFeeBps(uint256 swapFeeBps_) internal returns (bool) {
        emit SwapFeeBpsChanged(_swapFeeBps, swapFeeBps_);
        _swapFeeBps = swapFeeBps_;
        return true;
    }

    function getSwapFeeBps() external view returns (uint256) {
        return _swapFeeBps;
    }
}


// File contracts/WethUtils.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;



abstract contract WethUtils is SwapFee {
    using AddressUtils for address;

    IWETH internal _wethToken;

    event WethTokenChanged(address indexed oldWeth, address indexed newWeth);

    function setWethToken(
        address wethToken_
    ) external onlyAdmin returns (bool) {
        return _setWethToken(wethToken_);
    }

    function _setWethToken(
        address wethToken_
    ) internal returns (bool) {
        wethToken_.requireIsContract();
        emit WethTokenChanged(address(_wethToken), wethToken_);
        _wethToken = IWETH(wethToken_);
        return true;
    }

    function wethToken() external view returns (address) {
        return address(_wethToken);
    }

    // wrap ETH to WETH, ETH will be deducted from contract balance and WETH will be added to contract balance
    function _wrapReceivedEth() internal returns (bool) {
        uint256 wethBalanceBefore = _wethToken.balanceOf(address(this));
        _wethToken.deposit{value: msg.value}();

        require(
            _wethToken.balanceOf(address(this)) ==
                wethBalanceBefore + msg.value,
            'MemoContract: WETH_RECEIVED_NOT_EQUAL_AMOUNT'
        );

        return true;
    }
}


// File contracts/MemoSwapV1.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;




struct MemoSwapV2Data {
    address sourceToken;
    uint256 sourceAmount;
    address outputToken;
    uint256 minTokenOut;
    uint24 poolFee;
    uint160 sqrtPriceLimitX96;
    uint256 deadline;
}

abstract contract MemoSwapV1 is WethUtils {
    using AddressUtils for address;
    using ERC20Utils for address;

    ISwapRouter internal _swapRouter;

    event UniswapRouterChanged(
        address indexed oldSwapRouter,
        address indexed newSwapRouter
    );

    function setUniswapRouter(
        address routerAddress_
    ) external onlyAdmin returns (bool) {
        return _setUniswapRouter(routerAddress_);
    }

    function _setUniswapRouter(
        address routerAddress_
    ) internal returns (bool) {
        routerAddress_.requireIsContract();
        emit UniswapRouterChanged(address(_swapRouter), routerAddress_);
        _swapRouter = ISwapRouter(routerAddress_);
        return true;
    }

    function uniswapRouter() external view returns (address) {
        return address(_swapRouter);
    }

    function _swapSourceTokenToOutputToken(
        MemoSwapV2Data calldata memoSwapData_
    ) internal returns (uint256 amountOut) {
        if (memoSwapData_.sourceToken == memoSwapData_.outputToken) {
            return memoSwapData_.sourceAmount;
        }
        
        require(memoSwapData_.minTokenOut > 0, 'MemoSwapV2: minTokenOut is Zero');
        require(memoSwapData_.poolFee > 0 && memoSwapData_.poolFee <= 10000, 'MemoSwapV2: Invalid pool fee');

        amountOut = _swapExactInputSingle(
            memoSwapData_.sourceToken,
            memoSwapData_.sourceAmount,
            memoSwapData_.outputToken,
            memoSwapData_.poolFee,
            memoSwapData_.minTokenOut,
            memoSwapData_.sqrtPriceLimitX96,
            memoSwapData_.deadline,
            address(this)
        );
    }

    // swap sourceToken_ to outputToken StableCoin
    // minAmountDstToken_,  this value should be calculated using our SDK or an onchain price oracle
    function _swapExactInputSingle(
        address sourceToken_,
        uint256 sourceAmount_,
        address outputToken_,
        uint24 poolFee_,
        uint256 minAmountDstToken_,
        uint160 sqrtPriceLimitX96_,
        uint256 deadline_,
        address usdcWithdrawer_
    ) internal returns (uint256 amountOut) {
        sourceToken_._erc20Approve(address(_swapRouter), sourceAmount_);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: sourceToken_,
                tokenOut: outputToken_,
                fee: poolFee_,
                recipient: usdcWithdrawer_,
                deadline: deadline_,
                amountIn: sourceAmount_,
                amountOutMinimum: minAmountDstToken_,
                sqrtPriceLimitX96: sqrtPriceLimitX96_
            });

        amountOut = _swapRouter.exactInputSingle(params);
    }
}


// File contracts/AuthSigner.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;


abstract contract AuthSigner is MemoSwapV1 {
    using AddressUtils for address;

    address internal _authSigner;

    event AuthSignerChanged(
        address indexed oldSigner,
        address indexed newSigner
    );

    function getAuthSigner() public view returns (address) {
        return _authSigner;
    }

    function changeAuthSigner(address newSigner_) external onlyAdmin {
        _setAuthSigner(newSigner_);
        emit AuthSignerChanged(_authSigner, newSigner_);
    }

    function _setAuthSigner(address authSigner_) internal {
        authSigner_.requireNotContract();
        _authSigner = authSigner_;
    }
}


// File contracts/DomainSeparator.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;

abstract contract DomainSeparator is AuthSigner {
    mapping(uint256 => bytes32) public _domainSeparators;

    function _domainSeparator() internal returns (bytes32) {
        bytes32 domainSeparator = _domainSeparators[getChainId()];

        if (domainSeparator != 0x00) {
            return domainSeparator;
        }

        _domainSeparators[getChainId()] = getNewDomainSeparator(address(this));

        return _domainSeparators[getChainId()];
    }

    function getDomainSeparator() public view returns (bytes32) {
        return _domainSeparators[getChainId()];
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparators[getChainId()];
    }

    function getChainId() public view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function getNewDomainSeparator(
        address memoContract_
    ) internal view returns (bytes32) {
        uint256 chainID = getChainId();

        bytes32 newDomainSeparator = keccak256(
            abi.encode(
                keccak256(
                    'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
                ),
                keccak256(bytes('Coinflow Memo Contract')),
                keccak256(bytes('1')),
                chainID,
                memoContract_
            )
        );

        return newDomainSeparator;
    }
}


// File contracts/Authorization.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;



abstract contract Authorization is DomainSeparator {
    enum AuthorizationState {
        Unused,
        Used,
        Canceled
    }

    mapping(bytes32 => AuthorizationState) internal _authorizationStates;

    event AuthorizationUsed(bytes32 indexed nonce);
    event AuthorizationCanceled(bytes32 indexed nonce);

    /**
     * @notice Returns the state of an authorization
     * @param nonce         Nonce of the authorization
     * @return Authorization state
     */
    function authorizationState(
        bytes32 nonce
    ) external view returns (AuthorizationState) {
        return _authorizationStates[nonce];
    }

    function _requireUnusedAuthorization(bytes32 nonce) internal view {
        require(
            _authorizationStates[nonce] == AuthorizationState.Unused,
            'MemoContract: authorization is used or canceled'
        );
    }

    function _requireValidAuthorization(
        bytes32 nonce,
        uint256 validBefore
    ) internal view {
        require(
            block.timestamp < validBefore,
            'MemoContract: authorization is expired'
        );
        _requireUnusedAuthorization(nonce);
    }

    /**
     * @notice Mark an authorization as used
     * @param nonce         Nonce of the authorization
     */
    function _markAuthorizationAsUsed(bytes32 nonce) internal {
        _authorizationStates[nonce] = AuthorizationState.Used;
        emit AuthorizationUsed(nonce);
    }
}


// File contracts/SignerVerification.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;




abstract contract SignerVerification is Authorization {
    bytes32 public constant PERMIT_DATA_TYPEHASH =
        keccak256(
            'PermitData(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s)'
        );
    bytes32 public constant TRANSFER_OUTPUT_TOKEN_ARGS_TYPEHASH =
        keccak256(
            'TransferOutputTokenArgs(PermitData permitData,address outputToken,string memo,address recipientWallet,uint256 validBefore,bytes32 nonce)PermitData(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s)'
        );

    bytes32 public constant MEMO_SWAP_V2_DATA_TYPEHASH =
        keccak256(
            'MemoSwapV2Data(address sourceToken,uint256 sourceAmount,address outputToken,uint256 minTokenOut,uint24 poolFee,uint160 sqrtPriceLimitX96,uint256 deadline)'
        );
    bytes32 public constant SWAP_AND_TRANSFER_OUTPUT_TOKEN_ARGS_TYPEHASH =
        keccak256(
            'SwapAndTransferOutputTokenArgs(MemoSwapV2Data memoSwapData,PermitData permitMemoData,string memo,address recipientWallet,uint256 validBefore,bytes32 nonce)MemoSwapV2Data(address sourceToken,uint256 sourceAmount,address outputToken,uint256 minTokenOut,uint24 poolFee,uint160 sqrtPriceLimitX96,uint256 deadline)PermitData(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s)'
        );

    bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH =
        keccak256('CancelAuthorization(bytes32 nonce)');

    error TransferOutputTokenSignerMismatch(
        address expectedSigner,
        address signer
    );
    error SignatureFromTheZeroAddress();
    error ExpectedSignerNotSet();

    function hash(
        PermitData memory permitData
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_DATA_TYPEHASH,
                    permitData.owner,
                    permitData.spender,
                    permitData.value,
                    permitData.deadline,
                    permitData.v,
                    permitData.r,
                    permitData.s
                )
            );
    }

    function hash(
        MemoSwapV2Data memory memoSwapData
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    MEMO_SWAP_V2_DATA_TYPEHASH,
                    memoSwapData.sourceToken,
                    memoSwapData.sourceAmount,
                    memoSwapData.outputToken,
                    memoSwapData.minTokenOut,
                    memoSwapData.poolFee,
                    memoSwapData.sqrtPriceLimitX96,
                    memoSwapData.deadline
                )
            );
    }

    function hash(
        PermitData calldata permitData,
        address outputToken,
        string calldata memo,
        address recipientWallet,
        uint256 validBefore,
        bytes32 nonce
    ) internal pure returns (bytes32) {
        bytes32 permitDataHash = hash(permitData);
        bytes32 keccak256Memo = keccak256(bytes(memo));

        return
            keccak256(
                abi.encode(
                    TRANSFER_OUTPUT_TOKEN_ARGS_TYPEHASH,
                    permitDataHash,
                    outputToken,
                    keccak256Memo,
                    recipientWallet,
                    validBefore,
                    nonce
                )
            );
    }

    function hash(
        MemoSwapV2Data calldata memoSwapData,
        PermitData calldata permitMemoData,
        string calldata memo,
        address recipientWallet,
        uint256 validBefore,
        bytes32 nonce
    ) internal pure returns (bytes32) {
        bytes32 memoSwapDataHash = hash(memoSwapData);
        bytes32 permitDataHash = hash(permitMemoData);
        bytes32 keccak256Memo = keccak256(bytes(memo));

        return
            keccak256(
                abi.encode(
                    SWAP_AND_TRANSFER_OUTPUT_TOKEN_ARGS_TYPEHASH,
                    memoSwapDataHash,
                    permitDataHash,
                    keccak256Memo,
                    recipientWallet,
                    validBefore,
                    nonce
                )
            );
    }

    function _verifyTransferOutputTokenFunctionDataAndSigner(
        PermitData calldata permitData_,
        address outputToken_,
        string calldata memo_,
        address recipientWallet_,
        uint256 validBefore_,
        bytes32 nonce_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) internal {
        _requireValidAuthorization(nonce_, validBefore_);

        bytes32 typeHashAndData = hash(
            permitData_,
            outputToken_,
            memo_,
            recipientWallet_,
            validBefore_,
            nonce_
        );

        _assertSigner(
            getDomainSeparator(),
            typeHashAndData,
            getAuthSigner(),
            v_,
            r_,
            s_
        );

        _markAuthorizationAsUsed(nonce_);
    }

    function _assertSigner(
        bytes32 domainSeparator,
        bytes32 typeHashAndData,
        address expectedSigner,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure {
        address signer = recover(domainSeparator, v, r, s, typeHashAndData);

        if (signer != expectedSigner) {
            revert TransferOutputTokenSignerMismatch(expectedSigner, signer);
        }

        if (signer == address(0)) {
            revert SignatureFromTheZeroAddress();
        }

        if (expectedSigner == address(0)) {
            revert ExpectedSignerNotSet();
        }
    }

    function recover(
        bytes32 domainSeparator,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 typeHashAndData
    ) internal pure returns (address) {
        bytes32 digest = keccak256(
            abi.encodePacked('\x19\x01', domainSeparator, typeHashAndData)
        );
        return ECDSAUpgradeable.recover(digest, v, r, s);
    }

    function _verifySwapAndTransferOutputTokenFunctionDataAndSigner(
        MemoSwapV2Data calldata memoSwapData_,
        PermitData calldata permitMemoData_,
        string calldata memo_,
        address recipientWallet_,
        uint256 validBefore_,
        bytes32 nonce_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) internal {
        _requireValidAuthorization(nonce_, validBefore_);

        bytes32 typeHashAndData = hash(
            memoSwapData_,
            permitMemoData_,
            memo_,
            recipientWallet_,
            validBefore_,
            nonce_
        );

        _assertSigner(
            getDomainSeparator(),
            typeHashAndData,
            getAuthSigner(),
            v_,
            r_,
            s_
        );

        _markAuthorizationAsUsed(nonce_);
    }

    function _cancelAuthorization(
        bytes32 nonce_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) internal {
        _requireUnusedAuthorization(nonce_);

        bytes32 typeHashAndData = keccak256(
            abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, nonce_)
        );

        _assertSigner(
            getDomainSeparator(),
            typeHashAndData,
            getAuthSigner(),
            v_,
            r_,
            s_
        );

        _authorizationStates[nonce_] = AuthorizationState.Canceled;
        emit AuthorizationCanceled(nonce_);
    }

    /**
     * @notice Attempt to cancel an authorization
     * @dev Works only if the authorization is not yet used.
     * @param nonce         Nonce of the authorization
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function cancelAuthorization(
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _cancelAuthorization(nonce, v, r, s);
    }
}


// File contracts/MemoTransfer.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;




/**
 * @notice Struct containing the details required to transfer an output token with an attached memo.
 * @param permitData Struct containing permit data to allow the contract to transfer the output token from the owner's account.
 *                  If the owner is zero address, it indicates that approvals are used instead of permits.
 * @param outputToken The address of the output token to be transferred.
 * @param memo A string memo that will be logged with the transaction.
 * @param recipientWallet The address of the recipient wallet to receive the output token.
 * @param validBefore The deadline timestamp for the signature.
 * @param nonce The nonce for the signature.
 */
struct TransferOutputTokenArgs {
    PermitData permitData; // spender == memoContract contract, owner == zero address (when using approvals or usePermit = false)
    address outputToken;
    string memo;
    address recipientWallet;
    uint256 validBefore;
    bytes32 nonce;
}

/**
 * @notice Struct containing the details required to swap a source token for an output token and transfer the output token to a recipient wallet with an attached memo.
 * @param memoSwapData Struct containing the details of the swap operation, including source token, source amount, output token, and other swap parameters.
 * @param permitMemoData Struct containing permit data to allow the contract to transfer the source token from the owner's account.
 *                      If the owner is zero address, it indicates that approvals are used instead of permits.
 * @param memo A string memo that will be logged with the transaction.
 * @param recipientWallet The address of the recipient wallet to receive the output token.
 * @param validBefore The deadline timestamp for the signature.
 * @param nonce The nonce for the signature.
 */
struct SwapAndTransferOutputTokenArgs {
    MemoSwapV2Data memoSwapData;
    PermitData permitMemoData;
    string memo;
    address recipientWallet;
    uint256 validBefore;
    bytes32 nonce;
}

abstract contract MemoTransfer is SignerVerification {
    using AddressUtils for address;
    using ERC20Utils for address;

    event WithdrawOutputToken(
        address indexed from,
        address indexed to,
        address indexed outputToken,
        uint256 amount
    );

    event SwapAndTransferOutputToken(
        address indexed from,
        address indexed recipientWallet,
        address indexed outputToken,
        address sourceToken,
        uint256 sourceAmount,
        uint256 outputAmount
    );

    event MemoLogged(string memo);

    /**
     * @notice Transfers an output token from the permit signer or caller to the withdrawer wallet with an attached memo.
     * @dev This function transfers a specified amount of an output token to withdrawer wallet.
     *      It supports both direct transfers and transfers using permit data for gasless transactions. The function also logs the memo provided.
     * @param args_ Struct containing the details required to transfer an output token with an attached memo.
     * @param v The recovery id for the signature.
     * @param r The r value for the signature.
     * @param s The s value for the signature.
     * @return bool Returns true if the transfer is successful.
     */
    function transferOutputTokenWithMemo(
        TransferOutputTokenArgs calldata args_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        _assertInput(args_);
        address owner = _processPermitOrSender(
            args_.outputToken,
            args_.permitData
        );

        if (msg.sender != owner) {
            _verifyTransferOutputTokenFunctionDataAndSigner(
                args_.permitData,
                args_.outputToken,
                args_.memo,
                args_.recipientWallet,
                args_.validBefore,
                args_.nonce,
                v,
                r,
                s
            );
        }

        args_.outputToken._safeTransferFrom(
            owner,
            args_.recipientWallet,
            args_.permitData.value
        );

        emit WithdrawOutputToken(
            owner,
            args_.recipientWallet,
            args_.outputToken,
            args_.permitData.value
        );
        emit MemoLogged(args_.memo);

        return true;
    }

    function _assertInput(
        TransferOutputTokenArgs calldata args_
    ) internal view {
        require(
            isValidOutputToken(args_.outputToken),
            'MemoContractV2: Invalid output token'
        );
        require(
            args_.recipientWallet != address(0),
            'MemoContractV2: Recipient wallet is zero address'
        );
    }

    function calculateSwapFee(
        uint256 usdcReceived_
    ) public view returns (uint256) {
        return (usdcReceived_ * _swapFeeBps) / 10000;
    }

    /**
     * @notice Swaps a source token for an output token and transfers the output token to our withdrawer wallet, with an attached memo.
     * @dev This function allows the permit signer or caller to swap a specified amount of a source token for an output token and transfer the output token to our withdrawer wallet.
     *      It supports both direct transfers and transfers using permit data for gasless transactions. The function also logs the memo provided.
     * @param args_ Struct containing the details required to swap a source token for an output token and transfer the output token to a recipient wallet with an attached memo.
     * @param v The recovery id for the signature.
     * @param r The r value for the signature.
     * @param s The s value for the signature.
     * @return bool Returns true if the operation is successful.
     */
    function swapAndTransferOutputTokenWithMemo(
        SwapAndTransferOutputTokenArgs calldata args_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable returns (bool) {
        _assertInputSwapData(args_.memoSwapData, args_.recipientWallet);

        address tokenOwner = _processPermitOrSender(
            args_.memoSwapData.sourceToken,
            args_.permitMemoData
        );

        if (msg.sender != tokenOwner) {
            _verifySwapAndTransferOutputTokenFunctionDataAndSigner(
                args_.memoSwapData,
                args_.permitMemoData,
                args_.memo,
                args_.recipientWallet,
                args_.validBefore,
                args_.nonce,
                v,
                r,
                s
            );
        }

        if (msg.value > 0) {
            _wrapEthToWeth(args_.memoSwapData);
        } else {
            args_.memoSwapData.sourceToken._safeTransferFrom(
                tokenOwner,
                address(this),
                args_.memoSwapData.sourceAmount
            );
        }

        uint256 outputTokenAmountReceived = _swapSourceTokenToOutputToken(
            args_.memoSwapData
        );

        uint256 swapFee = _transferSwapFee(
            outputTokenAmountReceived,
            args_.memoSwapData.outputToken
        );

        uint256 actualOutputTokenWithdrawn = outputTokenAmountReceived -
            swapFee;
        args_.memoSwapData.outputToken._transferErc20TokensFromContract(
            args_.recipientWallet,
            actualOutputTokenWithdrawn
        );

        emit SwapAndTransferOutputToken(
            tokenOwner,
            args_.recipientWallet,
            args_.memoSwapData.outputToken,
            args_.memoSwapData.sourceToken,
            args_.memoSwapData.sourceAmount,
            actualOutputTokenWithdrawn
        );
        emit MemoLogged(args_.memo);

        return true;
    }

    function _assertInputSwapData(
        MemoSwapV2Data calldata memoSwapData_,
        address recipientWallet_
    ) internal view {
        memoSwapData_.sourceToken.requireIsContract();
    
        require(
            isValidOutputToken(memoSwapData_.outputToken),
            'MemoContractV2: Invalid output token'
        );

        require(
            memoSwapData_.sourceAmount > 0,
            'MemoContractV2: SourceAmount is Zero'
        );

        require(
            recipientWallet_ != address(0),
            'MemoContractV2: Recipient wallet is zero address'
        );
    }

    function _processPermitOrSender(
        address token_,
        PermitData calldata permitMemoData_
    ) internal returns (address) {
        if (permitMemoData_.owner != address(0) && permitMemoData_.value > 0) {
            require(
                permitMemoData_.spender == address(this),
                'MemoContractV2: Spender is not coinflow contract'
            );
            token_._permitWithAuthorization(permitMemoData_);
            return permitMemoData_.owner;
        }
        return msg.sender;
    }

    function _wrapEthToWeth(MemoSwapV2Data calldata memoSwapData_) internal {
        require(
            memoSwapData_.sourceToken == address(_wethToken),
            'MemoSwapV1: Invalid source token'
        );
        require(msg.value == memoSwapData_.sourceAmount, 'Invalid msg.value');

        _wrapReceivedEth();
    }

    function _transferSwapFee(
        uint256 tokenAmount_,
        address outputToken_
    ) internal returns (uint256) {
        uint256 swapFee = 0;

        if (_swapFeeBps > 0) {
            swapFee = calculateSwapFee(tokenAmount_);
            outputToken_._transferErc20TokensFromContract(
                _swapFeeWallet,
                swapFee
            );
        }

        return swapFee;
    }
}


// File contracts/MemoContractV2.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;



// For first time deployment, call initialize(address admin, wethToken, swapRouter, swapFeeWallet, swapFeeBps)
contract MemoContractV2 is MemoTransfer {
    using AddressUtils for address;
    using ERC20Utils for address;

    uint256[10] private gap_;

    function initialize(
        address admin_,
        address wethToken_,
        address swapRouter_,
        address swapFeeWallet_,
        uint256 swapFeeBps_,
        address authSigner_
    ) external initializer {
        admin_.requireNotContract();

        getAdmin().requireZeroAddress();
        __Admin_init(admin_);

        require(_initializedVersion == 0, 'MemoContract: Already initialized');
        _initializedVersion = 2;

        _setUniswapRouter(swapRouter_);
        _setWethToken(wethToken_);
        _setSwapFeeWallet(swapFeeWallet_);
        _setSwapFeeBps(swapFeeBps_);

        _domainSeparator();

        _setAuthSigner(authSigner_);
    }

    function getContractCodeVersion() external pure returns (uint16) {
        return 5;
    }
}