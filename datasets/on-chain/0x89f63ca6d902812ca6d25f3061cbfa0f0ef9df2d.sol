// File: contracts/dAPIs/vendor/AggregatorInterface.sol


pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}
// File: contracts/dAPIs/vendor/AggregatorV3Interface.sol


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
// File: contracts/dAPIs/vendor/AggregatorV2V3Interface.sol


pragma solidity ^0.8.0;



// solhint-disable-next-line interface-starts-with-i
interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

pragma solidity 0.8.17;


interface RateProvider {
    function getRate() external view returns (int256);
}

contract PartialAggregatorV2V3Interface is AggregatorV2V3Interface {
    error rateProviderAddressIsZero();

    error FunctionIsNotSupported();

    address public immutable rateProviderAddress;

    constructor(address rateProviderAddress_) {
        if (rateProviderAddress_ == address(0)) {
            revert rateProviderAddressIsZero();
        }
        rateProviderAddress = rateProviderAddress_;
    }

    function latestAnswer()
        external
        view
        virtual
        override
        returns (int256 value)
    {
        value = RateProvider(rateProviderAddress).getRate();
    }


    function latestTimestamp()
        external
        view
        virtual
        override
        returns (uint256 timestamp)
    {
        timestamp = block.timestamp;
    }

    function latestRound() external view virtual override returns (uint256) {
        revert FunctionIsNotSupported();
    }

    function getAnswer(
        uint256
    ) external view virtual override returns (int256) {
        revert FunctionIsNotSupported();
    }

    function getTimestamp(uint256) external view virtual returns (uint256) {
        revert FunctionIsNotSupported();
    }

    function decimals() external view virtual override returns (uint8) {
        return 18;
    }

    function description()
        external
        view
        virtual
        override
        returns (string memory)
    {
        return "";
    }

    function version() external view virtual override returns (uint256) {
        return 4913;
    }

    function getRoundData(
        uint80
    )
        external
        view
        virtual
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        revert FunctionIsNotSupported();
    }

    function latestRoundData()
        external
        view
        virtual
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        roundId = answeredInRound = 0;
        answer = RateProvider(rateProviderAddress).getRate();
        updatedAt = block.timestamp;
        startedAt = block.timestamp;
    }
}