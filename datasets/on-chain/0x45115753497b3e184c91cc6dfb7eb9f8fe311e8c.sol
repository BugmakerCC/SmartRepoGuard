// SPDX-License-Identifier: MIT

// CA: 0x9999ae1188F0a425eD41111562927aDEf87c4205

// Website: https://peperoneth.com
// Telegram: https://t.me/peperoneth
// Twitter: https://x.com/peperonethereum

pragma solidity ^0.8.23;

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

contract PEPER is IERC20 {
    string public name = "PEPER6900";
    string public symbol = "$PEPER";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 1 * 10 ** uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}