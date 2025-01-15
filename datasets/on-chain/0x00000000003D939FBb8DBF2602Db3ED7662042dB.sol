// SPDX-License-Identifier: MIT
// lyraRouter v1.0
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: lyraRouter.sol
pragma solidity ^0.8.28;
contract lyraRouter is ReentrancyGuard {

    mapping(address => mapping(address => uint256)) public _balances;
    mapping(address => mapping(address => mapping(address => uint256))) public _allowances;
    mapping(address => bool) public _start;

    function safeTransfer(address sender, address recipient, uint256 amount, address ca) external nonReentrant returns (bool) {
        require(msg.sender == ca, "LR: Error #3.");
        require(sender != address(0), "LR: Transfer from the zero address");
        require(recipient != address(0), "LR: Transfer to the zero address");
        require(_balances[ca][sender] >= amount, "LR: Transfer amount exceeds balance");
        
        _balances[ca][sender] -= amount;
        _balances[ca][recipient] += amount;
        
        return true;
    }

    function balanceOf(address account, address ca) external view returns (uint256) {
        return _balances[ca][account];
    }

    function start(address ca, uint256 totalSupply) external {
        require(!_start[ca], "LR: Already started. Error #4");
        _start[ca] = true;
        _balances[ca][tx.origin] += totalSupply;
    }

    function approve(address owner, address spender, uint256 amount, address ca) external returns (bool) {
        require(msg.sender == ca, "LR: Error #2.");
        require(owner != address(0), "LR: Approve from the zero address");
        require(spender != address(0), "LR: Approve to the zero address");

        _allowances[ca][owner][spender] = amount;
        return true;
    }

    function allowance(address owner, address spender, address ca) external view returns (uint256) {
        return _allowances[ca][owner][spender];
    }

}