/**
 *Submitted for verification at Etherscan.io on 2024-09-09
*/

// File: @api3/airnode-protocol-v1/contracts/api3-server-v1/proxies/interfaces/IProxy.sol


pragma solidity ^0.8.0;

/// @dev See DapiProxy.sol for comments about usage
interface IProxy {
    function read() external view returns (int224 value, uint32 timestamp);

    function api3ServerV1() external view returns (address);
}

// File: @api3/contracts/v0.8/interfaces/IProxy.sol


pragma solidity ^0.8.0;


// File: contracts/ExchangeRateAdaptor/ExchangeRateAgETH.sol


pragma solidity 0.8.17;


interface rsETHReader {
    function rsETHPrice() external view returns (uint256);
}


contract ExchangeRateAdaptor {  

   // Updating the proxy address is a security-critical action which is why
   // we have made it immutable.
   address public immutable agETH_to_rsETH_proxy;
   address public immutable rsETH_address;

   constructor(address _agETH_to_rsETH_proxy, address _rsETH_address) {
       agETH_to_rsETH_proxy = _agETH_to_rsETH_proxy;
       rsETH_address = _rsETH_address;
   }

   function read() public view returns (int224 value, uint32 timestamp) {
       (int224 agETH_to_rsETH_value,uint32 agETH_to_rsETH_timestamp) = IProxy(agETH_to_rsETH_proxy).read();
       (uint256 rsETH_to_ETH_value) = rsETHReader(rsETH_address).rsETHPrice();
        require(
            agETH_to_rsETH_timestamp + 1 days > block.timestamp,
            "Timestamp older than one day"
        );
       int256 int_rsETH_to_ETH_value = int256(rsETH_to_ETH_value); 
       value = agETH_to_rsETH_value * int224(int_rsETH_to_ETH_value) / 10**18 ;
       timestamp = agETH_to_rsETH_timestamp;
   }

    function read_agETH_to_rsETH() external view returns (int224 value, uint32 timestamp) {
       (value,timestamp) = IProxy(agETH_to_rsETH_proxy).read();
   }

    function read_rsETH_to_ETH() external view returns (uint256 value) {
       (value) = rsETHReader(rsETH_address).rsETHPrice();
   }

    function read_agETH_to_ETH() external view returns (int224 value, uint32 timestamp) {
       (value,timestamp) = read();
   }
}