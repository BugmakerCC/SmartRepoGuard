// SPDX-License-Identifier: MIT

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

abstract contract Ownable is Context {
    address private _owner;

    
    error OwnableUnauthorizedAccount(address account);

    
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
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

 
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

  
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);

 
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


interface IERC20Permit {
      function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

     function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


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

 
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

 
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

  
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
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


    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }


    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}


library SafeERC20 {
    using Address for address;

 
    error SafeERC20FailedOperation(address token);


    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);


    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

 
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

 
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

 
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }


    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }


    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }


    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}


interface IERC20Metadata is IERC20 {
 
    function name() external view returns (string memory);

 
    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/INSOPreSale.sol


pragma solidity ^0.8.20;

contract FashionBlockPresale is Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;
    IERC20 public token;
    IERC20Metadata public tokenMetadata;
    IERC20 public usdtToken;
    IERC20Metadata public usdtTokenMetadata;
    AggregatorV3Interface priceFeed;
    address public paymentAddress;
    uint currentStage;
    bool public presaleActive = true;
    mapping(uint => uint256) public stagePrice; 
    mapping(uint => uint256) public stageEndTime;
    uint256 public vestingDelayTime;
    string nativeSymbol;

    struct Buyer {
        uint256 token;
        uint256 endTime;
        uint256 paid;
        uint256 price;
        uint256 time;
        string symbol;
    }
    mapping(address => Buyer) public buyers;
    address[] public buyerAddresses;
    // constructor
    constructor(
        address _oracle,
        address _payment,
        address _token,
        string memory _symbol,
        address _usdtToken
    ) Ownable(msg.sender) {
        paymentAddress = _payment;
        token = IERC20(_token);
        tokenMetadata = IERC20Metadata(_token);
        usdtToken = IERC20(_usdtToken);
        usdtTokenMetadata = IERC20Metadata(_usdtToken);
        priceFeed = AggregatorV3Interface(_oracle);
        stagePrice[1] = 5 * (10**16);
        stagePrice[2] = 10 * (10**16);
        stagePrice[3] = 15 * (10**16);
        stageEndTime[1] = 1748615106000;
        stageEndTime[2] = 1748615106000;
        stageEndTime[3] = 1748615106000;
        vestingDelayTime = 180 * 24 * 60 * 60 * 1000;
        currentStage = 1;
        nativeSymbol = _symbol;
    }
    function getNativeTokenUsdPrice() public view returns(uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price*(10**10));
    }
    function getTokenAmount(uint256 _ethAmount) public view returns (uint256) {
        uint256 ethPriceInUSD = getNativeTokenUsdPrice();  // Fetch the current ETH/USD price
        uint256 tokensPerETH = (ethPriceInUSD) / stagePrice[currentStage];  // Calculate tokens per 1 ETH
        
        return (_ethAmount * tokensPerETH);  // Return token amount based on ETH input
    }
    function getTokenAmountForUsdt(uint256 _usdtAmount) public view returns(uint256) {
        uint256 _tokenAmount = (_usdtAmount / (stagePrice[currentStage]/(10**12))) * (10**18);
        return _tokenAmount;
    }
    function buyToken(
        address _buyerAddress    
    ) public payable {
        //payment price transfer to payement address
        require(block.timestamp < stageEndTime[currentStage], "current presale is ended");
         require(
            payable(paymentAddress).send(msg.value),
            "Failed to transfer payment!"
        );
        uint256 _tokenAmount = getTokenAmount(msg.value);
        Buyer storage buyerInfo = buyers[_buyerAddress];

        if (buyerInfo.token > 0) {
            _tokenAmount += buyerInfo.token;
        } else {
            buyerAddresses.push(_buyerAddress);
        }
        buyers[_buyerAddress] = Buyer(
            _tokenAmount, 
            ((block.timestamp*1000)+vestingDelayTime), 
            msg.value, 
            stagePrice[currentStage], 
            block.timestamp, 
            nativeSymbol
        );
    }
    // buyTokenWithUsdt funtion to buy tokens using USDT
    function buyTokenWithUsdt(
        address _buyerAddress,
        uint256 _usdtAmount
    ) public {
        require(block.timestamp < stageEndTime[currentStage], "current presale is ended");
        uint256 _tokenAmount = getTokenAmountForUsdt(_usdtAmount);
        require(
            usdtToken.allowance(msg.sender, address(this)) >= _usdtAmount,
            "Not enough USDT allowance!"
        );
        usdtToken.safeTransferFrom(_buyerAddress, address(this), _usdtAmount);
        Buyer storage buyerInfo = buyers[_buyerAddress];

        if (buyerInfo.token > 0) {
            _tokenAmount += buyerInfo.token;
        } else {
            buyerAddresses.push(_buyerAddress);
        }
        buyers[_buyerAddress] = Buyer(
            _tokenAmount, 
            ((block.timestamp*1000)+vestingDelayTime), 
            _usdtAmount, 
            stagePrice[currentStage], 
            block.timestamp, 
            "USDT"
        );
    }
    //claimToken funtion to claim tokens
    function claimToken() public {
       
     Buyer storage buyerInfo = buyers[msg.sender];
        require(
            buyerInfo.endTime < block.timestamp,
            "You can't calim before vesting end time!"
        );
        require(buyerInfo.token > 0, "You don't have tokens!");

        // Transfer tokens back to buyer
        token.safeTransfer(msg.sender, buyerInfo.token);

        //delete buyers info
        removeBuyer(msg.sender);
    }

    // findBuyerIndex to get index of single buyer address
    function findBuyerIndex(address _buyerAddress)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < buyerAddresses.length; i++) {
            if (buyerAddresses[i] == _buyerAddress) {
                return i;
            }
        }
        revert("Buyer address not found");
    }

    // removeBuyer to remove buyer info
    function removeBuyer(address _buyerAddress) public {
        require(buyers[_buyerAddress].token > 0, "Buyer does not exist");
        uint256 index = findBuyerIndex(_buyerAddress);

        // Remove the buyer from the mapping
        delete buyers[_buyerAddress];

        // Remove the address from the buyerAddresses array
        buyerAddresses[index] = buyerAddresses[buyerAddresses.length - 1];
        buyerAddresses.pop();
    }
    // getAllBuyers to show all buyers
    function getAllBuyers()
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256 length = buyerAddresses.length;
        address[] memory addresses = new address[](length);
        uint256[] memory tokens = new uint256[](length);
        uint256[] memory endTimes = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            address buyerAddress = buyerAddresses[i];
            Buyer storage buyer = buyers[buyerAddress];
            addresses[i] = buyerAddress;
            tokens[i] = buyer.token;
            endTimes[i] = buyer.endTime;
        }

        return (addresses, tokens, endTimes);
    }
    // getTotalTokenAmount to get total amount of all buyers
    function getTotalTokenAmount() public view returns (uint256) {
        uint256 totalTokenAmount = 0;
        for (uint256 i = 0; i < buyerAddresses.length; i++) {
            totalTokenAmount += buyers[buyerAddresses[i]].token;
        }
        return totalTokenAmount;
    }
    // update token address
    function setToken(address _token) public onlyOwner {
        require(_token != address(0), "Token is zero address!");
        token = IERC20(_token);
        tokenMetadata = IERC20Metadata(_token);
    }
    // update usdt token address
    function setUsdtToken(address _usdtToken) public onlyOwner {
        require(_usdtToken != address(0), "Token is zero address!");
        usdtToken = IERC20(_usdtToken);
        usdtTokenMetadata = IERC20Metadata(_usdtToken);
    }
    // update paementAddress
    function setPaymentAddress(address _paymentAddress) public onlyOwner {
        paymentAddress = _paymentAddress;
    }
    // flip presaleActive as true/false
    function flipPresaleActive() public onlyOwner {
        presaleActive = !presaleActive;
    }
    // withdrawFunds functions to get remaining funds transfer
    function withdrawFunds() public onlyOwner {
        require(
            payable(msg.sender).send(address(this).balance),
            "Failed withdraw!"
        );
        require(usdtToken.balanceOf(address(this)) > 0, "Insufficient Balance");
        usdtToken.safeTransfer(paymentAddress, usdtToken.balanceOf(address(this)));
    }
    // withdrawTokens functions to get remaining tokens transfer
    function withdrawTokens(address _to, uint256 _amount) public onlyOwner {
        uint256 _tokenBalance = token.balanceOf(address(this));
        require(_tokenBalance >= _amount, "Exceeds token balance!");
        token.safeTransfer(_to, _amount);
    }
    // withdrawUsdt functions to get remaining USDT
    function withdrawUsdt(address _to, uint256 _amount) public onlyOwner {
        uint256 _usdtTokenBalance = usdtToken.balanceOf(address(this));
        require(_usdtTokenBalance >= _amount, "Exceeds token balance!");
        usdtToken.safeTransfer(_to, _amount);
    }
    function getStageEndTime(uint _stage) public view returns(uint256) {
        return stageEndTime[_stage];
    }
    function setStageEndTime(uint _stage, uint256 _time) public onlyOwner {
        require(_time > 0, "invalid value!!!");
        require(_stage <= 3, "exceed range");
        require(_stage >= 1, "exceed range");
        stageEndTime[_stage] = _time;
    }
    function getStagePrice(uint _stage) public view returns (uint256) {
        return stagePrice[_stage];
    }
    function setStagePrice(uint _stage, uint256 _price) public onlyOwner {
        require(_price > 0, "invalid value!!!");
        require(_stage <= 3, "exceed range");
        require(_stage >= 1, "exceed range");
        stagePrice[_stage] = _price;
    }
    function setVestingTime(uint256 _time) public onlyOwner {
        vestingDelayTime = _time;
    }
    function getVestingTime() public view returns(uint256) {
        return vestingDelayTime;
    }
    function setCurrentStage(uint _stage) public onlyOwner {
        currentStage = _stage;
    }
    function getCurrentStage() public view returns(uint) {
        return currentStage;
    }

}