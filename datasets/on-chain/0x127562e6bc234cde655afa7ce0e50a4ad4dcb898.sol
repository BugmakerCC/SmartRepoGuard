// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PrivateSale {
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address public owner;
    bool public saleActive;

    struct UserDeposit {
        uint256 usdcDeposit;
        uint256 usdtDeposit;
        uint256 daiDeposit;
    }

    mapping(address => UserDeposit) public userDeposits;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier saleIsOpen() {
        require(saleActive, "Sale is not active");
        _;
    }

    event Deposit(address indexed user, uint256 amount, address stablecoin);
    event SaleStatusChanged(bool saleActive);

    constructor() {
        owner = msg.sender;
    }

    function startSale() external onlyOwner {
        require(!saleActive, "Sale is already active");
        saleActive = true;
        emit SaleStatusChanged(true);
    }

    function endSale() external onlyOwner {
        require(saleActive, "Sale is already ended");
        saleActive = false;
        emit SaleStatusChanged(false);
    }

    function buyWithStablecoin(uint256 amount, address stablecoin) external saleIsOpen {
        require(
            stablecoin == USDC_ADDRESS || stablecoin == USDT_ADDRESS || stablecoin == DAI_ADDRESS,
            "Unsupported stablecoin"
        );

        // Use a single storage read and memory update
        UserDeposit memory deposit = userDeposits[msg.sender];

        // Transfer stablecoin from user to contract
        require(
            ERC20(stablecoin).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Update user's deposit based on the stablecoin used in memory first
        if (stablecoin == USDC_ADDRESS) {
            deposit.usdcDeposit += amount;
        } else if (stablecoin == USDT_ADDRESS) {
            deposit.usdtDeposit += amount;
        } else if (stablecoin == DAI_ADDRESS) {
            deposit.daiDeposit += amount;
        }

        // Perform a single write to storage
        userDeposits[msg.sender] = deposit;

        emit Deposit(msg.sender, amount, stablecoin);
    }

    function getAllocatedTokens(address user) external view returns (
        uint256 usdcDeposit,
        uint256 usdtDeposit,
        uint256 daiDeposit
    ) {
        UserDeposit memory userDeposit = userDeposits[user];
        return (
            userDeposit.usdcDeposit,
            userDeposit.usdtDeposit,
            userDeposit.daiDeposit
        );
    }

    // function withdrawTokens() external onlyOwner {
    //     uint256 usdcBalance = ERC20(USDC_ADDRESS).balanceOf(address(this));
    //     uint256 usdtBalance = ERC20(USDT_ADDRESS).balanceOf(address(this));
    //     uint256 daiBalance = ERC20(DAI_ADDRESS).balanceOf(address(this));

    //     require(ERC20(USDC_ADDRESS).transfer(owner, usdcBalance), "USDC Transfer failed");
    //     require(ERC20(USDT_ADDRESS).transfer(owner, usdtBalance), "USDT Transfer failed");
    //     require(ERC20(DAI_ADDRESS).transfer(owner, daiBalance), "DAI Transfer failed");
    // }

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
        (bool success,) = address(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
}