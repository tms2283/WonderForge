extends Node3D

# WonderForge: Genesis — procedural EXPLORABLE GAME-SYSTEM VERTICAL SLICE.
# No claim of professional final art, advanced construction physics or Pi certification.

const SAVE_PATH := "user://genesis_save_v1.json"
const PLAYER_SCRIPT := preload("res://scripts/player.gd")
const CAMERA_SCRIPT := preload("res://scripts/camera_rig.gd")
const WORLD_SCRIPT := preload("res://scripts/world_gen.gd")
const BUILDER_SCRIPT := preload("res://scripts/world_builder.gd")
const VEHICLE_SCRIPT := preload("res://scripts/vehicle.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")
const QUALITY_SCRIPT := preload("res://scripts/quality_profiles.gd")
const GARAGE_SCRIPT := preload("res://scripts/rover_garage.gd")
const TRIAL_SCRIPT := preload("res://scripts/trial_course.gd")
const JOURNAL_SCRIPT := preload("res://scripts/engineering_journal.gd")
const BLUEPRINT_SCRIPT := preload("res://scripts/rover_blueprint.gd")

var player: GenesisPlayer
var follow: GenesisCamera
var landscape: GenesisLandscape
var builder: GenesisWorldBuilder
var rover: GenesisRover
var hud: GenesisHUD
var visited: Dictionary = {}
var resources: Dictionary = {"timber":12, "stone":8, "alloy":4, "energy":0}
var active_mission: int = 0
var story_flags: Dictionary = {"workshop":false,"beacon":false,"constructed":false,"rover":false}
var ambient_clock: float = 0.0
var toast_timeout: float = 0.0
var quality_name: String = "creator"
var quality_settings: Dictionary = {}
var garage: GenesisRoverGarage
var proving_grounds: GenesisTrialCourse
var engineering_journal: GenesisEngineeringJournal
var last_trial: Dictionary = {}
var last_hypothesis: String = ""
var trial_notice_s: float = 0.0

func _ready() -> void:
	quality_name = QUALITY_SCRIPT.resolve_requested()
	quality_settings = QUALITY_SCRIPT.get_settings(quality_name)
	Engine.max_fps = int(quality_settings["fps_cap"])
	_create_lighting()
	landscape = WORLD_SCRIPT.new()
	landscape.terrain_segments = int(quality_settings["terrain_segments"])
	landscape.tree_instances = int(quality_settings["tree_instances"])
	landscape.art_profile = quality_name
	landscape.name = "FoundersValley"
	add_child(landscape)
	player = PLAYER_SCRIPT.new()
	player.position = Vector3(0, landscape.height_at(0,12) + 2.0, 12)
	add_child(player)
	follow = CAMERA_SCRIPT.new()
	follow.name = "FollowCameraRig"
	add_child(follow)
	follow.target = player
	follow.camera.far = float(quality_settings["camera_far"])
	player.camera_node = follow.camera
	builder = BUILDER_SCRIPT.new()
	builder.name = "CreationWorkbench"
	add_child(builder)
	builder.camera = follow.camera
	builder.part_placed.connect(_on_part_placed)
	rover = VEHICLE_SCRIPT.new()
	rover.position = Vector3(14, landscape.height_at(14,9) + 3, 9)
	rover.rotation.y = 0.1
	add_child(rover)
	hud = HUD_SCRIPT.new()
	add_child(hud)
	engineering_journal = JOURNAL_SCRIPT.new()
	engineering_journal.load_records()
	last_trial = engineering_journal.latest()
	proving_grounds = TRIAL_SCRIPT.new()
	proving_grounds.terrain = landscape
	add_child(proving_grounds)
	proving_grounds.gate_cleared.connect(_on_gate_cleared)
	proving_grounds.run_completed.connect(_on_trial_completed)
	proving_grounds.run_failed.connect(_on_trial_failed)
	garage = GARAGE_SCRIPT.new()
	add_child(garage)
	garage.build_applied.connect(_on_garage_applied)
	garage.trial_requested.connect(_on_garage_trial)
	garage.garage_closed.connect(_on_garage_closed)
	_update_hud()
	hud.notice("QUALITY PROFILE · %s (override with -- --quality=explorer|creator|ultra)" % str(quality_settings["label"]))

func _create_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "HighAltitudeGoldenSun"
	sun.rotation_degrees = Vector3(-42, -23, 0)
	sun.light_color = Color("fff1d6")
	sun.light_energy = 1.25
	sun.shadow_enabled = bool(quality_settings["sun_shadows"])
	sun.directional_shadow_max_distance = float(quality_settings["shadow_distance"])
	add_child(sun)
	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("88bfcb")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("d1e0df")
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("bdd8cf")
	environment.fog_density = float(quality_settings["fog_density"])
	world_env.environment = environment
	add_child(world_env)

func _unhandled_input(event: InputEvent) -> void:
	if garage != null and garage.active: return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F1: hud.toggle_help()
			KEY_F5: _save_game()
			KEY_F9: _load_game()
			KEY_M: _show_quest_help()
			KEY_J: _show_trial_journal()
			KEY_G: _open_garage()
			KEY_B:
				if not rover.driving:
					builder.set_active(not builder.active)
					_update_hud()
			KEY_E: _interact()
			KEY_Q:
				if builder.active: builder.rotate_ghost()
			KEY_Z:
				if builder.active:
					var last_kind: int = builder.undo_last()
					if last_kind >= 0:
						var key := _cost_key(last_kind)
						resources[key] = int(resources.get(key,0)) + 1
						_update_hud()
			KEY_X:
				if builder.active:
					var redo_kind: int = builder.next_redo_kind()
					if redo_kind >= 0 and _can_afford(redo_kind) and builder.redo_last():
						_consume_resource(redo_kind)
						_update_hud()
			KEY_R:
				if proving_grounds.active and rover.driving:
					rover.reset_trial(proving_grounds.start_trial(rover.blueprint,last_hypothesis),proving_grounds.start_direction())
					hud.notice("TRIAL RESET · Same course, same design. Take another measurement.")
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6:
				if builder.active:
					builder.select(event.keycode - KEY_1)
					_update_hud()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and builder.active and not hud.splash.visible:
		if _can_afford(builder.selected) and builder.place():
			_consume_resource(builder.selected)
			_update_hud()

func _physics_process(_delta: float) -> void:
	if proving_grounds != null and rover != null:
		if proving_grounds.active and rover.driving:
			proving_grounds.update_drive(rover.global_position,rover.get_telemetry(),_delta)
		hud.set_rover_telemetry(rover.get_telemetry(),proving_grounds.guidance(rover.global_position),rover.driving)
	if builder.active and not hud.splash.visible:
		builder.update_aim(get_viewport())
	if rover.driving:
		follow.target = rover
	else:
		follow.target = player
	if player != null and hud != null:
		hud.coords_label.text = "MAP  /  X %d  :  Z %d" % [int(player.position.x), int(player.position.z)]

func _can_afford(part: int) -> bool:
	var key := _cost_key(part)
	if int(resources.get(key,0)) <= 0:
		hud.notice("Not enough %s. Find a workshop or guild beacon to restock." % key)
		return false
	return true

func _cost_key(part: int) -> String:
	match part:
		0, 3: return "timber"
		1: return "stone"
		_: return "alloy"

func _consume_resource(part: int) -> void:
	var key := _cost_key(part)
	resources[key] = maxi(0, int(resources.get(key,0)) - 1)

func _on_part_placed(_part: String) -> void:
	if builder.placed.size() >= 3 and not story_flags.constructed:
		story_flags.constructed = true
		hud.notice("QUEST MILESTONE · First three structural pieces assembled! +8 Timber")
		resources.timber += 8
		_advance_story()

func _interact() -> void:
	if rover.driving:
		if proving_grounds.active: proving_grounds.stop_trial()
		rover.driving = false
		player.global_position = rover.global_position + Vector3(3,2.1,0)
		player.set_driving(false)
		hud.notice("Disembarked from ForgeRover")
		return
	if player.global_position.distance_to(rover.global_position) < 7:
		rover.driving = true
		player.set_driving(true)
		builder.set_active(false)
		story_flags.rover = true
		hud.notice("FORGEROVER ONLINE · WASD drive, SPACE brake, G tune, E disembark")
		_advance_story()
		return
	var nearest: Dictionary = {}
	var dist := 7.5
	for landmark in landscape.landmarks:
		var ldist: float = player.global_position.distance_to(landmark.position)
		if ldist < dist:
			dist = ldist
			nearest = landmark
	if nearest.is_empty():
		hud.notice("No nearby station. Follow the lanterns and explore the valley.")
		return
	var marker: String = nearest.name
	if not visited.has(marker):
		visited[marker] = true
		match nearest.kind:
			"workshop": resources.timber += 12; story_flags.workshop = true
			"industry": resources.alloy += 10
			"challenge": resources.stone += 7
			"astronomy": resources.energy += 4
			"ecology": resources.timber += 7
		story_flags.beacon = true
		_advance_story()
		hud.notice("DISCOVERED · %s     REWARD: %s" % [marker, nearest.reward])
	else:
		hud.notice("%s · %s" % [marker, nearest.description])
	_update_hud()

func _advance_story() -> void:
	var completed := 0
	for key in ["workshop","beacon","constructed","rover"]:
		if story_flags.get(key,false): completed += 1
	active_mission = completed
	_update_hud()
	if completed == 4:
		hud.notice("ACT I COMPLETE · The Valley welcomes a new engineer!")

func _open_garage() -> void:
	if proving_grounds.active:
		proving_grounds.stop_trial()
		rover.driving = false
	if rover.driving:
		rover.driving = false
		player.global_position = rover.global_position + Vector3(3,2.1,0)
		player.set_driving(false)
	builder.set_active(false)
	player.interaction_enabled = false
	garage.open_garage(rover.blueprint,last_trial)
	hud.notice("INVENTOR'S GARAGE · Choose a design, write a prediction, run the proving grounds.")

func _on_garage_applied(config: Dictionary) -> void:
	rover.apply_build(config)
	hud.notice("NEW ROVER CONFIGURED · Changes now affect wheel geometry and driving physics.")

func _on_garage_trial(config: Dictionary, hypothesis: String) -> void:
	rover.apply_build(config)
	last_hypothesis = hypothesis
	var start: Vector3 = proving_grounds.start_trial(rover.blueprint,hypothesis)
	rover.reset_trial(start,proving_grounds.start_direction())
	player.set_driving(true)
	story_flags.rover = true
	_advance_story()
	hud.notice("TRIAL STARTED · Drive through SIX gates in order. R reset · E exit.")

func _on_garage_closed() -> void:
	if not rover.driving: player.interaction_enabled = true
	_update_hud()

func _on_gate_cleared(index: int, count: int) -> void:
	hud.notice("CHECKPOINT %d / %d   •   Follow the next arch" % [index,count])

func _on_trial_failed(reason: String) -> void:
	hud.notice(reason)

func _on_trial_completed(result: Dictionary) -> void:
	if engineering_journal.add_result(result):
		last_trial = result.duplicate(true)
		var best: Dictionary = engineering_journal.best()
		hud.notice("TRIAL COMPLETE · %.1f s, peak %.1f km/h! Best: %.1f s  ·  Press J for analysis." % [float(result["time_s"]),float(result["peak_speed_kmh"]),float(best.get("time_s",0))])
	else:
		hud.notice("TRIAL COMPLETE, but journal write failed. Check local storage.")
	resources["alloy"] = mini(100000,int(resources.get("alloy",0))+2)
	_update_hud()

func _show_trial_journal() -> void:
	if engineering_journal.records.is_empty():
		hud.notice("ENGINEERING JOURNAL · No trial yet. Press G, predict an outcome, and run the circuit.")
	else:
		hud.notice("JOURNAL · "+engineering_journal.compare_last_two().replace("\n","   |   "))

func _show_quest_help() -> void:
	hud.notice("ACT I · Find beacon, claim supplies, construct three parts, drive rover. G = engineering garage / J = experiment journal.")

func _update_hud() -> void:
	if hud == null: return
	hud.set_resources(resources)
	hud.set_mode(builder.active,builder.PARTS[builder.selected],builder.placed.size())
	var chapter := "ACT I  ·  THE FOUNDER'S TRIAL"
	if active_mission >= 4: chapter = "ACT II  ·  THE FRONTIER AWAITS (PREVIS)"
	hud.mission_label.text = chapter
	var objective := "Explore the valley. Activate a glowing quest beacon."
	if story_flags.beacon and not story_flags.constructed: objective = "Open BUILD MODE (B), select a part and place three pieces."
	if story_flags.constructed and not story_flags.rover: objective = "Find the copper ForgeRover near the workshop; press E to drive."
	if active_mission >= 4: objective = "Press G to design and test a rover; compare 2 trials with J, then explore the guilds."
	hud.hint_label.text = objective
	var flags := ["workshop","beacon","constructed","rover"]
	var lines := ["FIND THE FOUNDERS' WORKSHOP","ACTIVATE A QUEST BEACON","ASSEMBLE THREE PARTS","DRIVE THE FORGEROVER"]
	var report := ""
	for i in range(flags.size()):
		report += "%s  %02d   %s" % ["✓" if story_flags.get(flags[i],false) else "○", i+1, lines[i]]
		if i < flags.size()-1: report += "\n"
	hud.banner_label.text = report

func _save_game() -> void:
	var save := {
		"schema":"wonderforge.genesis.save.v1",
		"player":[player.global_position.x,player.global_position.y,player.global_position.z],
		"visited":visited,
		"resources":resources,
		"story":story_flags,
		"assembly":builder.export_data(),
		"rover_blueprint":rover.blueprint.duplicate(true),
		"journal_version":"wonderforge.genesis.journal.v1"
	}
	var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file == null:
		hud.notice("Could not save. Check local disk permissions.")
		return
	file.store_string(JSON.stringify(save,"  "))
	file.close()
	hud.notice("WORLD SAVED · Private local Godot save: genesis_save_v1.json")

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		hud.notice("No previous save yet. Press F5 to create one.")
		return
	var raw := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary) or parsed.get("schema","") != "wonderforge.genesis.save.v1":
		hud.notice("Save rejected: invalid format.")
		return
	var pos: Variant = parsed.get("player",[])
	if not (pos is Array) or pos.size() != 3:
		hud.notice("Save rejected: invalid player position.")
		return
	for n in pos:
		if not (n is float or n is int) or not is_finite(float(n)) or absf(float(n)) > 2000:
			hud.notice("Save rejected: invalid coordinates.")
			return
	var inventory: Variant = parsed.get("resources",{})
	var narrative: Variant = parsed.get("story",{})
	var discoveries: Variant = parsed.get("visited",{})
	if not (inventory is Dictionary and narrative is Dictionary and discoveries is Dictionary):
		hud.notice("Save rejected: invalid progression.")
		return
	if not builder.import_data(parsed.get("assembly",{})):
		hud.notice("Save rejected: invalid assembly data.")
		return
	var previous_blueprint: Variant = parsed.get("rover_blueprint",BLUEPRINT_SCRIPT.DEFAULT)
	if not BLUEPRINT_SCRIPT.strict_valid(previous_blueprint):
		hud.notice("Save rejected: invalid rover blueprint.")
		return
	rover.apply_build(previous_blueprint)
	player.global_position = Vector3(float(pos[0]),float(pos[1]),float(pos[2]))
	for key in resources.keys():
		resources[key] = clampi(int(inventory.get(key,resources[key])),0,100000)
	for key in story_flags.keys():
		story_flags[key] = bool(narrative.get(key,false))
	visited = discoveries.duplicate(true)
	_advance_story()
	hud.notice("PREVIOUS WORLD LOADED · Welcome back, inventor!")
