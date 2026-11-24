extends Node3D
class_name GenesisTrialCourse

signal gate_cleared(index: int, count: int)
signal run_completed(result: Dictionary)
signal run_failed(reason: String)

const GATE_COORDS: Array[Vector2] = [
	Vector2(21,62), Vector2(42,70), Vector2(63,57),
	Vector2(57,39), Vector2(35,32), Vector2(21,46)
]
const LIMIT_SECONDS := 240.0
var terrain: GenesisLandscape
var active: bool = false
var elapsed: float = 0
var next_gate: int = 0
var gate_visuals: Array[Node3D] = []
var records: int = 0
var hypothesis: String = ""
var chosen_blueprint: Dictionary = {}
var best_time_s: float = -1.0
var guide: Label3D

func _ready() -> void:
	name = "FoundersProvingGrounds_01"
	var track_mat := StandardMaterial3D.new()
	track_mat.albedo_color = Color("bba987")
	track_mat.roughness = 0.94
	for i in range(GATE_COORDS.size()):
		var v := GATE_COORDS[i]
		var gate := Node3D.new()
		gate.name = "CourseGate_%02d" % (i+1)
		gate.position = Vector3(v.x,_terrain_height(v.x,v.y),v.y)
		add_child(gate)
		gate_visuals.append(gate)
		_make_gate(gate,i)
		if i < GATE_COORDS.size()-1:
			_make_surface_track(v,GATE_COORDS[i+1],track_mat)
	guide = Label3D.new()
	guide.name = "TrialStart3DMarker"
	guide.text = "PROVING GROUNDS\nG  =  GARAGE     /     RUN A DESIGN TRIAL"
	guide.font_size = 32
	guide.pixel_size = 0.006
	guide.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guide.position = Vector3(21, _terrain_height(21,46)+3.8, 46)
	add_child(guide)
	_update_markers()

func _terrain_height(x: float,z: float) -> float:
	return terrain.height_at(x,z) if is_instance_valid(terrain) else 0.0

func _make_gate(gate: Node3D, index: int) -> void:
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color("6ad0b8") if index == 0 else Color("bf9e74")
	paint.metallic = 0.22
	paint.roughness = 0.42
	for s in [-1,1]:
		var post_mesh := CylinderMesh.new()
		post_mesh.height = 5.0
		post_mesh.top_radius = 0.16
		post_mesh.bottom_radius = 0.2
		var post := MeshInstance3D.new()
		post.name = "GatePillar"
		post.mesh = post_mesh
		post.material_override = paint
		post.position = Vector3(float(s)*4.2,2.5,0)
		gate.add_child(post)
	var crown_mesh := BoxMesh.new()
	crown_mesh.size = Vector3(9.0,0.3,0.4)
	var crown := MeshInstance3D.new()
	crown.mesh = crown_mesh
	crown.material_override = paint
	crown.position.y = 4.9
	gate.add_child(crown)
	var indicator := Label3D.new()
	indicator.name = "GateNumber"
	indicator.text = "CHECKPOINT %d / %d" % [index+1,GATE_COORDS.size()]
	indicator.font_size = 26
	indicator.pixel_size = 0.007
	indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	indicator.position = Vector3(0,5.7,0)
	gate.add_child(indicator)
	for s in [-1,1]:
		var cap := SphereMesh.new()
		cap.radius = 0.40
		cap.height = 0.8
		var sphere := MeshInstance3D.new()
		sphere.mesh = cap
		sphere.material_override = paint
		sphere.position = Vector3(float(s)*4.2,5.0,0)
		gate.add_child(sphere)

func _make_surface_track(start: Vector2, finish: Vector2, material: StandardMaterial3D) -> void:
	# Decorative ground breadcrumbs; no physics privilege or artificial grip.
	var length_m := start.distance_to(finish)
	for j in range(1,int(length_m/2.5)):
		var v := start.lerp(finish,float(j)*2.5/length_m)
		var cube := BoxMesh.new()
		cube.size = Vector3(0.60,0.08,1.55)
		var p := MeshInstance3D.new()
		p.name = "TrailWayfinding"
		p.mesh = cube
		p.material_override = material
		p.position = Vector3(v.x,_terrain_height(v.x,v.y)+0.18,v.y)
		p.rotation.y = atan2(finish.x-start.x,finish.y-start.y)
		add_child(p)

func start_trial(blueprint: Dictionary, expected: String = "") -> Vector3:
	chosen_blueprint = blueprint.duplicate(true)
	hypothesis = expected.left(220)
	elapsed = 0.0
	next_gate = 0
	active = true
	_update_markers()
	var origin := Vector2(21,46)
	return Vector3(origin.x,_terrain_height(origin.x,origin.y)+2.8,origin.y)

func start_direction() -> Vector3:
	var v := GATE_COORDS[0]
	return Vector3(v.x,_terrain_height(v.x,v.y)+1.0,v.y)

func stop_trial() -> void:
	active = false
	_update_markers()

func update_drive(pos: Vector3, telemetry: Dictionary, delta: float) -> void:
	if not active: return
	elapsed += delta
	if elapsed >= LIMIT_SECONDS:
		active = false
		run_failed.emit("Trial time limit reached. Change the design or restart with G.")
		_update_markers()
		return
	if next_gate >= GATE_COORDS.size(): return
	var gate := GATE_COORDS[next_gate]
	if Vector2(pos.x,pos.z).distance_to(gate) <= 6.6:
		next_gate += 1
		gate_cleared.emit(next_gate,GATE_COORDS.size())
		_update_markers()
		if next_gate >= GATE_COORDS.size():
			active = false
			records += 1
			if best_time_s < 0.0 or elapsed < best_time_s: best_time_s = elapsed
			var result := {
				"schema":"wonderforge.genesis.trial.v1",
				"time_s":snappedf(elapsed,0.01),
				"peak_speed_kmh":snappedf(float(telemetry.get("peak_speed_kmh",0.0)),0.1),
				"distance_m":snappedf(float(telemetry.get("distance_m",0.0)),0.1),
				"charge_percent":snappedf(float(telemetry.get("charge_percent",0.0)),0.1),
				"wheel_contact":int(telemetry.get("wheel_contact",0)),
				"hypothesis":hypothesis,
				"blueprint":chosen_blueprint.duplicate(true),
				"status":"course_completed",
			}
			run_completed.emit(result)

func guidance(rover_pos: Vector3) -> String:
	if not active: return "G  /  INVENTOR'S GARAGE   •   Choose a design to race"
	var g: Vector2 = GATE_COORDS[mini(next_gate,GATE_COORDS.size()-1)]
	var d: float = Vector2(rover_pos.x,rover_pos.z).distance_to(g)
	return "TRIAL  %d/%d  •  NEXT GATE %.0f m  •  %.1f s" % [next_gate+1,GATE_COORDS.size(),d,elapsed]

func _update_markers() -> void:
	for index in range(gate_visuals.size()):
		var gate := gate_visuals[index]
		var marker := gate.get_node("GateNumber") as Label3D
		if active and index == next_gate:
			marker.text = "▶  NEXT GATE %d  ◀" % (index+1)
			marker.modulate = Color("aaffda")
		else:
			marker.text = "CHECKPOINT %d" % (index+1)
			marker.modulate = Color("e4c99d")
