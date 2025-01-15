// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract RoarIco {
    uint256 public txNonce;

    IERC20 public token = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address public teamAddress = 0x8eB2523a910C6915B00b1716e20335f85f35b0A6;

    struct InfoByNonce {
        address user;
        string solAddress;
        uint256 amountEth;
        uint256 amountUsdt;
    }

    mapping(uint256 => InfoByNonce) public infoByNonce;
    event Buy(string, address, uint256);

    function buy(string memory solAddress, uint256 amount, bool isUsdt) public payable {
        if (!isUsdt) {
            require(
                msg.value >= 1e15,
                "ROAR_ICO: Amount must be grater then 1e15.."
            );
            amount = msg.value;
            payable(teamAddress).transfer(address(this).balance);
        } else {
            require(amount > 0, "ROAR_ICO: Amount must be grater then zero..");
            bool succes = token.transferFrom(msg.sender, address(this), amount);
            succes = token.transfer(teamAddress, amount);
            require(succes, "ERC20 token transfer error");
        }
        txNonce += 1;

        infoByNonce[txNonce].user = msg.sender;
        infoByNonce[txNonce].solAddress = solAddress;
        if (isUsdt) {
            infoByNonce[txNonce].amountUsdt = amount;
        } else {
            infoByNonce[txNonce].amountEth = amount;
        }

        emit Buy(solAddress, msg.sender, amount);
    }

    function updateTeamAddress(address _teamAddress) public {
        require(msg.sender == _teamAddress, "You can't update.");
        teamAddress = _teamAddress;
    }

    receive() external payable {
        payable(teamAddress).transfer(address(this).balance);
    }
}