/*
    _____
   /     \
  | () () |
   \  ^  /
    |||||
    |||||

  https://knots.finance/ Proprietary
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IYieldToken {
    function mint(address to, uint256 amount) external;
}

contract RecursiveFarming {
    mapping(address => uint256) public stakedBalance;
    uint256 public totalStaked;
    IYieldToken private yieldToken;
    uint256 private constant recursionDepth = 10;
    
    constructor(address _yieldToken) {
        yieldToken = IYieldToken(_yieldToken);
    }

    function stake(uint256 amount) external {
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;
        reinvestYield(amount, 0);
    }

    function reinvestYield(uint256 amount, uint256 depth) internal {
        if (depth >= recursionDepth || amount == 0) return;

        uint256 yield = calculateYield(amount);
        stakedBalance[msg.sender] += yield;
        totalStaked += yield;
        yieldToken.mint(msg.sender, yield);

        reinvestYield(yield, depth + 1);
    }

    function calculateYield(uint256 amount) internal pure returns (uint256) {
        return amount / 10;
    }

    function unstake(uint256 amount) external {
        require(stakedBalance[msg.sender] >= amount, "Not enough staked");
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;
    }

    function deformYield(uint256 deformationFactor) external {
        uint256 deformation = totalStaked / deformationFactor;
        totalStaked -= deformation;
        reinvestYield(deformation, 0);
    }
}