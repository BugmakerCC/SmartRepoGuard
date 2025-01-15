// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     
    */

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}
contract transferchecker {
    uint256 public transferCount =0;
    function transferFrom(address from, address to, uint256 value)public returns(bool){
        transferCount++;
        return true;
    }
}