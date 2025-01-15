// SPDX-License-Identifier: MIT

/*


██████╗░██████╗░██████╗░██╗░░██╗
██╔══██╗██╔═══╝░██╔══██╗██║░██╔╝
██████╔╝██████╗░██████╔╝█████╔╝░
██╔══██╗██╔═══╝░██╔══██╗██╔═██╗░
██████╔╝██████╗░██║░░██║██║░░██╗
╚═════╝░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝


$BERK: 4200 Defi Enthusiasts, Led by a Bold CEO, Gassed Their Gwei, and Crowned It the King of Defi Stonks. Long Live the Warren!

$BERK = Most Defi Efficient Coin

Socials: 

TG: https://t.me/BRK4200
X: https://x.com/BRK4200

*/

pragma solidity ^0.8.0;

contract BERK {
    uint    public supply            = 42000000*1e18;
    uint    public constant decimals = 18;
    uint    public constant MAX_INT  = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    string  public constant name     = "BERKSHIRE4200";
    string  public constant symbol   = "BERK";

    event  Approval(address indexed src, address indexed usr, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);

    mapping (address => uint)                       public  balance;
    mapping (address => mapping (address => uint))  public  allowance;

    constructor() {
        balance[msg.sender] = supply;
    }

    function totalSupply() public view returns (uint) {
        return supply;
    }

    function balanceOf(address usr) public view returns (uint) {
        return balance[usr];
    }

    function approve(address usr, uint wad) public returns (bool) {
        allowance[msg.sender][usr] = wad;

        emit Approval(msg.sender, usr, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        require(balance[src] >= wad, "No balance");

        if (src != msg.sender && allowance[src][msg.sender] != MAX_INT) {
            require(allowance[src][msg.sender] >= wad, "No allowance");
            allowance[src][msg.sender] -= wad;
        }

        balance[src] -= wad;
        balance[dst] += wad;

        emit Transfer(src, dst, wad);
        return true;
    }
}