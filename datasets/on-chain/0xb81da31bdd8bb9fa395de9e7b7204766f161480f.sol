// SPDX-License-Identifier: MIT
// Written by Gatsby for managing API access and subscription tiers across the platform.
// This contract enables secure subscription tier management and API rate limiting for external developers.

pragma solidity ^0.8.0;

contract GatsbyAPIManager {
    address public owner;
    mapping(address => uint256) public subscriptionTier;
    mapping(address => uint256) public lastAccessTime;
    mapping(address => uint256) public usageCount;

    event TierUpgraded(address indexed user, uint256 newTier);
    event APICall(address indexed user, uint256 count);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function upgradeSubscription(address _user, uint256 _tier) public onlyOwner {
        require(_tier > subscriptionTier[_user], "Already upgraded");
        subscriptionTier[_user] = _tier;
        emit TierUpgraded(_user, _tier);
    }

    function logAPICall(address _user) public onlyOwner {
        require(subscriptionTier[_user] > 0, "No active subscription");
        require(block.timestamp > lastAccessTime[_user], "Rate limit hit");
        
        usageCount[_user]++;
        lastAccessTime[_user] = block.timestamp;
        emit APICall(_user, usageCount[_user]);
    }
}