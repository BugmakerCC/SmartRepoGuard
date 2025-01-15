// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;


interface IOracle {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}


contract CometOracle is IOracle {

    IOracle internal constant oracle = IOracle(0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5);

    function decimals() external override pure returns (uint8) {
        return 18;
    }

    function latestRoundData() 
        external 
        override 
        view 
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            (
                roundId,
                answer,
                startedAt,
                updatedAt,
                answeredInRound
            ) = oracle.latestRoundData();

            answer *= 1e10;
        }
}