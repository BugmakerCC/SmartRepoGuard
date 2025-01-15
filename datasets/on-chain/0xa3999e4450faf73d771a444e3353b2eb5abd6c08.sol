// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 目标挖矿合约接口
interface IMiningContract {
    function mineBatch(uint256 mineCounts) external payable;
}

// 代币合约接口，用于查询和转账代币
interface ITokenContract {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ProxyMiningContract {
    address public owner = msg.sender;  // 合约部署者地址
    
    // 硬编码目标挖矿合约和代币合约地址
    IMiningContract public miningContract = IMiningContract(0x35c8941c294E9d60E0742CB9f3d58c0D1Ba2DEc4);
    ITokenContract public tokenContract = ITokenContract(0x35c8941c294E9d60E0742CB9f3d58c0D1Ba2DEc4);

    // 仅合约拥有者可以调用的方法
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // 代理调用 mineBatch，传递 mineCounts = 10，并使用合约余额支付 0.001 ETH
    function proxyMineBatch() external onlyOwner {
        require(address(this).balance >= 0.001 ether, "Insufficient contract balance for mining");

        // 调用目标合约的 mineBatch 方法，使用合约自身余额支付
        try miningContract.mineBatch{value: 0.001 ether}(10) {
            // 检查是否获得了 200 个代币
            uint256 balance = tokenContract.balanceOf(address(this));
            require(balance >= 200, "Mining failed or insufficient tokens received");

            // 成功获取 200 个代币后可以转给合约拥有者
            require(tokenContract.transfer(owner, 200), "Token transfer failed");

        } catch {
            // 如果调用失败，回滚交易
            revert("Mining operation failed, transaction reverted.");
        }
    }

    // 合约拥有者可以提取合约内剩余的资金
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // 接收 ETH 的回调函数，允许直接向合约转账
    receive() external payable {}
}