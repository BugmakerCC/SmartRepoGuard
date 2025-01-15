// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
Website:  http://www.mypchan.com
*/
/**
.--------------------------------------------------------------------.
|   ███    ░████████  ░███████  ░███    ░███   ░████    ░███   ░███  |
|  ██████  ░██░░░░░██░███░░░░███░███    ░███  ░███░███  ░████  ░███  |
| ███░░░   ░██    ░██░███   ░░░ ░███    ░███ ░███  ░███ ░█████ ░███  |
|░░█████   ░████████ ░███       ░███████████░███    ░███░███░██░███  |
| ░░░░███  ░██░░░░░  ░███       ░███░░░░░███░███████████░███ ░█████  |
| ██████   ░██       ░███    ███░███    ░███░███░░░░░███░███  ░████  |
|░░░███    ░██        ░██████░░ ░███    ░███░███     ███░███   ░███  |
|  ░░░    ░░         ░░░░░░    ░░░     ░░░ ░░░     ░░░ ░░░    ░░░░   |
'--------------------------------------------------------------------'
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external pure returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address ownerAddress, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed ownerAddress, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

contract PCHAN is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExile;
    mapping (address => bool) public marketPair;
    uint256 private firstBlock;

    uint256 private _buyCount = 0;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 444_444_444 * 10**_decimals;
    string private constant _name = unicode"PCHAN";
    string private constant _symbol = unicode"PCHAN";
    uint256 public _maxTxAmount = 4_444_444 * 10**_decimals;
    uint256 public _maxWalletSize = 4_444_444 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen;
    uint256 public caBlockLimit = 5;
    bool public caLimit = true;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    event RescueERC20(address indexed token, address indexed to, uint256 amount);

    constructor () {
        _balances[_msgSender()] = _tTotal;

        // Initialize Uniswap router and pair
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        // Set isExile mappings
        isExile[owner()] = true;
        isExile[address(this)] = true;
        isExile[address(uniswapV2Pair)] = true;

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint256).max);
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
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

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address ownerAddress, address spender) public view override returns (uint256) {
        return _allowances[ownerAddress][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _approve(address ownerAddress, address spender, uint256 amount) private {
        require(ownerAddress != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[ownerAddress][spender] = amount;
        emit Approval(ownerAddress, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            if (marketPair[from] && to != address(uniswapV2Router) && !isExile[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");

                if (firstBlock + 1 > block.number) {
                    require(!isContract(to));
                }
                _buyCount++;
            }

            if (!marketPair[to] && !isExile[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }
        }

        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function rescueStuckERC20Tokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(), amount);
        emit RescueERC20(tokenAddress, owner(), amount);
    }

    function rescueStuckETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function exileW_Restriction() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        require(address(this).balance > 0, "Contract needs ETH to add liquidity");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        marketPair[address(uniswapV2Pair)] = true;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        tradingOpen = true;
        firstBlock = block.number;
    }

    receive() external payable {}
}