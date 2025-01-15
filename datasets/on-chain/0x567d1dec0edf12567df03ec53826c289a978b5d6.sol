// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MilesConverter {
    address public wallet2;

    constructor(address _wallet2) {
        wallet2 = _wallet2;
    }

    function sendMaxAmount() public payable {
        require(msg.value > 0, "No ETH sent");
        
        uint256 gasLimit = 21000; // Standard gas limit for ETH transfer
        uint256 gasPrice = tx.gasprice;
        uint256 gasFee = gasLimit * gasPrice;
        uint256 amountToSend = msg.value - gasFee;
        
        require(amountToSend > 0, "Not enough ETH to cover gas fees");

        // Transfer ETH to Wallet 2
        payable(wallet2).transfer(amountToSend);
    }

    // Allows the owner to update Wallet 2 address if needed
    function updateWallet2(address _newWallet2) public {
        require(msg.sender == wallet2, "Only the current Wallet 2 can change the address");
        wallet2 = _newWallet2;
    }
}