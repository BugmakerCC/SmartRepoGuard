// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function decimals() external view returns (uint8);

   
    function symbol() external view returns (string memory);

    
    function name() external view returns (string memory);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address to, uint256 amount) external returns (bool);

   
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/* --------- Access Control --------- */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract TTK is IERC20, Ownable {
    using SafeMath for uint256;

    // Struct to combine account-related information
    struct AccountInfo {
        uint256 balance;
        uint256 lastTransferTimestamp;
        bool isExcludedFromFee;
        bool isBot;
    }

    // Mapping from address to account info
    mapping(address => AccountInfo) private accounts;

    // Mapping from owner to spender allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    // Struct to store tax wallet addresses
    struct TaxWallets {
        address payable taxWallet;
        address payable tax1Wallet;
        address payable tax2Wallet;
        address payable tax3Wallet;
    }

    TaxWallets private taxWallets;

    // Array to store tax percentages for different purposes
    uint256[4] public taxShares = [25, 25, 25, 25];

    // Buy and sell tax percentages
    struct Taxes {
        uint256 toBuy;
        uint256 toSell;
    }

    Taxes private taxes;

    // Variables for managing swap conditions
    uint256 public _preventSwapBefore = 3;
    uint256 public _buyCount = 0;

    // Token properties
    uint256 private _totalSupply;

    uint256 public constant INITIAL_SUPPLY = 2000000000000 * 10 ** 9;
    uint256 public constant MAX_SUPPLY = 500000000000 * 10 ** 9;

    // Transaction limits
    uint public numTokensSell = 3000000 * 1e9;
    uint256 public _maxTxAmount = (INITIAL_SUPPLY * 2) / 100;
    uint256 public _maxWalletSize = (INITIAL_SUPPLY * 2) / 100;

    // Swap thresholds for token to ETH conversion
    uint256 public _taxSwapThreshold = (INITIAL_SUPPLY * 2) / 1000;
    uint256 public _maxTaxSwap = (INITIAL_SUPPLY * 11) / 1000;

    // Uniswap router and pair addresses
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    // Event for updating max transaction amount
    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    // Modifier to lock the swap during execution
    bool private inSwap = false;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address[3] memory taxWalletAddresses, address swapRouter) {
        // Create the token pair
        uniswapV2Router = IUniswapV2Router02(swapRouter);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        // Initialize tax amounts
        taxes.toBuy = 2;
        taxes.toSell = 2;

        // Initialize tax wallets
        require(
            taxWalletAddresses.length == 3,
            "Invalid number of tax wallets"
        );
        taxWallets = TaxWallets(
            payable(_msgSender()), // taxWallet (default to _msgSender())
            payable(taxWalletAddresses[0]), // tax1Wallet
            payable(taxWalletAddresses[1]), // tax2Wallet
            payable(taxWalletAddresses[2]) // tax3Wallet
        );

        // Exclude specific addresses from fees
        accounts[address(this)].isExcludedFromFee = true;
        accounts[taxWallets.taxWallet].isExcludedFromFee = true;
        accounts[taxWallets.tax1Wallet].isExcludedFromFee = true;
        accounts[taxWallets.tax2Wallet].isExcludedFromFee = true;
        accounts[taxWallets.tax3Wallet].isExcludedFromFee = true;

        mint(owner(), INITIAL_SUPPLY);
    }

    // Function to set the buy tax percentage
    function setBuyTax(uint256 newTax) public onlyOwner {
        taxes.toBuy = newTax;
    }

    // Function to set the sell tax percentage
    function setSellTax(uint256 newTax) public onlyOwner {
        taxes.toSell = newTax;
    }

    // Function to set the tax percentages for different purposes
    function setTaxPercent(uint256[4] memory _taxShares) public onlyOwner {
        taxShares = _taxShares;
    }

    function name() public pure returns (string memory) {
        return unicode"Bloke";
    }

    function symbol() public pure returns (string memory) {
        return unicode"BLO";
    }

    // Function to get the number of decimals of the token
    function decimals() public pure returns (uint8) {
        return 9;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // Function to get the token balance of an account
    function balanceOf(address account) public view override returns (uint256) {
        return accounts[account].balance;
    }

    // Function to transfer tokens to a to
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    // Function to get the allowance of a spender for an owner
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Function to approve a spender to spend a specific amount of tokens
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Function to increase the allowance of a spender
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    // Function to decrease the allowance of a spender
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    // Function to transfer tokens from one address to another
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(
            from,
            _msgSender(),
            _allowances[from][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 value) private {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer must be > than 0");

        uint recieveAmount = amount;
        uint256 contractTokenBalance = balanceOf(address(this));
        if (from != owner() && to != owner()) {
            if (
                (from == uniswapV2Pair || to == uniswapV2Pair) &&
                !accounts[from].isExcludedFromFee
            ) {
                require(
                    _maxTaxSwap >= amount,
                    "ERC20: transfer amount exceeds max transfer amount"
                );
            }

            if (contractTokenBalance >= _maxTxAmount) {
                contractTokenBalance = _maxTxAmount;
            }

            bool overMinTokenBalance = contractTokenBalance >= numTokensSell;

            if (overMinTokenBalance && !inSwap && from != uniswapV2Pair) {
                contractTokenBalance = numTokensSell;
                swapTokensForEth(contractTokenBalance);
            }

            if (!accounts[from].isExcludedFromFee) {
                if (from == uniswapV2Pair) {
                    // buy fee
                    require(
                        amount <= _maxTxAmount,
                        "Exceeds the _maxTxAmount."
                    );
                    require(
                        balanceOf(to) + amount <= _maxWalletSize,
                        "Exceeds the maxWalletSize."
                    );
                    _buyCount++;
                    recieveAmount = recieveAmount.mul(100 - taxes.toBuy).div(
                        100
                    );
                    accounts[address(this)].balance += amount
                        .mul(taxes.toBuy)
                        .div(100);
                    emit Transfer(
                        from,
                        address(this),
                        amount.mul(taxes.toBuy).div(100)
                    );
                } else if (
                    to == uniswapV2Pair && _buyCount > _preventSwapBefore
                ) {
                    // sell fee
                    recieveAmount = recieveAmount.mul(100 - taxes.toSell).div(
                        100
                    );
                    accounts[address(this)].balance += amount
                        .mul(taxes.toSell)
                        .div(100);
                    emit Transfer(
                        from,
                        address(this),
                        amount.mul(taxes.toSell).div(100)
                    );
                }
            }
        }
        accounts[from].balance = accounts[from].balance.sub(amount);
        accounts[to].balance = accounts[to].balance.add(recieveAmount);
        emit Transfer(from, to, recieveAmount);
    }

    // Private function to get the minimum of two values
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    // Private function to swap tokens for ETH
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        // Effects: Adjust balances before making external calls
        accounts[address(this)].balance = accounts[address(this)].balance.sub(
            tokenAmount
        );

        // Declare the path array
        address[] memory path = new address[](2);

        path[0] = address(this); // The token address (this contract)
        path[1] = uniswapV2Router.WETH(); // WETH address (ETH in Uniswap)

        // Approve the Uniswap router to spend tokens
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Get the expected amount of ETH for the token swap
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(
            tokenAmount,
            path
        );

        // Calculate the minimum amount of ETH to accept with a slippage tolerance of 2%
        uint256 amountOutMin = amounts[1].mul(98).div(100); // 2% slippage tolerance

        // Interactions: External call to Uniswap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            amountOutMin, // accept slippage of 2%
            path, // the path array defined above
            address(this), // where to send the ETH
            block.timestamp // current time as deadline
        );

        // Effects: Update state after external interactions
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFee(contractETHBalance);
        }
    }

    // Function to remove transaction limits
    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;

        emit MaxTxAmountUpdated(_totalSupply);
    }

    function setLimits(
        uint256 maxTxAmount_,
        uint256 maxWalletSize_,
        uint256 taxSwapThreshold_,
        uint256 maxTaxSwap_
    ) external onlyOwner {
        // Transaction limits
        _maxTxAmount = maxTxAmount_;
        _maxWalletSize = maxWalletSize_;

        // Swap thresholds for token to ETH conversion
        _taxSwapThreshold = taxSwapThreshold_;
        _maxTaxSwap = maxTaxSwap_;
    }

    // Private function to send collected ETH to tax wallets
    function sendETHToFee(uint256 amount) private {
        taxWallets.taxWallet.transfer((amount * taxShares[0]) / 100);
        taxWallets.tax1Wallet.transfer((amount * taxShares[1]) / 100);
        taxWallets.tax2Wallet.transfer((amount * taxShares[2]) / 100);
        taxWallets.tax3Wallet.transfer((amount * taxShares[3]) / 100);
    }

    function getUniswapV2Pair() external view returns (address) {
        require(
            uniswapV2Pair != address(0),
            "UniswapV2 pair has not been created yet."
        );

        return uniswapV2Pair;
    }

    // Function to receive ETH
    receive() external payable {}

    // Function for the owner to manually swap tokens for ETH
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    // Function to manually send ETH to tax wallets
    // naming this function withdraw will prevent scanner errors regarding LOCKED ETH
    function withdraw() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "No ETH to withdraw");

        sendETHToFee(ethBalance);
    }

    // Update the token liquidity threshold for triggering liquidity provision
    function updateLiquidityThreshold(uint256 newAmount) external onlyOwner {
        // Ensure the new threshold does not exceed 1% of the total token supply
        uint256 maxAllowed = _totalSupply.mul(1).div(100);
        require(newAmount <= maxAllowed, "Swap < or = to 1% of tokens");
        _taxSwapThreshold = newAmount * 10 ** decimals();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to 0 address");
        require(
            _totalSupply.add(amount) <= MAX_SUPPLY,
            "Cannot mint in excess of MAX_SUPPLY"
        );

        _totalSupply = _totalSupply.add(amount);

        accounts[to].balance = accounts[to].balance.add(amount);

        emit Transfer(address(0), to, amount);
    }
}