/**
    $VPU - Valve AI, Virtual Private GPUs powering on-chain AI and decentralized web hosting.

    https://valveai.org
    https://twitter.com/valveai_
    https://t.me/valveai
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
}

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.20;

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

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
}


pragma solidity ^0.8.20;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity ^0.8.20;

interface IUniswapV2Pair {
    function mint(address to) external returns (uint liquidity);
}

pragma solidity ^0.8.20;


contract ValveAI is ERC20, Ownable {
    enum FeesTier {
        HIGH_FEES, // 25/25 initial fees
        MEDIUM_FEES, // 5/5 regular fees
        NO_FEES // 0/0 CEX fee
    }

    uint private constant HIGH_FEES_DURATION = 60 * 8; // High fee duration
    uint private constant LIMITS_DURATION = 60 * 4; // Max Tx Limit duration
    uint private constant BASE_TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    uint public constant MAX_TX_AMOUNT = (15 * BASE_TOTAL_SUPPLY) / 1000; // 1.5% Max Tx
    uint public constant MAX_WALLET_AMOUNT = (15 * BASE_TOTAL_SUPPLY) / 1000; // 1.5% Max Wallet
    uint private constant LIQUIDITY_AMOUNT = (50 * BASE_TOTAL_SUPPLY) / 100; // DEX Liquidity (50% + 25% Clog)
    uint private constant MARKETING_AMOUNT = (7 * BASE_TOTAL_SUPPLY) / 100; // Marketing Wallet 1 (7%)
    uint private constant MARKETING_AMOUNT_2 = (8 * BASE_TOTAL_SUPPLY) / 100; // Marketing Wallet 2 (8%)
    uint private constant PROJECT_AMOUNT = (10 * BASE_TOTAL_SUPPLY) / 100; // Project Tokens (10%)

    address private marketingWallet = address(0x18D699d47c9a9Bb9c7F4C7b753b6229F1578a797);
    address private marketingWallet2 = address(0x1cE9ef2c5010730BF58Bd02e4e197c484B9bC1A9);
    address private projectWallet = address(0x24ecB6E96100e95d78B13f783b16aef26A45a650);

    uint public launchTimestamp;

    address public stakingContract;
    address public feeRecipient;
    address public immutable WETH;
    address public immutable uniswapPair;
    IUniswapV2Factory public immutable uniswapFactory;
    IUniswapV2Router02 constant uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool private _swapping;
    bool public transferTaxActive = true;

    FeesTier public feesTier;

    constructor () Ownable(msg.sender) ERC20("Valve AI", "VPU") {
        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
        WETH = uniswapRouter.WETH();
        uniswapPair = uniswapFactory.createPair(address(this), WETH);
        feeRecipient = msg.sender;
        stakingContract = address(this); // Placeholder
        _mint(address(this), BASE_TOTAL_SUPPLY);
        _transfer(address(this), marketingWallet, MARKETING_AMOUNT);
    }

    modifier lockSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    function removeFees() external {
        require(msg.sender == feeRecipient, "Unauthorized");
        require(feesTier != FeesTier.NO_FEES);
        feesTier = FeesTier.NO_FEES;
    }

    function removeTransferTax() external {
        require(msg.sender == feeRecipient, "Unauthorized");
        transferTaxActive = false;
    }

    function setStaking(address _stakingContract) external {
        require(msg.sender == feeRecipient, "Unauthorized");
        stakingContract = _stakingContract;
    }

    function setFeeRecipient(address _feeRecipient) external {
        require(msg.sender == feeRecipient, "Unauthorized");
        feeRecipient = _feeRecipient;
    }

    function launchVPU() external payable lockSwap onlyOwner {
        require(launchTimestamp == 0, "VPU has already been launched.");

        launchTimestamp = block.timestamp;

        _approve(address(this), address(uniswapRouter), LIQUIDITY_AMOUNT); // mint liquidity amount to the pair
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this), LIQUIDITY_AMOUNT, 0, 0, msg.sender, block.timestamp); 
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (_swapping) return super._transfer(sender, recipient, amount);

        uint fees = _takeFees(sender, recipient, amount);
        if (fees != 0) {
            super._transfer(sender, address(this), fees);
            amount -= fees;
        }

        if (recipient == uniswapPair) _swapFees(amount);

        super._transfer(sender, recipient, amount);
    }

    // return fees amount taken from the transfer (and check for tx and wallet limits)
    function _takeFees(address sender, address recipient, uint amount) private returns (uint) {
        if (
            sender == address(this) 
            || recipient == address(uniswapRouter) 
            || recipient == stakingContract 
            || sender == stakingContract
            || recipient == marketingWallet 
            || sender == marketingWallet
            || recipient == marketingWallet2 
            || sender == marketingWallet2
            || recipient == projectWallet 
            || sender == projectWallet
            ) return 0;        

        // ensure max tx and max wallet
        if (limitsActive() && (sender == uniswapPair || (sender != uniswapPair && recipient != uniswapPair))) {
            require(amount <= MAX_TX_AMOUNT, "Max tx amount reached");
            require(balanceOf(recipient) + amount <= MAX_WALLET_AMOUNT, "Max wallet amount reached");
        }

        if (transferTaxActive && sender != uniswapPair && recipient != uniswapPair) return amount / 2;

        if (feesTier == FeesTier.NO_FEES) return 0; // 0% fees
        else if (feesTier == FeesTier.MEDIUM_FEES) return amount / 20; // 5% fees

        // else, token is at high fees tier and we check if we can change tier and return correct fees
        else {
            if (block.timestamp - launchTimestamp > HIGH_FEES_DURATION) {
                feesTier = FeesTier.MEDIUM_FEES;
                return amount / 20; // 5% fees
            }
            return amount / 4; // 25% fees
        }
    }

    // swap some fees tokens to eth
    function _swapFees(uint maxAmount) private lockSwap {
        uint tokenAmount = min(min(maxAmount, balanceOf(address(this))), totalSupply() / 100);
        if (tokenAmount < 1e18) return; // prevent too small swaps

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            feeRecipient,
            block.timestamp
        );
    }   

    // return true if max wallet and max tx limitations are still active
    function limitsActive() public view returns (bool) {
        return block.timestamp - launchTimestamp <= LIMITS_DURATION;
    }
    
    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}