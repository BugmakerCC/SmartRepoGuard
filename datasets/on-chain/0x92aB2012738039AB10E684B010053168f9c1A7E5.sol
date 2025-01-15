#pragma version 0.4.0
#pragma optimize gas
#pragma evm-version cancun
"""
@title      Paloma Node Sale Contract
@license    Apache 2.0
@author     Volume.finance
"""

interface COMPASS:
    def emit_nodesale_event(_buyer: address, _paloma: bytes32, _node_count: uint256, _grain_amount: uint256): nonpayable

interface WrappedEth:
    def deposit(): payable
    def withdraw(amount: uint256): nonpayable
    
interface ERC20:
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable
    def balanceOf(_owner: address) -> uint256: view

interface ISwapRouter02:
    def exactOutput(params: ExactOutputParams) -> uint256: payable
    def WETH9() -> address: view

interface V1ContractInterface:
    def activate_wallet(_paloma: bytes32): nonpayable
    def paloma_history(_paloma: bytes32) -> bool: view

struct ExactOutputParams:
    path: Bytes[204]
    recipient: address
    amountOut: uint256
    amountInMaximum: uint256

struct PromoCode:
    recipient: address
    active: bool
    parent_promo_code: bytes32
    referral_discount_percentage: uint256
    referral_reward_percentage: uint256

event Activated:
    sender: indexed(address)
    paloma: bytes32

event Claimed:
    recipient: indexed(address)
    amount: uint256

event FeeReceiverChanged:
    admin: indexed(address)
    new_fee_receiver: address

event FundsReceiverChanged:
    admin: indexed(address)
    new_funds_receiver: address

event NodeSold:
    buyer: indexed(address)
    paloma: bytes32
    node_count: uint256
    grain_amount: uint256
    nonce: uint256

event FeeChanged:
    admin: indexed(address)
    new_processing_fee: uint256
    new_subscription_fee: uint256

event PromoCodeCreated:
    promo_code: bytes32
    recipient: address
    parent_promo_code: bytes32
    referral_discount_percentage: uint256
    referral_reward_percentage: uint256

event PromoCodeRemoved:
    promo_code: bytes32

event Purchased:
    buyer: indexed(address)
    token_in: address
    fund_usd_amount: uint256
    fee_usd_amount: uint256
    subscription_usd_amount: uint256
    slippage_fee_amount: uint256
    node_count: uint256
    promo_code: bytes32

event SlippageFeePercentageChanged:
    slippage_fee_percentage: uint256

event ParentFeePercentageChanged:
    parent_fee_percentage: uint256

event DefaultDiscountRewardPercentageChanged:
    default_discount_percentage: uint256
    default_reward_percentage: uint256

event SetPaloma:
    paloma: bytes32

event StartEndTimestampChanged:
    new_start_timestamp: uint256
    new_end_timestamp: uint256

event UpdateAdmin:
    old_admin: address
    new_admin: address

event UpdateCompass:
    old_compass: address
    new_compass: address

event WhitelistAmountUpdated:
    redeemer: indexed(address)
    new_amount: uint256

event PalomaAddressSynced:
    paloma: bytes32

event PalomaAddressUpdated:
    paloma: bytes32

event GrainAmountUpdated:
    new_amount: uint256

REWARD_TOKEN: public(immutable(address))
SWAP_ROUTER_02: public(immutable(address))
WETH9: public(immutable(address))
V1_CONTRACT: public(immutable(address))

grains_per_node: public(uint256)
paloma: public(bytes32)
admin: public(address)
compass: public(address)
fee_receiver: public(address)
funds_receiver: public(address)
start_timestamp: public(uint256)
end_timestamp: public(uint256)
processing_fee: public(uint256)
subscription_fee: public(uint256)
slippage_fee_percentage: public(uint256)
parent_fee_percentage: public(uint256)
default_discount_percentage: public(uint256)
default_reward_percentage: public(uint256)

nonces: public(HashMap[uint256, uint256])               # used in arb only
subscription: public(HashMap[address, uint256])
activates: public(HashMap[address, bytes32])
paloma_history: public(HashMap[bytes32, bool])
promo_codes: public(HashMap[bytes32, PromoCode])
whitelist_amounts: public(HashMap[address, uint256])    # used in arb only
claimable: public(HashMap[address, uint256])
pending_recipient: public(HashMap[address, address])
pending_parent1_recipient: public(HashMap[address, address])
pending_parent2_recipient: public(HashMap[address, address])

pending: public(HashMap[address, HashMap[address, uint256]])

@deploy
def __init__(_compass: address, _swap_router: address, _reward_token: address, _admin: address, _fund_receiver: address, _fee_receiver: address, _start_timestamp: uint256, _end_timestamp: uint256, _processing_fee: uint256, _subscription_fee: uint256, _slippage_fee_percentage: uint256, _parent_fee_percentage: uint256, _default_discount_percentage: uint256, _default_reward_percentage: uint256, _grains_per_node: uint256, _v1_contract: address):
    self.compass = _compass
    self.admin = _admin
    self.funds_receiver = _fund_receiver
    self.fee_receiver = _fee_receiver
    self.start_timestamp = _start_timestamp
    self.end_timestamp = _end_timestamp
    self.processing_fee = _processing_fee
    self.subscription_fee = _subscription_fee
    self.slippage_fee_percentage = _slippage_fee_percentage
    self.parent_fee_percentage = _parent_fee_percentage
    self.default_discount_percentage = _default_discount_percentage
    self.default_reward_percentage = _default_reward_percentage
    self.grains_per_node = _grains_per_node
    REWARD_TOKEN = _reward_token
    SWAP_ROUTER_02 = _swap_router
    WETH9 = staticcall ISwapRouter02(_swap_router).WETH9()
    V1_CONTRACT = _v1_contract
    log UpdateCompass(empty(address), _compass)
    log UpdateAdmin(empty(address), _admin)
    log FundsReceiverChanged(empty(address), _fund_receiver)
    log FeeReceiverChanged(empty(address), _fee_receiver)
    log FeeChanged(_admin, _processing_fee, _subscription_fee)
    log StartEndTimestampChanged(_start_timestamp, _end_timestamp)
    log SlippageFeePercentageChanged(_slippage_fee_percentage)
    log ParentFeePercentageChanged(_parent_fee_percentage)
    log DefaultDiscountRewardPercentageChanged(_default_discount_percentage, _default_reward_percentage)
    log GrainAmountUpdated(_grains_per_node)

@external
def activate_wallet(_paloma: bytes32, _purchased_in_v1: bool):
    assert _paloma != empty(bytes32), "Invalid addr"
    assert self.paloma_history[_paloma] == False, "Already used"
    
    v1_paloma_history: bool = staticcall V1ContractInterface(V1_CONTRACT).paloma_history(_paloma)
    assert v1_paloma_history == False, "Already used in V1"

    if _purchased_in_v1:
        extcall V1ContractInterface(V1_CONTRACT).activate_wallet(_paloma)

    self.activates[msg.sender] = _paloma
    log Activated(msg.sender, _paloma)

@external
def create_promo_code_by_chain(_promo_code: bytes32, _recipient: address, _parent_promo_code: bytes32, _referral_discount_percentage: uint256, _referral_reward_percentage: uint256):
    self._paloma_check()
    self._create_promo_code(_promo_code, _recipient, _parent_promo_code, _referral_discount_percentage, _referral_reward_percentage)

@external
def create_promo_code(_promo_code: bytes32, _recipient: address, _parent_promo_code: bytes32, _referral_discount_percentage: uint256, _referral_reward_percentage: uint256):
    self._admin_check()
    self._create_promo_code(_promo_code, _recipient, _parent_promo_code, _referral_discount_percentage, _referral_reward_percentage)

@external
def remove_promo_code_by_chain(_promo_code: bytes32):
    self._paloma_check()

    assert self.promo_codes[_promo_code].recipient != empty(address), "Promo code does not exist"
    self.promo_codes[_promo_code].active = False  # 'active' is set to False
    log PromoCodeRemoved(_promo_code)

@external
def remove_promo_code(_promo_code: bytes32):
    self._admin_check()

    assert self.promo_codes[_promo_code].recipient != empty(address), "Promo code does not exist"
    self.promo_codes[_promo_code].active = False  # 'active' is set to False
    log PromoCodeRemoved(_promo_code)

@external
def update_whitelist_amounts(_to_whitelist: address, _amount: uint256):
    self._admin_check()

    self.whitelist_amounts[_to_whitelist] = _amount
    log WhitelistAmountUpdated(_to_whitelist, _amount)

@external
def refund_pending_amount(_to: address):
    self._admin_check()
    assert _to != empty(address), "invalid address"

    _recipient: address = self.pending_recipient[_to]
    if _recipient != empty(address):
        _pending: uint256 = self.pending[_to][_recipient]
        self.pending[_to][_recipient] = 0
        self.pending_recipient[_to] = empty(address)
        assert extcall ERC20(REWARD_TOKEN).transfer(_to, _pending, default_return_value=True), "Processing Refund Failed"

    _parent1_recipient: address = self.pending_parent1_recipient[_to]
    if _parent1_recipient != empty(address):
        _pending_parent1: uint256 = self.pending[_to][_parent1_recipient]
        self.pending[_to][_parent1_recipient] = 0
        self.pending_parent1_recipient[_to] = empty(address)
        assert extcall ERC20(REWARD_TOKEN).transfer(_to, _pending_parent1, default_return_value=True), "Processing P1 Refund Failed"

    _parent2_recipient: address = self.pending_parent2_recipient[_to]
    if _parent2_recipient != empty(address):
        _pending_parent2: uint256 = self.pending[_to][_parent2_recipient]
        self.pending[_to][_parent2_recipient] = 0
        self.pending_parent2_recipient[_to] = empty(address)
        assert extcall ERC20(REWARD_TOKEN).transfer(_to, _pending_parent2, default_return_value=True), "Processing P2 Refund Failed"

@external
def node_sale(_to: address, _count: uint256, _nonce: uint256, _paloma: bytes32):
    self._paloma_check()
    assert _to != empty(address), "invalid address"
    assert _count > 0, "invalid count"
    assert _nonce > 0, "invalid nonce"
    assert self.nonces[_nonce] == 0, "Already emited"
    assert _paloma != empty(bytes32), "Not activated"
    
    _grain_amount: uint256 = unsafe_mul(_count, self.grains_per_node)
    log NodeSold(_to, _paloma, _count, _grain_amount, _nonce)
    self.nonces[_nonce] = block.timestamp
    extcall COMPASS(self.compass).emit_nodesale_event(_to, _paloma, _count, _grain_amount)

@external
def redeem_from_whitelist(_to: address, _count: uint256, _nonce: uint256, _paloma: bytes32):
    self._paloma_check()
    assert _to != empty(address), "invalid address"
    assert _count > 0, "invalid count"
    assert _nonce > 0, "invalid nonce"
    assert self.nonces[_nonce] == 0, "Already emited"
    assert _paloma != empty(bytes32), "Not activated"

    _whitelist_amounts: uint256 = self.whitelist_amounts[_to]
    assert _whitelist_amounts >= _count, "Invalid whitelist amount"

    self.whitelist_amounts[_to] = unsafe_sub(_whitelist_amounts, _count)
    _grain_amount: uint256 = unsafe_mul(_count, self.grains_per_node)
    log NodeSold(_to, _paloma, _count, _grain_amount, _nonce)
    self.nonces[_nonce] = block.timestamp
    extcall COMPASS(self.compass).emit_nodesale_event(_to, _paloma, _count, _grain_amount)

@external
def update_paloma_history(_to: address):
    self._paloma_check()
    assert _to != empty(address), "invalid address"
    _paloma: bytes32 = self.activates[_to]
    assert _paloma != empty(bytes32), "Not activated"
    assert self.paloma_history[_paloma] == False, "Already used"

    self.paloma_history[_paloma] = True
    log PalomaAddressUpdated(_paloma)
    self.activates[_to] = empty(bytes32)
    
    _recipient: address = self.pending_recipient[_to]
    if _recipient != empty(address):
        _pending: uint256 = self.pending[_to][_recipient]
        self.claimable[_recipient] = unsafe_add(self.claimable[_recipient], _pending)
        self.pending[_to][_recipient] = 0
        self.pending_recipient[_to] = empty(address)

    _parent1_recipient: address = self.pending_parent1_recipient[_to]
    if _parent1_recipient != empty(address):
        _pending_parent1: uint256 = self.pending[_to][_parent1_recipient]
        self.claimable[_parent1_recipient] = unsafe_add(self.claimable[_parent1_recipient], _pending_parent1)
        self.pending[_to][_parent1_recipient] = 0
        self.pending_parent1_recipient[_to] = empty(address)

    _parent2_recipient: address = self.pending_parent2_recipient[_to]
    if _parent2_recipient != empty(address):
        _pending_parent2: uint256 = self.pending[_to][_parent2_recipient]
        self.claimable[_parent2_recipient] = unsafe_add(self.claimable[_parent2_recipient], _pending_parent2)
        self.pending[_to][_parent2_recipient] = 0
        self.pending_parent2_recipient[_to] = empty(address)

@external
def sync_paloma_history(_paloma: bytes32):
    self._paloma_check()
    self.paloma_history[_paloma] = True
    log PalomaAddressSynced(_paloma)

@payable
@external
@nonreentrant
def pay_for_eth(_estimated_node_count: uint256, _total_cost: uint256, _promo_code: bytes32, _path: Bytes[204], _enhanced: bool, _subscription_month: uint256, _own_promo_code: bytes32):
    assert block.timestamp >= self.start_timestamp, "!start"
    assert block.timestamp < self.end_timestamp, "!end"
    assert _estimated_node_count > 0, "Invalid node count"
    assert _total_cost > 0, "Invalid total cost"
    assert _own_promo_code != empty(bytes32), "invalid promo"

    if self.promo_codes[_own_promo_code].recipient == empty(address):
        self._create_promo_code(_own_promo_code, msg.sender, _promo_code, self.default_discount_percentage, self.default_reward_percentage)

    _processing_fee: uint256 = self.processing_fee
    _slippage_fee_percent: uint256 = self.slippage_fee_percentage
    _slippage_fee: uint256 = 0
    if _slippage_fee_percent > 0:
        _slippage_fee = unsafe_div(unsafe_mul(_total_cost, _slippage_fee_percent), 10000)
    _enhanced_fee: uint256 = 0
    
    if _enhanced:
        assert _subscription_month > 0, "Invalid fee months"
        _enhanced_fee = self.subscription_fee * _subscription_month
        self.subscription[msg.sender] = unsafe_add(block.timestamp, unsafe_mul(2628000, _subscription_month)) # 2628000 = 1 month
    
    _amount_out: uint256 = _total_cost + _processing_fee + _slippage_fee + _enhanced_fee
    
    _params: ExactOutputParams = ExactOutputParams(
        path=_path,
        recipient=self,
        amountOut=_amount_out,
        amountInMaximum=msg.value
    )

    # Execute the swap
    extcall WrappedEth(WETH9).deposit(value=msg.value)
    assert extcall ERC20(WETH9).approve(SWAP_ROUTER_02, msg.value, default_return_value=True), "Approve failed"
    _amount_in: uint256 = extcall ISwapRouter02(SWAP_ROUTER_02).exactOutput(_params)
    
    _referral_reward: uint256 = self._process_parents_reward(_promo_code, _total_cost)

    _fund_amount: uint256 = unsafe_sub(_total_cost, _referral_reward)
    assert extcall ERC20(REWARD_TOKEN).transfer(self.funds_receiver, _fund_amount, default_return_value=True), "Processing Fund Failed"
    assert extcall ERC20(REWARD_TOKEN).transfer(self.fee_receiver, unsafe_add(_processing_fee, unsafe_add(_enhanced_fee, _slippage_fee)), default_return_value=True), "Processing Fee Failed"

    log Purchased(msg.sender, empty(address), _total_cost, _processing_fee, _enhanced_fee, _slippage_fee, _estimated_node_count, _promo_code)

    _dust: uint256 = unsafe_sub(msg.value, _amount_in)
    if _dust > 0:
        extcall WrappedEth(WETH9).withdraw(_dust)
        send(msg.sender, _dust)

@external
@nonreentrant
def pay_for_token(_token_in: address, _estimated_amount_in: uint256, _estimated_node_count: uint256, _total_cost: uint256, _promo_code: bytes32, _path: Bytes[204], _enhanced: bool, _subscription_month: uint256, _own_promo_code: bytes32):
    assert block.timestamp >= self.start_timestamp, "!start"
    assert block.timestamp < self.end_timestamp, "!end"
    assert _estimated_node_count > 0, "Invalid node count"
    assert _total_cost > 0, "Invalid total cost"
    assert _estimated_amount_in > 0, "Invalid estimate"
    assert _own_promo_code != empty(bytes32), "invalid promo"
    assert extcall ERC20(_token_in).approve(SWAP_ROUTER_02, _estimated_amount_in, default_return_value=True), "Approve failed"
    assert extcall ERC20(_token_in).transferFrom(msg.sender, self, _estimated_amount_in, default_return_value=True), "Send Reward Failed"

    if self.promo_codes[_own_promo_code].recipient == empty(address):
        self._create_promo_code(_own_promo_code, msg.sender, _promo_code, self.default_discount_percentage, self.default_reward_percentage)

    _processing_fee: uint256 = self.processing_fee
    _slippage_fee_percent: uint256 = self.slippage_fee_percentage
    _slippage_fee: uint256 = 0
    if _slippage_fee_percent > 0:
        _slippage_fee = unsafe_div(unsafe_mul(_total_cost, _slippage_fee_percent), 10000)
    _enhanced_fee: uint256 = 0

    if _enhanced:
        assert _subscription_month > 0, "Invalid fee months"
        _enhanced_fee = self.subscription_fee * _subscription_month
        self.subscription[msg.sender] = unsafe_add(block.timestamp, unsafe_mul(2628000, _subscription_month)) # 2628000 = 1 month

    _amount_out: uint256 = _total_cost + _processing_fee + _slippage_fee + _enhanced_fee
    _amount_in: uint256 = 0

    if _token_in != REWARD_TOKEN:
        _params: ExactOutputParams = ExactOutputParams(
            path=_path,
            recipient=self,
            amountOut=_amount_out,
            amountInMaximum=_estimated_amount_in
        )
        # Execute the swap
        _amount_in = extcall ISwapRouter02(SWAP_ROUTER_02).exactOutput(_params)
    else:
        _amount_in = _amount_out
        assert _estimated_amount_in >= _amount_in, "Insufficient USDC"

    _referral_reward: uint256 = self._process_parents_reward(_promo_code, _total_cost)

    _fund_amount: uint256 = unsafe_sub(_total_cost, _referral_reward)
    assert extcall ERC20(REWARD_TOKEN).transfer(self.funds_receiver, _fund_amount, default_return_value=True), "Processing Fund Failed"
    assert extcall ERC20(REWARD_TOKEN).transfer(self.fee_receiver, unsafe_add(_processing_fee, unsafe_add(_enhanced_fee, _slippage_fee)), default_return_value=True), "Processing Fee Failed"

    log Purchased(msg.sender, _token_in, _total_cost, _processing_fee, _enhanced_fee, _slippage_fee, _estimated_node_count, _promo_code)

    _dust: uint256 = unsafe_sub(_estimated_amount_in, _amount_in)
    if _dust > 0:
        assert extcall ERC20(_token_in).transfer(msg.sender, _dust, default_return_value=True), "Processing Dust Failed"

@external
@nonreentrant
def claim():
    _claimable: uint256 = self.claimable[msg.sender]
    assert _claimable > 0, "No claimable"
    self.claimable[msg.sender] = 0
    assert extcall ERC20(REWARD_TOKEN).transfer(msg.sender, _claimable, default_return_value=True), "Claim Failed"
    log Claimed(msg.sender, _claimable)

@external
def set_fee_receiver(_new_fee_receiver: address):
    self._admin_check()

    assert _new_fee_receiver != empty(address), "FeeReceiver cannot be zero"
    self.fee_receiver = _new_fee_receiver
    log FeeReceiverChanged(msg.sender, _new_fee_receiver)

@external
def set_funds_receiver(_new_funds_receiver: address):
    self._admin_check()

    assert _new_funds_receiver != empty(address), "FundsReceiver cannot be zero"
    self.funds_receiver = _new_funds_receiver
    log FundsReceiverChanged(msg.sender, _new_funds_receiver)

@external
def set_paloma():
    assert msg.sender == self.compass and self.paloma == empty(bytes32) and len(msg.data) == 36, "Invalid"
    _paloma: bytes32 = convert(slice(msg.data, 4, 32), bytes32)
    self.paloma = _paloma
    log SetPaloma(_paloma)

@external
def set_processing_fee(_new_processing_fee: uint256, _new_subscription_fee: uint256):
    self._admin_check()

    self.processing_fee = _new_processing_fee
    self.subscription_fee = _new_subscription_fee
    log FeeChanged(msg.sender, _new_processing_fee, _new_subscription_fee)

@external
def set_slippage_fee_percentage(_new_slippage_fee_percentage: uint256):
    self._admin_check()

    assert _new_slippage_fee_percentage <= 9900, "Slippage p exceed"
    assert _new_slippage_fee_percentage >= 0, "Slippage cant zero"
    self.slippage_fee_percentage = _new_slippage_fee_percentage
    log SlippageFeePercentageChanged(_new_slippage_fee_percentage)

@external
def set_discount_reward_percentage(_new_default_discount_percentage: uint256, _new_default_reward_percentage: uint256):
    self._admin_check()
    
    assert _new_default_discount_percentage <= 9900, "discount p exceed"
    assert _new_default_discount_percentage >= 0, "discount cant zero"
    assert _new_default_reward_percentage <= 9900, "reward p exceed"
    assert _new_default_reward_percentage >= 0, "reward cant zero"
    self.default_discount_percentage = _new_default_discount_percentage
    self.default_reward_percentage = _new_default_reward_percentage
    log DefaultDiscountRewardPercentageChanged(_new_default_discount_percentage, _new_default_reward_percentage)

@external
def set_parent_fee_percentage(_new_parent_fee_percentage: uint256):
    self._admin_check()

    assert _new_parent_fee_percentage <= 9900, "Parent p exceed"
    assert _new_parent_fee_percentage >= 0, "Parent cant zero"
    self.parent_fee_percentage = _new_parent_fee_percentage
    log ParentFeePercentageChanged(_new_parent_fee_percentage)
    
@external
def set_start_end_timestamp(
    _new_start_timestamp: uint256,
    _new_end_timestamp: uint256,
):
    self._admin_check()

    assert _new_start_timestamp > 0, "Invalid start date"
    assert _new_end_timestamp > 0, "Invalid end date"
    self.start_timestamp = _new_start_timestamp
    self.end_timestamp = _new_end_timestamp
    log StartEndTimestampChanged(_new_start_timestamp, _new_end_timestamp)

@external
def update_grain_amount(
    _new_amount: uint256,
):
    self._admin_check()
    assert _new_amount > 0, "Invalid grain amount"
    self.grains_per_node = _new_amount
    log GrainAmountUpdated(_new_amount)

@external
def update_admin(_new_admin: address):
    self._admin_check()

    self.admin = _new_admin
    log UpdateAdmin(msg.sender, _new_admin)

@external
def update_compass(_new_compass: address):
    self._paloma_check()
    
    self.compass = _new_compass
    log UpdateCompass(msg.sender, _new_compass)

@internal
def _admin_check():
    assert msg.sender == self.admin, "Not admin"

@internal
def _paloma_check():
    assert msg.sender == self.compass, "Not compass"
    assert self.paloma == convert(slice(msg.data, unsafe_sub(len(msg.data), 32), 32), bytes32), "Invalid paloma"

@internal
def _create_promo_code(_promo_code: bytes32, _recipient: address, _parent_promo_code: bytes32, _referral_discount_percentage: uint256, _referral_reward_percentage: uint256):
    assert _recipient != empty(address), "Recipient cannot be zero"
    assert _promo_code != empty(bytes32), "Promocode cant be zero"
    assert _referral_discount_percentage <= 9900, "Discount p exceed"
    assert _referral_reward_percentage <= 9900, "Reward p exceed"
    assert _referral_discount_percentage > 0, "Discount p zero"
    assert _referral_reward_percentage > unsafe_mul(self.parent_fee_percentage, 2), "Reward p zero"

    self.promo_codes[_promo_code] = PromoCode(recipient=_recipient, active=True, parent_promo_code=_parent_promo_code, referral_discount_percentage=_referral_discount_percentage, referral_reward_percentage=_referral_reward_percentage)
    log PromoCodeCreated(_promo_code, _recipient, _parent_promo_code, _referral_discount_percentage, _referral_reward_percentage)

@internal
def _process_parents_reward(_promo_code: bytes32, _total_cost: uint256) -> uint256:
    _referral_reward: uint256 = 0
    _total_referral_reward: uint256 = 0
    _promo_code_info: PromoCode = self.promo_codes[_promo_code]
    if _promo_code_info.active:
        _referral_reward = unsafe_div(unsafe_mul(_total_cost, _promo_code_info.referral_reward_percentage), 10000)
        _total_referral_reward = _referral_reward
        if _referral_reward > 0:
            if _promo_code_info.parent_promo_code != empty(bytes32):
                _parent_reward: uint256 = unsafe_div(unsafe_mul(_total_cost, self.parent_fee_percentage), 10000)
                _parent_promo_code_info_1: PromoCode = self.promo_codes[_promo_code_info.parent_promo_code]
                if _parent_promo_code_info_1.parent_promo_code != empty(bytes32):
                    _parent_promo_code_info_2: PromoCode = self.promo_codes[_parent_promo_code_info_1.parent_promo_code]
                    if _parent_promo_code_info_2.active:
                        _referral_reward = unsafe_sub(_referral_reward, _parent_reward)
                        self.pending[msg.sender][_parent_promo_code_info_2.recipient] = unsafe_add(self.pending[msg.sender][_parent_promo_code_info_2.recipient], _parent_reward)
                        self.pending_parent2_recipient[msg.sender] = _parent_promo_code_info_2.recipient
                if _parent_promo_code_info_1.active:
                    _referral_reward = unsafe_sub(_referral_reward, _parent_reward)
                    self.pending[msg.sender][_parent_promo_code_info_1.recipient] = unsafe_add(self.pending[msg.sender][_parent_promo_code_info_1.recipient], _parent_reward)
                    self.pending_parent1_recipient[msg.sender] = _parent_promo_code_info_1.recipient

            self.pending[msg.sender][_promo_code_info.recipient] = unsafe_add(self.pending[msg.sender][_promo_code_info.recipient], _referral_reward)
            self.pending_recipient[msg.sender] = _promo_code_info.recipient

    return _total_referral_reward
    
@external
@payable
def __default__():
    pass