// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartToken {
    function prepapreClaim() external;
    function claim() external;
}

contract BatchClaimer {
    function batchClaim() external {
        // Hardcoded token address for your $SMART token contract
        ISmartToken smartToken = ISmartToken(0x91fF962f7DE9865D3ca8CA151BAc28969F52F34b);
        // Execute both functions in a single call
        smartToken.prepapreClaim();
        smartToken.claim();
    }
}