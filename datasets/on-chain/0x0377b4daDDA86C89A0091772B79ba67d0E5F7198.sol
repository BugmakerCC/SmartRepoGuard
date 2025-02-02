// SPDX-License-Identifier: GNU AGPLv3
pragma solidity >=0.8.18;

// lib/tokenized-strategy-periphery/src/utils/Governance.sol

contract Governance {
    /// @notice Emitted when the governance address is updated.
    event GovernanceTransferred(
        address indexed previousGovernance,
        address indexed newGovernance
    );

    modifier onlyGovernance() {
        _checkGovernance();
        _;
    }

    /// @notice Checks if the msg sender is the governance.
    function _checkGovernance() internal view virtual {
        require(governance == msg.sender, "!governance");
    }

    /// @notice Address that can set the default base fee and provider
    address public governance;

    constructor(address _governance) {
        governance = _governance;

        emit GovernanceTransferred(address(0), _governance);
    }

    /**
     * @notice Sets a new address as the governance of the contract.
     * @dev Throws if the caller is not current governance.
     * @param _newGovernance The new governance address.
     */
    function transferGovernance(
        address _newGovernance
    ) external virtual onlyGovernance {
        require(_newGovernance != address(0), "ZERO ADDRESS");
        address oldGovernance = governance;
        governance = _newGovernance;

        emit GovernanceTransferred(oldGovernance, _newGovernance);
    }
}

// lib/tokenized-strategy-periphery/src/utils/Governance2Step.sol

contract Governance2Step is Governance {
    /// @notice Emitted when the pending governance address is set.
    event UpdatePendingGovernance(address indexed newPendingGovernance);

    /// @notice Address that is set to take over governance.
    address public pendingGovernance;

    constructor(address _governance) Governance(_governance) {}

    /**
     * @notice Sets a new address as the `pendingGovernance` of the contract.
     * @dev Throws if the caller is not current governance.
     * @param _newGovernance The new governance address.
     */
    function transferGovernance(
        address _newGovernance
    ) external virtual override onlyGovernance {
        require(_newGovernance != address(0), "ZERO ADDRESS");
        pendingGovernance = _newGovernance;

        emit UpdatePendingGovernance(_newGovernance);
    }

    /**
     * @notice Allows the `pendingGovernance` to accept the role.
     */
    function acceptGovernance() external virtual {
        require(msg.sender == pendingGovernance, "!pending governance");

        emit GovernanceTransferred(governance, msg.sender);

        governance = msg.sender;
        pendingGovernance = address(0);
    }
}

// src/registry/ReleaseRegistry.sol

interface IFactory {
    function apiVersion() external view returns (string memory);
}

interface ITokenizedStrategy {
    function apiVersion() external view returns (string memory);
}

/**
 * @title YearnV3 Release Registry
 * @author yearn.finance
 * @notice
 *  Used by Yearn Governance to track on chain all
 *  releases of the V3 vaults by API Version.
 */
contract ReleaseRegistry is Governance2Step {
    event NewRelease(
        uint256 indexed releaseId,
        address indexed factory,
        address indexed tokenizedStrategy,
        string apiVersion
    );

    string public constant name = "Yearn V3 Release Registry";

    // The total number of releases that have been deployed
    uint256 public numReleases;

    // Mapping of release id starting at 0 to the address
    // of the corresponding factory for that release.
    mapping(uint256 => address) public factories;

    // Mapping of release id starting at 0 to the address
    // of the corresponding Tokenized Strategy for that release.
    mapping(uint256 => address) public tokenizedStrategies;

    // Mapping of the API version for a specific release to the
    // place in the order it was released.
    mapping(string => uint256) public releaseTargets;

    constructor(address _governance) Governance2Step(_governance) {}

    /**
     * @notice Returns the latest factory.
     * @return The address of the factory for the latest release.
     */
    function latestFactory() external view virtual returns (address) {
        uint256 _numReleases = numReleases;
        if (_numReleases == 0) return address(0);
        return factories[numReleases - 1];
    }

    /**
     * @notice Returns the latest tokenized strategy.
     * @return The address of the tokenized strategy for the latest release.
     */
    function latestTokenizedStrategy() external view virtual returns (address) {
        uint256 _numReleases = numReleases;
        if (_numReleases == 0) return address(0);
        return tokenizedStrategies[numReleases - 1];
    }

    /**
     * @notice Returns the api version of the latest release.
     * @return The api version of the latest release.
     */
    function latestRelease() external view virtual returns (string memory) {
        uint256 _numReleases = numReleases;
        if (_numReleases == 0) return "";
        return IFactory(factories[numReleases - 1]).apiVersion();
    }

    /**
     * @notice Issue a new release using a deployed factory.
     * @dev Stores the factory address in `factories` and the release
     * target in `releaseTargets` with its associated API version.
     *
     *   Throws if caller isn't `governance`.
     *   Throws if the api version is the same as the previous release.
     *   Throws if the factory does not have the same api version as the tokenized strategy.
     *   Emits a `NewRelease` event.
     *
     * @param _factory The factory that will be used create new vaults.
     */
    function newRelease(
        address _factory,
        address _tokenizedStrategy
    ) external virtual onlyGovernance {
        // Check if the release is different from the current one
        uint256 releaseId = numReleases;

        string memory apiVersion = IFactory(_factory).apiVersion();
        string memory tokenizedStrategyApiVersion = ITokenizedStrategy(
            _tokenizedStrategy
        ).apiVersion();

        require(
            keccak256(bytes(apiVersion)) ==
                keccak256(bytes(tokenizedStrategyApiVersion)),
            "ReleaseRegistry: api version mismatch"
        );

        if (releaseId > 0) {
            // Make sure this isn't the same as the last one
            require(
                keccak256(
                    bytes(IFactory(factories[releaseId - 1]).apiVersion())
                ) != keccak256(bytes(apiVersion)),
                "ReleaseRegistry: same api version"
            );
        }

        // Update latest release.
        factories[releaseId] = _factory;
        tokenizedStrategies[releaseId] = _tokenizedStrategy;

        // Set the api to the target.
        releaseTargets[apiVersion] = releaseId;

        // Increase our number of releases.
        numReleases = releaseId + 1;

        // Log the release for external listeners
        emit NewRelease(releaseId, _factory, _tokenizedStrategy, apiVersion);
    }
}