/**
 *Submitted for verification at Etherscan.io on 2024-09-24
*/

/*

▗▖ ▗▖▗▄▄▖  ▗▄▖▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖    
▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▝▚▞▘   █  ▐▛▚▖▐▌    
▐▌ ▐▌▐▛▀▘ ▐▛▀▜▌ ▐▌    █  ▐▌ ▝▜▌    
▐▙█▟▌▐▌   ▐▌ ▐▌ ▐▌  ▗▄█▄▖▐▌  ▐▌    
                                

The new Wpayin cross-chain wallet seamlessly connects multiple blockchain worlds, 
offering a unified experience across Ethereum, TON, and Bitcoin.

Telegram: https://t.me/walletpayin
X: https://x.com/walletpayin

Docs: https://docs.walletpayin.com
Mini App: https://mini.walletpayin.com
Beta: https://beta.walletpayin.com
Website: https://walletpayin.com
Dapp: https://app.walletpayin.com

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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
        if (a == 0) return 0;
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
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract WPAYIN is IERC20, Ownable {
    using SafeMath for uint256;

    string public name = "WPAYIN";
    string public symbol = "WPI";
    uint8 public decimals = 9;
    uint256 public totalSupply = 100_000_000 * 10**decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) public allowance;

    address public feeRecipient1 = 0xf19D98f0d6797386E1D235492ebE8dd3bEE2ecD6;
    address public feeRecipient2 = 0x6704A086752b119959e8d07e1af6792594dB4ea3;
    uint256 public transactionFee = 3; // 3% total fee

    uint256 public maxWalletSize = totalSupply.div(100);  // 1% of total supply
    uint256 public maxTransferSize = totalSupply.div(100);  // 1% of total supply

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen = false;
    bool private inSwap = false;
    bool private swapEnabled = false;

    mapping(address => bool) private excludedFromFees;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    event FeesCollected(address indexed from, address indexed to1, address indexed to2, uint256 feeAmount1, uint256 feeAmount2);
    event FeeRecipient2Updated(address indexed previousRecipient, address indexed newRecipient);
    event LimitsRemoved();

    modifier checkMaxWallet(address to, uint256 amount) {
        require(_balances[to].add(amount) <= maxWalletSize, "Max wallet limit exceeded");
        _;
    }

    modifier checkMaxTransfer(uint256 amount) {
        require(amount <= maxTransferSize, "Max transfer limit exceeded");
        _;
    }

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public checkMaxWallet(to, amount) checkMaxTransfer(amount) returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public checkMaxWallet(to, amount) checkMaxTransfer(amount) returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal checkMaxWallet(recipient, amount) checkMaxTransfer(amount) {
        uint256 feeAmount1 = 0;
        uint256 feeAmount2 = 0;

        if (!excludedFromFees[sender] && !excludedFromFees[recipient]) {
            uint256 totalFeeAmount = amount.mul(transactionFee).div(100);
            feeAmount1 = totalFeeAmount.div(2);  // 1.5% to the first address
            feeAmount2 = totalFeeAmount.sub(feeAmount1); // 1.5% to the second address

            _balances[sender] = _balances[sender].sub(totalFeeAmount);
            _balances[feeRecipient1] = _balances[feeRecipient1].add(feeAmount1);
            _balances[feeRecipient2] = _balances[feeRecipient2].add(feeAmount2);

            emit FeesCollected(sender, feeRecipient1, feeRecipient2, feeAmount1, feeAmount2);

            amount = amount.sub(totalFeeAmount);
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // Add _approve function
    function _approve(address owner, address spender, uint256 amount) internal {
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMaxWalletSize(uint256 newMaxWallet) external onlyOwner {
        require(newMaxWallet <= totalSupply, "Max wallet size cannot exceed total supply");
        maxWalletSize = newMaxWallet;
        emit MaxTxAmountUpdated(newMaxWallet);
    }

    function setMaxTransferSize(uint256 newMaxTransfer) external onlyOwner {
        require(newMaxTransfer <= totalSupply, "Max transfer size cannot exceed total supply");
        maxTransferSize = newMaxTransfer;
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        excludedFromFees[account] = excluded;
    }

    function openTrading() external payable onlyOwner {
        require(!tradingOpen, "Trading is already open");
        
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uint256 tokenAmount = totalSupply.mul(60).div(100);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: 2 ether}(
            address(this), 
            tokenAmount, 
            0, 
            0, 
            owner(), 
            block.timestamp
        );

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        
        swapEnabled = true;
        tradingOpen = true;
    }

    function setTransactionFee(uint256 newFee) external onlyOwner {
        require(newFee <= 100, "Fee too high");
        transactionFee = newFee;
        emit TransferTaxUpdated(newFee);
    }

    function setFeeRecipient2(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid address");
        address oldRecipient = feeRecipient2;
        feeRecipient2 = newRecipient;
        emit FeeRecipient2Updated(oldRecipient, newRecipient);
    }

    function removeLimits() external onlyOwner {
        maxWalletSize = totalSupply;
        maxTransferSize = totalSupply;
        emit LimitsRemoved();
    }
}