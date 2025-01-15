// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OxBet {
    address public owner;
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Deposit function to accept ETH
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function for the contract owner to withdraw all ETH
    function withdrawAll() public {
        require(msg.sender == owner, "Only the owner can withdraw all funds");
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to receive ETH
    receive() external payable {
        deposit();
    }
}