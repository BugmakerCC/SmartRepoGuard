/**
 *Submitted for verification at Etherscan.io on 2024-10-08
*/

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.20;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

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

abstract contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mainnet
     * Aggregator: ETH/USD
     * Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
     */

    /**
     * Network: Sepolia
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    /**
     * Network: BSC Mainnet
     * Aggregator: ETH/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    /**
     * Network: BSC Testnet
     * Aggregator: BNB/USD
     * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */
    constructor() {
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract ETHReceiver is PriceConsumerV3{

    IERC20 public usdt;

    uint256 public tokenPrice = 1 * 10 ** 16;//0.01 USD
    address owner;


    uint public bronze = 1000; //in usd
    uint public silver = 5000;
    uint public gold = 10000;
    uint public platinum = 25000;
    uint public diamond = 100000;

    uint8 public bronzePct = 1;
    uint8 public silverPct = 3;
    uint8 public goldPct = 6;
    uint8 public platinumPct = 8;
    uint8 public diamondPct = 10;

    uint256 public tge;


    struct User {
        address user;
        uint256 amountFunded;
        uint256 amountDue;
        uint256 refCode;
    }

    User [] public users; 

    modifier onlyOwner(){
        require(msg.sender == owner, "not authorized");
        _;
    }

    event BuyTokens(address indexed user, uint amount);
    event BuyTokensWithUSDT(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event USDTWithdrawal(address indexed user, uint amount);


    constructor(address _usdt, uint256 _tge){
        owner = msg.sender;
        usdt = IERC20(_usdt);
        tge = _tge;
    }

    function getUsers() public view returns (User[] memory ){
        return users;
    }

    function payWithETH(uint256 _refCode) external payable {
        require(msg.value > 0, "cannot send zero amount");
         // Get the latest BNB/USD price
        uint256 ethPriceInUSD = getRoundedETHPrice(); // 18 decimals

        // Convert BNB received (msg.value) to USD. BNB has 18 decimals, price has 8 decimals, so we scale up.
        uint256 ethAmountInUSD = (msg.value * ethPriceInUSD) / 10**18;

        // Now calculate how many tokens the user gets based on the token price in USD (18 decimals)
        uint256 tokensToBuy = ethAmountInUSD  / tokenPrice;

         tokensToBuy = processTiers(tokensToBuy);


        users.push(User({
            user: msg.sender,
            amountFunded: ethAmountInUSD / 10 ** 18, 
            amountDue: tokensToBuy,
            refCode: _refCode
            }));

            emit BuyTokens(msg.sender, tokensToBuy);
    }

    function payWithUSDT(uint _amount, uint _refCode) external {
        require(_amount * 10 ** 18 >= tokenPrice, "Insufficient amount sent");


         uint256 tokensToBuy = (_amount * 10**18) / tokenPrice;

         tokensToBuy = processTiers(tokensToBuy);


         users.push(User({
            user: msg.sender,
            amountFunded: _amount,
            amountDue: tokensToBuy,
            refCode: _refCode
         }));

         require(usdt.transferFrom(msg.sender, address(this), _amount * 10 ** 6), "Transfer failed");

         emit BuyTokensWithUSDT(msg.sender, tokensToBuy);


    }

    function getRoundedETHPrice() public view returns (uint256) {
        uint256 rawPrice = uint256(getLatestPrice());
        uint256 ethPrice = rawPrice / 10**8;
        return ethPrice * 10**18;
    }


    function getTotalETH() public view returns (uint256){
        uint256 total;
        for(uint8 i = 0; i < users.length; i++){
            total += users[i].amountFunded;
        }
        return total;
    }

    function processTiers(uint256 _amount) public view returns (uint256) {
        uint256 amount = _amount;

         if(amount   >= bronze && amount  < silver){
            amount = (amount * bronzePct / 100) + amount;
        }
        else if(amount  >= silver && amount  < gold){
            amount = (amount * silverPct / 100) + amount;
        }
        else if(amount  >= gold && amount  < platinum){
            amount = (amount * goldPct / 100) + amount;
        }
        else if(amount  >= platinum && amount  < diamond){
            amount = (amount * platinumPct / 100) + amount;
        }
        else if(amount  >= diamond){
            amount = (amount * diamondPct / 100) + amount;
        }

        return amount;
    }

    



    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        tokenPrice = _newPrice;
    }


    function setTiers(
        uint256 _bronze,
        uint256 _silver,
        uint256 _gold,
        uint256 _platinum,
        uint256 _diamond,
        uint8 _bronzePct,
        uint8 _silverPct,
        uint8 _goldPct,
        uint8 _platinumPct,
        uint8 _diamondPct
    ) external onlyOwner {
        require(_bronzePct < 100 && _silverPct < 100 && _goldPct < 100 && _platinumPct < 100 && _diamondPct < 100, "Percentage cannot be greater than 100");
        bronze = _bronze;
        silver = _silver;
        gold = _gold;
        platinum = _platinum;
        diamond = _diamond;
        bronzePct = _bronzePct;
        silverPct = _silverPct;
        goldPct = _goldPct;
        platinumPct = _platinumPct;
        diamondPct = _diamondPct;
    }


      function withdraw() external onlyOwner {
        require(
            block.timestamp > tge,
            "Cannot withdraw funds until after the TGE"
        );
        uint balance = address(this).balance;
        // This will payout the owner the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner).call{value: balance}("");
        require(os);
        // =============================================================================

        emit Withdrawal(msg.sender, balance);
    }

    function withdrawUSDT() external onlyOwner {
         require(
            block.timestamp > tge,
            "Cannot withdraw funds until after the TGE"
        );
        uint balance = usdt.balanceOf(address(this));

        usdt.transfer(owner, balance);

        emit USDTWithdrawal(msg.sender, balance);

    }




}