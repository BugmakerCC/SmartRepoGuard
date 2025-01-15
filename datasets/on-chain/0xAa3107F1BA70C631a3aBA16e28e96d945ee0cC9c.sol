// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Token {
    string public constant name = "NUGGET TRAP";
    string public constant symbol = "NGTG$"; // Updated ticker symbol
    uint8 public constant decimals = 8;
    uint256 public totalSupply;
    uint256 public tokenPriceInUSD = 60; // Price in cents, representing $0.60

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Set the initial supply as 50 during deployment
    constructor() {
        uint256 initialSupply = 50; // Initial supply set to 50
        totalSupply = initialSupply * 10 ** uint256(decimals); // 50 * 10^8 = 5 billion tokens
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

    // Function to calculate token price in USD
    function calculateTokenPrice(uint256 tokenAmount) public view returns (uint256) {
        return (tokenAmount * tokenPriceInUSD) / 100; // returns price in USD (cents to dollars)
    }
}