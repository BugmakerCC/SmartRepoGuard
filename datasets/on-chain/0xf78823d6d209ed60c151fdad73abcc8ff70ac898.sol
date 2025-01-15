// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

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

contract WPL_Presale is ReentrancyGuard, Ownable {
    IERC20 public token; // Token being sold (WPL token)
    IERC20 public USDT;  // USDT token for payment
    
    uint256 public constant HARD_CAP = 1340000 * 10**6; // 1,340,000 USDT (USDT has 6 decimals)
    uint256 public constant TOTAL_TOKENS_FOR_SALE = 20000000 * 10**4; // 20,000,000 tokens with 4 decimals
    uint256 public constant WHITELIST_DURATION = 1 minutes; //  
    uint256 public constant PUBLIC_SALE_DURATION = 14 days; // 
    uint256 public constant MIN_CONTRIBUTION = 10 * 10**6; // Minimum purchase of 10 USDT
    uint256 public constant MAX_CONTRIBUTION = 10000 * 10**6; // Maximum purchase of 10000 USDT per wallet
    uint256 public constant TGE_PERCENTAGE = 20; // 20% tokens available at TGE
    uint256 public constant VESTING_MONTHS = 8; // Vesting for 8 months
    uint256 public constant SECONDS_IN_MONTH = 30 days; // 30 days

    uint256 public startTime;
    uint256 public presaleEndTime;
    uint256 public totalRaised; // Total USDT raised in presale
    uint256 public totalSoldTokens; // Tokens that have been sold during the presale
    uint256 public tgeTime; // Time when TGE (Token Generation Event) occurs

    address[] public participants; // Store participants
    mapping(address => uint256) public contributions; // Contributions in USDT
    mapping(address => bool) public whitelisted; // Whitelisted addresses
    mapping(address => uint256) public vestedTokens; // Tokens vested for each participant
    mapping(address => uint256) public tokensClaimed; // Tokens already claimed by each participant

    enum SalePhase { NOT_STARTED, WHITELIST, PUBLIC, ENDED }
    SalePhase public currentPhase;

    event TokensPurchased(address indexed purchaser, uint256 amount);
    event TokensReleased(address indexed recipient, uint256 amount);
    event TGEInitiated(uint256 tgeTime);

    constructor(IERC20 _token, IERC20 _usdt) Ownable(msg.sender) {
        token = _token;
        USDT = _usdt;
        currentPhase = SalePhase.NOT_STARTED;
        totalSoldTokens = 0; // Initialize total sold tokens to 0
    }

    modifier onlyDuringPhase(SalePhase phase) {
        require(currentPhase == phase, "Function cannot be called at this time.");
        _;
    }

    // Function to start the presale
    function startPresale() external onlyOwner {
        require(currentPhase == SalePhase.NOT_STARTED, "Presale already started.");
        startTime = block.timestamp;
        currentPhase = SalePhase.WHITELIST;
    }

    // Function to update whitelist addresses
    function updateWhitelist(address[] calldata addresses, bool isWhitelisted) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelisted[addresses[i]] = isWhitelisted;
        }
    }

    // Function to get the current sale phase
    function getCurrentPhase() public view returns (SalePhase) {
        if (currentPhase == SalePhase.NOT_STARTED) {
            return SalePhase.NOT_STARTED;
        } else if (block.timestamp >= startTime + WHITELIST_DURATION + PUBLIC_SALE_DURATION) {
            return SalePhase.ENDED;
        } else if (block.timestamp >= startTime + WHITELIST_DURATION) {
            return SalePhase.PUBLIC;
        } else {
            return SalePhase.WHITELIST;
        }
    }

    // Function to initiate TGE
    function initiateTGE() external onlyOwner {
        require(tgeTime == 0, "TGE already initiated");
        require(currentPhase == SalePhase.ENDED, "Presale must be ended to initiate TGE");
        tgeTime = block.timestamp; // Set the TGE time
        emit TGEInitiated(tgeTime); // Emit event for TGE initiation
    }

    // Function to buy tokens using USDT
    function buyTokens(uint256 usdtAmount) external nonReentrant {
        require(usdtAmount >= MIN_CONTRIBUTION, "Minimum contribution is 10 USDT.");
        require(contributions[msg.sender] + usdtAmount <= MAX_CONTRIBUTION, "Maximum contribution is 10000 USDT.");
        require(totalRaised + usdtAmount <= HARD_CAP, "Hard cap reached.");

        currentPhase = getCurrentPhase();

        // If sale is in whitelist phase, check if the buyer is whitelisted
        if (currentPhase == SalePhase.WHITELIST) {
            require(whitelisted[msg.sender], "Not whitelisted.");
        } else if (currentPhase != SalePhase.PUBLIC) {
            revert("Sale is not active.");
        }

        // Transfer USDT from buyer to contract
        require(USDT.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed.");

        uint256 tokenPrice = HARD_CAP / TOTAL_TOKENS_FOR_SALE; // Price per token in USDT
        uint256 tokenAmount = usdtAmount / tokenPrice; // Calculate token amount to allocate

        contributions[msg.sender] += usdtAmount; // Update user's contribution
        vestedTokens[msg.sender] += tokenAmount; // Add tokens to be vested
        totalSoldTokens += tokenAmount; // Increase total sold tokens

        if (tokensClaimed[msg.sender] == 0) {
            participants.push(msg.sender); // Add participant if it's their first contribution
        }

        totalRaised += usdtAmount; // Update total raised amount

        emit TokensPurchased(msg.sender, tokenAmount); // Emit event for purchase
    }

    // Function to release vested tokens based on vesting schedule
    function releaseTokens() external nonReentrant {
        require(tgeTime > 0, "TGE has not been initiated yet.");
        require(vestedTokens[msg.sender] > 0, "No tokens vested.");

        uint256 tokensAvailable = calculateClaimableTokens(msg.sender);
        require(tokensAvailable > 0, "No tokens available for release.");

        tokensClaimed[msg.sender] += tokensAvailable; // Track claimed tokens
        token.transfer(msg.sender, tokensAvailable); // Transfer tokens to the user

        emit TokensReleased(msg.sender, tokensAvailable); // Emit event for token release
    }

    // Function to calculate claimable tokens based on vesting schedule
    function calculateClaimableTokens(address participant) public view returns (uint256) {
        if (block.timestamp < tgeTime) {
            return 0; // No tokens can be claimed before TGE
        }

        uint256 totalVested = vestedTokens[participant];
        uint256 tgeTokens = (totalVested * TGE_PERCENTAGE) / 100; // 20% at TGE
        uint256 monthsPassed = (block.timestamp - tgeTime) / SECONDS_IN_MONTH; // Months passed since TGE

        if (monthsPassed >= VESTING_MONTHS) {
            // If all months passed, all tokens are claimable
            return totalVested - tokensClaimed[participant];
        }

        uint256 monthlyTokens = ((totalVested - tgeTokens) / VESTING_MONTHS); // Monthly unlocked tokens
        uint256 tokensUnlocked = tgeTokens + (monthlyTokens * monthsPassed); // Total unlocked tokens

        return tokensUnlocked - tokensClaimed[participant]; // Return only the unclaimed tokens
    }

    // Function to end the presale
    function endPresale() external onlyOwner {
        require(currentPhase != SalePhase.ENDED, "Presale already ended.");
        currentPhase = SalePhase.ENDED;
        presaleEndTime = block.timestamp;
    }

    // Updated function to withdraw only unsold tokens
    function withdrawUnsoldTokens() external onlyOwner {
        uint256 unsoldTokens = TOTAL_TOKENS_FOR_SALE - totalSoldTokens; // Calculate unsold tokens
        uint256 contractBalance = token.balanceOf(address(this)); // Get balance of tokens in the contract

        // Withdraw only the unsold tokens
        uint256 tokensToWithdraw = (unsoldTokens <= contractBalance) ? unsoldTokens : contractBalance;
        require(tokensToWithdraw > 0, "No unsold tokens available.");

        token.transfer(owner(), tokensToWithdraw); // Transfer unsold tokens to the owner
    }

    // Function to withdraw stucked ETH in contract
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Function to withdraw raised USDT after the presale ends
    function withdrawFundsInUSDT() external onlyOwner {
        uint256 contractBalance = USDT.balanceOf(address(this)); // Get USDT balance of the contract
        require(USDT.transfer(owner(), contractBalance), "USDT withdrawal failed."); // Transfer USDT to the owner
    }
}