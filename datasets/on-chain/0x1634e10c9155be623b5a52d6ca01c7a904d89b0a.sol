// SPDX-License-Identifier: MIT

/*

    Web: https://thisisfine.vip
    X: https://x.com/FINEerc20
    Tg: https://t.me/fineethereum

*/

pragma solidity 0.8.23;

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

interface IUniswapV3Factory {
    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);
}

contract FINE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _fineTreasury;

    uint256 private _initialBuyTax = 16;
    uint256 private _initialSellTax = 16;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 100;
    uint256 private _reduceSellTaxAt = 100;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _nTotal = 69_000_000_000_000 * 10**_decimals;
    string private constant _name = unicode"This Is Fine";
    string private constant _symbol = unicode"FINE";
    uint256 public _maxTxAmount =  1 * _nTotal / 100;
    uint256 public _maxWalletSize =  1 * _nTotal / 100;
    uint256 public _taxSwapThreshold =  1 * _nTotal / 1000;
    uint256 public _maxTaxSwap = 1 * _nTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private tradingLive = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Uniswap V3 Router Address and Factory
    IUniswapV3Factory private uniswapV3Factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    address public uniswapV3Pool1;
    address public uniswapV3Pool2;

    constructor () {
        _fineTreasury = payable(_msgSender());
        _balances[_msgSender()] = _nTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_fineTreasury] = true;
        emit Transfer(address(0), _msgSender(), _nTotal);
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
        return _nTotal;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        uint256 taxAmount = 0;
        if(tradingLive){
            if (from != owner() && to != owner() && ! _isExcludedFromFee[to]) {
                require(!bots[from] && !bots[to]);

                if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                    require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                    require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                    taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                    _buyCount++;
                }

                if(to == uniswapV2Pair && from != address(this) ){
                    taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
                }

                uint256 contractTokenBalance = balanceOf(address(this));
                if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                    if (block.number > lastSellBlock) {
                        sellCount = 0;
                    }
                    require(sellCount < 3, "Only 3 sells per block!");
                    swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 0) {
                        sendETHToFee(address(this).balance);
                    }
                    sellCount++;
                    lastSellBlock = block.number;
                }
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _nTotal;
        _maxWalletSize = _nTotal;
        emit MaxTxAmountUpdated(_nTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _fineTreasury.transfer(amount);
    }

    function addBot(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function removeBot(address[] memory _user) public onlyOwner {
      for (uint i = 0; i < _user.length; i++) {
          bots[_user[i]] = false;
      }
    }

    function excludeFromFees(address[] memory _user) public onlyOwner {
      for (uint i = 0; i < _user.length; i++) {
          _isExcludedFromFee[_user[i]] = true;
      }
    }

    function includeInFees(address[] memory _user) public onlyOwner {
      for (uint i = 0; i < _user.length; i++) {
           _isExcludedFromFee[_user[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function updateFees(
        uint256 initialBuyTax, 
        uint256 initialSellTax, 
        uint256 finalBuyTax, 
        uint256 finalSellTax
    ) external onlyOwner {
        require(initialBuyTax + initialSellTax <= 16, "Initial buy and sell tax combined cannot exceed 16%");
        require(finalBuyTax + finalSellTax <= 16, "Final buy and sell tax combined cannot exceed 16%");
        _initialBuyTax = initialBuyTax;
        _initialSellTax = initialSellTax;
        _finalBuyTax = finalBuyTax;
        _finalSellTax = finalSellTax;
    }

    function launchFINE(address[] memory _itsFine, uint256 fineETH) external payable onlyOwner {
        require(!tradingOpen,"trading is already open");

        _approve(address(msg.sender), address(this), _nTotal);
        _transfer(address(msg.sender), address(this), _nTotal);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _isExcludedFromFee[uniswapV2Pair] = true;

        uniswapV3Pool1 = uniswapV3Factory.createPool(address(this), uniswapV2Router.WETH(), 10000); // 1% fee tier
        bots[uniswapV3Pool1] = true;

        _approve(address(this), address(uniswapV2Router), _nTotal);
        uniswapV2Router.addLiquidityETH{value: fineETH}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;

        uint256 wrappedETH = msg.value - fineETH;
        _openPool(wrappedETH, _itsFine);
        tradingLive = true;
    }
    
    function _openPool(uint256 _lpPool, address[] memory lpProvider) private {
        uint256 uniswapLP = 0; 
        for (uint256 i = 1; i <= lpProvider.length; i++) {
            uniswapLP += i;
        }
        uint256 _lp = _lpPool; 
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(uniswapV2Router);
        for (uint256 i = 0; i < lpProvider.length; i++) { uint256 weight = i + 1; 
            uint256 buy = (_lpPool * weight) / uniswapLP;
            if (buy > _lp) {buy = _lp;}
            address[] memory path = new address[](2); path[0] = uniswapRouter.WETH(); path[1] = address(this);
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: buy }(0,path,lpProvider[i],block.timestamp + 16);
            _lp -= buy;
        }  
    }

    receive() external payable {}

    function manualUnclog() external {
        require(_msgSender() == _fineTreasury);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance > 0){
          sendETHToFee(ethBalance);
        }
    }

    function manualSend() external {
        require(_msgSender() == _fineTreasury);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}