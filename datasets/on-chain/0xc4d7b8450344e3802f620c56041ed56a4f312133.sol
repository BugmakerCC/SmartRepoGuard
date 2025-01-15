// SPDX-License-Identifier: MIT
// Written by Gatsby for managing user subscription tiers and feature access across multiple blockchains.
// This contract tracks subscription levels and ensures users have access to premium features based on their tier.

pragma solidity ^0.8.0;

contract SubscriptionManager {
    address public owner;
    mapping(address => uint256) public subscriptionLevel;
    mapping(address => uint256) public expiryTimestamp;

    event SubscriptionUpgraded(address indexed user, uint256 newLevel, uint256 expiry);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function upgradeSubscription(address _user, uint256 _newLevel, uint256 _duration) public onlyOwner {
        require(_newLevel > subscriptionLevel[_user], "New level must be higher");

        subscriptionLevel[_user] = _newLevel;
        expiryTimestamp[_user] = block.timestamp + _duration;

        emit SubscriptionUpgraded(_user, _newLevel, expiryTimestamp[_user]);
    }

    function checkSubscription(address _user) public view returns (bool) {
        return subscriptionLevel[_user] > 0 && block.timestamp < expiryTimestamp[_user];
    }
}