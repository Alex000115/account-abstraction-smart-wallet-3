# Account Abstraction Smart Wallet

A professional-grade, flat-structured implementation of an ERC-4337 Smart Account. This repository provides the foundation for building "Smart Wallets" that replace traditional EOAs (Externally Owned Accounts).

## Features
* **ERC-4337 Compatible:** Works with entry points and bundlers for a seamless User Operation flow.
* **Social Recovery:** Allows a set of "guardians" to reset the wallet owner if the private key is lost.
* **Transaction Batching:** Execute multiple calls (e.g., approve + swap) in a single atomic transaction.
* **Signature Validation:** Customizable validation logic, supporting EIP-712 and potential multi-sig schemes.

## Core Components
1. **validateUserOp:** The entry point calls this to verify the signature and pay for gas from the wallet's deposit.
2. **execute:** Performs the actual transaction logic on behalf of the wallet.
3. **Recovery Module:** Logic to change the owner through a threshold of guardian signatures.

## Usage
Deploy the factory contract to generate deterministic wallet addresses for users based on their initial owner address and a salt.
