/*
                           
         ██████╗ ████████╗ ██████╗ ███╗   ███╗    ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗
        ██╔═══██╗╚══██╔══╝██╔═══██╗████╗ ████║    ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║
        ██║   ██║   ██║   ██║   ██║██╔████╔██║       ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║
        ██║   ██║   ██║   ██║   ██║██║╚██╔╝██║       ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║
        ╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║       ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║
         ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝       ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
 
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
}
 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
 
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
 
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
 
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
 
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
 
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
 
    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);
 
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
 
    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);
 
    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}
 
interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
        ) external returns (uint amountToken, uint amountETH);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract OTOMToken is Ownable , IERC20 {
 
    string private constant _name = "Otcom";
    string private constant _symbol = "OTOM";
    uint8  private constant _decimals = 18;
    uint256 private _totalSupply = 10 * 10**6 *10**uint256(_decimals);
 
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public blacklisted;
   
    address public devWallet;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
   
    uint256 public  liquidityTaxPercentage = 1000; //1000=1%
    uint256 public  devTaxPercentage=1000; // 1000 = 1%
    uint256 public  taxThreshold = 10000 * 10**uint256(_decimals); // Threshold for performing swapandliquify
    uint256 public  maxAmount = 20000 * 10 ** uint256(_decimals); // Max Buy/Sell Limit
    uint256 public  numBlocksForBlacklist = 50;  

    uint256 private liquidityTaxShare =50000;    
    uint256 private devTaxShare = 67000;      
    uint256 private currentBlockNumber;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapPair;

    bool private swapping;
    bool public  tradeOpen = false;
 
    //-------------events------------------ 
    event UpdatedDevWallet(address updatedDevWallet);
    event UpdatedTaxPercentage(uint256 updatedLiquidityTax,uint256 updatedDevTax);
    event UpatedTaxThreshold(uint256 updateTaxThreshold);
    event UpdatedMaxAmount(uint256 updatedMaxAmount);
    event UpdatedBlock(uint256 updatedBlocks); 
    event Burn(address indexed burner, uint256 amount);
    
    /**
    * @dev Constructor function that initializes the token contract.
    * - Assigns the total supply to the contract deployer (msg.sender).
    * - Sets up the UniswapV2 router on Etherum mainnet and creates a liquidity pair between this token and WETH.
    * - Approves the maximum possible allowance for both the sender and the contract to interact with the UniswapV2 router.
    * - Initializes the dev wallet.
    * - Emits a Transfer event indicating that tokens have been transferred from the zero address to the deployer.
    * @param _devWallet The address of the development wallet.
    */
    constructor(address _devWallet) {
        require(_devWallet != address(0),"Dev wallet cannot be zero address");
        _balances[msg.sender] = _totalSupply;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // Etherum mainnet
        );
        uniswapV2Router = _uniswapV2Router;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
 
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        devWallet = _devWallet;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
 
    /**
    * @notice Retrieves the name of the token.
    * @dev This function returns the name of the token, which is often used for identification.
    * It is commonly displayed in user interfaces and provides a human-readable name for the token.
    * @return The name of the token.
    */
    function name() public view virtual  returns (string memory) {
        return _name;
    }
     
    /**
    * @notice Retrieves the symbol or ticker of the token.
    * @dev This function returns the symbol or ticker that represents the token.
    * It is commonly used for identifying the token in user interfaces and exchanges.
    * @return The symbol or ticker of the token.
    */
    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }
     
    /**
    * @notice Retrieves the number of decimal places used in the token representation.
    * @dev This function returns the number of decimal places used to represent the token balances.
    * It is commonly used to interpret the token amounts correctly in user interfaces.
    * @return The number of decimal places used in the token representation.
    */
    function decimals() public view virtual  returns (uint8) {
        return _decimals;
    }
    
    /**
    * @notice Retrieves the total supply of tokens.
    * @dev This function returns the total supply of tokens in circulation.
    * @return The total supply of tokens.
    */
    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }
 
    /**
    * @notice Returns the balance of the specified account.
    * @param account The address for which the balance is being queried.
    * @return The balance of the specified account.
    */
    function balanceOf(
        address account
    ) public view virtual  returns (uint256) {
        return _balances[account];
    }

    /**
    * @dev Burns a specific amount of tokens from the caller's address.
    * @param amount The amount of tokens to be burned.
    */
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    /**
    * @dev Burns a specified amount of tokens from an account by transferring them to the dead address.
    * This does not decrease the total supply. Requirements: 
    * - `account` cannot be the zero address.
    * - `amount` must not exceed the balance of `account`.
    * Emits a {Transfer} event for the dead address and a {Burn} event.
    *
    * @param account The address from which to burn tokens.
    * @param amount The number of tokens to burn.
    */
    function _burn(address account, uint256 amount) internal {
       require(account != address(0), "ERC20: burn from the zero address");
   
       uint256 accountBalance = _balances[account];
       require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
       unchecked {
           _balances[account] = accountBalance - amount;
           _balances[DEAD] += amount;
       }
   
       emit Transfer(account, DEAD, amount);
       emit Burn(account, amount);
    }

    /**
    * @notice Transfers tokens from the sender's account to the specified recipient.
    * @dev This function is used to transfer tokens from the sender's account to the specified recipient.
    * @param to The address of the recipient to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful or not.
    */
    function transfer(
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    
    /**
    * @notice Transfers tokens from one account to another on behalf of a spender.
    * @dev This function is used to transfer tokens from one account to another on behalf of a spender.
    * @param from The address from which tokens will be transferred.
    * @param to The address to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful or not.
    */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
 
    /**
    * @notice Returns the amount of tokens that the spender is allowed to spend on behalf of the owner.
    * @param owner The address of the owner of the tokens.
    * @param spender The address of the spender.
    * @return The allowance amount.
    */
    function allowance(
        address owner,
        address spender
    ) public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }
 
    /**
    * @notice Approves the spender to spend a specified amount of tokens on behalf of the sender.
    * @param spender The address of the spender to be approved.
    * @param amount The amount of tokens to be approved for spending.
    * @return A boolean indicating whether the approval was successful or not.
    */
    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
 
    /**
    * @notice Internal function to set allowance for a spender.
    * @dev This function sets the allowance for a spender to spend tokens on behalf of the owner.
    * @param sender The address of the owner of the tokens.
    * @param spender The address of the spender.
    * @param amount The amount of tokens to be approved for spending.
    */
    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }
 
    /**
    * @notice Internal function to spend tokens from the allowance of a spender.
    * @dev This function checks if the spender has sufficient allowance from the owner
    * to spend the specified amount of tokens. If the spender's allowance is not
    * unlimited, it is decreased by the spent amount.
    * @param owner The address of the owner of the tokens.
    * @param spender The address of the spender.
    * @param amount The amount of tokens to be spent.
    */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    
    /**
    * @notice Internal function to transfer tokens from one address to another.
    * @dev This function transfers a specified amount of tokens from one address to another.
    * @param from The address from which tokens will be transferred.
    * @param to The address to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    */
    function _transferTokens(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }
 
        emit Transfer(from, to, amount);
    }
  
    /* 
    * @dev Enables trading by setting the `tradeOpen` flag to true.
    * The function checks whether trading is already open using the `require` statement.
    * If trading is already enabled, it will revert with the message "Trade is already open".
    * The `currentBlockNumber` is also set to the current block number when the trade is enabled.
    * Only the contract owner can call this function.
    */
    function enableTrade() public onlyOwner {
        require(!tradeOpen, "Trade is already open");
        currentBlockNumber = block.number;
        tradeOpen = true; 
    }
  
    /**
    * @dev Sets the number of blocks during which sniper bot protection is active. 
    * Only callable by the contract owner.
    * 
    * @param numBlocks The number of blocks for which addresses will be blacklisted after liquidity is added.
    * Emits an {UpdatedBlock} event indicating the new block count.
    */
    function setNumberOfBlocksForBlacklist(uint256 numBlocks) external onlyOwner {
        require(numBlocks > 0,"number of block should be more than 0");
        numBlocksForBlacklist = numBlocks;
        emit UpdatedBlock(numBlocksForBlacklist);
    }
 
    /**
    * @dev Sets the maximum transaction amount. Can only be called by the contract owner.
    * 
    * @param amount The new maximum amount allowed per transaction.
    * Requires that the amount does not exceed (200,000tokens) you need to pass amount with 18 decimal like you want pass 50k(50000000000000000000000) .
    * Emits an {UpdatedMaxAmount} event indicating the new maximum amount.
    */
    function setMaxAmount(uint256 amount) external onlyOwner {
        require(amount <= 200000 * 10 ** 18, "Amount exceeds the maximum limit of 200,000 tokens");
        maxAmount = amount;
        emit UpdatedMaxAmount(maxAmount);
    }
   
    /**
    * @dev Sets a new development wallet address.
    * - Only callable by the contract owner.
    * - Ensures that the provided address is not the zero address.
    * - Updates the `devWallet` state variable with the new address.
    * - Emits an `UpdatedDevWallet` event to log the change.
    * @param wallet The new development wallet address.
    */
    function setDevWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Dev wallet cannot be zero address");
        devWallet = wallet;
        emit UpdatedDevWallet(devWallet);
    }
 
    /**
    * @notice Sets the tax percentage, dividing it equally between liquidity and dev taxes.
    * @param _taxPercentage Total tax percentage (max 25%, i.e., 25000). 
    * -note: you need to pass percentage like you want  pass 3%(3000) 
    */
    function setTaxPercentage(uint256 _taxPercentage) external onlyOwner {
        require(_taxPercentage <= 25000, "Tax percentage cannot exceed 25%");
        
        // Split the total tax percentage equally between liquidityTax and devTax
        liquidityTaxPercentage = _taxPercentage / 2;
        devTaxPercentage = _taxPercentage / 2;
        
        emit UpdatedTaxPercentage(liquidityTaxPercentage,devTaxPercentage);
    }

    /**
    * @dev Sets the minimum token threshold for tax collection.
    * - Only callable by the contract owner.
    * - Ensures that the threshold is greater than zero to prevent invalid values.
    * - Updates the `taxThreshold` state variable with the new threshold.
    * - Emits an `UpdatedTaxThreshold` event to log the new threshold value.
    * @param _threshold The new tax threshold amount.
    */
    function setTaxThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold > 0 , "Amount should be more than zero");
        taxThreshold = _threshold;
        emit UpatedTaxThreshold(taxThreshold);
    }
    
    /**
    * @dev Swaps a specified amount of tokens for ETH using the Uniswap V2 router.
    * - The swap follows the token -> WETH path, converting tokens held by the contract into ETH.
    * - Approves the Uniswap router to spend the specified token amount.
    * - Uses `swapExactTokensForETHSupportingFeeOnTransferTokens` to execute the swap, which ensures fee-on-transfer tokens are supported.
    * - Accepts any amount of ETH in return for the swap.
    * - Sends the swapped ETH to the contract's address.
    * @param tokenAmount The amount of tokens to be swapped for ETH.
    */
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
 
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    /**
    * @dev Swaps tokens for ETH and adds liquidity.
    * A 1% of ETH is sent to the dev wallet, and the 1% is used for liquidity.
    */
    function swapAndLiquify() internal {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 swapToken;
        if (contractTokenBalance >= taxThreshold) {
            uint totalLiquidity=(contractTokenBalance * liquidityTaxShare)/100000;
            uint256 liqHalf =  totalLiquidity/ 2;
            uint256 otherLiqHalf =totalLiquidity-liqHalf;
            uint256 tokensToSwap = contractTokenBalance - liqHalf; 
 
            uint256 initialBalance = address(this).balance;
 
            swapTokensForEth(tokensToSwap);

            uint256 newBalance = address(this).balance - (initialBalance);
            swapToken= newBalance;

            bool transferSuccess;

            uint256 devAmount = (swapToken * devTaxShare)/100000;
            newBalance = newBalance - devAmount;
            (transferSuccess,) = devWallet.call{value: devAmount, gas: 35000}("");
 
            if (newBalance > 0) {
                addLiquidity(otherLiqHalf, newBalance);
            }
        }
    }
 
    /**
    * @dev Adds liquidity to the Uniswap pool by pairing tokens with ETH.
    * - Approves the Uniswap router to spend the specified amount of tokens.
    * - Uses the `addLiquidityETH` function to add liquidity, which pairs the specified token amount with the provided ETH amount.
    * - Accepts the token amount and ETH amount as parameters, ensuring that liquidity can be added effectively.
    * - Sets slippage to zero, acknowledging that slippage may occur.
    * @param tokenAmount The amount of tokens to add to the liquidity pool.
    * @param ethAmount The amount of ETH to pair with the tokens for liquidity.
    */
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    /**
    * @dev Handles token transfers between addresses with additional checks and tax handling.
    * 
    * - Prevents transfers from/to the zero address.
    * - Enforces that sender and recipient are not blacklisted.
    * - Ensures trading is enabled unless the sender or recipient is the contract owner.
    * - Automatically blacklists recipients who buy during the sniper bot protection period (early blocks after liquidity is added).
    * - Implements buy/sell taxes for liquidity and development, and transfers these to the contract for handling.
    * - Limits transaction amounts based on a defined max amount.
    * 
    * @param sender The address sending the tokens.
    * @param recipient The address receiving the tokens.
    * @param amount The number of tokens to be transferred.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!blacklisted[sender], "Sender is blacklisted");
        require(!blacklisted[recipient], "Recipient is blacklisted");
 
        //If it's the owner, do a normal transfer
        if (sender == owner() || recipient == owner() || sender == address(this)) {
            _transferTokens(sender, recipient, amount);
            return;
        }

        //Check if trading is enabled
        require(tradeOpen, "Trading is disabled");
        
        if(block.number <= currentBlockNumber + numBlocksForBlacklist){
            blacklisted[recipient] = true;
            return;
        }
 
        bool isBuy = sender == uniswapPair;
        bool isSell = recipient == uniswapPair;
 
        uint256 liquidtiyTax;
        uint256 devTax;
        uint256 totaltax;
 
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= taxThreshold;
 
        if (
            canSwap &&
            sender != uniswapPair &&
            !swapping 
        ) {
            swapping = true;
            swapAndLiquify();
            swapping = false;
        }
       
        if (isBuy || isSell) {
                require (amount <= maxAmount, "Cannot buy & sell  more than max limit");
                liquidtiyTax = _calculateTax(amount, liquidityTaxPercentage);
                devTax=_calculateTax(amount, devTaxPercentage);
                totaltax= liquidtiyTax + devTax;
                _transferTokens(sender, address(this), totaltax); 
        
            } 
            amount -= totaltax;
            _transferTokens(sender, recipient, amount);
    }
 
    /**
    * @dev Calculates the tax amount based on the provided percentage.
    * @param amount The total amount to calculate tax on.
    * @param _taxPercentage The tax percentage (scaled by 100,000).
    * @return The calculated tax amount.
    */
    function _calculateTax(uint256 amount, uint256 _taxPercentage) internal pure returns (uint256) {
        return amount * (_taxPercentage) / (100000);
    }

    /**
    * @dev Function to receive ETH when sent directly to the contract.
    * This function is called when no data is supplied with the transaction.
    */
    receive() external payable {}
}