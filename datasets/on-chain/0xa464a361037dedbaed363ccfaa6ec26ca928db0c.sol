// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Standard interface for ERC20 token
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// Uniswap V2 Router interface
interface IUniswapV2Router02 {
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Subscription {
    address public owner; // Contract owner
    address public usdtToken; // USDT token address
    address public paymentToken; // Payment token address
    address public wethToken; // Wrapped ETH (WETH) address
    address public uniswapRouter; // Uniswap V2 Router address

    enum Package { Basic, Pro, Ultimate } // Subscription packages

    mapping(Package => uint256) public subscriptionPrices; // Subscription package prices in USDT

    mapping(address => uint256) public subscriptions; // User subscription expiry times
    mapping(address => Package) public userPackages; // User subscription packages

    constructor(
        address _usdtToken,
        address _paymentToken,
        address _wethToken,
        address _uniswapRouter,
        uint256 _basicPrice,
        uint256 _proPrice,
        uint256 _ultimatePrice
    ) {
        owner = msg.sender;
        usdtToken = _usdtToken;
        paymentToken = _paymentToken;
        wethToken = _wethToken;
        uniswapRouter = _uniswapRouter;

        // Set subscription prices for each package
        subscriptionPrices[Package.Basic] = _basicPrice;
        subscriptionPrices[Package.Pro] = _proPrice;
        subscriptionPrices[Package.Ultimate] = _ultimatePrice;
    }

    // Function for users to subscribe to a package
    function subscribe(Package packageType) external {
        // Calculate the required payment token amount
        uint256 amountInPaymentToken = getAmountInPaymentToken(packageType);

        // Transfer payment tokens from user to the contract
        require(
            IERC20(paymentToken).transferFrom(msg.sender, address(this), amountInPaymentToken),
            "Transfer failed"
        );

        // Update user's subscription expiry and package
        subscriptions[msg.sender] = block.timestamp + 30 days;
        userPackages[msg.sender] = packageType;
    }

    // Function to calculate required payment token amount based on USDT price using Uniswap
    function getAmountInPaymentToken(Package packageType) public view returns (uint256) {
        uint256 amountOut = subscriptionPrices[packageType];

        address[] memory path = new address[](3); // Corrected address array declaration
        path[0] = paymentToken;
        path[1] = wethToken;
        path[2] = usdtToken;

        uint256[] memory amountsIn = IUniswapV2Router02(uniswapRouter).getAmountsIn(amountOut, path);

        return amountsIn[0];
    }

    // Function to get a user's subscription package and expiry time
    function getUserSubscription(address user) external view returns (Package packageType, uint256 expiryTime) {
        packageType = userPackages[user];
        expiryTime = subscriptions[user];
    }

    // Function for the contract owner to withdraw tokens from the contract
    function withdrawTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw tokens");
        IERC20(tokenAddress).transfer(owner, amount);
    }

    // Function for the contract owner to update subscription prices
    function updateSubscriptionPrice(Package packageType, uint256 newPrice) external {
        require(msg.sender == owner, "Only owner can update the price");
        subscriptionPrices[packageType] = newPrice;
    }
}