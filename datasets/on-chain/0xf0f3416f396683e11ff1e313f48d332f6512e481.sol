/*
    _____
   /     \
  | () () |
   \  ^  /
    |||||
    |||||

  https://knots.finance/ Proprietary
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ILoan {
    function transferCollateral(address borrower, uint256 amount) external;
}

contract InterlockingCollateral {
    struct Loan {
        uint256 collateral;
        address lender;
        bool isInterlocked;
    }

    mapping(address => Loan) public loans;
    ILoan public linkedLoanContract;
    uint256 private constant maxInterlocks = 4;

    function createLoan(address lender, uint256 collateral, bool interlock) external {
        loans[msg.sender] = Loan(collateral, lender, interlock);
        if (interlock) {
            interlockCollateral(lender, collateral, 0);
        }
    }

    function interlockCollateral(address lender, uint256 amount, uint256 depth) internal {
        if (depth >= maxInterlocks) return;

        uint256 splitAmount = amount / 2;
        linkedLoanContract.transferCollateral(lender, splitAmount);

        interlockCollateral(lender, splitAmount, depth + 1);
    }

    function repayLoan(address borrower) external {
        Loan memory loan = loans[borrower];
        require(loan.collateral > 0, "No loan to repay");
        loans[borrower].collateral = 0;
        payable(loan.lender).transfer(loan.collateral);
    }
}