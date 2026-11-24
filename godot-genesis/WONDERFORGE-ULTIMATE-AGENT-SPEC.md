# WONDERFORGE: GENESIS — COMPLETE GAME PRODUCTION & AGENT SPECIFICATION

**Revision:** 2026-11-23. **Minimum:** Raspberry Pi 4B 4GB. **Desktop:** Windows, Linux, macOS (support subject to export validation). **Premium graphics target:** modern gaming PCs. **Engine:** Godot 4.7.x stable. **Nature:** production contract plus separately delivered blockout vertical slice, NOT a completed commercial game. **License:** original code and conceptual direction only; third-party assets require separate license verification.

The chapters below form one continuous reference for a local autonomous coding agent. They are repeated as separately editable files for specialized tasks. If instructions conflict, game mechanics and numerical truth in Master Game Design prevail; visual craft follows Art Bible; testing claims follow QA Acceptance. Treat any capability explicitly marked unimplemented as a **work order**, never a deliverable already certified.



---

# PART 1: MASTER GAME DESIGN

# WONDERFORGE: GENESIS — MASTER GAME DESIGN / PRODUCTION CONTRACT

**Revision:** 2026-11-23; **status:** production vision plus honest engine-blockout vertical slice. This is the source-of-truth specification for a cross-platform Godot game inspired at the systems level by LEGO Worlds, Scrap Mechanic, Besiege, Contraption Maker, exploration RPGs, vehicle racers, colony builders and hands-on STEM learning. It must not copy proprietary art, locations, logos, UI or character designs from any inspiration. All numerical budgets below are **proposed acceptance targets, not measured achievements**.

## 0. Non-negotiable product identity

WonderForge is not a launcher wrapped around boring educational demos. It is a premium third-person **open-zone inventor adventure RPG** where things built in an intuitive physical workshop are used in a believable living world. In the first sixty seconds, a player sees a breathtaking world of huge moving gears, warm sunset clouds, wild greenery, copper workshops, toy-like engineering apparatuses that feel materially substantial, a winding race road, distant sky islands, and small moving airships. Within five minutes the player physically handles parts, snaps a rolling chassis together, and drives it over a scenic bridge. Within fifteen minutes their vehicle meets an obstacle it cannot overcome, teaching a genuine principle of traction or gearing through experimentation. Within one hour they have a workshop, an expedition route, a journal with measurements, and a machine of their own design.

**Pillars:** (1) *Agency*—any functional-looking component communicates its use and offers immediate feedback; (2) *Physical invention*—creation affects motion, force, control and access, not just decoration; (3) *Wonder*—the landscape inspires curiosity and exploration; (4) *Consequential learning*—real concepts matter in solving puzzles, with explicit simplifications; (5) *Meaningful progression*—guilds, discoveries, materials, settlements, roads and trade; (6) *Cooperative brotherhood*—two profiles and family-shared plans, sequential play on one Pi and optional network/second controller on stronger platforms later; (7) *Graceful scalability*—same gameplay/save systems on Pi and PC.

**Absolutely avoid:** flat educational card grids pretending to be a world; unresponsive click targets; fake physics dressed up as science; busy HUD; a constant chatterbox tutor; twitch monetization or streak pressures; uncontrolled AI actions; pay-to-win; moving the completion goalposts with arbitrary timers; assumptions that the Pi supports desktop graphics.

## 1. The first fifteen minutes: exact authored sequence

**00:00–00:25 — cinematic emergence.** No unskippable cinematic. Black fades to the silhouetted underside of a suspended stone bridge. Wind pushes cloth flags. Warm light reveals white limestone roofs, teal glass domes, copper machinery, three moving cable cars and a lake reflecting a split sky. The camera drifts toward a stone arch inscribed with an original maker sigil. The interactive title appears unobtrusively; the player may immediately press any key to continue. Audio: tonal wooden percussion, winds, faint machinery; no voiceover exposition.

**00:25–01:10 — arrive at the valley.** Camera cuts into natural player view. The playable adventurer stands on compact earth beside a workbench under an open awning. The UI displays only the currently relevant input, one accessible objective and a small neutral compass. Visual markers are environmental—a warm lantern on the trail, a fluttering workshop pennant, a copper beacon near the entrance. A friendly engineer NPC is visibly tightening a wheel on a half-built rover; the character notices the player but never interrupts movement.

**01:10–02:30 — first physical interaction.** The player approaches a repair rig. The appropriate tool receives a soft outline only when within interaction range. E interacts. A compact instruction ribbon states: *“This cart has a chassis and wheels, but no transmission. Bring it to life.”* Lift and rotate a wheel part. There is a grounded, audible socket click and a visible axle animation; failure to place a part is shown by a distinct red outline and contextual reason, never a silent no-op.

**02:30–05:00 — build something useful.** Builder opens in a spatial mode, maintaining the visible world behind a responsive workbench. Select chassis, four wheels and power source. Every part has icon, mass, power drain, material and slot indicator. First pass teaches snap sockets. Second pass teaches center of mass with the car tipping on a ledge. A side-panel displays a *clearly labelled simulated* center-of-mass bar and wheel-force arrows. A holographic ghost previews positions; controller and keyboard equivalents exist.

**05:00–08:30 — first driving trial.** Press TEST. The crafted rover enters a contained 70-meter track, with wooden slalom posts, a low bridge, a 12-degree hill and a final rough-terrain strip. Test results are presented as lived sensory information—wheel spin sound, suspension bounce, a lean meter, lightly animated tracks—not a sterile table. A short after-action card summarizes time, distance, energy and wheel slip with one suggested improvement. The game does not call these engineering-grade measurements.

**08:30–12:00 — exploration and discovery.** The track gate opens to the Founders' Valley. The player earns the ability to drive their rover on the main road. At a river crossing, the old wooden bridge is incomplete. They can detour on a longer road or design a temporary crossing. This models open-ended systems and prevents a single correct-answer puzzle. Nearby are reeds, fish, tiny water-driven mills, birds and a half-buried ancient mechanism that foreshadows a larger mystery.

**12:00–15:00 — first quest & maker journal.** The player interviews a bridge steward, examines a diagram, chooses one testable hypothesis, builds or modifies a bridge, runs a load test and records an observation. Acceptable progress requires *evidence of attempted testing*, not a magic formula or an AI-generated conclusion. Rewards unlock a decorated workshop module and a local road improvement; the village visibly changes.

**Acceptance:** A novice can accomplish this sequence without a written manual, with clear keyboard/mouse and controller affordances. A usability observer records misclicks, time to first successful snap, test understanding, ability to explain one physics principle, and first-build completion. Hero reveal and critical interactions must be benchmarked on Explorer profile—not simulated by hidden pre-rendered video.

## 2. Main loop and progression economy

**Loop A / expedition (5–15 min):** choose destination on an illustrated atlas, pack tool and battery supply, traverse world on foot/vehicle, observe hazards, collect non-destructive resources, meet characters, discover a design need and return with a hypothesis. **Loop B / forge (5–30 min):** choose reusable blueprint, snap functional parts, wire mechanical/electrical connections, run test chamber, inspect results, change one variable, publish a revision in personal journal. **Loop C / deploy (5–25 min):** bring a working invention into a world quest, use it to cross terrain, mine safely, transport goods or service a settlement, earn craft reputation and open new options. **Loop D / community (open-ended):** build trade networks, power villages, expand workshop districts, research energy resilience, race machines and share family blueprints.

Progression is **capability-based rather than XP grind**: rank 0 Apprentice (wood and basic beams), rank 1 Tinkerer (simple wheel assemblies), rank 2 Mechanist (gearing and pistons), rank 3 Architect (bridges, towers, load-bearing modules), rank 4 Navigator (water and flying systems), rank 5 Systems Engineer (automation, power circuits), rank 6 Founder (settlement production and trade), rank 7 Master Inventor (multi-machine missions and scientific investigation). Ranks unlock visible *part families*, not health or paid power multipliers. Guild favor unlocks alternative solutions rather than forced quest order.

**Materials & production:** timber (light/renewable), stone (heavy/compressive), copper (conductive/ductile), iron (strong/heavy), glass (brittle/transparent), cloth (light/drag), rubber (grippy), crystal (game-fantasy energy source, explicitly fictional), biomass (renewable chemistry abstraction), water (flow), steam (thermal), electricity (circuit resource). Give each physical material density, compressive/tensile stiffness, friction, buoyancy and thermal bounds using plausible order-of-magnitude values; exact engineering constants should be separately validated and unit-tested. Fictional crystals must never be represented as real circuitry.

**Resources never encourage destructive extraction as the only option.** Salvage, trade, recycling, sustainable forestry and repairing infrastructure are equal paths. Player workshop inventory is separated from town economy. Machines require maintenance, but degradation is opt-in on beginner difficulty. Failing a test costs time and limited consumables, but never wipes a design.

**World changes:** fixing a bridge visibly causes NPC carts to use it; adding a water wheel supplies energy to a bakery; constructing a lighthouse alters nighttime navigation; sustainable harvesting restores a damaged grove; restoring a rail link changes shipment routes. Triggered changes need persistent state and a before/after visibility test. Do not claim simulation of thousands of individual NPCs on Pi: use event-driven aggregate economy ticks and scene-local NPC activation.

## 3. Six authored realms and their unique mechanics

### 3.1 Founders' Valley / core shared hub
A temperate verdant gorge at golden hour, cliff-side white limestone workshops, copper aqueducts, orchard terraces, an enormous suspended bridge and a distant observatory. **Signature:** modular construction, player-owned workshop and first rover. **Systems:** snap assembly, friction on dirt/stone, basic economy, travel routes. **Narrative:** the newly found Founders' Guild seeks help reactivating a chain of long-dormant research stations. **Landmarks:** workshop courtyard; river crossing; 500m explorer road; windmill ridge; council market; recycled-metal foundry; teaching quarry; trial arena. **Reveals:** each new bridge and mill changes traffic and ambient sound.

### 3.2 The Sky Citadels / elevation, flight & navigation
Floating isles with wind-carved pale sandstone, copper aero-bridges, hanging gardens, tremendous sky turbines and atmospheric cloud layers. Each isle has a believable silhouette at kilometer distance and is reached by lift or lightweight glider. **Signature:** lift, drag, stability, tether limits, wind reading, pendulums. **Physics:** initially use approachable glider forces and clear airspeed feedback; rigorous model documented separately. **World hazard:** sudden gust zones announced by waving banners and wind-carved streamers. **Settlement effect:** repairing a cable car restores deliveries.

### 3.3 The Copperwild / machines and agriculture
A massive orange-rock canyon meeting a green biome of organic farms and waterwheels, worn rail tracks, cable lifts, mining conveyors and hydraulic machinery. **Signature:** gear ratios, torque, pumps, elevators, factory layout and rotational constraints. **Quest:** rebuild a grain-processing line using a motor or water source under a limited power budget. **Visual:** sienna sandstone, oxidized copper patina, reflective shallow irrigation channels, dust illuminated by late sun. Mechanical silhouettes are legible from far away: large gear teeth, belt arcs, bright safety paint.

### 3.4 Crystal Deep / geology, acoustics, subsurface exploration
Natural basalt columns descend into an underground aquifer with translucent mineral veins. Sections are in complete shadow except cave lichen, helmet lamps and reflected crystalline scattering. **Signature:** rock stability, simple geology, resonance, light reflection, echo-location puzzles, carts and drilling ethics. **Rule:** avoid false claims that crystal light or sound proves a geological theory; use the fantasy crystal as a game metaphor while supplying real field-guide comparisons.

### 3.5 Verdant Circuit / ecology and stewardship
Mossy forest canopies, enormous rooted living bridges, solar collectors disguised as leaves, carefully tended greenhouse domes and layered wetlands. **Signature:** irrigation, water balance, solar-energy budgeting, composting and low-impact infrastructure. **Mission:** design a powered seed nursery that grows without draining the local pond. Player impact alters wildlife, water flow and farm yields. Exploration includes real habitat observations and optional field activities.

### 3.6 The Ember Frontier / racing & advanced invention
A striking red desert and volcanic escarpment streaked with dry lake beds, mining ghost towns, long banked racetracks, elevated loop structures and abandoned wind towers. **Signature:** traction, gearing, momentum, vehicle center of gravity, track design and risk analysis. **Modes:** family-friendly stunt arena, ghost time-trial, logistics convoy, sanctioned engineering championships, damage-off experiment range. Races reward good design as much as driving skill.

World **landscape transitions are ecological**—dry grass gives way to sandstone, river wetland to peat forest, and deep caves have temperature and moisture gradients. Use portal/station travel to hide load times rather than claim a seamless planet on Pi. Higher-end hardware can make more of the horizon truly explorable with streaming chunks.

## 4. Engineering gameplay as a controllable machine simulator

**The physical build contract:** every part must declare an unambiguous connector type, joint compatibility, dimensions in meters, mass in kilograms, structural resistance, material, output capacity, rotation constraints, power ports, preview geometry and collision geometry. Parts receive a stable UUID independent of scene-instance IDs. Snap points are local transforms with tags (`stud`, `axle`, `hinge`, `hydraulic`, `electric_low`, `belt`, `rope`, `fluid`). The snap solver returns an actual placement transform and reason for invalid placement; users can disable snapping temporarily with a modifier.

**Build modes:** object mode (select / inspect), place mode (ghost), rotate mode (one-degree optional or 15-degree default), multi-select/group, symmetry plane, wire routing, hinge limits, axle bearing placement, paint and material. A beginner mode hides advanced joints and shows safe presets. A professional mode exposes solver settings, power graphs, debugging overlays and measurement probes. Undo/redo must be atomic and bounded to 100 commands with replayable data. Keyboard and controller affordances are equally discoverable; separate hotbar and radial menu layouts.

**Structural topology:** a `MachineGraph` is the canonical persistent model, **not** scene-tree parenting. Parts become nodes; rigid/welded, rotational, prismatic, spring, rope and logic links become typed edges; generators, consumers, storage and controllers form separate network graphs. The runtime converts connected components into simulated bodies according to the active budget; repeated scene generation must yield the same assembly graph hash. Gravity acts through the physics engine and validated joint constraints. Do not fake a free-standing bridge by leaving static meshes floating. For Pi, replace distant machine dynamics with validated deterministic approximate states (e.g., engine RPM state) while the local active machine uses physics.

**Test rig:** choose flat floor, hill, wind tunnel, deep water, obstacle track, bridge load bay, conveyor and rail course. Set goals for time, load, failure rate, power consumption and human safety constraints. Preview real-time overlays with a legend for derived/estimated data; log a CSV and structured JSON with test conditions. Each test writes model identifier, units, assumptions, simulation timestep, hardware physics profile and errors. Teach that results are estimates requiring physical validation.

**Vehicles:** initial land buggy uses drive, steering, braking, sprung wheels and camera follow. Later categories include six-wheel rover, tracked hauler, pedal cart, tractor, hovercraft (fantasy energy), riverboat, glider, airship and autonomous delivery bot. The game should evolve beyond the basic `VehicleBody3D` prototype to custom raycast suspension / RigidBody3D forces with visible mass distribution, traction curves, wheel slip, torque and braking; benchmark it and cross-check conservation constraints. Vehicle handling must feel readable and fun before realism dials are enabled. Automatic stabilization is an optional accessibility assist and is **labelled**.

**Control programming:** visual wiring with input sensor, comparator, mathematical operators, timers, state machines, actuator outputs and an explicit update-rate meter. Basic programming starts with a visual sequence (turn, advance, wait), branches into conditions, loops and PID-like feedback. Robot actions must be deterministic in a test arena. The AI may explain scripts and propose a **diff** for human approval but cannot execute arbitrary code.

**Structural analysis:** compute mass and center of mass exactly from the part graph; estimate force propagation with a separately tested constrained solver; visualize utilization ratio and mark invalid assumptions. Stress modes require mesh simplification, material-specific force response and a calibrated reference problem. Full finite-element analysis is a stretch target requiring its own specialist validation—not a checkbox that a game physics engine automatically satisfies.

## 5. Racing, quests and empire systems

**Racing modes:** Workshop Time Trial (fixed course), Freestyle Proving Grounds (creativity score based on clearly displayed criteria, not AI judgment), Cargo Rally (secure cargo and minimize damage), Hill Climb (torque vs center of mass), Expedition Marathon (resource planning), Relay Challenge (two-player role rotation), Sky Courier (lift and energy) and Player Built Circuit (track editor and ghost comparison). Vehicles and tracks must obey collision rules; lap validity uses checkpoints and out-of-bounds recovery. Leaderboards are local-only by default, with signed ghost replays and no public profiles for minors.

**Empire building:** not a top-down incremental clicker. The player can found outposts, open workshops, connect roads/rail/air routes, route goods, balance water/power and help NPC communities. Buildings are built from the same parts and blueprints as vehicles, but settlement optimization operates on pooled network graphs. Strategic overlays show consumption and supply as animated streams in the world. Buildings continue functioning while the player explores; on Pi distant operations advance via cheap resource ticks rather than thousands of active meshes. Every expansion solves a physical/logistical puzzle.

**Story framing:** an ancient network of research towers known as The Loom of Makers fell dormant centuries ago. The world is not endangered by a generic evil wizard; it faces failing infrastructure, lost knowledge, trade disruption and ecological stress. The hero restores communities by understanding systems and collaborating across guilds. Key NPCs have conflicting legitimate priorities, and players can choose sustainable vs high-output solutions without simplistic morality meters. The final act asks players to design an integrated network spanning all six biomes.

## 6. RPG progression, characters and social tone

An adventurer is a maker and explorer, not a fantasy combat specialist. Core stats are **skills demonstrated through play**: Design, Mechanics, Navigation, Ecology, Programming, Investigation and Community. Skills unlock better diagnostics and new design options. They should never prevent clever construction from succeeding merely because a numerical level is low. Outfits reflect functional roles: tool belts, weather-resistant canvas, copper badges, goggles, climbing harnesses, handmade patches; body diversity is supported without age caricatures. Characters express emotions by grounded body language and context-specific idle animation. Quests are suitable for young teens without patronizing language. Exploration dangers are navigable puzzles; no graphic gore.

**NPC behavior:** contextual goal trees, scheduled work animations, pathfinding on town roads, current need tied to economy graph, dialog choices where the player asks questions, optional exploration hints. Use animation LOD and low-count active agents on Explorer tier. Every important NPC must remain interactable without a model running. ORBIT is optional mentorship, not the sole story gate.

## 7. User experience, onboarding and accessibility

**Camera:** over-shoulder third-person exploration, smooth collision-aware orbit and shoulder switching; driving chase camera adjusts FOV with speed, soft horizon stabilization; building camera orbits the selected assembly without nauseating roll. Zoom ranges min/max are tuned per activity. Rebinding, toggle sprint, left-handed controls, adjustable camera sensitivity, aim assist and reduced camera motion must be supported.

**HUD design:** world dominates the screen. Compact top-left objective breadcrumb, bottom-right one current interaction prompt, small spatial mini-compass, thin resource strip while inventory is relevant. The builder exposes a 3D object and a visible 2.5D radial part palette, not 40 dense cards. A translucent blueprint overlay appears only during construction and never obscures structural joints. On PC, text size and legibility scale independently from 3D. On Pi, HUD remains high-resolution while world resolution scales.

**Accessibility:** no essential information encoded by hue alone; status is color + icon + label; controller navigation with focus states; subtitles including directional nonverbal sounds; keyboard-only critical-path test; configurable high contrast/dyslexia-friendly typography; no mandatory audio or reaction-time bottleneck; assist mode for aim, build placement and steering; reduced motion affects bobbing, camera inertia, flashes and screen-space effects.

**Save integrity:** schema-versioned save for world seed, quest flags, workshop state, settlement economy and part graph IDs; use temp-write then atomic rename, rolling backups, file-size caps and per-profile directories. Cross-platform saves must be tested by saving on PC and loading on Pi after converting assets. No process launches user-supplied scripts on load. The currently shipped save is basic v1 and must be migrated by a dedicated service before opening real multiplayer/settlement content.

## 8. Educational models and trustworthy feedback

Every science interaction uses the sequence **predict → construct → simulate → measure → explain → revise → optional physical experiment**. Visible labels differentiate game fiction, idealized toy simulation, approximate engineering result and empirically validated finding. Model definitions store units and source references; numerical assertions live in specialist modules with unit tests. Introductory models: Ohm's law, simple circuits, acceleration/drag, torque and gearing, bridge loading, center of mass, fluid displacement, water wheels, solar input and efficiency, soil/water balance, structural resonance, simple orbital geometry. Dangerous real-world electrical/mechanical instructions trigger an adult-supervision note. ORBIT may explain or propose a plan but cannot forge observations or pass a test on behalf of a child.

**Educational debriefs appear because of a discovery**, never as mandatory popups every minute. Example: a rover slips on wet stone; freeze-frame player-chosen replay shows wheel spin and traction curve; an optional prompt asks “Did the wheels fail because the motor was too weak or because the surface offered too little grip?” The player predicts which alteration will help, modifies tire or gearing, and watches the rerun. The journal stores the two runs for later comparison.

## 9. Architecture and team ownership

**Domain modules:** `WorldStreaming`, `QuestDirector`, `InventorController`, `CameraDirector`, `BuildModeController`, `MachineGraph`, `MachineSerializer`, `PartCatalog`, `SnapSolver`, `PhysicsAssembly`, `PowerNetwork`, `VehicleController`, `ArenaDirector`, `TestRecorder`, `SettlementSimulation`, `InventoryLedger`, `NavigationMap`, `NPCBehavior`, `LearningModelRegistry`, `MakerJournal`, `OrbitMentor`, `SaveSystem`, `SettingsService`, `AudioDirector`, `UIFlow`, `QualityManager`, `TelemetryLocalOnly`. Each owns its API, deterministic tests and budget. The canonical part graph and quest state may not depend on rendering nodes.

**Platform rule:** deterministic gameplay operations run on GDScript data and Godot physics with fixed timestep. Render quality, mesh LOD, lighting and draw distance are separate resources selected by a quality profile. Export targets: Windows x86_64, Linux x86_64, Linux ARM64 Pi4 compatibility profile; macOS universal/architectures based on available signed export templates. Steam Deck is an optional Linux target. No DRM/cloud dependency. Renderer selection is independent from profile: Pi prefers GL Compatibility; modern PC Ultra may use Forward+; fall back gracefully if unsupported. Do not switch a renderer mid-scene without a controlled restart.

**Project ownership:** all art source masters in `art/source` with working files, production export outputs in `art/export`, optimized platform profiles generated into an asset manifest; no binary asset may be silently imported at incompatible units. A designer can open the Godot inspector and see exposed exported fields for every gameplay-configurable parameter. No monolithic 5000-line gameplay singleton. Strong smoke tests for missing scene nodes, stale file paths and asset license metadata.

## 10. Explicit release gates

**Vertical slice gate:** visible and controllable third-person character, navigable 3D zone, usable builder, a driving test, completed quest, save/load and crash-free 30-minute manual session on desktop. Blockout art must be labelled as such. **Gameplay alpha gate:** at least 30 validated parts, functioning connector/joint graph, 3 playable race courses, 2 complete town missions, 2 contrasting biomes, basic economy and evidence-based lessons. **Art beta gate:** representative final character animation, real PBR asset sets, consistent textures, authored key landmarks, UI typography and audio mix all audited. **Release candidate gate:** cross-platform regression matrix, data migration, 1-hour endurance sessions, performance and input profiles, accessibility and family privacy. **Pi-minimum gate:** actual Pi 4B 4GB hardware, exact OS/driver/renderer version, memory and thermal logs, worst-case active-machine budget, low-storage testing, two-user account separation and safe rollback. **Gaming-PC gate:** high-detail master assets, advanced lighting and simulation validated on a published reference desktop configuration. Failed budget ⇒ reduce tier fidelity or machine complexity with user-visible reason, never secretly degrade physics correctness.

See the art bible for the exact look, agent playbook for implementation order and tests, and the QA matrix for hard evidence requirements.



---

# PART 2: CINEMATIC ART BIBLE

# WONDERFORGE — CINEMATIC ART BIBLE & ASSET-PRODUCTION CONTRACT

**North star:** An *exquisitely crafted, physically believable world of giant human-scale invention toys and living environments*, with the tactile warmth of handmade machines, cinematic adventure grandeur and the precision of genuine engineering. Visual quality should meet professional cross-platform indie/AA game expectations on desktop; the Pi4 is a lowest-quality export derived from the same premium authored assets. **Not photorealism exclusively:** the world reads as art-directed realism—natural materials and accurate proportion, with slightly exaggerated silhouettes for gameplay readability. Not generic cubes, neon dashboard cards, pixel art, voxel-only placeholder characters, or toy-plastic everywhere.

## 1. Image in the player's head

Imagine walking into an animated photograph of an impossible invention festival built by a civilization of master makers. The opening shot contains an enormous elegant wrought-copper suspension bridge across a verdant valley; in the middle distance a bright off-white stone town clings to a cliff and bristles with windmills and telescopes; beyond, golden-hour light catches high waterfalls and impossibly distant floating islands. Grass moves in the wind, the river is milky turquoise, smoke wisps from a foundry chimney, a glider crosses the sun and the outline of a wind-powered rover rattles down a stone road. Close up, brass fasteners have worn edges and proper slotted screw heads; canvas stretches across workshop awnings; transparent glass gear housings reveal teeth turning; functional components communicate their roles without a tutorial label. There is rich detail, but the sightline from player to destination is always clean.

**Art promise:** every screenshot should feel like it came from a real authored game rather than software scaffolding. No endless lawns with stock primitives; every landmark has a compositional silhouette, a material identity, environmental storytelling, plausible function and artistic focal point. The low-end tier may simplify scenery but must keep beautiful silhouettes, atmospheric palettes, grounded material response and elegantly readable composition.

## 2. Global shape language and motifs

Three aesthetic families bind the world: **Architectural romance** (arched limestone, terraced gardens, stone staircases, carved pediments, elegant suspension spans), **mechanical craft** (exposed copper shafts, belt drives, brass flywheels, riveted iron, precise glass instrument faces) and **living ecology** (moss, bark, weathered river stones, canvas, crops, animal tracks). Buildings follow 70% grounded silhouette, 20% uplifting technical wonder, 10% impossible element. Shape grammar uses large soft stone arcs juxtaposed with sharply defined functional gears; do not overuse hexagons or glowing triangles. Primary visible designs should read as a recognizable 3D form at one-eighth screen size.

**Scale guide:** player eye ~1.65m, doorway 2.3m, modular part sockets every 0.25m or 0.5m, demonstration bench ~0.95m high, portable rover 3.2m long, workshop courtyard 16m across, village tower 22m, suspension bridge 100–150m, world monument 60–120m. In Godot 1 unit = 1 meter. Never solve visual identity by making all parts enormous, which ruins accurate torque/force models.

## 3. Palette specification

Use measured palette anchors, with lighting allowed to shift perceptual color; these are art-direction swatches, not uniform albedos for every material.

| Semantic role | Color | Usage |
|---|---|---|
| Deep indigo stone | `#182A39` | Shaded metal, night architecture, HUD backgrounds |
| Aether turquoise | `#67B9B3` | Water, authored magical highlights, system accent |
| Warm aged copper | `#AE7954` | Workshop structure, machines, mechanical tools |
| Pale limestone | `#D8C9AD` | Village walls, dry cliffs, sculptural form |
| Fern forest | `#476C55` | Natural foliage, darker grove midtones |
| Gold morning light | `#EFC889` | Warm sun, lanterns, successful connections |
| Safety signal amber | `#EDAC52` | Caution / moving hazard, with icon and label |
| Failure accent coral | `#D36D5C` | Invalid placement, over-limit gauges, with text |
| Fog pale teal | `#9BC6CB` | Distant aerial perspective, not fully white haze |
| Violet wonder | `#8D83B7` | Observatory, rare mineral elements only |

**Value hierarchy:** major surfaces occupy medium and pale values so machinery is easy to read. The player remains darker than sky and lighter than cave entrances. A placed machine's connection sockets must remain visible against both lush forest and red desert. In daylight, avoid black slabs that crush detail; at night, preserve readable highlights and natural color temperature contrasts.

## 4. Materials at fingertip scale

**White limestone:** layered warm-gray roughness, pale pores, edge microchips, rain streaks, mineral deposits near water, hand-polished corners. Subtle normal detail stays at honest world scale (rock pores millimeters, joint mortar centimeters). **Copper:** brushed warm base, slight patina at water seams and joints, fingerprints near handles, repeated thin machined grooves where shafts rotate, not a uniformly shiny orange shader. **Brass:** slightly yellow, satin from frequent touch, hard edges on precision instrument rings, warm specular under sunset. **Iron:** black oxide with worn steel at impact points, rivet halo and tool scars, rust at failed paint only. **Timber:** lengthwise grain aligned with each beam, end-grain at cut ends, bark left only on rustic bridges, different species for lightweight cedar vs dense oak. **Glass:** clear cyan-gray surfaces, real thickness/edge highlights, dirt at gaskets and plausible reflection without impossible screen-space artifacts; Pi substitutes alpha-dither with edge trim. **Fabric:** linen/canvas weave, folds governed by anchor points, subtle wind animation; not rubber sheets. **Rubber:** matte rough black charcoal, visible tread pattern, sidewall embossed fictional maker marks; geometry silhouette matters more than 8K texture detail.

**PBR master target:** normalized material exports, metallic/roughness maps, color + tangent normal maps, authored AO only for crevices, roughness variation and detail masks where meaningful. Prefer 1K/2K textures per hero asset on desktop and 256–512px atlases on Explorer. Screen-space roughness should be physically plausible and not glow. Avoid texture repetition on roads by modular decals and procedural material blending. Substance Painter/Designer, Blender and ArmorPaint are acceptable source tools; deliver original blend files and material recipes.

## 5. Lighting and atmospheric composition

**Golden-hour baseline:** 18°–28° sun elevation, warm near-horizontal key, cool sky fill, soft penumbra on large forms, contact occlusion beneath beams and raised rails, subtle dust motes near foundry exhaust. **Night:** moon and stars drive silhouette, warm tungsten lanterns pool around work areas; high-contrast paths remain navigable. **Cave:** fewer motivated fixtures, gemstone bioluminescence restricted to fictional zones, helmet lamp beams show moisture and dust, controlled darks. **Storm:** slate sky, distant rain bands, fluttering banners, puddle response, lightning only as optional non-essential spectacle.

**PC Ultra pipeline:** Forward+ with environment volumetrics where affordable, baked or real-time indirect lighting as appropriate, high-resolution shadows, screen-space effects only if justified, sky shader with rich gradients, animated cloud layers, wind-reactive vegetation, screen-space reflections selectively. Use baked probes/lighting where static to reduce cost. **Creator:** simpler skies, distance shadow cascades, limited particles, lower shader variants and moderate reflection resolution. **Explorer:** Godot Compatibility renderer, baked/AO-like vertex accents, limited directional shadows (possibly off), authored vertex colors, unlit atmospheric gradients, low particle count, mesh fogcards instead of expensive volumetrics. Measure everything on actual device before approving settings.

**Camera composition:** horizontal 16:9 hero screenshots use a clear foreground prop (workbench/rail/grass), anchored midground (player + machine), landmark background and sky layer. Keep the playable hero at a meaningful screen proportion and no HUD text over the brightest region. Use 35–50mm equivalent camera for narrative glimpses, wider 24–30mm equivalent for vehicle trials, and avoid excessive FOV stretch. Every scene has specified focal point, secondary silhouette, navigation path and gameplay affordance.

## 6. Characters: human, relatable and real

**Player inventor:** early-teen-appropriate adventurer with natural anatomy, open-face expressions, practical clothing, hand-crafted accessories and a readable silhouette: fitted canvas jacket, rolled sleeves, reinforced trousers, leather work boots, shoulder satchel, small folded blueprint case and a compact wrench clipped at the hip. Optional goggles rest on forehead, never permanently conceal emotion. Body variants and head/hair combinations must not use bizarre proportions, gray beards or stock wizard robes. No costume implies a real brand or a proprietary character. Different playable brothers may choose identities without requiring precise personal resemblance.

**Material detail:** skin has plausible scattering on PC and a cheaper carefully authored texture on Pi; cloth friction and creases respond subtly to motion; leather straps possess stitching and edge dye. Animation set: 8-direction jog blend, relaxed idle, look-at, foot-plant on uneven ground, jump/land, two-handed carry, inspect part, kneel-and-weld, turn crank, lift heavy beam, steer vehicle, cheer, fail/reflect, journal writing, climb, swim and contextual sit. At least one handed-instrument pose where wrist/hand properly grasps the tool. Idle loops are staggered, not synchronized across crowds. Feet must not visibly skate in common gameplay.

**NPC lineup:** Maeve, senior bridgewright with rolled sleeves, leather apron and blueprints; Orrin, young inventor friend with a mismatched prosthetic tool attachment but no comedic disability treatment; Suri, greenhouse steward with waxed cotton rain cape and botanical satchel; Bram, broad-shouldered foundry mechanic with dark safety goggles and worn copper badge; Iona, observatory navigator with layered indigo scarf and angular compass. Each NPC has 3 readable clothing cues, 2 unique gestures, a personal workshop area and a story conflict revealed by actions, not lore dumps. Player age and family context should not infantilize the adventure.

## 7. Major location render sheets (artist instructions)

### A. Founders' Landing / opening spawn
**Composition:** asymmetrical S-curve trail at lower right leads toward grand arch at upper-middle. Left third: sunlit stone steps, hanging baskets, old oak and river glimpses. Right third: high-ceilinged open workshop with three huge gears rotating in different planes. Center: human-scale workbench with a partially assembled rover and approachable NPC. In far background: ribbon waterfall falling from a layered cliff at least 90m high; upper horizon holds floating island shadows. **Palette:** pale limestone, amber copper, deep forest teal, turquoise water, gold dust. **Motion:** fluttering linen roof, tree crowns, belt drive, occasional bird. **Audio:** water fall-off, clink of tools, wind, wheel ratchet. **Gameplay:** progression path readable via light, not an oversized waypoint pillar. **Asset list:** 7 modular wall sets, 4 awning types, 12 shop props, 3 gear assemblies, 2 lantern designs, 4 garden clusters, multiple road segments and 5 workshop tools.

### B. The Ribbon Bridge / first engineering problem
**Composition:** long exposed suspension span across foaming gorge; near end safe and repaired, far end missing six deck segments. Vertical rock walls show geological layers, lichen, niches and old support anchors. A freight cart waits on the near side; its wheels are realistically supported by ground geometry. **Gameplay affordance:** beam sockets glow **only during build mode**; correct-span state produces visible load-path visualization, no invisible collision bridge. **Lighting:** slanted afternoon sun reveals structural tension cables; mist softly separates cliffs. **Action:** player tests a small load cart with optional weight increments. **Success state:** rebuilt span visibly carries carts and reconnects village traffic. **PC hero asset:** physically credible cable anchor clamps and materials; **Pi substitute:** simplified cable mesh and static bridge segments with collision, while preserving the interaction zone.

### C. The Copperglass Foundry
**Composition:** a circular industrial hall open to the sky, terraced work floors and a diagonal conveyor belt crossing composition. Dominant monumental flywheel is framed against a smoke-lit roof opening. **Surfaces:** black iron girders, oxidized copper pumps, glazed bricks, safety yellow paint, grime only where use would cause it. **Lighting:** cool top light and warm furnace glow, high-quality emissive surfaces with restrained bloom. **Gameplay:** belts, gears and crushers have physically clear input/output, motor power meter and protected guard rails. **Audio:** low machinery hum, rhythmic chain clack, intermittent steam.

### D. Sky Citadel / epic vista
**Composition:** camera from a stone balcony looking toward white cliff islands suspended over a bright sea of clouds. Distant left is a crescent-shaped city built into a vertical island; upper center: gigantic orrery of gold/bronze rings; lower right: small working glider resting on a cable-car platform. Bridges and ropes introduce scale. **Material:** polished sandstone and iridescent glass; warm organic moss on rain-exposed surfaces; subtle blue atmospheric scattering. **Narrative cue:** severed cable-car segment hangs visible between two inhabited islands. **Animation:** tethered flags continuously show wind direction; suspended cargo platforms move slowly on demonstrably plausible paths. **Performance:** use layered distant sky cards for Explorer, real meshes for Creator/Ultra.

### E. Copperwild Waterworks
**Composition:** orange-brown canyon wall on left, blue-green irrigation terraces descending to lower right, huge timber waterwheel under center-left waterfall. Transparent water movement communicates kinetic energy. **Gameplay:** player can change flume valve, water flow and gear ratio, causing different wheel rates and mill output. **Material:** copper oxidation, wet basalt, worn cedar, woven baskets, grain sacks. **Audio:** low rushing water modulated by valve opening, creak of wooden shaft, grain conveyor scatter.

### F. Crystal Deep cathedral cavern
**Composition:** narrow tunnel in the lower-left opens into enormous vaulted cavern with colossal geometric black basalt columns and suspended mineral bands reflecting in deep blue water. One small human miner on a rope bridge establishes 100m scale. **Lighting:** shafts from ceiling fissures, bioluminescent lichen in sparse bands, specular crystals confined to local sources. **Gameplay:** rock stability, resonance measurement, safe route choices, cave cart physics. **Avoid:** random glowing RGB crystals everywhere; real mineral groups have coherent stratification and physical texture.

### G. Verdant Circuit botanical canopy
**Composition:** elevated wooden deck threaded between towering oaks, shallow wetland below and a luminous but grounded greenhouse under a wind turbine canopy. Exaggerated leaf silhouettes filter afternoon sunlight. **Interactive:** seedlings, insects, water gauge, irrigation pipe network, solar panels and a water pump that obey model constraints. **Sound:** insects, birds, slow wind, pump hum. **World state:** the biome appears visibly healthier as the player balances water and energy rather than simply being awarded green particles.

### H. Ember Frontier machine-racing stadium
**Composition:** massive rammed-earth amphitheater with angled copper grandstands, track spiraling across canyon ledge, distant red mountains and tall weather masts. A small maker-town market occupies bottom-left foreground. Race-start line has a proper mechanical gantry rather than default UI shapes. **FX:** tire dust, stone chips, heat haze only on PC if performant, physical suspension movement, satisfying wheel compression and mechanical idle. **Gameplay clarity:** road banking and terrain roughness visually predict steering and traction challenges. **Replay:** photo-mode composition options and side-by-side vehicle iteration comparisons.

## 8. Vehicle design families and exploded-view requirements

**Rover Mk I (intro):** 3.2m × 1.8m, steel-tube chassis, four removable tires, visible coil suspensions, covered storage pack, copper-blue motor case. Distinctive taper front grille and two work lights. Exposed modular bolts indicate sockets. *Reference sheet:* front/side/rear/3/4, exploded joint map, materials, collision volumes, suspension travel animation and LOD0–3. **Hauler:** six-wheel long chassis with dynamic independent cargo tray and turning radius diagram; textured weathered utility finish. **Crawler:** tracked articulated robot for cave safety; animated sprockets and believable belt silhouette. **Airship:** wooden composite gondola under textile balloon; craft mass and lift visually apparent; realistic rigging. **Glider:** bird-inspired ribbed wings and narrow fuselage, legible control surfaces. **Racer:** modular lightweight chassis, engineered downforce surfaces and reversible safety cage.

**Physics and visual binding:** wheel tire visuals attach to actual wheel joints; hinges rotate around their modeled axis; a stopped motor cannot keep visually spinning full speed. Do not animate fake collision where gameplay says a part has fallen off. For optimized tiers, bake nonfunctional tiny screws into normal/trim details but preserve crucial part joint silhouette and collision fidelity.

## 9. Build mode visual grammar (critical)

The construction interface should feel like being inside a spectacular virtual workshop, **not operating a form**. With B, the camera gracefully circles a clear work area as the surroundings de-emphasize. A subtle blue-white engineering grid appears only on the immediate bench. A part palette arcs along the bottom or left, with 3D silhouettes and a literal category name; numbers quick-switch. The selected part is a solid translucent hologram with a physically scaled shadow, snap points rendered as small spheres/rings, yellow axis guides, a clean orange 'cannot connect' state and a concise reason such as 'AXLE CONNECTOR REQUIRED'. A surface that would cause instability displays a projected center-of-mass arrow in *Advanced Tools* mode only. A prominent TEST switch transforms the setup instantly into a physics arena; no modal interrupts during experimentation.

**Audio-haptics:** hovering snap point = soft resonant tick; snapping = crisp wooden/metal click; invalid = quiet muted note, not an alarm; cutting connection = short release; changing part family = tactile flip of a catalog page. Controller haptics optional. Hotkeys must be shown near the component, not buried in Help. Large legible part labels and consistent shapes are essential on 720p Pi displays.

**Premium menus:** main menu is a real 3D room with visible diorama: sunlight through arched workshop doors, moving gears behind the title. Navigation items are carved signboards or precise unobtrusive type; no card-grid web aesthetic. The world map is a believable hand-illustrated chart with relief shading, movable lens and animated trade routes. Inventory is a physical blueprint book turning pages; text remains crisp vector UI. Quest log is a set of well-illustrated field notes with location sketch and clear next action, not a social-media task checklist.

## 10. Desktop graphics master / Pi-derived production matrix

| Asset/system | Explorer minimum Pi4 | Creator desktop | Ultra gaming PC |
|---|---|---|---|
| Main renderer | Compatibility, validated device driver | Compatibility or Mobile/Forward+ when measured | Forward+ with fallback |
| World texture atlases | 256–512px shared | 1–2K major textures | 2–4K hero surface sets |
| Important character | LOD2 geometry, one atlas | LOD1 and standard rig | LOD0 hero head/cloth, high fidelity |
| Far mountains | layered billboards/sky cards | impostor + mesh LOD | long-range geometry/streamed HLOD |
| Trees & grass | instances, simplified 100–300 visible | 500–2000 nearby instances | biome-dependent dense instances and wind |
| Shadows | baked/limited directional | cascaded dynamic sunlight | tuned cascades, soft contacts |
| Water | authored surface w/ efficient highlights | opaque+foam and reflections | physically attractive shore interaction |
| Part physics | small active assemblies budgeted | bigger assemblies, faster stepping | expanded budget and diagnostic fidelity |
| Sky | procedural gradient + static cards | animated atmospheric layers | physically detailed clouds when affordable |
| Animation | reduced-distance skeleton updates | full near-camera blending | richer secondary motion & cinematic idle |
| Viewport | 720p, dynamic scale where supported | 1080p tuned | 1440p/4K optional |

**The frame budget is a constraint, not an excuse:** high-end art is authored first, then LOD and shader derivatives are generated. Every derivative retains the same socket transforms, measurements, authored collision and gameplay behavior. A Pi silhouette must be recognizable alongside the PC counterpart in a side-by-side comparison. Avoid hiding functional moving parts at low quality. The exact numbers are **starting hypotheses** until measured on target devices.

## 11. Asset pipeline and acceptance templates

Every artist or AI-generated asset must be reviewed for copyright and coherence. Required source package for each hero model: original `.blend` or equivalent; a licensed source record; an FBX/glTF export; an origin/pivot diagram; scale check with 1m ruler; PBR textures; LOD0, LOD1, LOD2, LOD3; collisions in separate layers; 6-angle thumbnail turntable; an in-engine lighting screenshot; vertex/triangle/texture budget; machine connector transforms if applicable. Export forward axis as Godot-compatible (`-Z` forward, +Y up), use unit conversion audit. Nothing is imported into production with unknown scale.

**QA checklist:** Is the primary object legible at a distance? Are materials physically plausible? Does vegetation look rooted rather than scattered? Do highlights support focal hierarchy? Are moving parts visually tied to physical state? Does the world feel consistent with its own architecture? Are visual instructions unambiguous without text? Are tier variants perceptually coherent? Is the scene playable with no GPU feature? Are important elements keyboard/controller accessible?

## 12. Generative asset brief format

When using ComfyUI or image generators, use them for concept sheets, approved texture exploration, background plates and mood studies—not as proof that a 3D scene is built. Canonical prompt fields: `SUBJECT, LOCATION, FUNCTIONAL REQUIREMENTS, ART DIRECTION, LIGHTING, COMPOSITION, SCALE, MATERIALS, COLOR TEMPERATURE, ENGINE LIMITS, NEGATIVE SPECIFICATION, REVIEW CRITERIA`. Require a deterministic seed and store workflow/weights/license metadata. Human reviews select a consistent design language before 3D conversion. No image-to-3D mesh may be accepted without correct topology, UVs, pivots and joints.

**Founders' Valley concept example:** “Wide 16:9 cinematic environment concept art, three-quarter elevated angle toward warm limestone maker village astride a turquoise river gorge, monumental suspended copper bridge in middle distance, believable workshops with turning gears and canvas awnings, layered forest cliffs, tall waterfall framed by rock stratification, small adventurous character scale reference, real material textures, late-afternoon golden sun, teal sky fill, astonishing atmosphere and sense of discovery, visual hierarchy and traversable landscape, ground-level shot feasible in 3D game. NOT a screenshot mockup, NO UI overlay, NO LEGO trademark figures, NO stock low-poly cubes, NO floating meaningless geometry, NO text or logos.”

**Engineer-approved image selection:** choose images depicting physically plausible geometry and clear machine function even before artistic sophistication. Generate separate mechanical orthographic callouts for artists; do not blindly convert impossible 2D gear meshing to production. Preserve AI workflow in `art_prompts/` and archive rejected designs for visual consistency checks.

## 13. Audio identity

Musical score combines chamber-string optimism, warm marimba and hammer dulcimer articulation, acoustic guitar harmonics, subtle analog modular synth, and found-object percussion. Exploration motifs share a recognizable four-note original interval that changes instrumentation by biome; avoid recognizable copyrighted themes. Mechanical audio is tactile, high-dynamic-range but controlled: bearings squeak under strain, gears have tooth cadence proportional to RPM, different surfaces produce distinct tire/foot impacts, stream flow reacts to volume. Mix buses: Master, Music, Ambience, Machines, UI, Voice, Accessibility. Mono fold-down must remain legible; subtitles for important nonverbal clues. Pi tier limits simultaneous voices, not necessary safety cues.

## 14. What the current build is visually

The repository's initial `scripts/world_gen.gd`, `player.gd` and `vehicle.gd` use **primitive Godot meshes as a shape-blockout**, not the look above. The purpose of those files is to establish scale, playable space, collision, basic camera and mechanics. Their visual limitations are known and intentional. Your local agent must use the tasks in `AGENT_BUILD_PLAYBOOK.md` to replace them with **real, art-directed modular assets**, then capture desktop and Pi screenshots against the hero-scene descriptions here. **Do not mark any art task complete merely because its placeholder meshes render.**



---

# PART 3: AUTONOMOUS AGENT BUILD PLAYBOOK

# WONDERFORGE — AUTONOMOUS GODOT BUILD AGENT PLAYBOOK

**Role:** principal gameplay engineer + technical artist + QA lead. **Goal:** transform the Godot Genesis blockout into a premium cross-platform invention-adventure game. **Execution principle:** implement a playable verified vertical slice, not a hundred inoperable menus. Favor safe incremental commits with objective acceptance evidence. Work from Godot 4.7.x stable GDScript; do not quietly upgrade to unstable engine releases. The Pi4 4GB is the **minimum certification target**; PC Ultra is the primary visual-quality design target. Asset source and save formats are shared.

## Read these artifacts before editing code

1. `docs/MASTER_GAME_DESIGN.md` for gameplay truth, progression, architecture and scope.
2. `docs/ART_BIBLE.md` for non-negotiable visual identity, scene sheets, materials, character and machine art.
3. `docs/PI4_PERFORMANCE.md` for rendering, quality profiles and device evidence.
4. `docs/QA_ACCEPTANCE.md` for exact proof required to call a feature shipped.
5. `README.md` for controls, current running code and explicit unfinished areas.

**Start session protocol:** record `git status`, Godot version/executable path, OS and architecture, render driver, source revision, available CPU/RAM/GPU and project baseline errors. Import and run `scenes/Main.tscn`. Save 3 screenshots (opening, movement, rover) and runtime log. If Godot is unavailable, perform source checks and stop claims of runtime verification. If a screenshot could not be captured by the running engine, do not substitute concept art or screenshots from a web page. Use a second branch named `feature/<ticket>`; never overwrite a teammate's uncommitted work. Commit each verified milestone with source and test evidence.

## Skills and tools

- **Godot** editor/headless/import/export, GDScript debugger, remote scene inspector and profiler. Test both Forward+ desktop and Compatibility Pi-tier renderers before changing default project renderer.
- **Blender** for clean mesh/rig/UV/LOD geometry and glTF 2.0 export. Use authored, licensed source assets only; capture turntables.
- **ComfyUI** for original concept studies and surface moodboards, NOT final meshes without artist review and proof of texture/mesh fidelity.
- **Audio** original or properly licensed, delivered as OGG/WAV/FLAC with rights record.
- **AI coding agent** may write source, tests, docs, scripts, prompts and art conversion tooling; it must never silently install OS packages or execute unknown downloaded scripts, and may not manufacture test outputs.
- **GitHub** CI with headless import/test and export checks on supported runners; Pi smoke/performance must run on a separate actual board before labels change.

## Workstream 00 — establish an engine-qualified baseline

**Inputs:** current `scenes/Main.tscn` and scripts. **Actions:** validate scene parses under the pinned engine. Fix any GDScript class registration or inference errors. Launch for at least five minutes; walk from the workshop to the grove; ray-place three parts, save and reload; enter Rover and drive at least 100m; walk near beacon and confirm progression. Save `artifacts/baseline/<commit>/`: `engine-version.txt`, `parse.log`, `play.log`, `screenshot-opening.png`, `screenshot-builder.png`, `screenshot-rover.png`, `test-matrix.json`. **Acceptance:** zero script parse errors, zero runtime exceptions, all initial interactions physically navigable, save round-trip. **Common failures:** GDScript typed inference mismatch, invalid resource enum, material/shadow feature unsupported on GL Compatibility, top-down camera blocked by a building, overlarge HUD on 720p; these are actual bugs to correct. CI parses only; it does not prove gameplay.

## Workstream 01 — replace the opening scene with final-quality authored modular environment

**Targets:** `scenes/world/FoundersLanding.tscn`, `scenes/props/`, `art/source/founders/`, `art/export/founders/`, `scripts/world/zone_loader.gd`, `data/landmarks/*.tres`. **Deliver 3 LODs** for monumental bridge, arches, workshop roof, aqueduct, waterfall cliff, mature oak and telescope tower, with correct collision and Godot pivots. Draw initial plan with exact coordinates and grid. Use terrain heightmap + procedural roadside dressing, not thousands of manually positioned unique nodes. Include stone/wood/copper trim atlas, surface decals and wind shader variants. Set a stable golden-hour light rig and weather color grade. Create 4 hero screenshots following compositions in `ART_BIBLE.md`. **Acceptance:** aesthetics signed off side-by-side with approved concept sheet; exploration from spawn to workshop remains <=2 minutes; interactive sockets distinguishable at 720p; LODs do not pop disastrously; collision paths accessible. **De-scope:** if key art cannot be finished, keep polished placeholder only for that art, do not replace gameplay with painted picture.

## Workstream 02 — build the modular machine-part catalog

**Files:** `data/parts/catalog.json`, `scripts/assembly/part_definition.gd`, `scripts/assembly/part_registry.gd`, `scripts/assembly/machine_graph.gd`, `scripts/assembly/graph_serializer.gd`, `scripts/assembly/connectors.gd`, `scripts/assembly/snap_solver.gd`, `scenes/parts/*.tscn`. **Minimum first delivery:** 30 visual+functional parts: structural beam (wood/steel), chassis frame, panel, strut, cross brace, axle shaft, bearing, wheel-small, wheel-large, tire-road, tire-offroad, caster, motor-electric, battery, gearbox, clutch, gear-8t, gear-16t, gear-32t, pulley, belt, spring, hydraulic piston, hinge, universal joint, steering rack, switch, lever, sensor-proximity, sensor-speed, lamp, cargo container, chain segment, rotor, float, propeller, solar panel, water turbine, seat, steering wheel, brake, connector, bridge anchor. Deliver named metadata for each including ID, unit scale, mass, material, center of mass, allowed connections, physics collider, tier-visual asset, texture license.

**Implement canonical graph:** stable part ID, connector ID, rigid groups and dynamic joint edges. Serialize numerical units and immutable schema version. Prohibit duplicate UUIDs, dangling edges, impossible connection classes, NaN, infinity, recursive asset paths and oversized graphs before spawning anything. **Acceptance:** machine saved in one operating system loads in another with identical graph and collision topology; 100 undo/redo operations restore original hash; invalid connector produces explanatory UI; no node names embedded as persistent IDs.

## Workstream 03 — create an intuitive spatial construction editor

**Files:** `scenes/ui/BuildHUD.tscn`, `scripts/build/build_controller.gd`, `scripts/build/tool_palette.gd`, `scripts/build/ghost_material.gd`, `scripts/build/command_stack.gd`, `scripts/build/workbench_camera.gd`. Implement enter/exit interpolation, object picking, outline, hover, snapping, intelligent part rotation, joint previews, symmetry/mirror, free placement, group move/duplicate and paint. Add 0.25m grid toggle, 15° rotation preset and precision mode. Device controls: keyboard/mouse, controller radial menu and gamepad bumper rotate. Add visible “WHY NOT?” connector error message. Include a “Quick Build” preset wizard for new players and advanced mode with joint/force visuals. **Acceptance:** novice attaches wheel to socket with <=3 clicks; two-minute benchmark to build a basic car without prior reading; undo restores cost and inventory; controls can be rebound; no impassable modal; game sim pauses while dragging unstable assemblies only when explicitly indicated.

## Workstream 04 — physical sandbox and testing simulator

**Files:** `scripts/physics/assembly_compiler.gd`, `scripts/physics/joint_factory.gd`, `scripts/physics/collision_groups.gd`, `scripts/physics/force_probes.gd`, `scripts/tests/arena_controller.gd`, `scripts/tests/measurement_logger.gd`. Compile part graph into rigid clusters and constraints; support fixed/weld, hinge, slider, rope, spring, rotational drive, damping and steering. Tune contacts, mass, restitution and friction by material with named units. Add deterministic offline test course with start/stop, reset, record and replay; summaries include velocity trace, time, distance, energy use, tire slip and contact violations. Validate conservation sanity: freefall acceleration, inclined plane, torque on a rotating flywheel, unloaded spring oscillation, bridge beam sag in a validated simplified model. Show a disclaimer where physics is approximated. **Acceptance:** machine falls when unsupported, bridge sags under added load, hinge rotates within bounds, wheels can lose traction and have visibly consistent motion, no ghost impulses or persistent creeping after reset. Record max contact/joint count and processing time by tier.

## Workstream 05 — “good driving” before advanced realism

**Files:** `scripts/vehicles/vehicle_controller.gd`, `scripts/vehicles/rig_suspension.gd`, `scripts/vehicles/steering_model.gd`, `scripts/vehicles/vehicle_camera.gd`, `data/vehicle_presets/*.tres`. Replace VehicleBody3D proof of concept with deterministic raycast/rigidbody suspension if it performs better and supports modular wheels. Give vehicle a controllable acceleration, predictable stopping distance, speed-dependent camera and shock-absorber visualization. Include tire friction variations and terrain-dependent rolling resistance; allow safe assists, handbrake, reverse, respawn. Build proper slalom, gradient hill, rocky lane and small jump. **Acceptance:** each control feels responsive at 30 FPS, no uncontrollable wobble, distinct tires change outcomes demonstrably, position reset is safe, a saved rover enters the world with the same appearance and physics on PC and Pi within declared approximation tolerances.

## Workstream 06 — write the game's first playable adventure chapter

**Scenes:** `scenes/missions/OpeningLanding.tscn`, `RepairCart.tscn`, `FirstRoverTrial.tscn`, `BrokenBridge.tscn`, `JournalReview.tscn`. **Quest spec:** cutscene skip, arrival, interaction indicator, first snap, rover test, scenic ride, broken bridge problem, create second revision, measured before/after, restore village route. Implement state machine and alternate solutions (detour is valid). **World consequences:** NPC cart route changes on bridge success; distant settlement smoke/street activity changes; quest steward moves from gate to market. **Acceptance:** fresh player follows flow without external guide, at least 2 valid solutions to bridge obstacle, every step can be resumed from save, objective texts have semantic tags, there is no softlock after leaving a mission zone.

## Workstream 07 — institute a real expedition & campaign map

**Files:** `data/zones/`, `scenes/ui/WorldAtlas.tscn`, `scripts/world/world_state.gd`, `scripts/world/zone_transition.gd`, `scripts/world/quest_director.gd`. Complete six zones in art bible, starting with Founders and Copperwild. Each zone needs 8–12 discoveries, 2 major missions, 4 optional experiments, 1 race/vehicle challenge and 1 visible settlement upgrade. Implement budgeted loaded-zone streaming and distant impostors. Travel options: on foot, physical rover and fast travel unlocked by repairing infrastructure. Preserve state across zone transitions. **Acceptance:** quest state serialization, isolated streaming tests, several-hour travel reliability and Pi memory stability, no long blocking stutter on zone enter.

## Workstream 08 — engineering RPG, local economy & meaningful empire

**Modules:** `scripts/economy/inventory_ledger.gd`, `production_graph.gd`, `settlement_state.gd`, `trade_route.gd`, `scripts/rpg/skill_mastery.gd`. Add eight skill ranks but never gate basic physical problem solving. Use event-driven producers and consumers: water mill -> mechanical power -> bakery; orchard -> food -> market; salvage -> metal -> foundry; stone quarry -> bridge. Route goods using logistics cost, capacity and travel delay; use aggregated calculations for offscreen settlements. Visualize infrastructure state in-world (machines moving, workers arriving, stores filled) and overlay only when requested. Build a first settlement district with at least 6 unique functional structures and 3 community improvement projects. **Acceptance:** each upgrade visibly changes world and simulation, economy never produces items from nothing without labelled fantasy source, save/load consistent over 1000 ticks, Pi only simulates local active actors physically.

## Workstream 09 — racing / challenges / replay

**Tracks:** Valley Sprint, Stonehill Climb, Ember Spiral, Cargo Relay, Water Crossing and Player Designed Circuit. Checkpoint graph prevents cutting course. A ghost recording stores input/position samples plus version and machine hash; if engine version causes nondeterminism, label ghost as approximate rather than deterministic. Race screen shows time, smooth split delta and physical tradeoffs. Build race editor using spline/control-point assets with bank/rise/guard-rail, and protect against self-intersection. **Acceptance:** 3 validated tracks by gameplay alpha, vehicle classes meaningfully differ, trial times stable within tolerance, no online leaderboard, optional shared-device local records.

## Workstream 10 — learning systems, ORBIT and journal

**Modules:** `data/lessons/*.json`, `scripts/education/concept_registry.gd`, `scripts/education/simulation_assumptions.gd`, `scripts/education/journal.gd`, `scripts/ai/orbit_bridge.gd`, `scenes/ui/FieldJournal.tscn`. Build lesson-linked interactions that support predict -> simulate -> revise. Bind event telemetry to transparent measurements, store units and solver version. Journal entries have hypothesis, procedure, observation, comparison, conclusion, model assumptions, screenshot and optional actual-world result; never auto-fill experimental result. Local AI integration should be **optional**; use the existing verified localhost-only ORBIT service via an explicit permissioned protocol with no arbitrary filesystem/shell/tool actions. On Pi AI might pause while 3D world is active, queue one operation and restore frame responsiveness; use fixed small models and a staged benchmark to determine feasibility. Model acts as guide, not game director. **Acceptance:** full playability without AI; replay the lesson with recorded telemetry, no fabricated measurements and per-user privacy intact.

## Workstream 11 — AAA-quality interaction polishing

**Deliverables:** polished player model and complete animation tree, contextual hand/tool IK, tactile part audio, foliage movement, responsive world map, color-safe status icons, help overlay and settings. Add photo mode with collision-free camera and quality selection. Instrument time-to-first-build, navigation error counts and key prompt impressions locally, without telemetry transmission. Achieve stable UI at 720p and 1080p, full controller path, remappable controls, readable quest text at TV distance. **Acceptance:** usability sessions by at least 5 testers with no author coaching, no critical navigation errors, all essential feedback multimodal.

## Workstream 12 — cross-platform export and optimization

**Primary development:** Windows/Linux/macOS desktop, quality Creator/Ultra. **Minimum:** Pi 4B 4GB quality Explorer. Use separate `export_presets.cfg` with real Godot-export template matches, not unverified placeholder export bundles. Windows needs signed or unsigned executable with SmartScreen disclosure; macOS requires code-signing/notarization before claiming frictionless distribution; Linux includes tested dependencies and glibc baseline. ARM64 Pi may use compatible Godot export templates or a custom export build; verify rather than guess. Run Explorer/Creator/Ultra in CI where possible, then actual board in lab. See `PI4_PERFORMANCE.md` for budget proposals and model tiers.

## Workstream 13 — publish and maintain

Create GitHub `release/*` branch only when tests pass; label `v0.2-alpha`, `v0.3-beta`, etc., not “final” while missing mechanics. Deliver asset provenance, credits, performance tables, user instructions, developer quickstart, schema migration and reversal guides. Include screenshots captured by actual Godot binary with renderer metadata. Do not put copyrighted third-party textures or model weights into Git unless rights and distribution terms are explicit. Always preserve user projects across updates.

---

## Coding agent execution prompts (copy individually)

### Prompt A — verify the baseline

> Open the current WonderForge Godot repository. Read all docs listed in `AGENT_BUILD_PLAYBOOK.md`. Determine the exact installed Godot stable version and runnable export templates. Import scenes headlessly, fix any parse or runtime failures without changing intended behavior. Run the scene interactively and capture a verified screenshot. Write `artifacts/baseline/report.md` with commands, logs, limitations and next blocking issues. Run checks, commit, and continue only when every baseline acceptance criterion is met. Never claim Pi verification from desktop tests.

### Prompt B — finish the first real machine editor

> Implement Workstreams 02 and 03 in small commits. Make `MachineGraph` the persistent canonical model, with stable IDs, typed connectors and tested serialization. Build a production-ready spatial snap editor including ghost previews, rotation, 100-step undo/redo and controller menu. Keep existing saves migratable. Add at least 30 manually inspected editable part assets with provenance. Demonstrate a user snapping a wheel to a chassis and solving an invalid connector error. Capture frame and input traces; use the QA matrix before marking complete.

### Prompt C — add fully functional engineering physics

> Implement Workstreams 04 and 05. Use documented physics engine APIs, test known reference problems, and expose measurement assumptions. Make a rover assemble from `MachineGraph`, drive a slalom and hill, show tire slip, and save the assembly. Ensure physics collision and visible assembly use identical transforms. Benchmark at Explorer, Creator and Ultra tier. Do not replace physics with animation or claim engineering accuracy beyond validated constraints.

### Prompt D — build the cinematic hero region

> Following the Art Bible scene descriptions and palette, replace the blockout Founders' Valley with polished original PBR art, correct pivots and LODs. Source or create assets with reproducible licenses; preserve exact collision, player movement and part snap transforms. Capture 16:9 in-engine screenshots at consistent camera locations for PC and Pi quality levels, and compare against approved concept images. Use a deliberately excellent, authored composition rather than a generic asset dump.

### Prompt E — build a shippable end-to-end chapter

> Implement the 15-minute playable opening sequence from the Master Game Design: workshop intro, connect a vehicle, run a test, reach a broken bridge, revise a machine, record evidence, and restore settlement traffic. Both alternate solutions work. No hard-coded cutscene is mandatory. Tie state to schema-versioned saves with recovery. Conduct five-person usability testing and document observed confusion; iterate until novice success criteria pass.

### Prompt F — cross-platform release verification

> Prepare separate Explorer/Creator/Ultra builds from the same gameplay sources. Test on Windows/Linux/macOS where supported; run an actual Pi 4B 4GB with Compatibility renderer and two Linux accounts. Capture sustained render/physics CPU, memory and thermal readings, save/load integrity and graphics screenshots. Record exact hardware/software versions. If any Pi gate fails, simplify cosmetic LOD, optimize materials and cap local assemblies; do not remove basic workshop gameplay. Declare only verified platforms supported.

## Quality-of-implementation template for EVERY ticket

- **Ticket and player promise:** exactly what user can now do that they could not do before.
- **Files touched:** scenes, scripts, data, tests, assets; include authored asset licenses.
- **Functional acceptance:** objective inputs, expected outcomes, failure paths, persistence and unit constraints.
- **Aesthetic acceptance:** reference render, palette, material detail, camera framing, feedback animation, text readability.
- **Performance:** machines/parts/instances under test, renderer, resolution, p50/p95 frame time and memory snapshots.
- **Compatibility:** Windows Creator, Linux Creator, Windows Ultra, Pi Explorer; unsupported states explicit.
- **Security/privacy:** profile access, user input validation, local-only network, save serialization, AI boundaries.
- **Evidence:** reproducible commands, logs, in-engine screenshots/video, test results; explicitly mark missing evidence.
- **Rollback:** how to restore previously saved worlds, config and release assets.

Any agent claiming a milestone complete without this report has not fulfilled the contract.



---

# PART 4: CROSS-PLATFORM TECHNICAL ARCHITECTURE

# Architecture — PC-led art, Pi-minimum capability

**Technical decisions:** Godot stable GDScript, separate physical simulation and render presentation, authoring master scenes and tier derivatives, deterministic quest state and bounded local AI. Build from the vertical slice outward. Target Windows, Linux and macOS desktops plus ARM64 Raspberry Pi OS where actually certified.

## Renderer abstraction and material fallback

Create `res://data/quality/presets/*.tres` for Explorer, Creator and Ultra. `QualityManager` reads command line, persisted user preference and measured capabilities, then selects visual visibility ranges, vegetation LOD, mesh/material variant and shadow/particle budgets. **Renderer itself must be chosen at process start**. PC Ultra runs Forward+ if supported and verified. Pi uses Compatibility and static/baked effects. Every PBR material should have both quality variants mapped in manifest; never require unsupported shader features to see a collision-critical socket. At runtime, failed advanced shader should switch to a validated fallback material, not invisible geometry.

## Layer rules

`GameDomain` saves only pure data (quest state, economy, graph, profile ID). `GameWorld` produces transient nodes and physics bodies. `GameView` binds geometry/animation/UI to domain events. `AIService` offers optional offline explanation via a separate supervised process. `PlatformHost` handles OS paths, display settings and approved external tool launches. Godot should **not** launch arbitrary shell commands proposed by AI, and cannot assume the previous Python portal is already running.

The **machine graph** serializes part definitions and connector edges, and is consumed by physics and rendering. No ownership cycle between scene nodes and game data. Tests should operate on domain graph without needing GPU. This allows a saved machine to be opened on Pi with lower visual LOD while retaining connectivity and material mass. Use fixed physics ticks and record solver version in experiment logs.

## Family profiles

Separate profile saves using the platform's per-user secure data directory. When using shared Pi Linux accounts, OS home permissions separate files; a deliberately shared blueprint directory is the only exchange route. Desktop family mode may offer profile selection, but that is **not** secure child account separation. Shared blueprints are copied via explicit action; always prompt before overwriting. Local AI conversation logs are private and opt-in, with clear deletion controls.

## Cross-platform build targets

| Platform | Native exports | Renderer | Status in this source bundle |
|---|---|---|---|
| Windows x86_64 | Godot Windows templates | Forward+ / Compatibility | Source target; no export binary included |
| Linux x86_64 | Godot Linux templates | Forward+ / Compatibility | Source target; no export binary included |
| macOS x86_64 / arm64 | Godot macOS templates | Metal backend / Compatibility | Planned, unverified |
| Raspberry Pi 4B arm64, 4GB | ARM64-compatible Godot build/export | Compatibility | Minimum target, unverified hardware |

**Conformance principle:** account security and graphics tiers are distinct. A high-end gaming PC can run the best renderer, highest LOD, widest physics budget and larger local AI while a Pi uses lower budgets; neither may receive different core campaign rewards, rules or save semantics.



---

# PART 5: HARDWARE AND PERFORMANCE STRATEGY

# Cross-platform renderer and simulation strategy

**Priority:** PC-quality art authoring with measurable scalability. **Certified minimum (future gate):** Raspberry Pi 4B 4GB. Raspberry Pi viability is **not** established until tested on physical hardware. Compatibility mode should be the Pi default; modern PCs may use Mobile or Forward+ where export/render requirements permit. See official Godot 3D performance, renderer and resolution-scaling documentation linked below.

## Three quality profiles: what changes and what never changes

| Feature | Explorer / Pi minimum | Creator / midrange | Ultra / gaming PC |
|---|---|---|---|
| Renderer | GL Compatibility | GL Compatibility or Mobile after testing | Forward+ if supported |
| Render target | 1280×720, adjustable scale | 1920×1080 | 2560×1440 / 3840×2160 optional |
| Trial frame goal | 30FPS sustained, 33.3ms frame | 60FPS, 16.7ms | 60+FPS, measured |
| Scene terrain subdivisions | 56 in demo | 82 in demo | 116 in demo |
| Visible tree instance sample | 110 in demo | 300 in demo | 600 in demo |
| Camera far limit | 165m | 320m | 450m |
| Shadows | Off/limited in demo | On | On, improved quality later |
| AI | Disabled during critical physics; optional tiny local model | Model optional via local CPU/GPU | Optional larger private model |
| Audio channels | budgeted | standard | high |
| Part count / active joints | budgeted after measurement | moderate | extended |
| Quest flags, saves, economy | **identical** | **identical** | **identical** |
| Part rules and physical units | **identical** | **identical** | **identical** |

**Critical:** current vertical slice chooses an aesthetic profile using `scripts/quality_profiles.gd`; future production should distinguish `VisualProfile`, `SimulationBudget` and `AccessibilityProfile`. The numeric demo presets are not proof of the FPS targets. Do **not** save quality profile into persistent world save. Graphics quality cannot silently change the blueprint's physical meaning; only number of simultaneously active rigid bodies and update frequency of distant actors may change, with documented simulation approximation.

## Recommended memory budgets (targets, not measurements)

For Explorer Pi4, aim for **peak resident game memory under 1.5GB**, leaving substantial system memory for Raspberry Pi OS and background services; initial engineering target 0.8–1.2GB. Allow world chunk meshes ~250MB, texture uploads ~300MB, engine/physics ~350MB, UI/audio/logic ~150MB, streaming buffer ~200MB—these are engineering hypotheses, not OS-provided caps. Chrome/desktop/optional local AI must be profiled separately. Disable local model while heavy physics trials run unless actual stress data justifies concurrent execution.

**GPU strategies:** MultiMesh vegetation, atlas textures, shared shader materials, baked static lighting, limited transparency, distance impostors, visibility range and occlusion culling where supported; avoid excessive shadow maps and dynamic reflections. Draw calls alone don't guarantee performance; measure GPU frame time, overdraw and shader cost. Use texture mipmaps and GLES/GL-friendly compressed formats; avoid 4K textures on Pi. Keep collision meshes simpler than visible meshes and use convex shapes for dynamics. Partition physics by local interest; never allow 500 unconstrained active parts by default on Pi.

**CPU strategies:** run world economy in coarse event ticks; procedural terrain generation off critical frame with precomputed caches; reduce NPC animation frequency by distance; throttle pathfinding and raycasts; use spatial hash for build snaps; never rebuild all instances on each mouse move. Run Godot profiler over multiple minutes with same scene and exact test inputs. Record p50 and p95 frame times, worst-stall durations and thermal throttling.

**Scaling rule:** if Explorer tier cannot sustain measured performance, reduce visual draw distance, effect counts, vegetation density, LoD triangle density and render resolution before changing gameplay. Keep target FPS and frame-time labels honest. Cross-platform save and machine graph hash must remain invariant. If physics machine complexity exceeds tier budget, warn with exact count and offer a “test in smaller groups” or batch-simulation mode; don't silently remove joints or fake results.

## Platform matrix

- **Windows 10/11 x64:** Creator and Ultra, native Godot export, keyboard/mouse and controllers. Run Direct3D/Vulkan renderer checks as applicable.
- **Linux x86_64:** Creator and Ultra, native export, validate supported GL/Vulkan drivers. Steam Deck can be benchmarked later.
- **macOS Intel/Apple Silicon:** supported after export templates, code-signing/notarization and Apple GPU/API checks pass, not by assumption.
- **Raspberry Pi OS 64-bit aarch64 / Pi4B 4GB:** Explorer target. Needs ARM64 export template/runtime compatible with OS, OpenGL ES/driver version, audio/controller testing, memory/thermal data and safe installation. May require an ARM64 build of Godot rather than the desktop editor.

## Suggested launch/runtime commands

At project root: `godot --path . --editor` (desktop development), `godot --headless --path . --editor --quit` (parse/import smoke), `godot --path . -- --quality=explorer` (runtime quality test). On compatible gaming PC, use `godot --rendering-method forward_plus --path . -- --quality=ultra` after renderer support is verified. On Pi: use the Compatibility renderer and `--quality=explorer`. The renderer is an **engine startup choice**; switch requires restart. The scripts under `launchers/` provide editable helpers. The project defaults to Compatibility so it opens on lower-end hardware, not because PC Ultra graphics should remain restricted to Compatibility forever.

## Acceptance test track

1. Record exact Pi hardware revision, RAM, OS codename/kernel, graphics driver, Godot commit/version, renderer, memory swap and power supply.
2. Create `Pi4-30min-route` deterministic run: boot, load game, open workshop, place 20 parts, test rover, drive 2km, transition zones, save, reload, quit.
3. Capture frame timings, CPU, RAM, swap, GPU memory/driver indicators, temperature, throttling flag, loader stalls and disk writes. Repeat after a fresh boot and after 30 minutes warm runtime.
4. Compare on reference PC with same save and settings except tier; confirm quests, materials, part IDs and machine topology are unchanged. Verify screenshot visual readability, even when distant detail is reduced.
5. Test thermal and low-voltage behavior without using aggressive overclocking. Fail if data corrupts or input becomes unusable. Tune graphics/physics until measured stable experience, and publish actual percentile figures.

## Official references

- Godot renderers: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Performance: https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html
- Resolution scaling: https://docs.godotengine.org/en/stable/tutorials/3d/resolution_scaling.html
- Hardware/system requirements: https://docs.godotengine.org/en/stable/about/system_requirements.html
- Multi-resolution: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html



---

# PART 6: QA AND RELEASE ACCEPTANCE

# WonderForge Genesis — verification and release gates

**This document is a rigorous contract, not a retrospective claim that the game has already passed these checks.** Execute every test against an actual Godot binary. When a criterion is untested, record **NOT RUN**, never PASS. For Pi hardware, collect real-device logs, not PC estimates.

## 1. Baseline testing matrix

| Code | Action | Expected result | Failure definition |
|---|---|---|---|
| B01 | Import `project.godot` with Godot 4.7.x stable | No missing resources or class failures | Any script parser/import error |
| B02 | Run `scenes/Main.tscn` 5 minutes | Valley visible, camera follows player, no exceptions | Crash, black screen, missing input |
| B03 | WASD, Shift, Space, orbit RMB+mouse | Responsive relative to camera; jump lands on world | Stuck controls, camera clipping, falling through |
| B04 | Press F1 then interact | Help screen hides without gameplay freeze | Tooltip/UI blocks intended controls |
| B05 | Approach workshop beacon, press E | Discovery reward and quest progress | No response, repeated reward exploit |
| B06 | Press B, select parts 1–6, press Q | Ghost part/rotation changes, no jitter | Wrong part/axis, invisible ghost |
| B07 | Place three parts, check resource cost | Cost exactly once and progress milestone | Inventory becomes negative or duplicates |
| B08 | Press E near rover, drive, brake, exit | Can enter, drive and safely leave | Player stuck, rover explosive force |
| B09 | F5 save, restart F9 load | Same progress, parts, player coordinate | Invalid data or silent overwrite |
| B10 | Corrupt save JSON, attempt F9 | Helpful error and no destructive state change | Crash, partial import, arbitrary file access |
| B11 | Launch with `--quality=explorer` | Explorer visual budget selected | Different quest/save results |
| B12 | Launch with `--quality=ultra` on capable PC | Ultra budget selected | Missing scenes, crash due to unsupported renderer |
| B13 | Resize window 1280x720 ↔ 1920x1080 | UI usable; no obscured critical inputs | HUD offscreen, unreadable text |
| B14 | Complete Act I | Clear chapter completion message, next options | Unclear goals, softlock |

**The current project does not yet implement all production flows.** Basic interaction code exists; Godot runtime confirmation is pending in this environment. Baseline test entries must be filled by a person or local coding agent who actually launches the engine.

## 2. Machine graph / construction system contracts

- Snapshot serializer: round-trip 10,000 randomly generated valid graphs up to tier part cap and compare stable graph ID, part transforms, connection topology and material settings.
- Reject: missing schema, malformed UUID, duplicate part ID, NaN/Infinity, oversized numbers, unknown connector class, references to unapproved external file paths, cyclic ownership pointers, count > limit, resource underflow.
- Snap geometry: socket A coincides with socket B within 1mm after transform; inconsistent orientation triggers user-facing explanation.
- Undo: 100-part placement/rotation/delete sequence, undo all, redo all, verify inventory and serialized hash identical.
- Physics: test supported vs unsupported beam, hinge limits, compound mass center, wheel slip changing with friction, collision contact and fixed timestep sensitivity.
- Performance: record max joints, contact pairs, solver milliseconds and average FPS under three tiers; fail Pi profile on actual frame-time evidence, not presumed ability.

## 3. World/quest/economy contracts

- Fresh save start, follow complete 15-minute chapter without external knowledge; five distinct novice users and median time to first working machine recorded.
- Complete bridge via physical span; then complete same quest through alternate service road; both should unlock narrative without contradictory flags.
- Leave zone in middle of mission; return via fast travel; resume without re-awarding resources.
- Settlement production ledger: no negative stock, mass/unit conservation where relevant; simulate 1000 offscreen ticks then reenter visually updated settlement.
- Save game from Windows Creator profile, load on Linux Explorer and PC Ultra; same quest/machine hash and economy state, allowing only documented numerical physics approximations.
- Damaged file: restore most recent valid backup; no silent overwrite of a newer valid save.

## 4. Educational integrity and safety

- Every numerical model has reference values and explicit units, assumptions and solver version. Reject outputs with nonsensical physical domain (negative mass, infinity, friction coefficient outside configured range).
- The game never calls a simulation result a guaranteed real-world outcome. Children must still perform observation and interpretation; ORBIT cannot write fictional observations into journal.
- An incorrect prediction yields a useful explanatory comparison; avoid generic "wrong" / grade-shame messages.
- Adult guidance appears with real tools/electricity/heat projects; no unsafe live-mains experiments in the built-in curriculum.
- Offline play succeeds with network disabled and no model. Internet connectivity is opt-in and irrelevant to core narrative.

## 5. Accessibility and UX acceptance

- Keyboard and mouse can complete every mandatory mission. Controller can select/menu/build/race with no pointer requirement. Rebinding and sensitivity controls persist.
- Use UI scale at 100%, 125%, 150%; essential text remains readable on 720p and standard TV viewing distance. Colorblind mode uses shape/icon and label.
- Reduced motion removes camera shake, head bob, repetitive flashing and heavy motion blur. Autopilot or simpler steering is labelled as assist and never changes scientific truth.
- Test at least 5 uncoached users: record first successful snap, number of invalid placements, time to navigate to Journal, success entering/exiting rover, success identifying current mission objective. Iterate on observed errors.
- No opt-out dark patterns, streak losses or pressure prompts. All save/export data can be deleted locally by the adult.

## 6. Pi4 minimum acceptance protocol

**Pi minimum hardware:** Raspberry Pi 4B 4GB (not a Pi5, no experimental overclock required). Document exact revision, OS release, driver, engine and compatible renderer. **Test all of:** boot/launch, 720p 30 FPS design goal, camera feel, construction with active physics, rover trial, at least one biome transition, save and restore, two separate user accounts, graceful exit, safe disk writes under low-storage, long warm run and temperature/throttling metrics. A Pi test cannot be simulated by constraining a gaming PC's resolution. Include screenshots and raw profiler logs of actual device. **Not-run is acceptable; invented success is not.**

## 7. Desktop high quality validation

**Windows** supported when native export runs on reference 1080p/1440p hardware. **Linux** when native export runs without editor and physics/audio work. **macOS** after signed/notarized release and tested Apple GPU paths. **Ultra** when final PBR hero scenes, advanced light settings, LOD transitions and stable 60+ FPS are measured on a documented reference gaming PC. A PC render screenshot is part of evidence, not proof of playability by itself.

## 8. Automated smoke commands and evidence

```bash
# From Godot game project root; requires official Godot executable installed.
godot --headless --path . --editor --quit
# Opens game on desktop (human interaction required for gameplay verification).
godot --path . -- --quality=creator
# Optional system smoke checks for JSON/art pack and source contracts.
python3 tools/validate_project.py
```

Continuous integration can run headless import and `tools/validate_project.py` even without a GPU. Do not call a headless smoke test a full runthrough of vehicle physics or UI. Publish `qa/<date>/` with engine version, CLI, log excerpts, full test matrix, captures and blockers. Until engine binary is available and scenes parse successfully, current runtime gate is `NOT RUN`.



---

# PART 7: CONCEPT IMAGE PROMPTS

# Original art concept prompt library

Use these as scene-direction prompts for concept exploration. Create original art, not imitations of named proprietary games. Save positive/negative prompts, seed, workflow, model-license and final reviewer verdict alongside exported reference images. Concept images are NOT Godot playable level geometry.

## Hero World — Founders' Valley

**Positive:** Original premium cross-platform fantasy engineering adventure environment, extraordinarily designed hand-crafted limestone maker town spanning a dramatic river gorge, large copper suspension bridge with realistic tension cables, glass workshop roofs, hanging gardens and flowing mechanical waterwheels, believable intricate tools and gears, distant white cliff citadel among teal-cloud floating islands, huge layered rock cliffs and broad waterfall, late golden-hour sunlight striking pale stone and copper, cool turquoise reflected sky, cinematic volumetric aerial depth, physically credible structural construction, harmonious ecological terrain, beautifully authored place for a character to explore at human scale, 16:9 3/4 elevated view, AAA game environment concept, detailed atmospheric 3D-ready composition, clear road and path silhouette. **Negative:** default cube meshes, low-poly placeholder box character, empty lawn, flat dashboard UI, text, logo, trademark figure, arbitrary glowing objects, giant illegible gadgets, over-saturation, impossible gear meshing, AI artifacts, untraversable road.

## Workshop / machine design

**Positive:** Interior of grand open-air invention workshop built from pale limestone and warm-weathered copper, mechanically credible transmission belts, meshing brass gears, timber worktables, portable blueprints, custom compact four-wheel rover whose wheel hubs, bearings, drive shafts and fasteners are visible at realistic scale, polished shop-worn steel, cloth banners, warm shafts of afternoon sunlight, engaging reachable part displays, cinematic wide 16:9 gameplay composition, space for player and camera, hard-surface art reference, accurate manufacturing details. **Negative:** paper-thin suspension, floating shafts, disproportionate player scale, arbitrary neon glow, UI, text, indistinguishable machine pieces.

## Vehicle exploded sheet

**Positive:** Original all-terrain compact invention rover, three-quarter perspective and four clean orthographic views, off-road rubber tread, copper-blue metal tubular chassis, four independent suspensions, 48V fictional safe demonstrator power pack, visible gearbox, realistic battery enclosure and secured wiring harness, labelled by number placeholders WITHOUT rendered words, neat exploded parts over neutral backdrop, realistic pivots/joints with consistent dimensions, premium product-visualization lighting, PBR material reference. **Negative:** impossible joints, glass wheels, floating axles, copied real automotive brand, intricate detail that hides part sockets, stylized blocky toy silhouette.

## Sky citadel wide key art

**Positive:** Immense floating limestone cliffs with elegant copper bridges, cable cars, suspended botanical glasshouses, physically grounded engineer's glider, giant astronomical orrery rings anchored to stone towers, soft billowing clouds and ocean of sky, warm ivory sunlight with cool pale cyan shadows, naturalistic brush-and-3D blended high production value environment concept, wide 16:9 camera with foreground stone balustrade and human scale marker, traversable atmospheric lanes, spectacular 3D game level design. **Negative:** generic space station, incoherent floating machinery, illegible architecture, video game HUD.

## Copperwild waterworks

**Positive:** Red sandstone canyon, lush irrigated terrace farms, enormous working wooden waterwheel connected through copper shaft and gear transmission to flour mill, visible river flow, plausible aqueduct and locks, white limestone storage buildings, dusty sunbeams, worn engineering tools, intricate winding paths for rover, painterly realistic 3D game environment keyframe, camera looking diagonally across machinery and canyon, 16:9. **Negative:** dry wheel spinning without water, random pipes with no endpoints, text, low-poly blocks, silly physics.

## Crystal Deep

**Positive:** Vast underground basalt-column cathedral with richly layered stratigraphy and wet stone, deep still aquifer, sparse blue-green lichen luminescence, immense realistic rope cart bridge, old excavated mining lifts, small human miner establishing scale, distant single pale sun shaft, cinematic natural darkness and reflected moisture, scientifically credible mineral groupings with separate fictional luminous crystal deposits, immersive exploration and geology mission environment. **Negative:** entire cave made of RGB neon gemstones, featureless tunnel, random magic symbols, text overlays, copied media character.

## Verdant Circuit

**Positive:** Elevated moss-covered forest research city with timber walkways, practical greenhouses, solar roof panels, water pumps and irrigation channels, huge ancient trees, afternoon sun through leaves, functional environmental engineering, wildlife habitat respectful construction, photographic material detail and art-directed composition, wide scenic 3D adventure game level key art, accurate hardware scale. **Negative:** simplistic green low-poly cylinders, fluorescent fog, arbitrary fantasy machinery, UI.

## Ember Frontier proving grounds

**Positive:** Professional modular invention racecourse built into red-desert canyon landscape, banked dirt track, mechanical starting gate, artistically memorable copper grandstands, long vistas, rugged customized rover cresting a hill with physically plausible suspension compression and contact dust, nearby maker settlement, premium cinematic gameplay concept, golden-hour lighting, deep burnt orange rock, clear racing route. **Negative:** copied branded car, floating vehicle, purposeless looping race road, illegible hazard markings, text.

