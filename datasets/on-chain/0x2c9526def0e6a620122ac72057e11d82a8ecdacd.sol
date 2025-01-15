// SPDX-License-Identifier: MIT
// https://x.com/99_erc
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC99 is IERC20 {
    event TokensCombined(address indexed owner, uint256 newTokenId, uint256[] combinedTokenIds);

    function generateTokens(uint256 amount) external returns (bool);
    function combineTokens(uint256[] memory tokenIds) external returns (uint256);
}

contract ERC99Token is IERC99 {
    string public name = "erc99";
    string public symbol = "99";
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _nextTokenId;

    address public constant vitalikAddress = 0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6;

    constructor() {
        uint256 maxSupply = 99_000_000 * 10 ** uint256(decimals);
        uint256 vitalikPortion = (maxSupply * 999) / 10000;
        uint256 deployerPortion = maxSupply - vitalikPortion;
        _balances[msg.sender] = deployerPortion;
        emit Transfer(address(0), msg.sender, deployerPortion);
        _balances[vitalikAddress] = vitalikPortion;
        emit Transfer(address(0), vitalikAddress, vitalikPortion);
        _totalSupply = maxSupply;
        _nextTokenId = 1;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount, "ERC99: transfer amount exceeds balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
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
    
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(_balances[from] >= amount, "ERC99: transfer amount exceeds balance");
        require(_allowances[from][msg.sender] >= amount, "ERC99: transfer amount exceeds allowance");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function generateTokens(uint256 amount) external override returns (bool) {
        _balances[msg.sender] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }
    
    function combineTokens(uint256[] memory tokenIds) external override returns (uint256) {
        require(tokenIds.length > 1, "ERC99: need at least two tokens to combine");
        uint256 newTokenId = _nextTokenId++;
        emit TokensCombined(msg.sender, newTokenId, tokenIds);
        return newTokenId;
    }
}