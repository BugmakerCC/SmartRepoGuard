// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

interface IVault {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

contract FlashLoanRecipient is IFlashLoanRecipient {
    IVault private constant vault = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    address public  owner;

    constructor() {
        owner = msg.sender;
    }


    function makeFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) public {
        vault.flashLoan(this, tokens, amounts, userData);
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == address(vault), "Invalid vault address");

        (address[] memory targets, bytes[] memory callsData) = abi.decode(userData, (address[], bytes[]));

        aggregate(targets, callsData);

        for (uint256 i = 0; i < tokens.length; i++) {
            require(
                IERC20(tokens[i]).transfer(address(vault), amounts[i] + feeAmounts[i]),
                "Token repayment failed"
            );
        }
    }

    function aggregate(address[] memory targets, bytes[] memory data) public payable returns (bytes[] memory returnData) {
        returnData = new bytes[](targets.length);
        
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory ret) = targets[i].call(data[i]);
            require(success, "Call failed");
            returnData[i] = ret;
        }
    }


    //If the tokens approve, Call Make Flashloan Directly
    function MasterSwap (
        address[] memory tokens,    
        address[] memory spenders, 
        uint256[] memory amounts,
        address[] memory flash_tokens,
        uint256[] memory loan_values,        
        bytes memory data        
    ) external onlyOwner() {
        
        for (uint256 i = 0; i < tokens.length; i++) {
            require(IERC20(tokens[i]).approve(spenders[i], amounts[i]), "Approval failed");
        }

        (bool success, ) = address(this).call(abi.encodeWithSignature(
            "makeFlashLoan(address[],uint256[],bytes)", 
            flash_tokens, loan_values, data
        ));
        require(success, "Flashloan failed");
    }

    
    function WithdrawToken (address token, uint256 _amount) external onlyOwner() {
        require(IERC20(token).transfer(msg.sender, _amount));
    }
       
    function approveERC20(
        address _token,
        address _spender,
        uint256 _amount
    ) public onlyOwner {

        require(IERC20(_token).approve(_spender, _amount), "ERC20 approval failed");
    }


    function withdrawEther(uint256 _amount) external onlyOwner() {
        require(address(this).balance >= _amount, "Insufficient Ether balance");
        payable(msg.sender).transfer(_amount);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call Func");
        _;
    }

    function changeOwner (address _newowner) external onlyOwner() {
        require(msg.sender == owner, 'Only Owner can make changes');
        owner = _newowner;
    }

}