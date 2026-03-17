// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SmartAccount.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

/**
 * @title AccountFactory
 * @dev Deploys SmartAccounts using CREATE2 for deterministic addresses.
 */
contract AccountFactory {
    IEntryPoint public immutable entryPoint;

    constructor(IEntryPoint _entryPoint) {
        entryPoint = _entryPoint;
    }

    function createAccount(address owner, uint256 salt) external returns (SmartAccount) {
        address addr = Create2.computeAddress(
            bytes32(salt),
            keccak256(abi.encodePacked(type(SmartAccount).creationCode, abi.encode(entryPoint, owner)))
        );

        if (addr.code.length > 0) {
            return SmartAccount(payable(addr));
        }

        return new SmartAccount{salt: bytes32(salt)}(entryPoint, owner);
    }
}
