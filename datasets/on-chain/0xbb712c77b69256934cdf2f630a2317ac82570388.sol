/**

█▀▀ █▀█ █ █▀█ █▀█ █
█▄▄ █▀▄ █ █▀▀ █▀▀ █▄▄


Website: https://WheelchairCat.me
Twitter: https://x.com/CRIPPLtheCAT
Telegram: https://t.me/CRIPPLtheCAT

**/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
}

contract WheelchairCatToken is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 1_000_000_000e18;
    uint256 private constant somethingPercent = 1_000_000e18;
    uint256 private constant oneHalfPercent = 15_000_000e18;
    uint256 private constant minSwap = 100_000e18;
    uint8 private constant _decimals = 18;
    uint256 public theTax;

    IUniswapV2Router02 immutable uniswapV2Router;
    address immutable uniswapV2Pair;
    address immutable WETH;
    address payable immutable marketingWallet;

    bool private launched = false;
    bool private unleashed = true;
    uint8 private inSwapAndLiquify;

    uint256 private startingBlock;

    string private constant _name = "Wheelchair Cat";
    string private constant _symbol = "CRIPPL";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isCat;
    mapping(address => bool) private _isDog;

    constructor() {
           uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = uniswapV2Router.WETH();

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );

        marketingWallet = payable(0x6663bf43F6A8BF748D16e0A109A3C612148c4FA0);
        _balance[msg.sender] = _totalSupply;
        _isCat[marketingWallet] = true;
        _isCat[msg.sender] = true;
        _isCat[address(this)] = true;
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256)
            .max;

        theTax = 5;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function startMeowing() external onlyOwner {
        launched = true;
        startingBlock = block.number;
    }

    function addToCats(address wallet) external onlyOwner {
        _isCat[wallet] = true;
    }

    function removeTheCat(address wallet) external onlyOwner {
        _isCat[wallet] = false;
    }

    function addToDogs(address wallet) external onlyOwner {
        _isDog[wallet] = true;
    }

    function removeTheDog(address wallet) external onlyOwner {
        _isDog[wallet] = false;
    }

    function updateUnleashed(bool unleash) external onlyOwner {
        unleashed = unleash;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");
        require(!_isDog[from] && !_isDog[to], "Dogos not allowed");

        if(!unleashed) {
            require(_balance[to] + amount <= oneHalfPercent, "No more");
        }

        uint256 _tax;
        if (_isCat[from] || _isCat[to]) {
            _tax = 0;
        } else {
            require(
                launched == true,
                "Launch"
            );

            if (inSwapAndLiquify == 1) {
                //No tax transfer
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == uniswapV2Pair) {
                _tax = getTheTax();
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > minSwap && inSwapAndLiquify == 0) {
                    if (tokensToSwap > somethingPercent) {
                        tokensToSwap = somethingPercent;
                    }
                    inSwapAndLiquify = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = WETH;
                    uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            marketingWallet,
                            block.timestamp
                        );
                    inSwapAndLiquify = 0;
                }
                 _tax = getTheTax(); 
            } else {
                _tax = 0;
            }
        }

        //Is there tax for sender|receiver?
        if (_tax != 0) {
            //Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            _balance[to] += transferAmount;
            _balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            //No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}

    function getTheTax() internal view returns (uint256) {
        return block.number < startingBlock + 5 ? 50 : theTax;
    }

    function changeTax(uint256 theNewTax) external onlyOwner {
        theTax = theNewTax;
    }

     function recover() external onlyOwner {
          IERC20(address(this)).transfer(
                msg.sender,
                IERC20(address(this)).balanceOf(address(this))
            );
    }
}