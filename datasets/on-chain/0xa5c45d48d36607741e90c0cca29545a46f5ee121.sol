/*

CHIB

Chiba is a meme coin project that traces its roots to the origins of iconic dog coins like 
DOGE, SHIB, NEIRO, and KABOSU. Inspired by the rescue group Chiba Wan, which saved Kabosu, 
the project celebrates the legacy of the dogs that sparked a crypto revolution, honoring 
their pivotal role in shaping the meme coin phenomenon.

https://chibcoin.com
https://x.com/chib_erc20
https://linktr.ee/chibcoin

 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is IERC20, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "CHIB: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "CHIB: transfer from the zero address");
        require(
            recipient != address(0),
            "CHIB: transfer to the zero address"
        );

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "CHIB: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "CHIB: approve from the zero address");
        require(spender != address(0), "CHIB: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "CHIB: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "CHIB: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(
            accountBalance >= amount,
            "CHIB: burn amount exceeds balance"
        );
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}
interface IUniswapV2Router02 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

contract Chiba is ERC20 {
    uint256 MAX_BALANCE_CAP = 4000000000 * 10 ** 9;
    uint256 private taxEndTime;
    address private taxWallet;
    uint16 private taxRate = 23;

    constructor() ERC20("Chiba", "CHIB") {
        _mint(msg.sender, 200000000000 * 10 ** 9);
        taxWallet = msg.sender;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(
            recipient == uniswapPair ||
                block.timestamp > taxEndTime ||
                _balances[recipient] + amount <= MAX_BALANCE_CAP,
            "CHIB: balance cap exceeded"
        );

        uint256 taxAmount = 0;
        uint256 amountAfterTax = amount;

        if (
            block.timestamp < taxEndTime &&
            (sender == uniswapPair || recipient == uniswapPair) &&
            sender != address(this)
        ) {
            taxAmount = (amount * taxRate) / 100;
            amountAfterTax = amount - taxAmount;
        }

        super._transfer(sender, recipient, amountAfterTax);

        if (taxAmount > 0) {
            super._transfer(sender, address(this), taxAmount);
        }

        if (
            _inSwap == false &&
            _balances[address(this)] > 0 &&
            sender != address(this) &&
            recipient != address(this) &&
            sender != uniswapPair &&
            recipient != uniswapPair
        ) {
            swapTax();
        }
    }

    function swapTax() internal {
        _inSwap = true;
        uint256 tokenAmount = balanceOf(address(this));
        uint256 maxSell = MAX_BALANCE_CAP;
        if (tokenAmount > maxSell) {
            tokenAmount = maxSell;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            taxWallet,
            block.timestamp
        );
        _inSwap = false;
    }

    function addLiquidity() external onlyOwner {
        require(!transferEnabled, "CHIB: transfer already enabled");
        uniswapRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        IUniswapV2Factory factory = IUniswapV2Factory(uniswapRouter.factory());

        uniswapPair = factory.getPair(address(this), uniswapRouter.WETH());

        if (uniswapPair == address(0)) {
            uniswapPair = factory.createPair(
                address(this),
                uniswapRouter.WETH()
            );
        }
        _approve(address(this), address(uniswapRouter), totalSupply());

        uniswapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapPair).approve(address(uniswapRouter), type(uint).max);

        taxEndTime = block.timestamp + 15 * 60;

        transferEnabled = true;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    bool _inSwap = false;
    bool private transferEnabled = false;
    address private uniswapPair;
    IUniswapV2Router02 private uniswapRouter;
    receive() external payable {}
    fallback() external payable {}
}