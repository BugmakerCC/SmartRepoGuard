#pragma version 0.4.0
#pragma optimize gas
#pragma evm-version cancun
"""
@title AAVE Stable Yield Chaser Vault
@license Apache 2.0
@author Volume.finance
"""

struct SwapInfo:
    route: address[11]
    swap_params: uint256[5][5]
    amount: uint256
    expected: uint256
    pools: address[5]

struct ReserveConfigurationMap:
    data: uint256

struct ReserveData:
    configuration: ReserveConfigurationMap
    liquidityIndex: uint128
    currentLiquidityRate: uint128
    variableBorrowIndex: uint128
    currentVariableBorrowRate: uint128
    currentStableBorrowRate: uint128
    lastUpdateTimestamp: uint40
    id: uint16
    aTokenAddress: address
    stableDebtTokenAddress: address
    variableDebtTokenAddress: address
    interestRateStrategyAddress: address
    accruedToTreasury: uint128
    unbacked: uint128
    isolationModeTotalDebt: uint128

interface ERC20:
    def balanceOf(_owner: address) -> uint256: view
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

interface WrappedEth:
    def deposit(): payable
    def withdraw(amount: uint256): nonpayable

interface CurveSwapRouter:
    def exchange(
        _route: address[11],
        _swap_params: uint256[5][5],
        _amount: uint256,
        _expected: uint256,
        _pools: address[5]=empty(address[5]),
        _receiver: address=msg.sender
    ) -> uint256: payable

interface AAVEPoolV3:
    def getReserveData(asset: address) -> ReserveData: view
    def supply(asset: address, amount: uint256, onBehalfOf: address, referralCode: uint16): nonpayable
    def withdraw(asset: address, amount: uint256, to: address) -> uint256: nonpayable

VETH: constant(address) = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
DENOMINATOR: constant(uint256) = 10 ** 18
WETH: public(immutable(address))
Router: public(immutable(address))
Pool: public(immutable(address))

event Deposited:
    depositor: address
    token0: address
    asset: address
    amount0: uint256
    balance: uint256

event UpdateAsset:
    old_asset: address
    new_asset: address
    amount0: uint256
    amount1: uint256

event Withdrawn:
    user: address
    token0: address
    asset: address
    amount0: uint256
    amount1: uint256
    balance: uint256

event UpdateCompass:
    old_compass: address
    new_compass: address

event UpdateRefundWallet:
    old_refund_wallet: address
    new_refund_wallet: address

event SetPaloma:
    paloma: bytes32

event UpdateEntranceFee:
    old_entrance_fee: uint256
    new_entrance_fee: uint256

event UpdateServiceFeeCollector:
    old_service_fee_collector: address
    new_service_fee_collector: address

event UpdateServiceFee:
    old_service_fee: uint256
    new_service_fee: uint256

compass: public(address)
asset: public(address)
a_asset: public(address)
totalSupply: public(uint256)
balanceOf: public(HashMap[address, uint256])
input_token: public(HashMap[address, address])
refund_wallet: public(address)
entrance_fee: public(uint256)
service_fee_collector: public(address)
service_fee: public(uint256)
paloma: public(bytes32)

@deploy
def __init__(_compass: address, _weth: address, _asset: address, _router: address, _pool: address,  _refund_wallet: address, _entrance_fee: uint256, _service_fee_collector: address, _service_fee: uint256):
    self.compass = _compass
    self.asset = _asset
    self.refund_wallet = _refund_wallet
    self.entrance_fee = _entrance_fee
    self.service_fee_collector = _service_fee_collector
    assert _service_fee < DENOMINATOR, "Invalid service fee"
    self.service_fee = _service_fee
    Router = _router
    WETH = _weth
    Pool = _pool
    self.a_asset = (staticcall AAVEPoolV3(_pool).getReserveData(_asset)).aTokenAddress
    log UpdateAsset(empty(address), _asset, 0, 0)
    log UpdateCompass(empty(address), _compass)
    log UpdateRefundWallet(empty(address), _refund_wallet)
    log UpdateEntranceFee(0, _entrance_fee)
    log UpdateServiceFeeCollector(empty(address), _service_fee_collector)
    log UpdateServiceFee(0, _service_fee)

@internal
def _safe_approve(_token: address, _to: address, _value: uint256):
    assert extcall ERC20(_token).approve(_to, _value, default_return_value=True), "Failed approve"

@internal
def _safe_transfer(_token: address, _to: address, _value: uint256):
    assert extcall ERC20(_token).transfer(_to, _value, default_return_value=True), "Failed transfer"

@internal
def _safe_transfer_from(_token: address, _from: address, _to: address, _value: uint256):
    assert extcall ERC20(_token).transferFrom(_from, _to, _value, default_return_value=True), "Failed transferFrom"

@external
@payable
@nonreentrant
def deposit(swap_info: SwapInfo):
    _value: uint256 = msg.value
    _entrance_fee: uint256 = self.entrance_fee
    if _entrance_fee > 0:
        _value -= _entrance_fee
        send(self.refund_wallet, _entrance_fee)
    _asset: address = self.asset
    _amount: uint256 = 0
    if swap_info.route[0] == _asset:
        _amount = staticcall ERC20(_asset).balanceOf(self)
        self._safe_transfer_from(_asset, msg.sender, self, swap_info.amount)
        _amount = staticcall ERC20(_asset).balanceOf(self) - _amount
    elif swap_info.route[0] == VETH and _asset == WETH:
        if _value > swap_info.amount:
            send(msg.sender, unsafe_sub(_value, swap_info.amount))
        else:
            assert _value == swap_info.amount, "Invalid amount"
        extcall WrappedEth(WETH).deposit(value=swap_info.amount)
        _amount = swap_info.amount
    else:
        if swap_info.route[0] == VETH:
            if _value > swap_info.amount:
                send(msg.sender, unsafe_sub(_value, swap_info.amount))
            else:
                assert _value == swap_info.amount, "Invalid amount"
            _amount = staticcall ERC20(_asset).balanceOf(self)
            extcall CurveSwapRouter(Router).exchange(swap_info.route, swap_info.swap_params, swap_info.amount, swap_info.expected, swap_info.pools, value=swap_info.amount)
            _amount = staticcall ERC20(_asset).balanceOf(self) - _amount
        else:
            input_amount: uint256 = staticcall ERC20(swap_info.route[0]).balanceOf(self)
            self._safe_transfer_from(swap_info.route[0], msg.sender, self, swap_info.amount)
            input_amount = staticcall ERC20(swap_info.route[0]).balanceOf(self) - input_amount
            self._safe_approve(swap_info.route[0], Router, input_amount)
            _amount = staticcall ERC20(_asset).balanceOf(self)
            extcall CurveSwapRouter(Router).exchange(swap_info.route, swap_info.swap_params, input_amount, swap_info.expected, swap_info.pools)
            _amount = staticcall ERC20(_asset).balanceOf(self) - _amount
    self._safe_approve(_asset, Pool, _amount)
    a_token: address = (staticcall AAVEPoolV3(Pool).getReserveData(_asset)).aTokenAddress
    before_a_balance: uint256 = staticcall ERC20(a_token).balanceOf(self)
    extcall AAVEPoolV3(Pool).supply(_asset, _amount, self, 0)
    increased_a_balance: uint256 = staticcall ERC20(a_token).balanceOf(self) - before_a_balance
    _total_supply: uint256 = self.totalSupply
    if _total_supply == 0 or before_a_balance == 0:
        self.totalSupply = increased_a_balance
        self.balanceOf[msg.sender] = increased_a_balance
    else:
        _increased_balance: uint256 = _total_supply * increased_a_balance // before_a_balance
        _total_supply += _increased_balance
        self.totalSupply = _total_supply
        self.balanceOf[msg.sender] += _increased_balance
    self.input_token[msg.sender] = swap_info.route[0]
    log Deposited(msg.sender, swap_info.route[0], _asset, swap_info.amount, _amount)

@internal
def _paloma_check():
    assert msg.sender == self.compass, "Not compass"
    assert self.paloma == convert(slice(msg.data, unsafe_sub(len(msg.data), 32), 32), bytes32), "Invalid paloma"

@external
def change_asset(_new_asset: address, swap_info: SwapInfo):
    self._paloma_check()
    old_asset: address = self.asset
    amount: uint256 = staticcall ERC20(old_asset).balanceOf(self)
    old_a_asset_balance: uint256 = staticcall ERC20(self.a_asset).balanceOf(self)
    _amount: uint256 = 0
    if old_a_asset_balance > 0:
        extcall AAVEPoolV3(Pool).withdraw(old_asset, old_a_asset_balance, self)
        amount = staticcall ERC20(old_asset).balanceOf(self) - amount
        self._safe_approve(old_asset, Router, amount)
        _amount = staticcall ERC20(_new_asset).balanceOf(self)
        extcall CurveSwapRouter(Router).exchange(swap_info.route, swap_info.swap_params, amount, swap_info.expected, swap_info.pools)
        _amount = staticcall ERC20(_new_asset).balanceOf(self) - _amount
        assert _amount > 0, "Invalid swap"
        _service_fee: uint256 = _amount * self.service_fee // DENOMINATOR
        if _service_fee > 0:
            self._safe_transfer(_new_asset, self.service_fee_collector, _service_fee)
            _amount -= _service_fee
        self._safe_approve(_new_asset, Pool, _amount)
        extcall AAVEPoolV3(Pool).supply(_new_asset, _amount, self, 0)
    self.asset = _new_asset
    self.a_asset = (staticcall AAVEPoolV3(Pool).getReserveData(_new_asset)).aTokenAddress
    log UpdateAsset(old_asset, _new_asset, amount, _amount)

@external
@nonreentrant
def withdraw(swap_info: SwapInfo, receiver: address = msg.sender, output_token: address = empty(address)):
    if msg.sender == self.compass:
        assert self.paloma == convert(slice(msg.data, unsafe_sub(len(msg.data), 32), 32), bytes32), "Invalid paloma"
    else:
        assert receiver == msg.sender, "Invalid receiver"
    _asset: address = self.asset
    a_balance: uint256 = staticcall ERC20(self.a_asset).balanceOf(self)
    _amount: uint256 = self.balanceOf[receiver]
    assert _amount > 0, "Invalid withdraw"
    _total_supply: uint256 = self.totalSupply
    a_balance = a_balance * _amount // _total_supply
    self.balanceOf[receiver] = 0
    self.totalSupply = _total_supply - _amount
    asset_balance: uint256 = staticcall ERC20(_asset).balanceOf(self)
    extcall AAVEPoolV3(Pool).withdraw(_asset, a_balance, self)
    asset_balance = staticcall ERC20(_asset).balanceOf(self) - asset_balance
    _output_token: address = output_token
    out_amount: uint256 = 0
    if _output_token == empty(address):
        _output_token = self.input_token[receiver]
    if _output_token == _asset:
        self._safe_transfer(_asset, receiver, asset_balance)
    elif _output_token == VETH and _asset == WETH:
        extcall WrappedEth(WETH).withdraw(asset_balance)
        send(receiver, asset_balance)
    else:
        self._safe_approve(_asset, Router, asset_balance)
        if _output_token == VETH:
            out_amount = self.balance
            extcall CurveSwapRouter(Router).exchange(swap_info.route, swap_info.swap_params, asset_balance, swap_info.expected, swap_info.pools)
            out_amount = self.balance - out_amount
            assert out_amount > 0, "Invalid swap"
            send(receiver, out_amount)
        else:
            out_amount = staticcall ERC20(_output_token).balanceOf(receiver)
            extcall CurveSwapRouter(Router).exchange(swap_info.route, swap_info.swap_params, asset_balance, swap_info.expected, swap_info.pools)
            out_amount = staticcall ERC20(_output_token).balanceOf(receiver) - out_amount
            assert out_amount > 0, "Invalid swap"
            self._safe_transfer(_output_token, receiver, out_amount)
    log Withdrawn(receiver, _output_token, _asset, out_amount, asset_balance, _amount)

@external
@view
def a_asset_balance() -> uint256:
    return staticcall ERC20(self.a_asset).balanceOf(self)

@external
def update_compass(new_compass: address):
    self._paloma_check()
    self.compass = new_compass
    log UpdateCompass(msg.sender, new_compass)

@external
def set_paloma():
    assert msg.sender == self.compass and self.paloma == empty(bytes32) and len(msg.data) == 36, "Invalid"
    _paloma: bytes32 = convert(slice(msg.data, 4, 32), bytes32)
    self.paloma = _paloma
    log SetPaloma(_paloma)

@external
def update_refund_wallet(new_refund_wallet: address):
    self._paloma_check()
    old_refund_wallet: address = self.refund_wallet
    self.refund_wallet = new_refund_wallet
    log UpdateRefundWallet(old_refund_wallet, new_refund_wallet)

@external
def update_entrance_fee(new_entrance_fee: uint256):
    self._paloma_check()
    old_entrance_fee: uint256 = self.entrance_fee
    self.entrance_fee = new_entrance_fee
    log UpdateEntranceFee(old_entrance_fee, new_entrance_fee)

@external
def update_service_fee_collector(new_service_fee_collector: address):
    self._paloma_check()
    old_service_fee_collector: address = self.service_fee_collector
    self.service_fee_collector = new_service_fee_collector
    log UpdateServiceFeeCollector(old_service_fee_collector, new_service_fee_collector)

@external
def update_service_fee(new_service_fee: uint256):
    self._paloma_check()
    assert new_service_fee < DENOMINATOR, "Invalid service fee"
    old_service_fee: uint256 = self.service_fee
    self.service_fee = new_service_fee
    log UpdateServiceFee(old_service_fee, new_service_fee)

@external
@payable
def __default__():
    pass