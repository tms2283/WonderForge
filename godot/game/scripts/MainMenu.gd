extends Control
## Native Godot menu. The artwork is an ORIGINAL Aetherworks key visual.

var overlay: Control

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    var art := TextureRect.new()
    art.texture = load("res://art/aetherworks-keyart.jpg")
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(art)

    var dim := ColorRect.new()
    dim.color = Color(0.016, 0.045, 0.08, 0.62)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(dim)

    var left := ColorRect.new()
    left.color = Color(0.016, 0.045, 0.075, 0.55)
    left.anchor_right = 0.52
    left.anchor_bottom = 1.0
    left.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(left)

    var content := VBoxContainer.new()
    content.anchor_left = 0.062
    content.anchor_top = 0.14
    content.anchor_right = 0.61
    content.anchor_bottom = 0.91
    content.add_theme_constant_override("separation", 12)
    add_child(content)

    content.add_child(_label("✦   WONDERFORGE ORIGINAL GAME UNIVERSE", 17, Color("b9edcc")))
    _space(content, 28)
    content.add_child(_label("AETHERWORKS", 69, Color("fff3db"), true))
    content.add_child(_label("THE WORLD IS YOUR INVENTION", 22, Color("ffce86"), true))
    _space(content, 15)
    var desc := _label("Explore a living maker kingdom. Construct wild machines.\nRace across the valley. Experiment, discover, and rebuild\nthe future — one brilliant idea at a time.", 19, Color("d4e4e3"))
    content.add_child(desc)
    _space(content, 22)
    content.add_child(_button("BEGIN ADVENTURE   ↗", Callable(self, "_begin"), true))
    content.add_child(_button("HOW TO PLAY  /  GAME CONTROLS", Callable(self, "_how_to")))
    content.add_child(_button("ABOUT THE ENGINEERING PROTOTYPE", Callable(self, "_about")))
    _space(content, 20)
    content.add_child(_label("SINGLE-PLAYER  •  OFFLINE-FIRST  •  GAMEPAD-READY", 13, Color("b9dfd6")))
    content.add_child(_label("Native Godot project · Original IP · Compatibility renderer", 12, Color("b6c8c7")))

    overlay = PanelContainer.new()
    overlay.anchor_left = 0.19
    overlay.anchor_top = 0.15
    overlay.anchor_right = 0.81
    overlay.anchor_bottom = 0.84
    overlay.add_theme_stylebox_override("panel", _panel(Color("0b2236"), Color("5caa9b"), 15))
    overlay.visible = false
    add_child(overlay)

func _label(value: String, font_size: int, tint: Color, bold: bool = false) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if bold:
        label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
        label.add_theme_constant_override("shadow_offset_x", 2)
        label.add_theme_constant_override("shadow_offset_y", 2)
    return label

func _space(parent: VBoxContainer, distance: int) -> void:
    var blank := Control.new()
    blank.custom_minimum_size.y = distance
    blank.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(blank)

func _panel(bg: Color, edge: Color, rounding: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = edge
    style.set_border_width_all(1)
    style.set_corner_radius_all(rounding)
    style.content_margin_left = 24
    style.content_margin_right = 24
    style.content_margin_top = 16
    style.content_margin_bottom = 16
    return style

func _button(title: String, cb: Callable, standout: bool = false) -> Button:
    var button := Button.new()
    button.text = title
    button.custom_minimum_size = Vector2(405, 59)
    button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    button.add_theme_font_size_override("font_size", 17)
    button.add_theme_color_override("font_color", Color("113439") if standout else Color("edf5ee"))
    button.add_theme_stylebox_override("normal", _panel(Color("f6ce83") if standout else Color("173b4b"), Color("f3d3a0") if standout else Color("7cbbaa"), 10))
    button.add_theme_stylebox_override("hover", _panel(Color("ffe1ad") if standout else Color("285767"), Color("fff3c4"), 10))
    button.add_theme_stylebox_override("pressed", _panel(Color("c8a56b") if standout else Color("22434c"), Color("edf5d4"), 10))
    button.pressed.connect(cb)
    return button

func _begin() -> void:
    get_tree().change_scene_to_file("res://scenes/world.tscn")

func _how_to() -> void:
    _show_overlay("YOUR FIRST ADVENTURE", "MOVE  —  W A S D / left stick\nLOOK  —  Hold right mouse and drag\nINTERACT  —  E or Enter near an inventor\nBUILD MODE  —  B at the workshop\nPLACE / REMOVE  —  Left / right click in build mode\nCHOOSE PART  —  1–0 or mouse wheel\nROTATE  —  R   ·   UNDO — Z   ·   REDO — Y\nDRIVE / EXIT ROVER  —  V\nQUEST JOURNAL  —  J   ·   ORBIT MENTOR — O\nPAUSE / RETURN  —  Escape\n\nA controller can move and steer the rover; build editing is currently designed for mouse and keyboard.")

func _about() -> void:
    _show_overlay("AETHERWORKS / DESIGN INTENT", "This is the NATIVE GODOT VERTICAL SLICE, not another web simulation.\n\nIt demonstrates a walkable original world, a modular workshop, a terrain environment, mechanical test mode, driving, an integrated quest loop, saving and a diegetic learning guide.\n\nArtwork, voice, dialogue, engineering simulation fidelity, multiplayer, civilizations, and complete biomes are targets for a full production pipeline.\n\nThe accompanying Art Bible and Agent Build Specification explain how to deliver the full game. Physical Raspberry Pi 4B performance is not yet verified.")

func _show_overlay(title: String, body: String) -> void:
    for child in overlay.get_children():
        child.queue_free()
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 13)
    overlay.add_child(box)
    box.add_child(_label("✦  " + title, 28, Color("f8d49a"), true))
    box.add_child(_label(body, 18, Color("e2efec")))
    var done := _button("RETURN TO THE WORLD  ↗", func() -> void: overlay.visible = false)
    box.add_child(done)
    overlay.visible = true
