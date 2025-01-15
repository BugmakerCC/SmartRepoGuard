pragma solidity 0.8.26;

// SPDX-License-Identifier: MIT

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract CrypiSplitter is Ownable {
    
    address public incubatorAddress;
    address public projectOwnerAddress;
    address public marketingAddress;

    address public tokenAddress;

    IDexRouter immutable public dexRouter;

    uint256 public constant FEE_DIVISOR = 10000;

    uint256 public minEthToConvert = 0.4 ether;

    event BuyBackAndBurn(uint256 ethAmount, uint256 tokenAmount, uint256 totalBurned);

    struct DistributionPercentages {
        uint24 incubatorPerc;
        uint24 projectOwnerPerc;
        uint24 marketingPerc;
        uint24 buybackPerc;
    }

    DistributionPercentages public distributionPercs;

    constructor(){
        address _v2Router;
        if(block.chainid == 1){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if(block.chainid == 5){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if(block.chainid == 97){
            _v2Router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else if(block.chainid == 42161){
            _v2Router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        } else if(block.chainid == 8453){ // BASE
            _v2Router = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
        } else if(block.chainid == 11155111) { // Sepolia Custom V2 router
            _v2Router = 0xa3D89E5B9C7a863BF4535F349Bc5619ABe72fb09;
        } else {
            revert("Chain not configured");
        }
        dexRouter = IDexRouter(_v2Router);
        incubatorAddress = msg.sender;
        projectOwnerAddress = msg.sender;
        marketingAddress = msg.sender;

        distributionPercs.incubatorPerc = 2333;
        distributionPercs.projectOwnerPerc = 2333;
        distributionPercs.marketingPerc = 667;
        distributionPercs.buybackPerc = 4667;
        require(distributionPercs.incubatorPerc + distributionPercs.projectOwnerPerc + distributionPercs.marketingPerc + distributionPercs.buybackPerc == FEE_DIVISOR, "Must equal 100%");
    }
    
    receive() external payable {
        distributeETH();
    }

    function updateIncubatorAddress(address _address) external onlyOwner {
        require(_address != address(0), "cannot set to 0 address");
        incubatorAddress = _address;
    }

    function updateProjectOwnerAddress(address _address) external onlyOwner {
        require(_address != address(0), "cannot set to 0 address");
        projectOwnerAddress = _address;
    }

    function updateMarketingAddress(address _address) external onlyOwner {
        require(_address != address(0), "cannot set to 0 address");
        marketingAddress = _address;
    }

    function updateTokenAddress(address _address) external onlyOwner {
        tokenAddress = _address;
    }

    function updateMinEthToConvert(uint256 _minEthToConvertInwei) external onlyOwner {
        minEthToConvert = _minEthToConvertInwei;
    }

    function updateDistribution(uint24 _incubator, uint24 _projectOwner, uint24 _marketing, uint24 _buyback) external onlyOwner {
        DistributionPercentages memory distributionPercsMem;
        distributionPercsMem.incubatorPerc = _incubator;
        distributionPercsMem.projectOwnerPerc = _projectOwner;
        distributionPercsMem.marketingPerc = _marketing;
        distributionPercsMem.buybackPerc = _buyback;

        require(distributionPercsMem.incubatorPerc + distributionPercsMem.projectOwnerPerc + distributionPercsMem.marketingPerc + distributionPercsMem.buybackPerc == FEE_DIVISOR, "Must equal 100%");
        distributionPercs = distributionPercsMem;
    }
    
    function distributeETH() internal {
        DistributionPercentages memory distributionPercsMem = distributionPercs;
        uint256 balance = address(this).balance;
        uint256 incubatorAmount = balance * distributionPercsMem.incubatorPerc / FEE_DIVISOR;
        uint256 projectOwnerAmount = balance * distributionPercsMem.projectOwnerPerc / FEE_DIVISOR;
        uint256 marketingAmount = balance * distributionPercsMem.marketingPerc / FEE_DIVISOR;
        
        bool success;

        if(incubatorAmount > 0){
            (success,) = payable(incubatorAddress).call{value: incubatorAmount}("");
        }

        if(projectOwnerAmount > 0){
            (success,) = payable(projectOwnerAddress).call{value: projectOwnerAmount}("");
        }

        if(marketingAmount > 0){
            (success,) = payable(marketingAddress).call{value: marketingAmount}("");
        }

        uint256 ethAmount = address(this).balance;

        if(tokenAddress != address(0) && ethAmount >= minEthToConvert){
            uint256 initialBalance = IERC20(tokenAddress).balanceOf(address(0xdead));
            
            swapEthForCFUN(ethAmount, 1);
            uint256 totalBurned = IERC20(tokenAddress).balanceOf(address(0xdead));
            uint256 deltaBalance = totalBurned - initialBalance;
            emit BuyBackAndBurn(ethAmount, deltaBalance, totalBurned);
        }
    }

    function buyBackAndBurnManually(uint256 amountOutMin) external payable {
        require(tokenAddress != address(0), "Token not active yet");

        uint256 initialBalance = IERC20(tokenAddress).balanceOf(address(0xdead));
        
        swapEthForCFUN(msg.value, amountOutMin);
        uint256 totalBurned = IERC20(tokenAddress).balanceOf(address(0xdead));
        uint256 deltaBalance = totalBurned - initialBalance;
        emit BuyBackAndBurn(msg.value, deltaBalance, totalBurned);
    }

    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success,) = payable(msg.sender).call{value: address(this).balance}("");
    }

    function swapEthForCFUN(uint256 amountInWei, uint256 amountOutMin) private {
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(tokenAddress);

        // make the swap
        dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountInWei}(
            amountOutMin, // accept any amount of Ethereum
            path,
            address(0xdead),
            block.timestamp
        );
    }
}