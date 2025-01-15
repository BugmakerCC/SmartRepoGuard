// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Factory {
    address owner;
    address deployedAddress;
    bool deployed = false;
    
    constructor(){
        owner = msg.sender;
    }

    function deployToken(
        bytes memory bytecode,
        bytes32 salt
    ) public returns (address) {
        require(msg.sender == owner, "Not allowed");
        require(!deployed, "Already deployed");
        address addr;
        assembly {
            addr := create2(
                callvalue(),
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        deployed = true;
        deployedAddress = addr;
        return addr;
    }
}