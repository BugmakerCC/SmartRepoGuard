// SPDX-License-Identifier:MIT
// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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

// File: TrumpVsHarris.sol


pragma solidity 0.8.20;




// Betting contract. Users who bet on the winning team share the “losing pool” in proportion to their share of the winning pool.
contract TRUMPvsHARRIS is Ownable, ReentrancyGuard {
    // ============= VARIABLES ============

    // Contract address of the CTOE
    IERC20 public immutable CamtoeToken = IERC20(0xE098247F045760B9820c70495d05Bb4D2DB6E6F0);
    
    //Minimum bet
    uint256 public minimumBet=1000000000000000000; //1 token
    // Timestamp of when the bet period starts
    uint256 public StartDate;
    // Timestamp of when the bet period ends
    uint256 public EndDate=1730804400; //Mon Nov 04 2024 23:00:00 GMT+0000

    // Number of tokens bet on Trump
    uint256 public Trump_pool;
    // Number of wallet which for Trump
    uint256 public Trump_participants;
    // Number of tokens bet on Harris
    uint256 public Harris_pool;
    // Number of wallet which for Harris
    uint256 public Harris_participants;

    // total bet
    uint256 public totalBet;
    // bet status
    string public betStatus;
    //winner
    uint256 public Winner;

    // mapping user tokens bet for each candidat
    // Trump pool: 1
    // Harris pool: 2
    mapping(address=> mapping(uint256 => uint256)) public user_candidat_bet;

    event Trump(address indexed  user, uint256 amount);
    event Harris(address indexed  user, uint256 amount);
    event Claim(address indexed  user, uint256 amount);
    event GetReimbursement(address indexed  user, uint256 amount);
    event SetWinner(uint256 winner);

    constructor() Ownable(msg.sender) {
        StartDate = block.timestamp;
        betStatus="open";
    }

    // ============= MODIFIERS ============

    modifier checkBeforeEndDate {
      require ( block.timestamp < EndDate) ;
      _ ;
    }

    modifier checkAfterEndDate {
      require ( block.timestamp > EndDate) ;
      _ ;
    }

    modifier checkStatus(string memory _status) {
      require(keccak256(abi.encodePacked((betStatus))) == keccak256(abi.encodePacked(_status)));
      _ ;
    }

    modifier checkNotStatus(string memory _status) {
      require(keccak256(abi.encodePacked((betStatus))) != keccak256(abi.encodePacked(_status)));
      _ ;
    }

    // ============= FUNCTIONS ============
    // Trump pool: 1
    function betTrump(uint256 _amount) nonReentrant checkNotStatus("cancelled") checkBeforeEndDate public {
        require(_amount >= minimumBet,"invalid token sent");
        if(user_candidat_bet[msg.sender][1]==0){
            Trump_participants+=1;
        }
        CamtoeToken.transferFrom(msg.sender, address(this), _amount);
        user_candidat_bet[msg.sender][1] += _amount;
        Trump_pool += _amount;
        totalBet += _amount;
        emit Trump(msg.sender, _amount);
    }

    // Harris pool: 2
    function betHarris(uint256 _amount) nonReentrant checkNotStatus("cancelled") checkBeforeEndDate public {
        require(_amount >= minimumBet,"invalid token sent");
        if(user_candidat_bet[msg.sender][2]==0){
            Harris_participants+=1;
        }
        CamtoeToken.transferFrom(msg.sender, address(this), _amount);
        user_candidat_bet[msg.sender][2] += _amount;
        Harris_pool += _amount;
        totalBet += _amount;
        emit Harris(msg.sender, _amount);
    }

    // Trump pool: 1
    // Harris pool: 2
    function set_winner(uint256 _Winner) checkAfterEndDate onlyOwner public {
        require(_Winner==1 || _Winner==2,"invalid candidat");
        Winner = _Winner;
        betStatus = "claim";
        emit SetWinner(_Winner);
    }

    function cancel() checkNotStatus("claim") onlyOwner public {
        betStatus="cancelled";
    }

    function getUserReward(address _user) checkStatus("claim") checkAfterEndDate public view returns (uint256){
        uint256 _userAmountBetWinner = user_candidat_bet[_user][Winner];
        uint256 _poolWinner;
        if(Winner==1){
            _poolWinner=Trump_pool;
        }
        else{
            _poolWinner=Harris_pool;
        }
        uint256 _rewardUser = ((totalBet-_poolWinner)*_userAmountBetWinner)/_poolWinner;

        return  _rewardUser;
    }

    function getreimbursement() nonReentrant checkStatus("cancelled") public {
        uint256 _userAmountBet;
        for(uint256 i=1 ; i<=2 ; i++){
            _userAmountBet += user_candidat_bet[msg.sender][i];
        }
        require(_userAmountBet>0,"nothing to get");
        CamtoeToken.transfer(msg.sender,_userAmountBet);
        for(uint256 i=1 ; i<=2 ; i++){
            delete user_candidat_bet[msg.sender][i];
        }

        emit GetReimbursement(msg.sender, _userAmountBet);
    }

    function getRewardWithdraw() nonReentrant checkNotStatus("cancelled") checkAfterEndDate public {
        uint256 _userReward=getUserReward(msg.sender);
        require(_userReward>0,"nothing to get");
        uint256 _userAmountBetWin = user_candidat_bet[msg.sender][Winner];

        for(uint256 i=1 ; i<=2 ; i++){
            delete user_candidat_bet[msg.sender][i];
        }
        uint256 total_amount = _userAmountBetWin + _userReward;
        CamtoeToken.transfer(msg.sender, total_amount);

        emit Claim(msg.sender, _userReward);
    }

}