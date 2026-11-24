extends Node3D
class_name GenesisCamera

var target: Node3D
var camera: Camera3D
var orbit_yaw: float = 0.6
var orbit_pitch: float = -0.27
var distance: float = 12.0
var sensitivity: float = 0.007
var smoothing: float = 8.0
var dragging: bool = false

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "AdventureCamera"
	camera.fov = 63.0
	camera.far = 400.0
	camera.current = true
	add_child(camera)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(5.0, distance - 1.2)
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(25.0, distance + 1.2)
	elif event is InputEventMouseMotion and dragging:
		orbit_yaw -= event.relative.x * sensitivity
		orbit_pitch = clampf(orbit_pitch - event.relative.y * sensitivity, -1.0, 0.16)

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target): return
	orbit_yaw += (Input.get_action_strength("wf_camera_left")-Input.get_action_strength("wf_camera_right"))*delta*2.4
	orbit_pitch = clampf(orbit_pitch + (Input.get_action_strength("wf_camera_up")-Input.get_action_strength("wf_camera_down"))*delta*1.5,-1.0,0.16)
	var pivot: Vector3 = target.global_position + Vector3.UP * (2.5 if target is VehicleBody3D else 1.7)
	var offset := Vector3(
		sin(orbit_yaw) * cos(orbit_pitch) * distance,
		-sin(orbit_pitch) * distance,
		cos(orbit_yaw) * cos(orbit_pitch) * distance
	)
	var wanted := pivot + offset
	camera.global_position = camera.global_position.lerp(wanted, clampf(delta * smoothing, 0, 1))
	camera.look_at(pivot, Vector3.UP)
