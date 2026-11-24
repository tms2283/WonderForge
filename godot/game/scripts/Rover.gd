extends RigidBody3D
class_name WFRover
## Drivable rigid-body prototype with sprung raycast contact points.
## This is deliberately NOT yet a Besiege-grade arbitrary assembly solver.
## Mass, power and wheel counts derive from the player's built blueprint.

signal speed_changed(kph: float)

const WHEEL_POSITIONS := [Vector3(-1.12, 0.02, -1.55), Vector3(1.12, 0.02, -1.55),
                          Vector3(-1.12, 0.02, 1.55), Vector3(1.12, 0.02, 1.55)]
var active: bool = false
var suspension_rays: Array[RayCast3D] = []
var wheels: Array[Node3D] = []
var sprung: bool = false
var speed: float = 0.0
var engine_power: float = 2800.0
var brake_strength: float = 0.96
var spring_stiffness: float = 9000.0
var spring_damping: float = 950.0
var suspension_rest: float = 1.23
var camera_arm: SpringArm3D
var camera: Camera3D

func _ready() -> void:
    name = "WorkingMechanismRover"
    collision_layer = 1
    collision_mask = 1
    can_sleep = false
    mass = 340.0
    linear_damp = 0.32
    angular_damp = 1.05
    var body_shape := BoxShape3D.new()
    body_shape.size = Vector3(2.35, 1.12, 3.7)
    var body_collision := CollisionShape3D.new()
    body_collision.shape = body_shape
    body_collision.position.y = 0.36
    add_child(body_collision)
    WFPartFactory.box(self, Vector3(2.32, 0.34, 3.6), Vector3(0, 0.65, 0), WFPartFactory.material_for("steel"))
    WFPartFactory.box(self, Vector3(1.70, 0.78, 1.28), Vector3(0, 1.0, 0.40), WFPartFactory.material_for("timber"))
    WFPartFactory.box(self, Vector3(1.60, 0.27, 0.98), Vector3(0, 1.43, 0.55), WFPartFactory.material_for("motor"))
    WFPartFactory.box(self, Vector3(1.88, 0.22, 0.22), Vector3(0, 0.55, -1.75), WFPartFactory.material_for("copper"))
    WFPartFactory.box(self, Vector3(1.8, 0.26, 0.22), Vector3(0, 0.55, 1.75), WFPartFactory.material_for("copper"))
    for offset in WHEEL_POSITIONS:
        var wheel := WFPartFactory.create_part("wheel")
        wheel.position = offset - Vector3(0, 0.55, 0)
        add_child(wheel)
        wheels.append(wheel)
        var ray := RayCast3D.new()
        ray.position = offset + Vector3(0, 0.4, 0)
        ray.target_position = Vector3(0, -1.65, 0)
        ray.collision_mask = 1
        ray.exclude_parent = true
        add_child(ray)
        suspension_rays.append(ray)
    camera_arm = SpringArm3D.new()
    camera_arm.spring_length = 8.0
    camera_arm.position = Vector3(0, 2.3, 0)
    camera_arm.rotation.x = -0.28
    add_child(camera_arm)
    camera = Camera3D.new()
    camera.current = false
    camera.fov = 72
    camera_arm.add_child(camera)
    set_active(false)

func configure_blueprint(stats: Dictionary) -> void:
    # Mechanical consequence visible to players: more motors increase tractive power,
    # extra material increases mass, and insufficient wheels trigger warning/fallback.
    var motor_count: int = maxi(1, int(stats.get("motors", 0)))
    var wheel_count: int = int(stats.get("wheels", 0))
    var body_mass: float = float(stats.get("mass", 0.0))
    engine_power = clampf(2400.0 + (motor_count - 1) * 780.0, 2000.0, 5500.0)
    mass = clampf(270.0 + body_mass * 2.2, 250, 800)
    sprung = wheel_count >= 4
    if not sprung:
        engine_power *= 0.55

func set_active(enabled: bool) -> void:
    active = enabled
    if camera != null:
        camera.current = enabled

func _physics_process(delta: float) -> void:
    if not active:
        return
    var throttle := float(Input.is_key_pressed(KEY_W)) - float(Input.is_key_pressed(KEY_S))
    var steer := float(Input.is_key_pressed(KEY_A)) - float(Input.is_key_pressed(KEY_D))
    if Input.get_connected_joypads().size() > 0:
        throttle = -Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
        steer = -Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
    var grounded_count: int = 0
    for i in range(suspension_rays.size()):
        var ray: RayCast3D = suspension_rays[i]
        if ray.is_colliding():
            grounded_count += 1
            var contact_distance: float = ray.global_position.distance_to(ray.get_collision_point())
            var displacement: float = clampf(suspension_rest - contact_distance, -0.6, 0.95)
            var wheel_offset: Vector3 = global_transform.basis * WHEEL_POSITIONS[i]
            var relative_velocity: Vector3 = linear_velocity + angular_velocity.cross(wheel_offset)
            var speed_vertical: float = relative_velocity.dot(global_transform.basis.y)
            var force: float = maxf(0.0, displacement * spring_stiffness - speed_vertical * spring_damping)
            apply_force(global_transform.basis.y * force, wheel_offset)
        wheels[i].rotate_x(delta * linear_velocity.length() * 0.44 * sign(throttle))
    if grounded_count > 0:
        var forwards := -global_transform.basis.z
        apply_central_force(forwards * throttle * engine_power)
        apply_torque(global_transform.basis.y * steer * minf(linear_velocity.length() * 180.0, 3200.0))
        var sideways := global_transform.basis.x
        apply_central_force(-sideways * linear_velocity.dot(sideways) * 800.0)
    if Input.is_key_pressed(KEY_SPACE):
        apply_central_force(-linear_velocity * brake_strength * mass)
    speed = linear_velocity.length() * 3.6
    speed_changed.emit(speed)
    if global_position.y < -18.0:
        global_position = Vector3(48, 3, -4)
        linear_velocity = Vector3.ZERO
        angular_velocity = Vector3.ZERO
