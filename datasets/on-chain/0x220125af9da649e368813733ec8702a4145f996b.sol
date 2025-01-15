// SPDX-License-Identifier: MIT
//  __      __       .__                                  __              _____                     ____   ____            .__   __
// /  \    /  \ ____ |  |   ____  ____   _____   ____   _/  |_  ____     /     \   ____   ____   ___\   \ /   /____   __ __|  |_/  |_
// \   \/\/   // __ \|  | _/ ___\/  _ \ /     \_/ __ \  \   __\/  _ \   /  \ /  \ /  _ \ /  _ \ /    \   Y   /\__  \ |  |  \  |\   __\
//  \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/   |  | (  <_> ) /    Y    (  <_> |  <_> )   |  \     /  / __ \|  |  /  |_|  |
//   \__/\  /  \___  >____/\___  >____/|__|_|  /\___  >  |__|  \____/  \____|__  /\____/ \____/|___|  /\___/  (____  /____/|____/__|
//        \/       \/          \/            \/     \/                         \/                   \/             \/
//        /\
//       /  \
//      /____\
//     /\    /\
//    /  \  /  \
//   /____\/____\
//   \    /\    /
//    \  /  \  /
//     \/____\/
// https://MoonVault.io
//
// MoonVault is a comprehensive blockchain platform, driven by the $VAULT Token.
//
// $VAULT & the S.T.A.R.R. Engine:
//
// Powered by S.T.A.R.R. (Self-Triggered Automatic Regeneration and Redistribution),
// $VAULT delivers dynamic tokenomics based on randomized blockchain data.
// On each transfer, the S.T.A.R.R. Engine rotates to deliver a combination of auto-buybacks with $VAULT reflections,
// decentralized liquidity infusions with non-dilutive LP rewards, token burns, and direct rewards in $ETH.
//
// The S.T.A.R.R. Engine ensures balanced distribution and gas efficiency while optimizing
// transaction cost-effectiveness for users through dynamic rotating functionality.
//
// Decentralized Liquidity Infusions:
// Initial liquidity for $VAULT is burned; no new LP tokens are made during infusions. These infusions auto-grow the liquidity
// pool in a fully decentralized manner while mitigating visible sells, lowering price impact, and providing
// direct non-dilutive LP rewards.
//
// Dual Rewards & Buyback Mechanism:
// Transfer Fees convert to $ETH on Sell Transactions. The S.T.A.R.R. Engine rotates rewards between buying back $VAULT and reflecting it to holders
// or distributing $WETH dividends. Claiming rewards is allowed every 15 minutes since last claim, and rewards claim automatically on buy, sell, or transfer. 
//
// Automated Burns:
// $VAULT's deflationary mechanism continuously reduces the total supply, balancing price fluctuations from
// token reserves added during liquidity infusions. This produces growing liquidity with a diminishing supply,
// creating increasingly resilient depth alongside appreciating price.
//
// MoonVault was conceived as an homage to both the fallen giants of the past and the bright stars of the future,
// whose light we've yet to see. The $VAULT token is designed to foster decentralized engagement that transcends borders,
// and MoonVault serves as a way station for fellow space travelers to connect and safely plot their course to the stars.
//
// We invite you to join a voyage through the evolving landscape of the new digital economy and find kinship
// among those who believe the Moon is not the final destination, but rather the beginning of the journey.


pragma solidity ^0.8.16;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20 is Context, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);

    function withdrawnDividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);

    function accumulativeDividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);

    function distributeDividends() external payable;

    function withdrawDividend(address _rewardToken) external;

    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount,
        address rewardToken
    );
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

contract DividendPayingToken is
    DividendPayingTokenInterface,
    DividendPayingTokenOptionalInterface,
    Ownable
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 internal constant magnitude = 2**128;

    mapping(address => uint256) internal magnifiedDividendPerShare;
    address[] public rewardTokens;
    address public nextRewardToken;
    uint256 public rewardTokenCounter;

    address public WETHAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public tokenAddress;
    IWETH private wethObj = IWETH(WETHAddress);

    IUniswapV2Router02 public immutable uniswapV2Router;

    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;
    mapping(address => mapping(address => uint256)) internal withdrawnDividends;

    mapping(address => uint256) public holderBalance;
    uint256 public totalBalance;

    mapping(address => uint256) public totalDividendsDistributed;

    event BuyBack(
        address indexed sender,
        uint256 amountSent,
        uint256 amountReceived
    );

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Router = _uniswapV2Router;

        rewardTokens.push(WETHAddress);

        nextRewardToken = rewardTokens[0];
    }

    receive() external payable {
        distributeDividends();
    }

    function distributeDividends() public payable override {
        require(totalBalance > 0);

        if (nextRewardToken == WETHAddress) {
            uint256 amount = msg.value;
            wethObj.deposit{value: amount}();
            if (amount > 0) {
                magnifiedDividendPerShare[
                    nextRewardToken
                ] = magnifiedDividendPerShare[nextRewardToken].add(
                    (amount).mul(magnitude) / totalBalance
                );
            }

            emit DividendsDistributed(msg.sender, amount, nextRewardToken);
            totalDividendsDistributed[
                nextRewardToken
            ] = totalDividendsDistributed[nextRewardToken].add(amount);
        } else if (nextRewardToken == tokenAddress) {
            uint256 initialBalance = IERC20(nextRewardToken).balanceOf(
                address(this)
            );
            buyTokens(msg.value, nextRewardToken);
            uint256 newBalance = IERC20(nextRewardToken)
                .balanceOf(address(this))
                .sub(initialBalance);
            emit BuyBack(msg.sender, msg.value, newBalance);

            if (newBalance > 0) {
                magnifiedDividendPerShare[
                    nextRewardToken
                ] = magnifiedDividendPerShare[nextRewardToken].add(
                    (newBalance).mul(magnitude) / totalBalance
                );

                totalDividendsDistributed[
                    nextRewardToken
                ] = totalDividendsDistributed[nextRewardToken].add(newBalance);
            }
        }

        rewardTokenCounter = rewardTokenCounter == rewardTokens.length - 1
            ? 0
            : rewardTokenCounter + 1;
        nextRewardToken = rewardTokens[rewardTokenCounter];
    }

    function buyTokens(uint256 amountInWei, address rewardToken) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = rewardToken;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amountInWei
        }(0, path, address(this), block.timestamp + 3600);
    }

    function withdrawDividend(address _rewardToken) external virtual override {
        _withdrawDividendOfUser(payable(msg.sender), _rewardToken);
    }

    function _withdrawDividendOfUser(address payable user, address _rewardToken)
        internal
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(
            user,
            _rewardToken
        );
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user][_rewardToken] = withdrawnDividends[user][
                _rewardToken
            ].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            IERC20(_rewardToken).transfer(user, _withdrawableDividend);
            return _withdrawableDividend;
        }

        return 0;
    }

    function dividendOf(address _owner, address _rewardToken)
        external
        view
        override
        returns (uint256)
    {
        return withdrawableDividendOf(_owner, _rewardToken);
    }

    function withdrawableDividendOf(address _owner, address _rewardToken)
        public
        view
        override
        returns (uint256)
    {
        return
            accumulativeDividendOf(_owner, _rewardToken).sub(
                withdrawnDividends[_owner][_rewardToken]
            );
    }

    function withdrawnDividendOf(address _owner, address _rewardToken)
        external
        view
        override
        returns (uint256)
    {
        return withdrawnDividends[_owner][_rewardToken];
    }

    function accumulativeDividendOf(address _owner, address _rewardToken)
        public
        view
        override
        returns (uint256)
    {
        return
            magnifiedDividendPerShare[_rewardToken]
                .mul(holderBalance[_owner])
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_rewardToken][_owner])
                .toUint256Safe() / magnitude;
    }

    function _increase(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++) {
            magnifiedDividendCorrections[rewardTokens[i]][
                account
            ] = magnifiedDividendCorrections[rewardTokens[i]][account].sub(
                (magnifiedDividendPerShare[rewardTokens[i]].mul(value))
                    .toInt256Safe()
            );
        }
    }

    function _reduce(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++) {
            magnifiedDividendCorrections[rewardTokens[i]][
                account
            ] = magnifiedDividendCorrections[rewardTokens[i]][account].add(
                (magnifiedDividendPerShare[rewardTokens[i]].mul(value))
                    .toInt256Safe()
            );
        }
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = holderBalance[account];
        holderBalance[account] = newBalance;
        if (newBalance > currentBalance) {
            uint256 increaseAmount = newBalance.sub(currentBalance);
            _increase(account, increaseAmount);
            totalBalance += increaseAmount;
        } else if (newBalance < currentBalance) {
            uint256 reduceAmount = currentBalance.sub(newBalance);
            _reduce(account, reduceAmount);
            totalBalance -= reduceAmount;
        }
    }
}

contract DividendTracker is DividendPayingToken, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(address key) private view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key) private view returns (int256) {
        if (!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index) private view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function size() private view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function set(address key, uint256 val) private {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint256 index = tokenHoldersMap.indexOf[key];
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }

    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor() {
        claimWait = 900;
        minimumTokenBalanceForDividends = 1000 * (10**18);
    }

    function excludeFromDividends(address account) external onlyOwner {
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        remove(account);

        emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner {
        require(excludedFromDividends[account]);
        excludedFromDividends[account] = false;

        emit IncludeInDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 900 && newClaimWait <= 86400,
            "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account, address _rewardToken)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;

        index = getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account, _rewardToken);
        totalDividends = accumulativeDividendOf(account, _rewardToken);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(uint256 index, address _rewardToken)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0,
                0,
                0
            );
        }

        address account = getKeyAtIndex(index);

        return getAccount(account, _rewardToken);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            set(account, newBalance);
        } else {
            _setBalance(account, 0);
            remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas)
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount;
        bool paid;
        for (uint256 i; i < rewardTokens.length; i++) {
            amount = _withdrawDividendOfUser(account, rewardTokens[i]);
            if (amount > 0) {
                lastClaimTimes[account] = block.timestamp;
                emit Claim(account, amount, automatic);
                paid = true;
            }
        }
        return paid;
    }

    function addRewardToken(address addr) public onlyOwner {
        rewardTokens.push(addr);
        tokenAddress = addr;
    }
}

contract Vault is Ownable, ERC20 {
    using SafeMath for uint256;

    address payable public marketing;
    address payable public development;
    address public vaultManager;
    address public vaultKeeper;
    address public vaultHelper;

    modifier onlyVaultManager() {
        require(
            msg.sender == vaultManager,
            "Not authorized: Vault Manager only"
        );
        _;
    }

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;

    uint256 public maxWalletLimit;
    uint256 public maxTxLimit;

    uint256 public buyTax;
    uint256 public sellTax;
    /**
     * @dev Means x% of the tax goes to S.T.A.R.R. Functionality
     */
    uint256 public taxDivisionPercentageForSTARR;

    uint256 public maxSwapbacksPerBlock = 2;
    uint256 private lastSwapBlock = 0;
    uint256 private swapbackCount = 0;
    uint256 private firstBlock = 0;

    bool public tradingActive;
    bool public swapEnabled;
    bool public isManagerSet = false;
    bool private swapping;
    bool private swapbackOccurred;

    enum SwapBackType {
        None,
        Dividends,
        Project
    }

    SwapBackType private lastSwapBackType;

    uint256 public totalBurned;
    uint256 public totalInfuseLPAdded;
    uint256 public totalDividend;
    uint256 public totalProjectAmount;

    uint256 public thresholdSwap;
    uint256 public tradingStartBlock;

    uint256 public swapableDividend;
    uint256 public swapableProjectAmount;

    DividendTracker public dividendTracker;
    IUniswapV2Router02 public dexRouter;
    address public lpPair;

    mapping(uint256 => uint256) private perBuyCount;
    mapping(address => bool) public lpPairs;
    mapping(address => bool) private _isExcludedFromTax;
    mapping(address => bool) private _botsBlacklist;

    event BurnToken(address indexed sender, uint256 amount);
    event infuseLPadded(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event burned(address indexed from, address indexed to, uint256 value);
    event dividend(address indexed from, address indexed to, uint256 value);
    event AddedDividend(uint256 amount);
    event buyTaxStatus(uint256 previousBuyTax, uint256 newBuyTax);
    event sellTaxStatus(uint256 previousSellTax, uint256 newSellTax);
    event TaxDivisionPercentageForSTARR(
        uint256 previousPercentage,
        uint256 newPercentage
    );
    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor() ERC20("MoonVault", "VAULT") {
        development = payable(0x8a5bb15816E96594f5D88c23Ba7F8B344601B40E);
        marketing = payable(0x362340cA11596eB37ed29fc2b3845025efC2134D);
        vaultManager = msg.sender;

        _mint(address(this), ((MAX_SUPPLY * 95) / 100));
        _mint(development, ((MAX_SUPPLY * 5) / 100));

        sellTax = 5;
        buyTax = 5;
        taxDivisionPercentageForSTARR = 60;

        maxTxLimit = (MAX_SUPPLY * 3) / 200; // 1.5% of Supply
        maxWalletLimit = (MAX_SUPPLY * 2) / 100; // 2% of Supply
        thresholdSwap = (MAX_SUPPLY * 5) / 10000; // 0.05% of Supply

        dexRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        lpPair = IUniswapV2Factory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        lpPairs[lpPair] = true;

        dividendTracker = new DividendTracker();
        dividendTracker.addRewardToken(address(this));
        dividendTracker.setBalance(
            payable(development),
            ((MAX_SUPPLY * 5) / 100)
        );

        _approve(owner(), address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

        _isExcludedFromTax[owner()] = true;
        _isExcludedFromTax[address(this)] = true;
        _isExcludedFromTax[address(dividendTracker)] = true;

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(lpPair);

        lastSwapBackType = SwapBackType.None;
        lastSwapBlock = 0;
    }

    receive() external payable {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "VAULT: transfer from the zero address");
        require(to != address(0), "VAULT: transfer to the zero address");
        require(!isBot(from) && !isBot(to), "VAULT: Bot Address cannot trade");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (block.number == firstBlock && lpPairs[from]) {
            require(
                perBuyCount[block.number] < 51,
                "VAULT: Exceeds buys allowed in the first block."
            );
            perBuyCount[block.number]++;
        }

        if (!tradingActive) {
            require(
                _isExcludedFromTax[from] || _isExcludedFromTax[to],
                "VAULT: Trading is not active yet."
            );
        }

        bool canSwap = (swapableDividend >= thresholdSwap ||
            swapableProjectAmount >= thresholdSwap);

        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            !lpPairs[from] &&
            !_isExcludedFromTax[from] &&
            !_isExcludedFromTax[to]
        ) {
            if (block.number > lastSwapBlock) {
                // A new block has started, so reset the swap counter
                lastSwapBlock = block.number;
                swapbackCount = 0;
            } // Ensure we haven't exceeded the max allowed swaps in this block
            if (swapbackCount < maxSwapbacksPerBlock) {
                swapping = true;

                // Rotate Swaps
                if (
                    lastSwapBackType == SwapBackType.None ||
                    lastSwapBackType == SwapBackType.Dividends
                ) {
                    if (swapableProjectAmount >= thresholdSwap) {
                        swapBackProject();
                        lastSwapBackType = SwapBackType.Project;
                    } else {
                        swapBackDividends();
                        lastSwapBackType = SwapBackType.Dividends;
                    }
                } else {
                    if (swapableDividend >= thresholdSwap) {
                        swapBackDividends();
                        lastSwapBackType = SwapBackType.Dividends;
                    } else {
                        swapBackProject();
                        lastSwapBackType = SwapBackType.Project;
                    }
                }

                lastSwapBlock = block.number;
                swapbackCount++;
                swapping = false;
            }
        }

        bool takeFee = !swapping;

        if (_isExcludedFromTax[from] || _isExcludedFromTax[to]) {
            takeFee = false;
        }

        uint256 fee = 0;

        //STARR

        if (takeFee) {
            uint256 STARR = _initiateSTARR();
            uint256 projectTax;
            uint256 remainingTax;

            if (
                (lpPairs[from] && buyTax > 0) ||
                (!lpPairs[from] && !lpPairs[to])
            ) {
                _checkMaxWalletLimit(to, amount);
                _checkMaxTxLimit(amount);

                fee = (amount.mul(buyTax)).div(100);
                (projectTax, remainingTax) = _getTaxAmount(fee);
                if (remainingTax > 0) {
                    if (STARR == 1) {
                        burn_(from, remainingTax);
                        totalBurned = totalBurned.add(remainingTax);
                        emit burned(from, to, remainingTax);
                    } else if (STARR == 2) {
                        totalInfuseLPAdded = totalInfuseLPAdded.add(
                            remainingTax
                        );
                        emit infuseLPadded(from, to, remainingTax);
                    } else if (STARR == 3) {
                        swapableDividend = swapableDividend.add(remainingTax);
                        totalDividend = totalDividend.add(remainingTax);
                        emit dividend(from, to, remainingTax);
                        super._transfer(from, address(this), remainingTax);
                    }
                }

                swapableProjectAmount = swapableProjectAmount.add(projectTax);
                totalProjectAmount = totalProjectAmount.add(projectTax);
                super._transfer(from, address(this), projectTax);
            } else if (lpPairs[to] && sellTax > 0) {
                _checkMaxTxLimit(amount);

                fee = (amount.mul(sellTax)).div(100);
                (projectTax, remainingTax) = _getTaxAmount(fee);
                if (remainingTax > 0) {
                    if (STARR == 1) {
                        burn_(from, remainingTax);
                        totalBurned = totalBurned.add(remainingTax);
                        emit burned(from, to, remainingTax);
                    } else if (STARR == 2) {
                        super._transfer(from, to, remainingTax);
                        totalInfuseLPAdded = totalInfuseLPAdded.add(
                            remainingTax
                        );
                        emit infuseLPadded(from, to, remainingTax);
                    } else if (STARR == 3) {
                        super._transfer(from, address(this), remainingTax);
                        swapableDividend = swapableDividend.add(remainingTax);
                        emit dividend(from, to, remainingTax);
                        totalDividend = totalDividend.add(remainingTax);
                    }
                }

                swapableProjectAmount = swapableProjectAmount.add(projectTax);
                totalProjectAmount = totalProjectAmount.add(projectTax);
                super._transfer(from, address(this), projectTax);
            }

            amount -= fee;
        }

        super._transfer(from, to, amount);

        dividendTracker.setBalance(payable(from), balanceOf(from));
        dividendTracker.setBalance(payable(to), balanceOf(to));
    }

    /// @dev Burn Function
    function burn(uint256 amount) public returns (bool) {
        burn_(_msgSender(), amount);
        return true;
    }

    function burn_(address sender, uint256 amount) private {
        require(_balances[sender] >= amount, "VAULT: Invalid amount");
        _burn(sender, amount);
        emit BurnToken(sender, amount);
    }

    /// @dev Dividend Functions
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner {
        dividendTracker.includeInDividends(account);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed(address rewardToken)
        external
        view
        returns (uint256)
    {
        return dividendTracker.totalDividendsDistributed(rewardToken);
    }

    function withdrawableDividendOf(address account, address rewardToken)
        external
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account, rewardToken);
    }

    function dividendTokenBalanceOf(address account)
        external
        view
        returns (uint256)
    {
        return dividendTracker.holderBalance(account);
    }

    function getAccountDividendsInfo(address account, address rewardToken)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account, rewardToken);
    }

    function getAccountDividendsInfoAtIndex(uint256 index, address rewardToken)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index, rewardToken);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimForBeneficiary(address beneficiary) external {
        require(beneficiary != address(0), "Invalid address");
        dividendTracker.processAccount(payable(beneficiary), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getNumberOfDividends() external view returns (uint256) {
        return dividendTracker.totalBalance();
    }

    /// @notice Trading Functionalities
    function enableTrading() public onlyOwner returns (bool) {
        require(!tradingActive, "VAULT: Cannot re-enable trading");
        tradingActive = true;
        swapEnabled = true;
        firstBlock = block.number;
        return true;
    }

    function enableTradingWithPermit(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Trading Token")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(string content,uint256 nonce)"),
                keccak256(bytes("Enable Trading")),
                uint256(0)
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainHash, structHash)
        );

        address sender = ecrecover(digest, v, r, s);
        require(sender == owner(), "VAULT: Invalid signature");

        tradingActive = true;
        swapEnabled = true;
        firstBlock = block.number;
    }

    function setFeeStructure(
        uint256 _buyTax,
        uint256 _sellFee,
        uint256 _taxDivisionPercentageForSTARR
    ) public onlyOwner returns (bool) {
        require(
            _taxDivisionPercentageForSTARR >= 0 &&
                _taxDivisionPercentageForSTARR <= 100,
            "VAULT: Percentage cannot be > 100 or < 0"
        );
        require(_buyTax <= 25, "VAULT: Buy tax cannot be more then 15%");
        require(_sellFee <= 25, "VAULT: Sell tax cannot be more then 15%");

        uint256 _prevBuyTax = buyTax;
        uint256 _prevSellTax = sellTax;
        uint256 _prevPercentage = taxDivisionPercentageForSTARR;

        buyTax = _buyTax;
        sellTax = _sellFee;
        taxDivisionPercentageForSTARR = _taxDivisionPercentageForSTARR;

        emit buyTaxStatus(_prevBuyTax, buyTax);
        emit sellTaxStatus(_prevSellTax, sellTax);
        emit TaxDivisionPercentageForSTARR(
            _prevPercentage,
            taxDivisionPercentageForSTARR
        );
        return true;
    }

    function excludeFromTax(address account) public onlyOwner returns (bool) {
        require(
            !_isExcludedFromTax[account],
            "VAULT: Account is already excluded from tax"
        );
        _isExcludedFromTax[account] = true;
        return true;
    }

    function includeInTax(address account) public onlyOwner returns (bool) {
        require(
            _isExcludedFromTax[account],
            "VAULT: Account is already included in tax"
        );
        _isExcludedFromTax[account] = false;
        return true;
    }

    function isExcludedFromTax(address account) public view returns (bool) {
        return _isExcludedFromTax[account];
    }

    /// @dev Allow Owner to Exclude any wallet from Bot Blacklist
    function addInBotBlacklist(address account)
        external
        onlyOwner
        returns (bool)
    {
        require(
            !_botsBlacklist[account],
            "VAULT: Account is already added in bot blacklist"
        );

        _botsBlacklist[account] = true;
        dividendTracker.excludeFromDividends(account);

        return true;
    }

    /// @dev Allow Owner to include any wallet from Bot Blacklist
    function removeFromBotBlacklist(address account)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _botsBlacklist[account],
            "VAULT: Account is already removed from bot blacklist"
        );

        _botsBlacklist[account] = false;
        dividendTracker.includeInDividends(account);

        return true;
    }

    /// @dev Return true if the account is bot
    function isBot(address account) public view returns (bool) {
        return _botsBlacklist[account];
    }

    function setMarketingAddress(address payable account)
        public
        onlyOwner
        returns (bool)
    {
        require(
            marketing != account,
            "VAULT: Account is already marketing address"
        );
        marketing = account;
        return true;
    }

    function setDevelopmentAddress(address payable account)
        public
        onlyOwner
        returns (bool)
    {
        require(
            development != account,
            "VAULT: Account is already development address"
        );
        development = account;
        return true;
    }

    function setVaultKeeper(address _vaultKeeper) external onlyVaultManager {
        vaultKeeper = _vaultKeeper;
        _isExcludedFromTax[vaultKeeper] = true; // Exclude from tax
        dividendTracker.includeInDividends(vaultKeeper); // Include in rewards
    }

    function setVaultHelper(address _vaultHelper) external onlyVaultManager {
        vaultHelper = _vaultHelper;
        _isExcludedFromTax[vaultHelper] = true;
    }

    function setVaultManager(address _newManager) external onlyVaultManager {
        require(!isManagerSet, "Vault manager can only be set once");
        vaultManager = _newManager; // Set new manager
        isManagerSet = true; // Mark the manager as set, so it can't be changed again
    }

    function renounceVaultManager() external onlyVaultManager {
        require(
            vaultManager != address(0),
            "Vault manager is already renounced"
        );
        vaultManager = address(0); // Renounce the manager role by setting it to the zero address
    }

    function setLimits(uint256 _maxWalletLimit, uint256 _maxTxLimit)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _maxWalletLimit >= 2 && _maxWalletLimit <= 100,
            "VAULT: Max Wallet limit cannot be less then 2% or more than 100%"
        );
        require(
            _maxTxLimit >= 1 && _maxTxLimit <= 100,
            "VAULT: Max tx limit cannot be less then 1% or more than 100%"
        );

        maxWalletLimit = (_maxWalletLimit * MAX_SUPPLY) / 100;
        maxTxLimit = (_maxTxLimit * MAX_SUPPLY) / 100;

        return true;
    }

    function setThresholdSwap(uint256 amount) public onlyOwner returns (bool) {
        require(
            amount != thresholdSwap,
            "VAULT: Amount cannot be same as previous amount"
        );
        thresholdSwap = amount;
        return true;
    }

    function recoverAllEth(address to) public onlyOwner returns (bool) {
        payable(to).transfer(address(this).balance);
        return true;
    }

    function setDividendTokenAddress(DividendTracker _token)
        external
        onlyOwner
        returns (bool)
    {
        dividendTracker = _token;
        return true;
    }

    function _initiateSTARR() private view returns (uint256) {
        uint256 returnNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    block.gaslimit,
                    tx.origin,
                    block.number,
                    tx.gasprice
                )
            )
        ) % 3;

        return returnNumber + 1;
    }

    /// @notice Private Function
    function _getTaxAmount(uint256 _tax)
        private
        view
        returns (uint256 projectAmount, uint256 remainingTax)
    {
        uint256 projectAmount_;
        uint256 remainingTax_;

        projectAmount_ =
            (_tax * ((100 - taxDivisionPercentageForSTARR))) /
            (100);
        remainingTax_ = (_tax * (taxDivisionPercentageForSTARR)) / (100);

        return (projectAmount_, remainingTax_);
    }

    function _checkMaxWalletLimit(address recipient, uint256 amount)
        private
        view
        returns (bool)
    {
        require(
            maxWalletLimit >= balanceOf(recipient).add(amount),
            "VAULT: Wallet limit exceeds"
        );
        return true;
    }

    function _checkMaxTxLimit(uint256 amount) private view returns (bool) {
        require(amount <= maxTxLimit, "VAULT: Transaction limit exceeds");
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBackProject() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap = 0;

        if (swapableProjectAmount >= thresholdSwap) {
            if (swapableProjectAmount > thresholdSwap * 10) {
                tokensToSwap = thresholdSwap * 10;
            } else {
                tokensToSwap = swapableProjectAmount;
            }
        }

        if (contractBalance == 0 || tokensToSwap == 0) {
            return;
        }

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(tokensToSwap);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        swapableProjectAmount = swapableProjectAmount.sub(tokensToSwap);

        bool success;
        (success, ) = address(marketing).call{value: ethBalance.div(2)}("");
        require(success, "Transfer to marketing wallet failed.");

        (success, ) = address(development).call{value: ethBalance.div(2)}("");
        require(success, "Transfer to development wallet failed.");
    }

    function swapBackDividends() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap = 0;

        if (swapableDividend >= thresholdSwap) {
            if (swapableDividend > thresholdSwap * 10) {
                tokensToSwap = thresholdSwap * 10;
            } else {
                tokensToSwap = swapableDividend;
            }
        }

        if (contractBalance == 0 || tokensToSwap == 0) {
            return;
        }

        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(tokensToSwap);
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        swapableDividend = swapableDividend.sub(tokensToSwap);

        bool success;
        (success, ) = address(dividendTracker).call{value: ethBalance}("");
        require(success, "Transfer to dividend tracker failed.");

        emit AddedDividend(ethBalance);
    }

    function addLiquidity() external payable onlyOwner {
        require(msg.value > 0, "Need to send ETH");

        IERC20(address(this)).approve(
            address(dexRouter),
            balanceOf(address(this))
        );

        dexRouter.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }
}