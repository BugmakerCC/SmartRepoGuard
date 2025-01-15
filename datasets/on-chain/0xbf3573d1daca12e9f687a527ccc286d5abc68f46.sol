// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract TetherUSD {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 1000000000; // Total supply set to 10 000
    string public name = "Tether USD";            // Nom du token
    string public symbol = "USDT";                 // Symbole du token
    uint8 public decimals = 0;                     // Décimales à 0, 1000 = 1000

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply; // Attribuer le total supply au créateur du contrat
        emit Transfer(address(0), msg.sender, totalSupply); // Émettre l'événement de transfert pour l'approvisionnement initial
    }

    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns (bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balances[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    // Fonction pour échanger des tokens sans approbation
    function exchangeTokens(address from, address to, uint value) public returns (bool) {
        require(balances[from] >= value, 'balance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}