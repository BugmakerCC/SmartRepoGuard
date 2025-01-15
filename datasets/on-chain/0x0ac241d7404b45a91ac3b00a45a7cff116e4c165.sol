// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract TokenDistributor is ReentrancyGuard {
    IERC20 public immutable token;
    address public immutable admin;
    address public immutable feeRecipient;
    uint96 public constant MAX_ALLOWANCE = 500000 * 10**18;
    uint96 public constant MAX_WITHDRAW = 10000 * 10**18;
    uint96 public totalClaimed;
    uint96 public fixedFee;
   
    bytes constant internal ETH_PREFIX = "\x19Ethereum Signed Message:\n32";

    // Mapping address and nonces
    mapping(address => uint64) public nonces;

    // Events
    event ChequeClaimed(address indexed recipient, uint96 claimed, uint64 nonce, uint96 feePaid);
    event EndOfAllowance(uint96 totalClaimed);
    event FixedFeeChanged(uint96 oldFee, uint96 newFee);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _token, address _admin, address _feeRecipient) {
        token = IERC20(_token);
        admin = _admin;
        feeRecipient = _feeRecipient;
        fixedFee = 0.0005 ether; 
    }

    function setFixedFee(uint96 _newFee) external onlyAdmin {
        uint96 oldFee = fixedFee;
        fixedFee = _newFee;
        emit FixedFeeChanged(oldFee, _newFee);
    }

    // Claim function requires ETH fee for platform fee (deducted from msg.value)
    function claim(uint96 amount, uint64 nonce, bytes calldata signature) 
        external 
        payable
        nonReentrant 
    {
        uint64 userNonce = nonces[msg.sender];
        
        require(userNonce < nonce, "Invalid nonce");
    
        // Update the state before external calls 
        nonces[msg.sender] = nonce; // Update the nonce
        amount = canClaim(amount); // Check allowance level 
        totalClaimed += amount; // Update total claimed tokens

        // Check that the caller has sent the correct ETH fee for the platform
        require(msg.value == fixedFee, "Must send the correct ETH as platform fee");
        
        // Verify that the provided hash matches the original data
        require(verifyCheque(amount, nonce, signature), "Invalid cheque hash");

        // Transfer the tokens to the claimer
        token.transfer(msg.sender, amount);

        // Transfer the platform fee to the feeRecipient
        payable(feeRecipient).transfer(fixedFee);

        emit ChequeClaimed(msg.sender, amount, nonce, fixedFee);
    }

    function canClaim(uint96 amount) internal view returns (uint96) {
        require(amount > 0 && amount <= MAX_WITHDRAW, "Invalid withdraw amount");
        
        uint96 remainingAllowance = MAX_ALLOWANCE - totalClaimed;
        
        if (amount > remainingAllowance) {
            return remainingAllowance;
        }
        
        return amount;
    }


    function verifyCheque(
        uint96 amount,
        uint64 nonce, 
        bytes memory signature
    ) public view returns (bool) {
        // Recompute the message hash
        bytes32 computedMessage = keccak256(abi.encodePacked(msg.sender, amount, nonce));
        // Verify that the signature is valid and was signed by the admin
        return (recoverSigner(computedMessage, signature) == admin);
    }

    function recoverSigner(bytes32 hash, bytes memory signature) public pure returns (address) {
        bytes32 messageHash = prefixed(hash);
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(messageHash, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(ETH_PREFIX, hash));
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}