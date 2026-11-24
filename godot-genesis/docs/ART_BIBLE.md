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
