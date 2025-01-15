// SPDX-License-Identifier:  GPL-3.0-or-later
// made with love for all ethereum and our shared future <3
pragma solidity ^0.8.26;

contract Blog {
    address public owner;
    string[] posts;
    string public parser = "onchainmd0"; // allow future data storage locations, eg blobs/l2, with modular js parsers
    address public upgradedTo;           // linked list of blog contracts if later upgrade desired
    string public title;                 // blog title (CANNOT BE CHANGED ONCE SET)

    constructor(string memory _title) {
        owner = msg.sender;
        title = _title;
    }

    function addPost(string calldata post) public  {
        if (msg.sender != owner) { revert(); }
        posts.push(post);
    }

    function deletePost(uint postID) public  {
        if (msg.sender != owner) { revert(); }
        posts[postID] = "";
    }

    function updateOwner(address newOwner) public {
        if (msg.sender != owner) { revert(); }
        owner = newOwner;
    }

    function doUpgrade(address nextContract) public {
        if (msg.sender != owner) { revert(); }
        upgradedTo = nextContract;
    }

    function getNumPosts() public view returns(uint count) {
        return posts.length;
    }

    function getPost(uint postNum) public view returns(string memory post) {
        return posts[postNum];
    }

}