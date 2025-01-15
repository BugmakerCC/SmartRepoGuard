// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GondolaNFT {
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // Owner address
    address private _owner;
    
    uint256 private _currentTokenId;
    uint256 public constant MAX_SUPPLY = 5000;
    uint256 public constant PUBLIC_MINT_LIMIT = 2;
    uint256 public constant HOLDER_MINT_LIMIT = 20;
    
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public mintCount;
    string private _baseURIValue;
    bytes32 public merkleRoot;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    constructor() {
        _name = "Gondola";
        _symbol = "GONDOLA";
        _owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }
    
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }
    
    function mint(uint256 quantity, bytes32[] calldata proof) public payable returns (uint256) {
        require(_currentTokenId + quantity <= MAX_SUPPLY, "Max supply reached");
        require(quantity > 0, "Must mint at least 1");
        
        // Verify mint limit based on whether address is in merkle tree
        bool isHolder = verifyProof(proof, keccak256(abi.encodePacked(msg.sender)));
        uint256 mintLimit = isHolder ? HOLDER_MINT_LIMIT : PUBLIC_MINT_LIMIT;
        require(mintCount[msg.sender] + quantity <= mintLimit, "Exceeds mint limit");
        
        mintCount[msg.sender] += quantity;
        
        for (uint256 i = 0; i < quantity; i++) {
            _currentTokenId++;
            _mint(msg.sender, _currentTokenId);
        }
        
        return _currentTokenId;
    }
    
    function verifyProof(bytes32[] calldata proof, bytes32 leaf) public view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == merkleRoot;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Invalid recipient");
        require(_owners[tokenId] == address(0), "Already minted");
        
        _balances[to] += 1;
        _owners[tokenId] = to;
        
        emit Transfer(address(0), to, tokenId);
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token doesn't exist");
        return tokenOwner;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        require(account != address(0), "Zero address");
        return _balances[account];
    }
    
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseURIValue = baseURI;
    }
    
    function _baseURI() internal view returns (string memory) {
        return _baseURIValue;
    }
    
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? 
            string(abi.encodePacked(baseURI, toString(tokenId), ".json")) : "";
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }
}