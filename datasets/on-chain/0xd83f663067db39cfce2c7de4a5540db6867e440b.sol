// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface StinkyManage {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function getStinkyToken() external view returns (uint256);
}

contract StinkyAssetContract {
    address public owner;
    StinkyManage public Manage;
    
    constructor(address _Manage) {
        owner = msg.sender;
        Manage = StinkyManage(_Manage);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function invest() external payable onlyOwner {
        require(msg.value > 0, "Investment must be greater than zero");
        Manage.deposit{ value: msg.value }();
    }

    function divest(uint256 amount) external onlyOwner {
        Manage.withdraw(amount);
    }

    function getManagedStinkyToken() external view returns (uint256) {
        return Manage.getStinkyToken();
    }
}