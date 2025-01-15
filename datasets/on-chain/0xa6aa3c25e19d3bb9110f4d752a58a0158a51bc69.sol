// File: contracts/Proxy.sol

interface Factory {
    function getWalletImplementationAddress() external view returns (address);
}

contract WalletProxy {
    Factory public immutable FACTORY;
    event FoundDelegateCall();

    constructor(address _factory) {
        FACTORY = Factory(_factory);
    }

    fallback() external payable {
        address implementation = FACTORY.getWalletImplementationAddress();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function getImplementation() external view returns (address) {
        return FACTORY.getWalletImplementationAddress();
    }
}

// File: contracts/interface/IWallet.sol

interface IWallet {
    function getWalletInfo()
        external
        view
        returns (
            address _deployer,
            address _walletFactory,
            address _owner,
            address _coldWallet,
            address _coldWalletAdmin,
            uint256 _nonce,
            string memory _cif
        );

    function changeColdWalletAddress(address _newColdWalletAddress) external;

    function changeColdWalletAdmin(address _newColdWalletAdmin) external;

    function toColdWallet(
        address _tokenAddress,
        address _depositerAddress,
        address _refundAddress,
        uint256 _transferAmount,
        uint256 _uid
    ) external;

    function approveAddress(
        address _tokenAddress,
        address _approveAddress,
        uint256 _approvalAmount
    ) external;

    function approveFund(
        address _tokenAddress,
        uint256 _transferAmount
    ) external returns (bool success);

    function changeSettingAddress(address _address) external returns (bool);

    function initialize(
        address _factory,
        address _deployer,
        address _owner,
        uint256 _nonce,
        string memory _cif
    ) external;
}

// File: contracts/utils/Context.sol

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

// File: contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

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

// File: contracts/access/Ownable.sol

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

// File: contracts/WalletFactory.sol

contract WalletFactory is Ownable, ReentrancyGuard {
    bool isUserAllowedToUsePKeys;
    address wallet_impl;
    address wallet_proxy;
    address middleware;
    address middlewareAdmin;

    // user => userCIF => walletNonce => walletAddress
    mapping(address walletOwner => mapping(string walletCif => mapping(uint256 nonce => address walletAddress)))
        public userWallet;

    // user nonce for wallet
    mapping(address _user => uint256 _nonce) userNonce;
    // user => cif
    mapping(address _owner => string cif) ownerToCif;
    // cif => user
    mapping(string cif => address _owner) cifToOwner;
    // user => mstore
    mapping(address _owner => uint256 _mstore) userToMNumber;
    // mstore => user
    mapping(uint256 _mstore => address _owner) mNumberToUser;
    mapping(address => bool) deployer;

    event WalletCreated(
        address indexed wallet,
        address owner,
        uint256 indexed nonce,
        string indexed cif
    );
    event WalletImplementationAddressChanged(address _from, address _to);
    event PKStatusChanged(bool _from, bool _to);
    event MiddlewareAddressChanged(address _from, address _to);
    event MiddlewareAdminAddressChanged(address _from, address _to);
    event DeployerRoleAccess(address account, bool granted);

    error CIFUsed(address ownerAddress);
    error UserUsedWithMNumber(uint256 index);
    error MNumberUsed(address ownerAddress);
    error CIFMissmatch();
    error InvalidCIF();
    error UserMissmatchWithCIF();
    error ArrayLengthMismatch();
    error NOTDeployer();

    modifier onlyDeployer() {
        if (!deployer[msg.sender]) {
            revert NOTDeployer();
        }
        _;
    }

    constructor(
        address _implementation,
        address _proxy,
        address _deployer
    ) Ownable(_deployer) {
        wallet_impl = _implementation;
        wallet_proxy = _proxy;
        deployer[_deployer] = true;
        emit DeployerRoleAccess(_deployer, true);
    }

    function grantDeployerRole(address account) public onlyOwner {
        emit DeployerRoleAccess(account, true);
        deployer[account] = true;
    }

    function revokeDeployerRole(address account) public onlyOwner {
        emit DeployerRoleAccess(account, false);
        deployer[account] = false;
    }

    /// @notice This function, updates the contract's implementation address.
    /// @param _newAddress The address of the new implementation contract.
    function changeWalletImplementationAddress(
        address _newAddress
    ) external onlyOwner {
        emit WalletImplementationAddressChanged(wallet_impl, _newAddress);
        wallet_impl = _newAddress;
    }

    function setMiddlewareAdminAddress(address _newAddress) external onlyOwner {
        emit MiddlewareAdminAddressChanged(middlewareAdmin, _newAddress);
        middlewareAdmin = _newAddress;
    }

    function setMiddlewareAddress(address _newAddress) external onlyOwner {
        emit MiddlewareAddressChanged(middleware, _newAddress);
        middleware = _newAddress;
    }

    /// @notice This function, enables or disables user permission to utilize private keys.
    function toggelPKStatus() external onlyOwner {
        emit PKStatusChanged(!isUserAllowedToUsePKeys, isUserAllowedToUsePKeys);
        isUserAllowedToUsePKeys = !isUserAllowedToUsePKeys;
    }

    /// @notice This function, creates a new smart wallet contract for a user.
    /// @param _owner Address of the user who will own the new wallet.
    /// @param _mStore Index associated with the user's mnemonics (potentially used for key generation).
    /// @param _cif cif number of the owner (user).
    function createWallet(
        address _owner,
        uint256 _mStore,
        string memory _cif
    ) external nonReentrant onlyDeployer returns (address wallet) {
        if (bytes(ownerToCif[_owner]).length == 0) {
            if (bytes(_cif).length == 0) {
                revert InvalidCIF();
            }
            if (cifToOwner[_cif] != address(0)) {
                revert CIFUsed(cifToOwner[_cif]);
            }
            if (userToMNumber[_owner] != 0) {
                revert UserUsedWithMNumber(userToMNumber[_owner]);
            }
            if (mNumberToUser[_mStore] != address(0)) {
                revert MNumberUsed(mNumberToUser[_mStore]);
            }

            ownerToCif[_owner] = _cif;
            cifToOwner[_cif] = _owner;
            userToMNumber[_owner] = _mStore;
            mNumberToUser[_mStore] = _owner;
        } else {
            if (!compare(ownerToCif[_owner], _cif)) {
                revert CIFMissmatch();
            }

            if (cifToOwner[_cif] != _owner) {
                revert UserMissmatchWithCIF();
            }
        }

        uint256 _nonce = userNonce[_owner];

        wallet = deployWallet(address(this), _owner, _nonce, _cif);

        userWallet[_owner][_cif][_nonce] = wallet;

        userNonce[_owner] += 1;

        emit WalletCreated(wallet, _owner, _nonce, _cif);
    }

    /// @notice This function deploys a new wallet contract.
    function deployWallet(
        address _deployer,
        address _owner,
        uint256 _nonce,
        string memory _cif
    ) internal returns (address) {
        bytes32 salt = keccak256(
            abi.encodePacked(_deployer, _owner, _nonce, _cif)
        );

        WalletProxy proxy = new WalletProxy{salt: salt}(address(this));

        IWallet(address(proxy)).initialize(
            address(this),
            _deployer,
            _owner,
            _nonce,
            _cif
        );

        return address(proxy);
    }

    /// @notice This function retrieves an array of wallet addresses associated with a specific user and CIF.
    /// @param _walletOwner Address of the user for whom to retrieve wallet addresses.
    /// @param _cif owner cif
    function getBatchWalletForUser(
        address _walletOwner,
        string memory _cif
    ) external view returns (address[] memory) {
        uint lastIndex = userNonce[_walletOwner];

        address[] memory addresses = new address[](lastIndex);
        for (uint256 i = 0; i < lastIndex; i++) {
            addresses[i] = userWallet[_walletOwner][_cif][i];
        }
        return addresses;
    }

    /// @notice This function retrieves an array of wallet addresses for a specified list of users, CIFs, and a single nonce.
    /// @param _walletOwner (list of addresses): Array containing wallet owner addresses.
    /// @param _cif (list of strings): Array containing CIF numbers corresponding to each owner in the `_walletOwner` list.
    /// @param _nonce (uint256): Specific nonce value to retrieve the associated wallet addresses.
    function getBatchWalletForMultipleUsers(
        address[] memory _walletOwner,
        string[] memory _cif,
        uint256 _nonce
    ) external view returns (address[] memory) {
        if (_walletOwner.length != _cif.length) {
            revert ArrayLengthMismatch();
        }
        address[] memory addresses = new address[](_walletOwner.length);

        for (uint256 i = 0; i < _walletOwner.length; i++) {
            addresses[i] = userWallet[_walletOwner[i]][_cif[i]][_nonce];
        }
        return addresses;
    }

    /// @notice This function retrieves the address of a specific wallet contract associated with a user.
    /// @param _address Address of the user who owns the wallet.
    /// @param _nonce Nonce value associated with the desired wallet.
    /// @param _cif owner CIF.
    function getWalletAddressOfOwner(
        address _address,
        uint256 _nonce,
        string memory _cif
    ) external view returns (address) {
        return userWallet[_address][_cif][_nonce];
    }

    /// @notice This function retrieves the current nonce associated with a specific user.
    /// @param _user Address of the user for whom to retrieve the nonce.
    function getUserNonce(address _user) external view returns (uint256) {
        return userNonce[_user];
    }

    /// @notice This function retrieves the CIF number associated with a specific user address.
    /// @param _user Address of the user for whom to retrieve the CIF number.
    function getUserCIF(address _user) external view returns (string memory) {
        return ownerToCif[_user];
    }

    /// @notice This function retrieves the address of the user associated with a specific (CIF) number.
    /// @param _cif The CIF number for which to retrieve the user address.
    function getCIFtoUser(string memory _cif) external view returns (address) {
        return cifToOwner[_cif];
    }

    /// @notice This function retrieves the mnemonics store number associated with a specific user address.
    /// @param _user Address of the user for whom to retrieve the mnemonics store number.
    function getMStoreNumberFromUser(
        address _user
    ) external view returns (uint256) {
        return userToMNumber[_user];
    }

    /// @notice This function retrieves the address of the user associated with a specific mnemonics store number.
    /// @param _mStoreNumber The mnemonics store number for which to retrieve the user address.
    function getUserFromMStoreNumber(
        uint256 _mStoreNumber
    ) external view returns (address) {
        return mNumberToUser[_mStoreNumber];
    }

    /// @notice This function compares the string equality of two provided strings.
    /// @param str1 The first string for comparison.
    /// @param str2 The second string for comparison.
    function compare(
        string memory str1,
        string memory str2
    ) public pure returns (bool) {
        if (bytes(str1).length != bytes(str2).length) {
            return false;
        }
        return
            keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2));
    }

    /// @notice This function returns the address of the wallet implementation contract.
    function getWalletImplementationAddress() external view returns (address) {
        return wallet_impl;
    }

    /// @notice This function returns the address of the wallet proxy contract.
    function getWalletProxy() external view returns (address) {
        return wallet_proxy;
    }

    /// @notice This function retrieves the current permission status for user utilization of private keys.
    function getPKStatus() external view returns (bool) {
        return isUserAllowedToUsePKeys;
    }

    function getMiddlewareAdminAddress() external view returns (address) {
        return middlewareAdmin;
    }

    function getMiddlewareWalletAddress() external view returns (address) {
        return middleware;
    }
}