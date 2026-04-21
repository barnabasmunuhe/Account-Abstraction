# ⚡ Account Abstraction (ERC-4337 + zkSync Era)

A hands-on implementation of **Account Abstraction (ERC-4337)** using smart contract wallets, EntryPoint mechanics, and off-chain scripting.

This project explores how **UserOperations are constructed, signed, and executed**, replacing traditional EOAs with programmable smart accounts.

---

## 🧠 Overview

This repository covers the full **Account Abstraction lifecycle**:

- Smart Contract Wallet deployment  
- ERC-4337 EntryPoint interaction  
- UserOperation construction & execution  
- Off-chain scripting using TypeScript  
- Cross-chain compatibility (Ethereum + zkSync Era)  

The focus is on the **execution flow and scripting layer**, which is critical in real-world AA systems.

---

## ⚙️ Core Concepts

### 🔹 Account Abstraction (ERC-4337)

- Removes dependency on EOAs  
- Introduces **UserOperation** instead of traditional transactions  
- Uses **EntryPoint contract** for execution  
- Enables gas abstraction and programmable accounts  

---

### 🔹 UserOperation Lifecycle

1. Construct UserOperation (off-chain)  
2. Sign with Smart Account owner  
3. Submit to EntryPoint  
4. EntryPoint validates:
   - Signature  
   - Nonce  
   - Gas limits  
5. Smart Wallet executes transaction  

---

## 🏗️ System Architecture

```mermaid
flowchart LR
    U[User]
    S[TypeScript Scripts]
    OP[UserOperation]
    EP[EntryPoint]
    SW[Smart Wallet]
    EX[Execution]

    U --> S
    S --> OP
    OP --> EP
    EP --> SW
    SW --> EX
````

---

## 🔍 Flow Explanation

* **Scripts (off-chain)** → build & sign UserOperations
* **EntryPoint** → validates and routes execution
* **Smart Wallet** → executes logic on-chain

---

## 🔩 Core Components

### 🧾 Smart Contract Wallets

* Replace EOAs with programmable accounts
* Execute transactions via EntryPoint
* Compatible with Ethereum & zkSync Era

---

### 🧠 EntryPoint (ERC-4337 Core)

* Handles:

  * Validation
  * Execution
* Central coordination layer for UserOperations

---

### 🧪 Interaction Scripts (TypeScript)

Main focus of the project.

Scripts handle:

* Constructing UserOperations
* Encoding calldata
* Signing operations
* Sending operations to EntryPoint
* Simulating bundler behavior

> ⚠️ Most complexity in Account Abstraction lives off-chain — this layer is critical.

---

## 🚧 Current Work (Active Development)

### 🔹 zkSync Era Deployment Challenge

Deploying `ZkMinimal.sol` using **TypeScript scripts** due to:

* Limitations with Foundry scripting on zkSync Era

---

### 🔹 In Progress

* Custom deployment scripts (TypeScript)
* Encryption script for private key handling
* Sending AA transaction flow (`sendUserOp`)
* zkSync-specific execution understanding

---

## ▶️ Script Usage

### Install Dependencies

```bash
yarn install
```

### Compile Contracts

```bash
forge build
```

### Deploy Contracts (Foundry)

```bash
forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Deploy via TypeScript (zkSync-compatible)

```bash
yarn deploy
# or
npx ts-node typescript-scripts/deploy.ts
```

### Create UserOperation

```bash
npx ts-node typescript-scripts/createUserOp.ts
```

### Send UserOperation

```bash
npx ts-node typescript-scripts/sendUserOp.ts
```

### Encrypt Private Key

```bash
npx ts-node typescript-scripts/EncryptKey.ts
```

---

## 🌐 Supported Networks

* Ethereum (ERC-4337)
* zkSync Era

---

## 🧪 Tech Stack

* Solidity
* ERC-4337
* Foundry
* TypeScript / JavaScript
* ethers.js / viem
* zkSync SDK

---

## 📂 Project Structure

```bash
/contracts
  ├── SmartWallet.sol
  ├── ZkMinimal.sol
  └── (future) Paymaster.sol

/script
  ├── Deploy.s.sol
  ├── Interactions.s.sol

/typescript-scripts
  ├── deploy.ts
  ├── createUserOp.ts
  ├── sendUserOp.ts
  ├── EncryptKey.ts

/test
  ├── SmartWallet.t.sol

/lib
  └── EntryPoint
```

---

## 📌 Key Learnings

* ERC-4337 architecture
* Full UserOperation lifecycle
* EntryPoint validation and execution
* Importance of off-chain infrastructure
* zkSync vs Ethereum differences
* Smart wallet design patterns

---

## 🧭 Roadmap

* [ ] Paymaster (gas sponsorship)
* [ ] Session Keys (delegated permissions)
* [ ] Bundler simulation improvements
* [ ] zkSync deployment pipeline
* [ ] Optional frontend

---

## 💡 Purpose

To build a solid engineering understanding of:

* Smart contract wallets
* Gas abstraction
* Modular account systems
* Off-chain + on-chain interaction

---

## 📎 Notes

This project is part of a deeper exploration into:

* Account Abstraction
* Smart Wallet Infrastructure
* zkSync ecosystem

Ongoing improvements will focus on scripting, deployment, and architecture.

```
That’s what makes it hit *professional level*.
```
