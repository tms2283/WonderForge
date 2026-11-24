extends CharacterBody3D
class_name GenesisPlayer

# Original animated preview protagonist. Procedural silhouette replaces the
# prototype crate-person; final art still requires a skinned authored character.
const SPEED: float = 7.0
const SPRINT_SPEED: float = 11.0
const JUMP_SPEED: float = 9.0
var camera_node: Camera3D
var model: Node3D
var facing: Vector3 = Vector3.FORWARD
var interaction_enabled: bool = true
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var cloak: Node3D
var walking_phase: float = 0.0
var idle_clock: float = 0.0

func _mat(tint: Color, metal: float = 0.0, rough: float = 0.8) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.roughness = rough
	mat.metallic = metal
	return mat

func _mesh(parent: Node3D, shape: Mesh, name_str: String, at: Vector3, color: Color, metal: float = 0.0) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = name_str
	n.mesh = shape
	n.position = at
	n.material_override = _mat(color,metal)
	parent.add_child(n)
	return n

func _capsule(parent: Node3D, name_str: String, at: Vector3, radius: float, height: float, tint: Color) -> MeshInstance3D:
	var shape := CapsuleMesh.new()
	shape.radius = radius
	shape.height = height
	return _mesh(parent,shape,name_str,at,tint)

func _sphere(parent: Node3D, name_str: String, at: Vector3, radius: float, tint: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = 2.0*radius
	shape.radial_segments = 16
	shape.rings = 8
	return _mesh(parent,shape,name_str,at,tint)

func _box(parent: Node3D, name_str: String, at: Vector3, dims: Vector3, tint: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = dims
	return _mesh(parent,shape,name_str,at,tint)

func _ready() -> void:
	name = "Inventor_OriginalPreview"
	floor_snap_length = 0.6
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.9
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position.y = 0.95
	add_child(collider)
	model = Node3D.new()
	model.name = "OriginalInventorSilhouette_ArtToBeReplaced"
	add_child(model)
	_capsule(model,"WeatheredLeatherFieldCoat",Vector3(0,1.25,0),0.40,1.02,Color("8a6f50"))
	_capsule(model,"DarkerApron",Vector3(0,1.16,-0.19),0.25,0.82,Color("405f66"))
	_sphere(model,"NaturalFace",Vector3(0,1.99,-0.02),0.28,Color("ddb58c"))
	var hair := _sphere(model,"ShortCroppedHair",Vector3(0,2.17,0.04),0.265,Color("43372e"))
	hair.scale = Vector3(1.01,0.55,0.90)
	_box(model,"GoggleStrap",Vector3(0,2.02,-0.218),Vector3(0.50,0.07,0.08),Color("304d55"))
	for side in [-1.0,1.0]:
		_sphere(model,"CopperGoggleLens",Vector3(side*0.12,2.01,-0.27),0.091,Color("b9854d"))
		var pauldron := _sphere(model,"WeatheredShoulderPlate",Vector3(side*0.43,1.63,0),0.205,Color("68898a"))
		pauldron.scale = Vector3(1.08,0.75,1.15)
	left_arm = Node3D.new()
	right_arm = Node3D.new()
	left_leg = Node3D.new()
	right_leg = Node3D.new()
	left_arm.position = Vector3(-0.49,1.53,0)
	right_arm.position = Vector3(0.49,1.53,0)
	left_leg.position = Vector3(-0.22,0.86,0)
	right_leg.position = Vector3(0.22,0.86,0)
	for limb in [left_arm,right_arm,left_leg,right_leg]: model.add_child(limb)
	_capsule(left_arm,"LeftCoatSleeve",Vector3(0,-0.31,0),0.14,0.69,Color("667c80"))
	_capsule(right_arm,"RightCoatSleeve",Vector3(0,-0.31,0),0.14,0.69,Color("667c80"))
	_sphere(left_arm,"LeatherGlove",Vector3(0,-0.66,-0.01),0.13,Color("5f4737"))
	_sphere(right_arm,"LeatherGlove",Vector3(0,-0.66,-0.01),0.13,Color("5f4737"))
	_capsule(left_leg,"LeftFieldTrousers",Vector3(0,-0.36,0),0.19,0.76,Color("354d58"))
	_capsule(right_leg,"RightFieldTrousers",Vector3(0,-0.36,0),0.19,0.76,Color("354d58"))
	for leg in [left_leg,right_leg]:
		_box(leg,"LeatherWalkingBoot",Vector3(0,-0.75,-0.105),Vector3(0.32,0.28,0.51),Color("44362f"))
	_box(model,"BrassWristInstrument",Vector3(0.61,1.08,-0.16),Vector3(0.24,0.18,0.16),Color("c59d62"))
	_box(model,"FieldToolPouch",Vector3(-0.42,0.97,0.21),Vector3(0.29,0.38,0.30),Color("70513b"))
	cloak = Node3D.new()
	cloak.name = "OriginalTerracottaHalfCape_Preview"
	cloak.position = Vector3(0,1.62,0.24)
	model.add_child(cloak)
	var cape_mesh := ArrayMesh.new()
	var array: Array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(-0.37,0,0),Vector3(0.38,0,0),Vector3(-0.53,-0.93,0.13),Vector3(0.50,-1.00,0.13)])
	array[Mesh.ARRAY_INDEX] = PackedInt32Array([0,2,1,1,2,3])
	cape_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,array)
	var cape_visual := _mesh(cloak,cape_mesh,"WindWornHalfCape",Vector3.ZERO,Color("a95f4c"))
	var cape_mat := cape_visual.material_override as StandardMaterial3D
	cape_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

func _physics_process(delta: float) -> void:
	if not interaction_enabled:
		velocity = Vector3.ZERO
		return
	idle_clock += delta
	if not is_on_floor():
		velocity.y -= 20.0*delta
	elif Input.is_action_just_pressed("wf_jump"):
		velocity.y = JUMP_SPEED
	var move_axis := Input.get_vector("wf_left","wf_right","wf_backward","wf_forward")
	var direction := Vector3.ZERO
	if camera_node != null:
		var forward := -camera_node.global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		var right := camera_node.global_transform.basis.x
		right.y = 0
		right = right.normalized()
		direction = (right*move_axis.x+forward*move_axis.y).normalized()
	var speed := SPRINT_SPEED if Input.is_action_pressed("wf_sprint") else SPEED
	var acceleration := 25.0 if is_on_floor() else 8.0
	velocity.x = move_toward(velocity.x,direction.x*speed,acceleration*delta)
	velocity.z = move_toward(velocity.z,direction.z*speed,acceleration*delta)
	if direction.length_squared() > 0.005:
		facing = direction
		model.rotation.y = lerp_angle(model.rotation.y,atan2(-facing.x,-facing.z),clampf(12.0*delta,0,1))
	var pace := clampf(Vector2(velocity.x,velocity.z).length()/SPEED,0,1.55)
	walking_phase += delta*(6.0+pace*4.2)
	left_leg.rotation.x = lerpf(left_leg.rotation.x,sin(walking_phase)*0.50*pace,clampf(14*delta,0,1))
	right_leg.rotation.x = lerpf(right_leg.rotation.x,-sin(walking_phase)*0.50*pace,clampf(14*delta,0,1))
	left_arm.rotation.x = lerpf(left_arm.rotation.x,-sin(walking_phase)*0.32*pace,clampf(11*delta,0,1))
	right_arm.rotation.x = lerpf(right_arm.rotation.x,sin(walking_phase)*0.32*pace,clampf(11*delta,0,1))
	cloak.rotation.x = sin(walking_phase*0.52)*0.05+pace*0.075
	model.position.y = sin(walking_phase*2)*0.025*pace + sin(idle_clock*1.5)*0.015
	move_and_slide()

func set_driving(value: bool) -> void:
	interaction_enabled = not value
	visible = not value
	set_physics_process(not value)
	collision_layer = 0 if value else 1
	collision_mask = 0 if value else 1
