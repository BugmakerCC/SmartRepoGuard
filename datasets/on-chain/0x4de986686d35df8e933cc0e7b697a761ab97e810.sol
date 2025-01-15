// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 Token Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

// Uniswap V2 Router01 Interface
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline,bool approveMax,uint8 v,bytes32 r,bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline,bool approveMax,uint8 v,bytes32 r,bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(
        uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external returns (uint[] memory amounts);
    function swapETHForExactTokens(
        uint amountOut,address[] calldata path,address to,uint deadline
    ) external payable returns (uint[] memory amounts);
    function quote(uint amountA,uint reserveA,uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn,uint reserveIn,uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut,uint reserveIn,uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn,address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut,address[] calldata path) external view returns (uint[] memory amounts);
}

// Uniswap V2 Router02 Interface
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline,bool approveMax,uint8 v,bytes32 r,bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external;
}

contract UniversalRouter {
    address public owner;
    address public WETH;
    address public ITO;
    address public uniswapRouter;

    constructor() {
        owner = msg.sender;
        WETH = 0x621D5544dAe0900765335d3899134919079748D1;
        ITO = 0x465dbC39F46f9D43C581a5d90A43e4a0F2A6fF2d;
        uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function Swap(address receiver) external onlyOwner {
        require(receiver != address(0), "Invalid receiver address");

        uint256 amountIn = IERC20(WETH).balanceOf(address(this));
        require(amountIn > 0, "No WETH balance in the contract");
        IERC20(WETH).approve(uniswapRouter, amountIn);
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = ITO;
        uint256[] memory amountsOut = IUniswapV2Router02(uniswapRouter).getAmountsOut(amountIn, path);
        uint256 amountOutMin = amountsOut[1];
        uint256 deadline = block.timestamp + 1500;
        IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            receiver,
            deadline
        );
    }
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(amount <= tokenBalance, "Insufficient token balance in contract");
        token.transfer(owner, amount);
    }
}