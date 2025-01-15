// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes memory) {this; return msg.data;}
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {_name = name_; _symbol = symbol_;}
    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function decimals() public view virtual override returns (uint8) {return 18;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}
    function transfer(address to, uint256 amount) public virtual override returns (bool) {_transfer(_msgSender(), to, amount); return true;}
    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {_approve(_msgSender(), spender, amount); return true;}
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {_spendAllowance(from, _msgSender(), amount); _transfer(from, to, amount); return true;}
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {_approve(_msgSender(), spender, allowance(_msgSender(), spender) + addedValue); return true;}
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = allowance(_msgSender(), spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {_approve(_msgSender(), spender, currentAllowance - subtractedValue);}
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0) && to != address(0), "ERC20: transfer from/to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {_balances[account] += amount;}
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0) && spender != address(0), "ERC20: approve from/to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {_approve(owner, spender, currentAllowance - amount);}
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Pair {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Sync(uint112 reserve0, uint112 reserve1);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function sync() external;
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external view returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) { return _owner; }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "You are not owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Use renounce function");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }
}

contract Depicted is IERC20, Ownable {
    string private constant _name = "Depicted";
    string private constant _symbol = "DPT";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 250000000 * (10**_decimals); // 250,000,000

    address public WBNB;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Remove from fee collection mapping
    mapping(address => bool) public isFeeExempt;

    // Blacklist mapping
    mapping(address => bool) public isBlacklisted;

    // Remove from trading enabled check
    mapping(address => bool) public isAuthorized;
    
    // Remove from transaction and wallet limits mapping
    mapping (address => bool) public isExcludedFromTransactionLimitChecks;

    // Buy fees
    uint256 public buyWallet1Fee = 2;
    uint256 public buyWallet2Fee = 2;
    uint256 public buyWallet3Fee = 1;
    uint256 public buyLiquidityFee = 1;
    uint256 public buyTotalFees = 6;

    // Sell fees
    uint256 public sellWallet1Fee = 2;
    uint256 public sellLiquidityFee = 2;
    uint256 public sellWallet2Fee = 1;
    uint256 public sellWallet3Fee = 1;
    uint256 public sellTotalFees = 6;

    // Tax collection counter
    uint256 public tokenForWallet1 = 0;
    uint256 public tokenForWallet2 = 0;
    uint256 public tokenForWallet3 = 0;
    uint256 public tokenForLiquidity = 0;

    // Fee receiver
    address public wallet1FeeReceiver;
    address public wallet2FeeReceiver;
    address public wallet3FeeReceiver;

    IUniswapV2Router02 public router;
    address public pair;

    bool public tradingOpen = false;
    uint256 public maxTransactionLimitBuy;
    uint256 public maxTransactionLimitSell;
    uint256 public maxWalletLimit;

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 1) / 10000; // 0.01% of supply
    bool private inSwap;
    bool public transactionLimitsInEffect = true;

    // Modifiers
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Events
    event TradingEnabled(bool enabled);
    event BlacklistUpdated(address indexed _address, bool isBlacklisted);
    event ETHCleared(address indexed wallet, uint256 amount);
    event TokensCleared(address indexed tokenAddress, address indexed wallet, uint256 amount);
    event BuyFeesUpdated(uint256 wallet1, uint256 liquidity, uint256 wallet2, uint256 wallet3);
    event SellFeesUpdated(uint256 wallet1, uint256 liquidity, uint256 wallet2, uint256 wallet3);
    event MaxTransactionLimitUpdated(uint256 maxTransactionLimitBuy, uint256 maxTransactionLimitSell);
    event MaxWalletLimitUpdated(uint256 newMaxWalletLimit);
    event TransactionLimitsRemovedForever();
    event TaxCounterReset();
    event AuthorizationStatusUpdated(address indexed account, bool isAuthorized);
    event FeeExemptionStatusUpdated(address indexed holder, bool isFeeExempt);
    event ExcludedFromTransactionLimitChecks(address indexed holder, bool exempt);
    event Wallet1ReceiverUpdated(address indexed newReceiver);
    event Wallet2ReceiverUpdated(address indexed newReceiver);
    event Wallet3ReceiverUpdated(address indexed newReceiver);
    event SwapBackSettingsUpdated(bool enabled, uint256 amount);
    event SwapFailed(string message);
    event LiquidityAddedFailed(string message);

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap 
        WBNB = router.WETH();
        pair = IUniswapV2Factory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        maxTransactionLimitBuy = _totalSupply * 1 / 100; // 1% of total supply is maxTransactionLimitBuy
        maxTransactionLimitSell = _totalSupply * 1 / 100; // 1% of total supply is maxTransactionLimitSell
        maxWalletLimit = _totalSupply * 2 / 100; // 2% of total supply is maxWalletLimit

        isFeeExempt[msg.sender] = true;
        isFeeExempt[owner()] = true;
        isAuthorized[owner()] = true;
        isExcludedFromTransactionLimitChecks[address(this)] = true;
        isExcludedFromTransactionLimitChecks[owner()] = true;
        isExcludedFromTransactionLimitChecks[DEAD] = true;
        isExcludedFromTransactionLimitChecks[ZERO] = true;
        wallet1FeeReceiver = 0x04662A7067d9Af5bd87fBcf7ec82574a8BB60Df4;
        wallet2FeeReceiver = 0x982FB4769216023fAce96a4e6Aa700a9cF4d0cC5;
        wallet3FeeReceiver = 0x7A3b40CB8B1ADDb9BFCF2BD8D1F1CB91c0AE279d;
        // One time supply transfer
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // Fallback
    receive() external payable {}

    // Basic ERC20 override
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
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

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) internal returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    // Burn tokens from the owner's balance
    function burn(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(_balances[msg.sender] >= amount, "Insufficient balance to burn");
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // Open trading function
    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        tradingOpen = true;
        emit TradingEnabled(true);
    }

    // Update blacklist status
    function updateBlacklistStatus(address _address, bool _isBlacklisted) external onlyOwner {
        require(_address != address(0), "Invalid address");
        require(_address != owner(), "Cannot blacklist the owner");
        isBlacklisted[_address] = _isBlacklisted;
        emit BlacklistUpdated(_address, _isBlacklisted);
    }

    function clearETH() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH in contract");
        payable(msg.sender).transfer(amount);
        emit ETHCleared(msg.sender, amount);
    }

    // WARNING: Use this function with trusted tokens only
    function clearTokens(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(this), "Cannot clear native tokens");
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token in contract");
        token.transfer(msg.sender, balance);
        emit TokensCleared(tokenAddress, msg.sender, balance);
    }

    // Buy fees setter
    function updateBuyFees(uint256 wallet1, uint256 liquidity, uint256 wallet2, uint256 wallet3) external onlyOwner {
        buyWallet1Fee = wallet1;
        buyLiquidityFee = liquidity;
        buyWallet2Fee = wallet2;
        buyWallet3Fee = wallet3;
        buyTotalFees = wallet1 + liquidity + wallet2 + wallet3;
        require(buyTotalFees <= 10, "Buy fees can not be greater than 10%");
        emit BuyFeesUpdated(wallet1, liquidity, wallet2, wallet3);
    }

    // Sell fees setter
    function updateSellFees(uint256 wallet1, uint256 liquidity, uint256 wallet2, uint256 wallet3) external onlyOwner {
        sellWallet1Fee = wallet1;
        sellLiquidityFee = liquidity;
        sellWallet2Fee = wallet2;
        sellWallet3Fee = wallet3;
        sellTotalFees = wallet1 + liquidity + wallet2 + wallet3;
        require(sellTotalFees <= 10, "Sell fees can not be greater than 10%");
        emit SellFeesUpdated(wallet1, liquidity, wallet2, wallet3);
    }

    // Maximum transaction limits setter for both buy and sell
    function updateMaxTransactionLimits(uint256 _amountBuy, uint256 _amountSell) external onlyOwner {
        uint256 minimumLimit = (_totalSupply * 1 / 1000) / (10**_decimals);
        require(_amountBuy >= minimumLimit, "Cannot set maxTransactionLimitBuy lower than 0.1% of total supply");
        require(_amountSell >= minimumLimit, "Cannot set maxTransactionLimitSell lower than 0.1% of total supply");
        maxTransactionLimitBuy = _amountBuy * (10**_decimals);
        maxTransactionLimitSell = _amountSell * (10**_decimals);
        emit MaxTransactionLimitUpdated(maxTransactionLimitBuy, maxTransactionLimitSell);
    }

    // Maximum wallet limit setter
    function updateMaxWalletLimit(uint256 _amount) external onlyOwner {
        require(_amount >= (_totalSupply * 1 / 100) / (10**_decimals), "Cannot set maxWalletLimit lower than 1% of total supply");
        maxWalletLimit = _amount * (10**_decimals);
        emit MaxWalletLimitUpdated(maxWalletLimit);
    }

    // Reset tax counter to zero
    function resetTaxCounter() external onlyOwner {
        tokenForWallet1 = 0;
        tokenForWallet2 = 0;
        tokenForWallet3 = 0;
        tokenForLiquidity = 0;
        emit TaxCounterReset();
    }

    // Clear transaction and wallet limits forever
    function removeTransactionLimitsForever() external onlyOwner {
        require(transactionLimitsInEffect, "Transaction limits already removed");
        transactionLimitsInEffect = false;
        emit TransactionLimitsRemovedForever();
    }

    // Exemptions
    function setIsAuthorized(address value, bool exempt) external onlyOwner {
        isAuthorized[value] = exempt;
        emit AuthorizationStatusUpdated(value, exempt);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        emit FeeExemptionStatusUpdated(holder, exempt);
    }

    function excludeFromTransactionLimitChecks(address holder, bool exempt) public onlyOwner {
        isExcludedFromTransactionLimitChecks[holder] = exempt;
        emit ExcludedFromTransactionLimitChecks(holder, exempt);
    }

    // Receivers
    function setWallet1Receiver(address _wallet1FeeReceiver) external onlyOwner {
        wallet1FeeReceiver = _wallet1FeeReceiver;
        emit Wallet1ReceiverUpdated(_wallet1FeeReceiver);
    }

    function setWallet2Receiver(address _wallet2FeeReceiver) external onlyOwner {
        wallet2FeeReceiver = _wallet2FeeReceiver;
        emit Wallet2ReceiverUpdated(_wallet2FeeReceiver);
    }

    function setWallet3Receiver(address _wallet3FeeReceiver) external onlyOwner {
        wallet3FeeReceiver = _wallet3FeeReceiver;
        emit Wallet3ReceiverUpdated(_wallet3FeeReceiver);
    }

    // Swapback settings
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        require(_amount > 2500, "Swap threshold must be greater than 2500");
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit SwapBackSettingsUpdated(_enabled, _amount);
    }

    // Manually trigger tax distribution
    function manualTaxSwap() external onlyOwner {
        uint256 contractTokenBalance = _balances[address(this)];
        require(contractTokenBalance > 0, "No tokens to swap");
        require(!inSwap, "Already in swap");
        swapBack();
    }

    // Internal and Private functions
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isBlacklisted[sender], "Sender is blacklisted");
        require(!isBlacklisted[recipient], "Recipient is blacklisted");
        if (inSwap) {return _basicTransfer(sender, recipient, amount);}
        require(isAuthorized[sender] || isAuthorized[recipient] || tradingOpen, "Trading is not open yet");
        if (shouldSwapBack()) {swapBack();}

        if (transactionLimitsInEffect && !isAuthorized[sender] && !isAuthorized[recipient]) {
            require(sender != owner() && recipient != owner() && recipient != address(0) && recipient != address(DEAD), "Invalid addresses");
            if (sender == pair) { // Buy transaction
                if (!isExcludedFromTransactionLimitChecks[recipient]) {
                    require(amount <= maxTransactionLimitBuy, "Buy exceeds limit");
                    require(_balances[recipient] + amount <= maxWalletLimit, "Wallet exceeds limit");
                }
            } else if (recipient == pair) { // Sell transaction
                if (!isExcludedFromTransactionLimitChecks[sender]) {
                    require(amount <= maxTransactionLimitSell, "Sell exceeds limit");
                }
            } else { // For other transfers
                if (!isExcludedFromTransactionLimitChecks[recipient]) {
                    require(_balances[recipient] + amount <= maxWalletLimit, "Transfer exceeds limit");
                }
            }
        }

        _balances[sender] -= amount;
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount, recipient) : amount;
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function takeFee(address sender, uint256 amount, address to) internal returns (uint256) {
        uint256 feeAmount = (to == pair) ? (amount * sellTotalFees) / 100 : (sender == pair ? (amount * buyTotalFees) / 100 : 0);
        if (feeAmount == 0) return amount;
        _balances[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        distributeFee(feeAmount, to == pair);
        return amount - feeAmount;
    }

    function distributeFee(uint256 feeAmount, bool isSell) internal {
        uint256 wallet1Part = (feeAmount * (isSell ? sellWallet1Fee : buyWallet1Fee)) / (isSell ? sellTotalFees : buyTotalFees);
        uint256 wallet2Part = (feeAmount * (isSell ? sellWallet2Fee : buyWallet2Fee)) / (isSell ? sellTotalFees : buyTotalFees);
        uint256 wallet3Part = (feeAmount * (isSell ? sellWallet3Fee : buyWallet3Fee)) / (isSell ? sellTotalFees : buyTotalFees);
        uint256 liquidityPart = feeAmount - (wallet1Part + wallet2Part + wallet3Part);

        tokenForWallet1 += wallet1Part;
        tokenForWallet2 += wallet2Part;
        tokenForWallet3 += wallet3Part;
        tokenForLiquidity += liquidityPart;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            tradingOpen &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 totalTokensToSwap = tokenForWallet1 + tokenForWallet2 + tokenForWallet3 + tokenForLiquidity;
        if (totalTokensToSwap == 0) return;  // If there's nothing to swap, just return
        uint256 liquidityTokens = (tokenForLiquidity * _balances[address(this)]) / (2 * totalTokensToSwap);
        uint256 amountToSwapForETH = _balances[address(this)] - liquidityTokens;
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH);
        uint256 newETHBalance = address(this).balance;
        uint256 ethBalanceChange = newETHBalance - initialETHBalance;
        distributeETH(ethBalanceChange, liquidityTokens, totalTokensToSwap);
    }

    function distributeETH(uint256 ethBalance, uint256 liquidityTokens, uint256 totalTokensToSwap) private {
        uint256 ethForWallet1 = ethBalance * tokenForWallet1 / totalTokensToSwap;
        uint256 ethForWallet2 = ethBalance * tokenForWallet2 / totalTokensToSwap;
        uint256 ethForWallet3 = ethBalance * tokenForWallet3 / totalTokensToSwap;
        uint256 ethForLiquidity = ethBalance - (ethForWallet1 + ethForWallet2 + ethForWallet3);

        sendETH(wallet1FeeReceiver, ethForWallet1);
        sendETH(wallet2FeeReceiver, ethForWallet2);
        sendETH(wallet3FeeReceiver, ethForWallet3);

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
        }
    }

    function sendETH(address to, uint256 amount) private {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "ETH Transfer failed");
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {} catch {emit SwapFailed("Failed to swap tokens for ETH");}
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(router), tokenAmount);
        try router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        ) {} catch {emit LiquidityAddedFailed("Failed to add liquidity");}
    }
}