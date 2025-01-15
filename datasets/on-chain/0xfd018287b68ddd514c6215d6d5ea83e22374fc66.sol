// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DelayedGratification {
    address public owner;
    address public currentAllowee;
    uint256 public allowanceBlockNumber;
    uint256 public constant DELAY_BLOCKS = 50;
    uint256 public wasteCounter;

    constructor() {
        owner = msg.sender;
    }

    function delayed() external {
        if (currentAllowee != msg.sender) {
            currentAllowee = msg.sender;
            allowanceBlockNumber = block.number + DELAY_BLOCKS;

            /*uint256 gasToWaste = DELAY_BLOCKS - (allowanceBlockNumber - block.number);
            for (uint256 i = 0; i < gasToWaste; i++) {
                bytes32 slot = keccak256(abi.encodePacked(wasteCounter));
                assembly {
                    sstore(slot, i)
                }
                wasteCounter++;
            }*/
        }
    }

    function gratification() external {
        require(msg.sender == currentAllowee, "The universe whispers: Patience is a virtue, young grasshopper");
        require(block.number >= allowanceBlockNumber, "Time is but a river, and your boat hasn't reached the shore yet");

        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);

        currentAllowee = address(0);
        allowanceBlockNumber = 0;
    }

    function ownerWithdraw() external {
        require(msg.sender == owner, "The key you hold does not unlock this door of destiny");

        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);

        currentAllowee = address(0);
        allowanceBlockNumber = 0;
    }

    receive() external payable {}
}