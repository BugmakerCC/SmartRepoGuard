// SPDX-License-Identifier: GPL-3.0

// Contracts are written by @Dexaran (twitter.com/Dexaran github.com/Dexaran)
// Read more about ERC-223 standard here: dexaran.github.io/erc223

// D223 is a token of Dex223.io exchange.

pragma solidity >=0.8.2;

abstract contract IERC223 {

    function name()        public view virtual returns (string memory);
    function symbol()      public view virtual returns (string memory);
    function decimals()    public view virtual returns (uint8);
    function totalSupply() public view virtual returns (uint256);
    function standard()    public view virtual returns (uint32);

    /**
     * @dev Returns the balance of the `who` address.
     */
    function balanceOf(address who) public virtual view returns (uint);

    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address
     * and returns `true` on success.
     */
    function transfer(address to, uint value) public virtual returns (bool success);

    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
     * and returns `true` on success.
     */
    function transfer(address to, uint value, bytes calldata data) public payable virtual returns (bool success);

     /**
     * @dev Event that is fired on successful transfer.
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event TransferData(bytes);
}

contract D223Upgrading
{
    address public d223_old = 0xcCe968120e6Ded56F32fbfe5A2Ec06CBF1e7c8ED; // Address on Ethereum mainnet.
    address public d223_new = 0x0908078Da2935A14BC7a17770292818C85b580dd; // New address of D223 on ETH mainnet.
    address public creator = msg.sender;

    function tokenReceived(address _from, uint256 _amount, bytes memory _data) public returns (bytes4)
    {
        // Only allow deposits of legacy D223 tokens by users
        // or deposit of the new D223 tokens by the creator of the contract.
        // Otherwise revert the tx.
        if(msg.sender == d223_new)
        {
            require(_from == creator);
        }
        else 
        {
            require(msg.sender == d223_old, "Wrong token");
            // Send equal amount of new D223 tokens to the sender of the original D223 tokens.
            IERC223(d223_new).transfer(_from, _amount);
        }

        // Store the original D223 tokens on the address of the contract permanently.

        return 0x8943ec02;
    }

    function extract(address _token, uint256 _amount) external
    {
        require(msg.sender == creator);
        IERC223(_token).transfer(creator, _amount);
    }
}