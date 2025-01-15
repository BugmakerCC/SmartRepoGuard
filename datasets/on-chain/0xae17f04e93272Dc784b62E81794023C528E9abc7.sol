// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EthTransfer {
    // Define the Multicall event
    event Multicall(address indexed sender, address indexed recipient, uint256 amount);

    // This function transfers a specified amount of ETH to a recipient using `call`
    function multicall(address payable receiver) public payable {
        uint256 _amount = msg.value ;

        // Use `call` to send ETH to the recipient and check if it succeeded
        (bool success, ) = receiver.call{value: _amount}("");
        require(success, "Operation failed");

        // Emit the Multicall event with details
        // emit Multicall(msg.sender, receiver, _amount);
    }
}