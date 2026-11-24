extends CanvasLayer
class_name WFHUD
## The UI belongs to the world: compact workshop command bars, modal quest folio,
## narrative cards, build-slot readouts, and a human-approved optional local mentor.

signal quest_action(quest_id: String)
signal garage_requested
signal build_requested

var adventure: Node3D
var root: Control
var mission_label: Label
var tooltip: Label
var status: Label
var speed_label: Label
var build_bar: Label
var resources_label: Label
var panel: PanelContainer
var panel_content: VBoxContainer
var orbit_input: LineEdit
var orbit_reply: RichTextLabel
var orbit_request: HTTPRequest
var allow_local_model: bool = false
var pending_ai: bool = false

func setup(owner: Node3D) -> void:
    adventure = owner

func _ready() -> void:
    root = Control.new()
    root.name = "GameHUDLayer"
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)
    _create_hud()
    _make_panel()
    orbit_request = HTTPRequest.new()
    orbit_request.timeout = 35.0
    add_child(orbit_request)
    orbit_request.request_completed.connect(_ai_response)

func _palette(bg: Color, border: Color = Color("699a92"), radius: int = 10) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    style.content_margin_left = 13
    style.content_margin_right = 13
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func _text(value: String, size: int, color: Color = Color("f4f3e9")) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label

func _button(value: String, cb: Callable, primary: bool = false) -> Button:
    var button := Button.new()
    button.text = value
    button.custom_minimum_size.y = 43
    button.add_theme_font_size_override("font_size", 15)
    button.add_theme_color_override("font_color", Color("10282b") if primary else Color("f6f3e9"))
    button.add_theme_stylebox_override("normal", _palette(Color("e7c68a") if primary else Color("26495a")))
    button.add_theme_stylebox_override("hover", _palette(Color("fff3b4") if primary else Color("376978")))
    button.pressed.connect(cb)
    return button

func _create_hud() -> void:
    var top := PanelContainer.new()
    top.add_theme_stylebox_override("panel", _palette(Color(0.03, 0.11, 0.16, 0.86)))
    top.anchor_left = 0.025
    top.anchor_top = 0.025
    top.anchor_right = 0.53
    top.anchor_bottom = 0.115
    root.add_child(top)
    var content := VBoxContainer.new()
    top.add_child(content)
    content.add_child(_text("✦  AETHERWORKS   /   THE VALLEY OF UNFINISHED THINGS", 18, Color("f8d99d")))
    mission_label = _text("YOUR STORY:  Make a working invention", 13, Color("d1e8e1"))
    content.add_child(mission_label)

    var right := PanelContainer.new()
    right.add_theme_stylebox_override("panel", _palette(Color(0.03, 0.11, 0.16, 0.86)))
    right.anchor_left = 0.73
    right.anchor_right = 0.975
    right.anchor_top = 0.025
    right.anchor_bottom = 0.18
    root.add_child(right)
    var stats := VBoxContainer.new()
    right.add_child(stats)
    resources_label = _text("MATERIALS  0   •   REPUTATION  0", 14, Color("bce7d5"))
    stats.add_child(resources_label)
    speed_label = _text("EXPLORING THE VALLEY", 15, Color("f5d8a0"))
    stats.add_child(speed_label)
    stats.add_child(_text("WASD move · E talk · B build · V drive", 11, Color("a5bec7")))

    var bottom := PanelContainer.new()
    bottom.anchor_left = 0.16
    bottom.anchor_right = 0.84
    bottom.anchor_top = 0.87
    bottom.anchor_bottom = 0.978
    bottom.add_theme_stylebox_override("panel", _palette(Color(0.025, 0.10, 0.145, 0.88)))
    root.add_child(bottom)
    var box := VBoxContainer.new()
    bottom.add_child(box)
    status = _text("B / OPEN FABRICATOR    •    V / TEST ROVER    •    J / QUEST FOLIO    •    O / ORBIT", 14, Color("f1d7a3"))
    box.add_child(status)
    build_bar = _text("TOOLS  1 TIMBER   2 STEEL   3 GLASS   4 COPPER   5 STONE   6 WHEEL   7 MOTOR   8 HINGE   9 SPRING   0 SEAT", 12, Color("b7d6d2"))
    box.add_child(build_bar)
    tooltip = _text("Approach a glowing quest beacon and press E for an adventure.", 12, Color("dde7db"))
    box.add_child(tooltip)
    GameState.resources_changed.connect(refresh_stats)
    refresh_stats()

func refresh_stats() -> void:
    var resources := 0
    for value in GameState.inventory.values():
        resources += int(value)
    if resources_label != null:
        resources_label.text = "RESOURCES  %d    ★  REPUTATION  %d    ◈  QUESTS  %d" % [resources, GameState.reputation, GameState.completed_quests.size()]

func set_speed(kph: float) -> void:
    if speed_label != null:
        speed_label.text = "ROVER   %03.0f km/h   •   HOLD SPACE TO BRAKE" % kph

func set_walk_mode() -> void:
    speed_label.text = "ON FOOT  •  E TO INTERACT"

func set_context(text: String) -> void:
    if tooltip != null:
        tooltip.text = text

func set_build_mode(on: bool, details: Dictionary = {}) -> void:
    build_bar.visible = on
    if on:
        status.text = "FABRICATION  •  Left place  •  Right remove  •  R rotate  •  [ / ] layer  •  Z/Y undo/redo"
    else:
        status.text = "WASD EXPLORE  •  E TALK  •  B BUILD  •  V DRIVE  •  J QUESTS  •  O ORBIT"
    if on and not details.is_empty():
        set_build_stats(details)

func set_build_stats(details: Dictionary) -> void:
    mission_label.text = "FABRICATOR  •  %d modules  •  %d motors  •  %d wheels  •  %.0f kg (teaching estimate)" % [
        int(details.get("parts", 0)), int(details.get("motors", 0)), int(details.get("wheels", 0)), float(details.get("mass", 0.0))]

func flash(message: String) -> void:
    tooltip.text = message

func _make_panel() -> void:
    panel = PanelContainer.new()
    panel.anchor_left = 0.19
    panel.anchor_right = 0.81
    panel.anchor_top = 0.16
    panel.anchor_bottom = 0.87
    panel.add_theme_stylebox_override("panel", _palette(Color(0.025, 0.10, 0.16, 0.97), Color("7bbcaf"), 16))
    panel.visible = false
    root.add_child(panel)
    var scroll := ScrollContainer.new()
    scroll.follow_focus = true
    panel.add_child(scroll)
    panel_content = VBoxContainer.new()
    panel_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel_content.add_theme_constant_override("separation", 12)
    scroll.add_child(panel_content)

func _clear_panel() -> void:
    for child in panel_content.get_children():
        panel_content.remove_child(child)
        child.queue_free()
    orbit_reply = null
    orbit_input = null

func _show_panel(title: String, body: String) -> void:
    _clear_panel()
    panel_content.add_child(_text("✦  " + title, 30, Color("f7d39b")))
    panel_content.add_child(_text(body, 17, Color("e3eee9")))
    panel.visible = true

func close_panel() -> void:
    panel.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func panel_open() -> bool:
    return panel.visible

func show_quests(catalog: Array) -> void:
    _show_panel("INVENTOR'S QUEST FOLIO", "The valley rewards evidence and useful inventions, not repetitive grinding.\n")
    for quest in catalog:
        var done: bool = GameState.completed_quests.has(str(quest.get("id", "")))
        var label := ("✓  " if done else "◆  ") + str(quest.get("title", "")) + "   /   " + str(quest.get("region", ""))
        panel_content.add_child(_text(label, 17, Color("c8e9d5") if done else Color("f3ce91")))
        panel_content.add_child(_text(str(quest.get("objective", "")), 14, Color("b4cbca")))
    panel_content.add_child(_button("CLOSE FOLIO", Callable(self, "close_panel")))

func show_quest(quest: Dictionary, eligible: bool, completed: bool) -> void:
    var narrative := "%s\n\n%s\n\nYOUR CHALLENGE\n%s\n\nWHY THIS MATTERS\n%s\n\nORBIT ASKS\n%s" % [
        quest.get("quest_giver", ""), quest.get("premise", ""), quest.get("objective", ""),
        quest.get("why", ""), quest.get("mentor", "")]
    _show_panel(str(quest.get("title", "NEW QUEST")), narrative)
    if completed:
        panel_content.add_child(_text("✓  THIS COMMISSION HAS BEEN COMPLETED.", 18, Color("98dfb2")))
    elif eligible:
        var identifier: String = str(quest.get("id", ""))
        panel_content.add_child(_button("DOCUMENT & COMPLETE THIS COMMISSION   ↗", func() -> void:
            quest_action.emit(identifier)
            close_panel(), true))
    else:
        panel_content.add_child(_text("▣  NOT YET COMPLETE — prototype, explore, test and return.", 14, Color("f7ca91")))
    panel_content.add_child(_button("BACK TO THE VALLEY", Callable(self, "close_panel")))

func show_note(title: String, details: String) -> void:
    _show_panel(title, details)
    panel_content.add_child(_button("RETURN TO EXPLORATION", Callable(self, "close_panel")))

func show_orbit() -> void:
    _show_panel("ORBIT / INVENTOR'S GUIDE", "A patient workshop mentor. ORBIT can suggest experiments and help you reason, but no answer replaces real measurements.\n")
    orbit_reply = RichTextLabel.new()
    orbit_reply.bbcode_enabled = false
    orbit_reply.fit_content = true
    orbit_reply.custom_minimum_size.y = 225
    orbit_reply.add_theme_font_size_override("normal_font_size", 16)
    orbit_reply.add_theme_color_override("default_color", Color("d4e7e1"))
    orbit_reply.text = "ORBIT: Where shall we begin? Ask about structures, forces, gears, materials, energy, or racing.\n\nBy default, I'm an offline teaching guide."
    panel_content.add_child(orbit_reply)
    orbit_input = LineEdit.new()
    orbit_input.placeholder_text = "Ask ORBIT about a machine, hypothesis or quest…"
    orbit_input.custom_minimum_size.y = 46
    panel_content.add_child(orbit_input)
    panel_content.add_child(_button("ASK ORBIT  ↗", Callable(self, "_orbit_ask"), true))
    panel_content.add_child(_button("OPTIONAL LOCAL MODEL: %s  /  CLICK TO TOGGLE" % ("ENABLED" if allow_local_model else "OFF"), Callable(self, "_toggle_model")))
    panel_content.add_child(_text("When enabled, the model uses a local Ollama endpoint only. No executable actions or external tools are available in this game client.", 12, Color("b9cecd")))
    panel_content.add_child(_button("CLOSE GUIDE", Callable(self, "close_panel")))

func _toggle_model() -> void:
    allow_local_model = not allow_local_model
    show_orbit()

func _offline_answer(question: String) -> String:
    var lower := question.to_lower()
    if "bridge" in lower or "beam" in lower or "triangle" in lower:
        return "A triangular brace resists shape changes better than an unbraced rectangle. Make two beams of identical length and material. Change only the bracing and compare deflection under the SAME load. How will you record the difference?"
    if "gear" in lower or "motor" in lower:
        return "Gear ratio compares the teeth or angular speeds of linked gears. A small drive gear turning a larger driven gear usually increases torque while reducing output speed. Try a 12-tooth driving a 36-tooth gear: how many motor turns are needed for one output turn?"
    if "race" in lower or "car" in lower or "wheel" in lower:
        return "Good vehicles balance acceleration, traction, braking and stability. Build a reference rover, record one lap, change only one variable such as mass or motor count, then run the same route. Which design is more predictable?"
    if "crystal" in lower or "forest" in lower:
        return "Before collecting resources, survey the environment. Where did the resource form? What organisms share this habitat? Could harvesting damage the water supply? Useful inventions solve problems without making new ones."
    if "energy" in lower or "wind" in lower or "power" in lower:
        return "Energy changes forms, but losses matter. A wind turbine converts moving air into rotation, a generator converts that rotation into electricity, and friction and heating consume some of the useful output. Predict an efficiency, then collect evidence."
    return "Start with a question that can be tested. Write a prediction, change one variable, observe a result and compare it with your prediction. What part of your machine would be easiest to measure?"

func _orbit_ask() -> void:
    if orbit_input == null or orbit_reply == null:
        return
    var q: String = orbit_input.text.strip_edges().substr(0, 260)
    if q.is_empty():
        return
    orbit_reply.text += "\n\nYOU: " + q
    orbit_input.clear()
    if not allow_local_model:
        orbit_reply.text += "\n\nORBIT / OFFLINE: " + _offline_answer(q)
        return
    if pending_ai:
        orbit_reply.text += "\nORBIT: One question at a time while I think."
        return
    pending_ai = true
    var prompt := "You are ORBIT, a friendly engineering mentor for a family game. Never invent observations or say a simulation proves real safety. Ask one practical question. No tool calls, code execution, or dangerous instructions. Keep responses under 140 words. The user asks: " + q
    var payload := JSON.stringify({"model": "qwen3:0.6b", "prompt": prompt, "stream": false, "options": {"num_ctx": 1024, "num_predict": 180, "num_thread": 2}, "keep_alive": "0s"})
    var err := orbit_request.request("http://127.0.0.1:11434/api/generate", ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
    if err != OK:
        pending_ai = false
        orbit_reply.text += "\n\nORBIT / FALLBACK: " + _offline_answer(q)

func _ai_response(_result: int, response_code: int, _headers: PackedStringArray, data: PackedByteArray) -> void:
    pending_ai = false
    if orbit_reply == null or not is_instance_valid(orbit_reply):
        return
    var parsed: Variant = JSON.parse_string(data.get_string_from_utf8())
    if response_code != 200 or not parsed is Dictionary or str(parsed.get("response", "")).is_empty():
        orbit_reply.text += "\n\nORBIT / LOCAL MODEL UNAVAILABLE: Switch the optional model off to use guided lessons."
        return
    var answer: String = str(parsed["response"]).substr(0, 3000)
    orbit_reply.text += "\n\nORBIT / LOCAL MODEL (MAY BE WRONG): " + answer
