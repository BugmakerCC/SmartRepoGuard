// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract SlopyWithdrawalContract {
    address public owner;
    address public slopyToken;
    address public publicKey;
    mapping(uint256 => bool) public processedRequests;

    struct PayoutRequest {
        uint256 amount; // Сумма для перевода в Slopy
        uint256 fee; // Комиссия в ETH
        address recipient; // Адрес получателя средств
        uint256 uniqId; // Уникальный ID запроса
        uint64 expires; // Дата истечения срока действия, Unix time
        bytes sign; // Подпись запроса
    }

    // Событие успешного вывода средств
    event WithdrawalSuccess(uint256 indexed uniqId, address indexed recipient);

    // Событие смены публичного ключа
    event PublicKeyUpdated(address indexed oldPublicKey, address indexed newPublicKey);


    constructor(address _slopyToken, address _publicKey) {
        owner = msg.sender;
        slopyToken = _slopyToken;
        publicKey = _publicKey;
    }

        // Модификатор для функций, доступных только владельцу
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Функция для вывода средств
    function withdraw(PayoutRequest memory payoutRequest) public payable {
        // 1. Проверяем, что запрос с таким uniqId не был обработан ранее
        require(
            !processedRequests[payoutRequest.uniqId],
            "Request already processed"
        );

        // 2. Проверям, что срок действия запроса не истек
        require(block.timestamp < payoutRequest.expires, "Expired");

        // 3. Проверяем, что отправитель запроса совпадает с указанным адресом получателя
        require(
            msg.sender == payoutRequest.recipient,
            "Recipient address does not match sender"
        );

        // 4. Проверяем подпись
        require(verifySignature(payoutRequest), "Invalid signature");

        // 5. Проверяем, что отправлено достаточно ETH для комиссии
        require(msg.value >= payoutRequest.fee, "Insufficient fee");

        // 6. Отправляем комиссию владельцу контракта
        payable(owner).transfer(payoutRequest.fee);

        // 7. Переводим Slopy на счет пользователя
        IERC20(slopyToken).transfer(msg.sender, payoutRequest.amount);

        // 8. Помечаем запрос как обработанный
        processedRequests[payoutRequest.uniqId] = true;

        // 9. Генерируем событие успешного вывода средств
        emit WithdrawalSuccess(payoutRequest.uniqId, msg.sender);
    }

    // Функция для перевода всех средств SLOPY на счёт владельца контракта
    function returnFunds() public onlyOwner {
        // Получаем баланс Slopy на контракте
        uint256 contractBalance = IERC20(slopyToken).balanceOf(address(this));

        // Проверяем, что баланс больше 0
        require(contractBalance > 0, "No SLOPY available for withdrawal");

        // Переводим все Slopy владельцу контракта
        IERC20(slopyToken).transfer(owner, contractBalance);
    }

    // Функция для смены публичного ключа
    function updatePublicKey(address newPublicKey) public onlyOwner {
        require(newPublicKey != address(0), "New public key cannot be the zero address");
        address oldPublicKey = publicKey;
        publicKey = newPublicKey;
        emit PublicKeyUpdated(oldPublicKey, newPublicKey);
    }

    // Функция для проверки подписи
    function verifySignature(
        PayoutRequest memory payoutRequest
    ) internal view returns (bool) {
        // Хэшируем данные запроса
        bytes32 messageHash = getMessageHash(payoutRequest);

        // Получаем адрес, который подписал сообщение
        address recoveredAddress = recoverSigner(
            messageHash,
            payoutRequest.sign
        );

        // Проверяем, соответствует ли восстановленный адрес публичному ключу
        return recoveredAddress == publicKey;
    }

    // Получение хэша сообщения
    function getMessageHash(
        PayoutRequest memory payoutRequest
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    payoutRequest.amount,
                    payoutRequest.fee,
                    payoutRequest.recipient,
                    payoutRequest.uniqId,
                    payoutRequest.expires
                )
            );
    }

    // Восстановление адреса подписанта
    function recoverSigner(
        bytes32 messageHash,
        bytes memory signature
    ) internal pure returns (address) {
        // Добавляем префикс "\x19Ethereum Signed Message:" к хэшу для стандарта EIP-191
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        // Восстанавливаем адрес из подписи
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    // Вспомогательная функция для разделения подписи
    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Функция для получения баланса Slopy контракта
    function getContractSlopyBalance() public view returns (uint256) {
        return IERC20(slopyToken).balanceOf(address(this));
    }
}