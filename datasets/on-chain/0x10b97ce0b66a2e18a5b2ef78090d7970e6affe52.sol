{{
  "language": "Vyper",
  "sources": {
    "contracts/bridgers/IBridger.vyi": {
      "content": "# pragma version ~=0.4.0\n\"\"\"\n@title Curve Bridge Adapter\n@license MIT\n@author CurveFi\n@notice Interface mainly used for bridging Curve emissions to L2s and collected fees to Ethereum.\n\"\"\"\n\nfrom ethereum.ercs import IERC20\n\n\n@external\n@payable\ndef bridge(_token: IERC20, _to: address, _amount: uint256, _min_amount: uint256=0) -> uint256:\n    \"\"\"\n    @notice Bridge `_token`\n    @param _token The ERC20 asset to bridge\n    @param _to The receiver on `_chain_id`\n    @param _amount The amount of `_token` to deposit, 2^256-1 for the whole balance\n    @param _min_amount Minimum amount when to bridge\n    @return Bridged amount\n    \"\"\"\n    ...\n\n\n@view\n@external\ndef check(_account: address) -> bool:\n    \"\"\"\n    @notice Check if `_account` may bridge via `transmit_emissions`\n    @param _account The account to check\n    \"\"\"\n    ...\n\n\n@view\n@external\ndef cost() -> uint256:\n    \"\"\"\n    @notice Cost in ETH to bridge, not all chains are supported\n    \"\"\"\n    ...\n",
      "sha256sum": "6f706ae0fccd481df984cada3477305aa5cc727b755c74568316fe7fe3af9898"
    },
    "contracts/bridgers/LzXdaoBridger.vy": {
      "content": "# @version 0.4.0\n\"\"\"\n@title LzXdaoBridger\n@custom:version 0.0.1\n@author Curve.Fi\n@license Copyright (c) Curve.Fi, 2020-2024 - all rights reserved\n@notice Curve Xdao Layer Zero bridge wrapper\n\"\"\"\n\nversion: public(constant(String[8])) = \"0.0.1\"\n\nfrom ethereum.ercs import IERC20\nimport IBridger\n\nimplements: IBridger\n\n\ninterface Bridge:\n    def bridge(_receiver: address, _amount: uint256, _refund: address): payable\n    def quote() -> uint256: view\n\n\nCRV20: constant(address) = 0xD533a949740bb3306d119CC777fa900bA034cd52\nBRIDGE: public(immutable(Bridge))\n\nDESTINATION_CHAIN_ID: public(immutable(uint256))\n\n\n@deploy\ndef __init__(_bridge: Bridge, _chain_id: uint256):\n    \"\"\"\n    @param _bridge Layer Zero Bridge of CRV\n    @param _chain_id Chain ID to bridge to (actual, not LZ)\n    \"\"\"\n    BRIDGE = _bridge\n    DESTINATION_CHAIN_ID = _chain_id\n\n    assert extcall IERC20(CRV20).approve(BRIDGE.address, max_value(uint256))\n\n\n@external\n@payable\ndef bridge(_token: IERC20, _to: address, _amount: uint256, _min_amount: uint256=0) -> uint256:\n    \"\"\"\n    @notice Bridge `_token` through XDAO Layer Zero\n    @param _token The ERC20 asset to bridge\n    @param _to The receiver on `_chain_id`\n    @param _amount The amount of `_token` to deposit, 2^256-1 for the whole balance\n    @param _min_amount Minimum amount when to bridge\n    @return Bridged amount\n    \"\"\"\n    amount: uint256 = _amount\n    if amount == max_value(uint256):\n        amount = min(staticcall _token.balanceOf(msg.sender), staticcall _token.allowance(msg.sender, self))\n    assert amount >= _min_amount, \"Amount too small\"\n\n    assert extcall _token.transferFrom(msg.sender, self, amount)\n\n    extcall BRIDGE.bridge(_to, amount, msg.sender, value=self.balance)\n    return amount\n\n\n@view\n@external\ndef cost() -> uint256:\n    \"\"\"\n    @notice Cost in ETH to bridge\n    \"\"\"\n    return staticcall BRIDGE.quote()\n\n\n@view\n@external\ndef check(_account: address) -> bool:\n    \"\"\"\n    @notice Check if `_account` is allowed to bridge\n    @param _account The account to check\n    \"\"\"\n    return True\n",
      "sha256sum": "3c2bfcb73cf1cf5699a67acc46ed627d1d9018b8c5a396e2a427d3b23e163d6d"
    }
  },
  "settings": {
    "outputSelection": {
      "contracts/bridgers/LzXdaoBridger.vy": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    },
    "search_paths": [
      "."
    ]
  },
  "compiler_version": "v0.4.0+commit.e9db8d9",
  "integrity": "9535510e47fe4a8b95961434d865806d07bf0a18fa79fef4716072419b0b1477"
}}