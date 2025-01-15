//SPDX-License-Identifier: MIT



pragma solidity ^0.8.25;

interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint tokens
    ) external returns (bool success);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function approve(
        address spender,
        uint tokens
    ) external returns (bool success);

    function allowance(
        address tokenOwner,
        address spender
    ) external view returns (uint remaining);

    function totalSupply() external view returns (uint);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint tokens
    );
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}

contract KermitStake is Owned {
    using SafeMath for uint;
    address public Kermit;
    address public Kermit_REWARD;

    uint public feeOnUnstake;
    uint public feeOnStake;
    uint public minimumStake;
    uint public totalStaked;
    bool public active = true;

    mapping(address => uint) public referralCount;
    mapping(address => uint) public referralRewards;
    mapping(address => uint) public stakes;
    mapping(address => uint) public stakeRewards;
    mapping(address => uint) private lastClock;

    event OnWithdrawal(address sender, uint amount);
    event OnStake(address sender, uint amount, uint tax);
    event OnUnstake(address sender, uint amount, uint tax);

    constructor(
        address _Kermit,
        address _Kermit_reward,
        uint _feeOnStake,
        uint _feeOnUnstake,
        uint _minimumStake
    ) {
        Kermit = _Kermit;
        Kermit_REWARD = _Kermit_reward;
        feeOnStake = _feeOnStake;
        feeOnUnstake = _feeOnUnstake;
        minimumStake = _minimumStake;
    }

    modifier whenActive() {
        require(active == true, "Staking yet to open");
        _;
    }

    function calculateRewards(address _stakeholder) public view returns (uint) {
        uint activeDays = (block.timestamp.sub(lastClock[_stakeholder])).div(
            86400
        );
        uint KermitRewardBalance = IERC20(Kermit_REWARD).balanceOf(address(this));
        uint rewards = 0;
        uint stakeAmount = stakes[_stakeholder].div(10 ** 18);

        if (stakeAmount >= 100000) {
            rewards = KermitRewardBalance.mul(5).mul(activeDays).mul(50).div(100000);
        } else if (stakeAmount >= 30000) {
            rewards = KermitRewardBalance.mul(5).mul(activeDays).mul(15).div(100000);
        } else if (stakeAmount >= 5000) {
            rewards = KermitRewardBalance.mul(5).mul(activeDays).mul(5).div(100000);
        } else if (stakeAmount >= 500) {
            rewards = KermitRewardBalance.mul(5).mul(activeDays).mul(1).div(100000);
        }

        return rewards;
    }

    function addToStake(uint _amount) external {
        require(_amount >= minimumStake, "Check minimum stake");
        require(
            IERC20(Kermit).balanceOf(msg.sender) >= _amount,
            "Insufficient Kermit Balance"
        );
        require(
            IERC20(Kermit).transferFrom(msg.sender, address(this), _amount),
            "Staking Failed"
        );

        uint stakingTax = (feeOnStake.mul(_amount)).div(1000);
        uint afterTax = _amount.sub(stakingTax);

        totalStaked = totalStaked.add(afterTax);
        stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(
            calculateRewards(msg.sender)
        );

        uint remainder = (block.timestamp.sub(lastClock[msg.sender])).mod(
            86400
        );
        lastClock[msg.sender] = block.timestamp.sub(remainder);
        stakes[msg.sender] = (stakes[msg.sender]).add(afterTax);

        emit OnStake(msg.sender, afterTax, stakingTax);
    }

    function removeFromStake(uint _amount) external {
        require(_amount <= stakes[msg.sender] && _amount > 0, "Not enough Tokens");

        uint unstakingTax = (feeOnUnstake.mul(_amount)).div(1000);
        uint afterTax = _amount.sub(unstakingTax);

        stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(
            calculateRewards(msg.sender)
        );
        stakes[msg.sender] = (stakes[msg.sender]).sub(_amount);

        uint remainder = (block.timestamp.sub(lastClock[msg.sender])).mod(
            86400
        );
        lastClock[msg.sender] = block.timestamp.sub(remainder);
        totalStaked = totalStaked.sub(_amount);
        IERC20(Kermit).transfer(msg.sender, afterTax);

        emit OnUnstake(msg.sender, _amount, unstakingTax);
    }

    function claimReward() external returns (bool success) {
        uint totalReward = (referralRewards[msg.sender])
            .add(stakeRewards[msg.sender])
            .add(calculateRewards(msg.sender));
        require(
            (block.timestamp - lastClock[msg.sender]) >= 86400,
            "Minimum claim time not reached"
        );
        require(totalReward > 0, "No rewards to claim");
        require(
            IERC20(Kermit_REWARD).balanceOf(address(this)) >= totalReward,
            "Not enough Tokens in Pool"
        );

        stakeRewards[msg.sender] = 0;
        referralRewards[msg.sender] = 0;
        referralCount[msg.sender] = 0;

        uint remainder = (block.timestamp.sub(lastClock[msg.sender])).mod(
            86400
        );
        lastClock[msg.sender] = block.timestamp.sub(remainder);
        IERC20(Kermit_REWARD).transfer(msg.sender, totalReward);

        emit OnWithdrawal(msg.sender, totalReward);
        return true;
    }

    function calculateRewardPool() external view returns (uint) {
        return IERC20(Kermit_REWARD).balanceOf(address(this));
    }

    function changePoolStatus() external onlyOwner {
        if (active) {
            active = false;
        } else {
            active = true;
        }
    }

    function updateFeeOnStake(uint _feeOnStake) external onlyOwner {
        feeOnStake = _feeOnStake;
    }

    function updateFeeOnUnstake(uint _feeOnUnstake) external onlyOwner {
        feeOnUnstake = _feeOnUnstake;
    }

    function updateMinimumStake(uint _minimumStake) external onlyOwner {
        minimumStake = _minimumStake;
    }

    function retrieveKermit(uint _amount) external onlyOwner returns (bool success) {
        require(
            (IERC20(Kermit).balanceOf(address(this))).sub(totalStaked) >= _amount,
            "Not enough Kermit"
        );
        IERC20(Kermit).transfer(msg.sender, _amount);
        emit OnWithdrawal(msg.sender, _amount);
        return true;
    }

    function retrieveKermitReward(uint _amount) external onlyOwner returns (bool success) {
        require(
            IERC20(Kermit_REWARD).balanceOf(address(this)) >= _amount,
            "Not enough Kermit"
        );
        IERC20(Kermit_REWARD).transfer(msg.sender, _amount);
        emit OnWithdrawal(msg.sender, _amount);
        return true;
    }
}