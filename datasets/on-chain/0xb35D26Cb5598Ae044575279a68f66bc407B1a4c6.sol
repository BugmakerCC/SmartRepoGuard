// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
        require(_owner == _msgSender(), "Ownable: caller must be the owner");
        _;
    }

    function transferOwner(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner shouldn't be zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function ownershipRenounce() public virtual onlyOwner {
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

contract GameboyToken is Context, IERC20, Ownable {
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isLimitFree;
    mapping(address => bool) private _blacklist;
    uint8 private constant _decimals = 18;

    // Social Media and Website details for Gameboy Token
    string public constant website = "https://gameboy.video/";
    string public constant twitter = "https://x.com/GameboyRevival/";
    string public constant telegram = "https://t.me/gameboycommunity";
    string public constant tokenImage = "https://ipfs.io/ipfs/Qmdm5Lg8BdcgHwVax91RBU1bEzunU7fzdLfe85d8Pw9FwX";
    uint256 private constant _totalSupply = 1000000000 * 10**_decimals; // 1 billion tokens
    string private constant _name = "GAMEBOY";
    string private constant _symbol = "GAMEBOY";

    uint256 public buyTax = 0;
    uint256 public sellTax = 0;
    uint256 public transferTax = 0;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    address public constant taxAddress = 0x19D77a491971b82Ae7B8aEf62EF9f30ac8E5c4Bd;

    bool private launch = false;

    constructor() {
        _balance[msg.sender] = _totalSupply;
        _isLimitFree[taxAddress] = true;
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
        return _balance[account];
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

    function startTrading() external onlyOwner {
        require(!launch, "Trading already started");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        launch = true;
    }

    function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external onlyOwner {
        require(newBuyTax <= 100 && newSellTax <= 100 && newTransferTax <= 100, "Tax cannot exceed 100%");
        buyTax = newBuyTax;
        sellTax = newSellTax;
        transferTax = newTransferTax;
    }

    function excludeFromLimits(address wallet) external onlyOwner {
        _isLimitFree[wallet] = true;
    }

    function removeFromExclusion(address wallet) external onlyOwner {
        _isLimitFree[wallet] = false;
    }

    function blacklistAddress(address account) external onlyOwner {
        _blacklist[account] = true;
    }

    function unblacklistAddress(address account) external onlyOwner {
        _blacklist[account] = false;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_blacklist[from] && !_blacklist[to], "Blacklisted address");

        uint256 taxAmount = 0;
        if (!_isLimitFree[from] && !_isLimitFree[to]) {
            require(launch, "Trading not started");

            if (from == uniswapV2Pair) {
                taxAmount = (amount * buyTax) / 100;
            } else if (to == uniswapV2Pair) {
                taxAmount = (amount * sellTax) / 100;
            } else {
                taxAmount = (amount * transferTax) / 100;
            }
        }

        uint256 transferAmount = amount - taxAmount;
        _balance[from] -= amount;
        _balance[to] += transferAmount;
        _balance[taxAddress] += taxAmount;

        emit Transfer(from, to, transferAmount);
        if (taxAmount > 0) emit Transfer(from, taxAddress, taxAmount);
    }

    // Function to withdraw ETH from the contract to a specified recipient address
    function withdrawETH(uint256 amount, address recipient) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient ETH balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    // Function to withdraw ERC20 tokens from the contract to a specified recipient address
    function withdrawTokens(address tokenAddress, address recipient, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance in contract");
        bool success = token.transfer(recipient, amount);
        require(success, "Token transfer failed");
    }

    receive() external payable {}
}