// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract GroverBounty {

    struct Bounty {
        address creator;
        address acceptor;
        uint256 ethAmount;
        bool creatorAccepted;
        bool acceptorAccepted;
        bool disabled;
    }

    address private owner;
    mapping(uint256 => Bounty) private bounties;
    uint256 private bountyCounter;

    uint256 private minimumBountyAmount = 0.01 ether; // wei
    address private feeAddress = 0x14643EB279BC10385b4d85A5dF9ac29e06ead9Cd;
    uint8 private CANCEL_FEE_PERCENTAGE = 5; // %
    uint8 private COMPLETE_FEE_PERCENTAGE = 5; // %

    // events
    event BountyCreated(uint256 indexed bountyId, address indexed creator, uint256 amount);
    event BountyTakenAndResolved(uint256 indexed bountyId, address indexed acceptor);
    event BountyCompleted(uint256 indexed bountyId, address indexed creator, address indexed acceptor, uint256 amount);
    event BountyCanceled(uint256 indexed bountyId, address indexed creator, address indexed acceptor);

    function getBounty(uint256 id) public view returns (Bounty memory) {
        require(id >= 0 && id < bountyCounter, "Invalid bounty id.");
        return bounties[id];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner, "Not owner.");
        owner = newOwner;
    }

    function getMinimumBountyAmount() public view returns (uint256) {
        return minimumBountyAmount;
    }

    function setMinimumBountyAmount(uint256 amount) external {
        require(msg.sender == owner, "Not owner.");
        minimumBountyAmount = amount;
    }

    function getFeeAddress() public view returns (address) {
        return feeAddress;
    }

    function setFeeAddress(address newAddress) external {
        require(msg.sender == owner, "Not owner.");
        feeAddress = newAddress;
    }

    function getFees() public view returns (uint256, uint256) {
        return (CANCEL_FEE_PERCENTAGE, COMPLETE_FEE_PERCENTAGE);
    }

    function setFees(uint8 cancelFee, uint8 completeFee) external {
        require(msg.sender == owner, "Not owner.");
        CANCEL_FEE_PERCENTAGE = cancelFee;
        COMPLETE_FEE_PERCENTAGE = completeFee;
    }

    function getLastBounty() public view returns (Bounty memory) {
        uint256 id = bountyCounter-1;
        require(id >= 0, "No bounties yet.");
        return bounties[id];
    }

    constructor() {
        owner = msg.sender;
        bountyCounter = 0;
    }

    function withdraw(address receiver, uint256 amount) external {
        require(msg.sender == owner, "Not owner.");
        payable(receiver).transfer(amount);
    }

    function createBounty() external payable returns(uint256 id) {
        require(msg.value >= minimumBountyAmount, "Bounty amount must be greater or equal than minimum bounty value.");

        id = bountyCounter;
        bounties[id] = Bounty({
            creator: msg.sender,
            acceptor: address(0),
            ethAmount: msg.value,
            creatorAccepted: false,
            acceptorAccepted: false,
            disabled: false
        });
        bountyCounter++;

        emit BountyCreated(id, msg.sender, msg.value);
    }

    function cancelBounty(uint256 id) external {
        require(id >= 0 && id < bountyCounter, "Invalid bounty id.");
        Bounty storage bounty = bounties[id];
        require(bounty.creator == msg.sender || bounty.acceptor == msg.sender, "Only the bounty creator/acceptor can cancel it.");
        require(!bounty.disabled, "This bounty was already disabled.");
        require(!bounty.creatorAccepted, "Cannot cancel this bounty because it is accepted by creator.");
        if(bounty.creator == msg.sender) {
            bounty.disabled = true;
            uint256 payout = bounty.ethAmount - ((bounty.ethAmount * CANCEL_FEE_PERCENTAGE) / 100);
            payable(bounty.creator).transfer(payout);
            payable(feeAddress).transfer(bounty.ethAmount - payout);

            emit BountyCanceled(id, msg.sender, address(0));
        }
        else if(bounty.acceptor == msg.sender) {
            bounty.acceptor = address(0);
            bounty.creatorAccepted = false;
            bounty.acceptorAccepted = false;

            emit BountyCanceled(id, address(0), msg.sender);
        }
    }

    function takeAndAcceptBounty(uint256 id, address acceptor) external {
        require(id >= 0 && id < bountyCounter, "Invalid bounty id.");
        Bounty storage bounty = bounties[id];
        require(!bounty.disabled, "This bounty is not active.");
        require(bounty.creator == msg.sender, "Only the bounty creator can cancel it.");
        require(acceptor != bounty.creator && acceptor != address(0), "Invalid acceptor.");
        bounty.acceptor = acceptor;
        bounty.acceptorAccepted = true;
        bounty.creatorAccepted = true;
        bounty.disabled = true;
        uint256 payout = bounty.ethAmount - ((bounty.ethAmount * COMPLETE_FEE_PERCENTAGE) / 100);
        payable(bounty.acceptor).transfer(payout);
        payable(feeAddress).transfer(bounty.ethAmount - payout);
        emit BountyTakenAndResolved(id, acceptor);
    }
}