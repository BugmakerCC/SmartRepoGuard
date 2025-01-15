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

// File: contracts/SendrEscrow.sol


pragma solidity ^0.8.0;




contract SendrEscrow is Ownable, ReentrancyGuard{

    struct Milestone {
        uint256 contractId;
        uint256 value;
        string title;
        bool released;
        bool inDispute;
    }

    struct Delegate {
        address delegateAddress;
        uint256 votingPower;
        uint256 timestamp;
    }

    struct Contract {
        Milestone[] milestones;
        uint256 startBlock;
        uint256 contractId;
        address payer;
        address payee;
        bool active;
        string title;
        address tokenAddress;
        bool inDispute;
        uint256 valueRemaining;
    }

    struct Dispute {
        uint256 contractId;
        uint256 milestoneId;
        bool fullContractDispute;
        bool resolved;
        uint256 snapshotBlock; 
        uint256 yesVotes; 
        uint256 noVotes;
        uint256 votingDeadline;
        uint256 totalVotes;
        mapping(address => bool) hasVoted;
    }

    uint256 public VOTING_DURATION = 24 hours;
    uint256 public VOTING_EXTENSION_DURATION = 12 hours;
    uint256 public THRESHOLD_PERCENT = 10; 
    uint256 public CONTRACT_FEE = 500;
    address public FEE_WALLET = 0xeaDA12106cE206Ed1faD23C4cD94Af794282FA22;

    uint256 public activeContracts;
    IERC20 public sendrToken;
    address public sendrTreasury;
    uint256 public contractCount;

    mapping(address => Delegate[]) public userDelegations;
    mapping(uint256 => Contract) public contracts;
    mapping(uint256 => Dispute) public disputes;
    mapping(address => uint256[]) public userContracts;
    mapping(uint256 => bool) public fundedStatus;
    mapping(uint256 => address) public signer;
    mapping(address => mapping(uint256 => bool)) private voidCheck;
    mapping(uint256 => mapping(uint256 => bool)) private payeeSignedMilestone;
    mapping(uint256 => mapping(uint256 => bool)) private payerSignedMilestone;
    mapping(uint256 => bool) public voided;

    event DisputeCreated(
        uint256 contractId, 
        uint256 milestoneId, 
        bool fullContractDispute, 
        uint256 snapshotBlock
    );

    event DisputeResolved(
        uint256 contractId, 
        uint256 milestoneId, 
        bool inFavorOfPayee
    );

    event VotingExtended(
        uint256 contractId, 
        uint256 milestoneId
    );

    event ContractCreated(
        uint256 contractId,
        address payer,
        address payee,
        string title,
        string identifier
    );

    event MilestoneReleased(
        uint256 contractId,
        address payer,
        address payee,
        string title
    );

    event ContractSigned(
        uint256 contractId,
        address payer,
        address payee,
        string title
    );

    event MilestoneDisputed(
        uint256 contractId,
        uint256 milestoneId
    );

    event ContractDisputed(
        uint256 contractId
    );

    event ContractVoided(
        uint256 contractId
    );

    constructor(IERC20 _sendrToken) Ownable (msg.sender) {
        sendrToken = _sendrToken;
    }

    function setSendrToken(IERC20 _sendrToken) external onlyOwner {
        sendrToken = _sendrToken;
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        FEE_WALLET = _feeWallet;
    }

    function setFee(uint256 _fee) external onlyOwner {
        CONTRACT_FEE = _fee;
    }

    function setSendrTreasury(address _sendrTreasury) external onlyOwner {
        sendrTreasury = _sendrTreasury;
    }

    function setVotingDuration(uint256 _duration) external onlyOwner {
        require(_duration > 0, "Duration must be greater than zero");
        VOTING_DURATION = _duration;
    }

    function setVotingExtensionDuration(uint256 _extension) external onlyOwner {
        require(_extension > 0, "Extension must be greater than zero");
        VOTING_EXTENSION_DURATION = _extension;
    }

    function setThresholdPercent(uint256 _percent) external onlyOwner {
        require(_percent > 0 && _percent <= 100, "Percent must be between 1 and 100");
        THRESHOLD_PERCENT = _percent;
    }

    /**
    * @notice Allows a user to delegate a specified amount of voting power to a delegate address.
    * @dev This function records a self-delegation by storing the delegate address, the voting power,
    *      and the timestamp of the delegation. Only self-delegation is permitted by design.
    * @param delegateAddress The address to which the user is delegating their voting power.
    * @param votingPower The amount of voting power the user wishes to delegate.
    */
    function delegateVotes(address delegateAddress, uint256 votingPower) external {
        require(votingPower <= sendrToken.balanceOf(msg.sender), "Insufficient balance to delegate");

        userDelegations[msg.sender].push(Delegate({
            delegateAddress: delegateAddress,
            votingPower: votingPower,
            timestamp: block.timestamp
        }));
    }

    /**
    * @notice Retrieves the historical voting power of a user at a specific timestamp.
    * @dev This function checks past delegations recorded by the user and determines their voting power at the time of a dispute. Only self-delegations are considered.
    * @param user The address of the user whose voting power is being queried.
    * @param disputeTimestamp The timestamp of the dispute for which the voting power is needed.
    * @return uint256 The user's voting power as of the specified dispute timestamp.
    */
    function getPastVotes(address user, uint256 disputeTimestamp) public view returns (uint256) {
        Delegate[] memory delegations = userDelegations[user];
        uint256 lastValidVotingPower = 0;

        for (uint256 i = 0; i < delegations.length; i++) {
            if (delegations[i].timestamp <= disputeTimestamp) {
                lastValidVotingPower = delegations[i].votingPower;
            } else {
                break;
            }
        }

        require(sendrToken.balanceOf(user) >= lastValidVotingPower, "Insufficient balance for past voting power");

        return lastValidVotingPower;
    }
    /**
     * @notice Raises a dispute for a specific contract or milestone
     * @param _contractId The ID of the contract to dispute
     * @param _milestoneId The ID of the milestone to dispute, if applicable
     * @param _fullContractDispute True if the dispute is for the entire contract, false if it's for a specific milestone
     */
    function raiseDispute(uint256 _contractId, uint256 _milestoneId, bool _fullContractDispute) public {
        Contract storage _contract = contracts[_contractId];

        require(
            msg.sender == _contract.payer || 
            msg.sender == _contract.payee, 
            "Only contract parties can raise disputes"
        );
        require(
            _contract.active,
            "Contract not active"
        );
        require(
            _contract.valueRemaining > 0,
            "No value remaining"
        );
        require(
            !_contract.inDispute,
            "Contract already in dispute"
        );

        if (_fullContractDispute) {
            _contract.inDispute = true;
        } else {
            Milestone storage milestone = _contract.milestones[_milestoneId];

            require(
                !milestone.inDispute, 
                "Milestone already in dispute"
            );

            milestone.inDispute = true;
        }

        uint256 snapshotBlock = block.number;

        Dispute storage dispute = disputes[_contractId];
        dispute.contractId = _contractId;
        dispute.milestoneId = _milestoneId;
        dispute.fullContractDispute = _fullContractDispute;
        dispute.resolved = false;
        dispute.snapshotBlock = snapshotBlock;
        dispute.yesVotes = 0;
        dispute.noVotes = 0;
        dispute.votingDeadline = block.timestamp + VOTING_DURATION;
        dispute.totalVotes = 0;

        emit DisputeCreated(
            _contractId, 
            _milestoneId, 
            _fullContractDispute, 
            snapshotBlock
        );
    }

    /**
     * @notice Allows users to vote on an active dispute
     * @param _contractId The ID of the contract with an active dispute
     * @param _voteInFavorOfPayee True to vote in favor of the payee, false to vote in favor of the payer
     */
    function voteOnDispute(uint256 _contractId, bool _voteInFavorOfPayee) public nonReentrant {
        Dispute storage dispute = disputes[_contractId];

        require(!dispute.resolved, "Dispute already resolved");
        require(block.timestamp <= dispute.votingDeadline, "Voting period has ended");
        require(!dispute.hasVoted[msg.sender], "You have already voted");

        uint256 voterBalance = getPastVotes(msg.sender, dispute.snapshotBlock);
        require(voterBalance > 0, "No voting power");

        if (_voteInFavorOfPayee) {
            dispute.yesVotes += voterBalance;
        } else {
            dispute.noVotes += voterBalance;
        }

        dispute.totalVotes += voterBalance;
        dispute.hasVoted[msg.sender] = true;

        uint256 totalSupply = sendrToken.totalSupply();
        if (dispute.totalVotes >= (totalSupply * THRESHOLD_PERCENT / 100)) {
            _resolveDispute(_contractId);
        }
    }

    function _resolveDispute(uint256 _contractId) internal {
        Dispute storage dispute = disputes[_contractId];
        require(!dispute.resolved, "Dispute already resolved");

        Contract storage _contract = contracts[_contractId];
        Milestone storage milestone = _contract.milestones[dispute.milestoneId];

        bool inFavorOfPayee = dispute.yesVotes > dispute.noVotes;
        dispute.resolved = true;

        if (inFavorOfPayee) {
            if (dispute.fullContractDispute) {
                _sendFunds(
                    _contractId, 
                    _contract.payee, 
                    _contract.valueRemaining
                );
                _contract.valueRemaining = 0; 
                _contract.inDispute = false;
                _contract.active = false;
            } else {
                _sendFunds(
                    _contractId, 
                    _contract.payee, 
                    milestone.value
                );
                milestone.released = true;
                milestone.inDispute = false;  
                _contract.valueRemaining -= milestone.value; 
            }
        } else {
            if (dispute.fullContractDispute) {
                _sendFunds(
                    _contractId, 
                    _contract.payer, 
                    _contract.valueRemaining
                );
                _contract.valueRemaining = 0; 
                _contract.inDispute = false;
                _contract.active = false;
            } else {
                _sendFunds(
                    _contractId, 
                    _contract.payer, 
                    milestone.value
                );
                milestone.inDispute = false;
            }
        }

        emit DisputeResolved(
            _contractId, 
            dispute.milestoneId, 
            inFavorOfPayee
        );
    }

    function _sendFunds(uint256 _contractId, address recipient, uint256 amount) internal {
        require(FEE_WALLET != address(0), "Fee wallet not set");
        Contract storage _contract = contracts[_contractId];

        // Calculate the fee based on CONTRACT_FEE
        uint256 fee = (amount * CONTRACT_FEE) / 10000;
        uint256 remainingAmount = amount - fee;

        if (_contract.tokenAddress == address(0)) {
            // Send fee and remaining amount in ETH
            payable(FEE_WALLET).transfer(fee);
            payable(recipient).transfer(remainingAmount);
        } else {
            // Send fee and remaining amount in ERC20 tokens
            IERC20 token = IERC20(_contract.tokenAddress);
            token.transfer(FEE_WALLET, fee);
            token.transfer(recipient, remainingAmount);
        }
    }

    /**
     * @notice Creates a new escrow contract with specified milestones
     * @param _values The values of each milestone in the contract
     * @param _titles The titles for each milestone
     * @param _numMilestones The number of milestones in the contract
     * @param _payer The address of the payer in the contract
     * @param _payee The address of the payee in the contract
     * @param _tokenAddress The address of the token used in the contract (use address(0) for ETH)
     * @param _title The title of the contract
     */
    function createContract(
        uint256[] memory _values,
        string[] memory _titles,
        uint256 _numMilestones,
        address _payer,
        address _payee,
        address _tokenAddress,
        string memory _title,
        string memory _id 
    ) public payable {
        require(
            msg.sender == _payer || msg.sender == _payee,
            "Contract creator must be the payer or payee"
        );
        require(
            _payer != _payee,
            "Payer and Payee addresses must differ"
        );
        require(
            _values.length == _numMilestones && _titles.length == _numMilestones,
            "Invalid number of milestones"
        );

        uint256 toSend = 0;
        address _signer;

        if (msg.sender == _payer) {
            _signer = _payee;

            for (uint256 i = 0; i < _values.length; i++) {
                toSend += _values[i];
            }

            if (_tokenAddress != address(0)) {
                require(
                    IERC20(_tokenAddress).transferFrom(msg.sender, address(this), toSend),
                    "ERC20 transfer failed"
                );
                fundedStatus[contractCount] = true;
            } else {
                require(msg.value == toSend, "Wrong ETH amount");
                fundedStatus[contractCount] = true;
            }
        } else {
            _signer = _payer;
        }

        Milestone[] memory milestones = new Milestone[](_numMilestones);
        uint256 _totalValue = 0;

        for (uint256 i = 0; i < _numMilestones; i++) {
            _totalValue += _values[i];
            milestones[i] = Milestone(
                contractCount, 
                _values[i],   
                _titles[i], 
                false,       
                false       
            );
        }

        Contract storage newContract = contracts[contractCount];
        newContract.payer = _payer;
        newContract.payee = _payee;
        newContract.title = _title;
        newContract.tokenAddress = _tokenAddress;
        if (msg.sender == _payer) {
            newContract.valueRemaining = _totalValue;
        }
        else {
            newContract.valueRemaining = 0;
        }
        newContract.active = false; 

        for (uint256 i = 0; i < milestones.length; i++) {
            newContract.milestones.push(milestones[i]);
        }

        signer[contractCount] = _signer;
        contractCount += 1;
        emit ContractCreated(contractCount, _payer, _payee, _title, _id);
    }

    function _generateMilestoneArray(
        uint256 _contractId,
        uint256[] memory _values,
        string[] memory _titles,
        uint256 _numMilestones
    ) internal pure returns (Milestone[] memory, uint256) {
        Milestone[] memory toReturn = new Milestone[](_numMilestones);
        uint256 _totalValue = 0;

        for (uint256 i = 0; i < _numMilestones; i++) {
            _totalValue += _values[i];
            toReturn[i] = Milestone(
                _contractId,
                _values[i],
                _titles[i],
                false,
                false
            );
        }
        return (toReturn, _totalValue);
    }

    /**
     * @notice Signs and activates a created contract by the designated signer
     * @param _contractId The ID of the contract to sign and activate
     */
    function signContract(
        uint256 _contractId
    ) public payable {
        Contract storage _contract = contracts[_contractId];
        address _signer = signer[_contractId];
        require(
            _signer == msg.sender, 
            "You are not the signer"
        );
        require(
            !_contract.active,
            "Contract already active"
        );
        require(
            !_contract.inDispute,
            "Contract in dispute"
        );

        uint256 toSend = 0;

        if (_signer == _contract.payer) {
            for(uint256 i = 0; i < _contract.milestones.length; i++) {
                toSend += _contract.milestones[i].value;
            }

            if (
                _contract.tokenAddress != address(0)
            ) {
                address _tokenAddress = _contract.tokenAddress;

                uint256 currentBalance = IERC20(_tokenAddress).balanceOf(address(this));
                require(
                    IERC20(_tokenAddress).transferFrom(msg.sender, address(this), toSend)
                );
                uint256 newBalance = IERC20(_tokenAddress).balanceOf(address(this));
                require(
                    toSend == newBalance-currentBalance,
                    "Transfer failed"
                );
            }
            else {
                require(
                    msg.value == toSend, 
                    "Wrong ETH amount"
                );
            }
            fundedStatus[_contractId] = true;
            _contract.valueRemaining = toSend;
        }
        _contract.active = true;
        _contract.startBlock = block.timestamp;
    }

    /**
     * @notice Releases funds for a specific milestone in a contract
     * @param _contractId The ID of the contract containing the milestone
     * @param _milestoneId The ID of the milestone to release funds for
     */
    function releaseMilestone(
        uint256 _contractId, 
        uint256 _milestoneId
    ) public {
        Contract storage _contract = contracts[_contractId];

        require(
            _contract.active, 
            "Contract inactive"
        );
        require(
            _milestoneId < _contract.milestones.length, 
            "Out of bounds error"
        );
        require(
            msg.sender == _contract.payer || 
            msg.sender == _contract.payee,
            "Not a valid party of the contract"
        );
        require(
            !_contract.inDispute,
            "Contract in dispute"
        );
        
        Milestone storage milestone = _contract.milestones[_milestoneId];

        require(
            !milestone.inDispute,
            "Milestone in dispute"
        );
        require(
            !milestone.released, 
            "Milestone already released"
        );

        bool _payerSigned = payerSignedMilestone[_contractId][_milestoneId];
        bool _payeeSigned = payeeSignedMilestone[_contractId][_milestoneId];

        if (msg.sender == _contract.payer) {
            require(!_payerSigned, "Already signed this milestone");
            payerSignedMilestone[_contractId][_milestoneId] = true;
            _payerSigned = true;
        } else {
            require(!_payeeSigned, "Already signed this milestone");
            payeeSignedMilestone[_contractId][_milestoneId] = true;
            _payeeSigned = true;
        }

        if (_payerSigned && _payeeSigned) {
            milestone.released = true;

            _sendFunds(_contractId, _contract.payee, milestone.value);

            _contract.valueRemaining -= milestone.value;

            emit MilestoneReleased(
                _contractId,
                _contract.payer,
                _contract.payee,
                milestone.title
            );
        }
    }

    /**
     * @notice Initiates a dispute for a specific milestone within a contract
     * @param _contractId The ID of the contract containing the disputed milestone
     * @param _milestoneId The ID of the milestone to dispute
     */
    function disputeMilestone(
        uint256 _contractId, 
        uint256 _milestoneId
    ) public {
        Contract storage _contract = contracts[_contractId];

        require(
            msg.sender == _contract.payer ||
            msg.sender == _contract.payee,
            "Must be a valid party of the contract"
        );
        require(
            _contract.active,
            "Contract must be active"
        );
        require(
            _milestoneId < _contract.milestones.length, 
            "Out of bounds error"
        );
        require(
            !_contract.inDispute,
            "This contract is already in dispute"
        );
        Milestone[] storage _milestones = _contract.milestones;

        require(
            !_milestones[_milestoneId].inDispute,
            "Milestone is already in dispute"
        );

        _milestones[_milestoneId].inDispute = true;

        emit MilestoneDisputed(
            _contractId,
            _milestoneId
        );
    }

    /**
     * @notice Initiates a dispute for the entire contract
     * @param _contractId The ID of the contract to dispute
     */
    function disputeContract(
        uint256 _contractId
    ) public {
        Contract storage _contract = contracts[_contractId];

        require(
            msg.sender == _contract.payer ||
            msg.sender == _contract.payee,
            "Must be a valid party of the contract"
        );
        require(
            _contract.active,
            "Contract must be active"
        );
        require(
            _contract.valueRemaining > 0,
            "Contract empty"
        );
        require(
            !_contract.inDispute,
            "Contract already in dispute"
        );

        _contract.inDispute = true;

        emit ContractDisputed(
            _contractId
        );
    }

    /**
     * @notice Voids a contract by agreement of both parties
     * @param _contractId The ID of the contract to void
     */
    function voidContract(
        uint256 _contractId
    ) public {
        Contract storage _contract = contracts[_contractId];

        require(
            msg.sender == _contract.payer ||
            msg.sender == _contract.payee,
            "Must be a valid party of the contract"
        );

        bool _senderStatus = voidCheck[msg.sender][_contractId];
        require(
            !_senderStatus,
            "Already voided on your end"
        );

        voidCheck[msg.sender][_contractId] = true;

        if(
            !_contract.active && 
            msg.sender == _contract.payer
        ) {
            if(_contract.tokenAddress == address(0)) {
                payable(_contract.payer).transfer(_contract.valueRemaining);
                _contract.valueRemaining = 0;
            } else {
                IERC20(_contract.tokenAddress).transfer(_contract.payer, _contract.valueRemaining);
                _contract.valueRemaining = 0;
            }
            emit ContractVoided(_contractId);
        } 

        address _otherParty;

        if (msg.sender == _contract.payer) {
            _otherParty = _contract.payee;
        }
        else {
            _otherParty = _contract.payer;
        }

        bool _otherPartyStatus = voidCheck[_otherParty][_contractId];

        if (_otherPartyStatus) {
            if(_contract.tokenAddress == address(0)) {
                payable(_contract.payer).transfer(_contract.valueRemaining);
                _contract.valueRemaining = 0;
            } else {
                IERC20(_contract.tokenAddress).transfer(_contract.payer, _contract.valueRemaining);
                _contract.valueRemaining = 0;
            }
            emit ContractVoided(_contractId);
        }
    }
}