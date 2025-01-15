/**
TOKEN

**/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.26;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

interface IStaking {
    function depositRewards(uint256 reward) external;
}

contract Nodex is Context, IERC20, Ownable {
    uint256 private constant _totalSupply = 1000_000_000e18;
    uint128 public minSwap = uint128(_totalSupply/400);
    uint128 public maxSwap = uint128(_totalSupply/200);

    IUniswapV2Router02 immutable uniswapV2Router;
    address immutable uniswapV2Pair;
    address immutable WETH;
    address payable immutable marketingWallet;

    IStaking public stakingContract;

    uint64 public constant buyTax = 10;
    uint64 public constant sellTax = 10;

    uint8 public launch;
    uint8 private inSwapAndLiquify;
    uint64 public lastLiquifyTime;

    uint256 public maxTxAmt = _totalSupply * 2 / 100; //max Tx for first mins after launch

    string private constant _name = "NodeX";
    string private constant _symbol = "NODEX";

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = uniswapV2Router.WETH();

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );

        marketingWallet = payable(0xD2e5DbC6A3155237c324ceAA236c87CfACc26711);
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256)
            .max;

        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setNodexStakingContractAddress(address _staking) external onlyOwner {
        stakingContract = IStaking(_staking);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableNodeX() external onlyOwner {
        launch = 1;
        lastLiquifyTime = uint64(block.number);
    }

    function removeLimits() external onlyOwner {
        maxTxAmt = _totalSupply;
    }

    function changeMaxSwapbackThreshold(
        uint128 newMaxSwapThreshold
    ) external onlyOwner {
        require(
            newMaxSwapThreshold * 1e18 > minSwap,
            "Max Swap cannot be less than min swap"
        );
        maxSwap = newMaxSwapThreshold * 1e18;
    }

    function changeMinSwapbackThreshold(
        uint128 newMinSwapThreshold
    ) external onlyOwner {
        require(
            newMinSwapThreshold * 1e18 < maxSwap,
            "Min Swap cannot be greater than max swap"
        );
        minSwap = newMinSwapThreshold * 1e18;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        if (amount <= 1e9) {
            //Small amounts
            _balance[from] -= amount;
            unchecked {
                _balance[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }

        uint256 _tax;
        if(from == owner() || to == address(stakingContract) || from == address(stakingContract) || to == owner()) {
            _tax = 0;
        } else {
            require(
                launch != 0 && amount <= maxTxAmt,
                "Launch / Max TxAmount 2% at launch"
            );

            if (inSwapAndLiquify == 1) {
                //In swapback
                _balance[from] -= amount;
                unchecked {
                    _balance[to] += amount;
                }
                emit Transfer(from, to, amount);
                return;
            }

            //Buy
            if (from == uniswapV2Pair) {
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                //Sell
                uint256 tokensToSwap = _balance[address(this)];

                if (
                    tokensToSwap > minSwap &&
                    inSwapAndLiquify == 0 &&
                    lastLiquifyTime != uint64(block.number)
                ) {
                    if (tokensToSwap > maxSwap) {
                        tokensToSwap = maxSwap;
                    }

                    swapback(tokensToSwap);
                }

                _tax = sellTax;
            } else {
                //Normal Transfer
                _tax = 0;
            }
        }

        //Is there tax for sender|receiver?
        if (_tax != 0) {
            //Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            unchecked {
                _balance[to] += transferAmount;
                _balance[address(this)] += taxTokens;
            }

            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            //No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function swapback(uint256 tokensToSwap) internal {

        inSwapAndLiquify = 1;

        //20% of Token for staking
        //tokensToSwap will always be > 0 tokens
        uint forStaking = tokensToSwap / 5; // 100% / 5 = 20%
        uint forSwapback;

        unchecked {
            forSwapback = tokensToSwap - forStaking; //100% - 20% = 80%
        }
       
        //Deposit staking
        try stakingContract.depositRewards(forStaking) {
            //Transfer to staking (only if call to staking contract works)
            unchecked {
                _balance[address(this)] -= forStaking;
                _balance[address(stakingContract)] += forStaking;
                emit Transfer(
                    address(this),
                    address(stakingContract),
                    forStaking
                );
            }
        } catch {
            //If call to staking contract fails, don't transfer tokens to it
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        //Don't break selling if swapback fails
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            forSwapback,
            0,
            path,
            marketingWallet,
            block.timestamp
        ) {} catch {}
        
        lastLiquifyTime = uint64(block.number);
        inSwapAndLiquify = 0;
    }

    receive() external payable {}
}