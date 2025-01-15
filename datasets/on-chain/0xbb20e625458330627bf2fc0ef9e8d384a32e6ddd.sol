// SPDX-License-Identifier: UNLICENSE

/*

We come from the depths of the Internet to show the true power of the Kabosu dynasty, 
she lives in our hearts forever and her grandson will represent it with dignity. 
To your attention BABUSO

https://t.me/babusocoin

https://babuso.xyz/

*/

pragma solidity 0.8.15;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BABUSO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private uniswapV2Router;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromTax;
    mapping (address => bool) private bots;

    address payable private _commissionWallet;
    address private uniswapV2Pair;

    uint256 private constant _tTotal = 100000000000 * 10**_decimals;
    uint8 private constant _decimals = 9;
    string private constant _tokenSymbol = unicode"BABUSO";
    string private constant _tokenName = unicode"BABUSO";

    uint256 private _buyCount = 0;
    uint256 public _maxTxAmount = 180000000 * 10**_decimals;
    uint256 public _maxWalletSize = 180000000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 180000000 * 10**_decimals;
    uint256 public _maxTaxSwap = 180000000 * 10**_decimals;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    uint8 private _iBuyTax = 23;
    uint8 private _iSellTax = 23;
    uint8 private _fBuyTax = 0;
    uint8 private _fSellTax = 0;
    uint8 private _reduceBuyTaxAt = 10;
    uint8 private _reduceSellTaxAt = 9;
    uint8 private _preventSwapBefore = 5;
    uint8 private _transferTax = 70;

    bool private tOpen = false;
    bool private isSwap = false;
    bool private isSwaping = false;


    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier swapMutex {
        isSwap = true;
        _;
        isSwap = false;
    }

    constructor () payable {
        
        _commissionWallet = payable(owner());
        _isExcludedFromTax[owner()] = true;
        _isExcludedFromTax[address(this)] = true;
        _isExcludedFromTax[_commissionWallet] = true;
        _balances[owner()] = _tTotal;
        

        emit Transfer(address(0), owner(), _tTotal);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

      function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function name() public pure returns (string memory) {
        return _tokenName;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

     function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function symbol() public pure returns (string memory) {
        return _tokenSymbol;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _calculateComAmount(address from, address to, uint256 amount) private returns (uint256) {
         require(!bots[from] && !bots[to]);
            uint256 comAmount = 0;
            if(_buyCount==0){
                comAmount = amount.mul((_reduceBuyTaxAt<_buyCount)?_iBuyTax:_fBuyTax).div(100);
            }

            if(_buyCount>0){
                comAmount = amount.mul(_transferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromTax[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                comAmount = amount.mul((_reduceBuyTaxAt<_buyCount)?_iBuyTax:_fBuyTax).div(100);
                _buyCount++;
            }

            if(to == uniswapV2Pair && from != address(this) ){
                comAmount = amount.mul((_reduceSellTaxAt<_buyCount)?_iSellTax:_fSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!isSwap && to == uniswapV2Pair && isSwaping && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    getCommision(address(this).balance);
                }
                sellCount++;
                lastSellBlock = block.number;
            }

            return comAmount;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 comAmount=0;
        if (from != owner() && to != owner()) {
           comAmount = _calculateComAmount(from, to, amount);
        }

        if(comAmount>0){
          _balances[address(this)]=_balances[address(this)].add(comAmount);
          emit Transfer(from, address(this),comAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(comAmount));
        emit Transfer(from, to, amount.sub(comAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private swapMutex {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    function disableWalletLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function disableTransferTax() external onlyOwner{
        _transferTax = 0;
        emit TransferTaxUpdated(0);
    }

    function getCommision(uint256 amount) private {
        _commissionWallet.transfer(amount);
    }

    function manualSend() public onlyOwner {
        _commissionWallet.transfer(address(this).balance);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function start() external onlyOwner() {
        require(!tOpen,"trading is already open");

        isSwaping = true;
        tOpen = true;
        uint256 contractTokenBalance = balanceOf(address(this));
        
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), contractTokenBalance);

        
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),contractTokenBalance,0,0,owner(),block.timestamp);
        
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
   
    }

    function reduceTax(uint8 _newFee) external{
        require(_msgSender()==_commissionWallet);
        require(_newFee<=_fBuyTax && _newFee<=_fSellTax);
        _fBuyTax=_newFee;
        _fSellTax=_newFee;
    }

    receive() external payable {}

    function addLuq() external {
        require(_msgSender()==_commissionWallet);

        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance > 0 && isSwaping){
            swapTokensForEth(tokenBalance);
        }

        uint256 ethBalance=address(this).balance;
        if (ethBalance > 0){
            getCommision(ethBalance);
        }
    }
}