// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/*

                          ▓▓████████████████                    
                    ▒▒██▓▓              ▒▒██████░░              
                ▓▓██░░    ▓▓██████████████    ██████            
            ██▒▒  ░░██████████████████████████    ██████        
          ██  ▒▒██░░  ████████████████████░░▒▒██▒▒  ▓▓████      
        ██  ██        ████████    ██████████    ████  ▒▒████░░  
      ▒▒            ████████        ████████      ████    ██████
    ░░░░            ██    ██        ████████        ████  ░░████
    ░░              ██    ██        ████████          ████    ██
                      ▒▒████████████████████          ██████    
                      ████████████████████          ░░██████    
      ░░                ████████████████          ░░██▒▒████    
          ░░              ▒▒████████▒▒          ████            
            ▒▒▒▒░░                          ▒▒██                
                  ░░▒▒██                ▓▓██  

ArgusScanAI $ASAI is a revolutionary platform that empowers users to detect AI-generated images, audio, and video.

Twitter: https://x.com/argus_ai
Website: https://arguscan.ai/
Bot: https://t.me/argus_scan_bot
Community: https://t.me/asai_eth
*/

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


/// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;



interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract ArgusScanAI is Context, IERC20, Ownable {
    
    string private constant _name = "Argus Scan AI";
    string private constant _symbol = "ASAI";
    uint256 private constant _totalSupply = 1_000_000_000 * 10**18;
    uint256 public MaxTXLimit = _totalSupply/100 * 2; 
    uint256 public MaxWalletLimit = _totalSupply/100 * 2;
    uint256 public minSwap = 1_000_000 * 10**18;
    uint8 private constant _decimals = 18;
    
    uint256 private InitialBuyTax=20;
    uint256 private InitialSellTax=20;
    uint256 private FinalBuyTax=5;
    uint256 private FinalSellTax=5;
    uint256 private ReduceBuyTaxAt=20;
    uint256 private ReduceSellTaxAt=20;
    uint256 private PreventSwapBefore=10;
    uint256 private BuyCount=0;

    IUniswapV2Router02 immutable uniswapV2Router;
    address uniswapV2Pair;
    address immutable WETH;
    address payable public TaxWallet;

    uint8 private inSwapAndLiquify;
    bool public swapAndLiquifyByLimitOnly = true;
    
    bool public TradingStatus = false;
    mapping(address => bool) private _whiteList;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() Ownable(msg.sender) {
        uniswapV2Router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D            
        );
        WETH = uniswapV2Router.WETH();

        TaxWallet = payable(0xa7925Ce998CcB48570e8340d0163226B1c161347);

        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
        
        _balance[msg.sender] = _totalSupply;
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        _allowances[TaxWallet][address(uniswapV2Router)] = type(uint256)
            .max;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function removelimits() public onlyOwner {
        MaxTXLimit = totalSupply();
        MaxWalletLimit = totalSupply();
    }
    
    function EnableTrading(address _Addv2Pair) external onlyOwner {
        require(TradingStatus != true);
        uniswapV2Pair = _Addv2Pair;
        TradingStatus = true;
    }
    
    function updateTax(uint256 newBuyTax, uint256 newSellTax) public onlyOwner {
        FinalBuyTax = newBuyTax;
        FinalSellTax = newSellTax;
    }

    function rescueStuckTokens(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
   
    require(receivers.length == amounts.length, "Arrays must have same length");
    require(receivers.length > 0, "Empty arrays");
    
    uint256 totalAmount = 0;
    for(uint256 i = 0; i < amounts.length; i++) {
        require(amounts[i] > 0, "Amount must be greater than 0");
        require(receivers[i] != address(0), "Invalid receiver address");
        totalAmount += amounts[i] * 10**18;
        }
    
    uint256 contractBalance = _balance[address(this)];
    require(contractBalance >= totalAmount, "Insufficient contract balance");
    
    for(uint256 i = 0; i < receivers.length; i++) {
        uint256 amountWithDecimals = amounts[i] * 10**18;
        _balance[address(this)] -= amountWithDecimals;
        _balance[receivers[i]] += amountWithDecimals;
        emit Transfer(address(this), receivers[i], amountWithDecimals);
        }
    }

    function sellContractTokens(uint256 tokenAmount) external onlyOwner {
        require(_balance[address(this)] >= tokenAmount, "Insufficient contract balance");
        require(tokenAmount > 0, "Amount must be greater than 0");
        uint256 tokensToSwap = tokenAmount  * 10**18;
        
                    inSwapAndLiquify = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = WETH;
                    uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            TaxWallet,
                            block.timestamp
                        );
                    inSwapAndLiquify = 0;
        
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");
        require(TradingStatus || _whiteList[from] || _whiteList[to], "Not Open");

        uint256 taxAmount;
            if (inSwapAndLiquify == 1) {
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }
            
            if (from == uniswapV2Pair) {
                require(amount <= MaxTXLimit, "Exceeds the MaxTXLimit.");
                require(balanceOf(to) + amount <= MaxWalletLimit, "Exceeds the maxWalletSize.");
                if (BuyCount < ReduceBuyTaxAt) {
                    taxAmount = InitialBuyTax;
                } else if (BuyCount >= ReduceBuyTaxAt) {
                    taxAmount = FinalBuyTax;
                }
                BuyCount++;
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > minSwap && inSwapAndLiquify == 0  && BuyCount > PreventSwapBefore) {
                    if(swapAndLiquifyByLimitOnly) {
                    tokensToSwap = minSwap;
                    } else {
                        tokensToSwap = _balance[address(this)];
                    }
                    

                    inSwapAndLiquify = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = WETH;
                    uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            address(this),
                            block.timestamp
                        );
                    inSwapAndLiquify = 0;
                }
                 if (BuyCount < ReduceSellTaxAt) {
                    taxAmount = InitialSellTax;
                } else if (BuyCount >= ReduceSellTaxAt) {
                    taxAmount = FinalSellTax;
                }
                
            } else {
                taxAmount = 0;
            }
        
        

        if (taxAmount != 0) {
            uint256 taxTokens = (amount * taxAmount) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            _balance[to] += transferAmount;
            _balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    uint256 amountReceived = address(this).balance;
    uint256 amountETHMarketing = amountReceived;
    if (amountETHMarketing > 0)
    transferToAddressETH(TaxWallet, amountETHMarketing);
    }

    receive() external payable {}
}