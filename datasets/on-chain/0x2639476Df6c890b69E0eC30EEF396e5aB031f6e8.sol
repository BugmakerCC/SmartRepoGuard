// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Main is Ownable {

    IERC20 public mintToken;

    constructor(address mintAddress){
        mintToken = IERC20(mintAddress);
    }

    function claimBalance() external {
        payable(owner()).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external  {
        IERC20(token).transfer(owner(), amount);
    }


    function getLastByteComparison() public view returns (uint) {
        bytes32 randomHash = keccak256(abi.encodePacked(
            msg.sender, 
            block.timestamp, 
            block.prevrandao, 
            block.number, 
            gasleft(),
            blockhash(block.number - 1)
        ));

        bytes1 lastByte = randomHash[31];
        bytes1 secondByte = randomHash[30];

        
        for (uint8 i = 0xa1; i <= 0xa8; i++) {
            if (lastByte == bytes1(i)) {
                return 5;
            }
        }

        for (uint8 j = 0xb1; j <= 0xb4; j++) { 
            if (lastByte == bytes1(j)) {
                return 20;
            }
        }

        if (lastByte == bytes1(0xc1)){
            return 50;
        }

        for (uint8 k = 0xa1; k <= 0xaf; k++) { 
            if (secondByte == bytes1(k) && lastByte == bytes1(0x11)) {
                return 100;
            }
        }

        return 0; 
    }





    receive() external payable {

        require(msg.sender == tx.origin, "Contracts are not allowed to send ETH");

        payable(owner()).transfer(msg.value);

        if (msg.value == 0.01 ether) {


            uint res = getLastByteComparison();


            if (res == 5) {
                mintToken.transferFrom(owner(),msg.sender,42069000 * 5 * 10 ** 18);
            } else if (res == 20) {
                mintToken.transferFrom(owner(),msg.sender,42069000 * 20 * 10 ** 18);
            } else if (res == 50) {
                mintToken.transferFrom(owner(),msg.sender,42069000 * 50 * 10 ** 18);
            } else if (res == 100){
                mintToken.transferFrom(owner(),msg.sender,42069000 * 100 * 10 ** 18);
            }

        } else {}        
    }

}