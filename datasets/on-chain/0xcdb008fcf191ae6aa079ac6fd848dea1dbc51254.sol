/*
    _____
   /     \
  | () () |
   \  ^  /
    |||||
    |||||

  https://knots.finance/ Proprietary
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
}

contract KnotLiquidity {
    struct Pool {
        uint256 liquidity;
        address token;
        address linkedPool;
        bool isInterconnected;
    }

    mapping(address => Pool) private pools;
    mapping(address => mapping(address => uint256)) public userLiquidity;
    uint256 private constant propagationDepth = 5;
    
    function deposit(address pool, uint256 amount) external {
        require(pools[pool].token != address(0), "Pool doesn't exist");
        IERC20(pools[pool].token).transferFrom(msg.sender, address(this), amount);
        userLiquidity[msg.sender][pool] += amount;
        pools[pool].liquidity += amount;
        propagateLiquidity(pool, amount, 0);
    }

    function propagateLiquidity(address pool, uint256 amount, uint256 depth) internal {
        if (depth >= propagationDepth || pools[pool].linkedPool == address(0)) return;

        uint256 transferAmount = amount / 2;
        pools[pool].liquidity -= transferAmount;
        pools[pools[pool].linkedPool].liquidity += transferAmount;
        propagateLiquidity(pools[pool].linkedPool, transferAmount, depth + 1);
    }

    function addPool(address pool, address token, address linkedPool) external {
        pools[pool] = Pool({
            liquidity: 0,
            token: token,
            linkedPool: linkedPool,
            isInterconnected: true
        });
    }

    function withdraw(address pool, uint256 amount) external {
        require(userLiquidity[msg.sender][pool] >= amount, "Insufficient liquidity");
        userLiquidity[msg.sender][pool] -= amount;
        pools[pool].liquidity -= amount;
        IERC20(pools[pool].token).transfer(msg.sender, amount);
    }

    function deformPool(address fromPool, address toPool, uint256 deformationFactor) external {
        require(pools[fromPool].isInterconnected, "Pool is not interconnected");
        uint256 totalDeformation = pools[fromPool].liquidity / deformationFactor;
        pools[fromPool].liquidity -= totalDeformation;
        pools[toPool].liquidity += totalDeformation;
        propagateLiquidity(toPool, totalDeformation, 0);
    }
}