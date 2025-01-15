// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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

// File: HereditasV2.sol


pragma solidity ^0.8.17;




/**
 * @title InheritanceManager
 * @dev Manages multiple inheritance plans, handling ERC20 tokens via approvals.
 */
contract InheritanceManager is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Constants
    uint256 public constant EXECUTOR_FEE_BPS = 100; // 1%
    uint256 public constant DEVELOPER_FEE_BPS = 10; // 0.1%
    uint256 public constant TOTAL_SHARES = 10000; // 100%

    // Developer address to receive fees
    address public immutable developer;

    // Structure to represent a beneficiary
    struct Beneficiary {
        address addr;    // Beneficiary address
        uint256 share;   // Share in basis points
    }

    // Structure to represent an inheritance plan
    struct InheritancePlan {
        address owner;
        Beneficiary[] beneficiaries;
        uint256 lastActive;
        bool distributed;
        address[] approvedTokens;          // List of approved ERC20 tokens
        mapping(address => bool) tokenApproved; // Quick lookup for approved tokens
        uint256 inactPeriod;
        uint256 gracePeriod;
    }

    // Mapping from owner to their inheritance plan
    mapping(address => InheritancePlan) public plans;

    // Mapping from beneficiary to list of owner addresses with plans including them
    mapping(address => address[]) public beneficiaryToOwners;

    // Events
    event PlanCreated(address indexed owner);
    event BeneficiaryAdded(address indexed owner, address beneficiary, uint256 share);
    event BeneficiaryRemoved(address indexed owner, address beneficiary);
    event TokenRegistered(address indexed owner, address indexed token);
    event TokenApprovalRevoked(address indexed owner, address indexed token);
    event AssetsDistributed(address indexed initiator, address indexed owner, bool isBeneficiary, uint256 executorFee);
    event Heartbeat(address indexed owner, uint256 timestamp);
    event InactivityPeriodUpdated(address indexed owner, uint256 newPeriod);
    event GracePeriodUpdated(address indexed owner, uint256 newGracePeriod);
    event PlanDeleted(address indexed owner);

    // Constructor
    constructor() {
        developer = msg.sender;
    }

    /**
     * @dev Create a new inheritance plan.
     */
    function createPlan(
        address[] calldata _beneficiaries,
        uint256[] calldata _shares,
        uint256 _inactPeriod,
        uint256 _gracePeriod
    ) external {
        require(_beneficiaries.length == _shares.length, "Mismatched input lengths");
        require(_beneficiaries.length > 0, "At least one beneficiary required");

        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == address(0), "Plan already exists");
        require(_inactPeriod > 0, "Inactivity period  > 0");

        plan.owner = msg.sender;
        plan.lastActive = block.timestamp;
        plan.inactPeriod = _inactPeriod;
        plan.gracePeriod = _gracePeriod;

        uint256 totalShares = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            address beneficiary = _beneficiaries[i];
            uint256 share = _shares[i];
            require(beneficiary != address(0), "Invalid beneficiary");
            require(share > 0 && share <= TOTAL_SHARES, "Invalid share");

            // Prevent duplicate beneficiaries
            require(!isBeneficiary(msg.sender, beneficiary), "Duplicate beneficiary");

            plan.beneficiaries.push(Beneficiary({addr: beneficiary, share: share}));
            totalShares += share;

            // Update beneficiary to owners mapping
            beneficiaryToOwners[beneficiary].push(msg.sender);

            emit BeneficiaryAdded(msg.sender, beneficiary, share);
        }
        require(totalShares == TOTAL_SHARES, "Total shares must equal 10000");

        emit PlanCreated(msg.sender);
    }

    /**
     * @dev Add a beneficiary to an existing inheritance plan.
     */
    function addBeneficiary(address _beneficiary, uint256 _share) external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period passed");
        require(_beneficiary != address(0), "Invalid beneficiary");
        require(_share > 0 && _share <= TOTAL_SHARES, "Invalid share");
        require(!isBeneficiary(msg.sender, _beneficiary), "Beneficiary exists");

        uint256 currentTotalShares = getTotalShares(plan.beneficiaries);
        uint256 newTotalShares = TOTAL_SHARES - _share;

        // Adjust existing shares proportionally
        for (uint256 i = 0; i < plan.beneficiaries.length; i++) {
            plan.beneficiaries[i].share = (plan.beneficiaries[i].share * newTotalShares) / currentTotalShares;
        }

        // Handle rounding discrepancies
        uint256 adjustedTotal = getTotalShares(plan.beneficiaries);
        if (adjustedTotal < newTotalShares) {
            plan.beneficiaries[0].share += newTotalShares - adjustedTotal;
        } else if (adjustedTotal > newTotalShares) {
            plan.beneficiaries[0].share -= adjustedTotal - newTotalShares;
        }

        // Add new beneficiary
        plan.beneficiaries.push(Beneficiary({addr: _beneficiary, share: _share}));
        beneficiaryToOwners[_beneficiary].push(msg.sender);

        plan.lastActive = block.timestamp;

        emit BeneficiaryAdded(msg.sender, _beneficiary, _share);
        emit Heartbeat(msg.sender, block.timestamp);

        // After adjustment, total shares should be TOTAL_SHARES
        require(getTotalShares(plan.beneficiaries) == TOTAL_SHARES, "Total shares mismatch after addition");
    }

    /**
     * @dev Remove a beneficiary from an inheritance plan.
     * @param _beneficiary Address of the beneficiary to remove.
     */
    function removeBeneficiary(address _beneficiary) external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period  passed");
        require(isBeneficiary(msg.sender, _beneficiary), "Beneficiary not found");

        uint256 index = findBeneficiaryIndex(plan.beneficiaries, _beneficiary);
        require(index < plan.beneficiaries.length, "Beneficiary not found");

        // Remove beneficiary by swapping with the last element
        plan.beneficiaries[index] = plan.beneficiaries[plan.beneficiaries.length - 1];
        plan.beneficiaries.pop();

        // Remove owner from beneficiaryToOwners mapping
        removeOwnerFromBeneficiary(_beneficiary, msg.sender);

        // Adjust shares proportionally
        if (plan.beneficiaries.length > 0) {
            uint256 currentTotalShares = getTotalShares(plan.beneficiaries);
            require(currentTotalShares > 0, "No shares left");

            for (uint256 i = 0; i < plan.beneficiaries.length; i++) {
                plan.beneficiaries[i].share = (plan.beneficiaries[i].share * TOTAL_SHARES) / currentTotalShares;
            }

            // Handle rounding discrepancies
            uint256 adjustedTotal = getTotalShares(plan.beneficiaries);
            if (adjustedTotal < TOTAL_SHARES) {
                plan.beneficiaries[0].share += TOTAL_SHARES - adjustedTotal;
            } else if (adjustedTotal > TOTAL_SHARES) {
                plan.beneficiaries[0].share -= adjustedTotal - TOTAL_SHARES;
            }

            require(getTotalShares(plan.beneficiaries) == TOTAL_SHARES, "Total shares mismatch after removal");
        }

        plan.lastActive = block.timestamp;

        emit BeneficiaryRemoved(msg.sender, _beneficiary);
        emit Heartbeat(msg.sender, block.timestamp);
    }

    /**
     * @dev Get all inheritance plans where a specific address is a beneficiary.
     */
    function getPlansByBeneficiary(address _beneficiary) external view returns (address[] memory) {
        return beneficiaryToOwners[_beneficiary];
    }

    /**
     * @dev Register an approved ERC20 token.
     */
    function registerToken(IERC20 _token) external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period  passed");
        require(address(_token) != address(0), "Invalid token");
        require(!plan.tokenApproved[address(_token)], "Token already registered");

        plan.approvedTokens.push(address(_token));
        plan.tokenApproved[address(_token)] = true;

        plan.lastActive = block.timestamp;

        emit TokenRegistered(msg.sender, address(_token));
        emit Heartbeat(msg.sender, block.timestamp);
    }

    /**
     * @dev Revoke approval of a token.
     */
    function revokeTokenApproval(IERC20 _token) external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period  passed");
        require(address(_token) != address(0), "Invalid token");
        require(plan.tokenApproved[address(_token)], "Token not registered");

        uint256 index = findTokenIndex(plan.approvedTokens, address(_token));
        require(index < plan.approvedTokens.length, "Token not found");

        // Remove token by swapping with the last element
        plan.approvedTokens[index] = plan.approvedTokens[plan.approvedTokens.length - 1];
        plan.approvedTokens.pop();
        plan.tokenApproved[address(_token)] = false;

        plan.lastActive = block.timestamp;

        emit TokenApprovalRevoked(msg.sender, address(_token));
        emit Heartbeat(msg.sender, block.timestamp);
    }

    /**
     * @dev Heartbeat function to update the last active timestamp.
     */
    function heartbeat() external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period passed");

        plan.lastActive = block.timestamp;
        emit Heartbeat(msg.sender, block.timestamp);
    }

    /**
    * @dev Distribute inheritance after inactivity.
    * @param _owner Address of the owner whose assets are to be distributed.
    */
    function distributeInheritance(address _owner) external nonReentrant {
        InheritancePlan storage plan = plans[_owner];
        require(plan.owner != address(0), "Plan doesn't exist");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp >= plan.lastActive + plan.inactPeriod, "Inact period not passed");

        bool executor = !isBeneficiary(_owner, msg.sender);
        if (executor) {
            require(block.timestamp >= plan.lastActive + plan.inactPeriod + plan.gracePeriod, "Grace period not passed");
        }

        plan.distributed = true;

        uint256 totalExecFee = 0;

        for (uint256 i = 0; i < plan.approvedTokens.length; i++) {
            IERC20 token = IERC20(plan.approvedTokens[i]);
            uint256 amount = min(token.allowance(_owner, address(this)), token.balanceOf(_owner));
            if (amount == 0) continue;

            uint256 execFee = handleTokenDistribution(plan, token, amount, executor);
            totalExecFee += execFee;
        }

        emit AssetsDistributed(msg.sender, _owner, !executor, totalExecFee);
        _cleanupPlan(_owner);
    }

    /**
     * @dev Update the inactivity period.
     * @param _newPeriod New inactivity period in seconds.
     */
    function updateInactPeriod(uint256 _newPeriod) external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period  passed");
        require(_newPeriod > 0, "New period > 0");

        plan.inactPeriod = _newPeriod;
        plan.lastActive = block.timestamp;
        emit InactivityPeriodUpdated(msg.sender, _newPeriod);
        emit Heartbeat(plan.owner, block.timestamp);
    }

    /**
     * @dev Update the grace period.
     * @param _newGrace New grace period in seconds.
     */
    function updateGracePeriod(uint256 _newGrace) external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period  passed");

        plan.lastActive = block.timestamp;
        plan.gracePeriod = _newGrace;
        emit GracePeriodUpdated(msg.sender, _newGrace);
        emit Heartbeat(plan.owner, block.timestamp);
    }

    /**
     * @dev Delete an inheritance plan.
     */
    function deletePlan() external {
        InheritancePlan storage plan = plans[msg.sender];
        require(plan.owner == msg.sender, "Not the owner");
        require(!plan.distributed, "Already distributed");
        require(block.timestamp < plan.lastActive + plan.inactPeriod, "Inactivity period  passed");

        // Remove owner from all beneficiaries' mappings
        for (uint256 i = 0; i < plan.beneficiaries.length; i++) {
            address beneficiary = plan.beneficiaries[i].addr;
            address[] storage owners = beneficiaryToOwners[beneficiary];
            for (uint256 j = 0; j < owners.length; j++) {
                if (owners[j] == msg.sender) {
                    owners[j] = owners[owners.length - 1];
                    owners.pop();
                    break;
                }
            }
            emit BeneficiaryRemoved(msg.sender, beneficiary);
        }

        // Revoke all token approvals
        for (uint256 i = 0; i < plan.approvedTokens.length; i++) {
            plan.tokenApproved[plan.approvedTokens[i]] = false;
        }
        delete plan.approvedTokens;

        // Reset plan details
        delete plans[msg.sender];

        emit PlanDeleted(msg.sender);
    }

    /**
     * @dev Check if an address is a beneficiary for a specific owner.
     * @param _owner Address of the owner.
     * @param _addr Address to check.
     * @return bool indicating if the address is a beneficiary.
     */
    function isBeneficiary(address _owner, address _addr) public view returns (bool) {
        InheritancePlan storage plan = plans[_owner];
        uint256 len = plan.beneficiaries.length;
        for (uint256 i = 0; i < len; i++) {
            if (plan.beneficiaries[i].addr == _addr) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Get all beneficiaries for a specific owner.
     * @param _owner Address of the owner.
     * @return Array of Beneficiary structs.
     */
    function getBeneficiaries(address _owner) external view returns (Beneficiary[] memory) {
        InheritancePlan storage plan = plans[_owner];
        Beneficiary[] memory b = new Beneficiary[](plan.beneficiaries.length);
        for (uint256 i = 0; i < plan.beneficiaries.length; i++) {
            b[i] = plan.beneficiaries[i];
        }
        return b;
    }

    /**
     * @dev Get all approved tokens for a specific owner.
     * @param _owner Address of the owner.
     * @return Array of token addresses.
     */
    function getTokens(address _owner) external view returns (address[] memory) {
        return plans[_owner].approvedTokens;
    }

    // ===================== Internal Functions =====================

    /**
     * @dev Calculate the total shares from a list of beneficiaries.
     * @param beneficiaries Array of Beneficiary structs.
     * @return uint256 total shares.
     */
    function getTotalShares(Beneficiary[] storage beneficiaries) internal view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            total += beneficiaries[i].share;
        }
        return total;
    }

    /**
     * @dev Find the index of a beneficiary in the beneficiaries array.
     * @param beneficiaries Array of Beneficiary structs.
     * @param _beneficiary Address of the beneficiary to find.
     * @return uint256 index of the beneficiary.
     */
    function findBeneficiaryIndex(Beneficiary[] storage beneficiaries, address _beneficiary) internal view returns (uint256) {
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i].addr == _beneficiary) {
                return i;
            }
        }
        return type(uint256).max;
    }

    /**
     * @dev Find the index of a token in the approvedTokens array.
     * @param tokens Array of token addresses.
     * @param _token Address of the token to find.
     * @return uint256 index of the token.
     */
    function findTokenIndex(address[] storage tokens, address _token) internal view returns (uint256) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == _token) {
                return i;
            }
        }
        return type(uint256).max;
    }

    /**
     * @dev Remove an owner from a beneficiary's list of owners.
     * @param _beneficiary Address of the beneficiary.
     * @param _owner Address of the owner to remove.
     */
    function removeOwnerFromBeneficiary(address _beneficiary, address _owner) internal {
        address[] storage owners = beneficiaryToOwners[_beneficiary];
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
    }

    /**
     * @dev Calculate the minimum of two numbers.
     * @param a First number.
     * @param b Second number.
     * @return uint256 the minimum value.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Cleanup plan after distribution.
     * @param _owner Address of the owner whose plan is to be cleaned up.
     */
    function _cleanupPlan(address _owner) internal {
        InheritancePlan storage plan = plans[_owner];
        
        // Remove owner from all beneficiaries' mappings
        for (uint256 i = 0; i < plan.beneficiaries.length; i++) {
            address beneficiary = plan.beneficiaries[i].addr;
            address[] storage owners = beneficiaryToOwners[beneficiary];
            for (uint256 j = 0; j < owners.length; j++) {
                if (owners[j] == _owner) {
                    owners[j] = owners[owners.length - 1];
                    owners.pop();
                    break;
                }
            }
            emit BeneficiaryRemoved(_owner, beneficiary);
        }

        // Revoke all token approvals
        for (uint256 i = 0; i < plan.approvedTokens.length; i++) {
            plan.tokenApproved[plan.approvedTokens[i]] = false;
        }
        delete plan.approvedTokens;

        // Reset plan details
        delete plans[_owner];

        emit PlanDeleted(_owner);
    }

    /**
     * @dev Handle the distribution of a single token.
     * @param plan Storage reference to the inheritance plan.
     * @param token ERC20 token to distribute.
     * @param amount Amount of tokens to transfer.
     * @param isExecutor Boolean indicating if the caller is an executor.
     * @return uint256 executor fee collected.
     */
    function handleTokenDistribution(
        InheritancePlan storage plan,
        IERC20 token,
        uint256 amount,
        bool isExecutor
    ) internal returns (uint256) {
        uint256 devFee = (amount * DEVELOPER_FEE_BPS) / TOTAL_SHARES;
        uint256 execFee = isExecutor ? (amount * EXECUTOR_FEE_BPS) / TOTAL_SHARES : 0;
        uint256 distributeAmt = amount - devFee - execFee;

        // Transfer developer fee
        token.safeTransferFrom(plan.owner, developer, devFee);

        // Transfer executor fee if applicable
        if (isExecutor && execFee > 0) {
            token.safeTransferFrom(plan.owner, msg.sender, execFee);
        }

        // Distribute to beneficiaries
        for (uint256 i = 0; i < plan.beneficiaries.length; i++) {
            Beneficiary memory b = plan.beneficiaries[i];
            uint256 bAmt = (distributeAmt * b.share) / TOTAL_SHARES;
            if (bAmt > 0) {
                token.safeTransferFrom(plan.owner, b.addr, bAmt);
            }
        }

        return execFee;
    }
}