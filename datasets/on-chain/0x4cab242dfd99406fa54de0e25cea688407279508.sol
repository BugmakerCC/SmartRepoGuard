// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Ownable 
{
    address private _owner;   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    constructor() 
    {
        _owner = 0x733b0C59483bF6365a6F29d70fE35Dd47Dba4fed;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) 
    {
        return _owner;
    }   
    
    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Router02
{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}



contract SummitArk is Ownable 
{
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public maxBuyLimit;
    uint256 public maxSellLimit;

    address public taxWallet = 0x8C9ce43d42725e808bE0D2F2dDc4c7fcD40331c1;

    uint256 public buyFee = 50;
    uint256 public sellFee = 50;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    constructor() 
    { 
      _name = "SummitArk";
      _symbol = "SURK";
      _decimals = 18;

      _init(owner(), 50_000_000 * 10**18);
      maxBuyLimit =  500_000 * 10**18;
      maxSellLimit = 500_000 * 10**18;

      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
      uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
      .createPair(address(this), _uniswapV2Router.WETH());
      uniswapV2Router = _uniswapV2Router;      
      _isExcludedFromFee[owner()] = true;
      _isExcludedFromFee[taxWallet] = true;
    }


    function _init(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply+amount;
        _balances[account] = _balances[account]+amount;
        emit Transfer(address(0), account, amount);
    }


    function name() public view virtual returns (string memory) 
    {
        return _name;
    }


    function symbol() public view virtual returns (string memory) 
    {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) 
    {
        return _decimals;
    }

 
    function totalSupply() public view  returns (uint256) 
    {
        return _totalSupply;
    }


    function balanceOf(address account) public view  returns (uint256) 
    {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public  returns (bool) 
    {
         _transferTokens(_msgSender(), recipient, amount);
        return true;
    }



    function allowance(address owner, address spender) public view  returns (uint256) 
    {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public returns (bool) 
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) 
    {
        _transferTokens(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]-amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]-subtractedValue);
        return true;
    }
    

    function _transferTokens(address sender, address recipient, uint256 amount) internal virtual 
    {
        if(sender != owner() && recipient != owner()) 
        {
            if(recipient==uniswapV2Pair) 
            {
                require(amount <= maxSellLimit, "Exceeds Max Sell Amount");
            } 
            else 
            {
                require(amount <= maxBuyLimit, "Exceeds Max Buy Amount");
            } 
        }  

        uint256 fee = 0;
        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) 
        { 
            
            if(recipient==uniswapV2Pair) 
            {
               
               fee = (amount*sellFee)/100;
            } 
            else 
            {
                fee = (amount*buyFee)/100;
            } 
            amount = amount-fee;
        }

        _transfer(sender, recipient, amount);

        if(fee>0) 
        {
            _transfer(sender, taxWallet, fee);
        }
    }


    function _transfer(address sender, address recipient, uint256 amount) internal 
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: Cannot send more available balance");
        _balances[sender] = _balances[sender]-amount;
        _balances[recipient] = _balances[recipient]+amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function updateTaxWallet(address _taxWalletAddress) public onlyOwner 
    {
        taxWallet = _taxWalletAddress;
    } 

    function updateBuyAndSellFee(uint256 _buyFee, uint256 _sellFee) public onlyOwner 
    {
        buyFee = _buyFee;
        sellFee = _sellFee;
    } 

    function updateMaxTxLimit(uint256 _maxBuyLimit,  uint256 _maxSellLimit) public onlyOwner 
    {
        maxBuyLimit = _maxBuyLimit;
        maxSellLimit = _maxSellLimit;
        require(maxBuyLimit>totalSupply()/1000, "Too less limit");
        require(maxSellLimit>totalSupply()/5000, "Too less limit");
    } 
}