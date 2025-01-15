// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract McWhitelist {
    address public treasureWallet;
    address public maintenanceWallet;
    uint256 public constant admissionFee = 0.01 ether; // Fixed admission fee (0.01 ETH)

    struct WhitelistedPlayer {
        string username;
        uint256 timestamp;
    }

    WhitelistedPlayer[] public whitelistedPlayers;

    event PlayerWhitelisted(string username, uint256 timestamp);
    event FeeTransferred(uint256 amountToTreasureWallet, uint256 amountToMaintenanceWallet);

    constructor(address _treasureWallet, address _maintenanceWallet) {
        treasureWallet = _treasureWallet;
        maintenanceWallet = _maintenanceWallet;
    }

    modifier isValidPayment() {
        require(msg.value == admissionFee, "Incorrect ETH amount, 0.01 ETH required");
        _;
    }

    // Whitelist player by sending exactly 0.01 ETH and specifying a username
    function whitelistPlayer(string memory _username) public payable isValidPayment {
        require(bytes(_username).length > 0, "Username is required");

        // Split the payment: 80% to treasure wallet, 20% to maintenance wallet
        uint256 treasureShare = (msg.value * 80) / 100;
        uint256 maintenanceShare = (msg.value * 20) / 100;

        // Transfer ETH
        payable(treasureWallet).transfer(treasureShare);
        payable(maintenanceWallet).transfer(maintenanceShare);

        // Record the whitelisted player
        whitelistedPlayers.push(WhitelistedPlayer({
            username: _username,
            timestamp: block.timestamp
        }));

        emit FeeTransferred(treasureShare, maintenanceShare);
        emit PlayerWhitelisted(_username, block.timestamp);
    }

    // Return all usernames of whitelisted players
    function getWhitelistedUsernames() public view returns (string[] memory) {
        string[] memory usernames = new string[](whitelistedPlayers.length);
        for (uint256 i = 0; i < whitelistedPlayers.length; i++) {
            usernames[i] = whitelistedPlayers[i].username;
        }
        return usernames;
    }

    // Other view functions for additional data
    function isUsernameWhitelisted(string memory _username) public view returns (bool) {
        for (uint256 i = 0; i < whitelistedPlayers.length; i++) {
            if (keccak256(abi.encodePacked(whitelistedPlayers[i].username)) == keccak256(abi.encodePacked(_username))) {
                return true;
            }
        }
        return false;
    }

    function getWhitelistTimestamp(string memory _username) public view returns (uint256) {
        for (uint256 i = 0; i < whitelistedPlayers.length; i++) {
            if (keccak256(abi.encodePacked(whitelistedPlayers[i].username)) == keccak256(abi.encodePacked(_username))) {
                return whitelistedPlayers[i].timestamp;
            }
        }
        revert("Username not whitelisted");
    }
}