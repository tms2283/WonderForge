extends RefCounted
class_name GenesisInputActions

# One input semantic map on desktop + low-end ARM, deliberately independent of
# visual quality and account save state. Runtime map avoids hidden editor config.
static func _action(name: String, keys: Array[int] = [], joy_button: int = -1, joy_axis: int = -1, direction: float = 0.0) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name,0.18)
	for keycode in keys:
		var key := InputEventKey.new()
		key.physical_keycode = keycode
		if not InputMap.action_has_event(name,key): InputMap.action_add_event(name,key)
	if joy_button >= 0:
		var button := InputEventJoypadButton.new()
		button.button_index = joy_button
		if not InputMap.action_has_event(name,button): InputMap.action_add_event(name,button)
	if joy_axis >= 0:
		var motion := InputEventJoypadMotion.new()
		motion.axis = joy_axis
		motion.axis_value = direction
		if not InputMap.action_has_event(name,motion): InputMap.action_add_event(name,motion)

static func install() -> void:
	_action("wf_left",[KEY_A,KEY_LEFT],-1,JOY_AXIS_LEFT_X,-1.0)
	_action("wf_right",[KEY_D,KEY_RIGHT],-1,JOY_AXIS_LEFT_X,1.0)
	_action("wf_forward",[KEY_W,KEY_UP],-1,JOY_AXIS_LEFT_Y,-1.0)
	_action("wf_backward",[KEY_S,KEY_DOWN],-1,JOY_AXIS_LEFT_Y,1.0)
	_action("wf_camera_left",[],-1,JOY_AXIS_RIGHT_X,-1.0)
	_action("wf_camera_right",[],-1,JOY_AXIS_RIGHT_X,1.0)
	_action("wf_camera_up",[],-1,JOY_AXIS_RIGHT_Y,-1.0)
	_action("wf_camera_down",[],-1,JOY_AXIS_RIGHT_Y,1.0)
	_action("wf_jump",[KEY_SPACE],JOY_BUTTON_A)
	_action("wf_brake",[KEY_SPACE],JOY_BUTTON_B)
	_action("wf_sprint",[KEY_SHIFT],JOY_BUTTON_LEFT_STICK)
