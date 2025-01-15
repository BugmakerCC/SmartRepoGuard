// SPDX-License-Identifier: MIT

/**
	MATCHA AI - Predict the Future of Memecoins

	Website: https://matchaai.io/
    Telegram: https://t.me/matchaai_io
    X : https://x.com/matchaai_io
                                                                                                                      
**/

pragma solidity >=0.8.20;

abstract contract BaseContext {
    function caller() internal view virtual returns (address) {
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
        address owner,
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
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeCalc {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeCalc: addition overflow detected");
        return c;
    }

    function subtract(uint256 a, uint256 b) internal pure returns (uint256) {
        return subtract(a, b, "SafeCalc: subtraction overflow detected");
    }

    function subtract(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function multiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeCalc: multiplication overflow detected");
        return c;
    }

    function divide(uint256 a, uint256 b) internal pure returns (uint256) {
        return divide(a, b, "SafeCalc: division by zero detected");
    }

    function divide(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownership is BaseContext {
    address private _owner;
    event OwnerUpdated(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = caller();
        _owner = msgSender;
        emit OwnerUpdated(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == caller(), "Ownership: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnerUpdated(_owner, address(0));
        _owner = address(0);
    }
}

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDEXRouter {
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract MatchaAIToken is BaseContext, IERC20, Ownership {
    using SafeCalc for uint256;

    mapping(address => bool) private _excludedFromFees;
    mapping(address => bool) private blockedAddresses;
    mapping(address => uint256) private _accountBalances;
    mapping(address => mapping(address => uint256)) private _tokenAllowances;

    uint256 private _initialBuyFee = 19;
    uint256 private _initialSellFee = 19;
    uint256 private _finalBuyFee = 5;
    uint256 private _finalSellFee = 5;
    uint256 private _feeReductionBlock = 30;
    uint256 private _swapActivationBlock = 35;
    uint256 private _buyCounter = 0;

    uint8 private constant DECIMALS = 9;
    uint256 private constant SUPPLY_TOTAL = 100000000 * 10 ** DECIMALS;
    string private constant TOKEN_NAME = unicode"Matcha AI";
    string private constant TOKEN_SYMBOL = unicode"MATCHA";
    uint256 public maxTransactionAmount = 2000000 * 10 ** DECIMALS;
    uint256 public maxWalletSize = 2000000 * 10 ** DECIMALS;
    uint256 public swapThresholdAmount = 500000 * 10 ** DECIMALS;
    uint256 public maxSwapAmount = 2000000 * 10 ** DECIMALS;

    address payable private _feeWallet;
    uint256 launchBlock;

    IDEXRouter private dexRouter;
    address private dexPair;
    bool private isSwapping = false;
    bool private isSwapActivated = false;
    bool private tradingEnabled = false;

    event MaxTransactionAmountUpdated(uint _maxTransaction);
    modifier lockTheSwap() {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    constructor() {
        _feeWallet = payable(caller());
        _accountBalances[caller()] = SUPPLY_TOTAL;
        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[_feeWallet] = true;

        emit Transfer(address(0), caller(), SUPPLY_TOTAL);
    }

    function name() public pure returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public pure override returns (uint256) {
        return SUPPLY_TOTAL;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _accountBalances[account];
    }

    function transfer(
        address recipient,
        uint256 value
    ) public override returns (bool) {
        _transfer(caller(), recipient, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _tokenAllowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) public override returns (bool) {
        _approve(caller(), spender, value);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 value
    ) public override returns (bool) {
        _transfer(sender, recipient, value);
        _approve(
            sender,
            caller(),
            _tokenAllowances[sender][caller()].subtract(
                value,
                "IERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "IERC20: approve from zero address");
        require(spender != address(0), "IERC20: approve to zero address");
        _tokenAllowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {
        require(from != address(0), "IERC20: transfer from zero address");
        require(to != address(0), "IERC20: transfer to zero address");
        require(value > 0, "Transfer amount must be greater than zero");

        uint256 feeAmount = 0;

        if (from != owner() && to != owner()) {
            require(!blockedAddresses[from] && !blockedAddresses[to]);

            if (from == dexPair || to == dexPair) {
                if (
                    from == dexPair &&
                    to != address(dexRouter) &&
                    !_excludedFromFees[to]
                ) {
                    require(
                        value <= maxTransactionAmount,
                        "Exceeds max transaction limit."
                    );
                    require(
                        balanceOf(to) + value <= maxWalletSize,
                        "Exceeds max wallet size."
                    );

                    feeAmount = value
                        .multiply(
                            (_buyCounter > _feeReductionBlock)
                                ? _finalBuyFee
                                : _initialBuyFee
                        )
                        .divide(100);
                    _buyCounter++;
                }

                if (to == dexPair && from != address(this)) {
                    feeAmount = value
                        .multiply(
                            (_buyCounter > _feeReductionBlock)
                                ? _finalSellFee
                                : _initialSellFee
                        )
                        .divide(100);
                }

                uint256 contractBalance = balanceOf(address(this));
                if (
                    !isSwapping &&
                    to == dexPair &&
                    isSwapActivated &&
                    contractBalance > swapThresholdAmount &&
                    _buyCounter > _swapActivationBlock
                ) {
                    swapTokensForEth(
                        min(value, min(contractBalance, maxSwapAmount))
                    );
                    uint256 contractEthBalance = address(this).balance;
                    if (contractEthBalance > 0) {
                        sendEthToFee(address(this).balance);
                    }
                }
            } else {
                feeAmount = 0;
            }
        }

        _accountBalances[from] = _accountBalances[from].subtract(value);
        _accountBalances[to] = _accountBalances[to].add(
            value.subtract(feeAmount)
        );

        if (feeAmount > 0) {
            _accountBalances[address(this)] = _accountBalances[address(this)]
                .add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
        }

        emit Transfer(from, to, value.subtract(feeAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function isContract(address account) private view returns (bool) {
        return account.code.length > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendEthToFee(uint256 amount) private {
        _feeWallet.transfer(amount);
    }

    function manualSwapTokensForEth() external {
        require(caller() == _feeWallet, "Caller is not authorized");
        uint256 tokenBalance = balanceOf(address(this));
        uint256 ethBalance = address(this).balance;

        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        if (ethBalance > 0) {
            sendEthToFee(ethBalance);
        }
    }

    function removeLimits() external onlyOwner {
        maxTransactionAmount = SUPPLY_TOTAL;
        maxWalletSize = SUPPLY_TOTAL;
        emit MaxTransactionAmountUpdated(SUPPLY_TOTAL);
    }

    function openTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        dexRouter = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(dexRouter), SUPPLY_TOTAL);
        dexPair = IDEXFactory(dexRouter.factory()).createPair(
            address(this),
            dexRouter.WETH()
        );
        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(dexPair).approve(address(dexRouter), type(uint).max);
        isSwapActivated = true;
        tradingEnabled = true;
        launchBlock = block.number;
    }

    receive() external payable {}
}