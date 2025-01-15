// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ENSNameHasher {
    /**
     * @dev Computes the namehash of an ENS domain string.
     * @notice The domain string must be provided in Punycode (ASCII-compatible encoding)
     * to correctly handle Unicode characters. Convert Unicode domains to Punycode before calling.
     * @param domain The ENS domain string in Punycode format to hash.
     * @return The node hash of the domain.
     */
    function namehash(string memory domain) public pure returns (bytes32) {
        bytes32 node = bytes32(0);

        if (bytes(domain).length > 0) {
            string memory name = normalize(domain);
            string[] memory labels = split(name, ".");

            for (uint256 i = labels.length; i > 0; i--) {
                node = keccak256(
                    abi.encodePacked(node, keccak256(bytes(labels[i - 1])))
                );
            }
        }

        return node;
    }

    /**
     * @dev Normalizes an ENS domain string by converting it to lowercase.
     * @param domain The ENS domain string to normalize.
     * @return The normalized domain string.
     */
    function normalize(
        string memory domain
    ) internal pure returns (string memory) {
        bytes memory domainBytes = bytes(domain);
        for (uint256 i = 0; i < domainBytes.length; i++) {
            // Convert uppercase ASCII letters to lowercase
            if (domainBytes[i] >= 0x41 && domainBytes[i] <= 0x5A) {
                domainBytes[i] = bytes1(uint8(domainBytes[i]) + 32);
            }
        }
        return string(domainBytes);
    }

    // Splits a string by a separator, returns an array of substrings
    function split(
        string memory str,
        string memory delim
    ) internal pure returns (string[] memory) {
        uint256 count = 1;
        uint256 delimLength = bytes(delim).length;

        // Count occurrences of delimiter
        for (uint256 i = 0; i < bytes(str).length - delimLength + 1; i++) {
            bool matchFound = true;
            for (uint256 j = 0; j < delimLength; j++) {
                if (bytes(str)[i + j] != bytes(delim)[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                count++;
                i += delimLength - 1;
            }
        }

        string[] memory parts = new string[](count);
        uint256 partIndex = 0;
        uint256 start = 0;

        // Split the string
        for (uint256 i = 0; i < bytes(str).length - delimLength + 1; i++) {
            bool matchFound = true;
            for (uint256 j = 0; j < delimLength; j++) {
                if (bytes(str)[i + j] != bytes(delim)[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                parts[partIndex] = substring(str, start, i);
                partIndex++;
                start = i + delimLength;
                i += delimLength - 1;
            }
        }

        parts[partIndex] = substring(str, start, bytes(str).length);
        return parts;
    }

    // Helper function to get a substring of a string
    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);

        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }

        return string(result);
    }
}