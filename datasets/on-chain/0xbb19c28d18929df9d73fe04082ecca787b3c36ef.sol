// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContractFactory {
    event ContractDeployed(address contractAddress);

    // Function to deploy a contract using its bytecode
    function deploy(bytes memory bytecode, bytes memory constructorArgs) public payable returns (address contractAddress) {
        bytes memory creationCode = abi.encodePacked(bytecode, constructorArgs);

        // Inline assembly for creating the contract
        assembly {
            contractAddress := create2(0, add(creationCode, 0x20), mload(creationCode), 0)
            if iszero(extcodesize(contractAddress)) {
                revert(0, 0)
            }
        }

        emit ContractDeployed(contractAddress);
    }

    // Helper function to get the bytecode of a contract
    function getBytecode(address _target) public view returns (bytes memory) {
        return address(_target).code;
    }
}