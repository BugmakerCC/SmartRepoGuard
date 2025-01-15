// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) 
    {
        return payable(msg.sender);
    }
}


interface ChainLink
{
    function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


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


contract Ownable is Context 
{
    
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _addr) 
    {
        address msgSender = _addr;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


struct Contributor {
    uint256 contributionsUSDT;
    uint256 contributionsEth;
    uint256 boughtTokens;
}

struct ContributorInfo {
    address contributorAddress;
    uint256 boughtTokens;
}

contract ImperiumPresale is Context, Ownable 
{

    address[] public contributorsList;
    mapping(address => Contributor) public contributorsData;
    
    uint256 public presaleStartTime = 0;
    uint256 public presaleEndTime = 0;

    uint256 raisedUsdt = 0;
    bool public presaleSuccessful = false;
    bool public stopPresale = true;
    bool private locked;

    modifier noReentrant() {
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

    uint256 public totalTokensAllocated = 0;
    uint256 public totalTokensSold = 0;

    address public tokenAddress =  0x9378d92A057094C85A8E6Db14833582002C31E74;
    address public usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20 public presaleToken; 
    IERC20 public usdtToken; 

    Stage[] public stages;

    struct Stage {
        uint256 tokensPerHunderedUsdt;
        uint256 tokensAllocated;
    }

    ChainLink public chainLink; 
    
    constructor(address _owner) Ownable(_owner)
    {
        usdtToken = IERC20(usdtAddress);
        presaleToken =  IERC20(tokenAddress);
        chainLink = ChainLink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);  
        stages.push(Stage(3333, 31_666_667*10**18));  // Stage 1  :  Price $0.03 per IMP
        stages.push(Stage(2500, 25_000_000*10**18));  // Stage 2  :  Price $0.04 per IMP
        stages.push(Stage(2000, 21_000_000*10**18));  // Stage 3  :  Price $0.05 per IMP
        stages.push(Stage(1666, 18_333_334*10**18));  // Stage 4  :  Price $0.06 per IMP
        stages.push(Stage(1428, 16_428_571*10**18));  // Stage 5  :  Price $0.07 per IMP
        stages.push(Stage(1250, 15_000_000*10**18));  // Stage 6  :  Price $0.08 per IMP
        stages.push(Stage(1111, 13_888_889*10**18));  // Stage 7  :  Price $0.09 per IMP
        stages.push(Stage(1000, 13_500_000*10**18));  // Stage 8  :  Price $0.10 per IMP
        stages.push(Stage(909,  13_181_818*10**18));  // Stage 9  :  Price $0.11 per IMP
        stages.push(Stage(833,  12_500_000*10**18));  // Stage 10 :  Price $0.12 per IMP   
        for(uint256 i=0; i<10; i++) 
        {
            totalTokensAllocated += stages[i].tokensAllocated;
        }                        
    }




    function getStage() public view returns(uint256) 
    {
        
        if(totalTokensSold>=totalTokensAllocated) { return 11; }

        uint256 total = totalTokensAllocated-stages[9].tokensAllocated;
        if(totalTokensSold>total) { return 10; }
        
        total -= stages[8].tokensAllocated;
        if(totalTokensSold>total) { return 9; }

        total -= stages[7].tokensAllocated;
        if(totalTokensSold>total) { return 8; }

        total -= stages[6].tokensAllocated;
        if(totalTokensSold>total) { return 7; }

        total -= stages[5].tokensAllocated;
        if(totalTokensSold>total) { return 6; }

        total -= stages[4].tokensAllocated;
        if(totalTokensSold>total) { return 5; }   

        total -= stages[3].tokensAllocated;
        if(totalTokensSold>total) { return 4; }  

        total -= stages[2].tokensAllocated;
        if(totalTokensSold>total) { return 3; } 

        total -= stages[1].tokensAllocated;
        if(totalTokensSold>total) { return 2; }  

        return 1;

    }


    function setStagesPrice(uint256 stage, uint256 _tokensPerHunderedUsdt) external onlyOwner 
    {
        stages[stage-1].tokensPerHunderedUsdt = _tokensPerHunderedUsdt;
    }    

    function setStagesTokensAllocated(uint256 stage, uint256 _tokensAllocated) external onlyOwner 
    {
        stages[stage-1].tokensAllocated = _tokensAllocated;
    }  

    

    function startPresale(uint256 _hours) external onlyOwner {
        presaleStartTime = block.timestamp;
        presaleEndTime = block.timestamp+(_hours*3600);
        stopPresale = false;
    }



    function extendPresale(uint256 _hours) external onlyOwner {
        presaleEndTime += _hours*3600;
    }


    function assetsBalance() external view returns(uint256 usdtBal, uint256 ethBal) 
    {
        usdtBal = usdtToken.balanceOf(address(this));
        ethBal = address(this).balance;
        return(usdtBal, ethBal);
    }


    function ethPrice() public view returns(uint256) {
        (, int256 price, , ,) = chainLink.latestRoundData();
        uint256 _price = uint256(price);
        return _price;
    }

    function ethToUsd(uint256 ethAmount) public view returns (uint256)  
    {
        uint256 _price = ethPrice();
        return  ethAmount*_price*10**10/1_000_000_000_000_000_000;
    }


    function progress() public view returns(uint256) 
    {
        return (100*totalTokensSold*10**18/totalTokensAllocated);
    } 


    function balancesOf(address _addr) public view returns(uint256, uint256, uint256, uint256) 
    {
        uint256 ethBalance = payable (_addr).balance;
        uint256 usdtBalance = usdtToken.balanceOf(_addr);
        uint256 tokenBalance = presaleToken.balanceOf(_addr);
        uint256 _boughtTokens = contributorsData[_addr].boughtTokens;
        return(ethBalance, usdtBalance, tokenBalance, _boughtTokens);
    }    

    function tokensPerUsdt() public view returns(uint256) 
    {
        uint256 stage = getStage();
        return stages[stage-1].tokensPerHunderedUsdt;
    }


    function usdtToTokens(uint256 usdtAmount) public view returns(uint256) 
    {   
        uint256 buyingTokens = usdtAmount*tokensPerUsdt()/100;
        if(presaleSuccessful) 
        { 
            buyingTokens = 0;
        }
        return buyingTokens;
    }


    function ethToTokens(uint256 ethAmount) public view returns(uint256) 
    {
        uint256 usdtAmount = ethToUsd(ethAmount);
        uint256 buyingTokens = usdtToTokens(usdtAmount);
        return buyingTokens;
    }


    function updatePresaleStatus() internal 
    {
        if(totalTokensSold >= totalTokensAllocated) 
        {
            presaleSuccessful = true;
            stopPresale = true;
        }   
    }



    function genInfo() public view returns(uint256, uint256, uint256, uint256, uint256, uint256) 
    {
        return(progress(), ethPrice(), presaleEndTime, raisedUsdt, getStage(), tokensPerUsdt());
    }



    function setPresale(bool _stopPresale, bool _presaleSuccessful) external  onlyOwner 
    {
        stopPresale = _stopPresale;
        presaleSuccessful = _presaleSuccessful;
    }    



    function checkReq(address _addr) public  
    {
        require(!stopPresale, "Presale has been stopped");
        uint256 stage = getStage();
        require(stage<=10, "Presale is Over");    
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Presale is not active."); 
        if(contributorsData[_addr].boughtTokens==0) 
        { 
            contributorsList.push(_addr); 
            contributorsData[_addr] = Contributor(0,0,0);
        }           
    }

                                                            
    event ContributedUsdt(address buyer, uint256 amountBought, uint256 timestamp);
    function contributeUSDT(uint256 usdtAmount) public noReentrant 
    {
        checkReq(msg.sender);
        contributorsData[msg.sender].contributionsUSDT += usdtAmount;
        raisedUsdt += usdtAmount;
        uint256 tokensAmount = usdtToTokens(usdtAmount);
        require(tokensAmount>0, "Presale is not active");
        contributorsData[msg.sender].boughtTokens += tokensAmount;
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "USDT Deposite failed.");
        totalTokensSold += tokensAmount;
        emit ContributedUsdt(msg.sender, tokensAmount, block.timestamp);
        updatePresaleStatus();
    }


    event ContributedETH(address buyer, uint256 ethAmount, uint256 timestamp);
    function contributeEth() public payable noReentrant 
    {
        checkReq(msg.sender);
        uint256 ethAmount = msg.value;
        contributorsData[msg.sender].contributionsEth = ethAmount;
        raisedUsdt += ethToUsd(ethAmount);
        uint256 tokensAmount = ethToTokens(ethAmount);
        require(tokensAmount>0, "Presale is not active");
        contributorsData[msg.sender].boughtTokens += tokensAmount;
        totalTokensSold += tokensAmount;
        emit ContributedETH(msg.sender, ethAmount, block.timestamp);
        updatePresaleStatus();
    }

    
    function claimTokens() external 
    {
       require(presaleSuccessful, "Presale not yet completed.");
       uint256 tokensAmount = contributorsData[msg.sender].boughtTokens;
       require(presaleToken.transferFrom(owner(), msg.sender, tokensAmount), "Withdrawal failed.");
       contributorsData[msg.sender].boughtTokens = 0;
    }


    // Only owner can call this function
    function widthdrawEth() external onlyOwner 
    {
        payable(owner()).transfer(address(this).balance);
    }

    function widthdrawUSDT() external onlyOwner 
    {
        usdtToken.transfer(owner(), usdtToken.balanceOf(address(this)));
    }    

    function widthdrawTokens() external onlyOwner 
    {
        presaleToken.transfer(owner(), presaleToken.balanceOf(address(this)));
    }

    
    

    // View function to get sorted contributors by boughtTokens
    function getTopFiveContributors() public view returns (ContributorInfo[] memory) {
        uint256 length = contributorsList.length;
        // Create a temporary array to hold ContributorInfo (address and boughtTokens)
        ContributorInfo[] memory tempContributors = new ContributorInfo[](length);

        // Populate the temporary array with data from the contributorsData mapping
        for (uint256 i = 0; i < length; i++) {
            address contributor = contributorsList[i];
            tempContributors[i] = ContributorInfo(contributor, contributorsData[contributor].boughtTokens);
        }

        // Sort the tempContributors array by boughtTokens using Bubble Sort
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = 0; j < length - 1; j++) {
                if (tempContributors[j].boughtTokens < tempContributors[j + 1].boughtTokens) {
                    // Swap if the next element has more boughtTokens
                    ContributorInfo memory temp = tempContributors[j];
                    tempContributors[j] = tempContributors[j + 1];
                    tempContributors[j + 1] = temp;
                }
            }
        }

        ContributorInfo[] memory tempContributors1 = new ContributorInfo[](5);
        uint256 max = 5;
        if(length<max) { max = length; }
        for(uint256 i=0; i<max; i++) 
        {
            tempContributors1[i] = tempContributors[i];
        }
        return tempContributors1;
    }    

}