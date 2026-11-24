extends SceneTree

# Godot engine contract, including real FileAccess and DirAccess operations.
# godot --headless --path . --script res://tests/save_guard_smoke.gd
const SAVE := preload("res://scripts/save_guard.gd")
const ROVER := preload("res://scripts/rover_blueprint.gd")
const PATH := "user://wf-save-guard-contract.json"
var errors: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		errors.append(message)
		push_error("WF SAVE GUARD FAIL: " + message)

func _cleanup() -> void:
	for suffix in ["", ".bak", ".tmp"]:
		var path: String = PATH + str(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _run() -> void:
	_cleanup()
	var original := {
		"schema": SAVE.SAVE_SCHEMA,
		"player":[0.0, 2.0, 12.0],
		"visited":{"FoundersWorkshop":true},
		"resources":{"timber":12, "stone":8, "alloy":4, "energy":0},
		"story":{"workshop":true, "beacon":false, "constructed":false, "rover":false},
		"assembly":{"schema":SAVE.ASSEMBLY_SCHEMA, "parts":[{"kind":0, "p":[2.0, 1.0, 2.0], "rot":0.0}]},
		"rover_blueprint":ROVER.DEFAULT.duplicate(true),
		"journal_version":"wonderforge.genesis.journal.v1",
	}
	_check(SAVE.valid_payload(original), "valid v1 save accepted")
	_check(SAVE.write_atomic(original, PATH), "first save committed")
	var first := SAVE.read_best(PATH)
	_check(bool(first.get("ok", false)) and first.get("source") == "primary", "primary save validated")
	var edited := original.duplicate(true)
	edited["resources"]["timber"] = 33
	_check(SAVE.write_atomic(edited, PATH), "second save committed with backup")
	_check(FileAccess.file_exists(PATH + ".bak"), "last-known-good backup created")
	var invalid := edited.duplicate(true)
	invalid["player"] = [INF, 0, 0]
	_check(not SAVE.write_atomic(invalid, PATH), "non-finite coordinates refused")
	var malformed := FileAccess.open(PATH, FileAccess.WRITE)
	_check(malformed != null, "test corruption file opened")
	if malformed != null:
		malformed.store_string("{broken JSON")
		malformed.close()
	var recovered := SAVE.read_best(PATH)
	_check(bool(recovered.get("ok", false)) and recovered.get("source") == "backup", "backup recovered after primary corruption")
	if bool(recovered.get("ok", false)):
		_check(int(recovered["data"]["resources"]["timber"]) == 12, "backup is previous valid state")
	_check(FileAccess.file_exists(PATH), "corrupt primary retained for forensics")
	_cleanup()
	if errors.is_empty():
		print("WF SAVE GUARD CONTRACT PASS: schema validation, staged commit, backup and recovery")
		quit(0)
	else:
		printerr("WF SAVE GUARD CONTRACT FAIL: ", errors)
		quit(1)
