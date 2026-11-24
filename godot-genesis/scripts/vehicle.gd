extends VehicleBody3D
class_name GenesisRover

# VehicleBody3D is a deliberately LIMITED physics model. Engineering lessons
# describe trends, not certified vehicle dynamics. A production custom
# suspension/constraint solver belongs behind the same Blueprint API.
const BLUEPRINT := preload("res://scripts/rover_blueprint.gd")
var driving: bool = false
var blueprint: Dictionary = {}
var metrics: Dictionary = {}
var battery_remaining: float = 180.0
var distance_m: float = 0.0
var peak_speed_kmh: float = 0.0
var battery_start: float = 180.0
var traveled_time: float = 0.0
var all_wheels: Array[VehicleWheel3D] = []
var chassis_mesh: MeshInstance3D
var cabin_mesh: MeshInstance3D
var bumper_front: MeshInstance3D
var bumper_rear: MeshInstance3D
var running_lamp: OmniLight3D
var last_position: Vector3
var steering_input: float = 0.0

func _mat(tint: Color, metal: float = 0.0, rough: float = 0.65) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = tint
	m.metallic = metal
	m.roughness = rough
	return m

func _box(parent: Node3D, name_str: String, where: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.name = name_str
	visual.mesh = mesh
	visual.material_override = mat
	visual.position = where
	parent.add_child(visual)
	return visual

func _tube(parent: Node3D, name_str: String, where: Vector3, radius: float, length: float, tint: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = length
	mesh.radial_segments = 16
	var n := MeshInstance3D.new()
	n.name = name_str
	n.mesh = mesh
	n.position = where
	n.rotation.z = PI * 0.5
	n.material_override = _mat(tint, 0.42, 0.48)
	parent.add_child(n)
	return n

func _ready() -> void:
	name = "ForgeRover_ModularPrototype"
	continuous_cd = true
	can_sleep = false
	var collider := CollisionShape3D.new()
	var collision_mesh := BoxShape3D.new()
	collision_mesh.size = Vector3(2.24, 0.68, 3.8)
	collider.shape = collision_mesh
	collider.position.y = 0.67
	add_child(collider)
	chassis_mesh = _box(self,"RoundedChassis_ArtReplacement", Vector3(0,0.77,0),Vector3(2.24,0.63,3.8),_mat(Color("bf8f55"),0.38,0.37))
	cabin_mesh = _box(self,"GlassCabin_ArtReplacement", Vector3(0,1.27,-0.2),Vector3(1.65,0.58,1.54),_mat(Color("476f7d"),0.52,0.21))
	bumper_front = _box(self,"FrontBumper",Vector3(0,0.62,-2.01),Vector3(1.99,0.21,0.29),_mat(Color("283d46"),0.57,0.35))
	bumper_rear = _box(self,"RearBumper",Vector3(0,0.62,2.01),Vector3(1.99,0.21,0.29),_mat(Color("283d46"),0.57,0.35))
	for side in [-1,1]:
		for axle in [-1,1]:
			var wheel := VehicleWheel3D.new()
			wheel.name = "Wheel_%s_%s" % [side,axle]
			wheel.use_as_steering = axle < 0
			wheel.use_as_traction = axle > 0
			add_child(wheel)
			all_wheels.append(wheel)
			var tyre := CylinderMesh.new()
			tyre.height = 0.27
			tyre.radial_segments = 20
			var tyre_visual := MeshInstance3D.new()
			tyre_visual.name = "RubberTire"
			tyre_visual.mesh = tyre
			tyre_visual.rotation.z = PI / 2
			tyre_visual.material_override = _mat(Color("212c34"),0,0.96)
			wheel.add_child(tyre_visual)
			var hub := _tube(wheel,"CopperHub",Vector3.ZERO,0.20,0.30,Color("cd965e"))
			hub.position.x = 0.0
			var glint := _tube(wheel,"AxlePivot",Vector3.ZERO,0.085,0.34,Color("edf0dc"))
			glint.position.x = 0.0
	for side in [-1,1]:
		for front in [-1,1]:
			_box(self,"HeadlightOrSignal",Vector3(float(side)*0.78,0.91,float(front)*1.93), Vector3(0.23,0.18,0.17),_mat(Color("ffdfa0") if front < 0 else Color("d65747"),0.1,0.19))
	# Decorative body ribs. These are not collision or structural engineering parts.
	for side in [-1,1]:
		_box(self,"ChassisRail",Vector3(float(side)*0.80,0.33,0),Vector3(0.14,0.18,3.56),_mat(Color("334952"),0.6,0.42))
		_box(self,"SuspensionStrut",Vector3(float(side)*0.93,0.42,0),Vector3(0.10,0.16,2.83),_mat(Color("b4a482"),0.5,0.46))
	running_lamp = OmniLight3D.new()
	running_lamp.name = "WorkshopSignal_BatteryPresent"
	running_lamp.position = Vector3(0,1.72,0)
	running_lamp.light_color = Color("9ff6d5")
	running_lamp.light_energy = 0.22
	running_lamp.omni_range = 3.0
	add_child(running_lamp)
	apply_build(BLUEPRINT.DEFAULT)
	last_position = global_position

func apply_build(value: Variant) -> void:
	blueprint = BLUEPRINT.clean(value)
	metrics = BLUEPRINT.stats(blueprint)
	mass = float(metrics["mass_kg"])
	var length_m: float = metrics["chassis_length_m"]
	var width_m: float = metrics["chassis_width_m"]
	var radius: float = metrics["wheel_radius_m"]
	if chassis_mesh != null:
		(chassis_mesh.mesh as BoxMesh).size = Vector3(width_m,0.63,length_m)
		(cabin_mesh.mesh as BoxMesh).size = Vector3(width_m*0.74,0.58,length_m*0.41)
		bumper_front.position.z = -length_m*0.52
		bumper_rear.position.z = length_m*0.52
	for wheel in all_wheels:
		var is_left := wheel.name.begins_with("Wheel_-1")
		var front := wheel.name.ends_with("_-1")
		wheel.position = Vector3((-1.0 if is_left else 1.0)*(width_m*0.51),0.42,(-1.0 if front else 1.0)*(length_m*0.33))
		wheel.wheel_radius = radius
		wheel.wheel_rest_length = float(metrics["suspension_rest_m"])
		wheel.suspension_stiffness = float(metrics["suspension_stiffness"])
		wheel.damping_compression = float(metrics["damping"])
		wheel.damping_relaxation = float(metrics["damping"])*1.14
		wheel.wheel_friction_slip = float(metrics["tire_grip"])
		wheel.wheel_roll_influence = 0.12
		var tyre := wheel.get_node("RubberTire") as MeshInstance3D
		(tyre.mesh as CylinderMesh).top_radius = radius
		(tyre.mesh as CylinderMesh).bottom_radius = radius
	battery_remaining = minf(battery_remaining,float(metrics["battery_units"]))
	battery_start = float(metrics["battery_units"])

func restore_charge() -> void:
	battery_remaining = float(metrics.get("battery_units",180.0))
	battery_start = battery_remaining

func reset_trial(at: Vector3, toward: Vector3) -> void:
	driving = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = at
	look_at(Vector3(toward.x, at.y, toward.z),Vector3.UP)
	restore_charge()
	distance_m = 0.0
	peak_speed_kmh = 0.0
	traveled_time = 0.0
	last_position = at
	driving = true

func get_telemetry() -> Dictionary:
	return {
		"speed_kmh": linear_velocity.length()*3.6,
		"peak_speed_kmh": peak_speed_kmh,
		"distance_m": distance_m,
		"charge_units": battery_remaining,
		"charge_percent": 100.0*battery_remaining/maxf(1.0,float(metrics.get("battery_units",180.0))),
		"mass_kg": mass,
		"time_s": traveled_time,
		"wheel_contact": _wheel_contact_count(),
	}

func _wheel_contact_count() -> int:
	var count := 0
	for wheel in all_wheels:
		if wheel.is_in_contact(): count += 1
	return count

func _physics_process(delta: float) -> void:
	if not driving:
		engine_force = 0
		brake = 8
		steering = move_toward(steering,0.0,delta*2)
		last_position = global_position
		return
	traveled_time += delta
	distance_m += (global_position-last_position).length()
	last_position = global_position
	var speed: float = linear_velocity.length()
	peak_speed_kmh = maxf(peak_speed_kmh,speed*3.6)
	var throttle := float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) - float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))*0.55
	var engine_cap: float = metrics.get("speed_cap_mps",24.0)
	var gear_factor: float = clampf(1.0-speed/maxf(2.0,engine_cap),0.0,1.0)
	engine_force = throttle*float(metrics["engine_force"])*gear_factor if battery_remaining>0.1 else 0.0
	brake = 22.0 if Input.is_key_pressed(KEY_SPACE) else 0.0
	var turn := float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)) - float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
	steering_input = move_toward(steering_input,turn,delta*3)
	steering = steering_input*float(metrics["turn_limit_rad"])*clampf(1.0-speed/47.0,0.42,1.0)
	if absf(throttle)>0.05 and battery_remaining>0.0:
		battery_remaining = maxf(0.0,battery_remaining - delta*float(metrics["drain_factor"])*(0.35+1.2*absf(throttle)+speed*0.023))
	if running_lamp != null:
		running_lamp.visible = battery_remaining>0.1
