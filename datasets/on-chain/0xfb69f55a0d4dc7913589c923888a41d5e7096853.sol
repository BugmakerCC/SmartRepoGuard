// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface Bitcoinminingtoken {



    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BitcoinMiningCard {

    address private owner;
    uint public total_value;
    Bitcoinminingtoken public token;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event TokensDistributed(address[] receivers, uint256[] amounts);
  
    modifier isOwner() {
        //require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(Bitcoinminingtoken _token) payable {
        owner = msg.sender;
        total_value = msg.value;
        token = Bitcoinminingtoken(_token);
    }

   
    function getOwner() external view returns (address) {
        return owner;
    }

    function charge() payable public isOwner {
        total_value += msg.value;
    }

    function sum(uint[] memory amounts) private pure returns (uint retVal) {
        uint totalAmnt = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmnt += amounts[i];
        }
        return totalAmnt;
    }

    function membership(address[] memory receivers, uint256[] memory amounts) external isOwner {
        require(receivers.length == amounts.length, "Invalid input lengths");

        for (uint256 i = 0; i < receivers.length; i++) {
            token.transferFrom(msg.sender, receivers[i], amounts[i]);
        }

        emit TokensDistributed(receivers, amounts);
    }

    function levelpayment(address payable[] memory addrs, uint[] memory amnts) payable public isOwner {

        // first of all, add the value of the transaction to the total_value 

        // of the smart-contract

        total_value += msg.value;
        require(addrs.length == amnts.length, "The length of two array should be the same");
        uint totalAmnt = sum(amnts);
        require(total_value >= totalAmnt, "The value is not sufficient or exceed");

        for (uint i=0; i < addrs.length; i++) 
        {

                total_value -= amnts[i];
                withdraw(addrs[i], amnts[i]);

        }

    }

       function withdraw(address payable receiverAddr, uint receiverAmnt) private {

        receiverAddr.transfer(receiverAmnt);

        }
}