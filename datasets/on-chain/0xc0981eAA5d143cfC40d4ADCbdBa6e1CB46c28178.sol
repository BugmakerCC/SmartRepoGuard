// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) 
    {
        return payable(msg.sender);
    }
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


contract LEEACPresale is Context, Ownable 
{
    mapping(address => uint256) public contributionsUSDT;
    mapping(address => uint256) public contributionsEth;
    mapping(address => uint256) public boughtTokens;
    address[] public contributers;
    
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;

    bool public presaleSuccessful = false;
    bool private locked;

    modifier noReentrant() {
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }


    uint256 public totalTokensSold;
    uint256 public tokensAllocatedForPresale = 5_000_000_000_000_000 * 10**18;
    uint256 public tokensPerThousandUsdt = 10000;

    address public presaleTokenAddress  =   0x0324dee62cfc74Aa1406C91297606156f6f9a5DF; 
    address public usdtAddress          =   0xdAC17F958D2ee523a2206206994597C13D831ec7; 

    IERC20 public presaleToken; 
    IERC20 public usdtToken; 

    ChainLink public chainLink; 

    uint256 usdtCollected = 0;
    uint256 ethCollected = 0;    
    
    constructor(address _owner) Ownable(_owner)
    {
        usdtToken = IERC20(usdtAddress);
        presaleToken =  IERC20(presaleTokenAddress);
        chainLink = ChainLink(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);     // Chainlink POL-> USDT Address
    }


    function extendPresale(uint256 _hours) external onlyOwner 
    {
        presaleEndTime += _hours*3600;
        presaleSuccessful = false;        
    }


    function startPresale(uint256 _timeInHours) external  onlyOwner 
    {
        presaleStartTime = block.timestamp;
        presaleEndTime = block.timestamp+(_timeInHours*3600);
        presaleSuccessful = false;
    }



    function assetsBalance() external view returns(uint256 usdtBal, uint256 ethBal) 
    {
        usdtBal = usdtToken.balanceOf(address(this));
        ethBal = address(this).balance;
        return(usdtBal, ethBal);
    }



    function polPrice() public view returns(uint256) {
        (, int256 price, , ,) = chainLink.latestRoundData();
        uint256 _price = uint256(price);
        return _price;
    }
    


    function progress() public view returns(uint256) 
    {
        return (100*totalTokensSold * 10**18 / tokensAllocatedForPresale);
    } 


    function balancesOf(address _addr) public view returns(uint256, uint256, uint256, uint256) 
    {
        uint256 ethBalance = payable(_addr).balance;
        uint256 usdtBalance = usdtToken.balanceOf(_addr);
        uint256 tokenBalance = presaleToken.balanceOf(_addr);
        uint256 _boughtTokens = boughtTokens[_addr];
        return(ethBalance, usdtBalance, tokenBalance, _boughtTokens);
    }    
    

    function ethToUsd(uint256 ethAmount) public view returns (uint256)  
    {
        uint256 _price = polPrice();
        return  ethAmount*_price*10**10/1_000_000_000_000_000_000;
    }


    function genInfo() public view returns(uint256, uint256, uint256, uint256)  
    {
        uint256 _progress = progress();
        uint256 _ethPrice = ethToUsd(1 ether);
        uint256 usdRaised = raisedUsdt();
        return(_progress, _ethPrice, presaleEndTime, usdRaised);
    }


    function usdtToTokens(uint256 usdtAmount) public view returns(uint256) 
    {   
        uint256 buyingTokens = (usdtAmount*tokensPerThousandUsdt)/1000;
        if(totalTokensSold+buyingTokens > tokensAllocatedForPresale) 
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


    function updatetokensPerThousandUsdt(uint256 __tokensPerThousandUsdt) public onlyOwner 
    {
        tokensPerThousandUsdt = __tokensPerThousandUsdt;
    }


    function updatePresaleStatus() internal 
    {
        if(totalTokensSold >= tokensAllocatedForPresale) 
        {
            presaleSuccessful = true;            
        }   
    }


    function setPresale(bool _presaleSuccessful) external  onlyOwner 
    {
        presaleSuccessful = _presaleSuccessful;
    }    



    function raisedUsdt() public view returns(uint256) 
    {
        return usdtCollected+ethToUsd(ethCollected);
    }


    function checkReq(address contributor) internal  
    {
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Presale is not active.");    
        if(boughtTokens[contributor]==0) 
        { 
            contributers.push(contributor); 
        }    
    }


    event ContributedUsdt(address buyer, uint256 amountBought, uint256 timestamp);
    function contributeUSDT(uint256 usdtAmount) public noReentrant  
    {
        checkReq(msg.sender);       
        usdtCollected += usdtAmount;
        contributionsUSDT[msg.sender] = usdtAmount;
        require(usdtAmount>0, "Zero contribution is invalid");
        uint256 buyingTokens = usdtToTokens(usdtAmount);
        require(buyingTokens>0, "Zero is not a valid amount");
        boughtTokens[msg.sender] += buyingTokens;
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "USDT failed to deposite.");
        require(presaleToken.transfer(msg.sender, buyingTokens), "Token Transfer failed.");
        totalTokensSold += buyingTokens;        
        emit ContributedUsdt(msg.sender, buyingTokens, block.timestamp);
        updatePresaleStatus();
    }
    

    event ContributedETH(address buyer, uint256 ethAmount, uint256 timestamp);
    function contributeEth() public payable noReentrant 
    {
        checkReq(msg.sender);       
        uint256 ethAmount = msg.value;
        ethCollected += ethAmount;
        require(ethAmount>0, "Zero contribution is invalid");
        contributionsEth[msg.sender] = ethAmount;
        uint256 buyingTokens = ethToTokens(ethAmount);
        require(buyingTokens>0, "Presale is not active");
        boughtTokens[msg.sender] += buyingTokens;
        require(presaleToken.transfer(msg.sender, buyingTokens), "Token Transfer failed.");
        totalTokensSold += buyingTokens;  
        emit ContributedETH(msg.sender, ethAmount, block.timestamp);
        updatePresaleStatus();
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

    function widthdrawPresaleTokens() external onlyOwner 
    {
        presaleToken.transfer(owner(), presaleToken.balanceOf(address(this)));
    }


    receive() external payable { }


}