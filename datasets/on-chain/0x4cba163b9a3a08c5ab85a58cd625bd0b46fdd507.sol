// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.28;

/// @dev Unlocks token - GMT: Saturday, January 11, 2025 9:09:09 AM.
contract Timelock {
    function unlock() public {
        if (block.timestamp >= 1736586549) token.transfer(ops, token.balanceOf(this));
    }
}

address constant ops = 0x0000000000001d8a2e7bf6bc369525A2654aa298;
IERC20 constant token = IERC20(0x00000000000007C8612bA63Df8DdEfD9E6077c97);

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function balanceOf(Timelock) external view returns (uint256);
}