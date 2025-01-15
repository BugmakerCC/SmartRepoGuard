// SPDX-License-Identifier: MIT

/*
Do Only Good Everyday 

Billy's Tweet -> https://x.com/BillyM2k/status/1366314363716395011?t=X27m_JuEb8Gp44_MnXWaxw&s=19

Website: https://www.dogemovement.com/
Telegram: https://t.me/DoOnlyGoodEverydayERC20
Twitter: https://x.com/DoOnlyGevrdy
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

contract Ownable is Context {
    address private _owner;
    event OwnershipChanged(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipChanged(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipChanged(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipChanged(_owner, newOwner);
        _owner = newOwner;
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

contract DOGE is Context, IToken, Ownable {
    using MathLib for uint256;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => bool) private noLimits;
    mapping (uint256 => uint256) private counts_OfBuyTxn; 
    address payable private addrTaxWallet;

    uint256 private firstBlock = 0; uint256 private _buyCount = 0;
    uint256 private _sellCount = 0; uint256 private lastSellBlock = 0;

    uint8 private constant DECIMALS = 9;
    uint256 private constant TOTAL_SUPPLY = 420690000000 * 10 ** DECIMALS;
    string private constant NAME = unicode"Do Only Good Everyday";
    string private constant SYMBOL = unicode"DOGE";
    
    uint256 public _maxTxnAmt = 4206900000 * 10 ** DECIMALS;
    uint256 public _maxWalletSize = 4206900000 * 10 ** DECIMALS;
    uint256 public _taxSwapThreshold = 4200000000 * 10 ** DECIMALS;
    uint256 public _maxTaxSwap = 4206900000 * 10 ** DECIMALS;

    IUniswapRouter private uniswapRouter;
    address public uniswapPair;
    bool private isTradingOpen;
    uint256 public caLimitNbr = 4;
    bool private isSwapping = false;
    bool private swapEnabled = false;
    bool public _t_CaSwap = true;

    event MaxTransactionAmountUpdated(uint256 maxTransactionAmount);
    
    modifier swapLock {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    uint256 private _initialBuyTax = 20;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;

    uint256 private _reduceBuyTaxAt = 25;
    uint256 private _reduceSellTaxAt = 25;
    uint256 private _preventSwapBefore = 25;

    constructor() {
        addrTaxWallet = payable(owner());
        balances[_msgSender()] = TOTAL_SUPPLY;
        noLimits[owner()] = true;
        noLimits[address(this)] = true;
        noLimits[address(uniswapPair)] = true;
        
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
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _setApproval(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _setApproval(sender, _msgSender(), allowances[sender][_msgSender()].safeSub(amount, "transfer exceeds allowance"));
        return true;
    }

    function _setApproval(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from zero address");
        require(spender != address(0), "approve to zero address");
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to zero address");
        require(amount > 0, "transfer amount must be greater than zero");
        
        uint256 _taxAmount = 0;

        if (from != owner() && to != owner()) {
            _taxAmount = amount.safeMul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).safeDiv(100);

            if (block.number == firstBlock) {
                require(counts_OfBuyTxn[block.number] < 40, "exceeds buy limit for initial block.");
                counts_OfBuyTxn[block.number]++;
            }

            if (from == uniswapPair && to != address(uniswapRouter) && !noLimits[to]) {
                require(amount <= _maxTxnAmt, "exceeds max transaction amount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "exceeds max wallet size.");
                _buyCount++;
            }

            if (to != uniswapPair && !noLimits[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "exceeds max wallet size.");
            }

            if (to == uniswapPair && from != address(this)) {
                _taxAmount = amount.safeMul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).safeDiv(100);
            }

            if (from != uniswapPair && to != uniswapPair && from != address(this)) {
                _taxAmount = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (_t_CaSwap && !isSwapping && to == uniswapPair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number > lastSellBlock) {
                    _sellCount = 0;
                }
                require(_sellCount < caLimitNbr, "CA balance sell limit reached");
                _swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                _sellCount++;
                lastSellBlock = block.number;
            } else if (!isSwapping && to == uniswapPair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                _swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (_taxAmount > 0) {
            balances[address(this)] = balances[address(this)].safeAdd(_taxAmount);
            emit Transfer(from, address(this), _taxAmount);
        }
        balances[from] = balances[from].safeSub(amount);
        balances[to] = balances[to].safeAdd(amount.safeSub(_taxAmount));
        emit Transfer(from, to, amount.safeSub(_taxAmount));
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
        addrTaxWallet.transfer(amount);
    }

    function setMaxTaxSwap(bool enable, uint256 amount, bool _enable, uint256 _amount) external onlyOwner {
        swapEnabled = enable;
        _maxTaxSwap = amount;
        _t_CaSwap = _enable;
        caLimitNbr = _amount;
    }

    function rescueStuckETH() external onlyOwner {
        payable(addrTaxWallet).transfer(address(this).balance);
    }

    function rescueUnknownERC20Tokens(address tokenAddr, uint amount) external onlyOwner {
        IToken(tokenAddr).transfer(addrTaxWallet, amount);
    }

    function freeLimits() external onlyOwner {
        _maxTxnAmt = TOTAL_SUPPLY;
        _maxWalletSize = TOTAL_SUPPLY;
        emit MaxTransactionAmountUpdated(TOTAL_SUPPLY);
    }

    function enableTrading() external onlyOwner() {
        require(!isTradingOpen, "trading is already open");
        uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _setApproval(address(this), address(uniswapRouter), TOTAL_SUPPLY);
        uniswapPair = IUniswapFactory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        noLimits[address(uniswapPair)] = true;
        uniswapRouter.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IToken(uniswapPair).approve(address(uniswapRouter), type(uint).max);
        swapEnabled = true;
        isTradingOpen = true;
        firstBlock = block.number;
    }

    receive() external payable {}
}