// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

/*

                                           ░                                    
                             ░ ░░░▒▒░▒▓░▒▒▒░▒▒░░░ ░                             
                    ░  ░▒░░░▒▒▓▓▒▒▒░▒▒▒▒░▓▓▒░▓▒▒▓▓▒▒░ ▒                         
                    ░░░▒░░▒░▒░░░░▓▒▒▒▓░▒▓░░░▓░▒▓▒▓▓▒▒▒▒▓░░░                     
                ░░▒░ ░▒░▓▓░▓▒░░░░▒▒░▓▒░▓▓░▒▓▓▒▒▓▒▓▒▒▒░▒▓░░░░                    
               ░░░▒▒▒▓▒░░▒▒▒▓▒▒▒▒▓▓▒▒▒▒▒▓▓▓▓▓▓▓▒▒▒▒▓▒░▒░▓▓▓▓▓▒▒ ░               
                ▓▒░░▒▓▓▓▓▒▒▒▒▓░░▒░▒▓▒▒▓▓▓▓▓▓▒▒▓▒▒▓▓▒▒▒▓▓█▒▓▓░▓▒░▓ ░             
           ░  ░░░▓▒▒░▒░░░░░▒▓▓█▓▓▓░▒▓▓▓▓░░░▓▓▓▓▓░▓▓▓▓▓▓▒▒▓▒▒▓▒█▓▒▒              
           ░░░ ░░░░▒▒▓▓░▒▒▒▒░▓▒▒▓▒░░░▒▒▒▒░░░▒▒░░▒▓▓▓▓▓▓▓▒▒▒▒▒▓▒▒▒░              
               ░░▒░░░░▒▒░▓░░▒▒▓▓▒▓▒▓▓░░▓▓▓▓▓▓▒▓▓▓▓▓▓▒░░▒▒░░▒░░░░░               
       ░░ ░░░░░░░▓▒░░░░░░░░░░░░▒▓▒▓░░▓░░▓▒░░░░  ░░▒▒░                           
       ░ ░░ ░░░▒░░░▓▒░░ ░░▒░░░░░▒▒░░░░░░░░░░      ░░   ░░░░░                    
       ░░░░░░░░░░░░░░░░░ ░░░░░░░ ░░░░                   ░▒█▓▓▒░                 
       ░░░░░▒░▒▒▒░░░░░░░░░    ░░░░                      ░▒▓▓▒▒▒▒▒░░             
        ░░░░░░░▒▒░░░░ ░░░░░░░ ░                    ░░ ░░░░▒▒▒▒▒▒▒░▒             
        ░░░░░░░░░░░░░░     ░   ░    ░       ░░░░░░ ░░░░░░░░░▒▒▒▒▒▒▒▒            
       ░  ░░░░░░░░░░░░░░░░░░░        ░░░░░░░░░░            ░▒▒▒▒▒▓▓█▓           
      ▒▒               ░░░░░░░░   ░ ░░░░░ ░▒▒░                    ▒▒░           
     ░▒▒                   ░▓▒▒       ░░░░▓▓░                                   
     ▓▓▒                    ░▓▓▓▒      ░▒▒▒                                     
    ░▓▓▓▒                      ▓▓█▓█▒    ▒▒▒▒▒▒░                                
                                                                  

    Her name is Shrub, the Hedgehog
    https://x.com/elonmusk/status/1852944795431227448
*/

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

contract Shrub is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    address payable private _taxWallet;

    IUniswapV2Router02 private _uniRouter;
    address private _uniPair;

    string private constant _symbol = unicode"Shrub";
    string private constant _name = unicode"Shrub The Hedgehog";

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 420_690_000_000 * 10 **_decimals;
    uint256 private constant _tTreasury = 4 * (_tTotal/100);

    uint256 private constant INIT_BUY_TAX = 10;
    uint256 private constant INIT_SELL_TAX = 10;
    uint256 private _buyTax = INIT_BUY_TAX;
    uint256 private _sellTax = INIT_SELL_TAX;

    uint256 public maxTxAmount =  2 * (_tTotal/100);
    uint256 public maxWalletSize =  2 * (_tTotal/100);
    uint256 public taxSwapThreshold =  1 * (_tTotal/1000);
    uint256 public maxTaxSwap = 1 * (_tTotal/100);
    
    bool private _tradingOpen;
    bool private _inSwap = false;
    bool private _swapEnabled = false;
    uint256 private _sellCount = 0;
    uint256 private _lastSellBlock = 0;

    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        
        _balances[_msgSender()] = _tTreasury;
        _balances[address(this)] = _tTotal - _tTreasury;

        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[address(this)] = true;
 
        _uniRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _uniPair = IUniswapV2Factory(_uniRouter.factory()).createPair(address(this), _uniRouter.WETH());
        IERC20(_uniPair).approve(address(_uniRouter), type(uint).max);

        emit Transfer(address(0), _msgSender(), _tTreasury);
        emit Transfer(address(0), address(this), _tTotal - _tTreasury);
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

        uint256 taxAmount = 0;
        if ( from != owner() && to != owner() ) {

            // buy
            if ( from == _uniPair && to != address(_uniRouter) && ! _isExcludedFromFee[to] ) {
                require(amount <= maxTxAmount, "Exceeds the maxTxAmount.");
                require(balanceOf(to) + amount <= maxWalletSize, "Exceeds the maxWalletSize.");
                if ( _buyTax > 0 ) {
                    taxAmount = amount.mul(_buyTax).div(100);
                }
            } else if ( to == _uniPair && from != address(this) ){ // sell
                if ( _sellTax > 0 ) {
                    taxAmount = amount.mul(_sellTax).div(100);
                }
            }

            // swap
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == _uniPair && _swapEnabled && contractTokenBalance > taxSwapThreshold) {
                if (block.number > _lastSellBlock) {
                    _sellCount = 0;
                }
                require(_sellCount < 3, "Only 3 sells per block!");
                swapTokensForEth(min(amount, min(contractTokenBalance, maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                _sellCount++;
                _lastSellBlock = block.number;
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this), taxAmount);
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
        path[1] = _uniRouter.WETH();
        _approve(address(this), address(_uniRouter), tokenAmount);
        _uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function updateTax(uint256 buy_, uint256 sell_) external onlyOwner {
        require(buy_ <= INIT_BUY_TAX && sell_ <= INIT_SELL_TAX);
        _buyTax = buy_;
        _sellTax = sell_;
    }

    function removeLimit() external onlyOwner{
        maxTxAmount = _tTotal;
        maxWalletSize = _tTotal;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!_tradingOpen,"trading is already open");
        _approve(address(this), address(_uniRouter), _tTotal);
        _uniRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingOpen = true;
    }

    receive() external payable {}

    function rescueStuckToken() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function rescueStuckETH() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}