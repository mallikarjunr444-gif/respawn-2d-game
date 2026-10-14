# Space Odyssey — Geometric & Mathematical Planetary Survival

A continuous 2D sci-fi planetary survival adventure hosted live at [https://orvexgames.me/](https://orvexgames.me/).

Outrun the cosmic **Black Hole Devourer**, navigate dynamic planetary environments, execute precision **Auto-Land** vector trajectories onto elevated landing lines, solve **geometric ricochet puzzles**, engage in multi-faction skirmishes, and wield devastating energy tech across the solar system and infinite cosmos.

---

## 🎮 Controls & Flight Telemetry

| Action | Keyboard | Touchpad / Gamepad | Purpose |
|---|---|---|---|
| **Steer** | `A` / `D` or `←` / `→` | Left / Right Arrows | Rotate attitude & steer vector |
| **Thrust / Flight** | `W` / `↑` / `Space` | `THRUST` Button | Longitudinal thruster acceleration |
| **Auto-Land** | `L` | `AUTO-LAND` Button | Autonomous descent guidance vector computer |
| **Brake / Reverse** | `S` / `↓` | Down Arrow | Retrograde braking burn & altitude drop |
| **Tactical Dash** | `Shift` | `DASH` Button | High-speed impulse burst (invulnerability window) |
| **Energy Sword** | `J` / Left Click | `SWORD` Button | Melee arc slash & **specular projectile parrying** |
| **Plasma Blaster** | `K` / Right Click | `BLAST` Button | High-velocity kinetic bolts with **specular ricochet** |
| **Phase Shield** | `Q` | `SHIELD` Button | **1 Shield Per Level**: 3.5s hexagonal invulnerability |
| **Board / Interact** | `E` / `Enter` | `BOARD` Button | Board departure rocket when artifacts secured |
| **Pause / Resume** | `P` / `Esc` | `PAUSE` Button | Mission tactical pause |
| **Retry** | `R` | Retry Button | Instant retry upon systems failure |

---

## 📐 Core Mathematical & Geometric Systems

1. **Auto-Land Guidance Vector Navigation**:
   - Calculates target displacement vector $\Delta \vec{r} = \vec{r}_{\text{line}} - \vec{r}$.
   - Dynamically solves for retrograde retro-thrust burns $\vec{a} = -\frac{\vec{v}^2}{2|\Delta \vec{r}|}\hat{v} - \vec{g}$ to nullify drift and set pitch $\theta \to 0$.
   - Lands strictly onto the **elevated Holographic Landing Line** on solid terrain.

2. **Specular Ricochet Law**:
   - Laser blaster bolts and deflected projectiles calculate surface normal vector $\hat{n}$:
     $$\vec{v}' = \vec{v} - 2(\vec{v} \cdot \hat{n})\hat{n}$$
   - Angle of incidence equals angle of reflection ($\theta_i = \theta_r$).
   - Ricochet shots off optical mirrors to hit remote power nodes and bypass laser blast doors!

3. **Relativistic Black Hole Gravitational Pursuit**:
   - The Black Hole Devourer dynamically sweeps across space behind the player: $x_{bh}(t) = x_{bh}(0) + v_{bh} \cdot t$.
   - Relativistic gravitational pull vector:
     $$\vec{F}_{bh} = \frac{G \cdot M_{bh}}{(x - x_{bh})^2 + 1600} (-\hat{i})$$
   - Real-time HUD telemetry displays proximity in meters and gravitational pull in Newtons.

4. **Predictive Ballistic Trajectory Parabola**:
   - Live predictive flight arc rendered in real-time:
     $$\vec{r}(t) = \vec{r}_0 + \vec{v}_0 t + \frac{1}{2}\vec{g} t^2$$

---

## 🌌 Planetary Worlds & Specialties

1. **Fractured Moon**: Low gravity ($g = 340$), quantum gravity inversion fields, crystal refraction prisms. **Reward:** *Vibro-Energy Sword*.
2. **Aether-7**: High sky islands, aerodynamic tensor wind field $\vec{W}(t) = \langle A \sin \omega t, B \cos \omega t \rangle$. **Reward:** *Dual Plasma Repeater*.
3. **Cinder Moon**: Volcanic heavy gravity ($g = 950$), parabolic magma ballistic geysers. **Reward:** *Thermobaric Cannon*.
4. **Cryos**: Glacial frictionless ice momentum ($\mu = 0.04$), specular ice mirror caves. **Reward:** *Singularity Gravity Lance*.
5. **Vortex Prime**: Relativistic 3-body orbiting mini-singularities, curved spacetime geodesics. **Reward:** *Graviton Vortex Overclock*.
6. **Earth Extraction Base**: Atmospheric re-entry shear winds, orbital defense grid matrix.
7. **Endless Frontier**: Procedurally generated infinite cosmic sectors with escalating Devourer speed, procedural landing lines, and infinite scoring.

---

## ⚔️ Inter-Enemy Faction Warfare & Weapon Rewards

- **Hostile Factions**: Voidlings (Void Predators), Automated Drone Sentinels, and Biome Beasts engage in combat with each other!
- **Tactical Infighting**: Bait rival factions into crossfire to clear fortified caverns.
- **Weapon Progression**: Advanced weapons are achieved **only after winning fights** against planetary guardians.
- **1 Phase Shield Per Level**: Each planetary sortie permits exactly 1 tactical shield charge (`Q`).

---

## 🚀 Live Deployment

The game deploys automatically to Firebase Hosting from `public/` on merge to `main`:
[https://orvexgames.me/](https://orvexgames.me/)
