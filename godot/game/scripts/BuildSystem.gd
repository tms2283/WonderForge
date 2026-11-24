extends Node3D
class_name WFBuildSystem
## In-world fabrication table: grid snapping, ghost, place/erase, undo/redo, save.

signal feedback(message: String)
signal changed

const ORIGIN := Vector3(-28.0, 0.60, 25.0)
const HALF: int = 6
const MAX_LAYER: int = 7

var enabled: bool = false
var selected: int = 0
var selected_layer: int = 0
var facing: int = 0
var preview: Node3D
var built_root: Node3D
var nodes: Dictionary = {}
var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []
var hover_cell := Vector3i.ZERO
var can_place: bool = true

func _ready() -> void:
    name = "AtelierBlueprintEditor"
    built_root = Node3D.new()
    built_root.name = "InstalledModules"
    add_child(built_root)
    _make_foundation()
    _draw_saved()
    _refresh_preview()
    set_enabled(false)

func _make_foundation() -> void:
    var foundation := WFPartFactory.box(self, Vector3(19.7, 0.26, 19.7), ORIGIN - Vector3(0, 0.37, 0), WFPartFactory.material_for("stone"))
    foundation.name = "WorkshopAssemblyGridFoundation"
    for i in range(-HALF, HALF + 2):
        var coord := float(i) * WFPartFactory.GRID - WFPartFactory.GRID / 2
        var line_x := WFPartFactory.box(self, Vector3(0.024, 0.021, 17.95), ORIGIN + Vector3(coord, -0.18, 0), WFPartFactory.material_for("steel"))
        line_x.name = "GridX"
        var line_z := WFPartFactory.box(self, Vector3(17.95, 0.022, 0.024), ORIGIN + Vector3(0, -0.18, coord), WFPartFactory.material_for("steel"))
        line_z.name = "GridZ"
    for x in [-9.1, 9.1]:
        for z in [-9.1, 9.1]:
            WFPartFactory.cylinder(self, 0.15, 1.0, ORIGIN + Vector3(x, 0.1, z), WFPartFactory.material_for("copper"))

func _key(pos: Vector3i) -> String:
    return "%d/%d/%d" % [pos.x, pos.y, pos.z]

func _part_position(cell: Vector3i) -> Vector3:
    return ORIGIN + Vector3(cell.x * WFPartFactory.GRID, cell.y * WFPartFactory.GRID + 0.17, cell.z * WFPartFactory.GRID)

func _entry(cell: Vector3i, kind: String, rot: int) -> Dictionary:
    return {"type": kind, "x": cell.x, "y": cell.y, "z": cell.z, "r": rot % 4}

func _draw_saved() -> void:
    for child in built_root.get_children():
        child.queue_free()
    nodes.clear()
    for entry in GameState.parts:
        _add_visual(entry)

func _add_visual(entry: Dictionary) -> void:
    var cell := Vector3i(int(entry["x"]), int(entry["y"]), int(entry["z"]))
    var item := WFPartFactory.create_part(str(entry["type"]))
    item.position = _part_position(cell)
    item.rotation.y = PI / 2.0 * float(entry.get("r", 0))
    built_root.add_child(item)
    nodes[_key(cell)] = item

func _refresh_preview() -> void:
    if preview != null:
        preview.queue_free()
    preview = WFPartFactory.create_part(WFPartFactory.CATALOG[selected], true)
    preview.name = "GhostPartPointer"
    add_child(preview)
    preview.position = _part_position(hover_cell)
    preview.rotation.y = PI / 2.0 * facing
    preview.visible = enabled

func set_enabled(value: bool) -> void:
    enabled = value
    if preview != null:
        preview.visible = value
    if value:
        feedback.emit("FABRICATOR ONLINE  •  Left-click place, right-click erase, R rotate, Z/Y undo/redo, number keys parts")
    else:
        GameState.save_game()

func select_part(index: int) -> void:
    selected = posmod(index, WFPartFactory.CATALOG.size())
    _refresh_preview()
    feedback.emit("MODULE  %s  ·  COST %d  ·  OWNED %d" % [WFPartFactory.CATALOG[selected].to_upper(), GameState.PART_COSTS[WFPartFactory.CATALOG[selected]], GameState.inventory[WFPartFactory.CATALOG[selected]]])

func rotate_part() -> void:
    facing = (facing + 1) % 4
    preview.rotation.y = PI / 2.0 * facing

func change_layer(amount: int) -> void:
    selected_layer = clampi(selected_layer + amount, 0, MAX_LAYER)
    feedback.emit("ASSEMBLY LAYER  %d / 8" % (selected_layer + 1))

func update_pointer(camera: Camera3D, mouse: Vector2) -> void:
    if not enabled or camera == null:
        return
    var ray_start: Vector3 = camera.project_ray_origin(mouse)
    var ray_dir: Vector3 = camera.project_ray_normal(mouse)
    var plane := Plane(Vector3.UP, ORIGIN.y + selected_layer * WFPartFactory.GRID)
    var result: Variant = plane.intersects_ray(ray_start, ray_dir)
    if result == null:
        can_place = false
        preview.visible = false
        return
    var point: Vector3 = result
    var x: int = roundi((point.x - ORIGIN.x) / WFPartFactory.GRID)
    var z: int = roundi((point.z - ORIGIN.z) / WFPartFactory.GRID)
    can_place = abs(x) <= HALF and abs(z) <= HALF
    hover_cell = Vector3i(x, selected_layer, z)
    preview.visible = can_place
    preview.position = _part_position(hover_cell)

func try_place() -> bool:
    if not enabled or not can_place:
        return false
    var index := _key(hover_cell)
    if nodes.has(index):
        feedback.emit("This socket is occupied. Right-click to remove it.")
        return false
    if GameState.parts.size() >= GameState.MAX_PARTS:
        feedback.emit("Prototype limit reached. Break the machine into modules.")
        return false
    var kind: String = WFPartFactory.CATALOG[selected]
    if not GameState.pay_part(kind):
        feedback.emit("Not enough %s. Complete quests or salvage materials." % kind)
        return false
    var entry := _entry(hover_cell, kind, facing)
    _apply({"action": "add", "part": entry}, true)
    redo_stack.clear()
    return true

func try_remove() -> bool:
    if not enabled or not can_place:
        return false
    var index := _key(hover_cell)
    for entry in GameState.parts:
        if _key(Vector3i(int(entry["x"]), int(entry["y"]), int(entry["z"]))) == index:
            _apply({"action": "remove", "part": entry.duplicate(true)}, true)
            GameState.refund_part(str(entry["type"]))
            redo_stack.clear()
            return true
    return false

func _apply(operation: Dictionary, record: bool) -> void:
    var entry: Dictionary = operation["part"]
    var cell := Vector3i(int(entry["x"]), int(entry["y"]), int(entry["z"]))
    if operation["action"] == "add":
        GameState.parts.append(entry)
        _add_visual(entry)
    else:
        for i in range(GameState.parts.size()):
            var p: Dictionary = GameState.parts[i]
            if _key(Vector3i(int(p["x"]), int(p["y"]), int(p["z"]))) == _key(cell):
                GameState.parts.remove_at(i)
                break
        if nodes.has(_key(cell)):
            nodes[_key(cell)].queue_free()
            nodes.erase(_key(cell))
    if record:
        undo_stack.append(operation)
        if undo_stack.size() > 100:
            undo_stack.pop_front()
    GameState.save_game()
    changed.emit()

func undo() -> void:
    if undo_stack.is_empty():
        return
    var op: Dictionary = undo_stack.pop_back()
    var opposite := "remove" if op["action"] == "add" else "add"
    _apply({"action": opposite, "part": op["part"]}, false)
    if opposite == "remove":
        GameState.refund_part(str(op["part"]["type"]))
    else:
        GameState.pay_part(str(op["part"]["type"]))
    redo_stack.append(op)

func redo() -> void:
    if redo_stack.is_empty():
        return
    var op: Dictionary = redo_stack.pop_back()
    if op["action"] == "add":
        if not GameState.pay_part(str(op["part"]["type"])):
            return
    else:
        GameState.refund_part(str(op["part"]["type"]))
    _apply(op, true)

func stats() -> Dictionary:
    var motors := 0
    var wheels := 0
    var mass := 0.0
    for item in GameState.parts:
        var p: String = str(item["type"])
        mass += {"steel": 2.8, "stone": 5.1, "timber": 0.9, "wheel": 3.0, "motor": 11.0}.get(p, 1.4)
        if p == "motor":
            motors += 1
        if p == "wheel":
            wheels += 1
    return {"parts": GameState.parts.size(), "mass": mass, "motors": motors, "wheels": wheels,
            "drive_ready": wheels >= 4 and motors >= 1}
