extends Node
## Persistent game progression, quests, resources and construction. This is real GDScript,
## not a browser demo. Human-readable save data; never execute strings from saves.

signal resources_changed
signal quest_completed(quest_id: String)
signal state_loaded

const SAVE_PATH: String = "user://aetherworks-save-v1.json"
const BACKUP_PATH: String = "user://aetherworks-save-v1.backup.json"
const VERSION: int = 1
const MAX_PARTS: int = 200
const MAX_COORD: int = 24
const PART_COSTS := {"timber": 1, "steel": 2, "glass": 2, "copper": 3, "stone": 1, "wheel": 4, "motor": 8, "hinge": 5, "spring": 5, "seat": 3}
const INITIAL_RESOURCES := {"timber": 80, "steel": 64, "glass": 30, "copper": 40, "stone": 70, "wheel": 16, "motor": 8, "hinge": 12, "spring": 12, "seat": 8}

var inventory: Dictionary = INITIAL_RESOURCES.duplicate(true)
var parts: Array[Dictionary] = []
var completed_quests: Array[String] = []
var reputation: int = 0
var discoveries: int = 0
var last_location: Vector3 = Vector3(0, 2, 11)
var captain_name: String = "Explorer"
var total_race_best: float = 0.0
var sound_enabled: bool = true

func _ready() -> void:
    load_game()

func can_afford(part_type: String) -> bool:
    return int(inventory.get(part_type, 0)) >= int(PART_COSTS.get(part_type, 10000))

func pay_part(part_type: String) -> bool:
    if not can_afford(part_type):
        return false
    inventory[part_type] = int(inventory[part_type]) - int(PART_COSTS[part_type])
    resources_changed.emit()
    return true

func refund_part(part_type: String) -> void:
    if not PART_COSTS.has(part_type):
        return
    inventory[part_type] = min(999, int(inventory.get(part_type, 0)) + int(PART_COSTS[part_type]))
    resources_changed.emit()

func award(quest_id: String, reward: Dictionary) -> bool:
    if completed_quests.has(quest_id):
        return false
    completed_quests.append(quest_id)
    reputation += int(reward.get("reputation", 25))
    discoveries += 1
    for key in reward.keys():
        if key == "reputation":
            continue
        if inventory.has(key):
            inventory[key] = min(999, int(inventory[key]) + int(reward[key]))
    quest_completed.emit(quest_id)
    resources_changed.emit()
    save_game()
    return true

func save_game() -> bool:
    var data: Dictionary = {
        "version": VERSION,
        "name": captain_name,
        "inventory": inventory,
        "parts": parts,
        "quests": completed_quests,
        "reputation": reputation,
        "discoveries": discoveries,
        "position": [last_location.x, last_location.y, last_location.z],
        "race_best": total_race_best,
        "sound_enabled": sound_enabled
    }
    var temp_path: String = SAVE_PATH + ".tmp"
    var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
    if file == null:
        push_warning("WonderForge: could not write save: " + str(FileAccess.get_open_error()))
        return false
    file.store_string(JSON.stringify(data, "  "))
    file.flush()
    file.close()
    var absolute_save: String = ProjectSettings.globalize_path(SAVE_PATH)
    var absolute_temp: String = ProjectSettings.globalize_path(temp_path)
    if FileAccess.file_exists(SAVE_PATH):
        var existing: PackedByteArray = FileAccess.get_file_as_bytes(SAVE_PATH)
        var backup: FileAccess = FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
        if backup != null:
            backup.store_buffer(existing)
            backup.close()
    var result: Error = DirAccess.rename_absolute(absolute_temp, absolute_save)
    if result != OK:
        push_warning("WonderForge: atomic save move failed: " + str(result))
        return false
    return true

func _valid_part(entry: Variant) -> bool:
    if not entry is Dictionary:
        return false
    if not PART_COSTS.has(str(entry.get("type", ""))):
        return false
    for axis in ["x", "y", "z", "r"]:
        if not entry.has(axis) or not (entry[axis] is int or entry[axis] is float):
            return false
        if abs(float(entry[axis])) > float(MAX_COORD):
            return false
    return int(entry["y"]) >= 0 and int(entry["y"]) <= 7

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var text: String = FileAccess.get_file_as_string(SAVE_PATH)
    if text.length() > 256000:
        return false
    var parsed: Variant = JSON.parse_string(text)
    if not parsed is Dictionary or int(parsed.get("version", -1)) != VERSION:
        return false
    var p: Variant = parsed.get("parts", [])
    if not p is Array or p.size() > MAX_PARTS:
        return false
    for entry in p:
        if not _valid_part(entry):
            return false
    parts.clear()
    for entry in p:
        parts.append(entry)
    var inv: Variant = parsed.get("inventory", {})
    if inv is Dictionary:
        for key in INITIAL_RESOURCES.keys():
            inventory[key] = clampi(int(inv.get(key, INITIAL_RESOURCES[key])), 0, 999)
    completed_quests.clear()
    var raw_quests: Variant = parsed.get("quests", [])
    if raw_quests is Array:
        for item in raw_quests.slice(0, 100):
            if item is String and item.length() < 80 and not completed_quests.has(item):
                completed_quests.append(item)
    captain_name = str(parsed.get("name", "Explorer")).substr(0, 24)
    reputation = clampi(int(parsed.get("reputation", 0)), 0, 99999)
    discoveries = clampi(int(parsed.get("discoveries", 0)), 0, 9999)
    total_race_best = clampf(float(parsed.get("race_best", 0.0)), 0.0, 100000.0)
    sound_enabled = bool(parsed.get("sound_enabled", true))
    var loc: Variant = parsed.get("position", [])
    if loc is Array and loc.size() == 3:
        var candidate := Vector3(float(loc[0]), float(loc[1]), float(loc[2]))
        if candidate.length() <= 140.0:
            last_location = candidate
    state_loaded.emit()
    return true
