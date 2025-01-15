// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract UpgradeProxy {
    // Function to update the implementation address in the proxy contract
    function updateImplementation(address, address newImplementation) external {
        // EIP-1967 implementation slot: keccak256("eip1967.proxy.implementation") - 1
        bytes32 implementationSlot = 0x360894A13BA1A3210667C828492DB98DCA3E2076CC3735A920A3CA505D382BBC;

        // Store the new implementation address in the correct storage slot
        assembly {
            sstore(implementationSlot, newImplementation)
        }
    }
}