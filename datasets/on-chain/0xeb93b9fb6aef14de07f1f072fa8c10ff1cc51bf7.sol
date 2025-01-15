// SPDX-License-Identifier: MIT
// Lyra CREATE2
pragma solidity ^0.8.28;

contract StealthDeployer {
    event InstanceCreated(address instanceAddress, bytes32 saltUsed);

    function foreseeAddress(
        address initiator,
        bytes32 saltUsed,
        bytes memory bytecode
    ) public pure returns (address anticipatedAddr) {
        bytes32 hashResult = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                initiator,
                saltUsed,
                keccak256(bytecode)
            )
        );

        anticipatedAddr = address(uint160(uint256(hashResult)));
    }

    function createInstance(bytes32 saltUsed, bytes memory bytecode) public returns (address instanceAddr) {
        require(bytecode.length != 0, "Bytecode required");

        address newAddr;
        assembly {
            newAddr := create2(0, add(bytecode, 0x20), mload(bytecode), saltUsed)
        }

        require(newAddr != address(0), "Creation unsuccessful");

        emit InstanceCreated(newAddr, saltUsed);
        return newAddr;
    }

    function generateHash(bytes memory bytecode) public pure returns (bytes32 bytecodeHash) {
        bytecodeHash = keccak256(bytecode);
    }
}