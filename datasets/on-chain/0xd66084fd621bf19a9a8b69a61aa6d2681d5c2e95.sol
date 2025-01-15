// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}


contract MetalliumAlpha is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "Metallium Alpha";
    string private _symbol = "MTLA";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 50_000_000_000 * 10**uint256(_decimals);

    uint256 public constant TEAM_LOCK_PERIOD = 365 days; // 1 year
    uint256 public constant COMMUNITY_LOCK_PERIOD = 60 days; // 2 months
    uint256 public constant VESTING_DURATION = 30 days; // Monthly increments

    // Allocations
    uint256 public teamAllocation = _totalSupply.mul(5).div(100);            // 5%
    uint256 public marketingDevelopment = _totalSupply.mul(10).div(100);     // 10%
    uint256 public communityRewards = _totalSupply.mul(25).div(100);         // 25%
    uint256 public treasury = _totalSupply.mul(10).div(100);                 // 10%
    uint256 public presaleAllocation = _totalSupply.mul(25).div(100);        // 25%
    uint256 public stakingAllocation = _totalSupply.mul(15).div(100);        // 15%

    // Vesting parameters
    uint256 public vestingStart;
    
    // Tracking unlocked amounts
    uint256 public teamUnlocked;
    uint256 public marketingUnlocked;
    uint256 public communityUnlocked;
    uint256 public treasuryUnlocked;

    // Tracking initial allocations
    address public teamWallet;
    address public marketingWallet;
    address public communityWallet;
    address public treasuryWallet;
    address public presaleWallet;
    address public stakingWallet;
    // Tax settings
    uint256 public constant TAX_PERCENTAGE = 15; // 1.5% tax (expressed as parts per thousand)
    uint256 public constant TAX_CAP_PERCENTAGE = 30; // 3% cap (expressed as parts per thousand)
    uint256 public  MAX_TAX_AMOUNT = _totalSupply.mul(TAX_CAP_PERCENTAGE).div(1000); // Max tax 3%

    // Tax recipient (marketing wallet)
    address public taxWallet;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(
        address _teamWallet, 
        address _marketingWallet, 
        address _communityWallet, 
        address _treasuryWallet,
        address _presaleWallet,
        address _stakingWallet,
        address _taxWallet
    ) {
        teamWallet = _teamWallet;
        marketingWallet = _marketingWallet;
        communityWallet = _communityWallet;
        treasuryWallet = _treasuryWallet;
        taxWallet = _taxWallet;
        presaleWallet = _presaleWallet;
        stakingWallet = _stakingWallet;

        // Set vesting start time
        vestingStart = block.timestamp;

        // Immediate transfers for presale and staking allocations
        _balances[presaleWallet] = presaleAllocation;
        _balances[stakingWallet] = stakingAllocation;
        emit Transfer(address(0), presaleWallet, presaleAllocation);
        emit Transfer(address(0), stakingWallet, stakingAllocation);

        // Remaining tokens sent to the owner (minus other locked allocations)
        _balances[_msgSender()] = _totalSupply
            .sub(teamAllocation)
            .sub(marketingDevelopment)
            .sub(communityRewards)
            .sub(treasury)
            .sub(presaleAllocation)
            .sub(stakingAllocation);
        emit Transfer(address(0), _msgSender(), _balances[_msgSender()]);
    }

    // Automatically release vested tokens during token interactions
    function _autoReleaseVestedTokens() internal {
        uint256 currentTime = block.timestamp;

        // Team Allocation: Released after 1 year
        if (currentTime >= vestingStart + TEAM_LOCK_PERIOD && teamUnlocked == 0) {
            _balances[teamWallet] = teamAllocation;
            teamUnlocked = teamAllocation;
            emit Transfer(address(0), teamWallet, teamUnlocked);
        }

        // Marketing/Development: 10% each month for 10 months
        uint256 marketingMonths = (currentTime - vestingStart) / VESTING_DURATION;
        if (marketingMonths > 0 && marketingMonths <= 10) {
            uint256 marketingRelease = marketingDevelopment.mul(marketingMonths).div(10);
            if (marketingRelease > marketingUnlocked) {
                uint256 amountToRelease = marketingRelease.sub(marketingUnlocked);
                _balances[marketingWallet] = _balances[marketingWallet].add(amountToRelease);
                marketingUnlocked = marketingRelease;
                emit Transfer(address(0), marketingWallet, amountToRelease);
            }
        }

        // Community Rewards: 20% after 2 months, then 10% increments
        if (currentTime >= vestingStart + COMMUNITY_LOCK_PERIOD) {
            uint256 communityMonths = (currentTime - (vestingStart + COMMUNITY_LOCK_PERIOD)) / VESTING_DURATION;
            uint256 communityRelease = communityRewards.mul(20).div(100).add(communityRewards.mul(10).div(100).mul(communityMonths));
            if (communityRelease > communityUnlocked && communityMonths >= 0) {
                uint256 amountToRelease = communityRelease.sub(communityUnlocked);
                _balances[communityWallet] = _balances[communityWallet].add(amountToRelease);
                communityUnlocked = communityRelease;
                emit Transfer(address(0), communityWallet, amountToRelease);
            }
        }

        // Treasury: 10% each month for 10 months
        uint256 treasuryMonths = (currentTime - vestingStart) / VESTING_DURATION;
        if (treasuryMonths > 0 && treasuryMonths <= 10) {
            uint256 treasuryRelease = treasury.mul(treasuryMonths).div(10);
            if (treasuryRelease > treasuryUnlocked) {
                uint256 amountToRelease = treasuryRelease.sub(treasuryUnlocked);
                _balances[treasuryWallet] = _balances[treasuryWallet].add(amountToRelease);
                treasuryUnlocked = treasuryRelease;
                emit Transfer(address(0), treasuryWallet, amountToRelease);
            }
        }

    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _autoReleaseVestedTokens(); // Auto-release vested tokens
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _autoReleaseVestedTokens(); // Auto-release vested tokens
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // Standard ERC20 functions
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

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (sender != owner() && recipient != owner()) {
            // Calculate tax
            uint256 taxAmount = _calculateTax(amount);
            uint256 amountAfterTax = amount.sub(taxAmount);

            if (taxAmount > 0) {
                _balances[sender] = _balances[sender].sub(taxAmount, "ERC20: transfer amount exceeds balance");
                _balances[taxWallet] = _balances[taxWallet].add(taxAmount);
                emit Transfer(sender, taxWallet, taxAmount);
            }

            _balances[sender] = _balances[sender].sub(amountAfterTax, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amountAfterTax);
            emit Transfer(sender, recipient, amountAfterTax);
        } else {
            // If sender or recipient is the owner, transfer the full amount
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }


    function _calculateTax(uint256 amount) internal view returns (uint256) {
        uint256 taxAmount = amount.mul(TAX_PERCENTAGE).div(1000); // 1.5% tax
        if (taxAmount > MAX_TAX_AMOUNT) {
            taxAmount = MAX_TAX_AMOUNT; // Cap at 3% of the total supply
        }
        return taxAmount;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 amount) public returns (bool) {
    require(amount > 0, "Amount must be greater than 0");
    _balances[_msgSender()] = _balances[_msgSender()].sub(amount, "ERC20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(_msgSender(), address(0), amount); 
    return true;
    }

}