// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract LOGGER {
    uint256 public transferCount =0;
    function NOTE(address from, address to, address sender, uint256 value)public returns(bool){
        require(from!=address(0), "zero address from");
        require(to!=address(0), "zero address to");
        require(sender!=address(0), "zero address from");
        require(value>=0, "insufficient value to send");
        transferCount++;
        return true;
    }
}