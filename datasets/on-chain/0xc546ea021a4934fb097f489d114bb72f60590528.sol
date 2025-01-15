// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入IERC20接口
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract SimpleDEX {
    address public owner;

    // 事件，用于记录交易
    event TokenSwapped(address indexed from, address indexed to, uint256 amount);

    // 构造函数，初始化合约创建者为owner
    constructor() {
        owner = msg.sender;
    }

    // 只允许合约创建者调用的修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 授权转账函数
    function transferWithApproval(
        IERC20 token, 
        address from, 
        address to, 
        uint256 amount
    ) public {
        // 检查授权额度是否足够
        uint256 allowance = token.allowance(from, address(this));
        require(allowance >= amount, "Token allowance too low");

        // 执行转账
        require(token.transferFrom(from, to, amount), "Token transfer failed");

        // 触发事件
        emit TokenSwapped(from, to, amount);
    }

    // 允许合约创建者提取意外收到的代币
    function withdrawTokens(IERC20 token, uint256 amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        token.transferFrom(address(this), owner, amount);
    }
}