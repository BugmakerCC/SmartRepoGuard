// SPDX-License-Identifier: MIT
/*
*
* X / Twitter: https://x.com/presidencygames
* Website: https://presidency.games
* Telegram: https://t.me/presidency_games
*
* Presidency Games on Ethereum!
*
* Uncle Don to make Murica Grape? Or make sure we aint goin back? 
* Just click the hackin' button to decide the next $PRESIDENT This is a game on Ethereum with zero tx needed to play. 
* Play it on the website or just join TG: 
* Each voting round takes 1 hour and 5% of all $PRESIDENT will go to the winner candidates Ethereum wallet. 
* One lucky voter gets the jackpot once their fav President is elected for real! 
* You are to decide if ElonBoss goes to MaRs or cry in his cybertruck. 
* CliCk ClIcK cliCK!
*
*/

pragma solidity ^0.8.17;

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract President is ERC20, Ownable {
    address private marketingWallet;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public launchedBlock = 0;

    bool    private swapping;
    uint256 public swapTokensAtAmount;

    mapping (address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    bool    public maxWalletLimitEnabled = true;
    uint256 maxWalletAmount;

    address public operator = 0x4B8cF9FEC083a8b854d285c4Ef507464FC105F11; 

    address public donald = 0x94845333028B1204Fbe14E1278Fd4Adde46B22ce;

    address public kamala = 0x000000000000000000000000000000000000dEaD;

    uint256 public lastRound = 0;

    uint256 public finalRound = 290;

    uint256 public donateAmount;
    uint256 public donateReserve;

    uint256 private constant startTime = 1729724400; 

    uint256 private constant roundDuration = 3600; 

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor (address _marketingWallet) ERC20("President", "PRESIDENT")
    {   
        marketingWallet = _marketingWallet;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[DEAD] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        
        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[DEAD] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[marketingWallet] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;
        
        _mint(owner(), 335_042_069 * (10 ** 18));
        uint256 tSupply = totalSupply();
        swapTokensAtAmount = tSupply / 1000;
        maxWalletAmount = tSupply * 2 / 100;
        donateAmount = 5 * tSupply / (finalRound * 100);
        donateReserve = 5 * tSupply / 100;

        super._transfer(owner(), address(this), donateReserve);
    }

    receive() external payable {

}
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function launch() external payable onlyOwner {
        require(launchedBlock == 0, "Already launched");
        require(msg.value >= 1 ether, "Need 1 ETH to launch");
        uint256 tokenAmount = totalSupply() * 90 / 100;
        super._transfer(owner(), address(this),tokenAmount);
        uint256 ethAmount = 1 ether;
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(), 
            block.timestamp
        );
        launchedBlock = block.number;
    }

    function removeStuckETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
		uint256 caBalance = balanceOf(address(this));
        if (donateReserve > caBalance) {
            donateReserve = caBalance;
        }
        caBalance -= donateReserve;

        if( 
            block.number - launchedBlock > 6 &&
            !swapping &&
            from != uniswapV2Pair &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            swapping = true;
            uint256 pairBalance = balanceOf(uniswapV2Pair);

            if (caBalance >= pairBalance / 100) 
                caBalance = pairBalance / 100;
            
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                caBalance,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp);
            uint256 newBalance = address(this).balance;

            if (newBalance > 0){
                payable(marketingWallet).transfer(newBalance);
            }   
            
            swapping = false;
        }

        bool takeFee = !swapping;
        
        if((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || ( from != uniswapV2Pair && to != uniswapV2Pair)){
            takeFee = false;
        }
        
        if(takeFee) {
            uint256 _tFees = 0;
            if(from == uniswapV2Pair || to == uniswapV2Pair) {
                _tFees = 42;
            }
            
            if (_tFees > 0) {
                if (block.number - launchedBlock < 250)
                    _tFees = _tFees * ((250 - (block.number - launchedBlock)) / 5);
                uint256 fee = amount * _tFees / 10000;
                amount = amount - fee;
                super._transfer(from, address(this), fee);
            }
        
        }

        if (maxWalletLimitEnabled && block.number - launchedBlock < 600) 
        {  
            
            if (_isExcludedFromMaxWalletLimit[from]  == false && 
                _isExcludedFromMaxWalletLimit[to]    == false &&
                from == uniswapV2Pair
            ) {
                
                uint balance  = balanceOf(to);
                require(
                    balance + amount <= maxWalletAmount, 
                    "MaxWallet: Recipient exceeds the maxWalletAmount"
                );
                
            }
        }  
        
        super._transfer(from, to, amount);
    }    


    function donate(bool toDonald, uint256 round) external {
        require(lastRound < finalRound, "No more rounds");
        require(msg.sender == operator, "Access denied");
        require(round == lastRound + 1, "Wrong round");
        require(startTime + round * roundDuration <= block.timestamp, "Invalid round");

        if (toDonald) {
            super._transfer(address(this), donald, donateAmount);
        } else {
            super._transfer(address(this), kamala, donateAmount);
        }

        donateReserve -= donateAmount;

        lastRound += 1;
    }
}