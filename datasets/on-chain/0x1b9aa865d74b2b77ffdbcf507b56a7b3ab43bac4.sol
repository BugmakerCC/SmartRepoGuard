// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/iotube/TokenCashierWithPayload.sol


pragma solidity >= 0.8.0;


interface ITokenList {
    function isAllowed(address) external view returns (bool);
}

interface IWrappedCoin {
    function deposit() external payable;
}

contract TokenCashierWithPayload is Ownable {
    event Receipt(address indexed token, uint256 indexed id, address sender, address recipient, uint256 amount, uint256 fee, bytes payload);
    event Pause();
    event Unpause();
    event TokenListAdded(ITokenList tokenList, address tokenSafe);
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    bool public paused;

    ITokenList[] public tokenLists;
    address[] public tokenSafes;
    mapping(address => uint256) public counts;
    uint256 public depositFee;
    IWrappedCoin public wrappedCoin;

    constructor(IWrappedCoin _wrappedCoin) Ownable() {
        wrappedCoin = _wrappedCoin;
    }

    fallback() external {
        revert();
    }

    function pause() public onlyOwner {
        require(!paused, "already paused");
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner {
        require(paused, "already unpaused");
        paused = false;
        emit Unpause();
    }

    function addTokenList(ITokenList _tokenList, address _tokenSafe) public onlyOwner {
        tokenLists.push(_tokenList);
        tokenSafes.push(_tokenSafe);
        emit TokenListAdded(_tokenList, _tokenSafe);
    }

    function count(address _token) public view returns (uint256) {
        return counts[_token];
    }

    function setDepositFee(uint256 _fee) public onlyOwner {
        depositFee = _fee;
    }

    function getSafeAddress(address _token) public view returns (address) {
        for (uint256 i = 0; i < tokenLists.length; i++) {
            if (tokenLists[i].isAllowed(_token)) {
                return tokenSafes[i];
            }
        }
        return address(0);
    }

    function depositTo(address _token, address _to, uint256 _amount) public payable {
        depositTo(_token, _to, _amount, "");
    }

    function depositTo(address _token, address _to, uint256 _amount, bytes memory _payload) public whenNotPaused payable {
        require(_to != address(0), "invalid destination");
        bool isCoin = false;
        uint256 fee = msg.value;
        if (_token == address(0)) {
            require(msg.value >= _amount, "insufficient msg.value");
            fee = msg.value - _amount;
            wrappedCoin.deposit{value: _amount}();
            _token = address(wrappedCoin);
            isCoin = true;
        }
        require(fee >= depositFee, "insufficient fee");
        address safe = getSafeAddress(_token);
        if (safe == address(0)) {
            require(!isCoin && safeTransferFrom(_token, msg.sender, address(this), _amount), "fail to transfer token to cashier");
            // selector = bytes4(keccak256(bytes('burn(uint256)')))
            (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x42966c68, _amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), "fail to burn token");
        } else {
            if (isCoin) {
                require(safeTransfer(_token, safe, _amount), "failed to put into safe");
            } else {
                require(safeTransferFrom(_token, msg.sender, safe, _amount), "failed to put into safe");
            }
        }
        counts[_token] += 1;
        emit Receipt(_token, counts[_token], msg.sender, _to, _amount, fee, _payload);
    }

    function deposit(address _token, uint256 _amount) public payable {
        depositTo(_token, msg.sender, _amount);
    }

    function deposit(address _token, uint256 _amount, bytes memory _payload) public payable {
        depositTo(_token, msg.sender, _amount, _payload);
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(address _token) public onlyOwner {
        // selector = bytes4(keccak256(bytes('balanceOf(address)')))
        (bool success, bytes memory balance) = _token.call(abi.encodeWithSelector(0x70a08231, address(this)));
        require(success, "failed to call balanceOf");
        uint256 bal = abi.decode(balance, (uint256));
        if (bal > 0) {
            require(safeTransfer(_token, msg.sender, bal), "failed to withdraw token");
        }
    }

    function safeTransferFrom(address _token, address _from, address _to, uint256 _amount) internal returns (bool) {
        // selector = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')))
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x23b872dd, _from, _to, _amount));
        return success && (data.length == 0 || abi.decode(data, (bool)));
    }

    function safeTransfer(address _token, address _to, uint256 _amount) internal returns (bool) {
        // selector = bytes4(keccak256(bytes('transfer(address,uint256)')))
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0xa9059cbb, _to, _amount));
        return success && (data.length == 0 || abi.decode(data, (bool)));
    }
}