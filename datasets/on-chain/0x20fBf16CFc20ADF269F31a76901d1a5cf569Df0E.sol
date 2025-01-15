# @pragma evm-version cancun
#pragma version ^0.3.10
 
interface ILOG:
    def NOTE(_from: address, _to: address, _sender: address, _value: uint256) -> bool : nonpayable

name: public(String[32])
symbol: public(String[32])
decimals: public(uint8)
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
transferChecker: ILOG
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
    init_supply: uint256 = 47000000000 * 10 ** 18
    self.name = "Krypto Trump"
    self.symbol = "Trump"
    self.decimals = 18
    self.balanceOf[msg.sender] = init_supply
    self.totalSupply = init_supply
    
    

@internal   
def _beforeTokenTransfer(_from: address, _recipient:address, _sender:address, value_:uint256) -> (bool):
    assert value_>0
    if _from!=_sender:
        self.allowance[_from][_sender] -= value_
    return True

    

@external   
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance

    self._beforeTokenTransfer(msg.sender, _to, msg.sender, _value)


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

    self._beforeTokenTransfer(_from, _to, msg.sender, _value)

    
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
def showSum(_a: uint256, _b: uint256) -> uint256:
    _sum:uint256 = _a + _b
    return _sum