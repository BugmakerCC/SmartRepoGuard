// SPDX-License-Identifier: MIT

/*
*   We print.. the world's biggest and first ever token receipt
*
*   Twitter/X:  https://x.com/etherreceipt
*   Telegram:   https://t.me/etherreceipt
*   Website:    https://etherreceipt.fun
*/

pragma solidity 0.8.28;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address public _owner;
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

}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract EtherReceipt is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet = payable(0x275961a2E8DDcAEaA03191C7623678DCd301E10b);

    uint256 private _tax=10;
    uint256 private _preventSwap=30;
    uint256 private _buyCount=0;

    uint256 public _taxSwapThreshold = 800000 * 10**decimals();
    uint256 public _sendETHToTaxThreshold = 0.5 ether;

    IRouter private router;
    address private pair;
    address private routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = totalSupply();
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), totalSupply());
    }

    function name() public pure returns (string memory) {
        return "Ether Receipt";
    }

    function symbol() public pure returns (string memory) {
        return "RECEIPT";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure override returns (uint256) {
        return 100000000 * 10**decimals();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - (amount));
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            if(!inSwap){
              taxAmount = amount * _tax / (100);
            }

            if (from == pair && to != address(router) && ! _isExcludedFromFee[to] ) {
                _buyCount++;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwap) {
                cLogConvert(_taxSwapThreshold > amount ? amount : _taxSwapThreshold);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > _sendETHToTaxThreshold) {
                    sendETHToTax(address(this).balance);
                }
            }
        }

        _balances[from]=_balances[from] - amount;
        _balances[to]=_balances[to] + (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)] + (taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
    }

    function cLogConvert(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToTax(uint256 amount) private {
        _taxWallet.transfer(amount);    
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"Trading is already open");
        router = IRouter(routerAddress);
        _approve(address(this), address(router), totalSupply());
        pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
        IERC20(pair).approve(address(router), type(uint).max);
    }

    function cLogToETH() external {
        require(_msgSender() == _taxWallet);
        cLogConvert(balanceOf(address(this)));
    }

    function ethToTax(uint256 amount) external {
        require(_msgSender() == _taxWallet);
        sendETHToTax(amount);
    }

    function cLogToTax() external {
        require(_msgSender() == _taxWallet);
        IERC20(address(this)).transfer(msg.sender, balanceOf(address(this)));
    }

    receive() external payable {}
}