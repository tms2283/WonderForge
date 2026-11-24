extends CharacterBody3D
## Low-cost third-person explorer, orbit camera, jump and sprint.
class_name WFAvatar

var speed: float = 6.0
var turn_speed: float = 10.0
var gravity_accel: float = 22.0
var jump_impulse: float = 7.0
var active: bool = true
var view_yaw: float = 0.0
var view_pitch: float = -0.20
var arm: SpringArm3D
var eye: Camera3D
var model: Node3D

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.36
    capsule.height = 1.8
    var collision := CollisionShape3D.new()
    collision.shape = capsule
    collision.position.y = 0.9
    add_child(collision)
    model = Node3D.new()
    model.name = "ExplorerSilhouette"
    add_child(model)
    _mesh(model, CapsuleMesh.new(), Vector3(0, 1.0, 0), Color("486d70"), Vector3(0.42, 0.82, 0.32))
    _mesh(model, SphereMesh.new(), Vector3(0, 1.84, 0), Color("edb789"), Vector3(0.31, 0.34, 0.29))
    _mesh(model, BoxMesh.new(), Vector3(0, 1.44, -0.24), Color("cd8355"), Vector3(0.67, 0.20, 0.20))
    _mesh(model, BoxMesh.new(), Vector3(0.28, 1.1, 0), Color("ac7139"), Vector3(0.19, 0.59, 0.23))
    _mesh(model, BoxMesh.new(), Vector3(-0.28, 1.1, 0), Color("ac7139"), Vector3(0.19, 0.59, 0.23))
    arm = SpringArm3D.new()
    arm.spring_length = 6.2
    arm.position.y = 1.65
    add_child(arm)
    eye = Camera3D.new()
    eye.current = true
    eye.fov = 67.0
    arm.add_child(eye)
    _sync_camera()

func _mesh(parent: Node3D, mesh: PrimitiveMesh, pos: Vector3, tint: Color, scaling: Vector3) -> void:
    var m := MeshInstance3D.new()
    m.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.roughness = 0.78
    m.material_override = mat
    m.position = pos
    m.scale = scaling
    parent.add_child(m)

func _sync_camera() -> void:
    arm.rotation = Vector3(view_pitch, view_yaw, 0)

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        view_yaw -= event.relative.x * 0.006
        view_pitch = clampf(view_pitch - event.relative.y * 0.005, -0.85, 0.20)
        _sync_camera()

func _physics_process(delta: float) -> void:
    if not active:
        return
    var x: float = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
    var y: float = float(Input.is_key_pressed(KEY_W)) - float(Input.is_key_pressed(KEY_S))
    x += Input.get_joy_axis(0, JOY_AXIS_LEFT_X) if Input.get_connected_joypads().size() > 0 else 0.0
    y += -Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) if Input.get_connected_joypads().size() > 0 else 0.0
    var direction := Vector2(x, y).normalized()
    var basis := Basis(Vector3.UP, view_yaw)
    var motion := (basis * Vector3(direction.x, 0, -direction.y)).normalized()
    var move_speed := speed * (1.55 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
    velocity.x = move_toward(velocity.x, motion.x * move_speed, 18 * delta)
    velocity.z = move_toward(velocity.z, motion.z * move_speed, 18 * delta)
    velocity.y -= gravity_accel * delta
    if is_on_floor():
        velocity.y = -0.25
        if Input.is_key_pressed(KEY_SPACE):
            velocity.y = jump_impulse
    move_and_slide()
    if direction.length() > 0.1:
        model.rotation.y = lerp_angle(model.rotation.y, atan2(-motion.x, -motion.z), minf(1, turn_speed * delta))
