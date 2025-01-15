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

// File: InheritanceContract.sol


pragma solidity ^0.8.17;




interface IInheritanceFactory {
    function registerBeneficiary(address beneficiary, address contractAddress) external;
    function unregisterBeneficiary(address beneficiary, address contractAddress) external;
}

contract InheritanceContract is ReentrancyGuard {
    // Contract owner (person setting up the inheritance)
    address public owner;

    // Developer address to receive the developer fee
    address public immutable developer;

    // Constants
    uint256 public constant EXECUTOR_FEE_BPS = 100; // 1%
    uint256 public constant DEVELOPER_FEE_BPS = 10; // 0.1%
    uint256 public constant TOTAL_SHARES = 10000; // 100%


    // Inactivity period after which inheritance can be claimed (in seconds)
    uint256 public inactivityPeriod;

    // Grace period after inactivity period during which only beneficiaries can initiate distribution
    uint256 public gracePeriod;

    // Timestamp of the last activity by the owner
    uint256 public lastActiveTimestamp;

    // Flag indicating whether assets have been distributed
    bool public isDistributed;

    // Total shares allocated to beneficiaries
    uint256 public totalSharesAllocated;

    // Beneficiaries and their shares in basis points
    struct Beneficiary {
        address beneficiaryAddress;
        uint256 share; // Share in basis points (e.g., 1250 for 12.5%)
    }

    Beneficiary[] public beneficiaries;
    mapping(address => uint256) private beneficiaryIndices; // Mapping to indices (index + 1)

    // List of ERC20 tokens deposited
    address[] public depositedTokens;
    mapping(address => bool) private isTokenDeposited;

    // Events
    event Heartbeat(address indexed owner, uint256 timestamp);
    event AssetsDeposited(address indexed depositor, uint256 amount, address tokenAddress);
    event InheritanceDistributed(address indexed initiator, bool isBeneficiary, uint256 executorFeeEther);
    event BeneficiaryAdded(address indexed beneficiary, uint256 share);
    event BeneficiaryRemoved(address indexed beneficiary);
    event AssetsWithdrawn(address indexed owner, uint256 amount, address tokenAddress);

    // Modifiers
    modifier onlyOwnerAndUpdateHeartbeat() {
        require(msg.sender == owner, "Only owner can call");
        lastActiveTimestamp = block.timestamp;
        emit Heartbeat(msg.sender, lastActiveTimestamp);
        _;
    }

    modifier updateHeartbeatIfOwner() {
        if (msg.sender == owner) {
            lastActiveTimestamp = block.timestamp;
            emit Heartbeat(msg.sender, lastActiveTimestamp);
        }
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function!");
        _;
    }

    modifier onlyNotDistributed() {
        require(!isDistributed, "Assets already distributed");
        _;
    }

    IInheritanceFactory public factory;

    constructor(
        address _owner,
        address[] memory _beneficiaryAddresses,
        uint256[] memory _shares, // Shares in basis points
        uint256 _inactivityPeriod,
        uint256 _gracePeriod,
        address _developer,
        address _factoryAddress // Factory address

    ) payable {
        require(_beneficiaryAddresses.length == _shares.length, "Mismatched beneficiaries and shares");
        require(_beneficiaryAddresses.length > 0, "At least one beneficiary required");
        require(_inactivityPeriod > 0, "Inactivity period must be > 0");

        totalSharesAllocated = 0;
        for (uint256 i = 0; i < _shares.length; i++) {
            uint256 share = _shares[i];
            address beneficiaryAddress = _beneficiaryAddresses[i];

            require(share > 0 && share <= TOTAL_SHARES, "Invalid share amount");
            require(beneficiaryAddress != address(0), "Invalid beneficiary address");
            require(beneficiaryIndices[beneficiaryAddress] == 0, "Beneficiary already exists");

            totalSharesAllocated += share;

            beneficiaries.push(Beneficiary({
                beneficiaryAddress: beneficiaryAddress,
                share: share
            }));

            beneficiaryIndices[beneficiaryAddress] = beneficiaries.length; // Index + 1 to avoid default 0 value

            emit BeneficiaryAdded(beneficiaryAddress, share);
        }
        require(totalSharesAllocated == TOTAL_SHARES, "Total shares must equal 10000 (100%)");

        owner = _owner;
        developer = _developer;
        inactivityPeriod = _inactivityPeriod;
        gracePeriod = _gracePeriod;
        lastActiveTimestamp = block.timestamp;
        factory = IInheritanceFactory(_factoryAddress);


        // Handle Ether sent during contract creation
        if (msg.value > 0) {
            uint256 developerFee = (msg.value * DEVELOPER_FEE_BPS) / TOTAL_SHARES; // 0.1%
            payable(developer).transfer(developerFee);
            emit AssetsDeposited(msg.sender, msg.value, address(0));
        }
    }

    function heartbeat() external onlyOwner onlyNotDistributed {
         lastActiveTimestamp = block.timestamp;
         emit Heartbeat(msg.sender, lastActiveTimestamp);
     }

    // Function to deposit Ether into the contract
    function depositEther() external payable onlyNotDistributed updateHeartbeatIfOwner {
        require(msg.value > 0, "Must send Ether");
        uint256 developerFee = (msg.value * DEVELOPER_FEE_BPS) / TOTAL_SHARES; // 0.1%
        payable(developer).transfer(developerFee);
        emit AssetsDeposited(msg.sender, msg.value, address(0));
    }

    // Function to deposit ERC20 tokens into the contract
    function depositERC20(IERC20 token, uint256 amount) external onlyNotDistributed updateHeartbeatIfOwner {
        require(amount > 0, "Amount must be > 0");
        address tokenAddress = address(token);

        // Transfer tokens from sender to contract
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Deduct developer fee
        uint256 developerFee = (amount * DEVELOPER_FEE_BPS) / TOTAL_SHARES; // 0.1%
        require(token.transfer(developer, developerFee), "Developer fee transfer failed");

        emit AssetsDeposited(msg.sender, amount, tokenAddress);

        // Track deposited tokens
        if (!isTokenDeposited[tokenAddress]) {
            isTokenDeposited[tokenAddress] = true;
            depositedTokens.push(tokenAddress);
        }
    }

    // Function to distribute inheritance
    function distributeInheritance() external nonReentrant onlyNotDistributed {
        require(block.timestamp >= lastActiveTimestamp + inactivityPeriod, "Inactivity period not passed");

        bool callerIsBeneficiary = isBeneficiary(msg.sender);
        uint256 executorFeeEther = 0;
        isDistributed = true;


        if (callerIsBeneficiary) {
            // Beneficiary can call immediately after inactivity period
            // No executor fee applied
        } else {
            // Executor can call only after grace period
            require(block.timestamp >= lastActiveTimestamp + inactivityPeriod + gracePeriod, "Grace period not passed");
            // Calculate executor fee for Ether
            executorFeeEther = (address(this).balance * EXECUTOR_FEE_BPS) / TOTAL_SHARES;
            if (executorFeeEther > 0) {
                payable(msg.sender).transfer(executorFeeEther);
            }
        }

        // Distribute Ether
        uint256 totalEther = address(this).balance;
        if (totalEther > 0) {
            uint256 etherToDistribute = totalEther - executorFeeEther;
            for (uint256 i = 0; i < beneficiaries.length; i++) {
                Beneficiary memory beneficiary = beneficiaries[i];
                uint256 amount = (etherToDistribute * beneficiary.share) / TOTAL_SHARES;
                if (amount > 0) {
                    payable(beneficiary.beneficiaryAddress).transfer(amount);
                }
            }
        }

        // Distribute ERC20 tokens
        for (uint256 i = 0; i < depositedTokens.length; i++) {
            address tokenAddress = depositedTokens[i];
            IERC20 token = IERC20(tokenAddress);
            uint256 totalTokenBalance = token.balanceOf(address(this));

            uint256 executorFeeToken = 0;

            if (totalTokenBalance > 0) {
                if (!callerIsBeneficiary) {
                    // Apply executor fee
                    executorFeeToken = (totalTokenBalance * EXECUTOR_FEE_BPS) / TOTAL_SHARES;
                    require(token.transfer(msg.sender, executorFeeToken), "Executor fee token transfer failed");
                }

                uint256 tokensToDistribute = totalTokenBalance - executorFeeToken;

                for (uint256 j = 0; j < beneficiaries.length; j++) {
                    Beneficiary memory beneficiary = beneficiaries[j];
                    uint256 amount = (tokensToDistribute * beneficiary.share) / TOTAL_SHARES;
                    if (amount > 0) {
                        require(token.transfer(beneficiary.beneficiaryAddress, amount), "Token transfer failed");
                    }
                }
            }
        }

        emit InheritanceDistributed(msg.sender, callerIsBeneficiary, executorFeeEther);
    }

    // Function to allow the owner to withdraw Ether
    function withdrawEther(uint256 amount) external onlyOwnerAndUpdateHeartbeat onlyNotDistributed nonReentrant {
        require(amount > 0, "Amount must be > 0");
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
        emit AssetsWithdrawn(owner, amount, address(0));
    }

    // Function to withdraw ERC20 tokens
    function withdrawERC20(IERC20 token, uint256 amount) external onlyOwnerAndUpdateHeartbeat onlyNotDistributed nonReentrant {
        require(amount > 0, "Amount must be > 0");
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(token.transfer(owner, amount), "Token transfer failed");
        emit AssetsWithdrawn(owner, amount, address(token));
    }

    // Function to add a beneficiary with automatic proportional adjustment
    function addBeneficiary(address _beneficiaryAddress, uint256 _share) external onlyOwnerAndUpdateHeartbeat onlyNotDistributed {
        require(_beneficiaryAddress != address(0), "Invalid address");
        require(_share > 0 && _share <= TOTAL_SHARES, "Invalid share amount");
        require(!isBeneficiary(_beneficiaryAddress), "Beneficiary exists");

        uint256 remainingShares = TOTAL_SHARES - _share;

        // Adjust existing beneficiaries' shares proportionally
        if (totalSharesAllocated > 0) {
            for (uint256 i = 0; i < beneficiaries.length; i++) {
                Beneficiary storage beneficiary = beneficiaries[i];
                beneficiary.share = (beneficiary.share * remainingShares) / totalSharesAllocated;
            }
        }

        // Add new beneficiary
        beneficiaries.push(Beneficiary({
            beneficiaryAddress: _beneficiaryAddress,
            share: _share
        }));

        beneficiaryIndices[_beneficiaryAddress] = beneficiaries.length; // Index + 1
        totalSharesAllocated = TOTAL_SHARES;

        // Handle rounding errors
        uint256 adjustedSharesSum = 0;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            adjustedSharesSum += beneficiaries[i].share;
        }

        if (adjustedSharesSum < TOTAL_SHARES) {
            beneficiaries[beneficiaries.length - 1].share += (TOTAL_SHARES - adjustedSharesSum);
        }

        // Register the new beneficiary with the factory
        factory.registerBeneficiary(_beneficiaryAddress, address(this));

        emit BeneficiaryAdded(_beneficiaryAddress, _share);
    }

    // Override removeBeneficiary function to notify the factory
    function removeBeneficiary(address _beneficiaryAddress) external onlyOwnerAndUpdateHeartbeat onlyNotDistributed {
        uint256 indexPlusOne = beneficiaryIndices[_beneficiaryAddress];
        require(indexPlusOne > 0, "Beneficiary does not exist");

        uint256 index = indexPlusOne - 1;
        uint256 removedShare = beneficiaries[index].share;

        // Remove beneficiary
        beneficiaries[index] = beneficiaries[beneficiaries.length - 1];
        beneficiaryIndices[beneficiaries[index].beneficiaryAddress] = indexPlusOne; // Update index mapping
        beneficiaries.pop();
        delete beneficiaryIndices[_beneficiaryAddress];

        totalSharesAllocated -= removedShare;

        uint256 remainingTotalShares = totalSharesAllocated;

        if (remainingTotalShares > 0) {
            // Adjust remaining beneficiaries' shares proportionally
            for (uint256 i = 0; i < beneficiaries.length; i++) {
                Beneficiary storage beneficiary = beneficiaries[i];
                beneficiary.share = (beneficiary.share * TOTAL_SHARES) / remainingTotalShares;
            }
            totalSharesAllocated = TOTAL_SHARES;

            // Handle rounding errors
            uint256 adjustedSharesSum = 0;
            for (uint256 i = 0; i < beneficiaries.length; i++) {
                adjustedSharesSum += beneficiaries[i].share;
            }

            if (adjustedSharesSum < TOTAL_SHARES) {
                beneficiaries[beneficiaries.length - 1].share += (TOTAL_SHARES - adjustedSharesSum);
            }
        }

        // Unregister the beneficiary from the factory
        factory.unregisterBeneficiary(_beneficiaryAddress, address(this));

        emit BeneficiaryRemoved(_beneficiaryAddress);
    }
    
    // Function to check if an address is a beneficiary
    function isBeneficiary(address _address) public view returns (bool) {
        return beneficiaryIndices[_address] != 0;
    }

    function getAllBeneficiaries() external view returns (Beneficiary[] memory) {
        return beneficiaries;
    }

    // Function to update inactivity period
    function updateInactivityPeriod(uint256 _newPeriod) external onlyOwnerAndUpdateHeartbeat onlyNotDistributed {
        require(_newPeriod > 0, "Inactivity period must be > 0");
        inactivityPeriod = _newPeriod;
    }

    // Function to update grace period
    function updateGracePeriod(uint256 _newGracePeriod) external onlyOwnerAndUpdateHeartbeat onlyNotDistributed {
        gracePeriod = _newGracePeriod;
    }

    function getDepositedTokens() external view returns (address[] memory) {
        return depositedTokens;
    }

    // Fallback function to accept Ether
    receive() external payable {
        // Apply developer fee
        uint256 developerFee = (msg.value * DEVELOPER_FEE_BPS) / TOTAL_SHARES; // 0.1%
        payable(developer).transfer(developerFee);
        emit AssetsDeposited(msg.sender, msg.value, address(0));

        // Update heartbeat if sender is owner
        if (msg.sender == owner) {
            lastActiveTimestamp = block.timestamp;
            emit Heartbeat(msg.sender, lastActiveTimestamp);
        }
    }
}

// File: InheritanceFactory.sol


pragma solidity ^0.8.17;


contract InheritanceFactory {
    // Developer address to receive developer fees
    address public immutable developer;

    // Array to store all deployed inheritance contracts
    address[] public allInheritanceContracts;

    // Mapping to store valid inheritance contracts
    mapping(address => bool) public validContracts;

    // Mapping from owner to their inheritance contracts
    mapping(address => address[]) public ownerToContracts;

    // Mapping from beneficiary address to their inheritance contracts
    mapping(address => address[]) public beneficiaryToContracts;

    // Event emitted when a new inheritance contract is created
    event InheritanceContractCreated(address indexed owner, address inheritanceContract);
    event BeneficiaryRegistered(address indexed beneficiary, address indexed inheritanceContract);
    event BeneficiaryUnregistered(address indexed beneficiary, address indexed inheritanceContract);


    constructor() {
        developer = msg.sender;
    }

    // Function to create a new inheritance contract
    function createInheritanceContract(
        address _owner,
        address[] calldata _beneficiaryAddresses,
        uint256[] calldata _shares,
        uint256 _inactivityPeriod,
        uint256 _gracePeriod
    ) external payable returns (address) {
        InheritanceContract inheritanceContract = (new InheritanceContract){value: msg.value}(
            _owner,
            _beneficiaryAddresses,
            _shares,
            _inactivityPeriod,
            _gracePeriod,
            developer,
            address(this)
        );

        address contractAddress = address(inheritanceContract);
        allInheritanceContracts.push(contractAddress);
        ownerToContracts[msg.sender].push(contractAddress);
        validContracts[contractAddress] = true;

        // Register each beneficiary in the factory's mapping
        for (uint256 i = 0; i < _beneficiaryAddresses.length; i++) {
            beneficiaryToContracts[_beneficiaryAddresses[i]].push(contractAddress);
            emit BeneficiaryRegistered(_beneficiaryAddresses[i], contractAddress);
        }

        emit InheritanceContractCreated(msg.sender, contractAddress);

        return contractAddress;
    }

    // Function to get the number of inheritance contracts created
    function getInheritanceContractCount() external view returns (uint256) {
        return allInheritanceContracts.length;
    }

    // Function to get inheritance contracts by owner
    function getContractsByOwner(address _owner) external view returns (address[] memory) {
        return ownerToContracts[_owner];
    }

    // Function to get inheritance contracts by beneficiary
    function getContractsByBeneficiary(address _beneficiary) external view returns (address[] memory) {
        return beneficiaryToContracts[_beneficiary];
    }

    // Register a beneficiary (called by InheritanceContract)
    function registerBeneficiary(address _beneficiary, address _contract) external {
        require(validContracts[_contract], "Unauthorized contract");
        require(msg.sender == _contract, "Only contract can register beneficiaries");
        beneficiaryToContracts[_beneficiary].push(_contract);
        emit BeneficiaryRegistered(_beneficiary, _contract);
    }

    // Unregister a beneficiary (called by InheritanceContract)
    function unregisterBeneficiary(address _beneficiary, address _contract) external {
        require(validContracts[_contract], "Unauthorized contract");
        require(msg.sender == _contract, "Only contract can unregister beneficiaries");

        address[] storage contracts = beneficiaryToContracts[_beneficiary];
        for (uint256 i = 0; i < contracts.length; i++) {
            if (contracts[i] == _contract) {
                contracts[i] = contracts[contracts.length - 1];
                contracts.pop();
                break;
            }
        }
        emit BeneficiaryUnregistered(_beneficiary, _contract);
    }

}