// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentBot {
    address public owner;
    mapping(address => uint256) internal  payments;
    mapping(address => bytes32) internal  keys;

    event PaymentReceived(address indexed payer, uint256 amount, uint256 duration);
    event KeyGenerated(address indexed user, bytes32 key);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Enhanced key generation function
    function generateKey(address user) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(user, block.timestamp, block.difficulty, blockhash(block.number - 1)));
    }

    // Retrieve the key for a user
    function getKey(address user) public view returns (bytes32) {
        return keys[user];
    }

    // Function for automatic payment acceptance
    receive() external payable {
        require(msg.value == 0.06 ether || msg.value == 0.3 ether || msg.value == 0.5 ether, "Invalid payment amount");

        uint256 duration;
        if (msg.value == 0.06 ether) {
            duration = 30;
        } else if (msg.value == 0.3 ether) {
            duration = 180;
        } else if (msg.value == 0.5 ether) {
            duration = 365;
        }

        payments[msg.sender] = duration;
        bytes32 key = generateKey(msg.sender);
        keys[msg.sender] = key;

        emit PaymentReceived(msg.sender, msg.value, duration);
        emit KeyGenerated(msg.sender, key);
    }

    // Withdraw funds, only accessible to the owner
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}