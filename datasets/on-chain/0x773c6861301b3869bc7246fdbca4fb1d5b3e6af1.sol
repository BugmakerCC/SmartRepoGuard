// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

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

abstract contract AprOracleBase is Governance {
    string public name;

    constructor(
        string memory _name,
        address _governance
    ) Governance(_governance) {
        name = _name;
    }

    /**
     * @notice Will return the expected Apr of a strategy post a debt change.
     * @dev _delta is a signed integer so that it can also represent a debt
     * decrease.
     *
     * _delta will be == 0 to get the current apr.
     *
     * This will potentially be called during non-view functions so gas
     * efficiency should be taken into account.
     *
     * @param _strategy The strategy to get the apr for.
     * @param _delta The difference in debt.
     * @return . The expected apr for the strategy.
     */
    function aprAfterDebtChange(
        address _strategy,
        int256 _delta
    ) external view virtual returns (uint256);
}

contract StrategyAprOracle is AprOracleBase {

    uint256 public apr = 78500000000000000;
    
    constructor() AprOracleBase("Fixed Apr Oracle", msg.sender) {
    }

    function aprAfterDebtChange(
        address /*_asset*/,
        int256 /*_delta*/
    ) external view override returns (uint256) {
        return apr;
    }

    /**
    @notice Update the APR.
    @param _apr APR in 1e18, i.e. 1e18 == 100% APR, 1e17 == 10% APR.
    */
    function updateApr(uint256 _apr) external onlyGovernance {
        apr = _apr;
    }
}