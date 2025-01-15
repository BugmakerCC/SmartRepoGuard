// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Test {
    function testStatic() public view returns (address){
        return tx.origin;
    }
}