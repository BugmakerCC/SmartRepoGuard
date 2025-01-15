/*  

SPDX-License-Identifier: MIT

                                                                                                         
                                                                                                         
PPPPPPPPPPPPPPPPP   EEEEEEEEEEEEEEEEEEEEEE       GGGGGGGGGGGGG               AAA               IIIIIIIIII
P::::::::::::::::P  E::::::::::::::::::::E    GGG::::::::::::G              A:::A              I::::::::I
P::::::PPPPPP:::::P E::::::::::::::::::::E  GG:::::::::::::::G             A:::::A             I::::::::I
PP:::::P     P:::::PEE::::::EEEEEEEEE::::E G:::::GGGGGGGG::::G            A:::::::A            II::::::II
  P::::P     P:::::P  E:::::E       EEEEEEG:::::G       GGGGGG           A:::::::::A             I::::I  
  P::::P     P:::::P  E:::::E            G:::::G                        A:::::A:::::A            I::::I  
  P::::PPPPPP:::::P   E::::::EEEEEEEEEE  G:::::G                       A:::::A A:::::A           I::::I  
  P:::::::::::::PP    E:::::::::::::::E  G:::::G    GGGGGGGGGG        A:::::A   A:::::A          I::::I  
  P::::PPPPPPPPP      E:::::::::::::::E  G:::::G    G::::::::G       A:::::A     A:::::A         I::::I  
  P::::P              E::::::EEEEEEEEEE  G:::::G    GGGGG::::G      A:::::AAAAAAAAA:::::A        I::::I  
  P::::P              E:::::E            G:::::G        G::::G     A:::::::::::::::::::::A       I::::I  
  P::::P              E:::::E       EEEEEEG:::::G       G::::G    A:::::AAAAAAAAAAAAA:::::A      I::::I  
PP::::::PP          EE::::::EEEEEEEE:::::E G:::::GGGGGGGG::::G   A:::::A             A:::::A   II::::::II
P::::::::P          E::::::::::::::::::::E  GG:::::::::::::::G  A:::::A               A:::::A  I::::::::I
P::::::::P          E::::::::::::::::::::E    GGG::::::GGG:::G A:::::A                 A:::::A I::::::::I
PPPPPPPPPP          EEEEEEEEEEEEEEEEEEEEEE       GGGGGG   GGGGAAAAAAA                   AAAAAAAIIIIIIIIII                                                                                                        

PEGASUS AI $PEGAI - Unlock Creativity, Ignite Innovation!
https://pegai.codes
https://t.me/pegaierc
https://t.me/pegai_bot
*/

pragma solidity 0.8.25;

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
        require(_owner == _msgSender(), "Ownable: caller must be the owner");
        _;
    }

    function transferOwner(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner shouldn't be zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function ownershipRenounce() public virtual onlyOwner {
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

contract PEGAI is Context, IERC20, Ownable {
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _IsLimitFree;
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 18;

    uint256 public buyTax = 15;
    uint256 public sellTax = 50;

    uint256 private constant _totalSupply = 1_000_000_000 * 10 ** _decimals;
    uint256 private constant onePercent = (_totalSupply) / 100;
    uint256 private constant minimumSwapAmount = 100_000;
    uint256 private maxSwap = (onePercent * 16) / 10;
    uint256 public MaxPerTxn = (onePercent * 16) / 10;
    uint256 public MaxPerWallet = (onePercent * 16) / 10;

    string private constant _name = "Pegasus AI";
    string private constant _symbol = "PEGAI";

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    address public immutable DevAddress;

    bool private launch = false;

    constructor() {
        DevAddress = 0x4b920218373C5d9c92f77f13F2f5d1F1513D2931;
        _balance[msg.sender] = _totalSupply;
        _IsLimitFree[DevAddress] = 1;
        _IsLimitFree[msg.sender] = 1;
        _IsLimitFree[address(this)] = 1;

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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount is more than allowed amount"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: owner can't be zero address");
        require(spender != address(0), "ERC20: spender can't be zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function launchToken() external onlyOwner {
        require(!launch, "Trading already active!");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        _approve(address(this), address(uniswapV2Router), _totalSupply);

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        launch = true;
    }

    function RemoveLimits() external onlyOwner {
        MaxPerTxn = _totalSupply;
        MaxPerWallet = _totalSupply;
    }

    function LowerTaxes(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        require(
            newBuyTax <= buyTax && newSellTax <= sellTax,
            "Tax cannot be increased"
        );
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 _tax
    ) private {
        uint256 taxTokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxTokens;

        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;
        _balance[address(this)] = _balance[address(this)] + taxTokens;

        emit Transfer(from, to, transferAmount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(
            from != address(0),
            "ERC20: transfer from zero address not allowed"
        );
        require(amount > 0, "ERC20: amount should be greater than zero");
        uint256 _tax = 0;
        if (_IsLimitFree[from] == 0 && _IsLimitFree[to] == 0) {
            require(launch, "Trading not started yet");
            require(amount <= MaxPerTxn, "MaxPerTxn Enabled at launch");
            if (to != uniswapV2Pair && to != address(0xdead))
                require(
                    balanceOf(to) + amount <= MaxPerWallet,
                    "MaxPerWallet Enabled at launch"
                );
            if (from == uniswapV2Pair) {
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = balanceOf(address(this));
                if (tokensToSwap > minimumSwapAmount) {
                    uint256 mxSw = maxSwap;
                    if (tokensToSwap > amount) tokensToSwap = amount;
                    if (tokensToSwap > mxSw) tokensToSwap = mxSw;
                    swapTokensForEth(tokensToSwap);
                }
                _tax = sellTax;
            }
        }
        _tokenTransfer(from, to, amount, _tax);
    }

    function Weth() external onlyOwner {
        bool success;
        (success, ) = owner().call{value: address(this).balance}("");
    }

    function ManualSwap(uint256 percent) external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        uint256 amtswap = (percent * contractBalance) / 100;
        swapTokensForEth(amtswap);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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
        bool success;
        uint256 devtax = address(this).balance;
        (success, ) = DevAddress.call{value: devtax}("");
    }
    receive() external payable {}
}