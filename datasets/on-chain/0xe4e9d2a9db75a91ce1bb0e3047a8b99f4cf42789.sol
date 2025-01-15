// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

interface ICompounder {
    function vault() external view returns (address);
    function management() external view returns (address);
}

interface IAprOracle {
     function getWeightedAverageApr(
        address _vault,
        int256 _delta
    ) external view returns (uint256);
}

interface IVault {
    function accountant() external view returns (address);
}

interface IAccountant {
    struct Fee {
        uint16 managementFee; // Annual management fee to charge.
        uint16 performanceFee; // Performance fee to charge.
        uint16 refundRatio; // Refund ratio to give back on losses.
        uint16 maxFee; // Max fee allowed as a percent of gain.
        uint16 maxGain; // Max percent gain a strategy can report.
        uint16 maxLoss; // Max percent loss a strategy can report.
        bool custom; // Flag to set for custom configs.
    }

    function getVaultConfig(
        address vault
    ) external view returns (Fee memory fee);
}

contract CompounderOracle {

    uint256 public constant MAX_BPS = 10_000;

    address public constant APR_ORACLE = 0x1981AD9F44F2EA9aDd2dC4AD7D075c102C70aF92;

    mapping (address => address) public remappings;

    function aprAfterDebtChange(
        address _strategy,
        int256 _delta
    ) external view virtual returns (uint256 _apr) {
        address vault = remappings[_strategy];

        if (vault == address(0)) {
            vault = ICompounder(_strategy).vault();
        }

        _apr = IAprOracle(APR_ORACLE).getWeightedAverageApr(vault, _delta);

        address accountant = IVault(vault).accountant();

        if (accountant != address(0)) {
            uint16 perfFee = IAccountant(accountant).getVaultConfig(vault).performanceFee;
            _apr = _apr * (MAX_BPS - perfFee) / MAX_BPS;
        }
    }

    function setRemapping(address _strategy, address _vault) external {
        require(msg.sender == ICompounder(_strategy).management());
        remappings[_strategy] = _vault;
    }

}