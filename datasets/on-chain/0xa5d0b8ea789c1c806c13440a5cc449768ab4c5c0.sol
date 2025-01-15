/*
website: https://mineai.co/
x: https://x.com/TheMineAI
telegram: https://t.me/mineaitoken
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract MineAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "MineAI";
    string private constant _symbol = "MineAI";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000000 * 10 ** _decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    address payable private _ownerWallet;
    uint256 private _buyTax = 10;
    uint256 private _sellTax = 10;
    uint256 private _taxSwapThreshold = 750000 * 10 ** _decimals;
    uint256 private _maxTaxSwap = 300000 * 10 ** _decimals;
    uint256 private liquidityPercentage = 50;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen = false;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event BuyTaxUpdate(uint256 tax);
    event SellTaxUpdate(uint256 tax);
    event LiquidityAdd(
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
    event OwnerWalletChange(address owner);
    event UpdateTaxSwapThreshold(uint256 taxSwapThreshold);
    event UpdateMaxTaxSwap(uint256 maxTaxSwap);
    event SetLiquidityPercentage(uint256 newLiquidityPercentage);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _balances[_msgSender()] = _tTotal;
        _ownerWallet = payable(_msgSender());
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount)
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            if (from == uniswapV2Pair && !_isExcludedFromFee[to]) {
                taxAmount = amount.mul(_buyTax).div(100);
            } else if (
                to == uniswapV2Pair &&
                !_isExcludedFromFee[from] &&
                from != address(this)
            ) {
                taxAmount = amount.mul(_sellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance >= _taxSwapThreshold &&
                from != address(this)
            ) {
                uint256 swapToken = min(balanceOf(address(this)), _maxTaxSwap);
                swapTokensForEth(swapToken);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    uint256 liquidityETHAmount = contractETHBalance
                        .mul(liquidityPercentage)
                        .div(100);
                    addLiquidity(balanceOf(address(this)), liquidityETHAmount);
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
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

    function sendETHToFee(uint256 amount) private {
        _ownerWallet.transfer(amount);
    }

    function manualSwap() external {
        require(
            _msgSender() == _ownerWallet,
            "Only tax wallet can trigger manual swap"
        );
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0) {
            swapTokensForEth(contractTokenBalance);
        }
    }

    function manualSend() external {
        require(
            _msgSender() == _ownerWallet,
            "Only tax wallet can trigger manual send"
        );
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFee(contractETHBalance);
        }
    }

    function setBuyTax(uint256 newBuyTax) external onlyOwner {
        require(newBuyTax <= 15, "Buy tax cannot exceed 15%");
        _buyTax = newBuyTax;

        emit BuyTaxUpdate(newBuyTax);
    }

    function setSellTax(uint256 newSellTax) external onlyOwner {
        require(newSellTax <= 15, "Sell tax cannot exceed 15%");
        _sellTax = newSellTax;

        emit SellTaxUpdate(newSellTax);
    }

    function setLiquidityPercentage(
        uint256 newLiquidityPercentage
    ) external onlyOwner {
        require(
            newLiquidityPercentage <= 100,
            "Liquidity percentage cannot exceed 100%"
        );
        liquidityPercentage = newLiquidityPercentage;

        emit SetLiquidityPercentage(newLiquidityPercentage);
    }

    function excludeMultipleFromFee(
        address[] calldata accounts,
        bool excluded
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        ) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                _ownerWallet,
                block.timestamp
            );

        emit LiquidityAdd(amountToken, amountETH, liquidity);
    }

    function setOwnerWallet(address payable newOwnerWallet) external onlyOwner {
        _ownerWallet = newOwnerWallet;

        emit OwnerWalletChange(newOwnerWallet);
    }

    function updateMaxTaxSwap(uint256 maxTaxSwap) external onlyOwner {
        _maxTaxSwap = maxTaxSwap;

        emit UpdateMaxTaxSwap(maxTaxSwap);
    }

    function updateTaxSwapThreshold(
        uint256 taxSwapThreshold
    ) external onlyOwner {
        _taxSwapThreshold = taxSwapThreshold;

        emit UpdateTaxSwapThreshold(taxSwapThreshold);
    }

    function recoverEmergency() external onlyOwner {
        sendETHToFee(address(this).balance);
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        addLiquidity(balanceOf(address(this)), address(this).balance);

        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );

        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}
}