# htContract — Decentralized Ticket Registry

Solidity smart contract for the HackTickets platform. Deployed and tested on a local Hardhat network; ready for Base Sepolia.

## Contract

**`DecentralizedTicketRegistry`** — `contracts/contract.sol`

Key responsibilities:
- Create and manage events (name, location, date, capacity, price, active status)
- Mint tickets — stores a salted hash of the buyer's phone number on-chain (no PII)
- Mark tickets as used to prevent double-entry
- Only the contract owner (backend wallet) can write to the contract

## Scripts

```bash
npm run node      # Start local Hardhat node on http://127.0.0.1:8545
npm run compile   # Compile Solidity → artifacts/ + typechain-types/
npm run deploy    # Deploy to localhost and write htBe/deployment.json
```

## Setup

```bash
npm install
npm run node       # Terminal 1 — keep running
npm run deploy     # Terminal 2
```

After deploy, `htBe/deployment.json` is updated with the contract address and ABI path. The backend reads this on startup.

## Networks

| Network | Chain ID | RPC |
|---------|----------|-----|
| `hardhat` (in-process) | 31337 | — |
| `localhost` | 31337 | `http://127.0.0.1:8545` |

To deploy to **Base Sepolia**, add to `hardhat.config.ts`:

```ts
baseSepolia: {
  url: process.env.BASE_SEPOLIA_RPC_URL,
  accounts: [process.env.PRIVATE_KEY],
  chainId: 84532,
}
```

Then: `npm run deploy -- --network baseSepolia`

## Generated Files

| Path | Description |
|------|-------------|
| `artifacts/` | Compiled ABI + bytecode (git-ignored) |
| `cache/` | Hardhat build cache (git-ignored) |
| `typechain-types/` | TypeScript types for the contract (git-ignored) |
| `htBe/deployment.json` | Contract address written by deploy script |
