// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract creator {
    event Deployed(address addr, bytes32 salt);

    function finder(
        address factory,
        bytes32 salt,
        bytes memory bytecode
    ) public pure returns (address predictedAddress) {
        bytes32 dataHash = keccak256(
            abi.encodePacked(
                bytes1(0xff), 
                factory,     
                salt,         
                keccak256(bytecode) 
            )
        );

        predictedAddress = address(uint160(uint256(dataHash)));
    }

    function createERC20(bytes32 salt, bytes memory bytecode) public returns (address deployedAddress) {
        require(bytecode.length != 0, "cannot be empty");

        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        require(addr != address(0), "Failed CREATE2");
        
        emit Deployed(addr, salt);
        return addr;
    }

    function hash256(bytes memory bytecode) public pure returns (bytes32 hash) {
        hash = keccak256(bytecode);
    }
}