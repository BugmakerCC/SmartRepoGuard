// SPDX-License-Identifier: MIT
// Twitter: https://twitter.com/fairprotocolxyz
// Telegram: https://t.me/fairprotocolxyz
// Website: https://fairprotocol.xyz/

pragma solidity ^0.8.28;
contract fairPlatform {
    string public name;
    string public symbol;
    string public twitter;
    string public telegram;
    string public website;
    uint8 public decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * (10 ** uint256(decimals));
    uint256 public supply = 0;
    mapping(address => bool) public hasMinted;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, string memory _twitter, string memory _telegram, string memory _website) {
        name = _name;
        symbol = _symbol;
        twitter = _twitter;
        telegram = _telegram;
        website = _website;
        supply += totalSupply / 1000;
        balances[tx.origin] = totalSupply / 1000;
        emit Transfer(address(0), tx.origin, totalSupply / 1000);
    }
    function getTokenInfo() public view returns (
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint256
    ) {
        return (name, symbol, twitter, telegram, website, supply);
    }
    function mint() external{
        require(supply + (totalSupply / 1000) <= totalSupply, "Total supply exceeded");
        require(!hasMinted[msg.sender], "Address has already minted");
        require(msg.sender == tx.origin, "Contracts are not allowed to mint");
        hasMinted[msg.sender] = true;

        supply += totalSupply / 1000;
        balances[msg.sender] += totalSupply / 1000;
        emit Transfer(address(0), msg.sender, totalSupply / 1000);
    }
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");

        allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Transfer to the zero address");

        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }
}

contract ERC20Deployer {
    uint256 public count = 0;
    mapping(uint256 => address) public fairs;
    event TokenDeployed(address indexed tokenAddress, string name, string symbol);

    function deployToken(string memory _name, string memory _symbol, string memory _twitter, string memory _telegram, string memory _website) public {
        fairPlatform token = new fairPlatform(_name, _symbol, _twitter, _telegram, _website); 
        ++count;
        fairs[count] = address(token);
        emit TokenDeployed(address(token), _name, _symbol); 
    }
}