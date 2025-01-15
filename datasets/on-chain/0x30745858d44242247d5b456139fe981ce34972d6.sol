// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
}

contract SATOSHIPATCH is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() {
        name = "satoshi 74638 patched bitcoin";
        symbol = "patch";
        decimals = 8;
        _update(address(0), msg.sender, 184467440737085540);
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _update(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        require(allowance[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        allowance[sender][msg.sender] -= amount;
        _update(sender, recipient, amount);
        return true;
    }

    function mint(uint256 amountToMint) external {
        require(amountToMint <= 244678000924078, "Minting exceeds amount to mint");
        require(totalSupply + amountToMint <= 18446744073708554078, "Minting exceeds total supply");
        _update(address(0),msg.sender, amountToMint);
    }

    function _update(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            totalSupply += value;
        } else {
            uint256 fromBalance = balanceOf[from];
            if (fromBalance < value) {
                revert("ERC20: transfer amount exceeds balance");
            }
            unchecked {
                balanceOf[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                totalSupply -= value;
            }
        } else {
            unchecked {
                balanceOf[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
}