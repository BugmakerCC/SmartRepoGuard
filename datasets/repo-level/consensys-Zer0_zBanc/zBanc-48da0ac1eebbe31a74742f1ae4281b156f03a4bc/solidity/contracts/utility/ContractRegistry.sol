// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;
import "./Owned.sol";
import "./Utils.sol";
import "./interfaces/IContractRegistry.sol";

/**
  * @dev Contract Registry
  *
  * The contract registry keeps contract addresses by name.
  * The owner can update contract addresses so that a contract name always points to the latest version
  * of the given contract.
  * Other contracts can query the registry to get updated addresses instead of depending on specific
  * addresses.
  *
  * Note that contract names are limited to 32 bytes UTF8 encoded ASCII strings to optimize gas costs
*/
contract ContractRegistry is IContractRegistry, Owned, Utils {
    struct RegistryItem {
        address contractAddress;    // contract address
        uint256 nameIndex;          // index of the item in the list of contract names
    }

    mapping (bytes32 => RegistryItem) private items;    // name -> RegistryItem mapping
    string[] public contractNames;                      // list of all registered contract names

    /**
      * @dev triggered when an address pointed to by a contract name is modified
      *
      * @param _contractName    contract name
      * @param _contractAddress new contract address
    */
    event AddressUpdate(bytes32 indexed _contractName, address _contractAddress);

    /**
      * @dev returns the number of items in the registry
      *
      * @return number of items
    */
    function itemCount() public view returns (uint256) {
        return contractNames.length;
    }

    /**
      * @dev returns the address associated with the given contract name
      *
      * @param _contractName    contract name
      *
      * @return contract address
    */
    function addressOf(bytes32 _contractName) public view override returns (address) {
        return items[_contractName].contractAddress;
    }

    /**
      * @dev registers a new address for the contract name in the registry
      *
      * @param _contractName     contract name
      * @param _contractAddress  contract address
    */
    function registerAddress(bytes32 _contractName, address _contractAddress)
        public
        ownerOnly
        validAddress(_contractAddress)
    {
        // validate input
        require(_contractName.length > 0, "ERR_INVALID_NAME");

        // check if any change is needed
        address currentAddress = items[_contractName].contractAddress;
        if (_contractAddress == currentAddress)
            return;

        if (currentAddress == address(0)) {
            // update the item's index in the list
            items[_contractName].nameIndex = contractNames.length;

            // add the contract name to the name list
            contractNames.push(bytes32ToString(_contractName));
        }

        // update the address in the registry
        items[_contractName].contractAddress = _contractAddress;

        // dispatch the address update event
        emit AddressUpdate(_contractName, _contractAddress);
    }

    /**
      * @dev removes an existing contract address from the registry
      *
      * @param _contractName contract name
    */
    function unregisterAddress(bytes32 _contractName) public ownerOnly {
        // validate input
        require(_contractName.length > 0, "ERR_INVALID_NAME");
        require(items[_contractName].contractAddress != address(0), "ERR_INVALID_NAME");

        // remove the address from the registry
        items[_contractName].contractAddress = address(0);

        // if there are multiple items in the registry, move the last element to the deleted element's position
        // and modify last element's registryItem.nameIndex in the items collection to point to the right position in contractNames
        if (contractNames.length > 1) {
            string memory lastContractNameString = contractNames[contractNames.length - 1];
            uint256 unregisterIndex = items[_contractName].nameIndex;

            contractNames[unregisterIndex] = lastContractNameString;
            bytes32 lastContractName = stringToBytes32(lastContractNameString);
            RegistryItem storage registryItem = items[lastContractName];
            registryItem.nameIndex = unregisterIndex;
        }

        // remove the last element from the name list
        contractNames.pop();
        // zero the deleted element's index
        items[_contractName].nameIndex = 0;

        // dispatch the address update event
        emit AddressUpdate(_contractName, address(0));
    }

    /**
      * @dev utility, converts bytes32 to a string
      * note that the bytes32 argument is assumed to be UTF8 encoded ASCII string
      *
      * @return string representation of the given bytes32 argument
    */
    function bytes32ToString(bytes32 _bytes) private pure returns (string memory) {
        bytes memory byteArray = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            byteArray[i] = _bytes[i];
        }

        return string(byteArray);
    }

    /**
      * @dev utility, converts string to bytes32
      * note that the bytes32 argument is assumed to be UTF8 encoded ASCII string
      *
      * @return string representation of the given bytes32 argument
    */
    function stringToBytes32(string memory _string) private pure returns (bytes32) {
        bytes32 result;
        assembly {
            result := mload(add(_string,32))
        }
        return result;
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function getAddress(bytes32 _contractName) public view returns (address) {
        return addressOf(_contractName);
    }
}
