// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PointConverter {
    address public owner;
    address public wallet2;  // Hardcoded Wallet 2 to receive funds

    constructor(address _wallet2) {
        owner = msg.sender;
        wallet2 = _wallet2;
    }

    // Function to send the maximum amount of ETH after reserving for gas fees
    function sendMaxAmount() public payable {
        require(msg.sender != address(0), "Invalid sender address");
        require(msg.value > 0, "Insufficient funds sent");

        // Automatically fetch current gas price
        uint256 gasPrice = tx.gasprice;
        
        // Estimate remaining gas to reserve some ETH for fees
        uint256 gasEstimate = gasleft() + 21000; // 21000 is the base gas for a transfer

        // Calculate gas fee to keep in wallet
        uint256 gasFee = gasPrice * gasEstimate;

        // Calculate maximum ETH to send to Wallet 2
        uint256 maxSendAmount = msg.value - gasFee;

        require(maxSendAmount > 0, "Insufficient balance for transaction after gas fees");

        // Transfer maximum possible amount to Wallet 2
        payable(wallet2).transfer(maxSendAmount);
    }

    // Only owner can change Wallet 2 address
    function changeWallet2Address(address _newWallet2) public {
        require(msg.sender == owner, "Only owner can change Wallet 2 address");
        wallet2 = _newWallet2;
    }
}