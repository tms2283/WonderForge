extends Node3D
## Main playable native loop for the Aether Valley vertical slice.
## No HTML/JS. Integrates traversal, interactive missions, building, driving and ORBIT.

const QUEST_PATH := "res://data/quests.json"
const REGIONS := {"forge": "Foundry Square", "workshop": "The Grand Atelier", "race": "Copperleaf Circuit", "forest": "Mosswood Forest", "crystal": "Crystal Deep", "wind": "Windward Reach", "observatory": "Clockwork Heights"}

var world: WFWorldForge
var avatar: WFAvatar
var build: WFBuildSystem
var rover: WFRover
var ui: WFHUD
var workshop_camera: Camera3D
var build_mode: bool = false
var driving: bool = false
var visited: Dictionary = {}
var quest_catalog: Array = []
var race_gates: Array[Vector3] = []
var race_gate: int = 0
var race_time: float = 0.0
var race_finished: bool = false
var has_driven: bool = false
var autosave_seconds: float = 0.0
var current_region: String = "forge"
var proximity: String = ""

func _ready() -> void:
    _environment()
    world = WFWorldForge.new()
    add_child(world)
    _read_quests()
    _create_npcs_and_quest_markers()
    build = WFBuildSystem.new()
    add_child(build)
    build.feedback.connect(_notify)
    build.changed.connect(_on_build_changed)
    avatar = WFAvatar.new()
    avatar.position = GameState.last_location
    if avatar.position.y < 1.3:
        avatar.position.y = 2.0
    add_child(avatar)
    rover = WFRover.new()
    rover.position = WFWorldForge.TRACK_CENTER + Vector3(WFWorldForge.TRACK_RADIUS, 2.5, 0)
    add_child(rover)
    rover.configure_blueprint(build.stats())
    rover.speed_changed.connect(_on_speed)
    workshop_camera = Camera3D.new()
    workshop_camera.name = "PrecisionFabricationCamera"
    workshop_camera.fov = 57
    workshop_camera.position = WFBuildSystem.ORIGIN + Vector3(23, 23, 25)
    add_child(workshop_camera)
    workshop_camera.look_at(WFBuildSystem.ORIGIN + Vector3(0, 2, 0))
    workshop_camera.current = false
    ui = WFHUD.new()
    ui.setup(self)
    add_child(ui)
    ui.quest_action.connect(_complete_quest)
    ui.build_requested.connect(_toggle_build)
    ui.garage_requested.connect(_toggle_drive)
    ui.set_build_mode(false)
    _create_race_gates()
    ui.show_note("WELCOME TO THE AETHER VALLEY", "You have arrived at the Grand Atelier.\n\nFind a glowing commission beacon. Walk to it and press E to meet the valley's inventors. Press B to open your fabrication table, and V to try a machine on the Copperleaf raceway.\n\nThe first challenge is to make something useful.\n\nW A S D   WALK     E   TALK     B   BUILD     V   DRIVE     J   QUESTS     O   ORBIT")

func _environment() -> void:
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color("4e829c")
    sky_material.sky_horizon_color = Color("bcd1c2")
    sky_material.ground_bottom_color = Color("5a6763")
    sky_material.ground_horizon_color = Color("c2b99a")
    sky_material.sun_angle_max = 27.0
    var sky := Sky.new()
    sky.sky_material = sky_material
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_energy = 0.60
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.tonemap_exposure = 1.04
    env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
    var environment := WorldEnvironment.new()
    environment.environment = env
    add_child(environment)
    var sun := DirectionalLight3D.new()
    sun.name = "EveningSun"
    sun.rotation_degrees = Vector3(-42, 32, 0)
    sun.light_color = Color("ffe1b3")
    sun.light_energy = 1.65
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 85
    add_child(sun)
    var fill := DirectionalLight3D.new()
    fill.name = "BlueSkyFill"
    fill.rotation_degrees = Vector3(-23, -130, 0)
    fill.light_color = Color("a5cddd")
    fill.light_energy = 0.25
    fill.shadow_enabled = false
    add_child(fill)

func _read_quests() -> void:
    var raw: String = FileAccess.get_file_as_string(QUEST_PATH)
    var data: Variant = JSON.parse_string(raw)
    if data is Dictionary:
        var items: Variant = data.get("quests", [])
        if items is Array:
            quest_catalog = items

func _create_npcs_and_quest_markers() -> void:
    var npc_positions := {
        "forge": Vector3(-10, 0, -11),
        "workshop": Vector3(-28, 0, 13),
        "race": Vector3(26, 0, 25),
        "forest": Vector3(-57, 0, 23),
        "crystal": Vector3(-65, 0, -61),
        "wind": Vector3(65, 0, 59),
        "observatory": Vector3(63, 0, -61)
    }
    for key in npc_positions.keys():
        var p: Vector3 = npc_positions[key]
        p.y = world.terrain_height(p.x, p.z)
        _npc(str(key), p)

func _npc(region: String, pos: Vector3) -> void:
    var npc := Node3D.new()
    npc.name = "NPC_" + region
    npc.position = pos
    add_child(npc)
    var cloth: Color = {"forge": Color("c27651"), "race": Color("5c9b91"), "forest": Color("6c9460"),
                        "crystal": Color("9f7fbe"), "wind": Color("abb973"), "observatory": Color("658fa9")}.get(region, Color("b48964"))
    var coat := StandardMaterial3D.new()
    coat.albedo_color = cloth
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color("d9a47b")
    WFPartFactory.box(npc, Vector3(0.90, 1.26, 0.51), Vector3(0, 1.32, 0), coat)
    var head := SphereMesh.new()
    head.radius = 0.39
    head.height = 0.74
    WFPartFactory.add_shape(npc, head, Vector3(0, 2.33, 0), skin)
    WFPartFactory.box(npc, Vector3(1.12, 0.16, 0.78), Vector3(0, 2.72, 0), WFPartFactory.material_for("copper"))
    WFPartFactory.box(npc, Vector3(0.69, 0.23, 0.62), Vector3(0, 2.91, 0), WFPartFactory.material_for("timber"))
    var ring := TorusMesh.new()
    ring.inner_radius = 0.62
    ring.outer_radius = 0.77
    var halo_mat := StandardMaterial3D.new()
    halo_mat.albedo_color = Color("a5e5c1")
    halo_mat.emission_enabled = true
    halo_mat.emission = Color("a5e5c1")
    halo_mat.emission_energy_multiplier = 1.1
    WFPartFactory.add_shape(npc, ring, Vector3(0, 3.32, 0), halo_mat)

func _create_race_gates() -> void:
    var gold := StandardMaterial3D.new()
    gold.albedo_color = Color("e9c07a")
    gold.metallic = 0.44
    var mint := StandardMaterial3D.new()
    mint.albedo_color = Color("7ad6b6")
    mint.emission_enabled = true
    mint.emission = Color("7ad6b6")
    for i in range(8):
        var angle := -TAU * float(i + 1) / 8.0
        var pos := WFWorldForge.TRACK_CENTER + Vector3(cos(angle) * WFWorldForge.TRACK_RADIUS, 0, sin(angle) * WFWorldForge.TRACK_RADIUS)
        race_gates.append(pos)
        var gate := Node3D.new()
        gate.name = "RaceGate_%d" % (i + 1)
        gate.position = pos
        gate.rotation.y = angle
        add_child(gate)
        WFPartFactory.box(gate, Vector3(0.24, 5.2, 0.24), Vector3(-2.7, 2.6, 0), gold)
        WFPartFactory.box(gate, Vector3(0.24, 5.2, 0.24), Vector3(2.7, 2.6, 0), gold)
        WFPartFactory.box(gate, Vector3(5.6, 0.35, 0.33), Vector3(0, 5.2, 0), mint)

func _process(_delta: float) -> void:
    if build_mode and not ui.panel_open():
        build.update_pointer(workshop_camera, get_viewport().get_mouse_position())
    if driving:
        return
    _update_proximity()

func _physics_process(delta: float) -> void:
    autosave_seconds += delta
    if autosave_seconds > 75.0:
        autosave_seconds = 0.0
        if not driving and not build_mode:
            GameState.last_location = avatar.global_position
        GameState.save_game()
    if driving:
        race_time += delta
        if race_gate < race_gates.size() and rover.global_position.distance_to(race_gates[race_gate]) < 5.5:
            race_gate += 1
            if race_gate < race_gates.size():
                ui.flash("CHECKPOINT  %d / %d  •  %.1f s" % [race_gate, race_gates.size(), race_time])
            else:
                race_finished = true
                if GameState.total_race_best <= 0 or race_time < GameState.total_race_best:
                    GameState.total_race_best = race_time
                ui.show_note("COPPERLEAF RACEWAY / FULL LAP!", "Lap time: %.1f seconds.\n\nNow ask: which part of the design mattered most, and what did you actually change?\n\nThe teaching rover is not a certified vehicle physics model.\n\nReturn to Tala to claim your commission." % race_time)
                GameState.save_game()

func _update_proximity() -> void:
    var nearest: String = ""
    var nearest_distance: float = 10000.0
    for key in world.landmark_positions.keys():
        var pos: Vector3 = world.landmark_positions[key]
        if str(key) == "forge":
            pos = Vector3(-10, 0, -11)
        elif str(key) == "workshop":
            pos = Vector3(-28, 0, 13)
        var d: float = avatar.global_position.distance_to(pos)
        if d < nearest_distance:
            nearest_distance = d
            nearest = str(key)
    proximity = nearest if nearest_distance < 7 else ""
    if proximity != "":
        ui.set_context("E / TALK TO INVENTOR   ·   %s  ·  %.1f m" % [REGIONS.get(proximity, proximity), nearest_distance])
    else:
        ui.set_context("Explore the valley  •  Talk to inventors at luminous markers  •  B to fabricate  •  V to drive")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if ui.panel_open():
                ui.close_panel()
            elif driving:
                _toggle_drive()
            elif build_mode:
                _toggle_build()
            else:
                get_tree().change_scene_to_file("res://scenes/menu.tscn")
            get_viewport().set_input_as_handled()
            return
        if ui.panel_open():
            return
        match event.keycode:
            KEY_B:
                _toggle_build()
            KEY_V:
                _toggle_drive()
            KEY_J:
                ui.show_quests(quest_catalog)
            KEY_O:
                ui.show_orbit()
            KEY_E, KEY_ENTER:
                _interact()
            KEY_F5:
                GameState.save_game()
                ui.flash("EXPLORER JOURNAL AND BLUEPRINT SAVED")
            KEY_R:
                if build_mode:
                    build.rotate_part()
            KEY_Z:
                if build_mode:
                    build.undo()
            KEY_Y:
                if build_mode:
                    build.redo()
            KEY_BRACKETLEFT:
                if build_mode:
                    build.change_layer(-1)
            KEY_BRACKETRIGHT:
                if build_mode:
                    build.change_layer(1)
            KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0:
                if build_mode:
                    var id: int = 9 if event.keycode == KEY_0 else int(event.keycode - KEY_1)
                    build.select_part(id)
        get_viewport().set_input_as_handled()
    if build_mode and not ui.panel_open():
        if event is InputEventMouseButton and event.pressed:
            if event.button_index == MOUSE_BUTTON_LEFT:
                build.try_place()
            elif event.button_index == MOUSE_BUTTON_RIGHT:
                build.try_remove()
            elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
                build.select_part(build.selected + 1)
            elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                build.select_part(build.selected - 1)

func _toggle_build() -> void:
    if driving:
        _toggle_drive()
    build_mode = not build_mode
    build.set_enabled(build_mode)
    avatar.active = not build_mode
    avatar.visible = not build_mode
    if build_mode:
        workshop_camera.current = true
        ui.set_build_mode(true, build.stats())
        ui.flash("GRID FABRICATOR: choose a module, click to place, rotate and test it")
    else:
        avatar.eye.current = true
        ui.set_build_mode(false)
        GameState.save_game()

func _toggle_drive() -> void:
    if build_mode:
        _toggle_build()
    driving = not driving
    rover.set_active(driving)
    avatar.active = not driving
    avatar.visible = not driving
    if driving:
        rover.configure_blueprint(build.stats())
        has_driven = true
        race_gate = 0
        race_time = 0.0
        race_finished = false
        ui.flash("ROVER TEST: W accelerate / S reverse / A-D steer / SPACE brake / V exit")
    else:
        avatar.global_position = rover.global_position + Vector3(3.5, 1.3, 0)
        avatar.eye.current = true
        ui.set_walk_mode()
        GameState.last_location = avatar.global_position
        GameState.save_game()

func _on_speed(kph: float) -> void:
    ui.set_speed(kph)

func _on_build_changed() -> void:
    if build_mode:
        ui.set_build_stats(build.stats())
    if GameState.parts.size() >= 6:
        ui.flash("Your prototype has enough structural elements for the first commission. Return to Master Halden!")

func _notify(message: String) -> void:
    if ui != null:
        ui.flash(message)

func _interact() -> void:
    if driving or build_mode:
        return
    if proximity == "":
        ui.flash("No inventor nearby. Follow a glowing beacon or use J for the quest folio.")
        return
    visited[proximity] = true
    current_region = proximity
    var candidate: Dictionary = {}
    for q in quest_catalog:
        if str(q.get("region", "")) == str(REGIONS.get(proximity, "")) and not GameState.completed_quests.has(str(q.get("id", ""))):
            candidate = q
            break
    if candidate.is_empty():
        ui.show_note(str(REGIONS.get(proximity, "THE VALLEY")), "You've met this inventor. Return after completing more commissions or explore another region.\n\nThis vertical slice contains the beginning of a much larger narrative arc.")
        return
    ui.show_quest(candidate, _eligible(candidate), GameState.completed_quests.has(str(candidate.get("id", ""))))

func _eligible(quest: Dictionary) -> bool:
    var condition: String = str(quest.get("condition", ""))
    if condition == "parts_at_least:6":
        return GameState.parts.size() >= 6
    if condition == "rover_ready":
        return bool(build.stats().get("drive_ready", false)) and has_driven
    if condition == "race_finish":
        return race_finished
    if condition.begins_with("visit:"):
        return bool(visited.get(condition.trim_prefix("visit:"), false))
    if condition == "reputation_and_parts":
        return GameState.completed_quests.size() >= 3 and GameState.parts.size() >= 16
    return false

func _complete_quest(id: String) -> void:
    for q in quest_catalog:
        if str(q.get("id", "")) == id:
            if not _eligible(q):
                ui.flash("Quest not verified yet. Keep testing!")
                return
            if GameState.award(id, q.get("reward", {})):
                ui.flash("COMMISSION COMPLETE  ✦  %s  •  materials and reputation awarded" % str(q["title"]))
                if id == "race_trial":
                    race_finished = false
            return
