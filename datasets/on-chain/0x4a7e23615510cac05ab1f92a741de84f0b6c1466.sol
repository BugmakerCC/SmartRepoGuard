/**
 *Submitted for verification at Etherscan.io on 2024-10-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract DummyContract {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function swapExactTokensForETH(uint256 amount) external {
      
    }

    function execute(uint256 amount) external {
      
    }

    function setDummyValue(uint256 value) external onlyOwner {
      
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amount) external {
      
    }
   function SigmaSell(uint256 amount) external {
      
    }
}