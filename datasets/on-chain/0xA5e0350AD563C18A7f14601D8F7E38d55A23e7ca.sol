/**

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

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

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
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

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _generateSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

     function _burnSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply -= amount;
        _balances[account] -= amount;
         emit Transfer(account, address(0x000000000000000000000000000000000000dEaD), amount);
     
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface UniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

}

interface UniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}


contract Geeks is ERC20, Ownable {
    UniswapV2Router public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public GeeksAddr = address(0);
    IERC20 public GeeksToken;
    uint256 public maxWallet;
    uint256 public maxTxnAmount;
    bool private swappingETH;
    bool private swappingTKN;
    uint256 public swapTokensAtAmount;
    uint256 public swapLimit;
    address public devWallet = 0x27E78a81efDC7f0cA14CbbC3E50dD812D7F5264F;
    address public marketingWallet = 0x6e68c68CfAc0bA5Ae01fDA6C61c0DA3D209A1728;
    bool public limitsInEffect = true;
    bool public tradingLive = false;
    bool public swapEnabled = false;
    address public bridgeContract = 0x13e65B7C2066926aC90E6b09831cF460F9ee16E8;
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    uint256 public ethPairTaxedTokens;
    uint256 public tokenPairTaxedTokens;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => TaxRates) public pairTaxRates;
    mapping(address => mapping(address => bool)) private _isExcludedMaxTransactionAmount;
    mapping(address => mapping(address => bool)) private _isExcludedFromFees;

     struct TaxRates {
        uint256 buyTax;
        uint256 sellTax;
    }

    event EnabledTrading();

    event RemovedLimits();

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event UpdatedTxnAmount(uint256 newAmount);

    event UpdatedMaxWalletAmount(uint256 newAmount);

    event MaxTransactionExclusion(address _address, bool excluded);

    event OwnerManualCollection(uint256 timestamp);


    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetTaxRates(address indexed pair, uint256 buyTax, uint256 sellTax);
    event ExcludeFromMaxTransaction(address indexed updAds, address indexed pair, bool isEx);
    event ExcludeFromFees(address indexed updAds, address indexed pair, bool isEx);



    constructor() ERC20("Geeks", "Geeks") {
        UniswapV2Router _uniswapV2Router = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = UniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this),_uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), uniswapV2Pair, true);
        excludeFromMaxTransaction(uniswapV2Pair, uniswapV2Pair, true);
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        uint256 totalSupply = 1000000000 * 10 ** 18;
        maxWallet = 10000000 * 10 ** 18;
        maxTxnAmount = 10000000 * 10 ** 18;
        swapTokensAtAmount = 1000000 * 10 ** 18; 
        swapLimit = 5;
        setTaxRates(uniswapV2Pair,10,25);
        excludeFromFees(owner(),uniswapV2Pair, true);
        excludeFromFees(devWallet,uniswapV2Pair, true);
        excludeFromFees(marketingWallet,uniswapV2Pair, true);
        excludeFromFees(address(this),uniswapV2Pair, true);
        excludeFromFees(address(0xdead),uniswapV2Pair, true);
        excludeFromMaxTransaction(owner(),uniswapV2Pair, true);
        excludeFromMaxTransaction(devWallet,uniswapV2Pair, true);
        excludeFromMaxTransaction(marketingWallet, uniswapV2Pair,true);
        excludeFromMaxTransaction(address(this),uniswapV2Pair, true);
        excludeFromMaxTransaction(address(0xdead),uniswapV2Pair, true);
        _generateSupply(msg.sender, totalSupply);
        transferOwnership(msg.sender);
    }

    receive() external payable {}

    // ENABLE TRADING
    function enableTrading() external onlyOwner {
        require(!tradingLive, "Trading already live!");
        tradingLive = true;
        swapEnabled = true;
        emit EnabledTrading();
    }

     function setSwapLimit(uint256 _limit) public onlyOwner {
        swapLimit = _limit;
    } 
    

    function setGeeksContract(IERC20 _GeeksToken,address _Geeks) public onlyOwner {
        GeeksAddr = _Geeks;
        GeeksToken = _GeeksToken;
    } 

        function setMarketingWallet(address _wallet) external onlyOwner {
        marketingWallet = _wallet;
    } 

        function setDevWallet(address _wallet) external onlyOwner {
        devWallet = _wallet;
    } 

      function bridgeMint(uint256 amount, address reciever) external {
        require(msg.sender == bridgeContract, "Only Callable By bridge Contract");
          _generateSupply(reciever, amount);
    }

     function bridgeBurn(uint256 amount, address user) external {
        require(msg.sender == bridgeContract, "Only Callable By bridge Contract");
          _burnSupply(user, amount);
    }

         function updatebridge(address _newBridge) external onlyOwner{
         bridgeContract = _newBridge;
    }

    // REMOVE TXN LIMITS
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        emit RemovedLimits();
    }

    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        maxTxnAmount = newNum * (10 ** 18);
        emit UpdatedTxnAmount(maxTxnAmount);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        maxWallet = newNum * (10 ** 18);
        emit UpdatedMaxWalletAmount(maxWallet);
    }

    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        swapTokensAtAmount = newAmount;
    }


      function RemoveAutomatedMarketMakerPair(address pair)  external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, false);
        emit SetAutomatedMarketMakerPair(pair, false);
    }

    function initToken1NewAutomatedMarketMakerPair(address token1, address token2, uint256 buyTax, uint256 sellTax)  external onlyOwner {
       address pair = UniswapV2Factory(uniswapV2Router.factory()).createPair(token1,token2);
        _setAutomatedMarketMakerPair(pair, true);
        setTaxRates(pair, buyTax, sellTax);
        emit SetAutomatedMarketMakerPair(pair, true);
    }

     function logPairToken2(address pair, bool value) external onlyOwner {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updatePairforToken1AndToken2(address pair) external onlyOwner{
        excludeFromMaxTransaction(pair,pair,true);
        excludeFromMaxTransaction(router,pair,true);
        excludeFromMaxTransaction(owner(),pair, true);
        excludeFromMaxTransaction(devWallet,pair, true);
        excludeFromMaxTransaction(marketingWallet, pair,true);
        excludeFromMaxTransaction(address(this),pair, true);
        excludeFromMaxTransaction(address(0xdead),pair, true);
        excludeFromFees(owner(),pair, true);
        excludeFromFees(devWallet,pair, true);
        excludeFromFees(marketingWallet,pair, true);
        excludeFromFees(address(this),pair, true);
        excludeFromFees(address(0xdead),pair, true); 
    }


  function setTaxRates(address pair, uint256 buyTax, uint256 sellTax) public onlyOwner {
        require(buyTax <= 25, "Buy tax too high"); 
        require(sellTax <= 25, "Sell tax too high"); 
        pairTaxRates[pair] = TaxRates(buyTax, sellTax);
        emit SetTaxRates(pair, buyTax, sellTax);
    }


      function getTaxRates(address pair) external view returns (uint256 buyTax, uint256 sellTax) {
        TaxRates memory rates = pairTaxRates[pair];
        return (rates.buyTax, rates.sellTax);
    }

    function excludeFromMaxTransaction(address updAds, address pair, bool isEx) public onlyOwner {
        require(updAds != address(0), "Address cannot be the zero address");
        _isExcludedMaxTransactionAmount[updAds][pair] = isEx;
        emit ExcludeFromMaxTransaction(updAds, pair, isEx);
    }

  
 function isExcludedFromMaxTransaction(address updAds, address pair) public view returns (bool) {
        return _isExcludedMaxTransactionAmount[updAds][pair];
    }


  function excludeFromFees(address updAds, address pair, bool isEx) public onlyOwner {
        require(updAds != address(0), "Address cannot be the zero address");
        _isExcludedFromFees[updAds][pair] = isEx;
        emit ExcludeFromFees(updAds, pair, isEx);
    }


     function isExcludedFromFees(address updAds, address pair) public view returns (bool) {
        return _isExcludedFromFees[updAds][pair];
    }


function _transfer(
    address from,
    address to,
    uint256 amount
) internal override {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "amount must be greater than 0");

    bool isBuy = automatedMarketMakerPairs[from];
    bool isSell = automatedMarketMakerPairs[to];

    address pair = isBuy ? from : (isSell ? to : address(0));

    if (!tradingLive) {
        require(
            isExcludedFromFees(from, pair) || isExcludedFromFees(to, pair),
            "Trading is not active."
        );
    }

    if (limitsInEffect) {
        if (
            from != owner() &&
            to != owner() &&
            !isExcludedFromFees(from, pair) &&
            !isExcludedFromFees(to, pair)
        ) {
            if (isBuy) {
                require(
                    amount <= maxTxnAmount,
                    "Buy transfer amount exceeds the max txn."
                );
                require(
                    amount + balanceOf(to) <= maxWallet,
                    "Cannot exceed max wallet"
                );
            } else if (isSell) {
                require(
                    amount <= maxTxnAmount,
                    "Sell transfer amount exceeds the max txn."
                );
            } else {
                require(
                    amount + balanceOf(to) <= maxWallet,
                    "Cannot exceed max wallet"
                );
            }
        }
    }

    uint256 contractETHTokenBalance = ethPairTaxedTokens;
    uint256 contractTokenBalance = tokenPairTaxedTokens;

    bool canSwapETH = contractETHTokenBalance >= swapTokensAtAmount;
    bool canSwapTKN = contractTokenBalance >= swapTokensAtAmount;

    if (
        canSwapETH &&
        swapEnabled &&
        !swappingETH &&
        !isBuy &&
        !isExcludedFromFees(from, pair) &&
        !isExcludedFromFees(to, pair)
    ) {
        swappingETH = true;
        collectETHFees();
        swappingETH = false;
    }

    if (
        canSwapTKN &&
        swapEnabled &&
        !swappingTKN &&
        !isBuy &&
        !isExcludedFromFees(from, pair) &&
        !isExcludedFromFees(to, pair)
    ) {
        swappingTKN = true;
        collectTokenFees();
        swappingTKN = false;
    }

    bool takeEthFee = false;
    bool takeTokenFee = false;

    if (pair == uniswapV2Pair) {
        takeEthFee = true;
    } else if (pair != uniswapV2Pair) {
        takeTokenFee = true;
    } else {
        revert("Invalid pair address");
    }

    if (isExcludedFromFees(from, pair) || isExcludedFromFees(to, pair)) {
        takeEthFee = false;
        takeTokenFee = false;
    }

    uint256 fees = 0;

    if (takeEthFee) {
        // Apply ETH fees based on transaction type
        if (isSell) {
            TaxRates memory sellTaxRates = pairTaxRates[to];
            if (sellTaxRates.sellTax > 0) {
                fees = (amount * sellTaxRates.sellTax) / 100;
                ethPairTaxedTokens += fees;
            }
        } else if (isBuy) {
            TaxRates memory buyTaxRates = pairTaxRates[from];
            if (buyTaxRates.buyTax > 0) {
                fees = (amount * buyTaxRates.buyTax) / 100;
                ethPairTaxedTokens += fees;
            }
        }

        if (fees > 0) {
            super._transfer(from, address(this), fees);
        }
        amount -= fees;
    }

    if (takeTokenFee) {
        // Apply Token fees based on transaction type
        if (isSell) {
            TaxRates memory sellTaxRates = pairTaxRates[to];
            if (sellTaxRates.sellTax > 0) {
                fees = (amount * sellTaxRates.sellTax) / 100;
                tokenPairTaxedTokens += fees;
            }
        } else if (isBuy) {
            TaxRates memory buyTaxRates = pairTaxRates[from];
            if (buyTaxRates.buyTax > 0) {
                fees = (amount * buyTaxRates.buyTax) / 100;
                tokenPairTaxedTokens += fees;
            }
        }

        if (fees > 0) {
            super._transfer(from, address(this), fees);
        }
        amount -= fees;
    }

    super._transfer(from, to, amount);
}




    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function swapTokensForTokens(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = GeeksAddr;

   
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        devWallet,
        block.timestamp
    );
}

    function collectETHFees() private {
        uint256 totalEthTokensToSwap = ethPairTaxedTokens;
        uint256 contractBalance = balanceOf(address(this));

        if (totalEthTokensToSwap == 0 && contractBalance == 0) {
            return;
        }

        if (limitsInEffect) {
            if (totalEthTokensToSwap > swapTokensAtAmount * swapLimit) {
                totalEthTokensToSwap = swapTokensAtAmount * swapLimit;
            }
        }
        else
         {
            if (totalEthTokensToSwap > swapTokensAtAmount) {
                totalEthTokensToSwap = swapTokensAtAmount;
            }
        }

        bool success;

        swapTokensForEth(totalEthTokensToSwap);

        ethPairTaxedTokens -= totalEthTokensToSwap;

        if (address(this).balance > 0) {
            (success, ) = address(marketingWallet).call{value: address(this).balance}(
                ""
            );
        }
    }





    function collectTokenFees() private {
        uint256 totalGeeksTokensToSwap = tokenPairTaxedTokens;
      

        if (totalGeeksTokensToSwap == 0) {
            return;
        }

        if (limitsInEffect) {
            if (totalGeeksTokensToSwap > swapTokensAtAmount * swapLimit) {
                totalGeeksTokensToSwap = swapTokensAtAmount * swapLimit;
            }
        } else {
            if (totalGeeksTokensToSwap > swapTokensAtAmount) {
                totalGeeksTokensToSwap = swapTokensAtAmount;
            }
        }
        swapTokensForTokens(totalGeeksTokensToSwap);
        tokenPairTaxedTokens -= totalGeeksTokensToSwap;
    }

    //Remove any clog from contract
    function manualTokenSwap() external onlyOwner {
        require(tokenPairTaxedTokens >= 0, "No tokens to swap");
        swappingTKN = true;
        collectTokenFees();
        swappingTKN = false;
       
    }

    function manualETHSwap() external  onlyOwner{
        require(ethPairTaxedTokens >= 0, "No tokens to swap");
        swappingETH = true;
        collectETHFees();
        swappingETH = false;
     
    }

    //Remove Tokens from contract
        function manualTokenCollection() external onlyOwner{
            uint256 balance = this.balanceOf(address(this));
            uint256 allocated = ethPairTaxedTokens + tokenPairTaxedTokens;
            require(balance > allocated, "Cant Remove Tokens That Are Allocated for swapping");
            uint256 tokenBalance = balance - allocated;
            super._transfer(address(this), devWallet, tokenBalance);
    }


     //Remove any sent eth to contract
    function withdrawETH() external onlyOwner{
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
}