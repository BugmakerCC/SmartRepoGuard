// SPDX-License-Identifier: MIT

/*
BISX777: The "Bahamas Illuminati Society Xperiment" is a fun memecoin, not linked to the BISX Stock Exchange (Bahamas International Securities Exchange).

777
The 777 angel number is considered a powerful spiritual message. 
When it appears repeatedly in your life, it is a reminder that you are on the right path and that you are in tune with your purpose and mission in life.

https://t.me/bisx777
https://x.com/bisx777eth
*/

pragma solidity 0.8.25;

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

contract  BISX777  is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    
    string private constant _name = "BISX777";
    string private constant _symbol = "BISX";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1000000000  * 10**_decimals;

    address private _taxFeeWallet;
    uint256 private _buyTax = 5;
    uint256 private _sellTax = 15;

    uint256 public _maxWalletAmount = 20000000  * 10**_decimals;
    uint256 public _maxTxAmount = 20000000 * 10**_decimals;
    uint256 public _maxSwapAmount = 10000000  * 10**_decimals;

    bool private swapLimitOn = true;
    bool private tradeOpen;
    bool private inSwap = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    constructor () {
        uint256 tokenAmount = _tTotal.mul(12).div(100);
        _taxFeeWallet = _msgSender();

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _balances[_msgSender()] = _tTotal.sub(tokenAmount);
        _balances[address(this)] = tokenAmount;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance."));
        return true;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address.");
        require(spender != address(0), "ERC20: approve to the zero address.");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address.");
        require(to != address(0), "ERC20: transfer to the zero address.");
        require(amount > 0, "_transfer: Transfer amount must be greater than zero.");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "_transfer: Amount of transfer exceeds max transaction amount.");
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                require(tradeOpen,"_transfer: Trade is not yet open.");
                require(balanceOf(to) + amount <= _maxWalletAmount, "_transfer: Amount of transfer exceeds max wallet amount.");
                taxAmount = amount.mul(_buyTax).div(100);
            } else if (to == uniswapV2Pair){
                require(tradeOpen,"_transfer: Trade is not yet open.");
                taxAmount = amount.mul(_sellTax).div(100);
                uint256 contractTokenBalance = balanceOf(address(this));
                if (!inSwap && contractTokenBalance > 1 * 10**_decimals) {
                    uint256 getMinValue = (contractTokenBalance > _maxSwapAmount)?_maxSwapAmount:contractTokenBalance;
                    swapTokensForEth((amount > getMinValue)?getMinValue:amount);
                }
            } else {
                taxAmount = 0;
            }
        }
        uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance > 0.001 ether) {     
            sendETHToFeeWallet(address(this).balance);
        }
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(tokenAmount>_maxTxAmount) {
            tokenAmount = _maxTxAmount;
        }
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

    function sendETHToFeeWallet(uint256 amount) private {
        payable(_taxFeeWallet).transfer(amount);
    }

    function changeMaxSwapAmountAmount(uint256 amount) external onlyOwner {
        require(amount >= 20000000, "changeMaxSwapAmountAmount: Amount should be more than 20000000 tokens.");
        _maxSwapAmount = amount * 10**_decimals;
    }

    function changeMaxTransactionAmount(uint256 amount) external onlyOwner {
        require(amount >= 20000000, "changeMaxTransactionAmount: Amount should be more than 20000000 tokens.");
        _maxTxAmount = amount * 10**_decimals;
    }
    
    function changeMaxWalletAmount(uint256 amount) external onlyOwner {
        require(amount >= 1000000, "changeMaxWalletAmount: Amount should be more than 1000000 tokens.");
        _maxWalletAmount = amount * 10**_decimals;
    }

    function changeFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        require(buyFee <= 15, "changeBuyFee: buyFee shouldn't exceed 15%.");
        require(sellFee <= 15, "changeSellFee: sellFee shouldn't exceed 15%.");
        _buyTax = buyFee;
        _sellTax = sellFee;
    }

    function removeLimit() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletAmount=_tTotal;
        swapLimitOn = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function openTrade() external onlyOwner {
        require(!tradeOpen,"openTrading: Trading is already open.");
        tradeOpen = true;
    }

    function manualSwap() external {
        require(_msgSender()==_taxFeeWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFeeWallet(ethBalance);
        }
    }

    receive() external payable {}

}