// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//import "hardhat/console.sol";

/*
Smart CEO 1.0

This contract's job is to take over the CEO and decrease the issuance.

It receives CIG as a stipend from the liquidity mining rewards earned by the locker.

*/

contract SmartCEO {

    ICigToken immutable public cig;
    ILock immutable public locker;
    uint256 constant punkIndex = 2317;
    uint256 constant MIN_EPOCHS = 7200 * 40; // once we take CEO, we should have enough for at least this many
    bytes32 graffiti = bytes32("SmartCEO 1.0") ;

    constructor (
        address _cig,   // 0xCB56b52316041A62B6b5D0583DcE4A8AE7a3C629
        address _locker // 0xaeD1117F9C01672646964d093643F8974Bb752B4
    ) {
        cig = ICigToken(_cig);
        cig.approve(address(this), type(uint256).max);
        locker = ILock(_locker);
    }

    /**
    * Take the CEO if not CEO. The new takeover price will be 0.42069% of total supply.
    * Tax deposit required: A minimum of "MIN_EPOCHS"
    * If already CEO, decrease the issuance, burn tax & adjust the price if necessary
    */
    function execute() external {
        locker.harvest();                      // get our pay
        if (cig.The_CEO() != address(this)) {
            // take over and reward caller
            uint256 price = cig.CEO_price();
            uint256 cpd = getCpd();
            uint256 newPrice = cig.totalSupply()
                / 10000000 * 42069;            // 0.42069% of total supply (0.0042069);
            newPrice = newPrice / 1e18 * 1e18; // round
            uint256 bal = cig.balanceOf(address(this));
            uint256 deposit = (newPrice / 1000 / 7200)
                * MIN_EPOCHS;                  // how much tax to deposit, min amount
            require (bal >= price + deposit, "cig deficiency");
            uint256 totalSpend = price + deposit;
            if (bal > totalSpend) {
                deposit = bal - totalSpend;    // add remainder balance to deposit
                totalSpend = price + deposit;
            }
            cig.buyCEO(
                totalSpend,
                newPrice,
                deposit,
                punkIndex,
                graffiti
            );
            cig.transfer(msg.sender, cpd); //reward caller
        } else {
            // we are CEO
            uint256 cpd = getCpd();                             // cpd = cig per day
            cig.depositTax(cig.balanceOf(address(this)) - cpd);
            cig.rewardDown();                                   // decrease the reward
            // we just decreased the reward, so decrease the tax
            // estimate a new tax per block we can afford, based on stipend
            if (cig.CEO_tax_balance() < cpd * 10) {             // less than 10 days remaining?
                cig.setPrice(cpd * 9);
            } else {
                cig.burnTax();
            }
            cig.transfer(msg.sender, cpd);                      // reward caller
        }
    }
    /**
    * getCpd gets estimated cig per day that we will earn at current CIG issuance rate
    */
    function getCpd() public view returns (uint256) {
        uint256 supply = cig.stakedlpSupply();
        ICigToken.UserInfo memory info = cig.farmers(address(locker));
        uint256 cpd = info.deposit  * 1e12
            / supply * ( cig.cigPerBlock() * 7200)
            / 1e12 ; // cig per day
        return cpd;
    }

    /**
    * In case of emergency break glass
    */
    function emergency() external {
        require (msg.sender == address(0xc43473fA66237e9AF3B2d886Ee1205b81B14b2C8), "not tycoon");
        cig.transfer(msg.sender, cig.balanceOf(address(this)));
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ICigToken is IERC20 {
    struct UserInfo {
        uint256 deposit;    // How many LP tokens the user has deposited.
        uint256 rewardDebt; // keeps track of how much reward was paid out
    }
    function farmers(address _user) external view returns (UserInfo memory);
    function cigPerBlock() external view returns (uint256);
    function CEO_price() external view returns (uint256);
    function CEO_tax_balance() external view returns (uint256);
    function The_CEO() external view returns(address);
    function rewardsChangedBlock() external view returns (uint256);
    function rewardUp() external returns (uint256);
    function rewardDown() external returns (uint256);
    function depositTax(uint256 _amount) external;
    function buyCEO(
        uint256 max_spend,
        uint256 new_price,
        uint256 tax_amount,
        uint256 punk_index,
        bytes32 graffiti
    ) external;
    function stakedlpSupply() external view returns(uint256);
    function setPrice(uint256 _price) external;
    function burnTax() external;

}

interface ILock {
    function harvest() external;
    function getStats(address _user) view external returns(uint256[] memory);
    struct Stipend {
        address to;    // where to send harvested CIG rewards to
        uint256 amount;// max CIG that will be sent
        uint256 period;// how many blocks required between calls
        uint256 block; // record of last block number when called
    }
    function stipend(address _addr) view external returns(Stipend memory);
}