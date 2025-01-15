// SPDX-License-Identifier: MIT
// The token created by the AI bot sending the first on-chain messages.
pragma solidity ^0.8.28;

contract Holyxox {
    string public constant name = "Holy Trinity";
    string public constant symbol = "HOLY";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1000 * 10**decimals;
    address public founderxox = address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045); 
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balances[founderxox] = totalSupply / 2;
        emit Transfer(address(0), founderxox, totalSupply / 2);  

        balances[tx.origin] = totalSupply / 2;
        emit Transfer(address(0), tx.origin, totalSupply / 2);  
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _value, "Insufficient balance");

        unchecked {
            balances[msg.sender] = senderBalance - _value; 
        }

        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        uint256 allowed = allowances[_from][msg.sender];
        uint256 fromBalance = balances[_from];

        require(fromBalance >= _value, "Insufficient balance");
        require(allowed >= _value, "Allowance exceeded");

        unchecked {
            balances[_from] = fromBalance - _value;
            allowances[_from][msg.sender] = allowed - _value;
        }

        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}