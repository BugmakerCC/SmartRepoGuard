// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Token {
    string public constant name = "NUGGET TRAP";
    string public constant symbol = "NGTG$$"; // Updated ticker symbol
    uint8 public constant decimals = 2; // Decimal places set to 2
    uint256 public totalSupply;
    uint256 public tokenPriceInCents = 60; // Price in cents, representing $0.60

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Set the initial supply as 5 billion during deployment
    constructor() {
        uint256 initialSupply = 5000000000; // 5 billion tokens
        totalSupply = initialSupply * 10 ** uint256(decimals); // Adjusting for 2 decimal places: 5,000,000,000 * 10^2
        balanceOf[msg.sender] = totalSupply; // Assign total supply to contract creator
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    // Function to send Ether to an address
    function sendEther(address payable _to) public payable {
        require(msg.value > 0, "Must send some ether");
        _to.transfer(msg.value);
    }

    // Function to calculate token price in USD based on price in cents
    function calculateTokenPrice(uint256 tokenAmount) public view returns (uint256) {
        return (tokenAmount * tokenPriceInCents) / 100; // Returns price in USD (cents to dollars)
    }
}