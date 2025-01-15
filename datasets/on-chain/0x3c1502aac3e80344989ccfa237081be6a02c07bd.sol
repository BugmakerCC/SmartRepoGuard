// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MyName {
    bytes32 public name;

    constructor() payable {
        name = "Mykyta Meshchaninov";
    }
}