/**
 *Submitted for verification at Etherscan.io on 2024-10-14
*/

// SPDX-License-Identifier: MIT
// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
pragma solidity ^0.8.20;
abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.20;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
pragma solidity ^0.8.20;
library Address {
    error AddressInsufficientBalance(address account);
    error AddressEmptyCode(address target);
    error FailedInnerCall();
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResultFromTarget(target, success, returndata);
    }
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata
    ) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }
    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
pragma solidity ^0.8.20;
library SafeERC20 {
    using Address for address;
    error SafeERC20FailedOperation(address token);
    error SafeERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeCall(token.transferFrom, (from, to, value))
        );
    }
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 requestedDecrease
    ) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(
                    spender,
                    currentAllowance,
                    requestedDecrease
                );
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeCall(
            token.approve,
            (spender, value)
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeCall(token.approve, (spender, 0))
            );
            _callOptionalReturn(token, approvalCall);
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }
    function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            address(token).code.length > 0;
    }
}
pragma solidity ^0.8.20;
contract Presale is Ownable {
    using SafeERC20 for IERC20;
    uint256 public rate;
    uint public saleTokenDec;
    uint256 public totalTokensforSale;
    mapping(address => bool) public payableTokens;
    mapping(address => uint256) public tokenPrices;
    bool public saleStatus;
    address[] public buyers;
    mapping(address => bool) public buyersExists;
    mapping(address => uint256) public buyersAmount;
    uint256 public totalBuyers;
    uint256 public totalTokensSold;
    address public teamWallet;
    struct BuyerDetails {
        address buyer;
        uint amount;
    }
    event BuyToken(
        address indexed buyer,
        address indexed token,
        uint256 paidAmount,
        uint256 purchasedAmount
    );
    constructor(address _teamWallet) Ownable(msg.sender) {
        saleStatus = false;
        teamWallet = _teamWallet;
    }
    modifier saleEnabled() {
        require(saleStatus == true, "Presale: is not enabled");
        _;
    }
    modifier saleStoped() {
        require(saleStatus == false, "Presale: is not stopped");
        _;
    }
    function setSaleToken(
        uint256 _decimals,
        uint256 _totalTokensforSale,
        uint256 _rate,
        bool _saleStatus
    ) external onlyOwner {
        require(_rate != 0);
        rate = _rate;
        saleStatus = _saleStatus;
        saleTokenDec = _decimals;
        totalTokensforSale = _totalTokensforSale;
    }
    function stopSale() external onlyOwner saleEnabled {
        saleStatus = false;
    }
    function resumeSale() external onlyOwner saleStoped {
        saleStatus = true;
    }
    function addPayableTokens(
        address[] memory _tokens,
        uint256[] memory _prices
    ) external onlyOwner {
        require(
            _tokens.length == _prices.length,
            "Presale: tokens & prices arrays length mismatch"
        );

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_prices[i] != 0);
            payableTokens[_tokens[i]] = true;
            tokenPrices[_tokens[i]] = _prices[i];
        }
    }
    function payableTokenStatus(
        address _token,
        bool _status
    ) external onlyOwner {
        require(payableTokens[_token] != _status);

        payableTokens[_token] = _status;
    }
    function updateTokenRate(
        address[] memory _tokens,
        uint256[] memory _prices,
        uint256 _rate
    ) external onlyOwner {
        require(
            _tokens.length == _prices.length,
            "Presale: tokens & prices arrays length mismatch"
        );
        if (_rate != 0) {
            rate = _rate;
        }
        for (uint256 i = 0; i < _tokens.length; i += 1) {
            require(payableTokens[_tokens[i]] == true);
            require(_prices[i] != 0);
            tokenPrices[_tokens[i]] = _prices[i];
        }
    }
    function getTokenAmount(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        uint256 amtOut;
        if (token != address(0)) {
            require(payableTokens[token] == true, "Presale: Token not allowed");
            uint256 price = tokenPrices[token];
            amtOut = (amount * (10 ** saleTokenDec)) / (price);
        } else {
            amtOut = (amount * (10 ** saleTokenDec)) / (rate);
        }
        return amtOut;
    }
    function transferETH() internal {
        uint256 teamAmt = (msg.value * 30) / 100;
        payable(teamWallet).transfer(teamAmt);
        payable(owner()).transfer(msg.value - teamAmt);
    }
    function transferToken(address _token, uint256 _amount) internal {
        uint256 teamAmt = (_amount * (30)) / (100);
        IERC20(_token).safeTransferFrom(msg.sender, teamWallet, teamAmt);
        IERC20(_token).safeTransferFrom(msg.sender, owner(), _amount - teamAmt);
    }
    function buyToken(
        address _token,
        uint256 _amount
    ) external payable saleEnabled {
        uint256 amount = _token != address(0) ? _amount : msg.value;
        uint256 saleTokenAmt = getTokenAmount(_token, amount);

        require(saleTokenAmt != 0, "Presale: Amount is 0");
        require(
            (totalTokensSold + saleTokenAmt) < totalTokensforSale,
            "Presale: Not enough tokens to be sold"
        );

        if (_token != address(0)) {
            transferToken(_token, _amount);
        } else {
            transferETH();
        }
        totalTokensSold += saleTokenAmt;

        if (!buyersExists[msg.sender]) {
            buyers.push(msg.sender);
            buyersExists[msg.sender] = true;
            totalBuyers += 1;
        }
        buyersAmount[msg.sender] += saleTokenAmt;
        emit BuyToken(msg.sender, _token, amount, saleTokenAmt);
    }
    function buyersDetailsList(
        uint _from,
        uint _to
    ) external view returns (BuyerDetails[] memory) {
        require(_from < _to, "Presale: _from should be less than _to");
        uint to = _to > totalBuyers ? totalBuyers : _to;
        uint from = _from > totalBuyers ? totalBuyers : _from;
        BuyerDetails[] memory buyersAmt = new BuyerDetails[](to - from);
        for (uint i = from; i < to; i += 1) {
            buyersAmt[i] = BuyerDetails(buyers[i], buyersAmount[buyers[i]]);
        }
        return buyersAmt;
    }
}