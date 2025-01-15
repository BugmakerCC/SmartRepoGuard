/*

Join Whizy's immersive adventure game to explore the exciting world of blockchain and web3 technology! 
? Embark on a thrilling journey as Azad, an intrepid reporter, discovers a financial crisis in the fictional country of Listenbourg. 
No prior knowledge needed - just follow the story and discover the wonders of web3 along the way! Start your adventure now!

Website/dApp: https://whizy.app

Documentation: https://docs.whizy.app

Medium: https://medium.com/@whizyeth/whizy-story-of-a-whistleblower-17a846a025bf

Twitter: https://twitter.com/WhizyETH

Community chat: https://t.me/WhizyETH                                           

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

contract Whizy {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    string public constant name = "WHIZY";
    string public constant symbol = "WHIZY";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}