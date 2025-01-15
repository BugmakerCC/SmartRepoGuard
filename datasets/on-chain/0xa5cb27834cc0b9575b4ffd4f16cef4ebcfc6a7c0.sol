// SPDX-License-Identifier: MIT
// https://thedaonft.eth.limo/

pragma solidity ^0.8.11;


/*
  ::::::::::: :::    ::: :::::::::: ::::    ::: :::::::::: :::::::::::
     :+:     :+:    :+: :+:        :+:+:   :+: :+:            :+:
    +:+     +:+    +:+ +:+        :+:+:+  +:+ +:+            +:+
   +#+     +#++:++#++ +#++:++#   +#+ +:+ +#+ :#::+::#       +#+
  +#+     +#+    +#+ +#+        +#+  +#+#+# +#+            +#+
 #+#     #+#    #+# #+#        #+#   #+#+# #+#            #+#
###     ###    ### ########## ###    #### ###            ###

Minter will mint out the remaining nfts
*/

//import "hardhat/console.sol";

contract Minter {

    IRedeemer private r = IRedeemer(0x01D7B7728E41564F63ef8989A1D827F5e4e6E56C);
    ITheNFT private nft = ITheNFT(0x79a7D3559D73EA032120A69E59223d4375DEb595);
    ITheNFT private v1 = ITheNFT(0x266830230bf10A58cA64B7347499FD361a011a02);
    IERC20 private theDao = IERC20(0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413);
    address private deployer;
    uint256 private constant oneDao = 1e16;

    constructor() {
        nft.setApprovalForAll(address(r), true);       // approve redeemer to use our nfts
        theDao.approve(address(r), type(uint256).max); // approve redeemer to take our thedao tokens
        deployer = msg.sender;
    }

    function mintout(uint256 i) external {
        unchecked {
            theDao.transferFrom(msg.sender, address(this), i * oneDao);
            uint256 id = 1800 - v1.balanceOf(address(v1));
            r.mint(i, true);
            for (uint256 count = 0; count < i; count++) {
                r.burn(id + count);
            }
            theDao.transfer(msg.sender, i * oneDao);
        }
    }

    function sweep(address tok) external {
        IERC20(tok).transfer(deployer, theDao.balanceOf(address(this)));
    }

}

interface IRedeemer {
    function mint(uint256 _i, bool _sendCig) external;
    function burn(uint256 _id) external;
}

interface ITheNFT {
    function balanceOf(address) external view returns(uint256);
    function ownerOf(uint256) external view returns(address);
    function transferFrom(address,address,uint256) external;
    function mint(uint256 i) external;
    function approve(address to, uint256 tokenId) external;
    function burn(uint256 id) external;
    function restore(uint256 id) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function upgrade(uint256[] calldata _ids) external;
    function setApprovalForAll(address _operator, bool _approved) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}