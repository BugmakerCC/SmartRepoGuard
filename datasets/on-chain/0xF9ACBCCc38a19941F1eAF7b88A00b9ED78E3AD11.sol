// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract E2TMinter {
    uint256 public constant MAX_ADDRESSES = 1222;

    struct WalletInfo {
        string message;
    }

    WalletInfo[] private addresses;
    mapping(bytes32 => bool) private hasSentMessage;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function mint(string memory wallet) external {
        require(addresses.length < MAX_ADDRESSES, "Mint limit reached");

        bytes32 messageHash = keccak256(abi.encodePacked(wallet));
        require(!hasSentMessage[messageHash], "Wallet already minted");

        addresses.push(WalletInfo(wallet));
        hasSentMessage[messageHash] = true;
    }

    function getAddresses() external view returns (WalletInfo[] memory) {
        return addresses;
    }
}