// SPDX-License-Identifier: MIT

// Launch Your Token Effortlessly on Telegram – With Zero Gas Fees and No Initial Liquidity Required!
//
// With LaunchAI, anyone can create, buy, and sell tokens directly on Telegram or through our web platform. 
// Our AI-powered tools make branding a breeze, and tokens launch automatically on Uniswap when they reach a specific market cap threshold. 
// Simplify crypto creation today!
//
// Start Your Token Journey with LaunchAI!
//
// Telegram: https://t.me/launchaieth


pragma solidity 0.8.26;

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
    address public _owner;
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
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

contract LaunchAI is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;
    address payable private _mktWallet;
    address payable private _desginerWallet;
    address payable private _expenseWallet;

    uint256 private _initialTax=20;
    uint256 private _finalTax=5;
    uint256 private _preventSwapBefore=30;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10**_decimals;
    string private constant _name = unicode"Launch AI";
    string private constant _symbol = unicode"LNCH";
    uint256 public _maxTxAmount = 1_500_000 * 10**_decimals;
    uint256 public _maxWalletSize = 1_500_000 * 10**_decimals;
    uint256 public _taxSwap = 700_000 * 10**_decimals;
    uint256 public _launchDate;
    uint256 internal _locker;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address _tax1, address _tax3, address _tax4) {
        _taxWallet = payable(_tax1);
        _expenseWallet = payable(_msgSender());
        _desginerWallet = payable(_tax3);
        _mktWallet = payable(_tax4);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _locker = block.timestamp;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - (amount));
        return true;
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
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && _finalTax != 0) {
            if(!inSwap){
              taxAmount = amount * ((block.timestamp > _launchDate + 10 minutes)?_finalTax:_initialTax) / (100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                if(block.timestamp < _launchDate + 15 minutes){
                    require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                    require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                }
                _buyCount++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwap && _buyCount>_preventSwapBefore) {
                swapTokensForEth(_taxSwap > amount ? amount : _taxSwap);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0.1 ether) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        _balances[from]=_balances[from] - amount;
        _balances[to]=_balances[to] + (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)] + (taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        uint256 toSend = amount / 4;
        _taxWallet.transfer(toSend);
        _mktWallet.transfer(toSend);
        _desginerWallet.transfer(toSend);
        _expenseWallet.transfer(toSend);        
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
        _launchDate = block.timestamp;
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function reduceFee(uint256 _newFee) external{
      require(_msgSender() == _taxWallet);
      require(_newFee <= 5);
      _finalTax=_newFee;
    }

    function changeWallets(address _newTax, address _newmktWallet,address _newdWallet,address _neweWallet) external{
      require(block.timestamp > _locker + 90 days);
      require(_msgSender() == _taxWallet);
      _locker = block.timestamp;
      _taxWallet = payable(_newTax);
      _mktWallet = payable(_newmktWallet);
      _desginerWallet = payable(_newdWallet);
      _expenseWallet = payable(_neweWallet);
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        swapTokensForEth(balanceOf(address(this)));
    }

    function manualSend(uint256 amount) external {
        require(_msgSender() == _taxWallet);
        sendETHToFee(amount);
    }

    function manualSendToken() external {
        require(_msgSender() == _taxWallet);
        IERC20(address(this)).transfer(msg.sender, balanceOf(address(this)));
    }
}