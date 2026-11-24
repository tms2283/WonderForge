extends Node3D
class_name GenesisWorldBuilder

signal part_placed(part_name: String)

const PARTS: Array[String] = ["Timber", "Stone", "Steel", "Glass", "Copper", "Energy"]
const COLORS: Array[Color] = [Color("ae8158"), Color("9aa5a1"), Color("668aa5"), Color("bce8de"), Color("d79a59"), Color("59f1d4")]
const MAX_PARTS := 300
const SNAP_M := 0.5
const SCAN := preload("res://scripts/assembly_scan.gd")
var active: bool = false
var selected: int = 0
var yaw_steps: int = 0
var ghost: MeshInstance3D
var camera: Camera3D
var parts_root: Node3D
var placed: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []
var preview_legal: bool = false

func _ready() -> void:
	parts_root = Node3D.new()
	parts_root.name = "SavedMachineAssemblies"
	add_child(parts_root)
	ghost = MeshInstance3D.new()
	ghost.name = "BuildProjection"
	add_child(ghost)
	_update_ghost()
	ghost.visible = false

func _part_size(kind: int = -1) -> Vector3:
	var index: int = selected if kind == -1 else kind
	match index:
		0: return Vector3(3.5,0.35,1.0)  # timber beam
		1: return Vector3(2.0,1.0,2.0)  # stone foundation
		2: return Vector3(3.0,0.35,0.35) # steel brace
		3: return Vector3(2.0,2.0,0.2)  # framed glass panel
		4: return Vector3(0.8,1.0,0.8)  # copper enclosure
		_: return Vector3(0.75,0.75,0.75) # power core

func _update_ghost() -> void:
	if ghost == null: return
	var mesh := BoxMesh.new()
	mesh.size = _part_size()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLORS[selected]
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.43
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	ghost.mesh = mesh

func set_active(value: bool) -> void:
	active = value
	if ghost != null:
		ghost.visible = value and preview_legal

func choose(delta: int) -> void:
	selected = posmod(selected+delta,PARTS.size())
	_update_ghost()

func select(index: int) -> void:
	selected = clampi(index,0,PARTS.size()-1)
	_update_ghost()

func rotate_ghost() -> void:
	yaw_steps = (yaw_steps+1)%4
	ghost.rotation.y = yaw_steps*PI*0.5

func _dims_rotated(kind: int, radians: float) -> Vector3:
	var size: Vector3 = _part_size(kind)
	if absi(roundi(radians/(PI*0.5)))%2==1:
		return Vector3(size.z,size.y,size.x)
	return size

func _fits(new_pos: Vector3, kind: int, radians: float) -> bool:
	if placed.size()>=MAX_PARTS: return false
	var size := _dims_rotated(kind,radians)
	var a := AABB(new_pos-size*0.5+Vector3.ONE*0.025,size-Vector3.ONE*0.05)
	for part in placed:
		var p: Array = part["p"]
		var old_pos := Vector3(float(p[0]),float(p[1]),float(p[2]))
		var old_size := _dims_rotated(int(part["kind"]),float(part["rot"]))
		var other := AABB(old_pos-old_size*0.5+Vector3.ONE*0.025,old_size-Vector3.ONE*0.05)
		if a.intersects(other): return false
	return true

func update_aim(viewport: Viewport) -> void:
	if not active or camera == null: return
	var center := viewport.get_visible_rect().size*0.5
	var origin := camera.project_ray_origin(center)
	var end := origin+camera.project_ray_normal(center)*65.0
	var query := PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_areas = false
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		preview_legal = false
		ghost.visible = false
		return
	var p: Vector3 = hit["position"]
	var size := _part_size()
	var offset := size.y*0.5
	var snapped := Vector3(roundf(p.x/SNAP_M)*SNAP_M,roundf((p.y+offset)/SNAP_M)*SNAP_M,roundf(p.z/SNAP_M)*SNAP_M)
	ghost.global_position = snapped
	preview_legal = _fits(snapped,selected,yaw_steps*PI*0.5)
	ghost.visible = true
	var mat := (ghost.mesh as BoxMesh).material as StandardMaterial3D
	mat.albedo_color = COLORS[selected] if preview_legal else Color("ed6965")
	mat.albedo_color.a = 0.43

func place() -> bool:
	if not active or not preview_legal or placed.size()>=MAX_PARTS: return false
	var pos := ghost.global_position
	var rot := yaw_steps*PI*0.5
	if not _fits(pos,selected,rot): return false
	var record: Dictionary = {"kind":selected,"p":[pos.x,pos.y,pos.z],"rot":rot}
	placed.append(record)
	redo_stack.clear()
	_spawn_part(record)
	part_placed.emit(PARTS[selected])
	return true

func _spawn_part(data: Dictionary) -> void:
	var kind: int = int(data["kind"])
	var mesh := BoxMesh.new()
	mesh.size = _part_size(kind)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLORS[kind]
	mat.metallic = 0.48 if kind in [2,4] else 0.0
	mat.roughness = 0.20 if kind == 3 else 0.76
	if kind == 5:
		mat.emission_enabled = true
		mat.emission = COLORS[kind]
		mat.emission_energy_multiplier = 0.8
	mesh.material = mat
	var root := StaticBody3D.new()
	root.name = "StructuralPart_%s" % PARTS[kind]
	var p: Array = data["p"]
	root.position = Vector3(float(p[0]),float(p[1]),float(p[2]))
	root.rotation.y = float(data["rot"])
	root.collision_layer = 1
	root.collision_mask = 1
	parts_root.add_child(root)
	var shape := BoxShape3D.new()
	shape.size = _part_size(kind)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	root.add_child(collision)
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	root.add_child(visual)

func undo_last() -> int:
	if placed.is_empty(): return -1
	var removed: Dictionary = placed.pop_back()
	redo_stack.append(removed)
	var node: Node3D = parts_root.get_child(parts_root.get_child_count()-1)
	parts_root.remove_child(node)
	node.queue_free()
	return int(removed["kind"])

func next_redo_kind() -> int:
	return int(redo_stack[-1]["kind"]) if not redo_stack.is_empty() else -1

func redo_last() -> bool:
	if redo_stack.is_empty() or placed.size()>=MAX_PARTS: return false
	var data: Dictionary = redo_stack.pop_back()
	placed.append(data)
	_spawn_part(data)
	return true

func clear_parts() -> void:
	for node in parts_root.get_children():
		parts_root.remove_child(node)
		node.queue_free()
	placed.clear()
	redo_stack.clear()

func export_data() -> Dictionary:
	return {"schema":"wonderforge.genesis.assembly.v1","parts":placed.duplicate(true)}

func import_data(data: Dictionary) -> bool:
	if str(data.get("schema",""))!="wonderforge.genesis.assembly.v1": return false
	var parts: Variant = data.get("parts",[])
	if not (parts is Array) or parts.size()>MAX_PARTS: return false
	var cleaned: Array[Dictionary] = []
	for part in parts:
		if not (part is Dictionary): return false
		if not part.has("p") or not (part["p"] is Array) or part["p"].size()!=3: return false
		var xyz: Array = part["p"]
		for number in xyz:
			if not (number is int or number is float): return false
			if not is_finite(float(number)) or absf(float(number))>3000: return false
		var kind: int = int(part.get("kind",-1))
		if kind<0 or kind>=PARTS.size(): return false
		var rot: float = float(part.get("rot",0))
		if not is_finite(rot) or absf(rot)>7: return false
		cleaned.append({"kind":kind,"p":xyz.duplicate(),"rot":rot})
	clear_parts()
	for part in cleaned:
		placed.append(part)
		_spawn_part(part)
	return true

func structure_report() -> Dictionary:
	var sizes: Array = []
	for index in range(PARTS.size()):
		sizes.append(_part_size(index))
	return SCAN.summarize(placed, sizes)
