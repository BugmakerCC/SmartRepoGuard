/*


!NEW SHIT COIN ALERT!


:––

Kindly direct your esteemed attention to our digital repository, 
wherein lies a cornucopia of insights pertaining to this project, 
with particular emphasis on the illustrious BBL Lottery™, 
a veritable symphony of chance and opportunity.
For a deeper exploration and continuous updates, 
avail yourself of the following distinguished portals: 

WEBSITE:

https://brazilianbuttlift.wtf


TELEGRAM:

https://t.me/BRAZILIANBUTTLIFTJESUS


X:

https://x.com/BBLWIFJESUS


*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _setAllowance(owner, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _deductAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 increase) public virtual returns (bool) {
        address owner = _msgSender();
        _setAllowance(owner, spender, _allowances[owner][spender] + increase);
        return true;
    }

    function decreaseAllowance(address spender, uint256 decrease) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= decrease, "Allowance can't be set below zero");
        unchecked {
            _setAllowance(owner, spender, currentAllowance - decrease);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        uint256 balanceOfSender = _balances[from];
        require(from != address(0) && to != address(0), "Transfer from/to the zero address not allowed");
        require(balanceOfSender >= amount, "Transfer amount exceeds your balance");
        unchecked {
            _balances[from] = balanceOfSender - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Mint to the zero address not allowed");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _setAllowance(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0) && spender != address(0), "Approve from/to the zero address is not allowed");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _deductAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Allowance can't be set below zero");
            unchecked {
                _setAllowance(owner, spender, currentAllowance - amount);
            }
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed nextOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "You are not the owner of this contract");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address nextOwner) public virtual onlyOwner {
        require(nextOwner != address(0), "Zero address is the new owner of the contract");
        _transferOwnership(nextOwner);
    }

    function _transferOwnership(address nextOwner) internal virtual {
        address oldOwner = _owner;
        _owner = nextOwner;
        emit OwnershipTransferred(oldOwner, nextOwner);
    }
}

contract BBL is ERC20, Ownable {
    IUniswapV2Router02 private constant uniswap = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
    // "private constant" and declared right at deployment –> Can't be changed -> No foul play

    address public uniswapLiquidityPair;
    address public immutable feeWallet;
    uint256 private walletSizeLimit = 1393813939 * 1e18;
    uint256 private minContractTokenSwap = 69690696 * 1e18;
    uint256 private maxContractTokenSwap = 696906969 * 1e18;
    uint8 private sellTransactionCount;   
    uint8 private buyTransactionCount;
    uint32 private _lastSellBlock;
    uint8 private _feeDecreaseThreshold = 29;
    uint8 private _preventSwapBefore = 0;
    uint8 private _feePercentOnBuys = 2;
    uint8 private _feePercentOnSells = 2;
    bool private inSwap;
    uint8 private initialBuyFeePercent;
    uint8 private initialSellFeePercent;
    mapping (address => bool) private excludedFromLimits;

    constructor() ERC20("BRAZILIAN BUTT LIFT", "BBL") payable {
        uint256 totalSupply = 69690696969 * 1e18;
        initialBuyFeePercent = 19;
        initialSellFeePercent = 19;
        feeWallet = 0xC1e705F20b466e0e9735ec023Fa3081FAd95cfB3;
        excludedFromLimits[feeWallet] = true;
        excludedFromLimits[msg.sender] = true;
        excludedFromLimits[address(this)] = true;
        _setAllowance(address(this), address(uniswap), totalSupply);
        _setAllowance(msg.sender, address(uniswap), totalSupply);
        _mint(msg.sender, totalSupply);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0) && to != address(0) && amount > 0, "Transfer must not be from/to zero address and the amount must be greater than zero");
        bool excluded = excludedFromLimits[from] || excludedFromLimits[to];
        require(uniswapLiquidityPair != address(0) || excluded, "Liquidity pair not yet created");
        bool sellTransaction = to == uniswapLiquidityPair;
        bool buyTransaction = from == uniswapLiquidityPair;

        // Prevention against a Sybil attack -type price manipulation (buying through multiple wallets and selling all at once through one wallet):
        if(!sellTransaction && !buyTransaction && !excluded){
                require(balanceOf(to) + amount <= 1393813939 * 1e18, "One cannot transfer tokens between wallets to circumvent the initial wallet size limit");
        }

        if(buyTransaction && !excluded){
            require(balanceOf(to) + amount <= walletSizeLimit || to == address(uniswap), "Limit for maximum wallet size exceeded");
            if(buyTransactionCount <= _feeDecreaseThreshold)
                buyTransactionCount++;
            if(buyTransactionCount == _feeDecreaseThreshold){
                initialBuyFeePercent = _feePercentOnBuys;
                initialSellFeePercent = _feePercentOnSells;
            }
        }            
        
        uint256 contractTokenBalance = balanceOf(address(this));
       
        if (sellTransaction && !inSwap && contractTokenBalance >= minContractTokenSwap && !excluded && buyTransactionCount > _preventSwapBefore) {
            if (block.number > _lastSellBlock) 
                sellTransactionCount = 0;
            require(sellTransactionCount < 1, "One contract token swap per block at maximum");
            inSwap = true;
            _tokenToETHSwap(_min(amount, _min(contractTokenBalance, maxContractTokenSwap)));
            inSwap = false;
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) 
                _sendETHToFeeWallet(contractETHBalance);        
            sellTransactionCount++;
            _lastSellBlock = uint32(block.number);
        }
        
        uint8 fee = buyTransaction ? initialBuyFeePercent : initialSellFeePercent;
        
        if (fee > 0 && !excluded && !inSwap && (buyTransaction || sellTransaction)) {
            uint256 fees = amount * fee / 100;
            if (fees > 0){
                super._transfer(from, address(this), fees);
                amount-= fees;
            }
        }
        super._transfer(from, to, amount);
    }

    function _min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
    }

    function _tokenToETHSwap(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswap.WETH();
        _setAllowance(address(this), address(uniswap), tokenAmount);
        uniswap.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function _sendETHToFeeWallet(uint256 amount) private {
        payable(feeWallet).transfer(amount);
    }

    function removeLimits() external onlyOwner {                
        walletSizeLimit = totalSupply();
    }

    function updateStructure(uint256 maxAmount, uint256 minAmount) external onlyOwner {                
        maxContractTokenSwap = maxAmount;
        minContractTokenSwap = minAmount;
    }

    function sweepStuckETH() external onlyOwner {
        payable(feeWallet).transfer(address(this).balance);
    }

    function transferStuckToken(IERC20 token) external onlyOwner {
        token.transfer(feeWallet, token.balanceOf(address(this)));
    }

    function startTrading() external payable onlyOwner {
    super._transfer(msg.sender, address(this), totalSupply());
    uniswap.addLiquidityETH{value: 1 ether}(address(this), 52268022726 ether, 0, 0, msg.sender, block.timestamp);
    uniswapLiquidityPair = IUniswapV2Factory(uniswap.factory()).getPair(address(this), uniswap.WETH());
    }

    receive() external payable {}
}