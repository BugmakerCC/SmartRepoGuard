/**
https://kek.finance
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract KEKFinanceStaking {
    string public name = "KEK Finance Staking";
    address public owner;
    
    struct Staker {
        uint256 amount; // Amount of tokens staked
        uint256 rewardDebt; // Accumulated reward debt
        uint256 stakeTime; // Timestamp of staking
    }
    
    mapping(address => Staker) public stakers;
    uint256 public totalStaked;
    uint256 public rewardRate = 420; // Annual reward rate (percentage)

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Stake function: user stakes a certain amount of tokens
    function stake() public payable {
        require(msg.value > 0, "Cannot stake 0");

        if (stakers[msg.sender].amount > 0) {
            uint256 pendingReward = calculateReward(msg.sender);
            stakers[msg.sender].rewardDebt += pendingReward;
        }

        stakers[msg.sender].amount += msg.value;
        stakers[msg.sender].stakeTime = block.timestamp;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    // Withdraw function: user withdraws staked tokens along with pending rewards
    function withdraw(uint256 _amount) public {
        require(stakers[msg.sender].amount >= _amount, "Insufficient staked amount");

        uint256 pendingReward = calculateReward(msg.sender);
        uint256 totalReward = pendingReward + stakers[msg.sender].rewardDebt;

        stakers[msg.sender].amount -= _amount;
        totalStaked -= _amount;

        payable(msg.sender).transfer(_amount);
        if (totalReward > 0) {
            payable(msg.sender).transfer(totalReward);
            stakers[msg.sender].rewardDebt = 0;

            emit RewardClaimed(msg.sender, totalReward);
        }

        emit Withdrawn(msg.sender, _amount);
    }

    // Claim accumulated rewards without withdrawing the stake
    function reward() public {
        uint256 pendingReward = calculateReward(msg.sender);
        uint256 totalReward = pendingReward + stakers[msg.sender].rewardDebt;

        require(totalReward > 0, "No rewards available");

        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].stakeTime = block.timestamp;

        payable(msg.sender).transfer(totalReward);

        emit RewardClaimed(msg.sender, totalReward);
    }

    // Calculate pending reward based on staked amount and time
    function calculateReward(address _staker) public view returns (uint256) {
        Staker memory staker = stakers[_staker];
        if (staker.amount == 0) {
            return 0;
        }

        uint256 stakingDuration = block.timestamp - staker.stakeTime; // Duration in seconds
        uint256 annualReward = (staker.amount * rewardRate) / 100; // Annual reward
        uint256 reward = (annualReward * stakingDuration) / 365 days; // Proportional reward

        return reward;
    }

    // Allow contract owner to update the reward rate
    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
    }

    // Allow contract owner to withdraw contract's balance (for admin)
    function withdrawContractBalance(uint256 _amount) public onlyOwner {
        payable(owner).transfer(_amount);
    }

    // Fallback function to accept ETH
    receive() external payable {}

}