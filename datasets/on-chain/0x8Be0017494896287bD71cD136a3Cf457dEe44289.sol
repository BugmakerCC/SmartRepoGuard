// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * This is a placeholder contract for our upcoming 100% automated holder rewarding Jackpot Protocol
 * launching on November 8th! Stay tuned for more updates on our official channels:
 * - Twitter / X: https://x.com/FettiOnEth
 * - Telegram: https://t.me/FettiOnEth
 * - Website: https://fetti.win/
 */

contract FETTI {
    string public constant name = "FETTI";
    string public constant symbol = "FETTI";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1000000 * 10**uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        unchecked {
            balanceOf[msg.sender] -= _value;
        }
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0), "Invalid address");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        unchecked {
            balanceOf[_from] -= _value;
            allowance[_from][msg.sender] -= _value;
        }
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}