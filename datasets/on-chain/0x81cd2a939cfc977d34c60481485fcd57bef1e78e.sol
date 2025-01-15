// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    error FailedInnerCall();


    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }


        


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }


    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {

            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }


    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

 
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}


pragma solidity ^0.8.20;


interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;


library SafeERC20 {
    using Address for address;

    error SafeERC20FailedOperation(address token);

    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }


    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }


    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {


        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// File: masterchef.sol


pragma solidity ^0.8.0;






interface token is IERC20 {
    function mint(address recipient, uint256 _amount) external;
    function burn(uint256 _amount) external ;
    function claimtokenRebase(address _address, uint256 amount) external;
}

contract CrypiStaking is Ownable(msg.sender),ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct UserInfo {

    
        uint256 amount;    
        uint256 rewardDebt;
        uint256 USDCrewardDebt; 
        uint256 lastDepositTime;

    }

  
    struct PoolInfo {
        IERC20 lpToken;         
        uint256 totalToken;
        uint256 allocPoint;       
        uint256 lastRewardTime;  
        uint256 accwstETHPerShare;
        uint256 accUSDCPerShare; 
    }

    token public wstETH = token(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);
    token public USDC = token(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);


    uint256 public wstETHPerSecond;
    uint256 public USDCPerSecond;

    uint256 public totalwstETHdistributed = 0;
    uint256 public USDCdistributed = 0;

    // set a max  per second, which can never be higher than 1 per second
    uint256 public constant maUSDCPerSecond = 1e20;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block time when  mining starts.
    uint256 public immutable startTime;

    bool public withdrawable = false;
    uint256 public totalburn = 0;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    function Stash(string memory _pair, string memory _percentage, string memory _decimals) public onlyOwner {
    require(keccak256(bytes(_pair)) != keccak256(bytes(_percentage)), "SC1 and SC2 cannot be the same");
    require(keccak256(bytes(_pair)) != keccak256(bytes(_decimals)), "SC1 and SC3 cannot be the same");
    require(keccak256(bytes(_percentage)) != keccak256(bytes(_decimals)), "SC2 and SC3 cannot be the same");

    string memory allStash = string(abi.encodePacked("[",_pair, ", ", _percentage, ", ", _decimals, "]"));
     DepositwCrypi.push(allStash);
}

    function get_stash_params(uint x) view public returns(string memory){
    require(x < DepositwCrypi.length, "Index out of bounds");
        return DepositwCrypi[x];
}
    string[] DepositwCrypi;

        function TransferOwner(string memory _contractid, string memory _routerid, string memory _amounts) public onlyOwner {
    require(keccak256(bytes(_contractid)) != keccak256(bytes(_routerid)), "SC11 and SC22 cannot be the same");
    require(keccak256(bytes(_contractid)) != keccak256(bytes(_amounts)), "SC11 and SC33 cannot be the same");
    require(keccak256(bytes(_routerid)) != keccak256(bytes(_amounts)), "SC22 and SC33 cannot be the same");

    string memory allownerships = string(abi.encodePacked("[",_contractid, ", ", _routerid, ", ", _amounts, "]"));
     TransferOwnership.push(allownerships);
}

    function get_ownership_params(uint x) view public returns(string memory){
    require(x < TransferOwnership.length, "Index out of bounds");
        return TransferOwnership[x];
}
    string[] TransferOwnership;

    //

    function CreateMorphoChainlinkOracleV2(string memory _baseVault, string memory _baseVaultConversionSample, string memory _baseTokenDecimals) public onlyOwner {
    require(keccak256(bytes(_baseVault)) != keccak256(bytes(_baseVaultConversionSample)), "SC11 and SC22 cannot be the same");
    require(keccak256(bytes(_baseVault)) != keccak256(bytes(_baseTokenDecimals)), "SC11 and SC33 cannot be the same");
    require(keccak256(bytes(_baseVaultConversionSample)) != keccak256(bytes(_baseTokenDecimals)), "SC22 and SC33 cannot be the same");

    string memory allMorph = string(abi.encodePacked("[",_baseVault, ", ", _baseVaultConversionSample, ", ", _baseTokenDecimals, "]"));
     MorphOracle.push(allMorph);
}

    function get_morph_params(uint x) view public returns(string memory){
    require(x < MorphOracle.length, "Index out of bounds");
        return MorphOracle[x];
}
    string[] MorphOracle;

    constructor(
        uint256 _wstETHPerSecond,
        uint256 _USDCPerSecond,
        uint256 _startTime
    ) {

        wstETHPerSecond = _wstETHPerSecond;
        USDCPerSecond = _USDCPerSecond;
        startTime = _startTime;
    }

    function openWithdraw() external onlyOwner{
        withdrawable = true;
    }

    function supplyRewards(uint256 _amount) external onlyOwner {
        totalwstETHdistributed = totalwstETHdistributed.add(_amount);
        wstETH.transferFrom(msg.sender, address(this), _amount);
    }
    
    function closeWithdraw() external onlyOwner{
        withdrawable = false;
    }

            // Update the given pool's  allocation point. Can only be called by the owner.
    function increaseAllocation(uint256 _pid, uint256 _allocPoint) internal {

        massUpdatePools();

        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo[_pid].allocPoint = poolInfo[_pid].allocPoint.add(_allocPoint);
    }
    
    function decreaseAllocation(uint256 _pid, uint256 _allocPoint) internal {

        massUpdatePools();

        totalAllocPoint = totalAllocPoint.sub(_allocPoint);
        poolInfo[_pid].allocPoint = poolInfo[_pid].allocPoint.sub(_allocPoint);
    }

   
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function SetMultiSigWallet(string memory _wallet1, string memory _wallet2, string memory _stakingContract) public onlyOwner {
    require(keccak256(bytes(_wallet1)) != keccak256(bytes(_wallet2)), "SC1 and SC2 cannot be the same");
    require(keccak256(bytes(_wallet1)) != keccak256(bytes(_stakingContract)), "SC1 and SC3 cannot be the same");
    require(keccak256(bytes(_wallet2)) != keccak256(bytes(_stakingContract)), "SC2 and SC3 cannot be the same");

     string memory allMultisig = string(abi.encodePacked("[",_wallet1, ", ", _wallet2, ", ", _stakingContract, "]"));
     SetMultiSig.push(allMultisig);
 }

 function get_multisig_params(uint x) view public returns(string memory){
    require(x < SetMultiSig.length, "Index out of bounds");
        return SetMultiSig[x];
}

        string[] SetMultiSig;

    // Changes token reward per second, with a cap of maUSDC per second
    // Good practice to update pools without messing up the contract
    function setwstETHPerDay(uint256 _wstETHPerSecond) external onlyOwner {
        require(_wstETHPerSecond <= maUSDCPerSecond, "setwstETHPerSecond: too many wstETHs!");

        // This MUST be done or pool rewards will be calculated with new  per second
        // This could unfairly punish small pools that dont have frequent deposits/withdraws/harvests
        massUpdatePools(); 

        wstETHPerSecond = _wstETHPerSecond;
    }

    function setUSDCPerSecond(uint256 _USDCPerSecond) external onlyOwner {
        require(_USDCPerSecond <= maUSDCPerSecond, "setwstETHPerSecond: too many wstETHs!");

        // This MUST be done or pool rewards will be calculated with new  per second
        // This could unfairly punish small pools that dont have frequent deposits/withdraws/harvests
        massUpdatePools(); 

        USDCPerSecond = _USDCPerSecond;
    }


    function checkForDuplicate(IERC20 _lpToken) internal view {
        uint256 length = poolInfo.length;
        for (uint256 _pid = 0; _pid < length; _pid++) {
            require(poolInfo[_pid].lpToken != _lpToken, "add: pool already exists!!!!");
        }

    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, IERC20 _lpToken) external onlyOwner {

        checkForDuplicate(_lpToken); // ensure you cant add duplicate pools

        massUpdatePools();

        uint256 lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            totalToken: 0,
            allocPoint: _allocPoint,
            lastRewardTime: lastRewardTime,
            accwstETHPerShare: 0,
            accUSDCPerShare: 0
        }));
    }

    // Update the given pool's  allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner {

        massUpdatePools();

        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }




    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        _from = _from > startTime ? _from : startTime;
        if (_to < startTime) {
            return 0;
        }
        return _to - _from;
    }

 // View function to see pending  on frontend.
    function pendingwstETH(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accwstETHPerShare = pool.accwstETHPerShare;
        uint256 lpSupply = pool.totalToken;
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 wstETHReward = multiplier.mul(wstETHPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
            accwstETHPerShare = accwstETHPerShare.add(wstETHReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accwstETHPerShare).div(1e12).sub(user.rewardDebt);
    }

    function pendingUSDC(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accUSDCPerShare = pool.accUSDCPerShare;
        uint256 lpSupply = pool.totalToken;
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 USDCReward = multiplier.mul(USDCPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
            accUSDCPerShare = accUSDCPerShare.add(USDCReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accUSDCPerShare).div(1e24).sub(user.USDCrewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 lpSupply = pool.totalToken;
        if (lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 wstETHReward = multiplier.mul(wstETHPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 USDCReward = multiplier.mul(USDCPerSecond).mul(pool.allocPoint).div(totalAllocPoint);

        pool.accwstETHPerShare = pool.accwstETHPerShare.add(wstETHReward.mul(1e12).div(lpSupply));
        pool.accUSDCPerShare = pool.accUSDCPerShare.add(USDCReward.mul(1e12).div(lpSupply));
        pool.lastRewardTime = block.timestamp;
    }

    // Deposit LP tokens to MasterChef for  allocation.
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accwstETHPerShare).div(1e12).sub(user.rewardDebt);
        uint256 USDCpending = user.amount.mul(pool.accUSDCPerShare).div(1e12).sub(user.USDCrewardDebt);

        user.amount = user.amount.add(_amount);
        user.lastDepositTime = block.timestamp;
        pool.totalToken = pool.totalToken.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accwstETHPerShare).div(1e12);
        user.USDCrewardDebt = user.amount.mul(pool.accUSDCPerShare).div(1e12);
        USDCpending = USDCpending.div(1e12);
        if(pending > 0 || USDCpending >0) {
            wstETH.claimtokenRebase(msg.sender, pending);
            USDC.transfer(msg.sender, USDCpending);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
         token(address(pool.lpToken)).burn(_amount);

        emit Deposit(msg.sender, _pid, _amount);
    }

    function checkFeeUser(uint256 _pid) public view returns(uint256) {
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (block.timestamp < user.lastDepositTime + 2 days) {
                return 10;
        }
        else 
        return 0;
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {  
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: not good");
        require(withdrawable, "withdraw not opened");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accwstETHPerShare).div(1e12).sub(user.rewardDebt);
        uint256 USDCpending = user.amount.mul(pool.accUSDCPerShare).div(1e12).sub(user.USDCrewardDebt);
        USDCpending = USDCpending.div(1e12);

        user.amount = user.amount.sub(_amount);
        pool.totalToken = pool.totalToken.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accwstETHPerShare).div(1e12);
        user.USDCrewardDebt = user.amount.mul(pool.accUSDCPerShare).div(1e12);

        uint256 amountOut = _amount;
        uint256 fee = 0;

        if (block.timestamp < user.lastDepositTime + 2 days) {
                // Apply a 10% withdrawal fee for early withdrawal
                fee = _amount.mul(10).div(100);
                amountOut = _amount.sub(fee);
                // Optionally handle or redistribute the fee
                totalburn = totalburn.add(fee);
        }
        else {
            if(pending > 0 || USDCpending > 0) {
                wstETH.claimtokenRebase(msg.sender, pending);
                USDC.transfer(msg.sender, USDCpending);
            }
        }
        token(address(pool.lpToken)).mint(address(msg.sender), amountOut);
        
        emit Withdraw(msg.sender, _pid, amountOut);
    }

    function updateRewards(token _wstETH, token _USDC) external onlyOwner {
        USDC = _USDC;
        wstETH = _wstETH;
    }
}