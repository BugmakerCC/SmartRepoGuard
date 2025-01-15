// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;


// node_modules/@openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

// node_modules/frax-standard-solidity/src/access-control/v2/PublicReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

// NOTE: This file has been modified from the original to make the _status an internal item so that it can be exposed by consumers.
// This allows us to prevent global reentrancy across different

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
abstract contract PublicReentrancyGuard {
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

    uint256 internal _status;

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

// node_modules/frax-standard-solidity/src/access-control/v2/Timelock2Step.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== Timelock2Step ===========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// Reviewers
// Dennis: https://github.com/denett

// ====================================================================

/// @title Timelock2Step
/// @author Drake Evans (Frax Finance) https://github.com/drakeevans
/// @dev Inspired by OpenZeppelin's Ownable2Step contract
/// @notice  An abstract contract which contains 2-step transfer and renounce logic for a timelock address
abstract contract Timelock2Step {
    /// @notice The pending timelock address
    address public pendingTimelockAddress;

    /// @notice The current timelock address
    address public timelockAddress;

    constructor(address _timelockAddress) {
        timelockAddress = _timelockAddress;
    }

    // ============================================================================================
    // Functions: External Functions
    // ============================================================================================

    /// @notice The ```transferTimelock``` function initiates the timelock transfer
    /// @dev Must be called by the current timelock
    /// @param _newTimelock The address of the nominated (pending) timelock
    function transferTimelock(address _newTimelock) external virtual {
        _requireSenderIsTimelock();
        _transferTimelock(_newTimelock);
    }

    /// @notice The ```acceptTransferTimelock``` function completes the timelock transfer
    /// @dev Must be called by the pending timelock
    function acceptTransferTimelock() external virtual {
        _requireSenderIsPendingTimelock();
        _acceptTransferTimelock();
    }

    /// @notice The ```renounceTimelock``` function renounces the timelock after setting pending timelock to current timelock
    /// @dev Pending timelock must be set to current timelock before renouncing, creating a 2-step renounce process
    function renounceTimelock() external virtual {
        _requireSenderIsTimelock();
        _requireSenderIsPendingTimelock();
        _transferTimelock(address(0));
        _setTimelock(address(0));
    }

    // ============================================================================================
    // Functions: Internal Actions
    // ============================================================================================

    /// @notice The ```_transferTimelock``` function initiates the timelock transfer
    /// @dev This function is to be implemented by a public function
    /// @param _newTimelock The address of the nominated (pending) timelock
    function _transferTimelock(address _newTimelock) internal {
        pendingTimelockAddress = _newTimelock;
        emit TimelockTransferStarted(timelockAddress, _newTimelock);
    }

    /// @notice The ```_acceptTransferTimelock``` function completes the timelock transfer
    /// @dev This function is to be implemented by a public function
    function _acceptTransferTimelock() internal {
        pendingTimelockAddress = address(0);
        _setTimelock(msg.sender);
    }

    /// @notice The ```_setTimelock``` function sets the timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _newTimelock The address of the new timelock
    function _setTimelock(address _newTimelock) internal {
        emit TimelockTransferred(timelockAddress, _newTimelock);
        timelockAddress = _newTimelock;
    }

    // ============================================================================================
    // Functions: Internal Checks
    // ============================================================================================

    /// @notice The ```_isTimelock``` function checks if _address is current timelock address
    /// @param _address The address to check against the timelock
    /// @return Whether or not msg.sender is current timelock address
    function _isTimelock(address _address) internal view returns (bool) {
        return _address == timelockAddress;
    }

    /// @notice The ```_requireIsTimelock``` function reverts if _address is not current timelock address
    /// @param _address The address to check against the timelock
    function _requireIsTimelock(address _address) internal view {
        if (!_isTimelock(_address)) revert AddressIsNotTimelock(timelockAddress, _address);
    }

    /// @notice The ```_requireSenderIsTimelock``` function reverts if msg.sender is not current timelock address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsTimelock() internal view {
        _requireIsTimelock(msg.sender);
    }

    /// @notice The ```_isPendingTimelock``` function checks if the _address is pending timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _address The address to check against the pending timelock
    /// @return Whether or not _address is pending timelock address
    function _isPendingTimelock(address _address) internal view returns (bool) {
        return _address == pendingTimelockAddress;
    }

    /// @notice The ```_requireIsPendingTimelock``` function reverts if the _address is not pending timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _address The address to check against the pending timelock
    function _requireIsPendingTimelock(address _address) internal view {
        if (!_isPendingTimelock(_address)) revert AddressIsNotPendingTimelock(pendingTimelockAddress, _address);
    }

    /// @notice The ```_requirePendingTimelock``` function reverts if msg.sender is not pending timelock address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsPendingTimelock() internal view {
        _requireIsPendingTimelock(msg.sender);
    }

    // ============================================================================================
    // Functions: Events
    // ============================================================================================

    /// @notice The ```TimelockTransferStarted``` event is emitted when the timelock transfer is initiated
    /// @param previousTimelock The address of the previous timelock
    /// @param newTimelock The address of the new timelock
    event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);

    /// @notice The ```TimelockTransferred``` event is emitted when the timelock transfer is completed
    /// @param previousTimelock The address of the previous timelock
    /// @param newTimelock The address of the new timelock
    event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);

    // ============================================================================================
    // Functions: Errors
    // ============================================================================================

    /// @notice Emitted when timelock is transferred
    error AddressIsNotTimelock(address timelockAddress, address actualAddress);

    /// @notice Emitted when pending timelock is transferred
    error AddressIsNotPendingTimelock(address pendingTimelockAddress, address actualAddress);
}

// src/contracts/interfaces/IDepositContract.sol
// ┏━━━┓━┏┓━┏┓━━┏━━━┓━━┏━━━┓━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━┏┓━━━━━┏━━━┓━━━━━━━━━┏┓━━━━━━━━━━━━━━┏┓━
// ┃┏━━┛┏┛┗┓┃┃━━┃┏━┓┃━━┃┏━┓┃━━━━┗┓┏┓┃━━━━━━━━━━━━━━━━━━┏┛┗┓━━━━┃┏━┓┃━━━━━━━━┏┛┗┓━━━━━━━━━━━━┏┛┗┓
// ┃┗━━┓┗┓┏┛┃┗━┓┗┛┏┛┃━━┃┃━┃┃━━━━━┃┃┃┃┏━━┓┏━━┓┏━━┓┏━━┓┏┓┗┓┏┛━━━━┃┃━┗┛┏━━┓┏━┓━┗┓┏┛┏━┓┏━━┓━┏━━┓┗┓┏┛
// ┃┏━━┛━┃┃━┃┏┓┃┏━┛┏┛━━┃┃━┃┃━━━━━┃┃┃┃┃┏┓┃┃┏┓┃┃┏┓┃┃━━┫┣┫━┃┃━━━━━┃┃━┏┓┃┏┓┃┃┏┓┓━┃┃━┃┏┛┗━┓┃━┃┏━┛━┃┃━
// ┃┗━━┓━┃┗┓┃┃┃┃┃┃┗━┓┏┓┃┗━┛┃━━━━┏┛┗┛┃┃┃━┫┃┗┛┃┃┗┛┃┣━━┃┃┃━┃┗┓━━━━┃┗━┛┃┃┗┛┃┃┃┃┃━┃┗┓┃┃━┃┗┛┗┓┃┗━┓━┃┗┓
// ┗━━━┛━┗━┛┗┛┗┛┗━━━┛┗┛┗━━━┛━━━━┗━━━┛┗━━┛┃┏━┛┗━━┛┗━━┛┗┛━┗━┛━━━━┗━━━┛┗━━┛┗┛┗┛━┗━┛┗┛━┗━━━┛┗━━┛━┗━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┗┛━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// This interface is designed to be compatible with the Vyper version.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
interface IDepositContract {
    /// @notice A processed deposit event.
    event DepositEvent(bytes pubkey, bytes withdrawal_credentials, bytes amount, bytes signature, bytes index);

    /// @notice Submit a Phase 0 DepositData object.
    /// @param pubkey A BLS12-381 public key.
    /// @param withdrawal_credentials Commitment to a public key for withdrawals.
    /// @param signature A BLS12-381 signature.
    /// @param deposit_data_root The SHA-256 hash of the SSZ-encoded DepositData object.
    /// Used as a protection against malformed input.
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;

    /// @notice Query the current deposit root hash.
    /// @return The deposit root hash.
    function get_deposit_root() external view returns (bytes32);

    /// @notice Query the current deposit count.
    /// @return The deposit count encoded as a little endian 64-bit number.
    function get_deposit_count() external view returns (bytes memory);
}

// Based on official specification in https://eips.ethereum.org/EIPS/eip-165
interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceId` and
    ///  `interfaceId` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external pure returns (bool);
}

// This is a rewrite of the Vyper Eth2.0 deposit contract in Solidity.
// It tries to stay as close as possible to the original source code.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
contract DepositContract is IDepositContract, ERC165 {
    uint256 constant DEPOSIT_CONTRACT_TREE_DEPTH = 32;
    // NOTE: this also ensures `deposit_count` will fit into 64-bits
    uint256 constant MAX_DEPOSIT_COUNT = 2 ** DEPOSIT_CONTRACT_TREE_DEPTH - 1;

    bytes32[DEPOSIT_CONTRACT_TREE_DEPTH] branch;
    uint256 deposit_count;

    bytes32[DEPOSIT_CONTRACT_TREE_DEPTH] zero_hashes;

    constructor() public {
        // Compute hashes in empty sparse Merkle tree
        for (uint256 height = 0; height < DEPOSIT_CONTRACT_TREE_DEPTH - 1; height++) {
            zero_hashes[height + 1] = sha256(abi.encodePacked(zero_hashes[height], zero_hashes[height]));
        }
    }

    function get_deposit_root() external view override returns (bytes32) {
        bytes32 node;
        uint256 size = deposit_count;
        for (uint256 height = 0; height < DEPOSIT_CONTRACT_TREE_DEPTH; height++) {
            if ((size & 1) == 1) {
                node = sha256(abi.encodePacked(branch[height], node));
            } else {
                node = sha256(abi.encodePacked(node, zero_hashes[height]));
            }
            size /= 2;
        }
        return sha256(abi.encodePacked(node, to_little_endian_64(uint64(deposit_count)), bytes24(0)));
    }

    function get_deposit_count() external view override returns (bytes memory) {
        return to_little_endian_64(uint64(deposit_count));
    }

    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable override {
        // Extended ABI length checks since dynamic types are used.
        require(pubkey.length == 48, "DepositContract: invalid pubkey length");
        require(withdrawal_credentials.length == 32, "DepositContract: invalid withdrawal_credentials length");
        require(signature.length == 96, "DepositContract: invalid signature length");

        // Check deposit amount
        require(msg.value >= 1 ether, "DepositContract: deposit value too low");
        require(msg.value % 1 gwei == 0, "DepositContract: deposit value not multiple of gwei");
        uint256 deposit_amount = msg.value / 1 gwei;
        require(deposit_amount <= type(uint64).max, "DepositContract: deposit value too high");

        // Emit `DepositEvent` log
        bytes memory amount = to_little_endian_64(uint64(deposit_amount));
        emit DepositEvent(
            pubkey,
            withdrawal_credentials,
            amount,
            signature,
            to_little_endian_64(uint64(deposit_count))
        );

        // Compute deposit data root (`DepositData` hash tree root)
        bytes32 pubkey_root = sha256(abi.encodePacked(pubkey, bytes16(0)));
        bytes32 signature_root = sha256(
            abi.encodePacked(
                sha256(abi.encodePacked(signature[:64])),
                sha256(abi.encodePacked(signature[64:], bytes32(0)))
            )
        );
        bytes32 node = sha256(
            abi.encodePacked(
                sha256(abi.encodePacked(pubkey_root, withdrawal_credentials)),
                sha256(abi.encodePacked(amount, bytes24(0), signature_root))
            )
        );

        // Verify computed and expected deposit data roots match
        require(
            node == deposit_data_root,
            "DepositContract: reconstructed DepositData does not match supplied deposit_data_root"
        );

        // Avoid overflowing the Merkle tree (and prevent edge case in computing `branch`)
        require(deposit_count < MAX_DEPOSIT_COUNT, "DepositContract: merkle tree full");

        // Add deposit data root to Merkle tree (update a single `branch` node)
        deposit_count += 1;
        uint256 size = deposit_count;
        for (uint256 height = 0; height < DEPOSIT_CONTRACT_TREE_DEPTH; height++) {
            if ((size & 1) == 1) {
                branch[height] = node;
                return;
            }
            node = sha256(abi.encodePacked(branch[height], node));
            size /= 2;
        }
        // As the loop should always end prematurely with the `return` statement,
        // this code should be unreachable. We assert `false` just to be safe.
        assert(false);
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(ERC165).interfaceId || interfaceId == type(IDepositContract).interfaceId;
    }

    function to_little_endian_64(uint64 value) internal pure returns (bytes memory ret) {
        ret = new bytes(8);
        bytes8 bytesValue = bytes8(value);
        // Byteswapping during copying to bytes.
        ret[0] = bytesValue[7];
        ret[1] = bytesValue[6];
        ret[2] = bytesValue[5];
        ret[3] = bytesValue[4];
        ret[4] = bytesValue[3];
        ret[5] = bytesValue[2];
        ret[6] = bytesValue[1];
        ret[7] = bytesValue[0];
    }
}

// src/contracts/lending-pool/interfaces/ILendingPool.sol

// interface ILendingPool {
//     event AddInterest(uint256 interestEarned, uint256 rate, uint256 feesAmount, uint256 feesShare);
//     event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
//     event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
//     event Erc20Recovered(address token, uint256 amount);
//     event EtherRecovered(uint256 amount);
//     event FeesCollected(address _recipient, uint96 _collectAmt);
//     event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
//     event RedemptionQueueEntered(
//         address redeemer,
//         uint256 nftId,
//         uint256 amount,
//         uint32 maturityTimestamp,
//         uint96 redemptionFeeAmount
//     );
//     event RedemptionTicketNftRedeemed(address sender, address recipient, uint256 nftId, uint96 amountOut);
//     event SetBeaconOracle(address indexed oldBeaconOracle, address indexed newBeaconOracle);
//     event SetEtherRouter(address indexed oldEtherRouter, address indexed newEtherRouter);
//     event SetMaxOperatorQueueLength(uint32 _newMaxQueueLength);
//     event SetQueueLength(uint32 _newLength);
//     event SetRedemptionFee(uint32 _newFee);
//     event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);
//     event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);
//     event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
//     event UpdateRate(
//         uint256 oldRatePerSec,
//         uint256 oldFullUtilizationRate,
//         uint256 newRatePerSec,
//         uint256 newFullUtilizationRate
//     );

//     struct CurrentRateInfo {
//         uint64 lastTimestamp;
//         uint64 ratePerSec;
//         uint64 fullUtilizationRate;
//     }

//     struct VaultAccount {
//         uint256 amount;
//         uint256 shares;
//     }

//     function DEFAULT_CREDIT_PER_VALIDATOR_I48_E12() external view returns (uint256);

//     function ETH2_DEPOSIT_CONTRACT() external view returns (address);

//     function FEE_PRECISION() external view returns (uint32);

//     function INTEREST_RATE_PRECISION() external view returns (uint256);

//     function UTILIZATION_PRECISION() external view returns (uint256);

//     function acceptTransferTimelock() external;

//     function addInterest(
//         bool _returnAccounting
//     )
//         external
//         returns (
//             uint256 _interestEarned,
//             uint256 _feesAmount,
//             uint256 _feesShare,
//             CurrentRateInfo memory _currentRateInfo,
//             VaultAccount memory _totalBorrow
//         );

//     function approve(address to, uint256 tokenId) external;

//     function approveValidator(bytes memory _validatorPublicKey) external;

//     function balanceOf(address owner) external view returns (uint256);

//     function beaconOracle() external view returns (address);

//     function borrow(address _recipient, uint256 _borrowAmount) external;

//     function collectRedemptionFees(address _recipient, uint96 _collectAmt) external;

//     function currentRateInfo()
//         external
//         view
//         returns (uint64 lastTimestamp, uint64 ratePerSec, uint64 fullUtilizationRate);

//     function deployValidatorPool(address _validatorPoolOwnerAddress) external returns (address _pairAddress);

//     function enterRedemptionQueue(address _recipient, uint96 _amountToRedeem) external;

//     function enterRedemptionQueueWithPermit(
//         uint96 _amountToRedeem,
//         address _recipient,
//         uint256 _deadline,
//         uint8 _v,
//         bytes32 _r,
//         bytes32 _s
//     ) external;

//     function etherRouter() external view returns (address);

//     function finalDepositValidator(
//         bytes memory _validatorPublicKey,
//         bytes memory _withdrawalCredentials,
//         bytes memory _validatorSignature,
//         bytes32 _depositDataRoot
//     ) external;

//     function frxEth() external view returns (address);

//     function getApproved(uint256 tokenId) external view returns (address);

//     function getUtilization() external view returns (uint256 _utilization);

//     function initialDepositValidator(bytes memory _validatorPublicKey, uint256 _depositAmount) external;

//     function interestAccrued() external view returns (uint256);

//     function interestAvailableForWithdrawal() external view returns (uint256);

//     function rateCalculator() external view returns (address);

//     function isApprovedForAll(address owner, address operator) external view returns (bool);

//     function isSolvent(address _validatorPool) external view returns (bool _isSolvent);

//     function liquidate(address _validatorPoolAddress, uint256 _amountToLiquidate) external;

//     function maxOperatorQueueLength() external view returns (uint32);

//     function name() external view returns (string memory);

//     function nftInformation(uint256 nftId) external view returns (bool hasBeenRedeemed, uint32 maturity, uint96 amount);

//     function operatorAddress() external view returns (address);

//     function ownerOf(uint256 tokenId) external view returns (address);

//     function pendingTimelockAddress() external view returns (address);

//     function previewAddInterest()
//         external
//         view
//         returns (
//             uint256 _interestEarned,
//             uint256 _feesAmount,
//             uint256 _feesShare,
//             CurrentRateInfo memory _newCurrentRateInfo,
//             VaultAccount memory _totalBorrow
//         );

//     function recoverErc20(address _tokenAddress, uint256 _tokenAmount) external;

//     function recoverEther(uint256 amount) external;

//     function redeemRedemptionTicketNft(uint256 _nftId, address _recipient) external;

//     function redemptionQueueState() external view returns (uint32 nextNftId, uint32 queueLength, uint32 redemptionFee);

//     function renounceTimelock() external;

//     function repay(address _targetPool) external payable;

//     function safeTransferFrom(address from, address to, uint256 tokenId) external;

//     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;

//     function setApprovalForAll(address operator, bool approved) external;

//     function setCreationCode(bytes memory _creationCode) external;

//     function setMaxOperatorQueueLength(uint32 _newMaxQueueLength) external;

//     function setOperator() external;

//     function setOperator(address _newOperator) external;

//     function setQueueLength(uint32 _newLength) external;

//     function setRedemptionFee(uint32 _newFee) external;

//     function setVPoolBorrowAllowance(address _validatorPoolAddress, uint128 _newBorrowAllowance) external;

//     function setVPoolCreditPerValidatorI48_E12(
//         address _validatorPoolAddress,
//         uint48 _newCreditPerValidatorI48_E12
//     ) external;

//     function setVPoolValidatorCount(address _validatorPoolAddress, uint32 _newValidatorCount) external;

//     function supportsInterface(bytes4 interfaceId) external view returns (bool);

//     function symbol() external view returns (string memory);

//     function timelockAddress() external view returns (address);

//     function toBorrowAmount(address _validatorPool, uint256 _shares) external view returns (uint256 _borrowAmount);

//     function tokenURI(uint256 tokenId) external view returns (string memory);

//     function totalBorrow() external view returns (uint256 amount, uint256 shares);

//     function transferFrom(address from, address to, uint256 tokenId) external;

//     function transferTimelock(address _newTimelock) external;

//     function validatorDepositInfo(
//         bytes memory _validatorPublicKey
//     ) external view returns (uint32 whenValidatorApproved, uint96 userDepositedEther, uint96 lendingPoolDepositedEther);

//     function validatorPoolAccounts(
//         address _validatorPool
//     )
//         external
//         view
//         returns (
//             bool isInitialized,
//             bool wasLiquidated,
//             uint32 lastWithdrawal,
//             uint32 validatorCount,
//             uint48 creditPerValidatorI48_E12,
//             uint128 borrowAllowance,
//             uint256 borrowShares
//         );

//     function validatorPoolCreationCodeAddress() external view returns (address);
// }
interface ILendingPool {
    struct CurrentRateInfo {
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
    }

    struct VaultAccount {
        uint256 amount;
        uint256 shares;
    }

    function DEFAULT_CREDIT_PER_VALIDATOR_I48_E12() external view returns (uint48);
    function ETH2_DEPOSIT_CONTRACT() external view returns (address);
    function INTEREST_RATE_PRECISION() external view returns (uint256);
    function MAXIMUM_CREDIT_PER_VALIDATOR_I48_E12() external view returns (uint48);
    function MAX_WITHDRAWAL_FEE() external view returns (uint256);
    function MINIMUM_BORROW_AMOUNT() external view returns (uint256);
    function MISSING_CREDPERVAL_MULT() external view returns (uint256);
    function UTILIZATION_PRECISION() external view returns (uint256);
    function acceptTransferTimelock() external;
    function addInterest(
        bool _returnAccounting
    )
        external
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo,
            VaultAccount memory _totalBorrow
        );
    function beaconOracle() external view returns (address);
    function borrow(address _recipient, uint256 _borrowAmount) external;
    function currentRateInfo()
        external
        view
        returns (uint64 lastTimestamp, uint64 ratePerSec, uint64 fullUtilizationRate);
    function deployValidatorPool(
        address _validatorPoolOwnerAddress,
        bytes32 _extraSalt
    ) external returns (address _poolAddress);
    function entrancyStatus() external view returns (bool _isEntered);
    function etherRouter() external view returns (address);
    function finalDepositValidator(
        bytes memory _validatorPublicKey,
        bytes memory _withdrawalCredentials,
        bytes memory _validatorSignature,
        bytes32 _depositDataRoot
    ) external;
    function frxETH() external view returns (address);
    function getLastWithdrawalTimestamp(
        address _validatorPoolAddress
    ) external returns (uint32 _lastWithdrawalTimestamp);
    function getLastWithdrawalTimestamps(
        address[] memory _validatorPoolAddresses
    ) external returns (uint32[] memory _lastWithdrawalTimestamps);
    function getMaxBorrow() external view returns (uint256 _maxBorrow);
    function getUtilization(bool _forceLive, bool _updateCache) external returns (uint256 _utilization);
    function getUtilizationView() external view returns (uint256 _utilization);
    function initialDepositValidator(bytes memory _validatorPublicKey, uint256 _depositAmount) external;
    function interestAccrued() external view returns (uint256);
    function isLiquidator(address _addr) external view returns (bool _canLiquidate);
    function isSolvent(address _validatorPoolAddress) external view returns (bool _isSolvent);
    function isValidatorApproved(bytes memory _publicKey) external view returns (bool _isApproved);
    function liquidate(address _validatorPoolAddress, uint256 _amountToLiquidate) external;
    function pendingTimelockAddress() external view returns (address);
    function previewAddInterest()
        external
        view
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _newCurrentRateInfo,
            VaultAccount memory _totalBorrow
        );
    function previewValidatorAccounts(address _validatorPoolAddress) external view returns (VaultAccount memory);
    function rateCalculator() external view returns (address);
    function recoverStrandedEth() external returns (uint256 _amountRecovered);
    function redemptionQueue() external view returns (address);
    function registerWithdrawal(address _endRecipient, uint256 _sentBackAmount, uint256 _feeAmount) external;
    function renounceTimelock() external;
    function repay(address _targetPool) external payable;
    function setBeaconOracleAddress(address _newBeaconOracleAddress) external;
    function setCreationCode(bytes memory _creationCode) external;
    function setEtherRouterAddress(address _newEtherRouterAddress) external;
    function setInterestRateCalculator(address _calculatorAddress) external;
    function setLiquidator(address _liquidatorAddress, bool _canLiquidate) external;
    function setRedemptionQueueAddress(address _newRedemptionQueue) external;
    function setVPoolCreditsPerValidator(
        address[] memory _validatorPoolAddresses,
        uint48[] memory _newCreditsPerValidator
    ) external;
    function setVPoolValidatorCountsAndBorrowAllowances(
        address[] memory _validatorPoolAddresses,
        bool _setValidatorCounts,
        bool _setBorrowAllowances,
        uint32[] memory _newValidatorCounts,
        uint128[] memory _newBorrowAllowances,
        uint32[] memory _lastWithdrawalTimestamps
    ) external;
    function setVPoolWithdrawalFee(uint256 _newFee) external;
    function setValidatorApprovals(
        bytes[] memory _validatorPublicKeys,
        address[] memory _validatorPoolAddresses,
        uint32[] memory _whenApprovedArr,
        uint32[] memory _lastWithdrawalTimestamps
    ) external;
    function timelockAddress() external view returns (address);
    function toBorrowAmount(uint256 _shares) external view returns (uint256 _borrowAmount);
    function toBorrowAmountOptionalRoundUp(
        uint256 _shares,
        bool _roundUp
    ) external view returns (uint256 _borrowAmount);
    function totalBorrow() external view returns (uint256 amount, uint256 shares);
    function transferTimelock(address _newTimelock) external;
    function utilizationStored() external view returns (uint256);
    function vPoolWithdrawalFee() external view returns (uint256);
    function validatorDepositInfo(
        bytes memory _validatorPublicKey
    )
        external
        view
        returns (
            uint32 whenValidatorApproved,
            bool wasFullDepositOrFinalized,
            address validatorPoolAddress,
            uint96 userDepositedEther,
            uint96 lendingPoolDepositedEther
        );
    function validatorPoolAccounts(
        address _validatorPool
    )
        external
        view
        returns (
            bool isInitialized,
            bool wasLiquidated,
            uint32 lastWithdrawal,
            uint32 validatorCount,
            uint48 creditPerValidatorI48_E12,
            uint128 borrowAllowance,
            uint256 borrowShares
        );
    function validatorPoolCreationCodeAddress() external view returns (address);
    function wasLiquidated(address _validatorPoolAddress) external view returns (bool _wasLiquidated);
    function wouldBeSolvent(
        address _validatorPoolAddress,
        bool _accrueInterest,
        uint256 _addlValidators,
        uint256 _addlBorrowAmount
    ) external view returns (bool _wouldBeSolvent, uint256 _borrowAmount, uint256 _creditAmount);
}

// node_modules/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

// node_modules/@openzeppelin/contracts/access/Ownable2Step.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}

// src/contracts/ValidatorPool.sol

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// =========================== ValidatorPool ==========================
// ====================================================================
// Deposits ETH to earn collateral credit for borrowing on the LendingPool
// Controlled by the depositor

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Drake Evans: https://github.com/DrakeEvans
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Dennis: https://github.com/denett
// Sam Kazemian: https://github.com/samkazemian

// import { console } from "frax-std/FraxTest.sol";
// import { Logger } from "frax-std/Logger.sol";

/// @title Deposits ETH to earn collateral credit for borrowing on the LendingPool
/// @author Frax Finance
/// @notice Controlled by the depositor
contract ValidatorPool is Ownable2Step, PublicReentrancyGuard {
    // ==============================================================================
    // Storage & Constructor
    // ==============================================================================

    /// @notice Track amount of ETH sent to deposit contract, but pubkey
    mapping(bytes validatorPubKey => uint256 amtDeposited) public depositedAmts;

    /// @notice Withdrawal creds for the validators
    bytes32 public immutable withdrawalCredentials;

    /// @notice The Eth lending pool
    ILendingPool public immutable lendingPool;

    /// @notice The official Eth2 deposit contract
    IDepositContract public immutable ETH2_DEPOSIT_CONTRACT;

    /// @notice Constructor
    /// @param _ownerAddress The owner of the validator pool
    /// @param _lendingPoolAddress Address of the lending pool
    /// @param _eth2DepositAddress Address of the Eth2 deposit contract
    constructor(
        address _ownerAddress,
        address payable _lendingPoolAddress,
        address payable _eth2DepositAddress
    ) Ownable(_ownerAddress) {
        lendingPool = ILendingPool(_lendingPoolAddress);
        bytes32 _bitMask = 0x0100000000000000000000000000000000000000000000000000000000000000;
        bytes32 _address = bytes32(uint256(uint160(address(this))));
        withdrawalCredentials = _bitMask | _address;

        ETH2_DEPOSIT_CONTRACT = IDepositContract(_eth2DepositAddress);
    }

    // ==============================================================================
    // Eth Handling
    // ==============================================================================

    /// @notice Accept Eth
    receive() external payable {}

    // ==============================================================================
    // Check Functions
    // ==============================================================================

    /// @notice Make sure the sender is the validator pool owner
    function _requireSenderIsOwner() internal view {
        if (msg.sender != owner()) revert SenderMustBeOwner();
    }

    /// @notice Make sure the sender is either the validator pool owner or the owner
    function _requireSenderIsOwnerOrLendingPool() internal view {
        if (msg.sender == owner() || msg.sender == address(lendingPool)) {
            // Do nothing
        } else {
            revert SenderMustBeOwnerOrLendingPool();
        }
    }

    /// @notice Make sure the supplied pubkey has been used (deposited to) by this validator before
    /// @param _pubKey The pubkey you want to test
    function _requireValidatorIsUsed(bytes memory _pubKey) internal view {
        if (depositedAmts[_pubKey] == 0) revert ValidatorIsNotUsed();
    }

    // ==============================================================================
    // View Functions
    // ==============================================================================

    /// @notice Get the amount of Eth borrowed by this validator pool
    /// @param _amtEthBorrowed The amount of ETH this pool has borrowed
    function getAmountBorrowed() public view returns (uint256 _amtEthBorrowed) {
        // Fetch the borrowShares
        (, , , , , , uint256 borrowShares) = lendingPool.validatorPoolAccounts(address(this));

        // Return the amount of ETH borrowed
        return lendingPool.toBorrowAmountOptionalRoundUp(borrowShares, true);
    }

    // ==============================================================================
    // Deposit Functions
    // ==============================================================================

    /// @notice When the validator pool makes a deposit
    /// @param _validatorPool The validator pool making the deposit
    /// @param _pubkey Public key of the validator.
    /// @param _amount Amount of Eth being deposited
    /// @dev The ETH2 emits a Deposit event, but this is for Beacon Oracle / offchain tracking help
    event ValidatorPoolDeposit(address _validatorPool, bytes _pubkey, uint256 _amount);

    /// @notice Deposit a specified amount of ETH into the ETH2 deposit contract
    /// @param pubkey Public key of the validator
    /// @param signature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    /// @param _depositAmount The amount to deposit
    function _deposit(
        bytes calldata pubkey,
        bytes calldata signature,
        bytes32 _depositDataRoot,
        uint256 _depositAmount
    ) internal {
        bytes memory _withdrawalCredentials = abi.encodePacked(withdrawalCredentials);
        // Deposit one batch
        ETH2_DEPOSIT_CONTRACT.deposit{ value: _depositAmount }(
            pubkey,
            _withdrawalCredentials,
            signature,
            _depositDataRoot
        );

        // Increment the amount deposited
        depositedAmts[pubkey] += _depositAmount;

        emit ValidatorPoolDeposit(address(this), pubkey, _depositAmount);
    }

    // /// @notice Deposit 32 ETH into the ETH2 deposit contract
    // /// @param pubkey Public key of the validator
    // /// @param signature Signature from the validator
    // /// @param _depositDataRoot Part of the deposit message
    // function fullDeposit(
    //     bytes calldata pubkey,
    //     bytes calldata signature,
    //     bytes32 _depositDataRoot
    // ) external payable nonReentrant {
    //     _requireSenderIsOwner();

    //     // Deposit the ether in the ETH 2.0 deposit contract
    //     // Use this contract's stored withdrawal_credentials
    //     require((msg.value + address(this).balance) >= 32 ether, "Need 32 ETH");
    //     _deposit(pubkey, signature, _depositDataRoot, 32 ether);

    //     lendingPool.initialDepositValidator(pubkey, 32 ether);
    // }

    // /// @notice Deposit a partial amount of ETH into the ETH2 deposit contract
    // /// @param _validatorPublicKey Public key of the validator
    // /// @param _validatorSignature Signature from the validator
    // /// @param _depositDataRoot Part of the deposit message
    // /// @dev This is not a full deposit and will have to be completed later
    // function partialDeposit(
    //     bytes calldata _validatorPublicKey,
    //     bytes calldata _validatorSignature,
    //     bytes32 _depositDataRoot
    // ) external payable nonReentrant {
    //     _requireSenderIsOwner();

    //     // Deposit the ether in the ETH 2.0 deposit contract
    //     require((msg.value + address(this).balance) >= 8 ether, "Need 8 ETH");
    //     _deposit(_validatorPublicKey, _validatorSignature, _depositDataRoot, 8 ether);

    //     lendingPool.initialDepositValidator(_validatorPublicKey, 8 ether);
    // }

    /// @notice Deposit ETH into the ETH2 deposit contract. Only msg.value / sender funds can be used
    /// @param _validatorPublicKey Public key of the validator
    /// @param _validatorSignature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    /// @dev Forcing msg.value only prevents users from seeding an external validator and depositing exited funds into there,
    /// which they can then further exit and steal
    function deposit(
        bytes calldata _validatorPublicKey,
        bytes calldata _validatorSignature,
        bytes32 _depositDataRoot
    ) external payable nonReentrant {
        _requireSenderIsOwner();

        // Make sure an integer amount of 1 Eth is being deposited
        // Avoids a case where < 1 Eth is borrowed to finalize a deposit, only to have it fail at the Eth 2.0 contract
        // Also avoids the 1 gwei minimum increment issue at the Eth 2.0 contract
        if ((msg.value % (1 ether)) != 0) revert MustBeIntegerMultipleOf1Eth();

        // Deposit the ether in the ETH 2.0 deposit contract
        // This will reject if the deposit amount isn't at least 1 ETH + a multiple of 1 gwei
        _deposit(_validatorPublicKey, _validatorSignature, _depositDataRoot, msg.value);

        // Register the deposit with the lending pool
        // Will revert if you go over 32 ETH
        lendingPool.initialDepositValidator(_validatorPublicKey, msg.value);
    }

    /// @notice Finalizes an incomplete ETH2 deposit made earlier, borrowing any remainder from the lending pool
    /// @param _validatorPublicKey Public key of the validator
    /// @param _validatorSignature Signature from the validator
    /// @param _depositDataRoot Part of the deposit message
    /// @dev You don't necessarily need credit here because the collateral is secured by the exit message. You pay the interest rate.
    /// Not part of the normal borrow credit system, this is separate.
    /// Useful for leveraging your position if the borrow rate is low enough
    function requestFinalDeposit(
        bytes calldata _validatorPublicKey,
        bytes calldata _validatorSignature,
        bytes32 _depositDataRoot
    ) external nonReentrant {
        _requireSenderIsOwner();
        _requireValidatorIsUsed(_validatorPublicKey);

        // Reverts if deposits not allowed or Validator Pool does not have enough credit/allowance
        lendingPool.finalDepositValidator(
            _validatorPublicKey,
            abi.encodePacked(withdrawalCredentials),
            _validatorSignature,
            _depositDataRoot
        );
    }

    // ==============================================================================
    // Borrow Functions
    // ==============================================================================

    /// @notice Borrow ETH from the Lending Pool and give to the recipient
    /// @param _recipient Recipient of the borrowed funds
    /// @param _borrowAmount Amount being borrowed
    function borrow(address payable _recipient, uint256 _borrowAmount) public nonReentrant {
        _requireSenderIsOwner();

        // Borrow ETH from the Lending Pool and give to the recipient
        lendingPool.borrow(_recipient, _borrowAmount);
    }

    // ==============================================================================
    // Repay Functions
    // ==============================================================================

    /// @notice Repay a loan with msg.value ETH
    function repayWithValue() external payable nonReentrant {
        // On liquidation lending pool will call this function to repay the debt
        _requireSenderIsOwnerOrLendingPool();

        // Take ETH from this contract and give to the Lending Pool to repay any loans
        lendingPool.repay{ value: msg.value }(address(this));
    }

    /// @notice Repay a loan, specifing the ETH amount
    /// @param _repayAmount Amount of ETH to repay
    function repayAmount(uint256 _repayAmount) external nonReentrant {
        // On liquidation lending pool will call this function to repay the debt
        _requireSenderIsOwnerOrLendingPool();

        // Take ETH from this contract and give to the Lending Pool to repay any loans
        lendingPool.repay{ value: _repayAmount }(address(this));
    }

    /// @notice Repay a loan, specifing the shares amount
    /// @param _repayShares Amount of shares to repay
    function repayShares(uint256 _repayShares) external nonReentrant {
        _requireSenderIsOwnerOrLendingPool();
        uint256 _repayAmount = lendingPool.toBorrowAmountOptionalRoundUp(_repayShares, true);
        lendingPool.repay{ value: _repayAmount }(address(this));
    }

    // ==============================================================================
    // Withdraw Functions
    // ==============================================================================

    /// @notice Withdraw ETH from this contract. Must not have any outstanding loans.
    /// @param _recipient Recipient of the ETH
    /// @param _withdrawAmount Amount to withdraw
    /// @dev Even assuming the exited ETH is dumped back in here before the Beacon Oracle registers that, and if the user
    /// tried to borrow again, their collateral would be this exited ETH now that is "trapped" until the loan is repaid,
    /// rather than being in a validator, so it is still ok. borrow() would increase borrowShares, which would still need to be paid off first
    function withdraw(address payable _recipient, uint256 _withdrawAmount) external nonReentrant {
        _requireSenderIsOwner();

        // Calculate the withdrawal fee amount
        uint256 _withdrawalFeeAmt = (_withdrawAmount * lendingPool.vPoolWithdrawalFee()) / 1e6;
        uint256 _postFeeAmt = _withdrawAmount - _withdrawalFeeAmt;

        // Register the withdrawal on the lending pool
        // Will revert unless all debts are paid off first
        lendingPool.registerWithdrawal(_recipient, _postFeeAmt, _withdrawalFeeAmt);

        // Give the fee to the Ether Router first, to cover any fees/slippage from LP movements
        (bool sent, ) = payable(lendingPool.etherRouter()).call{ value: _withdrawalFeeAmt }("");
        if (!sent) revert InvalidEthTransfer();

        // Withdraw ETH from this validator pool and give to the recipient
        (sent, ) = payable(_recipient).call{ value: _postFeeAmt }("");
        if (!sent) revert InvalidEthTransfer();
    }

    // ==============================================================================
    // Errors
    // ==============================================================================

    /// @notice External contract should not have been entered previously
    error ExternalContractAlreadyEntered();

    /// @notice When there is not enough Eth in msg.sender + this pool
    error InsufficientSenderAndPoolEth();

    /// @notice Invalid ETH transfer during recoverEther
    error InvalidEthTransfer();

    /// @notice When you are trying to deposit a non integer multiple of 1 ether
    error MustBeIntegerMultipleOf1Eth();

    /// @notice Sender must be the lending pool
    error SenderMustBeLendingPool();

    /// @notice Sender must be the owner
    error SenderMustBeOwner();

    /// @notice Sender must be the owner or the lendingPool
    error SenderMustBeOwnerOrLendingPool();

    /// @notice Validator is not approved
    error ValidatorIsNotUsed();

    /// @notice Wrong Ether deposit amount
    error WrongEthDepositAmount();
}