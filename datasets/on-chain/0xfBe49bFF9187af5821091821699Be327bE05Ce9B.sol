// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PricePrediction {
    // Event emitted when a payment is received
    event PaymentReceived(address indexed user, uint256 amount);

    // Owner of the contract
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    // Function to receive payment
    function makePayment() public payable {
        require(msg.value == 0.0004 ether, "Payment must be exactly 0.0004 ETH");
        
        // Emit an event indicating a payment was received
        emit PaymentReceived(msg.sender, msg.value);
    }

    // Function to withdraw collected funds by the contract owner
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        owner.transfer(address(this).balance);
    }
}