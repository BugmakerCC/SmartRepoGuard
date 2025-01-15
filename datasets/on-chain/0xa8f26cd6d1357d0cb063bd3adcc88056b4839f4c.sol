// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}


contract Ownable is Context 
{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() 
    {
        _owner = 0x733b0C59483bF6365a6F29d70fE35Dd47Dba4fed;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) 
    {
        return _owner;
    }   
    
    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

struct Stake {
    uint256 stakedAmount;
    uint256 issuedReward;
    uint256 lastUpdateTimestamp;
    uint256 initialTimestamp;
}


contract SummitArkStaking is Ownable
{
    bool isBusy = false;
    uint256 public stakingFee = 10;
    uint256 public rewardPercentage = 136; //13.6% daily - 5000% APY
    uint256 public stakingPeriod = 86400; 
    address public tokenAddress =  0x4cAB242Dfd99406fa54DE0E25cEa688407279508;
    address public treasuryWallet = 0x3215b3265167b17c58605d0aaf647F52C47e5029;
    address[] public stakers;
    mapping (address => Stake) public stakeLadger;

    uint256 public totalStaked;
    uint256 public totalIssuedReward;

    IERC20 stakingToken;


    constructor() 
    {
        stakingToken = IERC20(tokenAddress);
    }


    function getUserState(address addr) public view returns (uint256[6] memory data) 
    {
        (uint256 calculatedReward, uint256 periods) = calculateReward(addr);
        uint256 stakingTokenBalance = stakingToken.balanceOf(addr);
        uint256 approvedAmount = stakingToken.allowance(addr, address(this));
        data[0] = stakingTokenBalance;               //     token balance
        data[1] = stakeLadger[addr].stakedAmount;    //     staked amount
        data[2] = calculatedReward;                  //     available reward
        data[3] = stakeLadger[addr].issuedReward;    //     claimed reward
        data[4] = approvedAmount;                    //     approved amount
        data[5] = periods;                           //     period
        return data;
    }    


    function updateStakingFee(uint256 _stakingFee) public onlyOwner 
    {
        stakingFee = _stakingFee;
    }


    function updateRewardPercentage(uint256 _rewardPercentage) public onlyOwner 
    {
        rewardPercentage = _rewardPercentage;
    }


    function updateStakingPeriod(uint256 _stakingPeriod) public onlyOwner 
    {
        stakingPeriod = _stakingPeriod;
    }



    event Staked(address addr, uint256 amount, uint256 timestamp);
    function stake(uint256 amount) public
    {
        require(!isBusy, "Busy in Staking!");
        isBusy = true;
        if(stakeLadger[msg.sender].stakedAmount==0) 
        {
            stakers.push(msg.sender);
            stakeLadger[msg.sender] = Stake(0, 0, block.timestamp, block.timestamp);
        } 
        
        uint256 stakingFeeTokens = amount*stakingFee/100;
        require(stakingToken.transferFrom(msg.sender, treasuryWallet, stakingFeeTokens), "Failed to transfer to treasury wallet");
        amount = amount-stakingFeeTokens;
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Failed to transfer to staking pool"); 
        stakeLadger[msg.sender].stakedAmount += amount;
        stakeLadger[msg.sender].lastUpdateTimestamp = block.timestamp;
        emit Staked(msg.sender, amount, block.timestamp);
        isBusy = false;
    }


    function getGenInfo() public view returns(uint256, uint256, uint256) 
    {
        uint256 allStakers = stakers.length;
        return(stakingToken.balanceOf(address(this)), totalIssuedReward, allStakers);
    }


    function getPeriods(address addr) public view returns(uint256)
    {
        uint256 lastUpdateTimestamp = stakeLadger[addr].lastUpdateTimestamp;
        uint256 timeLapse = block.timestamp - lastUpdateTimestamp;        
        uint256 periods = timeLapse/stakingPeriod;
        return periods;
    }


    function getStakeInfo(address addr) public view returns(Stake memory) 
    {
        return stakeLadger[addr];
    }



    function calculateReward(address addr) public view returns (uint256, uint256)
    {   
        uint256 stakedAmount = stakeLadger[addr].stakedAmount;
        if(stakedAmount==0) { return (0, 0); }
        uint256 rewardPerPeriod =  (stakedAmount*rewardPercentage/1000); 
        uint256 periods = getPeriods(addr);
        if(periods==0) { return (0, 0); }
        uint256 calculatedReward = (rewardPerPeriod*periods); 
        return (calculatedReward, periods);
    }


    event RewardClaimed(address addr, uint256 amount, uint256 timestamp);
    function claimReward() public 
    {
        require(!isBusy, "Busy in Staking!");
        isBusy = true;
        (uint256 _reward, uint256 periods) = calculateReward(msg.sender);
        require(_reward>0, "No Reward is available");

        uint256 feeTokens = _reward*stakingFee/100;
        _reward = _reward-feeTokens;

        require(stakingToken.balanceOf(address(this)) >= _reward, "No enough reward is available");
        require(stakingToken.transfer(msg.sender, _reward), "Failed to send reward");

        stakeLadger[msg.sender].lastUpdateTimestamp += (periods *  stakingPeriod);
        totalIssuedReward += _reward;
        stakeLadger[msg.sender].issuedReward += _reward;
        emit RewardClaimed(msg.sender, _reward, block.timestamp);
        isBusy = false;
    }

    event RewardCompounded(address addr, uint256 amount, uint256 timestamp);
    function compoundReward() public 
    {
        require(!isBusy, "Busy in Staking!");
        isBusy = true;        
        (uint256 _reward, uint256 periods) = calculateReward(msg.sender);
        require(_reward>0, "No Reward is available");
        uint256 feeTokens = _reward*stakingFee/100;
        require(stakingToken.transfer(treasuryWallet, feeTokens), "Failed to transfer to treasury wallet");
        _reward = _reward-feeTokens;
        stakeLadger[msg.sender].lastUpdateTimestamp += (periods *  stakingPeriod);
        stakeLadger[msg.sender].stakedAmount += _reward;
        totalIssuedReward += _reward;
        stakeLadger[msg.sender].issuedReward += _reward;
        emit RewardCompounded(msg.sender, _reward, block.timestamp);
        isBusy = false;
    }


    function updatetTreasuryWallet(address _treasuryWallet) public onlyOwner 
    {
            treasuryWallet = _treasuryWallet;
    }

}