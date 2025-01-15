// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import the ERC20 interface
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TokenDepositor {
    address public owner;
    address public depositAddress;
    uint256 public fee; // Fee in percentage (e.g., 5 for 5%)
    
    // Event to log deposits with fee
    event Deposit(
        uint256 indexed id,
        address indexed token,
        uint256 indexed amount,
        uint256 realAmount,
        uint256 fee
    );
    
    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    constructor(address _initialDepositAddress, uint256 _initialFee) {
        owner = msg.sender;
        depositAddress = _initialDepositAddress;
        fee = _initialFee;
    }
    
    // Function to change the deposit address
    function setDepositAddress(address _newDepositAddress) external onlyOwner {
        depositAddress = _newDepositAddress;
    }
    
    // Function to set the fee percentage, restricted to the owner
    function setFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 100, "Fee percentage cannot exceed 100");
        fee = _newFee;
    }
    
    // Function to deposit tokens with a specific ID
    function depositTokens(address token, uint256 amount, uint256 depositId) external {
        require(amount > 0, "Amount must be greater than 0");
        require(depositId > 0, "Deposit ID must be greater than 0");

        // Calculate the actual amount after deducting the fee
        uint256 amountAfterFee = amount - (amount * fee / 100);
        
        // Transfer tokens from the sender to the deposit address
        require(IERC20(token).transferFrom(msg.sender, depositAddress, amountAfterFee), "Token transfer failed");
        
        // Emit the deposit event with the original amount, amount after fee, and fee percentage
        emit Deposit(depositId, token, amountAfterFee, amount, fee);
    }
}