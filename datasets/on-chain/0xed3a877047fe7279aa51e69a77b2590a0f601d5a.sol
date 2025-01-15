// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface ITargetContract {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract WithdrawProxy {
    address public targetContract;
    address payable public owner;

    constructor(address _targetContract) {
        targetContract = _targetContract;
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Function to withdraw tokens from the target contract
    function withdrawTokens() external onlyOwner {
        ITargetContract target = ITargetContract(targetContract);
        uint256 tokenBalance = target.balanceOf(targetContract);
        require(tokenBalance > 0, "No tokens to withdraw");
        require(target.transfer(owner, tokenBalance), "Token transfer failed");
    }

    // Function to withdraw ETH from the target contract
    function withdrawETH() external onlyOwner {
        (bool success, ) = targetContract.call{value: 0}(
            abi.encodeWithSignature("manualSwap()")
        );
        require(success, "ETH withdrawal failed");
    }

    // Function to receive ETH in case of direct transfers
    receive() external payable {}
}