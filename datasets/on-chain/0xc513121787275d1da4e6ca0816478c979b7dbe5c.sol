// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// Embedded ReentrancyGuard to avoid import issues on Etherscan
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Mega is IERC20, IERC20Metadata, ReentrancyGuard {
    using Address for address payable;

    string public name = "MEGA";
    string public symbol = "$MEGA";
    uint8 public decimals = 18;

    uint256 private _totalSupply = 47000000000 * 10 ** uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public pair;
    bool public tradingEnabled = false;
    uint256 public maxBuyLimit; 
    uint256 public maxSellLimit;
    uint256 public maxWalletLimit;
    address public marketingWallet = 0x45cb9DB79371EA44d8D03047F7a7576D84423B5e;
    uint256 public buyMarketingTax = 3;
    uint256 public sellMarketingTax = 5;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public exemptFee;

    address private _owner;
    event AddressWhitelisted(address indexed addr, bool status);
    event TradingEnabled(bool status);

    constructor() {
        _balances[msg.sender] = _totalSupply;
        exemptFee[address(this)] = true;
        exemptFee[msg.sender] = true;
        exemptFee[marketingWallet] = true;
        _owner = msg.sender;
        maxBuyLimit = _totalSupply * 3 / 100;
        maxSellLimit = _totalSupply * 5 / 100;
        maxWalletLimit = _totalSupply * 3 / 100;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address accountOwner, address spender) external view override returns (uint256) {
        return _allowances[accountOwner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _approve(address accountOwner, address spender, uint256 amount) internal {
        require(accountOwner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        _allowances[accountOwner][spender] = amount;
        emit Approval(accountOwner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal nonReentrant {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "Insufficient balance");

        if (!exemptFee[sender] && !exemptFee[recipient]) {
            require(tradingEnabled || isWhitelisted[recipient], "Trading not enabled");
            if (recipient == pair) require(amount <= maxSellLimit, "Exceeds max sell limit");
            if (sender == pair) require(amount <= maxBuyLimit, "Exceeds max buy limit");
            require(_balances[recipient] + amount <= maxWalletLimit, "Exceeds max wallet limit");
        }

        uint256 fee = 0;
        if (!exemptFee[sender] && !exemptFee[recipient]) {
            if (recipient == pair) fee = (amount * sellMarketingTax) / 100;
            else if (sender == pair) fee = (amount * buyMarketingTax) / 100;
        }

        _balances[sender] -= amount;
        _balances[recipient] += (amount - fee);
        if (fee > 0) _balances[marketingWallet] += fee;

        emit Transfer(sender, recipient, amount - fee);
        if (fee > 0) emit Transfer(sender, marketingWallet, fee);
    }

    function whitelistAddress(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            isWhitelisted[addresses[i]] = status;
            emit AddressWhitelisted(addresses[i], status);
        }
    }

    function enableTrading(bool status) external onlyOwner {
        tradingEnabled = status;
        emit TradingEnabled(status);
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    function owner() public view returns (address) {
        return _owner;
    }
}