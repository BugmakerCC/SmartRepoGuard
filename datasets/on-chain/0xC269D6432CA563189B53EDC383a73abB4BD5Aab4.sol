{{
  "language": "Solidity",
  "sources": {
    "contracts/persistent/single-asset-redemption-queue/SingleAssetRedemptionQueueFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.8.19;\n\nimport {NonUpgradableProxy} from \"../../utils/0.8.19/NonUpgradableProxy.sol\";\nimport {ISingleAssetRedemptionQueue} from \"./ISingleAssetRedemptionQueue.sol\";\n\n/// @title SingleAssetRedemptionQueueFactory Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A factory for SingleAssetRedemptionQueue proxy instances\ncontract SingleAssetRedemptionQueueFactory {\n    event ProxyDeployed(address indexed deployer, address indexed proxyAddress, address indexed vaultProxy);\n\n    address internal immutable LIB_ADDRESS;\n\n    constructor(address _libAddress) {\n        LIB_ADDRESS = _libAddress;\n    }\n\n    function deployProxy(\n        address _vaultProxy,\n        address _redemptionAssetAddress,\n        uint256 _bypassableSharesThreshold,\n        address[] calldata _managers\n    ) external returns (address proxyAddress_) {\n        bytes memory constructData = abi.encodeWithSelector(\n            ISingleAssetRedemptionQueue.init.selector,\n            _vaultProxy,\n            _redemptionAssetAddress,\n            _bypassableSharesThreshold,\n            _managers\n        );\n\n        proxyAddress_ = address(new NonUpgradableProxy({_constructData: constructData, _contractLogic: LIB_ADDRESS}));\n\n        emit ProxyDeployed(msg.sender, proxyAddress_, _vaultProxy);\n\n        return proxyAddress_;\n    }\n}\n"
    },
    "contracts/utils/0.8.19/NonUpgradableProxy.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.8.19;\n\n/// @title NonUpgradableProxy Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A proxy contract for use with non-upgradable libs\n/// @dev The recommended constructor-fallback pattern of a proxy in EIP-1822, updated for solc 0.8.19,\n/// and using an immutable lib value to save on gas (since not upgradable).\n/// The EIP-1967 storage slot for the lib is still assigned,\n/// for ease of referring to UIs that understand the pattern, i.e., Etherscan.\ncontract NonUpgradableProxy {\n    address private immutable CONTRACT_LOGIC;\n\n    constructor(bytes memory _constructData, address _contractLogic) {\n        CONTRACT_LOGIC = _contractLogic;\n\n        assembly {\n            // EIP-1967 slot: `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`\n            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _contractLogic)\n        }\n        if (_constructData.length > 0) {\n            (bool success, bytes memory returnData) = _contractLogic.delegatecall(_constructData);\n            require(success, string(returnData));\n        }\n    }\n\n    // solhint-disable-next-line no-complex-fallback\n    fallback() external payable {\n        address contractLogic = CONTRACT_LOGIC;\n\n        assembly {\n            calldatacopy(0x0, 0x0, calldatasize())\n            let success := delegatecall(sub(gas(), 10000), contractLogic, 0x0, calldatasize(), 0, 0)\n            let retSz := returndatasize()\n            returndatacopy(0, 0, retSz)\n            switch success\n            case 0 { revert(0, retSz) }\n            default { return(0, retSz) }\n        }\n    }\n}\n"
    },
    "contracts/persistent/single-asset-redemption-queue/ISingleAssetRedemptionQueue.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport {IERC20} from \"../../external-interfaces/IERC20.sol\";\n\npragma solidity >=0.6.0 <0.9.0;\n\n/// @title ISingleAssetRedemptionQueue Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface ISingleAssetRedemptionQueue {\n    function init(\n        address _vaultProxy,\n        IERC20 _redemptionAsset,\n        uint256 _bypassableSharesAmount,\n        address[] calldata _managers\n    ) external;\n\n    function addManagers(address[] calldata _managers) external;\n\n    function getBypassableSharesThreshold() external view returns (uint256 sharesAmount_);\n\n    function getNextNewId() external view returns (uint256 id_);\n\n    function getNextQueuedId() external view returns (uint256 id_);\n\n    function getRedemptionAsset() external view returns (IERC20 asset_);\n\n    function getSharesForRequest(uint256 _id) external view returns (uint256 sharesAmount_);\n\n    function getUserForRequest(uint256 _id) external view returns (address user_);\n\n    function getVaultProxy() external view returns (address vaultProxy_);\n\n    function isManager(address _user) external view returns (bool isManager_);\n\n    function queueIsShutdown() external view returns (bool isShutdown_);\n\n    function redeemFromQueue(uint256 _endId, uint256[] calldata _idsToBypass) external;\n\n    function removeManagers(address[] calldata _managers) external;\n\n    function requestRedeem(uint256 _sharesAmount) external returns (uint256 id_);\n\n    function setBypassableSharesThreshold(uint256 _nextSharesThreshold) external;\n\n    function setRedemptionAsset(IERC20 _nextRedemptionAsset) external;\n\n    function shutdown() external;\n\n    function withdrawRequest(uint256 _id) external;\n}\n"
    },
    "contracts/external-interfaces/IERC20.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.6.0 <0.9.0;\n\n/// @title IERC20 Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IERC20 {\n    // IERC20 - strict\n\n    function allowance(address _owner, address _spender) external view returns (uint256 allowance_);\n\n    function approve(address _spender, uint256 _value) external returns (bool approve_);\n\n    function balanceOf(address _account) external view returns (uint256 balanceOf_);\n\n    function totalSupply() external view returns (uint256 totalSupply_);\n\n    function transfer(address _to, uint256 _value) external returns (bool transfer_);\n\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool transferFrom_);\n\n    // IERC20 - typical\n\n    function decimals() external view returns (uint8 decimals_);\n\n    function name() external view returns (string memory name_);\n\n    function symbol() external view returns (string memory symbol_);\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@openzeppelin/contracts/=lib/openzeppelin-solc-0.6/contracts/",
      "@uniswap/v3-core/=lib/uniswap-v3-core/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "forge-std/=lib/forge-std/src/",
      "openzeppelin-solc-0.6/=lib/openzeppelin-solc-0.6/contracts/",
      "openzeppelin-solc-0.7/=lib/openzeppelin-solc-0.7/contracts/",
      "openzeppelin-solc-0.8/=lib/openzeppelin-solc-0.8/contracts/",
      "uniswap-v3-core/=lib/uniswap-v3-core/",
      "uniswap-v3-core-0.8/=lib/uniswap-v3-core-0.8/",
      "uniswap-v3-periphery/=lib/uniswap-v3-periphery/contracts/",
      "uniswap-v3-periphery-0.8/=lib/uniswap-v3-periphery-0.8/contracts/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200,
      "details": {
        "yul": false
      }
    },
    "metadata": {
      "useLiteralContent": false,
      "bytecodeHash": "none",
      "appendCBOR": false
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    },
    "evmVersion": "paris",
    "viaIR": false,
    "libraries": {}
  }
}}