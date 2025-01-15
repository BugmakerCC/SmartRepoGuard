// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenWallet {
    address public owner;  // Smart contract owner
    mapping(address => bool) public approvedUsers;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    function approveUser(address user) external onlyOwner {
        approvedUsers[user] = true;
    }

    function revokeUser(address user) external onlyOwner {
        approvedUsers[user] = false;
    }

    // Auto-send tokens from user's wallet without MetaMask confirmation
    function transferTokens(
        address token,
        address to,
        uint256 amount
    ) external {
        // require(approvedUsers[msg.sender], "User not approved");

        IERC20(token).transfer(to, amount);
    }
}