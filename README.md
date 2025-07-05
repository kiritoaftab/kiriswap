# 🔄 Kiriswap

**Kiriswap** is a decentralized exchange (DEX) implementation that replicates the **Uniswap V1 algorithm**, built from scratch using Solidity. This project serves as an foundational base for understanding how automated market makers (AMMs) work, focusing on liquidity pools, LP tokens, and token swapping without order books.

---

## 🚀 Features

- ✅ **ERC20 <> ETH Swaps**
- ✅ **Liquidity Provisioning**
- ✅ **Liquidity Removal with LP Tokens**
- ✅ **Token <> Token Swaps** via ETH as intermediate
- ✅ **Factory Contract** to manage Exchange deployment
- ✅ Built using **Foundry** for testing and development

---

## 📦 Contracts

### 1. `MockToken.sol`
A minimal ERC20 token used for testing swap functionality.

### 2. `Exchange.sol`
Core logic for:
- Adding/removing liquidity
- ETH-to-Token swaps
- Token-to-ETH swaps
- Token-to-Token swaps (via intermediate ETH)
- Minting and burning LP tokens

> Each ERC20 token has its own `Exchange` contract.

### 3. `Factory.sol`
- Creates and stores unique `Exchange` contracts for each ERC20 token.
- Prevents duplicate exchanges.
- Acts as the central registry.

---

## 🔄 How Token-to-Token Swap Works

1. User calls `tokenToTokenSwap(_tokensSold, _minTokensBought, _tokenAddress)`
2. Tokens are swapped to ETH in the source `Exchange`.
3. ETH is forwarded to the target token's `Exchange`.
4. Target `Exchange` executes `ethToTokenTransfer` to send the output tokens **directly to the user**, saving gas.


## 📚 Concepts Used

- ✅ Constant Product Formula `x * y = k`
- ✅ LP token mint/burn math
- ✅ Factory + Exchange architecture
- ✅ `msg.sender` context during factory deployment
- ✅ Gas-optimized token transfer routing

---
