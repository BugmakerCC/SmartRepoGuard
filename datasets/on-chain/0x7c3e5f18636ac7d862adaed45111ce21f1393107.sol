// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 ^0.8.20 ^0.8.26;

//*
//* Website -   https://onlyup.win/
//* 
//*     /$$     /$$$$$$  /$$   /$$ /$$   /$$     /$$ /$$   /$$ /$$$$$$$                                                                                                                                                                                                                                                                                                                                                                               
//*   /$$$$$$  /$$__  $$| $$$ | $$| $$  |  $$   /$$/| $$  | $$| $$__  $$                                                                                                                                                                                                                                                                                                                                                                              
//*  /$$__  $$| $$  \ $$| $$$$| $$| $$   \  $$ /$$/ | $$  | $$| $$  \ $$                                                                                                                                                                                                                                                                                                                                                                              
//* | $$  \__/| $$  | $$| $$ $$ $$| $$    \  $$$$/  | $$  | $$| $$$$$$$/                                                                                                                                                                                                                                                                                                                                                                              
//* |  $$$$$$ | $$  | $$| $$  $$$$| $$     \  $$/   | $$  | $$| $$____/                                                                                                                                                                                                                                                                                                                                                                               
//*  \____  $$| $$  | $$| $$\  $$$| $$      | $$    | $$  | $$| $$                                                                                                                                                                                                                                                                                                                                                                                    
//*  /$$  \ $$|  $$$$$$/| $$ \  $$| $$$$$$$$| $$    |  $$$$$$/| $$                                                                                                                                                                                                                                                                                                                                                                                    
//* |  $$$$$$/ \______/ |__/  \__/|________/|__/     \______/ |__/                                                                                                                                                                                                                                                                                                                                                                                    
//*  \_  $$_/                                                                                                                                                                                                                                                                                                                                                                                                                                         
//*    \__/                                                                                                                                                                                                                                                                                                                                                                                                                                           
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*                                                                                                                                                                                                                                                                                                                                                                                                                                                   
//*  /$$$$$$$$ /$$                         /$$               /$$                                   /$$     /$$                   /$$                 /$$            /$$$$$$  /$$                                                                   /$$   /$$                                               /$$                           /$$                   /$$                                         /$$                                     /$$
//* |__  $$__/| $$                        | $$              | $$                                  | $$    | $$                  | $$                | $$           /$$__  $$|__/                                                                  |__/  | $$                                              | $$                          | $$                  | $$                                        | $$                                    | $$
//*    | $$   | $$$$$$$   /$$$$$$        /$$$$$$    /$$$$$$ | $$   /$$  /$$$$$$  /$$$$$$$        /$$$$$$  | $$$$$$$   /$$$$$$  /$$$$$$          /$$$$$$$  /$$$$$$ | $$  \__/ /$$  /$$$$$$   /$$$$$$$        /$$$$$$   /$$$$$$  /$$$$$$  /$$    /$$ /$$ /$$$$$$   /$$   /$$        /$$$$$$  /$$$$$$$   /$$$$$$$        /$$$$$$  /$$$$$$$ | $$ /$$   /$$       /$$$$$$    /$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$$       /$$   /$$  /$$$$$$ | $$
//*    | $$   | $$__  $$ /$$__  $$      |_  $$_/   /$$__  $$| $$  /$$/ /$$__  $$| $$__  $$      |_  $$_/  | $$__  $$ |____  $$|_  $$_/         /$$__  $$ /$$__  $$| $$$$    | $$ /$$__  $$ /$$_____/       /$$__  $$ /$$__  $$|____  $$|  $$  /$$/| $$|_  $$_/  | $$  | $$       |____  $$| $$__  $$ /$$__  $$       /$$__  $$| $$__  $$| $$| $$  | $$      |_  $$_/   /$$__  $$ /$$__  $$| $$__  $$ /$$__  $$ /$$_____/      | $$  | $$ /$$__  $$| $$
//*    | $$   | $$  \ $$| $$$$$$$$        | $$    | $$  \ $$| $$$$$$/ | $$$$$$$$| $$  \ $$        | $$    | $$  \ $$  /$$$$$$$  | $$          | $$  | $$| $$$$$$$$| $$_/    | $$| $$$$$$$$|  $$$$$$       | $$  \ $$| $$  \__/ /$$$$$$$ \  $$/$$/ | $$  | $$    | $$  | $$        /$$$$$$$| $$  \ $$| $$  | $$      | $$  \ $$| $$  \ $$| $$| $$  | $$        | $$    | $$  \__/| $$$$$$$$| $$  \ $$| $$  | $$|  $$$$$$       | $$  | $$| $$  \ $$|__/
//*    | $$   | $$  | $$| $$_____/        | $$ /$$| $$  | $$| $$_  $$ | $$_____/| $$  | $$        | $$ /$$| $$  | $$ /$$__  $$  | $$ /$$      | $$  | $$| $$_____/| $$      | $$| $$_____/ \____  $$      | $$  | $$| $$      /$$__  $$  \  $$$/  | $$  | $$ /$$| $$  | $$       /$$__  $$| $$  | $$| $$  | $$      | $$  | $$| $$  | $$| $$| $$  | $$        | $$ /$$| $$      | $$_____/| $$  | $$| $$  | $$ \____  $$      | $$  | $$| $$  | $$    
//*    | $$   | $$  | $$|  $$$$$$$        |  $$$$/|  $$$$$$/| $$ \  $$|  $$$$$$$| $$  | $$        |  $$$$/| $$  | $$|  $$$$$$$  |  $$$$/      |  $$$$$$$|  $$$$$$$| $$      | $$|  $$$$$$$ /$$$$$$$/      |  $$$$$$$| $$     |  $$$$$$$   \  $/   | $$  |  $$$$/|  $$$$$$$      |  $$$$$$$| $$  | $$|  $$$$$$$      |  $$$$$$/| $$  | $$| $$|  $$$$$$$        |  $$$$/| $$      |  $$$$$$$| $$  | $$|  $$$$$$$ /$$$$$$$/      |  $$$$$$/| $$$$$$$/ /$$
//*    |__/   |__/  |__/ \_______/         \___/   \______/ |__/  \__/ \_______/|__/  |__/         \___/  |__/  |__/ \_______/   \___/         \_______/ \_______/|__/      |__/ \_______/|_______/        \____  $$|__/      \_______/    \_/    |__/   \___/   \____  $$       \_______/|__/  |__/ \_______/       \______/ |__/  |__/|__/ \____  $$         \___/  |__/       \_______/|__/  |__/ \_______/|_______/        \______/ | $$____/ |__/
//*                                                                                                                                                                                                        /$$  \ $$                                             /$$  | $$                                                                   /$$  | $$                                                                                  | $$          
//*                                                                                                                                                                                                       |  $$$$$$/                                            |  $$$$$$/                                                                  |  $$$$$$/                                                                                  | $$          
//*                                                                                                                                                                                                        \______/                                              \______/                                                                    \______/                                                                                   |__/                                                                                                                                                                                                               \______/                                              \______/                                                                    \______/        \______/                                               |__/          
//* 

// lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol

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

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

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

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol

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

// lib/openzeppelin-contracts/contracts/utils/Address.sol

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

// lib/openzeppelin-contracts/contracts/utils/Context.sol

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

// lib/openzeppelin-contracts/contracts/utils/math/Math.sol

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

// lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// src/OnlyUpDataModel.sol



struct AccountOrder {
    // overflow theoritcally possible and not desired
    // at the End of Life contract stop enforcing selling restrictions
    uint256 accumulated;
    uint112 orderWEthSize; //cannot be bigger then Univ2 reserve
    uint128 orderUpSize;
    bytes32 nextIndex;
}

struct AccountState {
    bytes32 sellIndexTip;
    bool blacklisted;

    mapping (bytes32 => AccountOrder) orders;
}

struct UpdateSellState {
    bytes32 orderIndex;
    uint256 remainingValue;

    AccountOrder order;
}

struct UpdateTransferState {
    bytes32 orderIndex;
    uint256 remainingValue;

    AccountOrder sourceOrderMemory;
    AccountOrder newOrder;
}

struct InsertOrderState {
    bytes32 currentOrderIndex;
    bytes32 prevIndex;

    AccountOrder newEntry;
    AccountOrder currentOrderMemory;
    AccountOrder newOrderSegment;

    uint256 wEthWindowStart;
    uint256 wEthWindowEnd;
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

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

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

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

// lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol

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

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

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

// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol

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

// src/OnlyUpGeneric.sol
















abstract contract OnlyUpGeneric is ERC20, Ownable2Step {
    /***************************************************************************************************************************************************************************************************************
    * Born from ambition and cunning, this contract is our pledge. Its authenticity, forever etched in the hash '0x914baeb9ebfdefb9b1eee8faadfb6e8fc63c6b88714adb5e8e530acebaf230bd', ensures our promise endures. *
    ****************************************************************************************************************************************************************************************************************/

    constructor(uint256 kE4, bool deployPair) 
        ERC20("ONLYUP", "$ONLYUP") Ownable(msg.sender) {
        _init();
        _isToken0 = address(this) < address(_wEthErc20());

        require(kE4 >= 1e4, "K is wrong. Must be greater then or equal to 1.0");

        KE4 = kE4;

        if (deployPair) {
            Dex = IUniswapV2Pair(_univ2Factory().createPair(address(_wEthErc20()), address(this)));   
        } else {
            Dex = IUniswapV2Pair(address(0));
        }

        EolDelta = 10 ether;
        LastBuyTimestamp = uint40(block.timestamp);
        AutoUnlockTimespan = 7 days;
    }

    bool                                    internal immutable              _isToken0;
    IUniswapV2Pair                          public immutable                Dex;
    uint256                                 public immutable                KE4;
    bool                                    public                          PairLaunched;
    bool                                    public                          OpenMarketEnabled;
    uint72                                  public                          EolDelta;
    uint40                                  public                          LastBuyTimestamp;
    uint24                                  public                          AutoUnlockTimespan; //up to 6 month
    uint256                                 public                          AmountInAccumulated;
    mapping(address => AccountState)        public                          AccountStates;
    mapping(address => uint256)             public                          EarlyBuyers;

    event BlacklistChanged(address indexed wallet, bool indexed blacklisted);
    event EolDeltaUpdated(uint72 indexed newDelta);
    event UnlockTimespanUpdated(uint24 indexed newTimespan);
    


    function _wEthErc20() internal virtual view returns (IERC20);
    function _univ2Factory() internal virtual view returns (IUniswapV2Factory);
    function _init() internal virtual {

    }

    function _getPairReserves(IUniswapV2Pair dex) private view returns(uint256, uint256) {
        (uint112 reserve0, uint112 reserve1, ) = dex.getReserves();

        if (_isToken0) {
            return (reserve1, reserve0);
        } else {
            return (reserve0, reserve1);
        }
    }

    function _getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256 amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = numerator / denominator + 1;
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function _getRoundedPortion(uint256 portionE20, uint256 value) internal pure returns (uint256) {
        value = portionE20 * value / 1e19;
        unchecked {
            uint256 roundUp = (value % 10) / 5;

            return value / 10 + roundUp;
        }
    }

    function _eolEnforced(uint256 accumulated) internal view returns (bool) {
        return (type(uint256).max - EolDelta) <= accumulated;
    }

    function _sellBuyLockEnforced() internal view returns (bool) {
        return (uint256(LastBuyTimestamp) + AutoUnlockTimespan) >= block.timestamp;
    }

    function _insertNewAccountOrderBetweenIndexes(AccountState storage userAccount, bytes32 prevIndex, bytes32 index, AccountOrder memory newEntry) internal returns (bytes32) {
        bytes32 newIndex;

        //Chosing which direction we grow

        if (index == bytes32(0))
            newIndex = prevIndex;
        else
            newIndex = index;

        newIndex = _efficientHash(newIndex, bytes32(newEntry.accumulated));
        
        newEntry.nextIndex = index;
        userAccount.orders[newIndex] = newEntry;

        if (userAccount.sellIndexTip == index) {
            userAccount.sellIndexTip = newIndex;
        } else {
            userAccount.orders[prevIndex].nextIndex = newIndex;
        }

        return newIndex;
    }

    function __lmb_insertNewAccountOrder_nextIterationSwitch(InsertOrderState memory state) internal pure{
        state.prevIndex = state.currentOrderIndex;        
        state.currentOrderIndex = state.currentOrderMemory.nextIndex;
    }

    function _insertNewAccountOrder(AccountState storage userAccount, AccountOrder memory newEntryOriginal) internal {
        if (userAccount.sellIndexTip == bytes32(0)) {
            _insertNewAccountOrderBetweenIndexes(userAccount, bytes32(0), bytes32(0), newEntryOriginal);

            return;
        }

        InsertOrderState memory state;
        state.currentOrderIndex = userAccount.sellIndexTip;

        state.newEntry.accumulated = newEntryOriginal.accumulated;
        state.newEntry.orderWEthSize = newEntryOriginal.orderWEthSize;
        state.newEntry.orderUpSize = newEntryOriginal.orderUpSize;
        

        uint256 newEntryEnd = state.newEntry.accumulated + state.newEntry.orderWEthSize * KE4 / 1e4;

        for (state.prevIndex = bytes32(0); state.currentOrderIndex != bytes32(0); __lmb_insertNewAccountOrder_nextIterationSwitch(state)) {
            AccountOrder storage currentOrder = userAccount.orders[state.currentOrderIndex];
            state.currentOrderMemory = currentOrder;
            uint256 currentOrderWethEnd = state.currentOrderMemory.accumulated + state.currentOrderMemory.orderWEthSize * KE4 / 1e4;

            if (currentOrderWethEnd <= state.newEntry.accumulated) {
                //in case if we're at the end, just do it here without need of post-loop action
                if (state.currentOrderMemory.nextIndex == bytes32(0)) {
                    _insertNewAccountOrderBetweenIndexes(userAccount, state.currentOrderIndex, bytes32(0), state.newEntry);

                    return; // gas saving
                }
                continue;
            }

            // Two options of the start
            if (state.newEntry.accumulated < state.currentOrderMemory.accumulated) {
                state.newEntry.nextIndex = state.currentOrderIndex;

                if (newEntryEnd <= state.currentOrderMemory.accumulated) {
                    _insertNewAccountOrderBetweenIndexes(userAccount, state.prevIndex, state.currentOrderIndex, state.newEntry);

                    return;
                } //else

                state.wEthWindowStart = state.currentOrderMemory.accumulated;

                uint256 segmentPortionE20 = Math.mulDiv(1e20, state.currentOrderMemory.accumulated - state.newEntry.accumulated, newEntryEnd - state.newEntry.accumulated);

                state.newOrderSegment.accumulated = state.newEntry.accumulated;
                state.newOrderSegment.orderWEthSize = uint112(_getRoundedPortion(segmentPortionE20, state.newEntry.orderWEthSize));
                state.newOrderSegment.orderUpSize = uint128(_getRoundedPortion(segmentPortionE20, state.newEntry.orderUpSize));

                _insertNewAccountOrderBetweenIndexes(userAccount, state.prevIndex, state.currentOrderIndex, state.newOrderSegment);

            } else if (state.currentOrderMemory.accumulated < state.newEntry.accumulated) {
                state.wEthWindowStart = state.newEntry.accumulated;

                uint256 segmentPortionE20 = Math.mulDiv(1e20, state.newEntry.accumulated - state.currentOrderMemory.accumulated, currentOrderWethEnd - state.currentOrderMemory.accumulated);

                state.newOrderSegment.accumulated = state.currentOrderMemory.accumulated;
                state.newOrderSegment.orderWEthSize = uint112(_getRoundedPortion(segmentPortionE20, state.currentOrderMemory.orderWEthSize));
                state.newOrderSegment.orderUpSize = uint128(_getRoundedPortion(segmentPortionE20, state.currentOrderMemory.orderUpSize));
                
                state.newEntry.nextIndex = state.currentOrderIndex;
                _insertNewAccountOrderBetweenIndexes(userAccount, state.prevIndex, state.currentOrderIndex, state.newOrderSegment);
            }

            //Two options of end
            if (newEntryEnd < currentOrderWethEnd) {
                state.wEthWindowEnd = newEntryEnd;

                uint256 segmentPortionE20 = Math.mulDiv(1e20, currentOrderWethEnd - newEntryEnd, currentOrderWethEnd - state.currentOrderMemory.accumulated);

                state.newOrderSegment.accumulated = newEntryEnd;
                state.newOrderSegment.orderWEthSize = uint112(_getRoundedPortion(segmentPortionE20, state.currentOrderMemory.orderWEthSize));
                state.newOrderSegment.orderUpSize = uint128(_getRoundedPortion(segmentPortionE20, state.currentOrderMemory.orderUpSize));
                
                _insertNewAccountOrderBetweenIndexes(userAccount, state.currentOrderIndex, state.currentOrderMemory.nextIndex, state.newOrderSegment);

            } else if (currentOrderWethEnd < newEntryEnd) {
                state.wEthWindowEnd = currentOrderWethEnd;

                //later on we're moving on this extra portion towards new for loop iteration
            }
        

            {
                uint256 accumDelta = state.wEthWindowEnd - state.wEthWindowStart;

                uint256 currentSegmentPortionE20 = Math.mulDiv(1e20, accumDelta, currentOrderWethEnd - state.currentOrderMemory.accumulated);
                uint256 newSegmentPortionE20 = Math.mulDiv(1e20, accumDelta, newEntryEnd - state.newEntry.accumulated);

                currentOrder.accumulated = state.wEthWindowStart;
                currentOrder.orderWEthSize = uint112(_getRoundedPortion(currentSegmentPortionE20, state.currentOrderMemory.orderWEthSize));
                currentOrder.orderUpSize = uint128(_getRoundedPortion(currentSegmentPortionE20, state.currentOrderMemory.orderUpSize) + 
                                            _getRoundedPortion(newSegmentPortionE20, state.newEntry.orderUpSize));

            }

            //Repeating the case to do proper move info upfront
            if (currentOrderWethEnd < newEntryEnd)  {
                uint256 segmentPortionE20 = Math.mulDiv(1e20, newEntryEnd - currentOrderWethEnd, newEntryEnd - state.newEntry.accumulated);
            
                state.newEntry.accumulated = currentOrderWethEnd;
                state.newEntry.orderWEthSize = uint112(_getRoundedPortion(segmentPortionE20, state.newEntry.orderWEthSize));
                state.newEntry.orderUpSize = uint128(_getRoundedPortion(segmentPortionE20, state.newEntry.orderUpSize));

                //in case if we're at the end, just do it here without need of post-loop action
                if (state.currentOrderMemory.nextIndex == bytes32(0)) {
                    _insertNewAccountOrderBetweenIndexes(userAccount, state.currentOrderIndex, bytes32(0), state.newEntry);

                    return; //gas saving
                }
            } else {
                return; //gas saving; instead must do break
            }
        }        
    }

    function _update(address from, address to, uint256 value) internal override {
        if ((from != address(0)) && (to != address(0))) {
            IUniswapV2Pair dex = Dex;
            (uint256 wEthReserve, uint256 upReserve) = _getPairReserves(dex);

            //Buying
            if (from == address(dex)) {
                uint256 wEthPairBalance = _wEthErc20().balanceOf(address(dex));
                uint256 amountIn;

                LastBuyTimestamp = uint40(block.timestamp);

                // normal buy order
                if (wEthPairBalance != wEthReserve) {
                    amountIn = wEthPairBalance - wEthReserve;

                    uint256 estimatedIn = _getAmountIn(value, wEthReserve, upReserve);
                    int256 delta = int256(estimatedIn) - int256(amountIn);

                    //Trick protection - split payment in
                    //Part of payment may go through callback
                    if (delta > 1e5 wei) {
                        amountIn = estimatedIn;
                    }                    
                } else { //callback buy order
                    amountIn = _getAmountIn(value, wEthReserve, upReserve);
                }

                if (!OpenMarketEnabled) {
                    uint256 remainingPresale = EarlyBuyers[to];

                    require(remainingPresale >= amountIn, "Exceding early threshold");
                    EarlyBuyers[to]  = remainingPresale - amountIn;
                }

                uint256 accumulated = amountIn + AmountInAccumulated;
                AmountInAccumulated = accumulated;

                AccountOrder memory newOrder;

                newOrder.accumulated = accumulated;
                newOrder.orderWEthSize = uint112(amountIn);
                newOrder.orderUpSize = uint128(value);
           
                _insertNewAccountOrder(AccountStates[to], newOrder);
            } else if (to == address(dex)) { //selling
                uint256 accumulated = AmountInAccumulated;

                if (!_eolEnforced(accumulated)) {
                    AccountState storage accountState = AccountStates[from];
                    UpdateSellState memory state;

                    state.orderIndex = accountState.sellIndexTip;
                    state.remainingValue = value;
                    for (; (state.orderIndex != bytes32(0)) && (state.remainingValue > 0); state.orderIndex = state.order.nextIndex) {
                        state.order = accountState.orders[state.orderIndex];

                        uint256 sellTokensFromOrder = state.order.orderUpSize;
                        uint256 wethPortion = state.order.orderWEthSize;

                        if (state.remainingValue < sellTokensFromOrder) {
                            sellTokensFromOrder = state.remainingValue;
                            uint256 sellPercentageE20 = (sellTokensFromOrder * 1e20) / uint256(state.order.orderUpSize);
                            wethPortion = _getRoundedPortion(sellPercentageE20, state.order.orderWEthSize);
                        }

                        uint256 newSrcAccumulated = state.order.accumulated + (KE4 * wethPortion) / 1e4;

                        if (_sellBuyLockEnforced())
                            require(newSrcAccumulated <= accumulated, "There is not much tokens came in to unlock your sell");

                        state.order.accumulated = newSrcAccumulated;
                        state.order.orderWEthSize -= uint112(wethPortion);
                        state.order.orderUpSize -= uint128(sellTokensFromOrder);
                        state.remainingValue -= sellTokensFromOrder;
                       
                        accountState.orders[state.orderIndex] = state.order;

                        if (((state.order.orderUpSize | state.order.orderWEthSize) != 0) && (state.remainingValue == 0)) break;
                    }

                    accountState.sellIndexTip = state.orderIndex;
                }
            } else { //regular transfer

                AccountState storage sourceAccount = AccountStates[from];
                AccountState storage dstAccount = AccountStates[to];

                require(!sourceAccount.blacklisted, "Source is blacklisted");
                require(!dstAccount.blacklisted, "Destination is blacklisted");

                UpdateTransferState memory state;
                state.orderIndex = sourceAccount.sellIndexTip;
                state.remainingValue = value;

                for (; (state.orderIndex != bytes32(0)) && (state.remainingValue > 0); state.orderIndex = state.sourceOrderMemory.nextIndex) {
                    AccountOrder storage sourceOrder = sourceAccount.orders[state.orderIndex];
                    state.sourceOrderMemory = sourceOrder;

                    if (state.remainingValue < state.sourceOrderMemory.orderUpSize) { ///breaking the order
                        uint256 segmentPortionE20 = 1e20 * state.remainingValue / state.sourceOrderMemory.orderUpSize;

                        state.newOrder.accumulated = state.sourceOrderMemory.accumulated;
                        state.newOrder.orderWEthSize = uint112(_getRoundedPortion(segmentPortionE20, state.sourceOrderMemory.orderWEthSize));
                        state.newOrder.orderUpSize = uint128(state.remainingValue);
                        state.newOrder.nextIndex = bytes32(0);
                        
                        _insertNewAccountOrder(dstAccount, state.newOrder);

                        sourceOrder.accumulated = state.sourceOrderMemory.accumulated + state.newOrder.orderWEthSize * KE4 / 1e4;
                        sourceOrder.orderWEthSize = uint112(state.sourceOrderMemory.orderWEthSize - state.newOrder.orderWEthSize);
                        sourceOrder.orderUpSize = uint128(state.sourceOrderMemory.orderUpSize - state.remainingValue);

                        state.remainingValue = 0;

                        //always should be here, otherwise index will move to the next one
                        //and we miss current order
                        break;
                    } else {
                        state.sourceOrderMemory.nextIndex = bytes32(0);
                        
                        _insertNewAccountOrder(dstAccount, state.sourceOrderMemory);
                        state.remainingValue -= state.sourceOrderMemory.orderUpSize;
                    }
                }

                sourceAccount.sellIndexTip = state.orderIndex;
            }
        }

        super._update(from, to, value);
    }

    function GetAccountOrder(address wallet, bytes32 orderIndex) external view returns (AccountOrder memory) {
        return AccountStates[wallet].orders[orderIndex];
    }

    function GetAvailableAmountToSell(address wallet) public view returns (uint256) {
        AccountState storage accountState = AccountStates[wallet];
        AccountOrder memory order;

        uint256 upAmount = 0;

        for (bytes32 orderIndex = accountState.sellIndexTip; orderIndex != bytes32(0); orderIndex = order.nextIndex) {
            order = accountState.orders[orderIndex];

            if ((order.accumulated + KE4 * order.orderWEthSize / 1e4) > AmountInAccumulated) {
                uint256 wethPortion = (AmountInAccumulated - order.accumulated) * 1e4 / KE4;
                uint256 portionE20 = wethPortion * 1e20 / order.orderWEthSize;
                
                upAmount += portionE20 * order.orderUpSize / 1e20; //round down

                break;
            }

            upAmount += order.orderUpSize;
        }

        return upAmount;
    }

    function IsSellLockEnforced() external view returns (bool) {
        return !_eolEnforced(AmountInAccumulated) && _sellBuyLockEnforced();
    }

    function LaunchPair(uint112 supply) external onlyOwner {
        require (!PairLaunched, "pool can be launched only once");
        PairLaunched = true;

        _mint(address(Dex), supply);
        SafeERC20.safeTransfer(_wEthErc20(), address(Dex), _wEthErc20().balanceOf(address(this)));

        Dex.mint(address(this));
    }

    function SetBlacklist(address wallet, bool isBlacklisted) external onlyOwner {
        AccountStates[wallet].blacklisted = isBlacklisted;

        emit BlacklistChanged(wallet, isBlacklisted);
    }

    function SetEolDelta(uint72 newEolDelta, bool disallowImmediateEnforce) external onlyOwner {
        uint256 accumulated = AmountInAccumulated;
        require(!_eolEnforced(accumulated), "EOL already enforced");

        if (disallowImmediateEnforce) {
            require((type(uint256).max - newEolDelta) > accumulated, "New EOL delta leads to automatic irreversibale enforcing of EOL");
        }

        EolDelta = newEolDelta;
        emit EolDeltaUpdated(newEolDelta);
    }
    
    function SetAutoUnlockTimespan(uint24 autoUnlockTimespan) external onlyOwner {
        require(autoUnlockTimespan >= 7 days, "autoUnlockTimespan must be not least 7 days");
        AutoUnlockTimespan = autoUnlockTimespan;

        emit UnlockTimespanUpdated(autoUnlockTimespan);
    }

    function EnableOpenMarket() external onlyOwner {
        OpenMarketEnabled = true;
    }

    function WhitelistEarlyBuy(address[] calldata wallets, uint256[] calldata amounts) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            EarlyBuyers[wallets[i]] = amounts[i];
        }
    }
}

// src/OnlyUpOnEthereum.sol





contract OnlyUpOnEthereum is OnlyUpGeneric {
    constructor(uint256 kE4) OnlyUpGeneric(kE4, true) {
        
    }

    function _wEthErc20() internal override pure returns (IERC20) { return IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); }
    function _univ2Factory() internal override pure returns (IUniswapV2Factory) { return IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); }
}