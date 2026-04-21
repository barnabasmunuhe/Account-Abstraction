# ⚡ Account Abstraction (ERC-4337 + zkSync Era)

A modular Account Abstraction implementation exploring smart contract wallets, ERC-4337 execution flows, and cross-chain compatibility (Ethereum + zkSync Era).

The main focus is building a deep understanding of **how smart accounts interact with the EntryPoint through off-chain scripts (TypeScript/JavaScript)**.

---

## 🧠 Overview

This project implements the **Account Abstraction (ERC-4337)** architecture using:

- Smart Contract Accounts (Smart Wallets)
- EntryPoint contract (course-provided base)
- UserOperation lifecycle
- Ethereum + zkSync Era compatibility
- TypeScript/JavaScript interaction scripts

The goal is to go beyond deployment and understand the **full execution pipeline from off-chain construction to on-chain validation and execution**.

---

## 🏗️ Architecture

### ERC-4337 Execution Flow

1. User creates a **UserOperation**
2. UserOperation is signed by the Smart Wallet owner
3. Bundler submits the operation to the **EntryPoint**
4. EntryPoint validates:
   - Signature
   - Nonce
   - Gas limits
5. Execution is forwarded to the Smart Wallet
6. Optional Paymaster covers gas fees (gasless execution)

---

## 🔩 Core Components

### 🧩 Smart Wallets
- Custom smart contract accounts
- Replace EOAs with programmable wallets
- Execute transactions via EntryPoint
- Deployed for both Ethereum and zkSync Era

---

### ⚙️ EntryPoint (Course Base)
- Core ERC-4337 contract
- Handles validation + execution lifecycle
- Acts as the coordinator for all UserOperations

---

### 📜 Scripts (TypeScript / JavaScript)

This is the current core focus of the project.

Scripts handle:
- Building UserOperations
- Encoding calldata
- Signing operations
- Sending transactions to EntryPoint
- Simulating bundler behavior

Goal: master **off-chain interaction patterns for smart contract systems**

---

## 🚀 Current Focus Areas

### 🔹 1. Interaction Scripts (TypeScript/JavaScript)
- Build full UserOp lifecycle scripts
- Understand contract interaction deeply
- Improve bundler simulation logic

### 🔹 2. Paymaster Integration (Upcoming)
- Gas sponsorship mechanisms
- ERC-4337 Paymaster implementation
- Enable gasless transactions

### 🔹 3. Session Keys (Upcoming)
- Temporary delegated permissions
- Limited-scope transaction execution
- UX-focused wallet improvements

---

## 🌐 Multi-Chain Support

- Ethereum (ERC-4337 standard flow)
- zkSync Era (EVM-compatible AA environment)

Focus is on maintaining consistent account abstraction logic across different execution environments.

---

## 🧪 Tech Stack

- Solidity
- ERC-4337 (Account Abstraction standard)
- EntryPoint (course implementation)
- Foundry (testing & deployment)
- TypeScript / JavaScript (interaction scripts)
- ethers.js / viem
- zkSync Era tooling

---

## 📂 Project Structure

```bash
/contracts
  SmartWallet.sol
  Paymaster.sol (upcoming)

/scripts
  createUserOp.ts
  sendUserOp.ts
  deploy.ts

/test
  SmartWallet.t.sol

/lib
  EntryPoint (course-provided)
