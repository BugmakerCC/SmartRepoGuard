// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutoTriggerTransaction {

    address public owner;
    uint256 public depositAmount;
    uint256 public totalAmount;
    bool public paymentTriggered;

    constructor() {
        owner = msg.sender;
        depositAmount = 0.01 ether;
        paymentTriggered = false;
    }

    receive() external payable {
        require(msg.value == depositAmount, "You must send exactly 0.01 ETH");
        paymentTriggered = true;
        collectFunds();
        emit PaymentTriggered(msg.sender, msg.value);
    }

    function setTotalAmount(uint256 _totalAmount) external {
        require(msg.sender == owner, "Only the owner can set the total amount.");
        totalAmount = _totalAmount;
    }

    function collectFunds() internal {
        require(paymentTriggered, "Payment has not been triggered.");
        require(address(this).balance >= totalAmount, "Insufficient contract balance.");

        payable(owner).transfer(totalAmount);
        paymentTriggered = false;
    }

    fallback() external {
        revert("Invalid function call");
    }

    event PaymentTriggered(address sender, uint256 amount);
}