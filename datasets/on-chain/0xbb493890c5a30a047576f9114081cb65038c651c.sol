// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol


pragma solidity >=0.5.0;

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

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol


pragma solidity >=0.5.0;

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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


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

// File: boobies1.sol


pragma solidity ^0.8.26;








    /**
    * THIS CONTRACT IS NOT FULLY AUDITED AND IS STILL IN THE TESTING PHASE.
    * USE AT YOUR OWN RISK.
    * 
    * Twitter: https://twitter.com/5318008eth 
    *
    * TOKENOMICS:
    * Initial Supply: 1,000,000 BOOBS
    *
    * 2.5% of Supply to Dev
    * 2.5% of Supply to Rebase Rewards
    * 25% of Supply to Initial Liquidity Pool
    * 70% of Supply to Tranche Releases
    * 
    * Tranches unlocks at: [4x, 8x, 16x, 32x, 64x, 128x, 256x, 512x, 1024x, 2048x, 4096x, 8192x]
    * Tranche supply sizes are: [5%, 5%, 5%, 5%, 2.5%, 2.5%, 2.5%, 2.5%, 1.25%, 1.25%, 1.25%, 1.25%]
    * Ethereum raised in Tranche sales are immediately paired with unreleased tokens to add liquidity.
    *
    * Token Rebases to maintain peg of 5318008 * 10^y
    *
    * PLEASE READ BEFORE CHANGING ANY ACCOUNTING OR MATH
    * Anytime there is division, there is a risk of numerical instability from rounding errors. In
    * order to minimize this risk, we adhere to the following guidelines:
    * 1) The conversion rate adopted is the number of BaseUnits (BU) that equals 1 PublicUnit (PU).
    *    The inverse rate must not be used—TOTAL_BASE_UNITS is always the numerator and _totalSupply is
    *    always the denominator. (i.e., If you want to convert BU to PU, instead of multiplying by the inverse rate,
    *    you should divide by the normal rate).
    * 2) BaseUnit balances converted into PublicUnits are always rounded down (truncated).
    *
    * We make the following guarantees:
    * - If address 'A' transfers x PublicUnits to address 'B', A's resulting external balance will
    *   be decreased by precisely x PublicUnits, and B's external balance will be precisely
    *   increased by x PublicUnits.
    *
    * We do not guarantee that the sum of all balances equals the result of calling totalSupply().
    * This is because, for any conversion function 'f()' that has non-zero rounding error,
    * f(x0) + f(x1) + ... + f(xn) is not always equal to f(x0 + x1 + ... xn).
    */

contract Boobies is IERC20, ReentrancyGuard, Ownable {
    string private _name = "Boobies";
    string private _symbol = "BOOB";
    uint8 private _decimals = 18;

    // Constants
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_SUPPLY = 1_000_000 * 1e18;
    uint256 private constant TOTAL_BASE_UNITS = MAX_UINT256 - (MAX_UINT256 % INITIAL_SUPPLY); // TOTAL_BASE_UNITS is a multiple of INITIAL_SUPPLY so that _baseUnitsPerPublicUnit is an integer.

    // Token Variables
    uint256 private _totalSupply;
    uint256 private _baseUnitsPerPublicUnit;
    mapping(address => uint256) private _baseUnitBalances;
    mapping(address => mapping(address => uint256)) private _allowedPublicUnits; // This is denominated in PublicUnits (PU), because the BaseUnit-PublicUnit conversion might change before it's fully paid.

    // Rebase Variables
    uint256 public pegValue = 531800800800800800; // $0.5318008
    uint256 public lastRebaseBlock = 0;
    uint256 public maxPriceDifference = 3; // Maximum allowed price difference in percentage (3%)
    bool public launched = false;

    // Tranche Prices
    uint256 public initialPricePerInitialSupply;
    uint256[] public priceMultiples = [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192];
    uint256[12] public trancheSupplyBaseUnits;
    uint256[12] public trancheSoldBaseUnits;

    // Sniper Protection
    bool private _locked;
    bool public sniperProtection = false;
    mapping(address => bool) private _isExcludedFromSniperProtection;
    uint256 public maxTransaction = TOTAL_BASE_UNITS / 100; // 1% Max Transaction Size
    uint256 public maxPriorityFee = 33 * 1e8; // 3.3 gwei

    // Addresses
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;
    IUniswapV2Pair public ethUsdcPair;
    AggregatorV3Interface public ethPriceFeed;

    // Rebase Rewards
    uint256 public rewardMultiplier = 250; // 250% by default (should be around 150% of actual gas spent)
    mapping(address => uint256) public successfulRebaseCalls;

    // Events
    event Rebase(uint256 _totalSupply, uint256 pegValue);
    event LiquidityDeployed(address pair, uint256 tokenAmount, uint256 ethAmount);
    event RewardUnpaid(address indexed recipient, uint256 attemptedTokenAmount);
    event WithdrawalRequested(address indexed requester, uint256 amount, uint256 executeAfter);
    event WithdrawalExecuted(address indexed executor, uint256 amount);

    // Withdrawal Struct
    struct Withdrawal {
        uint256 amount;
        uint256 executeAfter;
    }

    // Timelock Mappings for Withdrawals
    mapping(address => Withdrawal) public pendingETHWithdrawals;
    mapping(address => Withdrawal) public pendingTokenWithdrawals;

    // Price and calculation errors
    error DivisionByZeroError(string context);
    error InvalidPriceError(string priceType);
    error PriceOutsideAcceptableRange();
    error PriceDifferenceOutOfRange();

    // Balance and allowance errors
    error InsufficientBalanceError(string balanceType);
    error InvalidRecipient(address recipient);

    // Input and validation errors
    error InvalidInputError(string inputType);
    error LaunchStatus(bool launched);
    error TranchePriceExceedsCurrentPrice();
    error TrancheSoldOut();

    // Access control errors
    error OnlyOwnerAllowed();
    error ReentrantCall();

    // Transaction limit errors
    error MaxTransactionExceeded();
    error MaxPriorityFeeExceeded();

    // Rebase errors
    error RebaseTimeLock();

    // Miscellaneous errors
    error NoETHToWithdraw();

    // Modifiers
    modifier validRecipient(address to) {
        if (to == address(0)) revert InvalidRecipient(to);
        _;
    }

    modifier trancheReentrant() {
        if (_locked) revert ReentrantCall();
        _locked = true;
        _;
        _locked = false;
    }

    /**
     * @dev Constructor initializes the contract with Uniswap V2 Router, ETH-USDC pair, and Chainlink oracle addresses.
     * 
     * Uniswap V2 Router Addresses:
     * Mainnet: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D (Mainnet Uniswap V2 Router address).
     * Sepolia: 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008 (Sepolia Uniswap V2 Router address).
     * 
     * ETH-USDC Pair Addresses:
     * Mainnet: 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc (ETH/USDC Uniswap V2 Pair on Mainnet).
     * Sepolia: 0x6c1bBfD6330CA6c3f27C29b3a3330dB2B6B0980a (ETH/USDC Uniswap V2 Pair on Sepolia).
     * 
     * USDC Token Address:
     * Mainnet: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 (USDC on Mainnet).
     * Sepolia: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 (USDC on Sepolia).
     *
     * Chainlink Oracle Addresses:
     * Mainnet: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 (ETH/USD on Mainnet).
     * Sepolia: 0x694AA1769357215DE4FAC081bf1f309aDC325306 (ETH/USD on Sepolia).
     */
    constructor(
        address _uniswapV2Router, 
        address _ethPriceFeed, 
        address _ethUsdcPair
    ) Ownable(msg.sender) {
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        ethPriceFeed = AggregatorV3Interface(_ethPriceFeed);
        ethUsdcPair = IUniswapV2Pair(_ethUsdcPair);
        uniswapV2Pair  = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()));

        _totalSupply = INITIAL_SUPPLY;
        _baseUnitBalances[address(this)] = TOTAL_BASE_UNITS;
        _baseUnitsPerPublicUnit = TOTAL_BASE_UNITS / _totalSupply;

        emit Transfer(address(0x0), address(this), _totalSupply);

        setExcludedFromSniperProtection(owner(), true);
        setExcludedFromSniperProtection(address(uniswapV2Router), true);
        setExcludedFromSniperProtection(address(this), true);
        setExcludedFromSniperProtection(address(0xdead), true);
        setExcludedFromSniperProtection(address(uniswapV2Pair), true);
    }

    /**
     * @dev Receive function to accept ETH deposits.
     */
    receive() external payable {
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Sets the maximum allowed price difference to allow for rebase.
     * @dev Only callable by the contract owner.
     * @param _maxPriceDifference The new maximum price difference percentage.
     */
    function setMaxPriceDifference(uint256 _maxPriceDifference) external onlyOwner {
        maxPriceDifference = _maxPriceDifference;
    }

    /**
     * @notice Sets the reward multiplier to adjust the payout of rebase rewards.
     * @dev Only callable by the contract owner.
     * @param newRewardMultiplier The new reward multiplier.
     */
    function setRewardMultiplier(uint256 newRewardMultiplier) external onlyOwner {
        if (newRewardMultiplier > 1000) revert InvalidInputError("Reward multiplier");
        rewardMultiplier = newRewardMultiplier;
    }

    /**
     * @notice Toggles sniper protection on or off.
     * @dev Only callable by the contract owner.
     */
    function toggleSniperProtection() external onlyOwner {
        sniperProtection = !sniperProtection;
    }

    /**
     * @notice Excludes or includes an account from sniper protection.
     * @dev Only callable by the contract owner.
     * @param account The address to exclude or include.
     * @param excluded Boolean indicating exclusion status.
     */
    function setExcludedFromSniperProtection(address account, bool excluded) public onlyOwner {
        _isExcludedFromSniperProtection[account] = excluded;
    }

    /**
     * @notice Requests to withdraw a specified amount of ETH from the contract.
     * @dev Only callable by the contract owner. Initiates a timelock of 24 hours.
     * @param amount The amount of ETH to withdraw.
     */
    function requestWithdrawETH(uint256 amount) external onlyOwner {
        if (amount > address(this).balance) revert NoETHToWithdraw();
        pendingETHWithdrawals[msg.sender] = Withdrawal({
            amount: amount,
            executeAfter: block.timestamp + 24 hours
        });
        emit WithdrawalRequested(msg.sender, amount, block.timestamp + 24 hours);
    }

    /**
     * @notice Executes the ETH withdrawal after the timelock period.
     * @dev Only callable by the contract owner once the timelock has passed.
     */
    function executeWithdrawETH() external onlyOwner nonReentrant {
        Withdrawal memory withdrawal = pendingETHWithdrawals[msg.sender];
        if (withdrawal.amount == 0) revert NoETHToWithdraw();
        if (block.timestamp < withdrawal.executeAfter) revert RebaseTimeLock();

        pendingETHWithdrawals[msg.sender].amount = 0;

        payable(owner()).transfer(withdrawal.amount);
        emit WithdrawalExecuted(msg.sender, withdrawal.amount);
    }

    /**
     * @notice Requests to withdraw a specified amount of tokens.
     * @dev Only callable by the contract owner. Initiates a timelock of 24 hours.
     * @param amount The amount of tokens to withdraw.
     */
    function requestWithdrawTokens(uint256 amount) external onlyOwner {
        if (amount == 0) revert InvalidInputError("Withdraw amount");
        uint256 baseUnitValue = amount * _baseUnitsPerPublicUnit;
        if (_baseUnitBalances[address(this)] < baseUnitValue) revert InsufficientBalanceError("Token balance");

        pendingTokenWithdrawals[msg.sender] = Withdrawal({
            amount: amount,
            executeAfter: block.timestamp + 24 hours
        });
        emit WithdrawalRequested(msg.sender, amount, block.timestamp + 24 hours);
    }

    /**
     * @notice Executes the token withdrawal after the timelock period.
     * @dev Only callable by the contract owner once the timelock has passed.
     */
    function executeWithdrawTokens() external onlyOwner nonReentrant {
        Withdrawal memory withdrawal = pendingTokenWithdrawals[msg.sender];
        if (withdrawal.amount == 0) revert NoETHToWithdraw();
        if (block.timestamp < withdrawal.executeAfter) revert RebaseTimeLock();

        pendingTokenWithdrawals[msg.sender].amount = 0;

        uint256 baseUnitValue = withdrawal.amount * _baseUnitsPerPublicUnit;
        _baseUnitBalances[address(this)] -= baseUnitValue;
        _baseUnitBalances[owner()] += baseUnitValue;

        emit Transfer(address(this), owner(), withdrawal.amount);
        emit WithdrawalExecuted(msg.sender, withdrawal.amount);
    }

    /**
     * @dev Rebalances the supply of PublicUnits to adjust for the current market price, bringing
     * the token supply back in line with its peg. The peg and supply adjustments are made based on the
     * current price of the token in USD, retrieved through external oracles and the Uniswap price feed.
     *
     * Internally adjusts the BaseUnit balance by recalculating the conversion rate between PublicUnits and BaseUnits.
     * The `totalSupply()` will be modified in accordance with the price peg.
     * 
     * In addition, the caller of the `rebase()` function will be paid a bonus in PublicUnits equivalent to 
     * cover gas cost incurred, adjusted by the reward multiplier. The token amount is calculated based 
     * on the ETH cost of gas, and the tokens are transferred to the caller's specified recipient.
     *
     * Emits a `Rebase` event reflecting the new total supply and peg value.
     * Emits a `Transfer` event if the reward payment to the caller is successful.
     * Emits a `RewardUnpaid` event if the contract does not have enough tokens to pay the reward.
     */
    function rebase(address paymentRecipient) external nonReentrant {
        if (block.number < (lastRebaseBlock + 300)) revert RebaseTimeLock();

        if (paymentRecipient == address(0)) {
            paymentRecipient = msg.sender;
        }

        uint256 gasStart = gasleft();

        _rebase();

        successfulRebaseCalls[msg.sender] += 1;

        if (rewardMultiplier > 0) {
            uint256 boobsPriceInETH = getBoobsPriceInETH();
            if (boobsPriceInETH == 0) revert InvalidPriceError("BOOBS/ETH");

            uint256 gasUsed = gasStart - gasleft();
            uint256 gasCost = gasUsed * block.basefee;
            uint256 payoutInETH = ((gasCost + (1.5 * 1e9)) * rewardMultiplier) / 100;

            uint256 tokenAmount = (payoutInETH * 1e18) / boobsPriceInETH;
            uint256 baseUnitValue = tokenAmount * _baseUnitsPerPublicUnit;

            if (_baseUnitBalances[address(this)] >= baseUnitValue) {
                _baseUnitBalances[address(this)] -= baseUnitValue;
                _baseUnitBalances[paymentRecipient] += baseUnitValue;

                emit Transfer(address(this), paymentRecipient, tokenAmount);
            } else {
                emit RewardUnpaid(paymentRecipient, tokenAmount);
            }
        }
    }

    /**
     * @dev Internal function that performs the rebase operation, adjusting the supply of PublicUnits 
     * based on the current price in USD and the target peg value.
     *
     * The function fetches the price of ETH from both Chainlink and Uniswap, ensuring that the price
     * discrepancy is within the acceptable range. Then, it calculates the new rebase factor and adjusts
     * the total supply of PublicUnits accordingly.
     * 
     * If the total supply has grown too large or too small, it adjusts the peg value by a factor of 10
     * in either direction. After adjusting the supply, the function syncs the Uniswap liquidity pair.
     * 
     * The `lastRebaseBlock` is updated to the current block after a successful rebase.
     *
     * Emits a `Rebase` event reflecting the new total supply and peg value.
     * 
     * return The updated supply of PublicUnits after the rebase.
     */
    function _rebase() internal {
        uint256 ethPriceFromChainlink = getETHPriceFromChainlink();
        uint256 ethPriceFromUniswap = getETHPriceFromUniswap();

        if (ethPriceFromChainlink == 0 || ethPriceFromUniswap == 0) revert InvalidPriceError("ETH");
        if (!isPriceDifferenceAcceptable(ethPriceFromUniswap, ethPriceFromChainlink)) revert PriceDifferenceOutOfRange();

        uint256 boobsPriceInUSD = getBoobsPriceInUSD(ethPriceFromUniswap);
        if (boobsPriceInUSD == 0) revert InvalidPriceError("BOOBS/USD");

        uint256 rebaseFactor = (boobsPriceInUSD * 1e18) / pegValue;
        uint256 supplyAdjustment = (rebaseFactor * _totalSupply) / 1e18;

        if (supplyAdjustment > (12_000_000 * 1e18)) {
            supplyAdjustment = supplyAdjustment / 10;
            pegValue = pegValue * 10;
        } else if (supplyAdjustment < (800_000 * 1e18)) {
            supplyAdjustment = supplyAdjustment * 10;
            pegValue = pegValue / 10;
        }

        _totalSupply = supplyAdjustment;
        _baseUnitsPerPublicUnit = TOTAL_BASE_UNITS / _totalSupply;
        lastRebaseBlock = block.number;

        emit Rebase(_totalSupply, pegValue);

        IUniswapV2Pair(address(uniswapV2Pair)).sync();
    }

    /**
     * @dev Retrieves the current price of BOOBS in USD based on Uniswap prices.
     * 
     * @param ethPriceFromUniswap The price of ETH from Uniswap.
     * @return The price of BOOBS in USD.
     */
    function getBoobsPriceInUSD(uint256 ethPriceFromUniswap) public view returns (uint256) {
        uint256 boobsPriceInETH = getBoobsPriceInETH();
        if (boobsPriceInETH == 0 || ethPriceFromUniswap == 0) revert InvalidPriceError("BOOBS/ETH or ETH/USD");

        return (boobsPriceInETH * ethPriceFromUniswap) / 1e18;
    }

    /**
     * @dev Retrieves the current price of BOOBS in ETH based on the Uniswap liquidity pool.
     * 
     * @return The price of BOOBS in ETH.
     */
    function getBoobsPriceInETH() public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(address(uniswapV2Pair));
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        if (reserve0 == 0 || reserve1 == 0) revert DivisionByZeroError("BOOBS/ETH reserves");

        if (pair.token0() == address(this)) {
            return uint256(reserve1) * 1e18 / uint256(reserve0);
        } else {
            return uint256(reserve0) * 1e18 / uint256(reserve1);
        }
    }

    /**
     * @dev Retrieves the current price of ETH in USD from Uniswap's ETH/USDC pool.
     * 
     * @return The price of ETH in USD.
     */
    function getETHPriceFromUniswap() public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(ethUsdcPair);
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        if (reserve0 == 0 || reserve1 == 0) revert DivisionByZeroError("ETH/USDC reserves");

        if (pair.token0() == uniswapV2Router.WETH()) {
            return uint256(reserve1) * 1e30 / uint256(reserve0);
        } else {
            return uint256(reserve0) * 1e30 / uint256(reserve1);
        }
    }

    /**
     * @dev Retrieves the current price of ETH in USD from Chainlink's price feed.
     * 
     * @return The price of ETH in USD (18 decimal places).
     */
    function getETHPriceFromChainlink() public view returns (uint256) {
        (,int256 price,,,) = ethPriceFeed.latestRoundData();
        if (price <= 0) revert InvalidPriceError("ETH from Chainlink");
        return uint256(price) * 1e10;
    }

    /**
     * @dev Checks if the price difference between Uniswap and Chainlink is within the acceptable range.
     * 
     * @param uniswapPrice The price of ETH from Uniswap.
     * @param chainlinkPrice The price of ETH from Chainlink.
     * @return True if the price difference is acceptable, false otherwise.
     */
    function isPriceDifferenceAcceptable(uint256 uniswapPrice, uint256 chainlinkPrice) public view returns (bool) {
        uint256 difference = uniswapPrice > chainlinkPrice ? uniswapPrice - chainlinkPrice : chainlinkPrice - uniswapPrice;
        uint256 percentageDifference = (difference * 100) / ((uniswapPrice + chainlinkPrice) / 2);
        return percentageDifference <= maxPriceDifference;
    }

    /**
     * @dev Deploys initial liquidity to Uniswap, sets up tranche supplies, and initializes key contract parameters.
     * This function can only be called once by the owner when the contract is unlaunched.
     * It requires ETH to be sent along with the transaction to provide initial liquidity.
     */
    function deployAndSendLiquidity() external payable onlyOwner {
        if (launched) revert LaunchStatus(launched);
        if (msg.value == 0) revert InsufficientBalanceError("ETH");
        

        uint256 ethAmount = msg.value;
        uint256 tokenAmount = _totalSupply;

        uint256 devTokenAmount = (tokenAmount * 25) / 1000; // 2.5%
        uint256 vaultTokenAmount = (tokenAmount * 725) / 1000; // 72.5%
        uint256 tokensToLP = tokenAmount - devTokenAmount - vaultTokenAmount; // 25%

        uint256 baseUnitValueDev = devTokenAmount * _baseUnitsPerPublicUnit;
        _baseUnitBalances[address(this)] -= baseUnitValueDev;
        _baseUnitBalances[owner()] += baseUnitValueDev;
        emit Transfer(address(this), owner(), devTokenAmount);

        if (balanceOf(address(this)) < tokensToLP) revert InsufficientBalanceError("Token balance for liquidity");

        _allowedPublicUnits[address(this)][address(uniswapV2Router)] = tokensToLP;

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokensToLP,
            0,
            0,
            owner(),
            block.timestamp
        );

        // Record initial price per initial supply
        initialPricePerInitialSupply = (ethAmount * 1e18) / tokensToLP;

        // Tranche Sizes (4 tranches of 5%, 4 tranches of 2.5%, and 4 tranches of 1.25%)
        uint256 trancheOne = (TOTAL_BASE_UNITS / 10000) * 500;
        uint256 trancheTwo = (TOTAL_BASE_UNITS / 10000) * 250;
        uint256 trancheThree = (TOTAL_BASE_UNITS / 10000) * 125;

        for (uint256 i = 0; i < priceMultiples.length; i++) {
            if (i < 4) {
                trancheSupplyBaseUnits[i] = trancheOne;
            } else if (i < 8) {
                trancheSupplyBaseUnits[i] = trancheTwo;
            } else {
                trancheSupplyBaseUnits[i] = trancheThree;
            }
        }

        launched = true;

        emit LiquidityDeployed(address(uniswapV2Pair), tokensToLP, ethAmount);
    }

    /**
     * @dev Allows users to purchase tokens from a specific tranche.
     * The tranche must be available for purchase (current price >= tranche price).
     * The transaction will be rejected if the current price differs from the tranche price by more than the specified percentage.
     * Excess ETH is refunded, and purchased tokens are added to Uniswap liquidity.
     * @param trancheIndex The index of the tranche to purchase from.
     * @param maxPriceDifferencePercent The maximum allowed percentage difference between current price and tranche price (must be greater than 1).
     */
    function buyTranche(uint256 trancheIndex, uint256 maxPriceDifferencePercent) external payable trancheReentrant {
        if (msg.value == 0) revert InsufficientBalanceError("ETH sent");
        if (!launched) revert LaunchStatus(launched);
        if (trancheIndex >= priceMultiples.length) revert InvalidInputError("Tranche index");
        if (maxPriceDifferencePercent < 100) revert InvalidInputError("Max price difference");

        uint256 currentPrice = getBoobsPriceInETH();
        uint256 tranchePricePerInitialSupply = initialPricePerInitialSupply * priceMultiples[trancheIndex];
        uint256 tranchePrice = (tranchePricePerInitialSupply * INITIAL_SUPPLY) / totalSupply();

        if (currentPrice < tranchePrice) revert TranchePriceExceedsCurrentPrice();
        if (currentPrice > (tranchePrice + (tranchePrice * maxPriceDifferencePercent / 10000))) revert PriceOutsideAcceptableRange();

        uint256 remainingBaseUnits = trancheSupplyBaseUnits[trancheIndex] - trancheSoldBaseUnits[trancheIndex];
        if (remainingBaseUnits == 0) revert TrancheSoldOut();

        uint256 tokensToBuy = (msg.value * 1e18) / currentPrice;

        uint256 baseUnitsToBuy = tokensToBuy * _baseUnitsPerPublicUnit;
        if (baseUnitsToBuy > remainingBaseUnits) {
            baseUnitsToBuy = remainingBaseUnits;
            tokensToBuy = baseUnitsToBuy / _baseUnitsPerPublicUnit;
        }

        uint256 ethToUse = (tokensToBuy * currentPrice) / 1e18;

        if (_baseUnitBalances[address(this)] < baseUnitsToBuy) revert InsufficientBalanceError("Token balance");

        _baseUnitBalances[address(this)] -= baseUnitsToBuy;
        _baseUnitBalances[msg.sender] += baseUnitsToBuy;

        trancheSoldBaseUnits[trancheIndex] += baseUnitsToBuy;

        if (ethToUse < msg.value) {
            payable(msg.sender).transfer(msg.value - ethToUse);
        }

        _allowedPublicUnits[address(this)][address(uniswapV2Router)] = tokensToBuy;

        uint256 minTokens = (tokensToBuy * 95) / 100; // 5% slippage tolerance
        uint256 minETH = (ethToUse * 95) / 100; // 5% slippage tolerance

        uniswapV2Router.addLiquidityETH{value: ethToUse}(
            address(this),
            tokensToBuy,
            minTokens,
            minETH,
            owner(),
            block.timestamp
        );

        emit Transfer(address(this), msg.sender, tokensToBuy);
    }
    
    /**
     * @dev Returns an array of boolean values indicating which tranches are currently available for purchase.
     * A tranche is available if its price is less than or equal to the current market price
     * and it still has tokens available for sale.
     * @return An array of boolean values where true indicates the tranche is available.
     */
    function getAvailableTranches() public view returns (bool[] memory) {
        bool[] memory availableTranches = new bool[](priceMultiples.length);
        uint256 currentPricePerInitialSupply = (getBoobsPriceInETH() * totalSupply()) / INITIAL_SUPPLY;
        
        for (uint256 i = 0; i < priceMultiples.length; i++) {
            uint256 tranchePricePerInitialSupply = initialPricePerInitialSupply * priceMultiples[i];
            if (currentPricePerInitialSupply >= tranchePricePerInitialSupply &&
                trancheSoldBaseUnits[i] < trancheSupplyBaseUnits[i]) {
                availableTranches[i] = true;
            } else {
                availableTranches[i] = false;
            }
        }
        
        return availableTranches;
    }

    /**
     * @dev Calculates the percentage difference between the current price and the tranche price.
     * @param trancheIndex The index of the tranche to compare against.
     * @return The percentage difference, expressed as a number where 10000 represents 100%.
     * Returns 0 if the current price is lower than or equal to the tranche price.
     */
    function getCurrentPriceDifferencePercent(uint256 trancheIndex) public view returns (uint256) {
        if (trancheIndex >= priceMultiples.length) revert InvalidInputError("Tranche index");
        
        uint256 currentPrice = getBoobsPriceInETH();
        uint256 tranchePricePerInitialSupply = initialPricePerInitialSupply * priceMultiples[trancheIndex];
        uint256 tranchePrice = (tranchePricePerInitialSupply * INITIAL_SUPPLY) / totalSupply();
        
        if (currentPrice <= tranchePrice) {
            return 0;
        }
        
        uint256 priceDifference = currentPrice - tranchePrice;
        uint256 percentageDifference = (priceDifference * 10000) / tranchePrice;
        
        return percentageDifference;
    }

    /**
     * @dev Returns the total supply of PublicUnits in the system.
     * This value is dynamically calculated based on the number of BaseUnits in existence
     * and the conversion rate from BaseUnits to PublicUnits.
     *
     * @return The total number of PublicUnits.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the number of PublicUnits held by a specific address.
     * This function performs an internal conversion from BaseUnits to PublicUnits.
     * 
     * @param who The address whose PublicUnit balance is being queried.
     * @return The number of PublicUnits held by the specified address.
     */
    function balanceOf(address who) public view override returns (uint256) {
        return _baseUnitBalances[who] / _baseUnitsPerPublicUnit;
    }

    /**
     * @dev Returns the raw balance in BaseUnits for a specific address.
     * This function does not convert BaseUnits to PublicUnits and is used for internal calculations.
     * 
     * @param who The address whose BaseUnit balance is being queried.
     * @return The raw balance of BaseUnits held by the specified address.
     */
    function scaledBalanceOf(address who) public view returns (uint256) {
        return _baseUnitBalances[who];
    }

    /**
     * @dev Returns the total number of BaseUnits in the system.
     * This function is used for internal accounting and is not directly tied to the PublicUnit supply.
     * 
     * @return The total number of BaseUnits.
     */
    function scaledTotalSupply() public pure returns (uint256) {
        return TOTAL_BASE_UNITS;
    }

    /**
     * @dev Transfers PublicUnits from the caller's account to the recipient's account.
     * The actual transfer is done by adjusting the BaseUnit balances internally. The public-facing
     * balance in PublicUnits is updated accordingly by the conversion between BaseUnits and PublicUnits.
     *
     * @param to The address to transfer PublicUnits to.
     * @param value The amount of PublicUnits to be transferred.
     * @return True if the transfer was successful.
     */
    function transfer(address to, uint256 value) public override validRecipient(to) nonReentrant returns (bool) {
        uint256 baseUnitValue = value * _baseUnitsPerPublicUnit;
        
        if (sniperProtection && !_isExcludedFromSniperProtection[to]){
            if (baseUnitValue > maxTransaction) revert MaxTransactionExceeded();
            if ((tx.gasprice - block.basefee) > maxPriorityFee) revert MaxPriorityFeeExceeded();
        }

        _baseUnitBalances[msg.sender] -= baseUnitValue;
        _baseUnitBalances[to] += baseUnitValue;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfers the entire PublicUnit balance from the caller's account to the specified recipient.
     * The PublicUnits are converted from BaseUnits before performing the transfer.
     * 
     * The caller's BaseUnit balance is set to zero after the transfer.
     *
     * Emits a `Transfer` event.
     * 
     * @param to The recipient of the entire PublicUnit balance.
     * @return True if the transfer is successful.
     */
    function transferAll(address to) public validRecipient(to) nonReentrant returns (bool) {
        uint256 baseUnitValue = _baseUnitBalances[msg.sender];
        uint256 value = baseUnitValue / _baseUnitsPerPublicUnit;

        if (sniperProtection && !_isExcludedFromSniperProtection[to]){
            if (baseUnitValue > maxTransaction) revert MaxTransactionExceeded();
            if ((tx.gasprice - block.basefee) > maxPriorityFee) revert MaxPriorityFeeExceeded();
        }

        delete _baseUnitBalances[msg.sender];
        _baseUnitBalances[to] += baseUnitValue;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Checks the amount of PublicUnits that an owner has allowed a spender to use on their behalf.
     * This function is part of the ERC20 standard and is used to manage allowances for token transfers.
     *
     * The allowance is denominated in PublicUnits, not BaseUnits, and will always return the remaining
     * amount of PublicUnits the spender can transfer.
     *
     * @param owner_ The address that owns the tokens.
     * @param spender The address that is allowed to spend the tokens.
     * @return The remaining number of PublicUnits that the spender can transfer.
     */
    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowedPublicUnits[owner_][spender];
    }

    /**
     * @dev Transfers PublicUnits from one account (`from`) to another (`to`) on behalf of the
     * account holder, provided that the caller has been approved to spend at least `value` PublicUnits.
     * This function adjusts BaseUnit balances internally.
     *
     * @param from The address from which to transfer PublicUnits.
     * @param to The address to which PublicUnits will be transferred.
     * @param value The amount of PublicUnits to be transferred.
     * @return True if the transfer is successful.
     */
    function transferFrom(address from, address to, uint256 value) public override nonReentrant returns (bool) {
        if (_allowedPublicUnits[from][msg.sender] < value) revert InsufficientBalanceError("Allowance");
        _allowedPublicUnits[from][msg.sender] -= value;

        uint256 baseUnitValue = value * _baseUnitsPerPublicUnit;

        if (sniperProtection && !_isExcludedFromSniperProtection[to]){
            if (baseUnitValue > maxTransaction) revert MaxTransactionExceeded();
            if ((tx.gasprice - block.basefee) > maxPriorityFee) revert MaxPriorityFeeExceeded();
        }

        if (_baseUnitBalances[from] < baseUnitValue) revert InsufficientBalanceError("Sender");

        _baseUnitBalances[from] -= baseUnitValue;
        _baseUnitBalances[to] += baseUnitValue;

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Transfers the entire PublicUnit balance from one account to another, using the allowance mechanism.
     * This function transfers all the BaseUnits held by the sender to the recipient and adjusts the 
     * allowance accordingly.
     *
     * Emits a `Transfer` event.
     * 
     * @param from The account from which PublicUnits are being transferred.
     * @param to The recipient of the PublicUnits.
     * @return True if the transfer is successful.
     */
    function transferAllFrom(address from, address to) public validRecipient(to) nonReentrant returns (bool) {
        uint256 senderBalance = balanceOf(from);
        if (_allowedPublicUnits[from][msg.sender] < senderBalance) revert InsufficientBalanceError("Allowance");

        uint256 baseUnitValue = _baseUnitBalances[from];
        uint256 value = baseUnitValue / _baseUnitsPerPublicUnit;

        if (sniperProtection && !_isExcludedFromSniperProtection[to]){
            if (baseUnitValue > maxTransaction) revert MaxTransactionExceeded();
            if ((tx.gasprice - block.basefee) > maxPriorityFee) revert MaxPriorityFeeExceeded();
        }

        _allowedPublicUnits[from][msg.sender] -= value;

        delete _baseUnitBalances[from];
        _baseUnitBalances[to] += baseUnitValue;

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of PublicUnits on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance—if they are both greater than zero—if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the PublicUnits.
     * @param value The amount of PublicUnits to be spent.
     * @return True if the approval was successful.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        _allowedPublicUnits[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Increases the allowance that `spender` has over the caller's PublicUnits.
     * This is safer than using `approve()` because it prevents the double-spend vulnerability.
     *
     * @param spender The address to which the allowance will be granted.
     * @param addedValue The amount of PublicUnits to add to the allowance.
     * @return True if the operation was successful.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _allowedPublicUnits[msg.sender][spender] += addedValue;

        emit Approval(msg.sender, spender, _allowedPublicUnits[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decreases the allowance that `spender` has over the caller's PublicUnits.
     * This is safer than using `approve()` because it prevents the double-spend vulnerability.
     *
     * @param spender The address for which to decrease the allowance.
     * @param subtractedValue The amount of PublicUnits to subtract from the allowance.
     * @return True if the operation was successful.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 oldValue = _allowedPublicUnits[msg.sender][spender];
        _allowedPublicUnits[msg.sender][spender] = (subtractedValue >= oldValue)
            ? 0
            : oldValue - subtractedValue;

        emit Approval(msg.sender, spender, _allowedPublicUnits[msg.sender][spender]);
        return true;
    }
}