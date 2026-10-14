# Space Odyssey

A 2D astronaut flight-survival game built with Godot 4. Pilot through open-space and planetary environments, manage fuel, avoid hazards, collect supplies, and reach each launch gate to continue the campaign.

## Run the game

1. Install Godot 4.7 or later.
2. Open this repository in the Godot editor and press **F6** to run the configured main scene, or run from a terminal:

   ```powershell
   godot --path .
   ```

## Controls

| Action | Keyboard | Purpose |
|---|---|---|
| Steer | `A` / `D` or arrow keys | Rotate the astronaut's flight direction |
| Thrust | `W`, `↑`, or `Space` | Accelerate forward |
| Brake | `S` or `↓` | Slow down and reverse |
| Boost | `Shift` | Burst forward while consuming fuel |
| Interact | `E` / `Enter` | Use a launch gate when its requirements are met |
| Energy sword | `J` / Left mouse button | Melee attack |
| Blaster | `K` / Right mouse button | Fire a projectile |
| Phase shield | `Q` | Activate the shield |
| Pause | `P` / `Esc` | Pause or resume |

## Campaign

The campaign contains ten planetary environments, each with its own flight conditions, hazards, fuel requirements, and route to the next world. Collect fuel cells and energy orbs, avoid collisions, and reach the launch gate with the required supplies. Completing levels earns credits that can be spent on fuel tank, thrust, and engine-efficiency upgrades.

The opening Black Space mission introduces flight and the singularity hazard. Use the planet navigation screen to replay unlocked missions and review your progress.

## Project structure

- `scenes/` — Main menu, flight gameplay, player, hazards, and UI scenes.
- `scripts/` — Campaign data, persistent game state, and procedural sound.
- `assets/` — Planet, character, enemy, hazard, and equipment artwork.
- `public/` — Firebase Hosting site and web-game assets.

Firebase Hosting is configured to serve the `public/` directory. Deploy it with the Firebase CLI after authenticating and selecting the intended Firebase project.
