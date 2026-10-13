# Event Horizon — Last Run to Earth

A 2D sci-fi survival platformer. Outrun the Devourer, solve puzzles to earn weapons, and reach Earth.

- **Play:** open `index.html` in a browser (single self-contained file, no build step).
- **Story Run:** six worlds — Fractured Moon, Aether-7, Cinder Moon, Cryos, Vortex Prime, Earth.
- **Weapons:** Energy Sword (mirror puzzle), Plasma Blaster (symbol lock), Phase Shield and Gravity Lance (orbital locks).
- **Infinite Frontier:** endless generated sectors with rising difficulty.
- **Controls:** A/D move, Space jump, Shift dash, J slash, K shoot (hold to charge the lance), Q shield, E use, M mute. Touch buttons appear on phones.

## Layout
- `index.html` — the full game (assembled from `src/`).
- `src/` — game source parts (`p1.html` head and input, `p2.js` levels and backgrounds, `p3*.js` drawing, `p4*.js` gameplay and puzzles, `p5.js` scenes and loop). Concatenate in this order to rebuild: `p1.html p2.js p3.js p3b.js p4.js p4b.js p5.js`.
- `assets/` — exported SVG art (characters, enemies, objects, weapons, planets, world backdrops). Open `assets/index.html` for a gallery.
- `tools/gen_assets.py` — regenerates the assets.
