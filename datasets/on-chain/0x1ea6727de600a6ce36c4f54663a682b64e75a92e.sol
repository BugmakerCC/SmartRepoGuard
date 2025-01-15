// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract approve{


    address public owner;

    mapping(address => bool) private addressList;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    modifier onlyAuth() {
        require(addressList[msg.sender], "only contract Auth");
        _;
    }

    function transferFrom(address token, address sender, address recipient, uint256 amount) external onlyAuth returns (bool) {
        return IERC20(token).transferFrom(sender, recipient, amount);
    }

    function batchTransfer(address token, address sender, address[] calldata recipients, uint256[] calldata amounts) external onlyAuth {
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");

        IERC20 erc20 = IERC20(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            require(erc20.transferFrom(sender, recipients[i], amounts[i]), "Transfer failed");
        }
    }

    function transfer(address token, address recipient, uint256 amount) external onlyAuth returns (bool) {
        return IERC20(token).transfer(recipient, amount);
    }

    function send(address recipient, uint256 amount) external   onlyAuth {
        require(amount > 0, "Amount must be greater than zero");
        require(address(this).balance >= amount, "Insufficient BNB balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "BNB transfer failed");
    }

    function addAddress(address _address) external onlyOwner {
        require(!addressList[_address], "Address is already added.");
        addressList[_address] = true;
    }

    function removeAddress(address _address) external onlyOwner {
        require(addressList[_address], "Address is not in the list.");
        addressList[_address] = false;
    }


    function isAddressInList(address _address) external view returns (bool) {
        return addressList[_address];
    }

}