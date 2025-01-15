// SPDX-License-Identifier: MIT

/*
$IZUMI - Neiro's First Name (OG NEIRO)

Izumi’s story is one of resilience and new beginnings. Rescued by an animal shelter and named for a fresh start, she found love with Riko Wako Mama before her journey led to Kabosu Mama, who saw her true potential. Renamed Neiro, she became the heir to the Doge name. Her rise to greatness began with the name Izumi.

Website: https://izumierc.com
Telegram: https://t.me/Izumioneth
Twitter: https://x.com/Izumioneth
Medium : https://medium.com/@izumioneth
*/

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library MathLib {
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "MathLib: addition overflow");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return safeSub(a, b, "MathLib: subtraction overflow");
    }

    function safeSub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "MathLib: multiplication overflow");
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return safeDiv(a, b, "MathLib: division by zero");
    }

    function safeDiv(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract OwnerControl is Context {
    address private contractOwner;
    event OwnershipChanged(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        contractOwner = msgSender;
        emit OwnershipChanged(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return contractOwner;
    }

    modifier onlyContractOwner() {
        require(contractOwner == _msgSender(), "OwnerControl: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyContractOwner {
        emit OwnershipChanged(contractOwner, address(0));
        contractOwner = address(0);
        remove_Max_Limits();
    }

    function remove_Max_Limits() internal virtual {}

    function changeOwnership(address newOwner) public virtual onlyContractOwner {
        require(newOwner != address(0), "OwnerControl: new owner is the zero address");
        emit OwnershipChanged(contractOwner, newOwner);
        contractOwner = newOwner;
    }
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapRouter {
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

contract IZUMI is Context, IToken, OwnerControl {
    using MathLib for uint256;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => bool) private exAddrs;
    mapping (uint256 => uint256) private buyTxns_Count; 
    address payable private fee_Wallet_Addr;


    struct Fees {
        uint256 iBFee;
        uint256 iSFee;
        uint256 eBFee;
        uint256 eSFee;
    }

    struct Threshold {
        uint256 thresBFee;
        uint256 thresSFee;
        uint256 swapThresL;
    }
    
    uint256 private initialBlock = 0; uint256 private total_Buys_Count = 0; 
    uint256 private total_Sells_Count = 0; uint256 private lastSellBlock = 0;


    uint8 private constant DECIMALS = 9;
    uint256 private constant TOTAL_SUPPLY = 420690000000 * 10 ** DECIMALS;
    string private constant NAME = unicode"Izumi";
    string private constant SYMBOL = unicode"IZUMI";
    
    uint256 public maxTransactionAmount = 4206900000 * 10 ** DECIMALS;
    uint256 public maxWalletSize = 4206900000 * 10 ** DECIMALS;
    uint256 public swapFeeThreshold = 4200000000 * 10 ** DECIMALS;
    uint256 public feeSwapLimit = 4206900000 * 10 ** DECIMALS;

    IUniswapRouter private uniswapRouter;
    address public uniswapPair;
    bool private isTradingOpen;
    uint256 public maxCaNum = 3;
    bool private isSwapping = false;
    bool private swapEnabled = false;
    bool public swapCaNum = true;

    event MaxTransactionAmountUpdated(uint256 maxTransactionAmount);
    
    modifier swapLock {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    constructor() {
        fee_Wallet_Addr = payable(0x53b9183AA2eb36865c8F1E06F805D7DfDED31a92);
        balances[_msgSender()] = TOTAL_SUPPLY;
        exAddrs[owner()] = true;
        exAddrs[address(this)] = true;
        exAddrs[address(uniswapPair)] = true;
        
        emit Transfer(address(0), _msgSender(), TOTAL_SUPPLY);
    }

    function name() public pure returns (string memory) {
        return NAME;
    }

    function symbol() public pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public pure override returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _setApproval(_msgSender(), spender, amount);
        return true;
    }

    Fees private feeInfo = Fees(20, 20, 0, 0);
    Threshold private thresInfo = Threshold(30, 30, 30);

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _executeTransfer(sender, recipient, amount);
        _setApproval(sender, _msgSender(), allowances[sender][_msgSender()].safeSub(amount, "transfer exceeds allowance"));
        return true;
    }

    function _setApproval(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from zero address");
        require(spender != address(0), "approve to zero address");
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _executeTransfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to zero address");
        require(amount > 0, "transfer amount must be greater than zero");
        
        uint256 feeAmount = 0;

        if (from != owner() && to != owner()) {
            feeAmount = amount.safeMul((total_Buys_Count > thresInfo.thresBFee) ? feeInfo.eBFee : feeInfo.iBFee).safeDiv(100);

            if (block.number == initialBlock) {
                require(buyTxns_Count[block.number] < 40, "exceeds buy limit for initial block.");
                buyTxns_Count[block.number]++;
            }

            if (from == uniswapPair && to != address(uniswapRouter) && !exAddrs[to]) {
                require(amount <= maxTransactionAmount, "exceeds max transaction amount.");
                require(balanceOf(to) + amount <= maxWalletSize, "exceeds max wallet size.");
                total_Buys_Count++;
            }

            if (to != uniswapPair && !exAddrs[to]) {
                require(balanceOf(to) + amount <= maxWalletSize, "exceeds max wallet size.");
            }

            if (to == uniswapPair && from != address(this)) {
                feeAmount = amount.safeMul((total_Buys_Count > thresInfo.thresSFee) ? feeInfo.eSFee : feeInfo.iSFee).safeDiv(100);
            }

            if (from != uniswapPair && to != uniswapPair && from != address(this)) {
                feeAmount = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (swapCaNum && !isSwapping && to == uniswapPair && swapEnabled && contractTokenBalance > swapFeeThreshold && total_Buys_Count > thresInfo.swapThresL) {
                if (block.number > lastSellBlock) {
                    total_Sells_Count = 0;
                }
                require(total_Sells_Count < maxCaNum, "CA balance sell limit reached");
                _swapTokensForEth(min(amount, min(contractTokenBalance, feeSwapLimit)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                total_Sells_Count++;
                lastSellBlock = block.number;
            } else if (!isSwapping && to == uniswapPair && swapEnabled && contractTokenBalance > swapFeeThreshold && total_Buys_Count > thresInfo.swapThresL) {
                _swapTokensForEth(min(amount, min(contractTokenBalance, feeSwapLimit)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (feeAmount > 0) {
            balances[address(this)] = balances[address(this)].safeAdd(feeAmount);
            emit Transfer(from, address(this), feeAmount);
        }
        balances[from] = balances[from].safeSub(amount);
        balances[to] = balances[to].safeAdd(amount.safeSub(feeAmount));
        emit Transfer(from, to, amount.safeSub(feeAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _swapTokensForEth(uint256 tokenAmount) private swapLock {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _setApproval(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        fee_Wallet_Addr.transfer(amount);
    }

    function configThresLimit(bool swapStatus, uint256 swapAmount, bool caStatus, uint256 caAmount) external onlyContractOwner {
        swapEnabled = swapStatus;
        feeSwapLimit = swapAmount;
        swapCaNum = caStatus;
        maxCaNum = caAmount;
    }

    function rescue_StuckETH() external onlyContractOwner {
        payable(fee_Wallet_Addr).transfer(address(this).balance);
    }

    function rescue_Any_ERC20Tokens(address tokenAddr, uint amount) external onlyContractOwner {
        IToken(tokenAddr).transfer(fee_Wallet_Addr, amount);
    }

    function remove_Max_Limits() internal override {
        maxTransactionAmount = TOTAL_SUPPLY;
        maxWalletSize = TOTAL_SUPPLY;
        emit MaxTransactionAmountUpdated(TOTAL_SUPPLY);
    }

    function enableTrading() external onlyContractOwner() {
        require(!isTradingOpen, "trading is already open");
        uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _setApproval(address(this), address(uniswapRouter), TOTAL_SUPPLY);
        uniswapPair = IUniswapFactory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        exAddrs[address(uniswapPair)] = true;
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IToken(uniswapPair).approve(address(uniswapRouter), type(uint).max);
        swapEnabled = true;
        isTradingOpen = true;
        initialBlock = block.number;
    }

    receive() external payable {}
}