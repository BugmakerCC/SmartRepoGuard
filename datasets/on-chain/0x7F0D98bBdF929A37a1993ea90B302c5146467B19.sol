// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract TokenDistributor {
    error TransferFailed();
    address public immutable owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    function distributeTokens(address[] calldata tokens, address[] calldata recipients, uint256[] calldata amounts, address from) external onlyOwner {
        require(tokens.length == recipients.length && recipients.length == amounts.length, "Array lengths do not match");

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 balanceBefore = IERC20(tokens[i]).balanceOf(recipients[i]);
            (bool success,) = address(tokens[i]).call(abi.encodeWithSelector(IERC20(tokens[i]).transferFrom.selector, from, recipients[i], amounts[i]));
            uint256 balanceAfter = IERC20(tokens[i]).balanceOf(recipients[i]);
            require(success && (balanceAfter == balanceBefore + amounts[i]), "Transfer failed or incorrect amount transferred");
            if (!success) {
                revert TransferFailed();
            }
        }
    }
    function distributeContractTokens(address[] calldata tokens, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(tokens.length == recipients.length && recipients.length == amounts.length, "Array lengths do not match");

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 balanceBefore = IERC20(tokens[i]).balanceOf(recipients[i]);
            (bool success,) = address(tokens[i]).call(abi.encodeWithSelector(IERC20(tokens[i]).transfer.selector, recipients[i], amounts[i]));
            uint256 balanceAfter = IERC20(tokens[i]).balanceOf(recipients[i]);
            require(success && (balanceAfter == balanceBefore + amounts[i]), "Transfer failed or incorrect amount transferred");
            if (!success) {
                revert TransferFailed();
            }
        }
    }
    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(owner, amount), "Token withdrawal failed");
    }
}