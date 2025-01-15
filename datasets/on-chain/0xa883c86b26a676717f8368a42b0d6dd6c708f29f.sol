// SPDX-License-Identifier: MIT

//Pusheen  Cat  on  Ethereum
//TG ; https://t.me/PusheenOnETH 
//Website ; https://www.pusheencateth.xyz/
//Twitter ; https://x.com/PusheenOnETH
pragma solidity ^0.8.0;

contract Pusheen {
    string public name = "Pusheen";
    string public symbol = "PUSH";
    uint8 public decimals = 18;
    uint256 public totalSupply = 420690000000000 * (10 ** uint256(decimals));

    address public owner;
    uint256 public initialBuyTaxFee = 0;  // Initial Buy Tax 6%
    uint256 public initialSellTaxFee = 0; // Initial Sell Tax 6%
    uint256 public ethCollected = 0;  // Track ETH collected in liquidity
    uint256 public volumeThreshold = 0 ether;  // Volume threshold of 5 ETH
    uint256 public bigBuyThreshold = 0 ether;  // Big buy threshold of 0.5 ETH
    bool public liquidityAdded = false;  // Track if liquidity is added
    bool public ownershipRenounced = false;  // Track if ownership has been renounced

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isTaxExempt;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipRenounced();

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    // Transfer tokens with dynamic buy/sell tax based on collected ETH volume
    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        uint256 tax = (value * getCurrentTax()) / 100;
        uint256 amountToTransfer = value - tax;

        balanceOf[msg.sender] -= value;
        balanceOf[to] += amountToTransfer;
        balanceOf[owner] += tax;  // Send tax to contract owner

        emit Transfer(msg.sender, to, amountToTransfer);

        // Check for big buy and reduce tax if necessary
        if (ethCollected >= volumeThreshold && value >= bigBuyThreshold) {
            reduceTaxOnBigBuy();
        }

        return true;
    }

    // Approve spender to transfer on behalf of the user
    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Transfer tokens on behalf of another user (using allowance)
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");

        uint256 tax = (value * getCurrentTax()) / 100;
        uint256 amountToTransfer = value - tax;

        balanceOf[from] -= value;
        balanceOf[to] += amountToTransfer;
        balanceOf[owner] += tax;  // Send tax to contract owner

        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, amountToTransfer);

        // Check for big buy and reduce tax if necessary
        if (ethCollected >= volumeThreshold && value >= bigBuyThreshold) {
            reduceTaxOnBigBuy();
        }

        return true;
    }

    // Reduce the tax by 1% on every big buy
    function reduceTaxOnBigBuy() internal {
        if (initialBuyTaxFee > 0) {
            initialBuyTaxFee -= 0; // Reduce buy tax by 1%
        }
        if (initialSellTaxFee > 0) {
            initialSellTaxFee -= 0; // Reduce sell tax by 1%
        }
    }

    // Automatically renounce ownership after volume threshold is reached
    function autoRenounceOwnership() internal {
        require(!ownershipRenounced, "Ownership already renounced");

        // Renounce ownership
        ownershipRenounced = true;
        owner = address(0);

        emit OwnershipRenounced();
    }

    // Track ETH received and update total collected ETH
    receive() external payable {
        ethCollected += msg.value;

        // Check if liquidity has been added
        if (liquidityAdded && ethCollected >= volumeThreshold) {
            autoRenounceOwnership();
        }
    }

    // Get the current tax rate based on collected ETH volume
    function getCurrentTax() public view returns (uint256) {
        if (isTaxExempt[msg.sender]) {
            return 0;  // No tax for exempt addresses
        }

        // If below the volume threshold, apply full tax
        if (ethCollected < volumeThreshold) {
            return initialBuyTaxFee;  // Apply full tax (6%)
        }

        // After unclogging, apply the dynamic buy/sell tax based on big buys
        return initialBuyTaxFee; // Use the dynamic buy tax fee
    }

    // Set liquidity added flag (to trigger auto renouncement)
    function setLiquidityAdded() external onlyOwner {
        liquidityAdded = true;
    }

    // Exempt certain addresses from tax (optional, can be removed if not needed)
    function setTaxExempt(address account, bool exempt) external onlyOwner {
        isTaxExempt[account] = exempt;
    }
}