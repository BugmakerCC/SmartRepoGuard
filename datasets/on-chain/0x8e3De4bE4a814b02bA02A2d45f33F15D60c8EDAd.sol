// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// FTSE999
//
//  Introducing a revolutionary new way to invest.
//  Due to our partnership with Vanguard, and the London Stock Exchange,
//  we are making it possible, for the first time in human history,
//  to invest in stock market assets entirely on the blockchain.
//
//  We are committed to full anonymity, privacy, and low trading fees.
//  Join the world of stock-market investing on Ethereum on:
//
//   Our website: https://ftse999.com/
//   Telegram: https://t.me/ftse999
//   X (formerly known as Twitter): https://x.com/FTSE999
abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FTSEToken is IERC20, Ownable {
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    IDEXRouter public router;
    address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    string constant _name = "FTSE999";
    string constant _symbol = "FTSE";
    uint8 constant _decimals = 18;

    uint256 constant _totalSupply = 999_999_999 * (10 ** _decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) liquidityCreator;
    mapping(address => bool) liquidityPools;
    address public immutable pair;

    uint256 liquidityFee = 100;
    uint256 marketingFee = 900;
    uint256 totalFee = liquidityFee + marketingFee;
    uint256 feeDenominator = 10000;

    uint256 public launchedAt;
    bool isTradingAllowed = false;

    bool swapBackEnabled = true;

    address devWallet;
    modifier onlyDev() {
        require(_msgSender() == devWallet, "FTSE: Caller is not dev");
        _;
    }

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event DistributedFees(uint256 fee);

    constructor() {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        liquidityCreator[owner()] = true;

        _allowances[address(this)][owner()] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;
        _allowances[owner()][routerAddress] = type(uint256).max;
        liquidityPools[pair] = true;

        _balances[owner()] = _totalSupply;

        emit Transfer(address(0), owner(), _totalSupply);

        devWallet = owner();
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMaximum(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function decreaseFee(
        uint256 _liquidityFee,
        uint256 _marketingFee
    ) external onlyDev {
        require(_liquidityFee <= liquidityFee, "FTSE: Can't make fee higher");
        require(_marketingFee <= marketingFee, "FTSE: Can't make fee higher");
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee + _marketingFee;
    }

    function setTeamWallet(address _newDev) external onlyOwner {
        devWallet = _newDev;
    }

    function feeWithdrawal(bool enabled, uint256 amount) external onlyDev {
        if (enabled) {
            uint256 amountETH = address(this).balance;
            payable(devWallet).transfer((amountETH * amount) / 10);
        }
    }

    function startTrading() external onlyOwner {
        require(!isTradingAllowed);
        isTradingAllowed = true;
        launchedAt = block.number;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(amount > 0, "FTSE: Amount must be over zero");
        require(sender != address(0), "FTSE: transfer from zero address");
        require(recipient != address(0), "FTSE: transfer to zero address");
        require(_balances[sender] >= amount, "FTSE: Insufficient balance");

        if (!launched() && liquidityPools[recipient]) {
            require(
                liquidityCreator[sender],
                "FTSE: Liquidity not added yet."
            );
            launch();
        }

        if (!isTradingAllowed) {
            require(
                liquidityCreator[sender] || liquidityCreator[recipient],
                "FTSE: Trading not open yet."
            );
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = feeExcluded(sender)
            ? receiveFee(recipient, amount)
            : amount;

        if (shouldSwapBack(recipient)) {
            if (amount > 0) swapBack();
        }

        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function feeExcluded(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function receiveFee(
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        bool sellingOrBuying = liquidityPools[recipient] ||
            liquidityPools[msg.sender];

        if (!sellingOrBuying) {
            return amount;
        }

        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        _balances[address(this)] += feeAmount;

        return amount - feeAmount;
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return
            !liquidityPools[msg.sender] &&
            !inSwap &&
            liquidityPools[recipient] &&
            swapBackEnabled;
    }

    function setProvideLiquidity(address lp, bool isPool) external onlyDev {
        require(lp != pair, "FTSE: Can't alter current liquidity pair");
        liquidityPools[lp] = isPool;
    }

    function setSwapBackEnabled(bool _enabled) external onlyDev {
        swapBackEnabled = _enabled;
    }

    function swapBack() internal swapping {
        uint256 myBalance = _balances[address(this)];

        if (myBalance < 1 ether) return;

        uint256 totalTokenFeeShare = marketingFee + liquidityFee / 2;

        uint256 amountToSwap = (myBalance * totalTokenFeeShare) / totalFee;
        uint256 amountForLiquidity = myBalance - amountToSwap;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 ETHBalanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 ETHAmountForLiq = ((address(this).balance - ETHBalanceBefore) *
            (liquidityFee / 2)) / totalTokenFeeShare;

        router.addLiquidityETH{value: ETHAmountForLiq}(
            address(this),
            amountForLiquidity,
            0,
            0,
            devWallet,
            block.timestamp
        );

        emit DistributedFees(amountToSwap);
    }

    function setIsFeeExempt(address _addr, bool _val) external onlyOwner {
        isFeeExempt[_addr] = _val;
    }

    function addLiquidityCreator(address _liquidityCreator) external onlyOwner {
        liquidityCreator[_liquidityCreator] = true;
    }

    function getCurrentSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }
}