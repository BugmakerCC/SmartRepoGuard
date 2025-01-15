// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Post Quantum Network Token
 * @notice Implementation of a secure ERC20 token with recovery capabilities
 * @dev Implements safety checks, reentrancy protection, and gas optimizations
 */

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

/**
 * @dev Reentrancy Guard abstract contract
 */
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

abstract contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(to != address(0), "Transfer to zero address");
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        require(spender != address(0), "Approve to zero address");
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        require(spender != address(0), "Approve to zero address");
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient balance for transfer");
        
        unchecked {
            // Overflow impossible due to balance check above
            _balances[from] = fromBalance - amount;
            // Overflow impossible as total supply cannot exceed max uint256
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Mint to zero address");
        
        unchecked {
            // Overflow check not needed as totalSupply cannot exceed max uint256
            _totalSupply += amount;
            _balances[account] += amount;
        }
        
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance for transfer");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

abstract contract Ownable {
    address private _owner;
    
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }
    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function _checkOwner() internal view virtual {
        if (owner() != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title Post Quantum Network Token
 * @notice ERC20 token with enhanced security features and recovery capabilities
 * @dev Implements reentrancy protection and gas optimizations
 */
contract PostQuantumNetwork is ERC20, Ownable, ReentrancyGuard {
    // Events
    event EthRecovered(address indexed to, uint256 amount);
    event TokensRecovered(address indexed token, address indexed to, uint256 amount);
    
    // Constants
    uint256 private constant INITIAL_SUPPLY = 400_000_000 * 10**18; // 400 million tokens

    /**
     * @notice Contract constructor
     * @dev Mints initial supply to deployer and sets up ownership
     */
    constructor() 
        ERC20("Post Quantum Network", "PQCN")
        Ownable(msg.sender)
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice Recovers ERC20 tokens accidentally sent to the contract
     * @dev Can recover any ERC20 token including PQCN tokens
     * @param tokenAddress Address of the token to recover
     * @param amount Amount of tokens to recover
     */
    function recoverERC20(address tokenAddress, uint256 amount) external nonReentrant onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient balance to recover");

        bool success = IERC20(tokenAddress).transfer(owner(), amount);
        require(success, "Token recovery failed");
        emit TokensRecovered(tokenAddress, owner(), amount);
    }

    /**
     * @notice Recovers ETH accidentally sent to the contract
     * @dev Protected against reentrancy attacks
     */
    function recoverETH() external nonReentrant onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to recover");
        
        (bool success, ) = owner().call{value: balance}("");
        require(success, "ETH recovery failed");
        emit EthRecovered(owner(), balance);
    }

    /**
     * @dev Allows the contract to receive ETH
     */
    receive() external payable {}
}