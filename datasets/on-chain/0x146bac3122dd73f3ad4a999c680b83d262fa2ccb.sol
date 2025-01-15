// SPDX-License-Identifier: MIT

/*
Decentralized Trading Maximum Control
OptionFI is an innovative decentralized binary trading platform 
built on the Ethereum blockchain.

Website: https://optionfi.io/
Documentation: https://docs.optionfi.io/
X / Twitter : https://x.com/Option_Fi
Telegram : https://t.me/OptionFiOfficial
*/

pragma solidity ^0.8.24;

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

contract OptionFI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isdevWallet;
    mapping (address => uint256) private _stakedBalances;
    mapping (address => uint256) private _stakeTimestamps;

    address payable private _receiverFeeWallet;

    uint256 private _initialBuyFee=20;
    uint256 private _initialSellFee=25;
    uint256 private _finalBuyFee=10;
    uint256 private _finalSellFee=25;

    uint256 private _reduceBuyFeeAt=19;
    uint256 private _reduceSellFeeAt=25;
    uint256 private _restrictSwapBefore=30;
    uint256 private _caTransferTax=0;

    uint256 private _caCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10**_decimals;
    string private constant _name = unicode"OptionFI";
    string private constant _symbol = unicode"OFI";

    uint256 public _initialMaxTx =  1 * (_tTotal/100);
    uint256 public _initialWalletSize =  1 * (_tTotal/100);
    uint256 public _swapThreshold=  1 * (_tTotal/1000);
    uint256 public _maxTaxSwap= 1 * (_tTotal/100);

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private totalBuyTx = 0;
    uint256 private maxSellBlock = 0;
    event MaxTxAmountUpdated(uint _initialMaxTx);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _receiverFeeWallet = payable(0x33B34f955610D95e895d56EE78a1873e93723e5e);
        _balances[_msgSender()] = _tTotal;
        _isdevWallet[owner()] = true;
        _isdevWallet[address(this)] = true;
        _isdevWallet[_receiverFeeWallet] = true;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            
            if(_caCount==0){
                taxAmount = amount.mul((_caCount>_reduceBuyFeeAt)?_finalBuyFee:_initialBuyFee).div(100);
            }
            if(_caCount>0){
                taxAmount = amount.mul(_caTransferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isdevWallet[to] ) {
                require(amount <= _initialMaxTx, "Exceeds the _initialMaxTx.");
                require(balanceOf(to) + amount <= _initialWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_caCount>_reduceBuyFeeAt)?_finalBuyFee:_initialBuyFee).div(100);
                _caCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_caCount>_reduceSellFeeAt)?_finalSellFee:_initialSellFee).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _swapThreshold && _caCount > _restrictSwapBefore) {
                if (block.number > maxSellBlock) {
                    totalBuyTx = 0;
                }
                require(totalBuyTx < 4, "Only 4 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                totalBuyTx++;
                maxSellBlock = block.number;
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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

    function unlockMaxWallet() external onlyOwner{
        _initialMaxTx = _tTotal;
        _initialWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _receiverFeeWallet.transfer(amount);
    }

    function rescueEthereum() external {
        require(_msgSender() == _receiverFeeWallet);
        payable(_receiverFeeWallet).transfer(address(this).balance);
    }

    function rescueERC20(address _tokenAddr, uint _amount) external {
        require(_msgSender() == _receiverFeeWallet);
        IERC20(_tokenAddr).transfer(_receiverFeeWallet, _amount);
    }


    function startTrade() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
    }
    
    function getContractETHBalance() external view returns (uint256) {
    return address(this).balance;
    
    }

    function setTax (uint256 _value) external onlyOwner returns (bool) {
        _finalBuyFee = _value;
        _finalSellFee = _value;
        require(_value <= 4,"Tax cannot exceed 5");
        return true;
    }

    function updateReceiverFeeWallet(address payable newWallet) external onlyOwner {
    require(newWallet != address(0), "New wallet address cannot be zero");
    _receiverFeeWallet = newWallet;
    
    }

    receive() external payable {}

    function clearStuckClog() external {
        require(_msgSender()==_receiverFeeWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function clearStuckEther() external {
        require(_msgSender()==_receiverFeeWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}