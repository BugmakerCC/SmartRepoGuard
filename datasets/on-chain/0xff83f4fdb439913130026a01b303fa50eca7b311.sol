// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

/*
 * https://t.me/miharusmilingporpoise
 * https://x.com/MiharuPorpoise

 https://oceanservice.noaa.gov/facts/dolphin_porpoise.html#:~:text=Dolphins%20and%20porpoises%20differ%20in,light%20spotting%20on%20the%20belly.
*/

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

contract Ownable {
    error NotOwner();

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        if (_owner != msg.sender) revert NotOwner();
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
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract Miharu is IERC20, Ownable {
    // errors
    error Initialized();
    error InvalidAddress();
    error InvalidAmount();
    error ZeroValue();
    error ZeroToken();
    error TaxTooHigh();
    error NotSelf();
    error Unauthorized();
    error Bot();
    error MaxWallet();
    error MaxTx();
    error Contract();
    error TooManySellsInBlock();

    // events
    event MaxTxAmountUpdated(uint256 maxTx);

    // storage
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromLimits;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    address payable internal _taxWallet;
    uint256 private _firstBlock;

    // params
    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 25;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 24;
    uint256 private _reduceSellTaxAt = 30;
    uint256 private _preventSwapBefore = 20;
    uint256 internal _buyCount = 0;

    uint8 private constant _DECIMALS = 18;
    uint256 private constant _TOTAL = 4.2069e9 * 10 ** _DECIMALS;
    string private constant _NAME = unicode"Smiling Porpoise";
    string private constant _SYMBOL = unicode"Miharu";
    uint256 public maxTx = 84.138e6 * 10 ** _DECIMALS;
    uint256 public maxWallet = 84.138e6 * 10 ** _DECIMALS;
    uint256 public swapThreshold = 4.2069e7 * 10 ** _DECIMALS;
    uint256 public maxTaxSwap = 4.2069e7 * 10 ** _DECIMALS;

    // internal storage
    IUniswapV2Router02 private constant _UNISWAP_V2_ROUTER =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private _uniswapV2Pair;
    bool public lpAdded;
    bool private _inSwap = false;
    bool private _swapEnabled = false;
    uint256 private _sellCountInBlock = 0;
    uint256 private _lastSellBlock = 0;

    // constructor
    constructor() {
        _taxWallet = payable(tx.origin);
        _balances[tx.origin] = _TOTAL;

        _isExcludedFromLimits[tx.origin] = true;
        _isExcludedFromLimits[address(0)] = true;
        _isExcludedFromLimits[address(0xdead)] = true;
        _isExcludedFromLimits[address(this)] = true;
        _isExcludedFromLimits[address(_UNISWAP_V2_ROUTER)] = true;

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[tx.origin] = true;

        emit Transfer(address(0), tx.origin, _TOTAL);
    }

    receive() external payable {}

    // erc20
    function name() public pure returns (string memory) {
        return _NAME;
    }

    function symbol() public pure returns (string memory) {
        return _SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() public pure override returns (uint256) {
        return _TOTAL;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        if (owner == address(0)) revert InvalidAddress();
        if (spender == address(0)) revert InvalidAddress();
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        if (from == address(0)) revert InvalidAddress();
        if (to == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        if (bots[from] || bots[to]) {
            revert Bot();
        }

        if (maxWallet != _TOTAL && !_isExcludedFromLimits[to]) {
            if (balanceOf(to) + amount > maxWallet) {
                revert MaxWallet();
            }
        }

        if (maxTx != _TOTAL && !_isExcludedFromLimits[from]) {
            if (amount > maxTx) {
                revert MaxTx();
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !_inSwap && contractTokenBalance >= swapThreshold && _swapEnabled && _buyCount > _preventSwapBefore
                && to == _uniswapV2Pair && !_isExcludedFromFee[from]
        ) {
            if (block.number > _lastSellBlock) {
                _sellCountInBlock = 0;
            }
            if (_sellCountInBlock >= 3) revert TooManySellsInBlock();
            _swapTokensForEth(_min(amount, _min(contractTokenBalance, maxTaxSwap)));
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                _sendETHToFee(contractETHBalance);
            }
            _sellCountInBlock++;
            _lastSellBlock = block.number;
        }

        uint256 taxAmount = 0;
        if (!_inSwap && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            // sell
            if (to == _uniswapV2Pair) {
                taxAmount = (amount * ((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax)) / 100;
            }
            // buy
            else if (from == _uniswapV2Pair) {
                if (_firstBlock + 25 > block.number) {
                    if (_isContract(to)) {
                        revert Contract();
                    }
                }
                taxAmount = (amount * ((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax)) / 100;
                ++_buyCount;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)] + taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount - taxAmount;
        emit Transfer(from, to, amount - taxAmount);
    }

    // owners
    function removeLimits() external onlyOwner {
        maxTx = _TOTAL;
        maxWallet = _TOTAL;
        emit MaxTxAmountUpdated(_TOTAL);
    }

    function setBots(address[] memory bots_, bool isBot_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = isBot_;
        }
    }

    function launch(uint256 amount) external payable onlyOwner {
        if (lpAdded) revert Initialized();
        if (msg.value == 0) revert ZeroValue();
        if (amount == 0) revert ZeroToken();
        _transfer(msg.sender, address(this), amount);
        _approve(address(this), address(_UNISWAP_V2_ROUTER), _TOTAL);

        _uniswapV2Pair =
            IUniswapV2Factory(_UNISWAP_V2_ROUTER.factory()).createPair(address(this), _UNISWAP_V2_ROUTER.WETH());
        _isExcludedFromLimits[_uniswapV2Pair] = true;

        _UNISWAP_V2_ROUTER.addLiquidityETH{value: address(this).balance}(
            address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp
        );
        IERC20(_uniswapV2Pair).approve(address(_UNISWAP_V2_ROUTER), type(uint256).max);
        _swapEnabled = true;
        lpAdded = true;
        _firstBlock = block.number;
    }

    function dropTax(uint256 buyTax_, uint256 sellTax_) external onlyOwner {
        if (buyTax_ > _finalBuyTax) revert TaxTooHigh();
        if (sellTax_ > _finalSellTax) revert TaxTooHigh();

        _finalBuyTax = buyTax_;
        _finalSellTax = sellTax_;
    }

    function clearStuckETH() external {
        (bool success,) = _taxWallet.call{value: address(this).balance}("");
        require(success);
    }

    function clearStuckSelf() external {
        _transfer(address(this), _taxWallet, balanceOf(address(this)));
    }

    function clearStuck(address token) external {
        if (token == address(this)) revert NotSelf();
        IERC20(token).transfer(_taxWallet, IERC20(token).balanceOf(address(this)));
    }

    // view
    function isBot(address a) public view returns (bool) {
        return bots[a];
    }

    // private
    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        _inSwap = true;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _UNISWAP_V2_ROUTER.WETH();
        _approve(address(this), address(_UNISWAP_V2_ROUTER), tokenAmount);
        _UNISWAP_V2_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, address(this), block.timestamp
        );
        _inSwap = false;
    }

    function _sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
}