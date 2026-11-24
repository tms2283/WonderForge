extends RefCounted
class_name GenesisSaveGuard

# The on-disk schema remains genesis.save.v1; this protects its transport, not a migration.
# Two copies maximum: current and the last independently validated current payload.
const SAVE_SCHEMA := "wonderforge.genesis.save.v1"
const ASSEMBLY_SCHEMA := "wonderforge.genesis.assembly.v1"
const MAX_BYTES := 512 * 1024
const MAX_PARTS := 300
const BLUEPRINT := preload("res://scripts/rover_blueprint.gd")

static func _bounded_number(n: Variant, limit: float) -> bool:
	return (n is int or n is float) and is_finite(float(n)) and absf(float(n)) <= limit

static func valid_payload(value: Variant) -> bool:
	if not (value is Dictionary): return false
	if value.get("schema", "") != SAVE_SCHEMA: return false
	var position: Variant = value.get("player", [])
	if not (position is Array) or position.size() != 3: return false
	for n in position:
		if not _bounded_number(n, 2000.0): return false
	var resources: Variant = value.get("resources", {})
	var visited: Variant = value.get("visited", {})
	var story: Variant = value.get("story", {})
	if not (resources is Dictionary and visited is Dictionary and story is Dictionary): return false
	if resources.size() > 16 or visited.size() > 256 or story.size() > 32: return false
	for key in resources.keys():
		if not (key is String) or key.length() > 60: return false
		var count: Variant = resources[key]
		if not _bounded_number(count, 100000.0) or float(count) < 0.0: return false
		if float(count) != floorf(float(count)): return false
	for key in visited.keys():
		if not (key is String) or key.length() > 120: return false
		if not (visited[key] is bool): return false
	for key in story.keys():
		if not (key is String) or key.length() > 80: return false
		if not (story[key] is bool): return false
	if not BLUEPRINT.strict_valid(value.get("rover_blueprint", null)): return false
	var assembly: Variant = value.get("assembly", {})
	if not (assembly is Dictionary) or assembly.get("schema", "") != ASSEMBLY_SCHEMA: return false
	var parts: Variant = assembly.get("parts", null)
	if not (parts is Array) or parts.size() > MAX_PARTS: return false
	for part in parts:
		if not (part is Dictionary): return false
		var kind: Variant = part.get("kind", null)
		if not _bounded_number(kind, 5.0) or float(kind) != floorf(float(kind)): return false
		var xyz: Variant = part.get("p", null)
		if not (xyz is Array) or xyz.size() != 3: return false
		for n in xyz:
			if not _bounded_number(n, 3000.0): return false
		if not _bounded_number(part.get("rot", null), 7.0): return false
	return JSON.stringify(value).to_utf8_buffer().size() <= MAX_BYTES

static func _read_one(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"ok":false, "reason":"unreadable"}
	var size := file.get_length()
	if size <= 0 or size > MAX_BYTES:
		file.close()
		return {"ok":false, "reason":"size"}
	var raw := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not valid_payload(parsed): return {"ok":false, "reason":"invalid-payload"}
	return {"ok":true, "data":parsed}

static func read_best(path: String) -> Dictionary:
	var primary := _read_one(path)
	if bool(primary.get("ok", false)):
		return {"ok":true, "source":"primary", "data":primary["data"]}
	var reserve := _read_one(path + ".bak")
	if bool(reserve.get("ok", false)):
		return {"ok":true, "source":"backup", "data":reserve["data"]}
	return {"ok":false, "reason":"no valid save or backup"}

static func write_atomic(value: Variant, path: String) -> bool:
	if not valid_payload(value): return false
	var text_data := JSON.stringify(value, "  ")
	if text_data.to_utf8_buffer().size() > MAX_BYTES: return false
	var staging := path + ".tmp"
	var handle := FileAccess.open(staging, FileAccess.WRITE)
	if handle == null: return false
	handle.store_string(text_data)
	handle.flush()
	var write_error := handle.get_error()
	handle.close()
	var staging_abs := ProjectSettings.globalize_path(staging)
	if write_error != OK or not bool(_read_one(staging).get("ok", false)):
		DirAccess.remove_absolute(staging_abs)
		return false
	var previous := _read_one(path)
	if bool(previous.get("ok", false)):
		# A failed backup copy aborts the transaction rather than destroying the last good copy.
		if DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".bak")) != OK:
			DirAccess.remove_absolute(staging_abs)
			return false
	if DirAccess.rename_absolute(staging_abs, ProjectSettings.globalize_path(path)) != OK:
		DirAccess.remove_absolute(staging_abs)
		return false
	return true
