// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoBro {
    mapping(address => uint256) private investments;
    mapping(address => uint256) private lastInvestmentBlock;
    
    uint256 private constant MINIMUM_HOLD_BLOCKS = 5;
    uint256 private constant OWNER_WITHDRAW_DELAY = 3 days;
    uint256 private seed;
    address private owner;
    uint256 private lastOwnerWithdraw;

    event Investment(address investor, uint256 amount);
    event Withdrawal(address investor, uint256 amount);
    event OwnerWithdrawal(uint256 amount);

    constructor() payable {
        seed = uint256(keccak256(abi.encodePacked(block.timestamp)));
        owner = msg.sender;
        lastOwnerWithdraw = block.timestamp;
    }

    function invest() external payable {
        require(msg.value > 0, "Investment must be greater than 0");
        require(investments[msg.sender] == 0, "Have to withdraw before a new investment can start");
        
        investments[msg.sender] += msg.value;
        lastInvestmentBlock[msg.sender] = block.number;
        
        emit Investment(msg.sender, msg.value);
    }

    function withdraw() external {
        require(investments[msg.sender] > 0, "No investment found");
        require(block.number >= lastInvestmentBlock[msg.sender] + MINIMUM_HOLD_BLOCKS, "Minimum hold period not met");

        uint256 amount = calculateWithdrawalAmount();
        uint256 contractBalance = address(this).balance;
        
        if (amount > contractBalance) {
            amount = contractBalance;
        }

        investments[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function calculateWithdrawalAmount() public view returns (uint256) {
        uint256 blocksPassed = block.number - lastInvestmentBlock[msg.sender];
        uint256 initialInvestmentBlock = lastInvestmentBlock[msg.sender];
        uint256 initialInvestment = investments[msg.sender];

        for (uint256 i = 0; i < blocksPassed; i++) {
            uint256 tempSeed = uint256(keccak256(abi.encodePacked(seed, initialInvestmentBlock + i)));
            int256 change = int256(tempSeed % 21) - 10; // Random number between -10 and 10
            initialInvestment = uint256(int256(initialInvestment) + (int256(initialInvestment) * change / 100));
        }

        return initialInvestment;
    }

    function getInitialInvestmentAmount() external view returns (uint256) {
        return investments[msg.sender];
    }

    function getLastInvestmentBlock() external view returns (uint256) {
        return lastInvestmentBlock[msg.sender];
    }

    function getCurrentWithdrawableAmount() external view returns (uint256) {
        if (investments[msg.sender] == 0 || block.number < lastInvestmentBlock[msg.sender] + MINIMUM_HOLD_BLOCKS) {
            return 0;
        }
        
        uint256 amount = calculateWithdrawalAmount();
        uint256 contractBalance = address(this).balance;
        return amount > contractBalance ? contractBalance : amount;
    }

    function ownerWithdraw() external {
        require(msg.sender == owner, "Only the owner can call this function");
        require(block.timestamp >= lastOwnerWithdraw + OWNER_WITHDRAW_DELAY, "Owner must wait 3 days between withdrawals");

        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");

        lastOwnerWithdraw = block.timestamp;
        payable(owner).transfer(amount);

        emit OwnerWithdrawal(amount);
    }

    receive() external payable {}
}