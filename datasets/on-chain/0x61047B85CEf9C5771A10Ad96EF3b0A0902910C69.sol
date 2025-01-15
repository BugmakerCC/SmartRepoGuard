// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import ERC20 Interface for handling tokens
interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract PrivateSale {
    // Supported stablecoin addresses
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC contract address
    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDP contract address
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI contract address

    // Token contract address
    address public tokenAddress;

    // Sale status
    bool public saleActive;

    // Contract owner
    address public owner;

    // User deposits and token allocations
    struct UserDeposit {
        uint256 usdcDeposit;
        uint256 usdtDeposit;
        uint256 daiDeposit;
        // uint256 tokenAllocation;
    }

    // Mapping to track user deposits and allocations
    mapping(address => UserDeposit) public userDeposits;

    // Minimum and maximum buy limits (stored internally in 18 decimals)
    // uint256 public minBuyAmount;
    // uint256 public maxBuyAmount;

    // Token price in the format of [amount of stablecoin per token]
    // uint public tokenPrice; // Stablecoin address => price in 18 decimals

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier saleIsOpen {
        require(saleActive, "Sale is not active");
        _;
    }

    // Events
    event Deposit(address indexed user, uint256 amount, address stablecoin);
    event SaleStatusChanged(bool saleActive);

    constructor() {
        // tokenAddress = _tokenAddress;
        owner = msg.sender;
        // minBuyAmount = _minBuyAmount;  // Store in 18 decimals
        // maxBuyAmount = _maxBuyAmount;  // Store in 18 decimals

        // Set initial token prices for each stablecoin in 18 decimals
    
        // tokenPrice = 10 * (10 ** 18); // $10 in DAI
    }
    
    // Function to start the private sale
    function startSale() external onlyOwner {
        require(!saleActive, "Sale is already active");
        saleActive = true;
        emit SaleStatusChanged(true);
    }

    // Function to end the private sale
    function endSale() external onlyOwner {
        require(saleActive, "Sale is already ended");
        saleActive = false;
        emit SaleStatusChanged(false);
    }

    // Function to get the decimals of a given token
    function getTokenDecimals(address token) public view returns (uint8) {
        return ERC20(token).decimals();
    }

    // // Function to deposit stablecoins and register the transaction with dynamic decimals handling
    // function deposit(uint256 amount, address stablecoin) external saleIsOpen {
    //     require(stablecoin == USDC_ADDRESS || stablecoin == USDP_ADDRESS || stablecoin == DAI_ADDRESS, "Unsupported stablecoin");

    //     // Get the stablecoin's decimals
    //     uint8 stablecoinDecimals = getTokenDecimals(stablecoin);

    //     // Adjust amount to 18 decimals for consistency
    //     uint256 scaledAmount = adjustTo18Decimals(amount, stablecoinDecimals);

    //     // Get the token price in 18 decimals
    //     uint256 price = tokenPrice[stablecoin];
    //     uint256 scaledMinBuyAmount = adjustFrom18Decimals(minBuyAmount, stablecoinDecimals);
    //     uint256 scaledMaxBuyAmount = adjustFrom18Decimals(maxBuyAmount, stablecoinDecimals);

    //     require(scaledAmount >= scaledMinBuyAmount && scaledAmount <= scaledMaxBuyAmount, "Deposit amount not within allowed range");

    //     // Transfer stablecoins from user to contract
    //     require(ERC20(stablecoin).transferFrom(msg.sender, address(this), amount), "Transfer failed");

    //     // Calculate token amount to allocate based on deposited amount and token price
    //     // uint256 tokensToAllocate = scaledAmount / price;

    //     // Update user's deposit and allocated tokens
    //     if (stablecoin == USDC_ADDRESS) {
    //         userDeposits[msg.sender].usdcDeposit += amount;
    //     } else if (stablecoin == USDP_ADDRESS) {
    //         userDeposits[msg.sender].usdpDeposit += amount;
    //     } else if (stablecoin == DAI_ADDRESS) {
    //         userDeposits[msg.sender].daiDeposit += amount;
    //     }
    //     // userDeposits[msg.sender].tokenAllocation += tokensToAllocate;

    //     // Emit deposit event
    //     emit Deposit(msg.sender, amount, stablecoin);
    // }
    
   // Function to handle USDC purchases
     // Function to handle USDC purchases
   function BuyWithUSDC(uint256 amount) external saleIsOpen {
    // uint8 usdcDecimals = getTokenDecimals(USDC_ADDRESS);
    
    
    // Convert amount to 18 decimals for internal consistency
    // uint256 scaledAmount = adjustTo18Decimals(amount, usdcDecimals);
    // uint256 scaledMinBuyAmount = adjustFrom18Decimals(minBuyAmount, usdcDecimals);
    // uint256 scaledMaxBuyAmount = adjustFrom18Decimals(maxBuyAmount, usdcDecimals);
    

    // require(scaledAmount >= scaledMinBuyAmount && scaledAmount <= scaledMaxBuyAmount, "Deposit amount not within allowed range");
    
    // Perform the token transfer (in native USDC decimals)
    require(ERC20(USDC_ADDRESS).transferFrom(msg.sender, address(this), amount), "USDC Transfer failed");

    // Record the user's deposit in native token decimals (6 for USDC)
    userDeposits[msg.sender].usdcDeposit += amount;

    emit Deposit(msg.sender, amount, USDC_ADDRESS);
}

    // Function to handle DAI purchases
 function BuyWithDAI(uint256 amount) external saleIsOpen {
    // uint8 daiDecimals = getTokenDecimals(DAI_ADDRESS);
    
    // uint256 scaledAmount = adjustTo18Decimals(amount, daiDecimals);
    // uint256 scaledMinBuyAmount = adjustFrom18Decimals(minBuyAmount, daiDecimals);
    // uint256 scaledMaxBuyAmount = adjustFrom18Decimals(maxBuyAmount, daiDecimals);

    // require(scaledAmount >= scaledMinBuyAmount && scaledAmount <= scaledMaxBuyAmount, "Deposit amount not within allowed range");

    require(ERC20(DAI_ADDRESS).transferFrom(msg.sender, address(this), amount), "DAI Transfer failed");

    userDeposits[msg.sender].daiDeposit += amount;

    emit Deposit(msg.sender, amount, DAI_ADDRESS);
}

function BuyWithUSDT(uint256 amount) external saleIsOpen {
    // uint8 usdpDecimals = getTokenDecimals(USDP_ADDRESS);
    
    // uint256 scaledAmount = adjustTo18Decimals(amount, usdpDecimals);
    // uint256 scaledMinBuyAmount = adjustFrom18Decimals(minBuyAmount, usdpDecimals);
    // uint256 scaledMaxBuyAmount = adjustFrom18Decimals(maxBuyAmount, usdpDecimals);

    // require(scaledAmount >= scaledMinBuyAmount && scaledAmount <= scaledMaxBuyAmount, "Deposit amount not within allowed range");

    require(ERC20(USDT_ADDRESS).transferFrom(msg.sender, address(this), amount), "USDP Transfer failed");

    userDeposits[msg.sender].usdtDeposit += amount;

    emit Deposit(msg.sender, amount, USDT_ADDRESS);
}

    // // Function to adjust amounts to 18 decimals for consistency
    // function adjustTo18Decimals(uint256 amount, uint8 decimals) public pure returns (uint256) {
    //     if (decimals < 18) {
    //         return amount * (10 ** (18 - decimals));
    //     } else if (decimals > 18) {
    //         return amount / (10 ** (decimals - 18));
    //     }
    //     return amount;
    // }

    // // Function to adjust amounts from 18 decimals back to token's decimals
    // function adjustFrom18Decimals(uint256 amount, uint8 decimals) public pure returns (uint256) {
    //     if (decimals < 18) {
    //         return amount / (10 ** (18 - decimals));
    //     } else if (decimals > 18) {
    //         return amount * (10 ** (decimals - 18));
    //     }
    //     return amount;
    // }

    // Function to get a detailed report of user's deposits and token allocations
    function getAllocatedTokens(address user) external view returns (
        uint256 usdcDeposit,
        uint256 usdtDeposit,
        uint256 daiDeposit
        // uint256 totalTokensAllocated
    ) {
        UserDeposit memory userDeposit = userDeposits[user];

        // Return the user's stablecoin deposits and token allocations
        return (
            userDeposit.usdcDeposit,
            userDeposit.usdtDeposit,
            userDeposit.daiDeposit
            // userDeposit.tokenAllocation
        );
    }

    // Function to withdraw stablecoins after the sale
    function withdrawTokens() external onlyOwner {
        uint256 usdcBalance = ERC20(USDC_ADDRESS).balanceOf(address(this));
        uint256 usdpBalance = ERC20(USDT_ADDRESS).balanceOf(address(this));
        uint256 daiBalance = ERC20(DAI_ADDRESS).balanceOf(address(this));

        require(ERC20(USDC_ADDRESS).transfer(owner, usdcBalance), "USDC Transfer failed");
        require(ERC20(USDT_ADDRESS).transfer(owner, usdpBalance), "USDP Transfer failed");
        require(ERC20(DAI_ADDRESS).transfer(owner, daiBalance), "DAI Transfer failed");
    }

    // Function to set minimum and maximum buy amounts with dynamic handling of decimals
    // function setMinMaxBuyAmount(uint256 _minBuyAmount, uint256 _maxBuyAmount) external onlyOwner {
    //     require(_minBuyAmount <= _maxBuyAmount, "Invalid amounts");
    //     minBuyAmount = _minBuyAmount;  // Store in 18 decimals
    //     maxBuyAmount = _maxBuyAmount;
    // }

    // Function to transfer ownership
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function withdrawERC20(address stuckTokenAddress) external onlyOwner {
        ERC20 token = ERC20(stuckTokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.transfer(owner, balance);
    }

    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    
}