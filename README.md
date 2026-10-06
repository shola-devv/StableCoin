# Stablecoin Project

A simple decentralized stablecoin project built with Foundry.

This project demonstrates a stablecoin system with:
- an ERC20 stablecoin token
- collateral-backed minting logic
- a DSCEngine contract managing deposits and price feeds
- OpenZeppelin and Chainlink integrations

## Stack
- Solidity
- Foundry
- OpenZeppelin
- Chainlink price feeds

## Project Structure
- `src/DecentralisedStableCoin.sol` — the stablecoin token
- `src/DSCEngine.sol` — collateral engine logic
- `test/` — test files
- `lib/` — external libraries

## Getting Started

Install dependencies:

```bash
forge install
```

Compile the project:

```bash
forge build
```

Run tests:

```bash
forge test
```

## Notes
This is a project focused on stablecoin mechanics, collateralization, and minting logic. It is intentionally simple and meant to be expanded as more advanced DeFi features are added .


