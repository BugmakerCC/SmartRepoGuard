// File: @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


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
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

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
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

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

// File: crashtest/crash-token/contracts/CTDT_ICO.sol

// security contact: crash@crashtestdummytoken.com; info@crashtestdummytoken.shop; info@saferouteinnovations.com



pragma solidity ^0.8.20;








/**
 * @title CTDTICOSale
 * @notice This contract manages the ICO sale for CTDT tokens.
 * @dev The contract allows the purchase of CTDT tokens using ETH or accepted ERC20 tokens.
 */
contract CTDTICOSale is Ownable, Pausable, ReentrancyGuard {
    using Address for address payable;


    IERC20 public immutable token;
    AggregatorV3Interface internal immutable priceFeedETHUSDT; // Use only for ETH to USDT conversion
    uint256 public priceCTDTinUSDT; // 700000 WEI expressed in the smallest unit of USDT (0.007 * 10^6)


    mapping(address => bool) public whitelisted;
    mapping(address => AggregatorV3Interface) public tokenPriceFeeds;
    mapping(address => bool) public acceptedTokens;
    mapping(address => uint8) private tokenDecimals;


    event TokensPurchased(address indexed buyer, uint256 ctdtAmount, address paymentToken, uint256 paymentAmount);
    event WhitelistUpdated(address indexed participant, bool status);
    event PriceFeedSet(address indexed tokenAddress, address priceFeedAddress, uint8 decimals, bool accepted);
    event PriceUpdated(uint256 price);
    event AcceptedTokenUpdated(address indexed tokenAddress, bool status);


    /**
     * @notice Modifier to restrict access to only whitelisted addresses.
     */
    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }


    /**
     * @notice Modifier to restrict actions to only accepted tokens.
     * @param tokenAddress The address of the token to check.
     */
    modifier onlyAcceptedTokens(address tokenAddress) {
        require(acceptedTokens[tokenAddress], "Token not accepted");
        _;
    }


    /**
     * @notice Constructor to initialize the ICO sale contract.
     * @param initialOwner The address of the contract owner.
     * @param _token The address of the CTDT token contract.
     * @param _ethPriceFeedAddress The address of the ETH/USDT price feed.
     * @param _initialPriceCTDTinUSDT The initial price of CTDT in USDT.
     */
    constructor(
        address initialOwner,
        IERC20 _token,
        address _ethPriceFeedAddress,
        uint256 _initialPriceCTDTinUSDT
    ) Ownable(initialOwner) Pausable() ReentrancyGuard() {
        token = _token;
        priceFeedETHUSDT = AggregatorV3Interface(_ethPriceFeedAddress);
        acceptedTokens[address(0)] = true;
        priceCTDTinUSDT = _initialPriceCTDTinUSDT; // Initialize the price
    }


    /**
     * @notice Set the price feed for a token.
     * @param tokenAddress The address of the token.
     * @param priceFeedAddress The address of the price feed contract.
     * @param decimals The decimals of the token.
     * @param accept Whether the token is accepted for payment.
     */
    function setTokenPriceFeed(address tokenAddress, address priceFeedAddress, uint8 decimals, bool accept) public onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        require(priceFeedAddress != address(0), "Invalid price feed address");


        if (accept) {
            tokenPriceFeeds[tokenAddress] = AggregatorV3Interface(priceFeedAddress);
            tokenDecimals[tokenAddress] = decimals;
            acceptedTokens[tokenAddress] = true;
        } else {
            delete tokenPriceFeeds[tokenAddress];
            delete tokenDecimals[tokenAddress];
            delete acceptedTokens[tokenAddress];
        }


        emit PriceFeedSet(tokenAddress, priceFeedAddress, decimals, accept);
    }


    /**
     * @notice Calculate the required ETH amount for a given CTDT amount.
     * @param ctdtAmount The amount of CTDT tokens.
     * @return The required ETH amount.
     */
    function calculateETHForCTDT(uint256 ctdtAmount) public view returns (uint256) {
        (, int256 price, , , ) = priceFeedETHUSDT.latestRoundData();
        require(price > 0, "Price feed error");


        uint256 totalCostInETH = ctdtAmount * priceCTDTinUSDT / uint256(price);


        return totalCostInETH;
    }


    /**
     * @notice Calculate the required token amount for a given CTDT amount.
     * @param ctdtAmount The amount of CTDT tokens.
     * @param paymentToken The address of the payment token.
     * @return The required token amount.
     */
    function calculateTokenForCTDT(uint256 ctdtAmount, address paymentToken) public view returns (uint256) {
        if(address(tokenPriceFeeds[paymentToken]) == address(0)) {
            revert ("Price feed not set for this token");
        }
        AggregatorV3Interface priceFeed = AggregatorV3Interface(tokenPriceFeeds[paymentToken]);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 tokenPriceInUSDT = uint256(price) * (10 ** (18 - tokenDecimals[paymentToken]));


        uint256 totalCostInUSDT = ctdtAmount * priceCTDTinUSDT;
        uint256 tokenAmount = totalCostInUSDT / tokenPriceInUSDT;


        return tokenAmount;
    }


    /**
     * @notice Check if a participant is whitelisted.
     * @param _participant The address of the participant.
     * @return True if the participant is whitelisted, false otherwise.
     */
    function whitelist(address _participant) external view returns (bool) {
        return whitelisted[_participant];
    }


    /**
     * @notice Update the whitelist status of a participant.
     * @param _participant The address of the participant.
     * @param _status The whitelist status.
     */
    function updateWhitelist(address _participant, bool _status) external onlyOwner {
        whitelisted[_participant] = _status;
        emit WhitelistUpdated(_participant, _status);
    }


    /**
     * @notice Batch update the whitelist status of multiple participants.
     * @param participants The addresses of the participants.
     * @param statuses The whitelist statuses.
     */
    function batchUpdateWhitelist(address[] calldata participants, bool[] calldata statuses) external onlyOwner {
        require(participants.length == statuses.length, "Array length mismatch");


        for (uint256 i = 0; i < participants.length; i++) {
            whitelisted[participants[i]] = statuses[i];
            emit WhitelistUpdated(participants[i], statuses[i]);
        }
    }


    /**
    * @notice Update the accepted status of a token.
    * @param tokenAddress The address of the token.
    * @param _status The accepted status.
    */
    function updateAcceptedToken(address tokenAddress, bool _status) external onlyOwner {
        acceptedTokens[tokenAddress] = _status;
        emit AcceptedTokenUpdated(tokenAddress, _status);
    }


    /**
     * @notice Buy CTDT tokens with payment in ETH or accepted ERC20 tokens.
     * @param ctdtAmount The amount of CTDT tokens to buy.
     * @param paymentToken The address of the payment token.
     */
    function buyTokens(uint256 ctdtAmount, address paymentToken) external payable nonReentrant whenNotPaused onlyWhitelisted onlyAcceptedTokens(paymentToken) {
        require(ctdtAmount > 0, "No tokens requested");
        require(token.balanceOf(address(this)) >= ctdtAmount, "Not enough tokens in contract");
        uint256 paymentAmount;
        int256 ethPrice;


        if (paymentToken == address(0)) {  // payment in Ether
            paymentAmount = calculateETHForCTDT(ctdtAmount);
            (, ethPrice, , , ) = priceFeedETHUSDT.latestRoundData();


            require(msg.value >= paymentAmount, "Insufficient ETH sent!");
            require(msg.value > 0, "ETH amount must be greater than zero");
            if (!token.transfer(msg.sender, ctdtAmount)) revert("Token transfer failed");


            if (msg.value > paymentAmount) {
                payable(msg.sender).sendValue(msg.value - paymentAmount);
            }


        } else {  // payment in ERC20
            paymentAmount = calculateTokenForCTDT(ctdtAmount, paymentToken);
            uint256 balanceBefore = IERC20(paymentToken).balanceOf(address(this));
            if (!IERC20(paymentToken).transferFrom(msg.sender, address(this), paymentAmount)) {
                revert("Transfer failed");
            }
            uint256 balanceAfter = IERC20(paymentToken).balanceOf(address(this));
            require(balanceAfter >= balanceBefore + paymentAmount, "Incorrect token amount sent");
            if (!token.transfer(msg.sender, ctdtAmount)) revert("Token transfer failed");
        }


        emit TokensPurchased(msg.sender, ctdtAmount, paymentToken, paymentAmount);
    }


    /**
     * @notice Withdraw funds from the contract.
     * @param tokenAddress The address of the token to withdraw, or address(0) for ETH.
     */
    function withdrawFunds(address tokenAddress) external onlyOwner nonReentrant {
        if (tokenAddress == address(0)) {  // withdraw Ether
            payable(owner()).sendValue(address(this).balance);
        } else {  // withdraw ERC20
            IERC20 paymentTokenContract = IERC20(tokenAddress);
            uint256 balance = paymentTokenContract.balanceOf(address(this));


            if (balance == 0) {
                revert("No funds to withdraw");
            } else {
                require(paymentTokenContract.transfer(owner(), balance), "Transfer failed");
            }
        }
    }


    /**
     * @notice Get the USD price of a token.
     * @param tokenAddress The address of the token.
     * @return The USD price of the token.
     */
    function getTokenPriceUSD(address tokenAddress) external view returns (uint256) {
        if(address(tokenPriceFeeds[tokenAddress]) == address(0)) {
            revert("Price feed not set for this token");
        }
        (, int256 price, , , ) = tokenPriceFeeds[tokenAddress].latestRoundData();
        return uint256(price);
    }


    /**
     * @notice Get the USD price of ETH.
     * @return The USD price of ETH.
     */
    function getEthPriceInUsd() external view returns (uint256) {
        (, int256 price, , , ) = priceFeedETHUSDT.latestRoundData();
        return uint256(price);
    }


    /**
     * @notice Pause the ICO sale.
     */
    function pauseICO() external onlyOwner {
        _pause();
    }


    /**
     * @notice Unpause the ICO sale.
     */
    function unpauseICO() external onlyOwner {
        _unpause();
    }


    /**
     * @notice Get the available CTDT tokens in the contract.
     * @return The available CTDT tokens.
     */
    function availableTokens() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}