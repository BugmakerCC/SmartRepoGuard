// Sources flattened with hardhat v2.22.6 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/access/Ownable.sol

// Original license: SPDX_License_Identifier: MIT
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


// File node_modules/@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol@v1.1.1

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}


// File openzeppelin-contracts-release-v4.9/contracts/security/ReentrancyGuard.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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


// File contracts/PresaleContract.sol

/**
 * @dev The `PresaleContract` is a comprehensive smart contract designed to manage the presale of SyntraCoin, a custom ERC20 token.
 * The contract facilitates multiple rounds of token sales, distributes tokens to participants, manages advisor commissions,
 * and handles the deployment of a Uniswap V3 liquidity pool upon the presale's conclusion. It also includes robust mechanisms
 * for emergency handling, participant refunds, and owner-controlled operations.
 *
 * **Key Features:**
 * 
 * 1. **Token Sale Management:**
 *    - The presale is divided into four rounds, each with increasing token prices and specific token limits.
 *    - Participants can purchase tokens using ETH, and the contract automatically handles ETH-to-USD conversions using Chainlink price feeds.
 *    - The contract tracks token purchases and ETH contributions per participant, ensuring correct token distribution once the presale ends.
 *    - The presale process is time-bound with a global timer, and it automatically progresses through the rounds as tokens are sold.
 * 
 * 2. **Discount Management:**
 *    - The contract includes a refund mechanism where participants can receive a 10% refund of their ETH contribution if they are referred by a valid advisor.
 *    - This discount is applied automatically during the purchase process, reducing the total ETH collected by the contract.
 * 
 * 3. **Investor Rights:**
 *    - Participants are entitled to receive the tokens they purchased once the presale concludes.
 *    - Investors can monitor their spending and token allocation via the contract's public functions.
 * 
 * 4. **Advisor Rights:**
 *    - Advisors can refer participants to the presale and earn a 10% commission on the ETH contributions made by their referred participants.
 *    - Advisors must be added by the contract owner to be eligible for commissions.
 *    - The contract automatically distributes the advisor’s commission during the purchase process.
 * 
 * 5. **Team Rights:**
 *    - The team (represented by the contract owner) receives 20% of the ETH collected from token sales and computer purchases as compensation.
 *    - The contract ensures that the team's share is transferred immediately during each purchase transaction.
 *    - The team has the right to withdraw remaining funds after the presale concludes, provided the withdrawal conditions are met.
 * 
 * 6. **Ownership and Control (OnlyOwner Functions):**
 *    - The contract is owned by a single entity (the owner), who has the authority to perform critical actions:
 *      - Add or remove advisors.
 *      - Initiate emergency withdrawals if the presale encounters issues.
 *      - Deploy the SyntraCoin token and create the Uniswap V3 liquidity pool.
 *      - Manage the transition from the presale to the post-sale phase, including token minting and fund management.
 *    - The `onlyOwner` modifier restricts sensitive functions to the contract owner, ensuring that only authorized personnel can execute these functions.
 * 
 * 7. **Emergency Handling and Refunds:**
 *    - The contract includes mechanisms to handle emergencies and ensure the safety of participant funds.
 *    - If the contract fails to safely deploy the SyntraCoin token and liquidity pool, it enters an emergency withdrawal mode.
 *    - In emergency mode, the owner can withdraw the remaining funds to prevent loss.
 *
 * The `PresaleContract` is a versatile and secure solution for managing the complexities of a token presale, offering various roles and rights 
 * to participants, advisors, and the project team while ensuring that funds are handled securely and transparently.
 */

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.15;

// Importing necessary contracts and interfaces

/// @custom:security-contact admin@syntralink.net 

// Interface for the Uniswap and Coin Manager contract
interface IUniswapAndCoinManager {
    function deployCoinAndPool(uint256 ethForPool) external payable;
    function mintTokens(address participant, uint256 amount) external;
    function coinAddress() external view returns (address);
}

// Main contract for managing the presale
contract PresaleContract is Ownable, ReentrancyGuard {

    // Enum utilized in order to assign the computer types
    enum ComputerType {
    Triton, 
    Hyperion, 
    Nyx, 
    Hecate
    }

    IUniswapAndCoinManager public immutable _uniswapAndCoinManager; // @dev Interface for interacting with the Uniswap and Coin Manager contract
    AggregatorV3Interface internal immutable _priceFeed; // @dev Interface for interacting with the Chainlink price feed
    uint256 public constant DECIMALS = 1e18; // @dev The number of decimal places for tokens
    uint256 public constant TOTAL_TOKENS = 40e6 * DECIMALS; // 40 million tokens
    uint256 public constant BASE_TRITON_PRICE = 9e5; // @dev Base price for the Triton computer in USD cents
    uint256 public constant BASE_HYPERION_PRICE = 9.3e5; // @dev Base price for the Hyperion computer in USD cents
    uint256 public constant BASE_NYX_PRICE = 2.4e5; // @dev Base price for the Nyx computer in USD cents
    uint256 public constant BASE_HECATE_PRICE = 4.5e5; // @dev Base price for the Hecate computer in USD cents
    uint256 public constant GLOBAL_TIMER = 604800 * 26; // @dev Duration of the presale in seconds (26 weeks)
    uint256 public constant MAX_ROUND = 3; // @dev Maximum number of rounds in the presale
    uint256 public constant ADVISOR_PERCENTAGE = 10; // @dev Percentage of ETH that advisors receive from referrals
    uint256 public constant REFUND_PERCENTAGE = 10; // @dev Percentage of ETH refunded to participants referred by an advisor
    uint256 public constant TEAM_PERCENTAGE = 20; // @dev Percentage of ETH allocated to the team
    uint256 public constant PERCENTAGE_BASE = 100; // @dev Base value for percentage calculations
    uint256[4] public _roundPrices = [10, 15, 20, 25]; // @dev Prices per token for each presale round in USD cents
    uint256[4] public _roundTokenLimits = [
        4e6 * DECIMALS, // @dev Token limit for round 1
        8e6 * DECIMALS, // @dev Token limit for round 2
        12e6 * DECIMALS, // @dev Token limit for round 3
        16e6 * DECIMALS // @dev Token limit for round 4
    ];
    uint256 public _currentRound = 0; // @dev Current presale round
    uint256 public _totalTokensSold; // @dev Total tokens sold during the presale
    uint256 public _totalEthSpentInComputers; // @dev Total ETH spent on computer purchases
    uint256 public _presaleStartedAt; // @dev Timestamp when the presale started
    uint256 public teamTotalVestedEth; // Total ETH allocated to the team for vesting
    uint256 public teamEthWithdrawn;   // Total ETH withdrawn by the team so far
    uint256 public teamEthVestingStartTime; // Timestamp when ETH vesting starts
    uint256 public constant TEAM_ETH_VESTING_DURATION = 2 * 365 days; // Vesting duration of 2 years

    mapping(address => uint256) public _computerTritonPurchases; // @dev Tracks Triton computer purchases per address
    mapping(address => uint256) public _computerHyperionPurchases; // @dev Tracks Hyperion computer purchases per address
    mapping(address => uint256) public _computerNyxPurchases; // @dev Tracks Nyx computer purchases per address
    mapping(address => uint256) public _computerHecatePurchases; // @dev Tracks Hecate computer purchases per address
    mapping(address => uint256) public _tokenPurchases; // @dev Tracks token purchases per address
    mapping(uint256 => uint256) public _tokensSoldPerRound; // @dev Tracks tokens sold per round
    mapping(address => address) private _advisorForParticipant; // @dev Maps participants to their advisors
    mapping(address => mapping(uint256 => uint256)) public _tokensSoldPerRoundByAddress; // @dev Tracks tokens sold per round by address
    mapping(address => mapping(uint256 => uint256)) public totalTokensEthSpentByUserInARound; 
    mapping(address => uint256) public totalSpent; // @dev Tracks total amount spent per participant
    mapping(address => bool) private _validAdvisors; // @dev Tracks valid advisors
    mapping(address => bool) public isAParticipant; // @dev Tracks if an user interacted with this contract
    address[] public _participants; // @dev List of all participants in the presale
    event AdvisorAdded(address indexed advisor); // @dev Event for when an advisor is added
    event AdvisorRemoved(address indexed advisor); // @dev Event for when an advisor is removed
    event ComputerPurchased(address indexed buyer, uint256 indexed amount, uint256 indexed ethSpent, ComputerType); // @dev Event for computer purchases
    event RoundAdvanced(uint256 indexed newRound); // @dev Event for when the presale advances to a new round
    event AddressRefunded(address indexed purchaser, uint256 indexed amount); // @dev Event for when a participant is refunded
    event TokenPurchased(address indexed purchaser, uint256 amount, uint256 ethSpent);
    event OwnerFundsTransferred(uint256 amount, uint256 timestamp);
    event TeamEthWithdrawn(uint256 amount, uint256 timestamp);

    bool public _isInEmergencyWithdraw; // @dev Flag indicating if the contract is in emergency withdrawal mode 

 
    /** 
     * @notice Constructor for initializing the PresaleContract
     * @param uniswapAndCoinManager_ - Address of the Uniswap and Coin Manager contract
     */
    constructor(address uniswapAndCoinManager_) Ownable() {
        require(uniswapAndCoinManager_ != address(0), "Invalid address"); // @dev Ensure the Uniswap and Coin Manager address is valid
        _uniswapAndCoinManager = IUniswapAndCoinManager(uniswapAndCoinManager_); // @dev Set the Uniswap and Coin Manager contract
        _priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // @dev Set the Chainlink price feed contract
        _presaleStartedAt = block.timestamp; // @dev Record the start time of the presale
        teamEthVestingStartTime = block.timestamp; // Initialize ETH vesting start time
    }

    /**
     * @notice Function to add an advisor, only callable by the contract owner
     * @param advisor - The address of the advisor to be added
     */
     function addAdvisor(address advisor) external onlyOwner {
        require(advisor != address(0), "Invalid address"); // @dev Ensure the advisor address is not the zero address
        require(!_validAdvisors[advisor], "Advisor already added"); // @dev Ensure the advisor is not already added
        _validAdvisors[advisor] = true; // @dev Mark the advisor as valid
        emit AdvisorAdded(advisor); // @dev Emit an event for the added advisor
    }

    /**
     * @notice Function to remove an advisor, only callable by the contract owner
     * @param advisor - The address of the advisor to be removed
     */
    function removeAdvisor(address advisor) external onlyOwner {
        require(advisor != address(0), "Invalid address"); // @dev Ensure the advisor address is not the zero address
        require(_validAdvisors[advisor], "Advisor not found"); // @dev Ensure the advisor exists in the list
        _validAdvisors[advisor] = false; // @dev Mark the advisor as invalid
        emit AdvisorRemoved(advisor); // @dev Emit an event for the removed advisor
    }

    /**
     * @dev Internal function to handle the purchase of computers
     * @param amount - The number of computers being purchased
     * @param totalPrice - The total ETH value for the purchase
     * @param purchases - The mapping that tracks purchases by address
     * @param computerType - The type of computer being purchased
     * @param advisor - The address of the advisor
     */
    function _purchaseComputer(
        uint256 amount,
        uint256 totalPrice,
        mapping(address => uint256) storage purchases,
        ComputerType computerType,
        address advisor
    ) internal {
        require(amount > 0, "Amount must be greater than 0"); // @dev Ensure the purchase amount is greater than 0
        require(msg.value == totalPrice, "Incorrect ETH sent"); // @dev Ensure the correct amount of ETH is sent
        uint256 teamShare = totalPrice; // @dev Initialize the team share to the full amount
        uint256 advisorShare; // @dev Initialize the advisor share to 0
        uint256 refundToSender; // @dev Initialize the refund to the sender to 0

        if (advisor != address(0) && _validAdvisors[advisor]) {
            refundToSender = (totalPrice * REFUND_PERCENTAGE) / PERCENTAGE_BASE; // @dev Calculate the refund to the sender
            advisorShare = (totalPrice * ADVISOR_PERCENTAGE) / PERCENTAGE_BASE; // @dev Calculate the advisor's share
            teamShare = totalPrice - refundToSender - advisorShare; // @dev Calculate the remaining share for the team
        } else if (advisor != address(0) && !_validAdvisors[advisor]) {
            revert("Invalid advisor address"); // @dev Revert if the advisor is invalid
        }

        purchases[msg.sender] += amount; // @dev Update the purchase record for the sender
        _totalEthSpentInComputers += msg.value; // @dev Update the total ETH spent on computers
        totalSpent[msg.sender] += msg.value; // @dev Update the total amount spent by the participant 
        if(!isAParticipant[msg.sender]){
        _participants.push(msg.sender); // @dev Add the participant to the list of participants if needed
        isAParticipant[msg.sender] = true; // @dev Assigns the user as a participant if needed
        }
        emit ComputerPurchased(msg.sender, amount, msg.value, computerType); // @dev Emit an event for the computer purchase

        (bool successTeam, ) = payable(owner()).call{value: teamShare}(""); // @dev Transfer the team's share to the owner
        require(successTeam, "Transfer to team failed"); // @dev Ensure the transfer to the team was successful
        if (advisorShare > 0) {
            (bool successAdvisor, ) = payable(advisor).call{value: advisorShare}(""); // @dev Transfer the advisor's share
            require(successAdvisor, "Transfer to advisor failed"); // @dev Ensure the transfer to the advisor was successful
        }
        if (refundToSender > 0) {
            (bool successRefund, ) = payable(msg.sender).call{value: refundToSender}(""); // @dev Refund the sender
            require(successRefund, "Refund to sender failed"); // @dev Ensure the refund to the sender was successful
        }
    }

    /**
     * @notice Function to purchase Triton computers during the presale
     * @param amount - The number of Triton computers to purchase
     * @param advisor - The address of the advisor
     */

    function purchaseTriton(uint256 amount, address advisor) external payable nonReentrant {
        _purchaseComputer(
            amount,
            purchaseTriton_price(amount),
            _computerTritonPurchases,
            ComputerType.Triton,
            advisor
        ); // @dev Call the internal function to handle the Triton purchase
    }

    /**
     * @notice Function to purchase Hyperion computers during the presale
     * @param amount - The number of Hyperion computers to purchase
     * @param advisor - The address of the advisor
     */
    function purchaseHyperion(uint256 amount, address advisor) external payable nonReentrant {
        _purchaseComputer(
            amount,
            purchaseHyperion_price(amount),
            _computerHyperionPurchases,
            ComputerType.Hyperion,
            advisor
        ); // @dev Call the internal function to handle the Hyperion purchase
    }

    /** 
     * @notice Function to purchase Nyx computers during the presale
     * @param amount - The number of Nyx computers to purchase
     * @param advisor - The address of the advisor
     */
    function purchaseNyx(uint256 amount, address advisor) external payable nonReentrant {
        _purchaseComputer(
            amount,
            purchaseNyx_price(amount),
            _computerNyxPurchases,
            ComputerType.Nyx,
            advisor
        ); // @dev Call the internal function to handle the Nyx purchase
    }

    /**
     * @notice Function to purchase Hecate computers during the presale
     * @param amount - The number of Hecate computers to purchase
     * @param advisor - The address of the advisor
     */
    function purchaseHecate(uint256 amount, address advisor) external payable nonReentrant {
        _purchaseComputer(
            amount,
            purchaseHecate_price(amount),
            _computerHecatePurchases,
            ComputerType.Hecate,
            advisor
        ); // @dev Call the internal function to handle the Hecate purchase
    }

    /**
     * @dev View function to calculate the ETH price for purchasing Triton computers
     * @param amount - The number of Triton computers to purchase
     * @return The total ETH required to purchase the specified number of Triton computers
     */
    function purchaseTriton_price(uint256 amount) public view returns (uint256) {
        return _convertUSDtoETH(BASE_TRITON_PRICE) * amount; // @dev Convert the USD price to ETH
    }

    /**
     * @dev View function to calculate the ETH price for purchasing Hyperion computers
     * @param amount - The number of Hyperion computers to purchase
     * @return The total ETH required to purchase the specified number of Hyperion computers
     */
    function purchaseHyperion_price(uint256 amount) public view returns (uint256) {
        return _convertUSDtoETH(BASE_HYPERION_PRICE) * amount; // @dev Convert the USD price to ETH
    }

    /**
     * @dev View function to calculate the ETH price for purchasing Nyx computers
     * @param amount - The number of Nyx computers to purchase
     * @return The total ETH required to purchase the specified number of Nyx computers
     */
    function purchaseNyx_price(uint256 amount) public view returns (uint256) {
        return _convertUSDtoETH(BASE_NYX_PRICE) * amount; // @dev Convert the USD price to ETH
    }

    /**
     * @dev View function to calculate the ETH price for purchasing Hecate computers
     * @param amount - The number of Hecate computers to purchase
     * @return The total ETH required to purchase the specified number of Hecate computers
     */
    function purchaseHecate_price(uint256 amount) public view returns (uint256) {
        return _convertUSDtoETH(BASE_HECATE_PRICE) * amount; // @dev Convert the USD price to ETH
    }

    /**
     * @dev View function to get the latest ETH/USD price from the Chainlink price feed
     * @return The latest ETH/USD price in USD
     */
    function _getLatestETHUSDPrice() public view returns (int) {
        (, int answer, , , ) = _priceFeed.latestRoundData(); // @dev Get the latest price data from Chainlink
        return answer / 1e8; // @dev Return the price scaled down to avoid floating point errors
    }

    /**
     * @dev View function to convert a USD amount to ETH based on the latest price feed data
     * @param amountInUSDCents - The amount in USD cents to convert
     * @return The equivalent amount in ETH
     */
    function _convertUSDtoETH(uint256 amountInUSDCents) public view returns (uint256) {
        uint256 currentETHPrice = uint256(_getLatestETHUSDPrice()); // @dev Get the current ETH/USD price
        uint256 result = ((amountInUSDCents * 1e16) / currentETHPrice); // @dev Convert USD to ETH
        return result; // @dev Return the converted amount in ETH
    }

    /** 
     * @notice Function to purchase tokens during the presale
     * @param amount - The number of tokens to purchase
     * @param advisor - The address of the advisor
     */
    function purchaseToken(uint256 amount, address advisor) external payable nonReentrant {
        require(amount > 0, "Amount must be greather than 0"); // @dev Ensure the purchase amount is always greater than 0
        require(amount <= _getCurrentRoundTokensRemaining(), "Can't exceed the actual round");
        if(_getCurrentRoundTokensRemaining() > 1e18){
        require(amount >= 1e18, "Amount must be greater than 1e18"); // @dev Ensure the purchase amount is greater than 0 if needed
        }
        if(_totalTokensSold + amount > TOTAL_TOKENS || block.timestamp > _presaleStartedAt + GLOBAL_TIMER) {
            revert("Presale is finished"); // @dev ensure that the presale is not finished
        }
        uint256 price = purchaseToken_price(amount); // @dev Calculate the total price in ETH
        require(msg.value == price, "Incorrect ETH sent"); // @dev Ensure the correct amount of ETH is sent
        uint256 teamShare = (price * TEAM_PERCENTAGE) / PERCENTAGE_BASE; // @dev Calculate the team's share
        uint256 advisorShare; // @dev Initialize the advisor's share to 0
        uint256 refundToSender; // @dev Initialize the refund to the sender to 0
        if (advisor != address(0) && _validAdvisors[advisor]) {
            refundToSender = (price * REFUND_PERCENTAGE) / PERCENTAGE_BASE; // @dev Calculate the refund to the sender
            advisorShare = (price * ADVISOR_PERCENTAGE) / PERCENTAGE_BASE; // @dev Calculate the advisor's share
            _advisorForParticipant[msg.sender] = advisor; // @dev Set the advisor for the participant
        }
        _totalTokensSold += amount; // @dev Update the total tokens sold 
        _tokensSoldPerRound[_currentRound] += amount; // @dev Update the tokens sold in the current round
        _tokenPurchases[msg.sender] += amount; // @dev Update the token purchase record
        _tokensSoldPerRoundByAddress[msg.sender][_currentRound] += amount; // @dev Update the tokens sold by address in the current round
        totalTokensEthSpentByUserInARound[msg.sender][_currentRound] += msg.value; // @dev Update the ETH spent by address in the current round
        totalSpent[msg.sender] += msg.value; // @dev Update the total amount spent by the participant
        teamTotalVestedEth += teamShare; // Accumulate the team's ETH share for vesting
        if(!isAParticipant[msg.sender]){
        _participants.push(msg.sender); // @dev Add the participant to the list of participants if needed
        isAParticipant[msg.sender] = true; // @dev Assigns the user as a participant if needed
        }
        emit TokenPurchased(msg.sender, amount, msg.value); // @dev Emit an event for the token purchase
        _updateRoundProgress(); // @dev Update the round progress based on the purchase

        if (refundToSender > 0) {
            (bool successRefund, ) = payable(msg.sender).call{value: refundToSender}(""); // @dev Refund the sender
            require(successRefund, "Refund to sender failed"); // @dev Ensure the refund to the sender was successful
            (bool successAdvisor, ) = payable(address(advisor)).call{value: advisorShare}(""); // @dev Transfer the advisor's share
            require(successAdvisor, "Refund to Advisor failed"); // @dev Ensure the transfer to the advisor was successful
        }
    }

    /**
     * @dev View function to calculate the ETH price for purchasing tokens
     * @param amount - The number of tokens to purchase
     * @return The total ETH required to purchase the specified number of tokens
     */
    function purchaseToken_price(uint256 amount) public view returns (uint256) {
        return _getCurrentRoundPrice() * (amount / DECIMALS); // @dev Calculate the price in ETH based on the current round price
    }

    /**
     * @dev Returns the top `topN` participants based on their total spending.
     * Iterates through the list of participants and selects the top spenders.
     * @param topN The number of top participants to return.
     * @return An array of addresses representing the top `topN` participants by spending.
     */ 
    function getTopParticipants(uint256 topN) public view returns (address[] memory) {
        require(topN > 0 && topN <= _participants.length, "Invalid topN value"); // @dev Ensure the topN value is valid
        address[] memory topParticipants = new address[](topN); // @dev Initialize the array to store top participants
        uint256[] memory topAmounts = new uint256[](topN); // @dev Initialize the array to store top spending amounts
        for (uint256 i = 0; i < topN; i++) {
            topParticipants[i] = _participants[i]; // @dev Populate initial top participants
            topAmounts[i] = totalSpent[_participants[i]]; // @dev Populate initial top amounts
        }
        for (uint256 i = topN / 2; i > 0; i--) {
            heapifyDown(topAmounts, topParticipants, i - 1, topN); // @dev Create a min-heap from the initial topN elements
        }
        for (uint256 i = topN; i < _participants.length; i++) {
            uint256 spent = totalSpent[_participants[i]]; // @dev Calculate the spending for the current participant
            if (spent > topAmounts[0]) {
                topAmounts[0] = spent; // @dev Replace the root of the heap with the new top spender
                topParticipants[0] = _participants[i]; // @dev Replace the corresponding participant
                heapifyDown(topAmounts, topParticipants, 0, topN); // @dev Heapify down to restore the min-heap property
            }
        }
        for (uint256 i = topN - 1; i > 0; i--) {
            (topAmounts[0], topAmounts[i]) = (topAmounts[i], topAmounts[0]); // @dev Swap the root with the last element
            (topParticipants[0], topParticipants[i]) = (topParticipants[i], topParticipants[0]); // @dev Swap the participants
            heapifyDown(topAmounts, topParticipants, 0, i); // @dev Heapify down to restore the min-heap property
        }

        return topParticipants; 
    }

    /**
     * @dev Heapifies down the element at index `start` in the min-heap.
     * @param topAmounts Array of the top spending amounts.
     * @param topParticipants Array of the top participant addresses.
     * @param start The starting index to heapify down.
     * @param size The size of the heap.
     */
    function heapifyDown(
        uint256[] memory topAmounts,
        address[] memory topParticipants,
        uint256 start,
        uint256 size
    ) internal pure {
        uint256 left = 2 * start + 1; // @dev Calculate the left child index
        uint256 right = 2 * start + 2; // @dev Calculate the right child index
        uint256 smallest = start; // @dev Initialize the smallest element as the current index
        if (left < size && topAmounts[left] < topAmounts[smallest]) {
            smallest = left; // @dev Update the smallest if the left child is smaller
        }
        if (right < size && topAmounts[right] < topAmounts[smallest]) {
            smallest = right; // @dev Update the smallest if the right child is smaller
        }
        if (smallest != start) {
            (topAmounts[start], topAmounts[smallest]) = (topAmounts[smallest], topAmounts[start]); // @dev Swap the current element with the smallest
            (topParticipants[start], topParticipants[smallest]) = (topParticipants[smallest], topParticipants[start]); // @dev Swap the corresponding participants
            heapifyDown(topAmounts, topParticipants, smallest, size); // @dev Recursively heapify down
        }
    }

    /**
     * @dev Returns the ranking of the caller based on their total spending.
     * @return The 1-based ranking of the caller among all participants. Returns 0 if the caller is not in the list.
     */
    function getRanking() external view returns (uint256) {
        address[] memory sortedParticipants = getTopParticipants(_participants.length); // @dev Get the sorted list of participants
        for (uint256 i = 0; i < sortedParticipants.length; i++) {
            if (sortedParticipants[i] == msg.sender) {
                return i + 1; // @dev Return the 1-based ranking if the participant is found
            }
        }
        return 0; // @dev Return 0 if the caller is not in the participants list
    }

    /**
     * @dev Returns the address of the top spender.
     * @return The address of the participant who has spent the most. Returns address(0) if there are no participants.
     */
    function getTopSpender() public view returns (address) {
        if (_participants.length == 0) return address(0); // @dev Return address(0) if no participants exist
        address[] memory sortedParticipants = getTopParticipants(_participants.length); // @dev Get the sorted list of participants 
        return sortedParticipants[0]; // @dev Returns the address of the first top spender
    }

    /**
     * @dev Returns the address of the second top spender.
     * @return The address of the participant who has spent the second most. Returns address(0) if there are less than 2 participants.
     */
    function getSecondTopSpender() public view returns (address) {
        if (_participants.length < 2) return address(0); // @dev Return address(0) if there are less than 2 participants
        address[] memory sortedParticipants = getTopParticipants(_participants.length); // @dev Get the sorted list of participants 
        return sortedParticipants[1]; // @dev Returns the address of the second top spender
    }

    /**
     * @dev Returns the address of the third top spender.
     * @return The address of the participant who has spent the third most. Returns address(0) if there are less than 3 participants.
     */
    function getThirdTopSpender() public view returns (address) {
        if (_participants.length < 3) return address(0); // @dev Return address(0) if there are less than 3 participants
        address[] memory sortedParticipants = getTopParticipants(_participants.length); // @dev Get the sorted list of participants 
        return sortedParticipants[2]; // @dev Returns the address of the third top spender
    }
    
    /**
     * @dev Returns the amount spent by the top spender.
     * @return The total amount spent by the top spender. Returns 0 if there are no participants.
     */
    function getTopSpenderAmount() external view returns (uint256) {
        address topSpender = getTopSpender(); // @dev Get the address of the top spender
        if (topSpender == address(0)) return 0; // @dev Return 0 if there is no top spender
        return totalSpent[topSpender]; // @dev Return the total amount spent by the top spender
    }

    /**
     * @dev Returns the amount spent by the second top spender.
     * @return The total amount spent by the second top spender. Returns 0 if there are less than 2 participants.
     */
    function getSecondTopSpenderAmount() external view returns (uint256) {
        address secondTopSpender = getSecondTopSpender(); // @dev Get the address of the second top spender
        if (secondTopSpender == address(0)) return 0; // @dev Return 0 if there is no second top spender
        return totalSpent[secondTopSpender]; // @dev Return the total amount spent by the second top spender
    }

    /**
     * @dev Returns the amount spent by the third top spender.
     * @return The total amount spent by the third top spender. Returns 0 if there are less than 3 participants.
     */
    function getThirdTopSpenderAmount() external view returns (uint256) {
        address thirdTopSpender = getThirdTopSpender(); // @dev Get the address of the third top spender
        if (thirdTopSpender == address(0)) return 0; // @dev Return 0 if there is no third top spender
        return totalSpent[thirdTopSpender]; // @dev Return the total amount spent by the third top spender
    }

    /*
     * @dev View function to get the price of tokens for the current round
     * @return The price of tokens in ETH for the current round
     */
    function _getCurrentRoundPrice() public view returns (uint256) {
        return _convertUSDtoETH(_roundPrices[_currentRound]); // @dev Convert the current round price to ETH
    }

    /*
     * @dev View function to get the remaining tokens available for purchase in the current round
     * @return The number of tokens still available for purchase in the current round
     */
    function _getCurrentRoundTokensRemaining() public view returns (uint256) {
        return _roundTokenLimits[_currentRound] - _tokensSoldPerRound[_currentRound]; // @dev Calculate the remaining tokens in the current round
    }

    /**
     * @dev Internal function to update the progress of the current round and handle token distribution across rounds
     */
    
    function _updateRoundProgress() internal {
        uint256 remainingTokensCurrentRound = _getCurrentRoundTokensRemaining(); // @dev Get the remaining tokens in the current round
        if (remainingTokensCurrentRound == 0 && _currentRound < MAX_ROUND) {
            _currentRound++; // @dev Advance to the next round if needed
            emit RoundAdvanced(_currentRound); // @dev Emit an event for advancing to the next round
        }
    }

    /**
     * @notice Function to distribute funds to the liquidity pool and the contract owner at the end of the presale.
     * Allocation:
     * - 70% of ETH balance -> Liquidity Pool
     * - 10% of ETH balance -> Contract Owner
     * - 20% of ETH balance -> Remains in the contract for other allocations (not handled here)
     */
     function deploy_SyntraCoin() external {
        require(msg.sender == address(this), "Only the contract can call this function"); // Ensure that only the contract can call this function
        uint256 totalBalance = address(this).balance; // Get the contract's total ETH balance
        uint256 ethForPool = (totalBalance * 70) / 100; // 70% for the liquidity pool
        uint256 ethForOwner = (totalBalance * 10) / 100; // 10% for the contract owner
        emit OwnerFundsTransferred(ethForOwner, block.timestamp); // Emit event
        (bool successOwner, ) = payable(owner()).call{value: ethForOwner}(""); // Send 10% to the owner
        require(successOwner, "Transfer to owner failed"); // Ensure the transfer goes correctly
        _uniswapAndCoinManager.deployCoinAndPool{value: ethForPool}(ethForPool); // Create coin and pool with UniswapAndCoinManager
    }

    /**
     * @notice Function for participants to mint the tokens they bought in the presale
     */
    function mintMyTokens() external nonReentrant {
        require(_uniswapAndCoinManager.coinAddress() != address(0), "Coin not deployed yet"); // @dev Ensure the token has been deployed
        uint256 amountToMint = _tokenPurchases[msg.sender]; // @dev Get the amount of tokens to mint for the sender
        require(amountToMint > 0, "No tokens to mint"); // @dev Ensure the participant has tokens to mint
        _tokenPurchases[msg.sender] = 0; // @dev Reset the token purchases for the sender
        _uniswapAndCoinManager.mintTokens(msg.sender, amountToMint); // @dev Mint the tokens for the participant
    }

    /**
     * @notice Allows the team to withdraw vested ETH according to the vesting schedule.
     */
    function withdrawTeamEth() external onlyOwner nonReentrant {
        uint256 vestedAmount = calculateVestedEthAmount(); // @dev calculates the vested amount accrued
        uint256 withdrawableAmount = vestedAmount - teamEthWithdrawn; // @dev Calculate the effective withdrawable vesting amount
        require(withdrawableAmount > 0, "No ETH available for withdrawal"); // @dev Ensure that the amount is greather than 0
        teamEthWithdrawn += withdrawableAmount; // @dev Update the total team withdrawn amount
        emit TeamEthWithdrawn(withdrawableAmount, block.timestamp); // @dev Emit an event when a withdraw is executed
        (bool success, ) = payable(owner()).call{value: withdrawableAmount}(""); // @dev Send the amount to the owner
        require(success, "Transfer failed"); // @dev Ensure that the transfer goes correclty
        }

  /**
 * @notice Calculates the total amount of ETH vested up to the current time.
 * @return The vested ETH amount.
 */
function calculateVestedEthAmount() public view returns (uint256) {
    if (block.timestamp >= teamEthVestingStartTime + TEAM_ETH_VESTING_DURATION) {
        return teamTotalVestedEth;
    } else {
        uint256 elapsedTime = block.timestamp - teamEthVestingStartTime; // @dev Calculate the elapsed time
        return (teamTotalVestedEth * elapsedTime) / TEAM_ETH_VESTING_DURATION; // @dev Calculate the withdrawable amount, based on the elapsed time
    }
}

    /**
     * @notice Function to attempt to withdraw funds safely; enters emergency mode if it fails
     */
    function safe_deploy_SyntraCoin() external nonReentrant onlyOwner {
        require(_uniswapAndCoinManager.coinAddress() == address(0), "Coin already deployed"); // @dev Ensure the token has not been deployed
        
        try this.deploy_SyntraCoin() {} catch {
            _isInEmergencyWithdraw = true; // @dev Enter emergency withdrawal mode if deployment fails
        }
    }

    /**
     * @notice Function to perform an emergency withdrawal if safe withdrawal fails
     */
    function emergencyWithdraw() external nonReentrant onlyOwner {
        require(_isInEmergencyWithdraw, "Emergency withdraw is not active"); // @dev Ensure emergency withdrawal mode is active
        uint256 balance = address(this).balance; // @dev Get the contract's ETH balance
        require(balance > 0, "No ETH available to withdraw"); // @dev Ensure there are funds
        (bool success, ) = payable(owner()).call{value: balance}(""); // @dev Transfer the balance to the owner
        require(success, "ETH transfer failed"); // @dev Ensure the ETH transfer was successful
    }

    /** 
     * @notice Function to allow participants to request a refund if certain conditions are met
     */
    function refundMe() external nonReentrant {
        if(_totalTokensSold >= TOTAL_TOKENS || block.timestamp > _presaleStartedAt + GLOBAL_TIMER) {
            revert("Presale is finished"); // @dev Ensure the presale is not finished
        } 
        uint256 tokensToRefund = _tokensSoldPerRoundByAddress[msg.sender][_currentRound]; // @dev Calculate the tokens wligible to refund
        require(tokensToRefund > 0, "No tokens purchased"); // @dev Ensure the participant has deposited ETH in the current round 
        uint256 totalTokenEthSpentCurrentRound = totalTokensEthSpentByUserInARound[msg.sender][_currentRound]; // @dev Calculate the total ETH spent by user in the current round
        uint256 refundPercentage = (_advisorForParticipant[msg.sender] != address(0)) ? 60 : 80; // @dev Determine the refund percentage based on advisor referral
        uint256 refundAmountInEth = (totalTokenEthSpentCurrentRound * refundPercentage) / PERCENTAGE_BASE; // @dev Calculate the refund amount
        _tokensSoldPerRoundByAddress[msg.sender][_currentRound] = 0; // @dev Update the user's tokens sold in the current round
        _totalTokensSold -= tokensToRefund; // @dev Update the total tokens sold 
        _tokensSoldPerRound[_currentRound] -= tokensToRefund; // @dev Update the total tokens sold in the current round
        totalTokensEthSpentByUserInARound[msg.sender][_currentRound] = 0; // @dev Update the user's ETH spent in the current round
        _tokenPurchases[msg.sender] -= tokensToRefund; // @dev Update the token purchases for the participant
        totalSpent[msg.sender] -= totalTokenEthSpentCurrentRound; // @dev Update the total amount spent by the participant
        emit AddressRefunded(msg.sender, refundAmountInEth); // @dev Emit an event for the refund
        (bool success, ) = payable(msg.sender).call{value: refundAmountInEth}(""); // @dev Transfer the refund to the participant
        require(success, "Transfer failed"); // @dev Ensure the refund transfer was successful
    }

    /**
    * @dev Returns the total number of participants in the presale.
    * This function provides a count of how many unique addresses have participated in the presale.
    * @return The total number of participants in the presale.
    */
    function getTotalParticipants() public view returns (uint256) {
        return _participants.length; // @dev Return the total number of participants in the presale
    }
}