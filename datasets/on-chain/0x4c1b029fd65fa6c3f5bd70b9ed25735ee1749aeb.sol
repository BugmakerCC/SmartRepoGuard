/**
 *Submitted for verification at Etherscan.io on 2024-08-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function balanceOf(address account) external view returns (uint256);
}

contract SWLETH {
    string public name = "Staked Wrapped Ether";
    string public symbol = "SWLETH";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address _to, uint256 _amount) external {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function burn(address _from, uint256 _amount) external {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(balanceOf[msg.sender] >= _amount, "Not enough balance");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        require(balanceOf[_from] >= _amount, "Not enough balance");
        require(allowance[_from][msg.sender] >= _amount, "Not enough allowance");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }
}

contract TimelockedWETH {
    IWETH public weth;
    SWLETH public swlethToken;
    address public owner;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Deposit) public deposits;
    uint256 constant LOCK_PERIOD = 15 days;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _weth) {
        weth = IWETH(_weth);
        swlethToken = new SWLETH();
        owner = msg.sender;
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount can not be 0");
        require(weth.transfer(address(this), _amount), "Transfer failed");
        deposits[msg.sender].amount += _amount;
        deposits[msg.sender].timestamp = block.timestamp;
        swlethToken.mint(msg.sender, _amount);
        emit Deposited(msg.sender, _amount);
    }

    function withdraw() external {
        require(deposits[msg.sender].amount > 0, "No WETH to be withdrawn");
        require(block.timestamp >= deposits[msg.sender].timestamp + LOCK_PERIOD, "Still locked");
        uint256 amount = deposits[msg.sender].amount;
        deposits[msg.sender].amount = 0;
        swlethToken.burn(msg.sender, amount);
        require(weth.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function getDepositInfo(address _user) external view returns (uint256 amount, uint256 unlockTime) {
        Deposit memory dep = deposits[_user];
        return (dep.amount, dep.timestamp + LOCK_PERIOD);
    }
}