extends Node3D
class_name GenesisWorldBuilder

signal part_placed(part_name: String)

const PARTS: Array[String] = ["Timber", "Stone", "Steel", "Glass", "Copper", "Energy"]
const COLORS: Array[Color] = [Color("ae8158"), Color("9aa5a1"), Color("668aa5"), Color("bce8de"), Color("d79a59"), Color("59f1d4")]
const MAX_PARTS: int = 300
var active: bool = false
var selected: int = 0
var yaw_steps: int = 0
var ghost: MeshInstance3D
var camera: Camera3D
var placer: Node3D
var parts_root: Node3D
var placed: Array[Dictionary] = []
var remove_mode: bool = false

func _ready() -> void:
	parts_root = Node3D.new()
	parts_root.name = "SavedMachineAssemblies"
	add_child(parts_root)
	ghost = MeshInstance3D.new()
	ghost.name = "BuildProjection"
	add_child(ghost)
	_update_ghost()
	ghost.visible = false

func _update_ghost() -> void:
	var mesh := BoxMesh.new()
	mesh.size = _part_size()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLORS[selected]
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	ghost.mesh = mesh

func _part_size() -> Vector3:
	match selected:
		0: return Vector3(3.5, 0.35, 1.0) # Beam
		1: return Vector3(2.0, 1.0, 2.0) # Foundation
		2: return Vector3(3.0, 0.35, 0.35) # Cross brace
		3: return Vector3(2.0, 2.0, 0.2) # Window
		4: return Vector3(0.8, 1.0, 0.8) # Conductive cell
		_: return Vector3(0.75, 0.75, 0.75) # Power core

func set_active(value: bool) -> void:
	active = value
	ghost.visible = value

func choose(delta: int) -> void:
	selected = posmod(selected + delta, PARTS.size())
	_update_ghost()

func rotate_ghost() -> void:
	yaw_steps = (yaw_steps + 1) % 4
	ghost.rotation.y = float(yaw_steps) * PI / 2.0

func update_aim(viewport: Viewport) -> void:
	if not active or camera == null: return
	var center: Vector2 = viewport.get_visible_rect().size / 2.0
	var ray_origin: Vector3 = camera.project_ray_origin(center)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(center) * 65.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = false
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		ghost.visible = false
		return
	ghost.visible = true
	var p: Vector3 = hit.position
	p = Vector3(roundf(p.x / 0.5) * 0.5, roundf(p.y / 0.5) * 0.5, roundf(p.z / 0.5) * 0.5)
	ghost.global_position = p + Vector3.UP * (_part_size().y * 0.5)

func place() -> bool:
	if not active or not ghost.visible or placed.size() >= MAX_PARTS: return false
	var position: Vector3 = ghost.global_position
	var rotation_y: float = float(yaw_steps) * PI / 2.0
	var data: Dictionary = {"kind": selected, "p": [position.x, position.y, position.z], "rot": rotation_y}
	placed.append(data)
	_spawn_part(data)
	part_placed.emit(PARTS[selected])
	return true

func _spawn_part(data: Dictionary) -> void:
	var kind: int = clampi(int(data.get("kind", 0)), 0, PARTS.size() - 1)
	var size_before: int = selected
	selected = kind
	var dims := _part_size()
	selected = size_before
	var mesh := BoxMesh.new()
	mesh.size = dims
	var material := StandardMaterial3D.new()
	material.albedo_color = COLORS[kind]
	material.metallic = 0.5 if kind == 2 or kind == 4 else 0.0
	material.roughness = 0.38 if kind == 3 else 0.76
	if kind == 5:
		material.emission_enabled = true
		material.emission = COLORS[kind]
		material.emission_energy_multiplier = 0.9
	mesh.material = material
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var p: Array = data.get("p", [0, 0, 0])
	visual.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	visual.rotation.y = float(data.get("rot", 0))
	parts_root.add_child(visual)

func clear_parts() -> void:
	for child in parts_root.get_children(): child.queue_free()
	placed.clear()

func export_data() -> Dictionary:
	return {"schema": "wonderforge.genesis.assembly.v1", "parts": placed.duplicate(true)}

func import_data(data: Dictionary) -> bool:
	if str(data.get("schema", "")) != "wonderforge.genesis.assembly.v1": return false
	var imported: Variant = data.get("parts", [])
	if not (imported is Array) or imported.size() > MAX_PARTS: return false
	var clean: Array[Dictionary] = []
	for entry in imported:
		if not (entry is Dictionary): return false
		if not entry.has("p") or not (entry["p"] is Array) or entry["p"].size() != 3: return false
		var p: Array = entry["p"]
		for number in p:
			if not (number is int or number is float) or absf(float(number)) > 3000: return false
		var kind: int = int(entry.get("kind", -1))
		if kind < 0 or kind >= PARTS.size(): return false
		var rot: float = float(entry.get("rot", 0))
		if not is_finite(rot) or absf(rot) > 7.0: return false
		clean.append({"kind": kind, "p": p.duplicate(), "rot": rot})
	clear_parts()
	for entry in clean:
		placed.append(entry)
		_spawn_part(entry)
	return true
