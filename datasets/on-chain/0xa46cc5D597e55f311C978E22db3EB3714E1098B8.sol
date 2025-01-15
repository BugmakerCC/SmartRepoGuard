// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ENSNameHasher {
    /**
     * @dev Computes the namehash of an ENS domain string.
     * @notice The domain string must be provided in Punycode (ASCII-compatible encoding)
     * to correctly handle Unicode characters. Convert Unicode domains to Punycode before calling.
     * @param domain The ENS domain string in Punycode format to hash.
     * @return The node hash of the domain.
     */
    function namehash(string memory domain) public pure returns (bytes32) {
        bytes memory domainBytes = bytes(domain);
        require(domainBytes.length > 0, "ENSNameHasher: empty domain");

        // Validate that all characters are ASCII
        for (uint256 i = 0; i < domainBytes.length; i++) {
            require(
                uint8(domainBytes[i]) < 0x80,
                "ENSNameHasher: domain must be in Punycode format (ASCII only)"
            );
        }

        // Split the domain into labels
        bytes32 node = 0x0;
        uint256 length = domainBytes.length;
        uint256 start = 0;

        while (start < length) {
            uint256 end = start;
            while (end < length && domainBytes[end] != ".") {
                end++;
            }

            // Create a bytes array to hold the label
            bytes memory labelBytes = new bytes(end - start);
            for (uint256 i = start; i < end; i++) {
                labelBytes[i - start] = domainBytes[i];
            }

            bytes32 label = keccak256(labelBytes);
            node = keccak256(abi.encodePacked(node, label));

            start = end + 1;
        }

        return node;
    }
}