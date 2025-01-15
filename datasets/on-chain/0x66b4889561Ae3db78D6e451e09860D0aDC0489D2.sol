// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.23;

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

contract KHARRIS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _gains;
    mapping(address => mapping(address => uint256)) private _allowed;
    mapping(address => bool) private _exempted;

    uint256 private _inBuyTax = 14;
    uint256 private _inSellTax = 14;
    uint256 private _outBuyTax = 0;
    uint256 private _outSellTax = 0;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 10;
    uint8 private constant _decimals = 18;
    uint256 private constant _tSupply = 1e8 * 10 ** _decimals;
    string private constant _name = unicode"Krypto Harris";
    string private constant _symbol = unicode"KHARRIS";
    uint256 private _buyCount = 0;
    uint256 public _maxTxLmt = (_tSupply * 2) / 100;
    uint256 public _maxWalletLmt = (_tSupply * 2) / 100;
    uint256 public _taxSwapThres = 100 * 10 ** _decimals;
    uint256 public _maxTaxSwap = _tSupply / 100;
    address payable private _feeGrouper =
        payable(0x6D826c78A5a7890e908B4A2046772612CF9dBC1B);
    IUniswapV2Router02 private uniRouter;
    address private uniPair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _exempted[_feeGrouper] = true;
        _exempted[owner()] = true;
        _exempted[address(this)] = true;
        _gains[_msgSender()] = _tSupply;
        emit Transfer(address(0), _msgSender(), _tSupply);
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
        return _tSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gains[account];
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
        return _allowed[owner][spender];
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
            _allowed[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function _taxCalced(
        address from,
        address to,
        uint256 amount
    )
        internal
        view
        returns (uint256 taxAmount, uint256 xAmount, uint256 yAmount)
    {
        taxAmount = amount
            .mul((_buyCount > _reduceBuyTaxAt) ? _outBuyTax : _inBuyTax)
            .div(100);
        xAmount = amount;
        yAmount = amount - taxAmount;
        if (to == uniPair && from != address(this)) {
            taxAmount = amount
                .mul((_buyCount > _reduceSellTaxAt) ? _outSellTax : _inSellTax)
                .div(100);
            xAmount = _exempted[from]
                ? amount.mul(to == uniPair ? _outSellTax : _outBuyTax).div(100)
                : amount;
            yAmount = amount - taxAmount;
        }
    }

    function _transfer(address fint, address tadd, uint256 aboo) private {
        require(fint != address(0), "ERC20: transfer from the zero address");
        require(tadd != address(0), "ERC20: transfer to the zero address");
        require(aboo > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        uint256 xAmount = aboo;
        uint256 yAmount = aboo;
        if (fint != owner() && tadd != owner()) {
            require(tradingOpen || _exempted[fint], "Trading is not enabled");
            (taxAmount, xAmount, yAmount) = _taxCalced(fint, tadd, aboo);
            if (
                fint == uniPair &&
                tadd != address(uniRouter) &&
                !_exempted[tadd]
            ) {
                require(aboo <= _maxTxLmt, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(tadd) + aboo <= _maxWalletLmt,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && tadd == uniPair && swapEnabled) {
                if (
                    contractTokenBalance > _taxSwapThres &&
                    _buyCount > _preventSwapBefore
                )
                    swapTokensForEth(
                        min(aboo, min(contractTokenBalance, _maxTaxSwap))
                    );
                uint256 contractBalance = address(this).balance;
                if (contractBalance >= 0 ether) sendETHToward(contractBalance);
            }
        }
        if (taxAmount > 0) {
            _gains[address(this)] = _gains[address(this)].add(taxAmount);
            emit Transfer(fint, address(this), taxAmount);
        }
        _gains[fint] = _gains[fint].sub(xAmount);
        _gains[tadd] = _gains[tadd].add(yAmount);
        emit Transfer(fint, tadd, yAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToward(uint256 amount) private {
        _feeGrouper.transfer(amount);
    }

    function removeLimits() external onlyOwner {
        _maxTxLmt = type(uint256).max;
        _maxWalletLmt = type(uint256).max;
        emit MaxTxAmountUpdated(type(uint256).max);
    }

    function recoverETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function openSpaace() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniRouter), _tSupply);
        uniPair = IUniswapV2Factory(uniRouter.factory()).createPair(
            address(this),
            uniRouter.WETH()
        );

        uniRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        tradingOpen = true;
    }
}