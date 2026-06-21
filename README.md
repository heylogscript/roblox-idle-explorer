# BrainrotIdle

An **idle exploration clicker** built for Roblox. Explore zones, collect artifacts, open chests, buy upgrades, and rebirth to progress further.

## Systems

- **Zone Exploration** — Click-driven zone progression with unlock gates
- **Artifact Collection** — Random artifact drops with rarity system
- **Upgrade Shop** — Buy permanent and temporary power-ups
- **Chest Opening** — RNG-based loot with rewards
- **Rebirth/Reset** — Prestige mechanic with permanent multipliers
- **Data Persistence** — DataStore save/load for player progress
- **Full UI** — Clicker HUD, shop, rebirth panel, stats display

## Architecture

| Layer | Role |
|---|---|
| `GameManager` | Core game loop, state orchestration, DataStore I/O |
| `WorldManager` | Zone/gate/artifact spawning and management |
| `Constants` | Central config: zones, upgrades, artifacts, chests |
| `GameUI` | Client-side HUD and all UI panels |

## Tech

- **Language:** Luau
- **Engine:** Roblox
- **Pattern:** Modular manager architecture, server-authoritative
