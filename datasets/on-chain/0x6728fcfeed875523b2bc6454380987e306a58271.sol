/*

Holy Meme Bible

“The Saints will accomplish what concerns me;
Your faithfulness, Lord, is everlasting;
Do not abandon the works of Your hands.” - Saint Pepe Psalm 138
*/


// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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
    
    function totalSupply() external view returns (uint256);

   
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20{
   
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
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

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    
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

interface ILpPair {
    function sync() external;
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract HMB is ERC20, Ownable { //Change token contract name here.

    mapping (address => bool) public exemptFromFees;
    mapping (address => bool) public exemptFromLimits;

    bool public tradingAllowed;

    mapping (address => bool) public isAMMPair;

    address public marketingAddress;
    address public devAddress;

    Taxes public buyTax;
    Taxes public sellTax;

    TokensForTax public tokensForTax;

    mapping(address => uint256) private _holderLastTransferBlock; //MEV Protection
    bool public antiMevEnabled = false;

    bool public limited = true;

    uint256 public swapTokensAtAmt;
    uint256 public lastSwapBackBlock;

    address public immutable lpPair;
    IDexRouter public immutable dexRouter;
    address public immutable WETH;

    TxLimits public txLimits;

    uint64 public constant FEE_DIVISOR = 10000; //This means 10000 units = 100%

    uint256 public launchBlock;

    uint256 public doNothing;

    bool public transferDelayEnabled = true;


    // structs

    struct TxLimits {
        uint128 transactionLimit;
        uint128 walletLimit;
    }

    struct Taxes {
        uint64 marketingTax;
        uint64 devTax;
        uint64 liquidityTax;
        uint64 totalTax;
    }

    struct TokensForTax {
        uint80 tokensForMarketing;
        uint80 tokensForLiquidity;
        uint80 tokensForDev;
        bool gasSaver;
    }

    // events

    event UpdatedTransactionLimit(uint newMax);
    event UpdatedWalletLimit(uint newMax);
    event SetExemptFromFees(address _address, bool _isExempt);
    event SetExemptFromLimits(address _address, bool _isExempt);
    event RemovedLimits();
    event UpdatedBuyTax(uint newAmt);
    event UpdatedSellTax(uint newAmt);

    // constructor

    constructor()
        ERC20("Holy Meme Bible", "HMB") 
    {   
        _mint(msg.sender, 100000000 * (10 ** 18)); //Change token supply here -> supply * (10 ** 18)

        address _v2Router;

        // @dev assumes WETH pair
        if(block.chainid == 1){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if(block.chainid == 5){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if(block.chainid == 97){
            _v2Router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else if(block.chainid == 42161){
            _v2Router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        } else if(block.chainid == 8453){
            _v2Router = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
        } else {
            revert("Chain not configured");
        }

        dexRouter = IDexRouter(_v2Router);

        txLimits.transactionLimit = uint128(totalSupply() * 10 / 1000); //Change maximum transaction limit here -> 1000 = 1%
        txLimits.walletLimit = uint128(totalSupply() * 10 / 1000); //Change maximum transaction limit here -> 1000 = 1%
        swapTokensAtAmt = totalSupply() * 10 / 10000; //Minimum amount to trigger convert the tax into ETH and transfer to Marketing and Dev address.

        marketingAddress = 0x857dF4dE23DB0224fAE3ED8Da31a2749e7Fe3Bb5; //Change marketing address here.
        devAddress = msg.sender; //Change dev address here, msg.sender means the address which is used to deploy the token.

        buyTax.marketingTax = 3000; //Change marketig tax on buy here -> 100 = 1%
        buyTax.liquidityTax = 0; //Change liquidity tax on buy here -> 100 = 1%
        buyTax.devTax = 0; //Change dev tax on buy here -> 100 = 1%
        buyTax.totalTax = buyTax.marketingTax + buyTax.liquidityTax + buyTax.devTax;

        sellTax.marketingTax = 3000; //Change marketig tax on sell here -> 100 = 1%
        sellTax.liquidityTax = 0; //Change liquidity tax on sell here -> 100 = 1%
        sellTax.devTax = 0; //Change dev tax on sell here -> 100 = 1%
        sellTax.totalTax = sellTax.marketingTax + sellTax.liquidityTax + sellTax.devTax;

        tokensForTax.gasSaver = true;

        doNothing = 0;

        WETH = dexRouter.WETH();
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), WETH);

        isAMMPair[lpPair] = true;

        exemptFromLimits[lpPair] = true;
        exemptFromLimits[msg.sender] = true;
        exemptFromLimits[address(this)] = true;

        exemptFromFees[msg.sender] = true;
        exemptFromFees[address(this)] = true;
        exemptFromFees[address(dexRouter)] = true;
 
        _approve(address(this), address(dexRouter), type(uint256).max);
        _approve(address(msg.sender), address(dexRouter), totalSupply());
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        
        if(!exemptFromFees[from] && !exemptFromFees[to]){
            require(tradingAllowed, "Trading not active");
            amount -= handleTax(from, to, amount);
            checkLimits(from, to, amount);
        }

        super._transfer(from,to,amount);
    }

    function checkLimits(address from, address to, uint256 amount) internal {
        if(limited){
            bool exFromLimitsTo = exemptFromLimits[to];
            uint256 balanceOfTo = balanceOf(to);
            TxLimits memory _txLimits = txLimits;
            // buy
            if (isAMMPair[from] && !exFromLimitsTo) {
                require(amount <= _txLimits.transactionLimit, "Max Txn");
                require(amount + balanceOfTo <= _txLimits.walletLimit, "Max Wallet");
            } 
            // sell
            else if (isAMMPair[to] && !exemptFromLimits[from]) {
                require(amount <= _txLimits.transactionLimit, "Max Txn");
            }
            else if(!exFromLimitsTo) {
                require(amount + balanceOfTo <= _txLimits.walletLimit, "Max Wallet");
            }

            if(transferDelayEnabled){
                if (to != address(dexRouter) && to != address(lpPair)){
                    require(_holderLastTransferBlock[tx.origin] + 30 < block.number, "Transfer Delay");
                    _holderLastTransferBlock[to] = block.number;
                    _holderLastTransferBlock[tx.origin] = block.number;
                    if(from == address(lpPair)){
                        require(tx.origin == to, "no buying to external wallets yet");
                    }
                }
            }

        }

    }

    function handleTax(address from, address to, uint256 amount) internal returns (uint256){

        if(balanceOf(address(this)) >= swapTokensAtAmt && !isAMMPair[from] && lastSwapBackBlock + 1 <= block.number) {
            convertTaxes();
        }
        
        uint128 tax = 0;

        Taxes memory taxes;

        if (isAMMPair[to]){
            taxes = sellTax;
        } else if(isAMMPair[from]){
            taxes = buyTax;
        }
        
        if(taxes.totalTax > 0){
            TokensForTax memory tokensForTaxUpdate = tokensForTax;


            if(launchBlock == block.number){
                if (isAMMPair[from]){
                    tax = uint128(amount * 100 / FEE_DIVISOR);
                } else if (isAMMPair[to]) {
                    tax = uint128(amount * 100 / FEE_DIVISOR);
                }
            } else {
                tax = uint128(amount * taxes.totalTax / FEE_DIVISOR);
            }
            tokensForTaxUpdate.tokensForLiquidity += uint80(tax * taxes.liquidityTax / taxes.totalTax / 1e9);
            tokensForTaxUpdate.tokensForMarketing += uint80(tax * taxes.marketingTax / taxes.totalTax / 1e9);
            tokensForTaxUpdate.tokensForDev += uint80(tax * taxes.devTax / taxes.totalTax / 1e9);
            tokensForTax = tokensForTaxUpdate;
            super._transfer(from, address(this), tax);
        }
        
        return tax;
    }

    function swapTokensForETH(uint256 tokenAmt) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmt,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function convertTaxes() private {

        uint256 contractBalance = balanceOf(address(this));
        TokensForTax memory tokensForTaxMem = tokensForTax;
        uint256 totalTokensToSwap = tokensForTaxMem.tokensForLiquidity + tokensForTaxMem.tokensForMarketing + tokensForTaxMem.tokensForDev;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmt * 10){
            contractBalance = swapTokensAtAmt * 10;
        }

        if(tokensForTaxMem.tokensForLiquidity > 0){
            uint256 liquidityTokens = contractBalance * tokensForTaxMem.tokensForLiquidity / totalTokensToSwap;
            super._transfer(address(this), lpPair, liquidityTokens);
            try ILpPair(lpPair).sync(){} catch {}
            contractBalance -= liquidityTokens;
            totalTokensToSwap -= tokensForTaxMem.tokensForLiquidity;
        }

        if(contractBalance > 0){

            swapTokensForETH(contractBalance);
            
            uint256 ethBalance = address(this).balance;

            bool success;

            if(tokensForTaxMem.tokensForDev > 0){
                (success,) = devAddress.call{value: ethBalance * tokensForTaxMem.tokensForDev / totalTokensToSwap}("");  
            }

            ethBalance = address(this).balance;

            if(ethBalance > 0){
                (success,) = marketingAddress.call{value: ethBalance}("");  
            }
        }

        tokensForTaxMem.tokensForLiquidity = 0;
        tokensForTaxMem.tokensForMarketing = 0;
        tokensForTaxMem.tokensForDev = 0;

        tokensForTax = tokensForTaxMem;
        lastSwapBackBlock = block.number;
    }

    // owner functions
    function setExemptFromFee(address _address, bool _isExempt) external onlyOwner {
        require(_address != address(0), "Zero Address");
        require(_address != address(this), "Cannot unexempt contract");
        exemptFromFees[_address] = _isExempt;
        emit SetExemptFromFees(_address, _isExempt);
    }

    function setExemptFromLimit(address _address, bool _isExempt) external onlyOwner {
        require(_address != address(0), "Zero Address");
        if(!_isExempt){
            require(_address != lpPair, "Cannot remove pair");
        }
        exemptFromLimits[_address] = _isExempt;
        emit SetExemptFromLimits(_address, _isExempt);
    }

    function updateTransactionLimit(uint128 newNumInTokens) external onlyOwner {
        require(newNumInTokens >= (totalSupply() * 1 / 1000)/(10**decimals()), "Too low");
        txLimits.transactionLimit = uint128(newNumInTokens * (10**decimals()));
        emit UpdatedTransactionLimit(txLimits.transactionLimit);
    }

    function updateWalletLimit(uint128 newNumInTokens) external onlyOwner {
        require(newNumInTokens >= (totalSupply() * 1 / 1000)/(10**decimals()), "Too low");
        txLimits.walletLimit = uint128(newNumInTokens * (10**decimals()));
        emit UpdatedWalletLimit(txLimits.walletLimit);
    }

    function updateSwapTokensAmt(uint256 newAmount) external onlyOwner {
        require(newAmount >= (totalSupply() * 1) / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= (totalSupply() * 5) / 1000, "Swap amount cannot be higher than 0.5% total supply.");
        swapTokensAtAmt = newAmount;
    }

    function updateBuyTax(uint64 _marketingTax, uint64 _liquidityTax, uint64 _devTax) external onlyOwner {
        Taxes memory taxes;
        taxes.marketingTax = _marketingTax;
        taxes.liquidityTax = _liquidityTax;
        taxes.devTax = _devTax;
        taxes.totalTax = _marketingTax + _liquidityTax + _devTax;
        require(taxes.totalTax  <= 3000 || taxes.totalTax <= buyTax.totalTax, "Keep tax below 30%");
        emit UpdatedBuyTax(taxes.totalTax);
        buyTax = taxes;
    }

    function updateSellTax(uint64 _marketingTax, uint64 _liquidityTax, uint64 _devTax) external onlyOwner {
        Taxes memory taxes;
        taxes.marketingTax = _marketingTax;
        taxes.liquidityTax = _liquidityTax;
        taxes.devTax = _devTax;
        taxes.totalTax = _marketingTax + _liquidityTax + _devTax;
        require(taxes.totalTax  <= 3000 || taxes.totalTax <= sellTax.totalTax, "Keep tax below 30%");
        emit UpdatedSellTax(taxes.totalTax);
        sellTax = taxes;
    }

    function renounceDevTax() external {
        require(msg.sender == devAddress, "Not dev");
        
        Taxes memory buyTaxes = buyTax;
        buyTaxes.marketingTax += buyTaxes.devTax;
        buyTaxes.devTax = 0;
        buyTax = buyTaxes;

        Taxes memory sellTaxes = sellTax;
        sellTaxes.marketingTax += sellTaxes.devTax;
        sellTaxes.devTax = 0;
        sellTax = sellTaxes;
    }

    function enableTrading() external onlyOwner {
        require(!tradingAllowed, "Trading already enabled");
        tradingAllowed = true;
        launchBlock = block.number;
        lastSwapBackBlock = block.number;
    }

    function removeLimits() external onlyOwner {
        limited = false;
        TxLimits memory _txLimits;
        uint256 supply = totalSupply();
        _txLimits.transactionLimit = uint128(supply);
        _txLimits.walletLimit = uint128(supply);
        txLimits = _txLimits;
        emit RemovedLimits();
    }


    function removeTransferDelay() external onlyOwner {
        require(transferDelayEnabled, "Already disabled!");
        transferDelayEnabled = false;
    }

    function withdrawStuckETH() external {
        bool success;
        (success,) = address(devAddress).call{value: address(this).balance}("");
    }

    function rescueTokens(address _token) external {
    	require(msg.sender == devAddress,"Not dev");
        require(_token != address(0), "_token address cannot be 0");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(_token),address(devAddress), _contractBalance);
    }

    function updateMarketingAddress(address _address) external onlyOwner {
        require(_address != address(0), "zero address");
        marketingAddress = _address;
    }

    function updateDevAddress(address _address) external onlyOwner {
        require(_address != address(0), "zero address");
        devAddress = _address;
    }
    function addNothing() external {
        doNothing +=1;
    }

    

    receive() payable external {}
}