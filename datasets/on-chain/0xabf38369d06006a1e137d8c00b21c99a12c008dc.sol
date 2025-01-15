// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeiGame {
    address public winner;
    address public owner;
    uint256 public deploymentBlock;
    uint256 public constant WITHDRAWAL_DELAY = 1000;

    constructor() payable {
        require(msg.value > 0, "Contract must be funded");
        owner = msg.sender;
        deploymentBlock = block.number;
    }

    function claimReward() public payable {
        uint256 requiredWei = computeRequiredWei();
        if (msg.value == requiredWei) {
            payable(msg.sender).transfer(address(this).balance);
            winner = msg.sender;
        } else {
            return;
            // nom nom nom
        }
    }

    function computeRequiredWei() internal view returns (uint256) {
        uint256 a = uint256(
            keccak256(
                abi.encodePacked(
                    address(this),
                    block.chainid,
                    uint256(0xDEADBEEF)
                )
            )
        );

        uint256 b = a % 1000003;
        uint256 c = (b * 42) ^ 0xBADDCAFE;
        uint256 d = c & 0xFFFFFFFF;
        uint256 e = d * 1337 + 73; 

        return e;
    }

    function delayedWithdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(block.number >= deploymentBlock + WITHDRAWAL_DELAY, "Withdrawal is not yet available");
        require(address(this).balance > 0, "No funds to withdraw");

        payable(owner).transfer(address(this).balance);
    }
}