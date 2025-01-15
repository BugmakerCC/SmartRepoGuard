/*

https://t.me/ziggyerc

*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed ownerAddress, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address ownerAddress, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 public buyTax = 18;  //
    uint256 public sellTax = 28;  //
    address public owner;

    modifier onlyOwner() {
        require(_msgSender() == owner, "Only the contract owner can call this function.");
        _;
    }

    event TaxUpdated(uint256 buyTax, uint256 sellTax);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(string memory name_, string memory symbol_, uint256 initialSupply) {
        _name = name_;
        _symbol = symbol_;
        owner = _msgSender();
        _totalSupply = initialSupply * 10 ** decimals();
        _balances[owner] = _totalSupply;  // Allocate all tokens to the contract deployer

        emit Transfer(address(0), owner, _totalSupply);  // Emit event to indicate the initial allocation
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address sender = _msgSender();  // Renamed from owner to sender
        _transfer(sender, to, amount, false);  // false indicates this is a regular transfer, not a sell
        return true;
    }

    function allowance(address ownerAddress, address spender) public view virtual override returns (uint256) {
        return _allowances[ownerAddress][spender];  // Changed owner to ownerAddress for clarity
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address sender = _msgSender();  // Renamed from owner to sender
        _approve(sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount, true);  // true indicates this is a sell transfer
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address sender = _msgSender();  // Renamed from owner to sender
        _approve(sender, spender, allowance(sender, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address sender = _msgSender();  // Renamed from owner to sender
        uint256 currentAllowance = allowance(sender, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function setBuyTax(uint256 _buyTax) external onlyOwner {
        buyTax = _buyTax;
        emit TaxUpdated(buyTax, sellTax);
    }

    function setSellTax(uint256 _sellTax) external onlyOwner {
        sellTax = _sellTax;
        emit TaxUpdated(buyTax, sellTax);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount,
        bool isSell
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        uint256 taxAmount = isSell ? (amount * sellTax / 100) : (amount * buyTax / 100);
        uint256 netAmount = amount - taxAmount;

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += netAmount;
        }

        emit Transfer(from, to, netAmount);

        if (taxAmount > 0) {
            _balances[owner] += taxAmount;  // Tax is sent to the contract owner
            emit Transfer(from, owner, taxAmount);
        }

        _afterTokenTransfer(from, to, netAmount);
    }

    function _approve(
        address ownerAddress,  // Renamed from owner to ownerAddress
        address spender,
        uint256 amount
    ) internal virtual {
        require(ownerAddress != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownerAddress][spender] = amount;
        emit Approval(ownerAddress, spender, amount);
    }

    function _spendAllowance(
        address ownerAddress,  // Renamed from owner to ownerAddress
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(ownerAddress, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(ownerAddress, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /// @dev Renounce ownership and transfer control to the dead address
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0x000000000000000000000000000000000000dEaD));
        owner = address(0x000000000000000000000000000000000000dEaD);
    }

    function hasLeadingZeroBytes(address addr, uint8 numZeroBytes) public pure returns (bool) {
        require(numZeroBytes <= 20, "Number of leading zero bytes cannot exceed 20");
        
        bytes20 addrBytes = bytes20(addr);
        for (uint256 i = 0; i < numZeroBytes; i++) {
            if (addrBytes[i] != 0x00) {
                return false;
            }
        }
        return true;
    }
}

pragma solidity ^0.8.9;

contract FaustTweet is ERC20 {
    constructor() ERC20(unicode"Andy's Dog", unicode"ZIGGY", 1000000000) {}
}