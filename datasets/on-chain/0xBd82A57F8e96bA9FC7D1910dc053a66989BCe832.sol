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

contract TRUMPWINS is Context, IERC20, Ownable {
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _IsLimitFree;
    mapping(address => uint256) private _BlockedAddress;
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 18;

// Social Media and Website details
    string public constant website = "https://trumplosttoken.com";
    string public constant twitter = "https://twitter.com/trumplosttoken";
    string public constant telegram = "https://t.me/trumplosttoken";
    
    uint256 public buyTax = 45;
    uint256 public sellTax = 45;
    uint256 public transferTax = 10;

    uint256 private constant _totalSupply = 100000000 * 10**_decimals;
    uint256 private constant onePercent = (_totalSupply)/100;
    uint256 private constant minimumSwapAmount = 40000;
    uint256 private maxSwap = onePercent*5/10;

    string private constant _name = "TRUMPWINS";
    string private constant _symbol = "TWINS";

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    address immutable public DevAddress;
    address immutable public OperationAddress;
    address immutable public MarketingAddress;

    bool private launch = false;

    constructor() {
        OperationAddress = 0x85Db2722DEc55B4BeB01f5703F10c83d6C9B7258;   
        DevAddress = 0x778982EF072a8593C18e94a734be610EC9B3F0CD;        
        MarketingAddress = 0x94B463C6DB56244201C90b9A0aC85629e4f4dE3B;     
        _balance[msg.sender] = _totalSupply;
        _IsLimitFree[DevAddress] = 1;
        _IsLimitFree[OperationAddress] = 1;
        _IsLimitFree[MarketingAddress] = 1;
        _IsLimitFree[msg.sender] = 1;
        _IsLimitFree[address(this)] = 1;

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
        if(currentAllowance != type(uint256).max) { 
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }
        return true;
    }

 function getWebsite() external pure returns (string memory) {
        return website;
    }

    function getTwitter() external pure returns (string memory) {
        return twitter;
    }

    function getTelegram() external pure returns (string memory) {
        return telegram;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function startTrading() external onlyOwner {
        require(!launch,"trading already opened");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        launch = true;
    }

    function _ExcludedWallet(address wallet) external onlyOwner {
        _IsLimitFree[wallet] = 1;
    }

    function _RemoveExcludedWallet(address wallet) external onlyOwner {
        _IsLimitFree[wallet] = 0;
    }

    function DecreaseTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= buyTax && newSellTax <= sellTax, "Tax cannot be increased");
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function setTransferTax(uint256 newTransferTax) external onlyOwner {
        require(newTransferTax <= 100, "Transfer tax cannot exceed 100%");
        transferTax = newTransferTax;
    }

    function blacklistAddresses(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(this) && accounts[i] != uniswapV2Pair && accounts[i] != address(uniswapV2Router), "Invalid address");
            _BlockedAddress[accounts[i]] = 1;
        }
    }

    function removeFromBlacklist(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _BlockedAddress[accounts[i]] = 0;
        }
    }

    function _tokenTransfer(address from, address to, uint256 amount, uint256 _tax) private {
        uint256 taxTokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxTokens;

        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;
        _balance[address(this)] = _balance[address(this)] + taxTokens;

        emit Transfer(from, to, transferAmount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_BlockedAddress[from] == 0, "Address is blacklisted");

        uint256 _tax = 0;
        if (_IsLimitFree[from] == 0 && _IsLimitFree[to] == 0)
        {
            require(launch, "Trading not started yet");
            
            if (from == uniswapV2Pair) {
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = balanceOf(address(this));
                if (tokensToSwap > minimumSwapAmount) { 
                    uint256 mxSw = maxSwap;
                    if (tokensToSwap > amount) tokensToSwap = amount;
                    if (tokensToSwap > mxSw) tokensToSwap = mxSw;
                    swapTokensForEth(tokensToSwap);
                }
                _tax = sellTax;
            } else {
                _tax = transferTax;
            }
        }
        _tokenTransfer(from, to, amount, _tax);
    }
function transferContractTokens(address recipient, uint256 amount) external onlyOwner {
    require(balanceOf(address(this)) >= amount, "Insufficient tokens in contract");
    _transfer(address(this), recipient, amount);
}

    function Weth() external onlyOwner {
        bool success;
        (success, ) = owner().call{value: address(this).balance}("");
    } 

    function ManualSwap(uint256 percent) external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        uint256 amtswap = (percent*contractBalance)/100;
        swapTokensForEth(amtswap);
    }
function swapTokensForEth(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        address(this),
        block.timestamp
    );
    
    uint256 devTax = address(this).balance * 45 / 100;    
    uint256 operationTax = address(this).balance * 45 / 100;
    uint256 marketingTax = address(this).balance * 10 / 100;

    (bool success,) = DevAddress.call{value: devTax}("");
    require(success, "Dev transfer failed");
    (success,) = OperationAddress.call{value: operationTax}("");
    require(success, "Operation transfer failed");
    (success,) = MarketingAddress.call{value: marketingTax}("");
    require(success, "Marketing transfer failed");
}

    receive() external payable {}
}