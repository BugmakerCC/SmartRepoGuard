pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract claimer {
    constructor(
        address tokenContract,
        address contractAddress,
        bytes4 functionSelector,
        bytes memory mintData
    ) {
        (bool success, ) = tokenContract.call(
            abi.encodePacked(functionSelector, mintData)
        );
        require(success, "Mint function call failed");

        IERC20 box = IERC20(tokenContract);

        box.transfer(contractAddress, box.balanceOf(address(this)));

        selfdestruct(payable(contractAddress));
    }
}

contract BatchMintLibs {
    address public commissionAddress;
    uint256 public commissionPercentage = 5;
    address public owner;

    constructor(address _commissionAddress) {
        commissionAddress = _commissionAddress;
        owner = msg.sender;
    }

    function setParams(
        uint _commissionPercentage,
        address _commissionAddress
    ) external {
        require(msg.sender == owner, "BatchMintLibs: caller is not the owner");
        commissionPercentage = _commissionPercentage;
        commissionAddress = _commissionAddress;
    }

    function mints(
        address tokenContract,
        uint count,
        address to,
        bytes4 functionSelector,
        bytes memory mintData
    ) external {
        IERC20 box = IERC20(tokenContract);

        uint256 totalMintedAmount = 0;

        for (uint i = 0; i < count; ) {
            new claimer(
                tokenContract,
                address(this),
                functionSelector,
                mintData
            );
            unchecked {
                i++;
            }
        }

        totalMintedAmount = box.balanceOf(address(this));
        uint256 commission = (totalMintedAmount * commissionPercentage) / 100;
        uint256 amountAfterCommission = totalMintedAmount - commission;
        box.transfer(to, amountAfterCommission);
        box.transfer(commissionAddress, commission);
    }
}