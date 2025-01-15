// SPDX-License-Identifier: UNLICENSE
// File: contracts/Grover/MyERC20.sol

pragma solidity ^0.8.20;

abstract contract Context2 {
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

library SafeMath2 {
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

contract Ownable2 is Context2 {
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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

contract MyERC20 is Context2, IERC20, Ownable2 {
    using SafeMath2 for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint8 private constant _decimals = 18;
    uint256 private _tTotal;
    string private _name;
    string private _symbol;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public tradingOpen;
    address public _creator;
    
    constructor (
        string memory initName,
        string memory initSymbol,
        uint256 initTotalSupply,
        address creator
    ) {
        _tTotal = initTotalSupply;
        _name = initName;
        _symbol = initSymbol;
        _creator = creator;

        //Ethereum
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        
        //Sepolia
        //uniswapV2Router = IUniswapV2Router02(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    }

    function distributeTokens(address[] calldata recipients, uint256[] calldata amounts, uint256 liquiditySupply) external onlyOwner returns(uint256) {
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");
        uint256 sum = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            _balances[recipients[i]] = amounts[i];
            sum = sum+amounts[i];
            emit Transfer(address(0), recipients[i], amounts[i]);
        }
        uint256 remainingTokens = _tTotal-sum;
        remainingTokens = remainingTokens > liquiditySupply ? liquiditySupply : remainingTokens;
        _balances[address(this)] = remainingTokens;
        emit Transfer(address(0), address(this), remainingTokens);
        return remainingTokens;
    }

    function addLiquidity(address poolOwner) external payable onlyOwner {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _approve(address(this), address(uniswapV2Pair), _tTotal);
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0, // Minimum amount of tokens to add
            0, // Minimum amount of ETH to add
            poolOwner,//address(0),
            block.timestamp
        );
        tradingOpen = true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
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
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount);
        emit Transfer(from, to, amount);
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    receive() external payable {}

    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(owner(), _amount);
    }
}

// File: contracts/GroverFactory.sol

pragma solidity ^0.8.20;


interface GroverFactory {
    
    event DEXTokenCreated(address tokenAddress, uint32 virtualId, string externalId);

    function createDEXToken(
        string memory name, 
        string memory symbol, 
        uint256 totalSupply,
        address[] calldata recipients, 
        uint256[] calldata amounts,
        uint256 cumulativeGas,
        address creator,
        address reimbursementAddress,
        uint256 liquiditySupply
    ) external payable returns (address);
}
// File: contracts/GroverFactory.sol


pragma solidity ^0.8.20;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    mapping(address => bool) private admins;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        admins[msgSender] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(admins[_msgSender()] == true, "Ownable: caller is not the owner");
        _;
    }

    function setAdmin(address _admin, bool isAdmin) external onlyOwner {
        admins[_admin] = isAdmin;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract GroverTokenFactory is Ownable, GroverFactory {
    event TokenCreated(address tokenAddress);
    error Overflow(uint8 z, uint8 x);
    uint256 public platformDEXFee = 1 ether / 5;
    uint256 public liquidityGas = 1 ether * 10 / 100;
    bool public enabled = true;

    function createDEXToken(
        string memory name, 
        string memory symbol, 
        uint256 totalSupply,
        address[] calldata recipients, 
        uint256[] calldata amounts,
        uint256 cumulativeGas,
        address creator,
        address reimbursementAddress,
        uint256 liquiditySupply
    ) external payable onlyAdmin returns (address) {
        uint256 startGas = gasleft();
        MyERC20 newToken = new MyERC20(name, symbol, totalSupply, creator);
        newToken.distributeTokens(recipients, amounts, liquiditySupply);

        uint256 gasUsed = startGas + cumulativeGas + 21000 - gasleft();
        
        uint256 gasCost = gasUsed * tx.gasprice; 
        uint256 reimbursementEth = gasCost + liquidityGas + platformDEXFee;
        uint256 liqAmount = msg.value - reimbursementEth;
        newToken.addLiquidity{value:liqAmount}(reimbursementAddress);

        (bool succ, ) = payable(reimbursementAddress).call{value: reimbursementEth}("");
        require(succ, "Transfer failed");

        return address(newToken);
    }

    function setPlatformDEXFee(uint256 _platformDEXFee) external onlyOwner {
        platformDEXFee = _platformDEXFee;
    }

    function setLiquidityGas(uint256 _liquidityGas) external onlyOwner {
        liquidityGas = _liquidityGas;
    }

    function setEnabled(bool _enabled) external onlyOwner {
        enabled = _enabled;
    }
}