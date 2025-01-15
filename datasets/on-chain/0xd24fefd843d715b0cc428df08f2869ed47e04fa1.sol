// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ENSResolverCaller {
    /**
     * @dev Resolves an ENS name to an Ethereum address using the PublicResolver contract.
     * @param resolverAddress The address of the PublicResolver contract.
     * @param node The node hash of the ENS name to resolve.
     * @return The Ethereum address associated with the ENS name.
     */
    function resolveAddress(
        address resolverAddress,
        bytes32 node
    ) external view returns (address) {
        // Ensure the resolver address is not zero
        require(
            resolverAddress != address(0),
            "ENSResolverCaller: resolver address cannot be zero"
        );

        // Call the addr function on the PublicResolver contract
        IPublicResolver resolver = IPublicResolver(resolverAddress);
        return resolver.addr(node);
    }
}

// Interface for the PublicResolver contract
interface IPublicResolver {
    function addr(bytes32 node) external view returns (address);
}