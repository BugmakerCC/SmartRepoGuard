/*

    Deployed on chef.fun, the ultimate launchpad for memes and utility. Deploy for 100$ and get up to 20,000$ worth of benefits!

    More info: web.chef.fun
    Twitter: https://x.com/chefdotfun
    Telegram: https://t.me/chefdotfun

*/

pragma solidity 0.8.19;

// SPDX-License-Identifier: MIT

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

interface IERC20Platformdata is IERC20{
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Platformdata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
}

interface IWETH {
    function deposit() external payable; 
}

interface ILpPair {
    function sync() external;
    function mint(address to) external returns (uint liquidity);
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function WAVAX() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ITokenLocker {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external returns (uint256 lockId);

    function vestingLock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 tgeDate,
        uint256 tgeBps,
        uint256 cycle,
        uint256 cycleBps,
        string memory description
    ) external returns (uint256 lockId);

    function multipleVestingLock(
        address[] calldata owners,
        uint256[] calldata amounts,
        address token,
        bool isLpToken,
        uint256 tgeDate,
        uint256 tgeBps,
        uint256 cycle,
        uint256 cycleBps,
        string memory description
    ) external returns (uint256[] memory);

    function unlock(uint256 lockId) external;

    function editLock(
        uint256 lockId,
        uint256 newAmount,
        uint256 newUnlockDate
    ) external;
}

contract ChefToken is ERC20, Ownable {

    mapping (address => bool) public exemptFromFees;

    address public immutable projectAddress;
    address public immutable platformAddress;
    address public immutable WETH;

    StructsLibrary.TokenInfo public tokenInfo;

    uint256 public buyTax;
    uint256 public sellTax;

    bool public launched;
    uint256 public launchTime;

    bool public limited;

    uint256 public immutable swapTokensAtAmt;
    uint256 public lastSwapBackBlock;

    address public immutable lpPair;
    IDexRouter public immutable dexRouter;
    ITokenLocker public immutable tokenLocker;

    mapping(address => uint256) private _holderLastTransferBlock;

    bool public transferDelayEnabled = true;

    uint64 public constant FEE_DIVISOR = 10000;

    // events

    event UpdatedBuyTax(uint256 newAmt);
    event UpdatedSellTax(uint256 newAmt);
    event UpdatedMaxWalletPercent(uint256 newAmt);
    event Launched(uint256 launchTime);

    // constructor

    constructor(StructsLibrary.TokenInfo memory params, address _platformAddress)
        
        ERC20(params._name, params._symbol)
    {
        tokenInfo = params;
        
        address _weth;
        if(block.chainid == 43114 && params._router == 0x60aE616a2155Ee3d9A68541Ba4544862310933d4){ // edge case for Trader Joe
            _weth = IDexRouter(tokenInfo._router).WAVAX();
        } else {
            _weth = IDexRouter(tokenInfo._router).WETH();
        }

        WETH = _weth;

        ITokenLocker _tokenLocker; 
        if(block.chainid == 1){ // Ethereum
            _tokenLocker = ITokenLocker(0x71B5759d73262FBb223956913ecF4ecC51057641);
        } else if(block.chainid == 56){ // BSC
            _tokenLocker = ITokenLocker(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
        } else if(block.chainid == 8453){ // BASE
            _tokenLocker = ITokenLocker(0xdD6E31A046b828CbBAfb939C2a394629aff8BBdC);
        } else if(block.chainid == 43114) { // Avalanche
            _tokenLocker = ITokenLocker(0x9479C6484a392113bB829A15E7c9E033C9e70D30);
        } else if(block.chainid == 11155111) { // Sepolia
            _tokenLocker = ITokenLocker(0x3eb4E18a5825f3a9ffc90Aa34cC137ac4D2D987f);
        } else {
            revert("Chain not configured");
        }
        tokenLocker = _tokenLocker;

        _mint(msg.sender, 1e9 * 1e18);

        swapTokensAtAmt = totalSupply() * 25 / 100000;

        require(params._maxWalletPlatform >= 10 || params._maxWalletPlatform == 0, "Max wallet too small.");
        require(params._maxWalletDEX >= 10 || params._maxWalletDEX == 0, "Max wallet too small.");
        if(params._maxWalletDEX == 0){
            limited = false;
        } else {
            limited = true;
        }

        projectAddress = tx.origin;
        platformAddress = _platformAddress;

        buyTax = params._buyTaxDEX;

        require(params._buyTaxDEX <= 5000, "Tax too high");
        require(params._buyTaxPlatform <= 5000, "Tax too high");

        sellTax = params._sellTaxDEX;
        require(params._sellTaxDEX <= 5000, "Tax too high");
        require(params._sellTaxPlatform <= 5000, "Tax too high");

        dexRouter = IDexRouter(params._router);
        
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), address(WETH));

        exemptFromFees[msg.sender] = true;
        exemptFromFees[address(this)] = true;
        exemptFromFees[address(0xdead)] = true;

        _approve(address(owner()), address(dexRouter), totalSupply());
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if(!exemptFromFees[from] && !exemptFromFees[to] && from != owner() && to != owner()){
            amount -= handleTax(from, to, amount);
            checkLimits(to, amount);
        }

        super._transfer(from,to,amount);
    }

    function handleTax(address from, address to, uint256 amount) internal returns (uint256){
        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmt;

        if(canSwap && to == lpPair && lastSwapBackBlock + 1 <= block.number) {
            swapBack();
        }
        
        uint256 tax = 0;
        uint256 taxes;

        if (to == lpPair){
            taxes = sellTax;
            require(launched, "Not Launched Yet");
        } else if(from == lpPair){
            taxes = buyTax;
            require(launched, "Not Launched Yet");
        }

        if(taxes > 0){
            tax = amount * taxes / FEE_DIVISOR;
            super._transfer(from, address(this), tax);
        }

        return tax;
    }

    function checkLimits(address to, uint256 amount) internal {
        if(limited){
            
            uint256 maxWallet = tokenInfo._maxWalletDEX * totalSupply() / 10000;
            uint256 balanceOfTo = balanceOf(to);

            if(to != lpPair) {
                require(amount + balanceOfTo <= maxWallet, "Max Wallet");
            }

            if(transferDelayEnabled){
                if(launchTime + 1 minutes <= block.timestamp){
                    transferDelayEnabled = false;
                }
                if (to != address(dexRouter) && to != address(lpPair)){
                    require(_holderLastTransferBlock[tx.origin] < block.number, "Transfer Delay");
                    _holderLastTransferBlock[tx.origin] = block.number;
                }
            }
        }
    }

    receive() payable external {}

    function swapTokensForEth(uint256 tokenAmt) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WETH);

        if(block.chainid == 43114 && address(dexRouter) == 0x60aE616a2155Ee3d9A68541Ba4544862310933d4){ // edge case for Trader Joe
            // make the swap
            dexRouter.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
                tokenAmt,
                0, // accept any amt of AVAX
                path,
                address(this),
                block.timestamp
            );
        } else {
            // make the swap
            dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmt,
                0, // accept any amt of ETH
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        
        if(contractBalance == 0) {return;}

        if(contractBalance > swapTokensAtAmt * 10){
            contractBalance = swapTokensAtAmt * 10;
        }
        
        uint256 liquidityTokens;

        if(tokenInfo._autoAndBurnLp[0]){
            liquidityTokens = contractBalance * 2 / 10; // 20% of tax goes to liquidity
            super._transfer(address(this), lpPair, liquidityTokens);
            ILpPair(lpPair).sync();
            contractBalance -= liquidityTokens;
        }

        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance;
                
        bool success;
        address devReferrer = tokenInfo._devReferrer;

        uint256 totalAmountForPlatformFee;
        
        if(liquidityTokens > 0 ){
            totalAmountForPlatformFee = ethBalance * 625 / 10000; // take 5% of the original amount
        } else {
            totalAmountForPlatformFee = ethBalance * 5 / 100;
        }

        if(devReferrer != address(0)){
            (success, ) = devReferrer.call{value: (totalAmountForPlatformFee * 20 / 100)}("");
            (success, ) = platformAddress.call{value: (totalAmountForPlatformFee * 80 / 100)}("");
        } else {
            (success, ) = platformAddress.call{value: totalAmountForPlatformFee}("");
        }

        ethBalance = address(this).balance;
            
        if(tokenInfo._taxWalletTaxPercents[0] > 0){
            uint256 amountForTaxWallet2 = ethBalance * tokenInfo._taxWalletTaxPercents[0] / FEE_DIVISOR;
            IWETH(WETH).deposit{value:amountForTaxWallet2}();
            IERC20(address(WETH)).transfer(tokenInfo._taxWallets[0], amountForTaxWallet2);
        }

        if(tokenInfo._taxWalletTaxPercents[1] > 0){
            uint256 amountForTaxWallet3 = ethBalance * tokenInfo._taxWalletTaxPercents[1] / FEE_DIVISOR;
            IWETH(WETH).deposit{value:amountForTaxWallet3}();
            IERC20(address(WETH)).transfer(tokenInfo._taxWallets[1], amountForTaxWallet3);
        }

        ethBalance = address(this).balance;

        if(ethBalance > 0){
            (success, ) = projectAddress.call{value: ethBalance}("");
        }

        lastSwapBackBlock = block.number;
    }

    // max wallet functions

    function updateMaxWallet(uint32 maxWalletPercent) external {
        require(projectAddress == msg.sender, "Not Token Creator");
        require(tokenInfo._maxWalletDEX != 0, "Cannot add max wallet");
        require(maxWalletPercent > tokenInfo._maxWalletDEX || maxWalletPercent == 0, "Can only increase max wallet or remove it");
        if(maxWalletPercent == 0){
            limited = false;
        }
        tokenInfo._maxWalletDEX = maxWalletPercent;
        emit UpdatedMaxWalletPercent(maxWalletPercent);
    }

    // tax functions

    function updateTax(uint64 _buyTax, uint64 _sellTax) external {

        require(projectAddress == msg.sender, "Only project address may revoke tax");
        require(_buyTax <= buyTax, "Keep buy tax at or below current Tax");
        buyTax = _buyTax;
        emit UpdatedBuyTax(buyTax);

        require(_sellTax <= sellTax, "Keep buy tax at or below current Tax");
        sellTax = _sellTax;
        emit UpdatedSellTax(sellTax);
    }

    function revokeTaxWallet1() external {
        require(msg.sender == tokenInfo._taxWallets[0], "Not owner of Tax Wallet");
        require(tokenInfo._taxWalletTaxPercents[0] > 0, "Tax already zero");
        if(tokenInfo._taxWalletTaxPercents[0] + tokenInfo._taxWalletTaxPercents[1] == 10000){
            tokenInfo._taxWalletTaxPercents[1] = 10000;
        }
        tokenInfo._taxWalletTaxPercents[0] = 0;
    }

    function revokeTaxWallet2() external {
        require(msg.sender == tokenInfo._taxWallets[1], "Not owner of Tax Wallet");
        require(tokenInfo._taxWalletTaxPercents[1] > 0, "Tax already zero");
        if(tokenInfo._taxWalletTaxPercents[0] + tokenInfo._taxWalletTaxPercents[1] == 10000){
            tokenInfo._taxWalletTaxPercents[0] = 10000;
        }
        tokenInfo._taxWalletTaxPercents[1] = 0;
    }

    function revokeProjectTaxWallet(uint24 taxWallet1Perc, uint24 taxWallet2Perc) external {
        require(projectAddress == msg.sender, "Only project address may revoke tax");
        require(taxWallet1Perc + taxWallet2Perc == 10000, "Must equal 10000 (100%)");
        if (taxWallet1Perc > 0){
            require(tokenInfo._taxWallets[0] != address(0), "Zero Address");
        }
        if (taxWallet2Perc > 0){
            require(tokenInfo._taxWallets[1] != address(0), "Zero Address");
        }
        tokenInfo._taxWalletTaxPercents[0] = taxWallet1Perc;
        tokenInfo._taxWalletTaxPercents[1] = taxWallet2Perc;   
    }

    // owner functions

    function setLaunched() external onlyOwner {
        launched = true;
        launchTime = block.timestamp;
        lastSwapBackBlock = block.number;
        emit Launched(launchTime);
    }

    function addLp() external payable onlyOwner {
        require(address(this).balance > 0 && balanceOf(address(this)) > 0);

        (bool success, ) = platformAddress.call{value: address(this).balance * 3 / 100}("");
        require(success, "ETH Not sent successfully");
        IWETH(WETH).deposit{value: address(this).balance}();
        address pair = lpPair;

        super._transfer(address(this), address(pair), balanceOf(address(this)));
        IERC20(address(WETH)).transfer(address(pair), IERC20(address(WETH)).balanceOf(address(this)));
        if(tokenInfo._autoAndBurnLp[1]){
            ILpPair(pair).mint(address(0xdead));
        } else {
            ILpPair(pair).mint(address(this));
            uint256 lpPairBalance = IERC20(pair).balanceOf(address(this));
            IERC20(pair).approve(address(tokenLocker), lpPairBalance);
            tokenLocker.lock(
                projectAddress,
                address(pair),
                true,
                lpPairBalance,
                block.timestamp + 30 days,
                string(abi.encodePacked(name(), " LP"))
            );
        }
    }

    // views

    function getTaxSplitValues() external view returns (address[] memory, uint24[] memory) {
        address[] memory wallets = new address[](3);
        uint24[] memory percents = new uint24[](3);
        wallets[0] = projectAddress;
        wallets[1] = tokenInfo._taxWallets[0];
        wallets[2] = tokenInfo._taxWallets[1];
        percents[1] = tokenInfo._taxWalletTaxPercents[0];
        percents[2] = tokenInfo._taxWalletTaxPercents[1];
        percents[0] = 10000 - (percents[1] + percents[2]);
        return (wallets, percents);
    }
}

library StructsLibrary {
    struct TokenInfo {
        string _name; 
        string _symbol;
        uint32 _maxWalletPlatform;
        uint32 _maxWalletDEX;
        uint24 _buyTaxPlatform;
        uint24 _sellTaxPlatform;
        uint24 _buyTaxDEX;
        uint24 _sellTaxDEX;
        address _router;
        bool _isLaunched;
        address[] _taxWallets;
        uint24[] _taxWalletTaxPercents;
        address _devReferrer;
        bool[] _autoAndBurnLp;
    }
}