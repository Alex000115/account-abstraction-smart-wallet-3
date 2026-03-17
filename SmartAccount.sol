// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@account-abstraction/contracts/interfaces/IAccount.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

/**
 * @title SmartAccount
 * @dev A simple ERC-4337 compliant smart contract wallet.
 */
contract SmartAccount is IAccount {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address public owner;
    IEntryPoint public immutable entryPoint;

    modifier onlyEntryPoint() {
        require(msg.sender == address(entryPoint), "Only EntryPoint can call");
        _;
    }

    constructor(IEntryPoint _entryPoint, address _initialOwner) {
        entryPoint = _entryPoint;
        owner = _initialOwner;
    }

    /**
     * @dev Validates the signature of a UserOperation.
     */
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external override onlyEntryPoint returns (uint256 validationData) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        if (owner != hash.recover(userOp.signature)) {
            return 1; // SIG_VALIDATION_FAILED
        }

        if (missingAccountFunds > 0) {
            (bool success, ) = payable(msg.sender).call{value: missingAccountFunds}("");
            (success); // Explicitly ignore return value for gas optimization
        }
        
        return 0; // SUCCESS
    }

    /**
     * @dev Execute a transaction from the wallet.
     */
    function execute(address dest, uint256 value, bytes calldata func) external {
        require(msg.sender == address(entryPoint) || msg.sender == owner, "Unauthorized");
        (bool success, ) = dest.call{value: value}(func);
        require(success, "Execution failed");
    }

    receive() external payable {}
}
