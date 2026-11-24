extends CharacterBody3D
class_name GenesisPlayer

signal request_interact

const SPEED: float = 7.0
const SPRINT_SPEED: float = 11.0
const JUMP_SPEED: float = 9.0
var camera_node: Camera3D
var model: Node3D
var facing: Vector3 = Vector3.FORWARD
var interaction_enabled: bool = true

func _ready() -> void:
	name = "Inventor"
	floor_snap_length = 0.6
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.9
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position.y = 0.95
	add_child(collider)
	model = Node3D.new()
	model.name = "InventorVisual_Placeholder"
	add_child(model)
	_add_body_part(Vector3(0, 1.16, 0), Vector3(0.88, 1.15, 0.48), Color("d5b477"))
	_add_body_part(Vector3(0, 1.91, 0), Vector3(0.54, 0.51, 0.48), Color("eed3aa"))
	_add_body_part(Vector3(-0.23, 0.47, 0), Vector3(0.3, 0.9, 0.38), Color("45596c"))
	_add_body_part(Vector3(0.23, 0.47, 0), Vector3(0.3, 0.9, 0.38), Color("45596c"))
	_add_body_part(Vector3(0, 1.2, 0.35), Vector3(0.7, 0.65, 0.14), Color("317f87"))

func _add_body_part(pos: Vector3, size: Vector3, tone: Color) -> void:
	var m := BoxMesh.new()
	m.size = size
	var surface := StandardMaterial3D.new()
	surface.albedo_color = tone
	surface.roughness = 0.8
	m.material = surface
	var n := MeshInstance3D.new()
	n.mesh = m
	n.position = pos
	model.add_child(n)

func _physics_process(delta: float) -> void:
	if not interaction_enabled:
		velocity = Vector3.ZERO
		return
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	elif Input.is_key_pressed(KEY_SPACE):
		velocity.y = JUMP_SPEED
	var movement := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): movement.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): movement.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): movement.y += 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): movement.y -= 1
	movement = movement.normalized()
	if camera_node != null:
		var basis_forward := -camera_node.global_transform.basis.z
		basis_forward.y = 0
		basis_forward = basis_forward.normalized()
		var basis_right := camera_node.global_transform.basis.x
		basis_right.y = 0
		basis_right = basis_right.normalized()
		var direction := basis_right * movement.x + basis_forward * movement.y
		if direction.length_squared() > 0.001:
			facing = direction.normalized()
			model.rotation.y = atan2(-facing.x, -facing.z)
		var speed: float = SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else SPEED
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	move_and_slide()

func set_driving(value: bool) -> void:
	interaction_enabled = not value
	visible = not value
	set_physics_process(not value)
	collision_layer = 0 if value else 1
	collision_mask = 0 if value else 1
