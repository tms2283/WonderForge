extends SceneTree

# Native Godot engine geometry regression test.
const SCAN := preload("res://scripts/assembly_scan.gd")
const BUILDER := preload("res://scripts/world_builder.gd")
var errors: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, note: String) -> void:
	if not ok:
		errors.append(note)
		push_error("WF ASSEMBLY SCAN FAIL: " + note)

func _part(x: float, z: float, yaw: float = 0.0) -> Dictionary:
	return {"kind":0, "p":[x, 1.0, z], "rot":yaw}

func _run() -> void:
	var sizes: Array = [Vector3(3.5, 0.35, 1.0)]
	_check(bool(SCAN.summarize([], sizes)["valid"]), "empty scan valid")
	var chain: Array = [_part(0.0,0.0), _part(3.5,0.0), _part(7.0,0.0)]
	var connected: Dictionary = SCAN.summarize(chain, sizes)
	_check(int(connected["contact_pairs"]) == 2, "face contacts found")
	_check(int(connected["components"]) == 1 and int(connected["largest_connected"]) == 3, "single connected group")
	_check(bool(connected["design_ready"]) and float(connected["horizontal_span_m"]) > 10.0, "span requires continuous geometry")
	var alone: Dictionary = SCAN.summarize(chain + [_part(30.0,0.0)], sizes)
	_check(int(alone["components"]) == 2 and int(alone["largest_connected"]) == 3, "disconnected pieces not included")
	var spaced: Dictionary = SCAN.summarize([_part(0.0,0.0), _part(4.5,0.0), _part(9.0,0.0)], sizes)
	_check(not bool(spaced["design_ready"]) and int(spaced["components"]) == 3, "gapped pieces rejected")
	var turned: Dictionary = SCAN.summarize([_part(0.0,0.0,PI/2), _part(0.0,3.5,PI/2)], sizes)
	_check(int(turned["contact_pairs"]) == 1, "rotated AABB correctly contacts")
	var builder := BUILDER.new()
	root.add_child(builder)
	await process_frame
	builder.placed = chain.duplicate(true)
	var live: Dictionary = builder.structure_report()
	_check(bool(live["design_ready"]) and int(live["largest_connected"]) == 3, "runtime builder integrates graph")
	builder.queue_free()
	await process_frame
	if errors.is_empty():
		print("WF ASSEMBLY SCAN PASS: face contacts, components, spans, rotations, live world integration")
		quit(0)
	else:
		printerr("WF ASSEMBLY SCAN CONTRACT FAIL: ", errors)
		quit(1)
