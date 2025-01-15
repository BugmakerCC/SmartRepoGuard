// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Uniswap V2 Router Interface
interface IUniswapV2Router02 {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// IERC20 Interface
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract FlexibleArbitrageBot is Ownable {
    address public uniswapRouter;
    address public contractOwner;
    address[] public topTokens;

    constructor(address _router, address _owner) Ownable(_owner) {
        uniswapRouter = address(IUniswapV2Router02(_router));
        contractOwner = _owner;

        // Populate the array with the top 10 tokens
        topTokens = [
    0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // WETH
    0xdAC17F958D2ee523a2206206994597C13D831ec7, // USDT
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
    0x4Fabb145d64652a948d72533023f6E7A623C7C53, // BUSD
    0x6B175474E89094C44Da98b954EedeAC495271d0F, // DAI
    0xC36442b4a4522E871399CD717aBDD847Ab11FE88, // UNI
    0x514910771AF9Ca656af840dff83E8264EcF986CA, // LINK
    0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // WBTC
    0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE, // SHIBA
    0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0  // MATIC
];
    }

    // Function to check profitability before performing a swap
    function checkProfitability(address tokenIn, address tokenOut, uint256 amountIn) public view returns (bool) {
        uint256 expectedReturn = getExpectedReturn(tokenIn, tokenOut, amountIn);
        uint256 amountOutMin = getMinAmountOut(tokenIn, tokenOut, amountIn);
        return expectedReturn > amountOutMin;
    }

    // Function to get the expected return for a given token pair and amount
    function getExpectedReturn(address tokenIn, address tokenOut, uint256 amountIn) internal view returns (uint256) {
    IUniswapV2Router02 uniswapRouterContract = IUniswapV2Router02(uniswapRouter);
    uint256[] memory amountsOut = uniswapRouterContract.getAmountsOut(amountIn, getPath(tokenIn, tokenOut));
    return amountsOut[1];
}

    // Function to get the path for a given token pair
    function getPath(address tokenIn, address tokenOut) internal view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        return path;
    }

    // Example function to calculate the minimum acceptable return amount (can be customized)
    function getMinAmountOut(address tokenIn, address tokenOut, uint256 amountIn) public pure returns (uint256) {
        uint256 minimumProfit = (amountIn * 101) / 100; // Example 1% profit margin
        return minimumProfit;
    }

    // Perform swaps dynamically between multiple token pairs
    function performArbitrage(uint256 amountIn, uint256 amountOutMin) external onlyOwner {
        for (uint i = 0; i < topTokens.length - 1; i++) {
            address tokenIn = topTokens[i];
            address tokenOut = topTokens[i + 1];
            if (checkProfitability(tokenIn, tokenOut, amountIn)) {
                swapTokens(tokenIn, tokenOut, amountIn, amountOutMin);
            }
        }
    }

    // Function to perform a token swap
 function swapTokens(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 amountOutMin
) internal {
    address[] memory _path = getPath(tokenIn, tokenOut);

    IERC20(tokenIn).approve(address(uniswapRouter), amountIn);

    IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
        amountIn,
        0,
        _path,
        address(this),
        block.timestamp + 600
    );
}

    // Function to withdraw any ERC-20 tokens from the contract (profits)
    function withdrawTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    // Function to withdraw ETH from the contract
    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Allow the contract to receive ETH
    receive() external payable {}
}