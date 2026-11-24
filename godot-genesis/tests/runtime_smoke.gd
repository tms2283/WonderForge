extends SceneTree

# Actual Godot-engine game-system test. Never substitute static text checks.
# Execute: godot --headless --path . --script res://tests/runtime_smoke.gd
const MODEL := preload("res://scripts/rover_blueprint.gd")
const ROVER := preload("res://scripts/vehicle.gd")
const GARAGE := preload("res://scripts/rover_garage.gd")
const COURSE := preload("res://scripts/trial_course.gd")
const JOURNAL := preload("res://scripts/engineering_journal.gd")
const BUILD := preload("res://scripts/world_builder.gd")
const INPUTS := preload("res://scripts/input_actions.gd")
const ORBIT := preload("res://scripts/orbit_mentor.gd")
var errors: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	if not value:
		errors.append(message)
		push_error("WF ENGINE TEST FAIL: " + message)

func _run() -> void:
	INPUTS.install()
	_check(InputMap.has_action("wf_forward") and InputMap.has_action("wf_camera_left"),"desktop/controller action maps installed")
	var original := MODEL.DEFAULT.duplicate(true)
	var high_torque := original.duplicate(true)
	high_torque["motor"] = "torque"
	high_torque["gearbox"] = "climb"
	var light := original.duplicate(true)
	light["frame"] = "racer"
	light["battery"] = "light"
	_check(MODEL.strict_valid(original),"factory blueprint validates")
	_check(MODEL.stats(high_torque)["engine_force"] > MODEL.stats(original)["engine_force"],"motor/gear choices change force")
	_check(MODEL.stats(light)["mass_kg"] < MODEL.stats(original)["mass_kg"],"frame/battery choices change mass")
	_check(MODEL.clean({"motor":"NOT_A_MOTOR"})["motor"] == "balanced","untrusted config is sanitized")
	_check(not MODEL.strict_valid({"schema":MODEL.SCHEMA}),"incomplete blueprint is rejected")

	var test_root := Node3D.new()
	test_root.name = "SimulationContractTest"
	root.add_child(test_root)
	var rover := ROVER.new()
	test_root.add_child(rover)
	await process_frame
	_check(rover.all_wheels.size()==4,"rover has four physics wheels")
	rover.apply_build(high_torque)
	_check(absf(rover.mass-MODEL.stats(high_torque)["mass_kg"])<0.01,"blueprint drives rigidbody mass")
	rover.apply_build(light)
	_check(absf(rover.all_wheels[0].wheel_radius-MODEL.stats(light)["wheel_radius_m"])<0.01,"blueprint drives actual wheel radius")

	var builder := BUILD.new()
	test_root.add_child(builder)
	await process_frame
	builder.set_active(true)
	builder.ghost.global_position=Vector3(2,1,2)
	builder.preview_legal=true
	_check(builder.place(),"builder places collision-backed part")
	_check(builder.placed.size()==1 and builder.parts_root.get_child_count()==1,"world stores construction piece")
	_check(builder.undo_last()==0 and builder.placed.is_empty(),"world building undo")
	_check(builder.redo_last() and builder.placed.size()==1,"world building redo")

	var garage := GARAGE.new()
	test_root.add_child(garage)
	await process_frame
	garage.open_garage(high_torque)
	_check(garage.active and garage.visible,"garage opens as usable interface")
	_check(garage.selectors.size()==6,"six actual editable engineering choices")
	garage.close_garage()
	_check(not garage.visible,"garage closes cleanly")

	var orbit := ORBIT.new()
	test_root.add_child(orbit)
	await process_frame
	_check(orbit.offline_answer("Explain my gears on a hill").contains("gearing"),"offline mentor has substantive mechanical guidance")
	_check(not orbit.local_model_toggle.button_pressed,"optional network model starts DISABLED")
	orbit.toggle()
	_check(orbit.active,"mentor opens as a real UI")
	orbit.toggle()
	_check(not orbit.active,"mentor closes without model calls")

	var course := COURSE.new()
	test_root.add_child(course)
	await process_frame
	var arrived: Array[Dictionary] = []
	course.run_completed.connect(func(report: Dictionary) -> void: arrived.append(report))
	course.start_trial(original,"Trail wheels should maintain grip")
	for gate in COURSE.GATE_COORDS:
		course.update_drive(Vector3(gate.x,0,gate.y),{"peak_speed_kmh":21.5,"distance_m":150.0,"charge_percent":61.2,"wheel_contact":4},1.2)
	_check(not course.active and arrived.size()==1,"six checkpoint course completes in order")
	if not arrived.is_empty():
		_check(float(arrived[0]["time_s"])>0,"actual elapsed trial time recorded")
		var journal := JOURNAL.new()
		_check(journal.valid_record(arrived[0]),"journal validates a real trial result")
		_check(journal.add_result(arrived[0]),"journal persists validated trial")
		journal.load_records()
		_check(not journal.records.is_empty(),"journal survives reload")
		var improved := arrived[0].duplicate(true)
		improved["time_s"] = 5.0
		improved["blueprint"] = high_torque
		_check(journal.add_result(improved),"second experiment persists")
		_check(journal.compare_last_two().contains("motor") or journal.compare_last_two().contains("design variables"),"comparison describes changed variables")

	test_root.queue_free()
	await process_frame
	if errors.is_empty():
		print("WF ENGINE CONTRACT PASS: cross-platform controls, blueprint physics, builder undo/redo, garage, offline mentor, six gates, journal")
		quit(0)
	else:
		printerr("WF ENGINE CONTRACT FAIL: ", errors)
		quit(1)
