// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.26;

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

event ReplaceImplementationStarted(address indexed previousImplementation, address indexed newImplementation);
event ReplaceImplementation(address indexed previousImplementation, address indexed newImplementation);
error Unauthorized();

/**
 * @title Upgradeable2Step
 * @notice This contract implements a two-step process for upgrading the implementation address. It provides security by allowing the owner to propose a new implementation and the implementation to accept itself.
 * @dev Inherits from `Ownable2Step`, allowing the contract owner to initiate the upgrade process, which must then be accepted by the proposed implementation.
 */
contract Upgradeable2Step is Ownable2Step {

    /// @notice The slot containing the address of the pending implementation contract.
    bytes32 public constant PENDING_IMPLEMENTATION_SLOT = keccak256("PENDING_IMPLEMENTATION_SLOT");

    /// @notice The slot containing the address of the current implementation contract.
    bytes32 public constant IMPLEMENTATION_SLOT = keccak256("IMPLEMENTATION_SLOT");

    /**
     * @dev Emitted when a new implementation is proposed.
     * @param previousImplementation The address of the previous implementation.
     * @param newImplementation The address of the new implementation proposed.
     */
    event ReplaceImplementationStarted(address indexed previousImplementation, address indexed newImplementation);

    /**
     * @dev Emitted when a new implementation is accepted and becomes active.
     * @param previousImplementation The address of the previous implementation.
     * @param newImplementation The address of the new active implementation.
     */
    event ReplaceImplementation(address indexed previousImplementation, address indexed newImplementation);

    /**
     * @dev Thrown when an unauthorized account attempts to execute a restricted function.
     */
    error Unauthorized();
      
    /**
     * @notice Initializes the contract and sets the deployer as the initial owner.
     * @dev Passes the deployer address to the `Ownable2Step` constructor.
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @notice Starts the implementation replacement process by setting a new pending implementation address.
     * @dev Can only be called by the owner. Emits the `ReplaceImplementationStarted` event.
     * @param impl_ The address of the new implementation contract to be set as pending.
     */
    function replaceImplementation(address impl_) public onlyOwner {
        bytes32 slot_pending = PENDING_IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot_pending, impl_)
        }
        emit ReplaceImplementationStarted(implementation(), impl_);
    }

    /**
     * @notice Completes the implementation replacement process by accepting the pending implementation.
     * @dev Can only be called by the pending implementation itself. Emits the `ReplaceImplementation` event and updates the `implementation` state.
     *      Deletes the `pendingImplementation` address upon successful acceptance.
     */
    function acceptImplementation() public {
        if (msg.sender != pendingImplementation()) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        emit ReplaceImplementation(implementation(), msg.sender);

        bytes32 slot_pending = PENDING_IMPLEMENTATION_SLOT;
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot_pending, 0)
            sstore(slot, caller())
        }
    }

    /**
     * @notice Allows a new implementation to become the active implementation in a proxy contract.
     * @dev Can only be called by the owner of the specified proxy contract. Calls `acceptImplementation` on the proxy contract.
     * @param proxy The proxy contract where the new implementation should be accepted.
     */
    function becomeImplementation(Upgradeable2Step proxy) public {
        if (msg.sender != proxy.owner()) {
            revert Unauthorized();
        }
        proxy.acceptImplementation();
    }

    /**
     * @notice Returns the pending implementation address
     * @return The pending implementation address
     */
    function pendingImplementation() public view returns (address) {
        address pendingImplementation_;
        bytes32 slot_pending = PENDING_IMPLEMENTATION_SLOT;
        assembly {
            pendingImplementation_ := sload(slot_pending)
        }
        return pendingImplementation_;
    }

    /**
     * @notice Returns the current implementation address
     * @return The current implementation address
     */
    function implementation() public view returns (address) {
        address implementation_;
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementation_ := sload(slot)
        }
        return implementation_;
    }
}

/**
 * @title Proxy2Step
 * @notice This contract serves as a proxy that delegates all calls to an implementation address, supporting a two-step upgradeable pattern.
 * @dev Inherits from `Upgradeable2Step` and allows implementation updates through a two-step process.
 */
contract Proxy2Step is Upgradeable2Step {

    /**
     * @notice Initializes the Proxy2Step contract with the initial implementation address.
     * @param impl_ The address of the initial implementation contract.
     */
    constructor(address impl_) {
        require(impl_ != address(0), "impl_ is zero address");
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, impl_)
        }
    }

    /**
     * @notice Fallback function that delegates all calls to the current implementation.
     * @dev Forwards all calldata to the implementation address and returns the result.
     * @dev Uses `delegatecall` to execute functions in the context of the implementation.
     */
    fallback() external virtual payable {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), sload(slot), 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @notice Receives Ether sent to the contract.
     * @dev This function is used to handle direct ETH transfers without data.
     */
    receive() external virtual payable {
        (bool result,) = implementation().delegatecall("");
        assembly {
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

/**
 * @title BridgeHubWrapperProxy
 * @notice This contract acts as a proxy for the BridgeHubWrapper, allowing for upgradeability and initialization with optional data.
 * @dev Inherits from Proxy2Step to manage implementation address changes in two steps.
 */
contract BridgeHubWrapperProxy is Proxy2Step {
    /**
     * @notice Constructs the BridgeHubWrapperProxy contract and initializes the implementation.
     * @dev If `initData_` is provided, it delegates a call to the implementation contract with that data.
     * @param impl_ The address of the initial implementation contract.
     * @param initData_ Optional initialization data to delegatecall to the implementation.
     */
    constructor(address impl_, bytes memory initData_) payable Proxy2Step(impl_) {
        require(impl_ != address(0), "Invalid impl address");
        if (initData_.length != 0) {
            (bool success,) = impl_.delegatecall(initData_);
            require(success, "init failed");
        }
    }
}