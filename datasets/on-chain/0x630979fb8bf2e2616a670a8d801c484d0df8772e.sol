// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SketchyCandyVan {
    address public owner;
    mapping(address => bool) public hasTakenCandy;
    
    constructor() payable {
        owner = msg.sender;
    }
    
    function buyCandy() public payable {
        require(msg.value >= 0.005 ether, "You must pay the van driver!");
        require(address(this).balance >= 0.01 ether, "Not enough candy left!");
        
        uint256 notRandomNumber = uint256(keccak256(abi.encodePacked(block.number, block.prevrandao))) % 100;
        
        if (notRandomNumber < 50) {
            revert("No candy for you!");
        }
        
        payable(msg.sender).transfer(0.01 ether);
    }

    function freeCandy() public {
        require(!hasTakenCandy[msg.sender], "You've already taken a free sample!");
        require(address(this).balance >= 0.005 ether, "Not enough candy left!");
        
        hasTakenCandy[msg.sender] = true;
        payable(msg.sender).transfer(0.005 ether);
    }
    
    function closeShop() public {
        require(msg.sender == owner, "Only the van driver can close the shop!");
        selfdestruct(payable(owner));
    }
    
    receive() external payable {}
}