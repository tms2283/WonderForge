extends VehicleBody3D
class_name GenesisRover

# A DRIVABLE PROTOTYPE, not finished machine physics. Production should replace
# the wheel simulation with custom RigidBody3D raycast suspension (see bible).
var driving: bool = false
var max_engine_force: float = 120.0
var steering_limit: float = 0.46

func _ready() -> void:
	name = "ForgeRover_Prototype"
	mass = 700.0
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.1, 0.7, 3.7)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.6
	add_child(collision)
	var chassis := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.0, 0.68, 3.5)
	chassis.mesh = body_mesh
	chassis.position.y = 0.66
	var finish := StandardMaterial3D.new()
	finish.albedo_color = Color("e0a65e")
	finish.metallic = 0.43
	finish.roughness = 0.34
	chassis.material_override = finish
	add_child(chassis)
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.55, 0.63, 1.4)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0,1.25,-0.1)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color("416c7e")
	glass.metallic = 0.55
	glass.roughness = 0.15
	cabin.material_override = glass
	add_child(cabin)
	for side in [-1,1]:
		for axle in [-1,1]:
			var wheel := VehicleWheel3D.new()
			wheel.position = Vector3(float(side) * 1.12, 0.45, float(axle) * 1.18)
			wheel.wheel_radius = 0.56
			wheel.wheel_rest_length = 0.27
			wheel.wheel_friction_slip = 2.8
			wheel.suspension_stiffness = 30.0
			wheel.damping_compression = 0.7
			wheel.damping_relaxation = 0.8
			wheel.use_as_traction = axle > 0
			wheel.use_as_steering = axle < 0
			wheel.name = "Wheel_%s_%s" % [side, axle]
			add_child(wheel)
			var ring := CylinderMesh.new()
			ring.top_radius = 0.53
			ring.bottom_radius = 0.53
			ring.height = 0.26
			ring.radial_segments = 16
			var tire := MeshInstance3D.new()
			tire.mesh = ring
			tire.rotation.z = PI / 2.0
			var rubber := StandardMaterial3D.new()
			rubber.albedo_color = Color("273742")
			rubber.roughness = 0.94
			tire.material_override = rubber
			wheel.add_child(tire)

func _physics_process(_delta: float) -> void:
	if not driving:
		engine_force = 0.0
		brake = 4.0
		steering = move_toward(steering, 0, 0.02)
		return
	var forward := float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	var reverse := float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
	engine_force = (forward - reverse * 0.55) * max_engine_force
	brake = 15.0 if Input.is_key_pressed(KEY_SPACE) else 0.0
	var right := float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
	var left := float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	steering = move_toward(steering, (left-right) * steering_limit, 0.04)
