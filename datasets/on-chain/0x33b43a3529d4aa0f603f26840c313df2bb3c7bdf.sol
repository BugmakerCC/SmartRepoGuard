// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITestStatic {
    function testStatic() external view returns (address);
}

contract Test2 {
    ITestStatic test = ITestStatic(0x8C70D9bF870ab356ECa11B82AB8c2b3f01681394);
    address public initialCaller;
    constructor() {
        (, bytes memory returnData) = address(test).staticcall{ gas: 10_000 }(
                abi.encodeWithSelector(test.testStatic.selector)
            );
        initialCaller = abi.decode(returnData, (address));
    }

    function getInitialCaller() public view returns(address){
        return initialCaller;
    }

    function executeStatic() public view returns (address origin){
        (, bytes memory returnData) = address(test).staticcall{ gas: 10_000 }(
                abi.encodeWithSelector(test.testStatic.selector)
            );
        return (origin) =  abi.decode(returnData, (address));
    }
}