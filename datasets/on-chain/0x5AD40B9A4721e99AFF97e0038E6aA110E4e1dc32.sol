//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata, ReentrancyGuard {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapSwapRouterV2 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

abstract contract NoDelegateCall {
    /// @dev The original address of this contract
    address private immutable original;

    constructor() {
        // Immutables are computed in the init code of the contract, and then inlined into the deployed bytecode.
        // In other words, this variable won't change when it's checked at runtime.
        original = address(this);
    }

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function checkNotDelegateCall() private view {
        require(address(this) == original);
    }

    /// @notice Prevents delegatecall into the modified method
    modifier noDelegateCall() {
        checkNotDelegateCall();
        _;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract WINWIN is ERC20, Ownable, NoDelegateCall {
    uint256 public constant ATTEMPT_VALUE = 0.02 ether;
    IUniswapSwapRouterV2 private constant uniswapRouter =
        IUniswapSwapRouterV2(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
        );

    uint256 public constant TOKEN_REWARD_PER_WIN = 1_000 * 10**18;
    uint256 public constant WIN_RATE_PERCENTAGE = 15; // Percentage chance to win
    uint256 public constant MAX_WINS_PER_BLOCK = 5; // Maximum wins per block

    mapping(address => uint256) public rewardsByAddress; // Amounts won by each address
    mapping(address => uint256) public attemptsByAddress; // Number of attempts made by each address

    uint256 public totalWins = 0; // Total wins across all attempts
    uint256 public totalAttempts = 0; // Total attempts made
    uint256 public maxAttemptsAllowed = 1000; // Maximum attempts allowed
    uint256 public addressCount = 0;

    bool public isAttemptEnabled = false; // Indicates if attempts are enabled
    bool public isClaimEnabled = false; // Indicates if claims are enabled
    bool public isTradingOpen = false; // Indicates if trading is open

    uint256 private lastAttemptBlockNumber = 0; // Last block where an attempt was made
    uint256 private currentBlockWinCount = 0; // Count of wins in the current block
    mapping(uint256 => uint256) public attemptCountsPerBlock; // Number of attempts per block
    mapping(uint256 => mapping(uint256 => address))
        public attemptsByBlockAndIndex; // Attempts per block by address

    mapping(address => address) public referralByAddress; // Referral addresses for invite codes
    mapping(address => uint256) public inviteCountByAddress; // Mapping to keep track of the number of invites for each address.
    mapping(string => address) public inviteCodeToAddressMapping; // Mapping invite codes to addresses
    mapping(address => string) public addressToInviteCodeMapping; // Mapping addresses to their invite codes
    mapping(address => bool) public hasGeneratedInviteCode; // Check if an invite code has been generated
    mapping(address => uint256) public attemptedInvitationsCount; // Count of attempts made through invites
    mapping(address => uint256) public claimedRefundCount; // Count of refunds claimed through invites

    mapping(address => bool) private isLiquidityPair; // Check if an address is a Uniswap V2 pair
    address private uniswapLiquidityPairAddress; // Address of the Uniswap V2 pair
    mapping(address => bool) private isExcludedFromFees; // Check if an address is excluded from fees

    constructor() ERC20("WINWIN", "WINWIN") {
        _mint(address(this), 2_000_000 * 10**18);
        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[address(this)] = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (!isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            if (isLiquidityPair[from] || isLiquidityPair[to]) {
                require(isTradingOpen, "TRADE_NOT_ENABLE!");
            }
        }
        super._transfer(from, to, amount);
    }

    function toggleOpenTrading() external onlyOwner {
        isTradingOpen = true;
    }

    function openTrading() external onlyOwner {
        _approve(address(this), address(uniswapRouter), totalSupply());

        uniswapLiquidityPairAddress = IUniswapV2Factory(uniswapRouter.factory())
            .createPair(address(this), uniswapRouter.WETH());

        isLiquidityPair[address(uniswapLiquidityPairAddress)] = true;
        IERC20(uniswapLiquidityPairAddress).approve(
            address(uniswapRouter),
            type(uint256).max
        );

        require(
            address(this).balance > 0,
            "No balance available to add liquidity!"
        );

        uniswapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            totalSupply() / 2,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function openClaim() external onlyOwner {
        require(!isClaimEnabled, "Claim has already been opened!");
        isClaimEnabled = true;
    }

    function claimRewards() external {
        require(isClaimEnabled, "Claim is not open yet!");
        require(
            rewardsByAddress[msg.sender] > 0,
            "No rewards available to claim for this address!"
        );

        super._transfer(
            address(this),
            msg.sender,
            rewardsByAddress[msg.sender] * TOKEN_REWARD_PER_WIN
        );

        rewardsByAddress[msg.sender] = 0;
    }

    function generateInviteCode() public {
        require(
            !hasGeneratedInviteCode[msg.sender],
            "Invite code has already been generated for this address!"
        );

        string memory inviteCode = _generateInviteCode(msg.sender);

        require(
            inviteCodeToAddressMapping[inviteCode] == address(0),
            "This invite code already exists!"
        );

        inviteCodeToAddressMapping[inviteCode] = msg.sender;
        addressToInviteCodeMapping[msg.sender] = inviteCode;

        hasGeneratedInviteCode[msg.sender] = true;
    }

    function getInviteCode() external view returns (string memory) {
        require(
            hasGeneratedInviteCode[msg.sender],
            "No invite code generated for this address!"
        );

        return addressToInviteCodeMapping[msg.sender];
    }

    receive() external payable {}

    function withdrawRewards() external nonReentrant noDelegateCall {
        require(isTradingOpen, "Trading is not open yet!");

        require(
            attemptedInvitationsCount[msg.sender] >
                claimedRefundCount[msg.sender],
            "Insufficient rewards: You have no rewards available to withdraw."
        );

        uint256 additionalInvitations = attemptedInvitationsCount[msg.sender];

        uint256 rewardPercentage = calculateRewardPercentage(
            additionalInvitations
        );

        uint256 refundAmount = (ATTEMPT_VALUE *
            additionalInvitations *
            rewardPercentage) / 100;

        payable(msg.sender).transfer(refundAmount);

        claimedRefundCount[msg.sender] = attemptedInvitationsCount[msg.sender];
    }

    function calculateRewardPercentage(uint256 count)
        internal
        pure
        returns (uint256)
    {
        if (count >= 900) return 10;

        return count / 100 + 1;
    }

    function attempt(string memory inviteCode)
        external
        payable
        noDelegateCall
        nonReentrant
    {
        require(isAttemptEnabled, "Attempts have not started yet!");

        require(!isTradingOpen, "Trading is already open!");

        require(
            totalWins + 1 <= maxAttemptsAllowed,
            "Insufficient seed balance left for new attempt!"
        );

        require(
            msg.value == ATTEMPT_VALUE,
            "Incorrect attempt value provided!"
        );

        if (block.number - lastAttemptBlockNumber >= 1) {
            processLastBlock();
        }

        if (attemptsByAddress[msg.sender] == 0) {
            addressCount++;
        }

        if (bytes(inviteCode).length > 0) {
            address preInviter = referralByAddress[msg.sender];
            address inviter = inviteCodeToAddressMapping[inviteCode];

            if (inviter != address(0) && inviter != msg.sender) {
                if (preInviter != inviter) {
                    if (preInviter != address(0)) {
                        inviteCountByAddress[preInviter]--;
                    }
                    referralByAddress[msg.sender] = inviter;
                    inviteCountByAddress[inviter]++;
                }
                attemptedInvitationsCount[inviter]++;
            }
        }

        totalAttempts++;

        attemptsByAddress[msg.sender]++;

        attemptCountsPerBlock[block.number]++;

        attemptsByBlockAndIndex[block.number][
            attemptCountsPerBlock[block.number]
        ] = msg.sender;

        // used for notify, actual token needs to claim after mint
        _mint(msg.sender, 0);
    }

    function processLastBlock() internal {
        currentBlockWinCount = 0;

        for (
            uint256 i = 1;
            i <= attemptCountsPerBlock[lastAttemptBlockNumber];
            i++
        ) {
            address attemptAddr = attemptsByBlockAndIndex[
                lastAttemptBlockNumber
            ][i];

            if (currentBlockWinCount >= MAX_WINS_PER_BLOCK) break;

            if (attemptAddr == address(0)) continue;

            if (getRandomBoolean()) {
                currentBlockWinCount++;
                totalWins++;
                rewardsByAddress[attemptAddr] += 1;
            }
        }

        lastAttemptBlockNumber = block.number;
    }

    function startAttempt() external onlyOwner {
        require(!isAttemptEnabled, "Attempts have already started!");

        isAttemptEnabled = true;

        lastAttemptBlockNumber = block.number;
    }

    function getRandomBoolean() public view returns (bool) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    block.number,
                    gasleft(),
                    msg.sender,
                    blockhash(block.number - 1)
                )
            )
        );

        uint256 probability = randomNumber % 100;

        return probability < WIN_RATE_PERCENTAGE;
    }

    function _generateInviteCode(address addr)
        public
        view
        returns (string memory)
    {
        bytes memory code = new bytes(4);
        bytes memory addrBytes = abi.encodePacked(addr);

        for (uint256 i = 0; i < 4; i++) {
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.timestamp, addrBytes, i))
            ) % 36;

            if (randomIndex < 10) {
                code[i] = bytes1(uint8(randomIndex) + 48);
            } else {
                code[i] = bytes1(uint8(randomIndex - 10) + 65);
            }
        }
        return string(code);
    }

    // Function to emergency rescue ETH from the contract in case of open tradig fail
    function rescueEmergency() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH in the contract");
        payable(msg.sender).transfer(address(this).balance);
    }
}