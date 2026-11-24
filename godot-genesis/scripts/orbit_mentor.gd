extends CanvasLayer
class_name GenesisOrbitMentor

signal mentor_closed

# Optional local-only conversational mentor. NO shell, filesystem, network tool,
# GPIO, script or gameplay action privilege. No action-taking/model-generated
# state changes. The user must opt in to localhost Ollama per session.
const ENDPOINT := "http://127.0.0.1:11434/api/chat"
const MODEL := "qwen3:0.6b"
const LIMIT_CHARS := 250
var active: bool = false
var root_box: Control
var entry: LineEdit
var output: RichTextLabel
var local_model_toggle: CheckButton
var ask_button: Button
var current_context: String = "Exploring Founders' Valley."
var pending: bool = false
var http: HTTPRequest

func _label(t: String, size: int, color: Color) -> Label:
	var n := Label.new()
	n.text = t
	n.add_theme_font_size_override("font_size",size)
	n.add_theme_color_override("font_color",color)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return n

func _ready() -> void:
	layer = 20
	name = "OrbitMentor_ExplicitLocalAI"
	root_box = ColorRect.new()
	root_box.name = "MentorShade"
	(root_box as ColorRect).color = Color(0.035,0.07,0.11,0.96)
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_box.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root_box)
	var area := MarginContainer.new()
	area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	area.add_theme_constant_override("margin_left",35)
	area.add_theme_constant_override("margin_right",35)
	area.add_theme_constant_override("margin_top",28)
	area.add_theme_constant_override("margin_bottom",28)
	root_box.add_child(area)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation",13)
	area.add_child(layout)
	layout.add_child(_label("✳   ORBIT  /  YOUR INVENTION COMPANION",18,Color("8ff1d8")))
	layout.add_child(_label("Ask a better question. Make a better machine.",28,Color("f6fcf5")))
	layout.add_child(_label("OFFLINE GUIDE is always available. LOCAL MODEL needs your own separately installed Ollama. ORBIT cannot run shell commands, edit game files, or make gameplay changes.",14,Color("b7d0d5")))
	output = RichTextLabel.new()
	output.name = "MentorResponse"
	output.bbcode_enabled = false
	output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output.add_theme_color_override("default_color",Color("ebf9f3"))
	output.add_theme_font_size_override("normal_font_size",18)
	output.text = "Welcome, inventor!\n\nTell me what you are trying to build. A useful experiment changes ONE variable and records what happened.\n\nExample: Why did my rover struggle on a hill?"
	layout.add_child(output)
	entry = LineEdit.new()
	entry.name = "MentorQuestion"
	entry.placeholder_text = "Ask about tires, gears, experiments, structures…"
	entry.max_length = LIMIT_CHARS
	entry.custom_minimum_size.y = 48
	entry.text_submitted.connect(func(_text: String) -> void: ask())
	layout.add_child(entry)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation",20)
	layout.add_child(controls)
	local_model_toggle = CheckButton.new()
	local_model_toggle.text = "USE OPTIONAL LOCAL OLLAMA (NO CLOUD)"
	local_model_toggle.button_pressed = false
	controls.add_child(local_model_toggle)
	ask_button = Button.new()
	ask_button.text = "ASK ORBIT"
	ask_button.custom_minimum_size = Vector2(180,50)
	ask_button.pressed.connect(ask)
	controls.add_child(ask_button)
	var close := Button.new()
	close.text = "RETURN TO ADVENTURE  /  ESC"
	close.custom_minimum_size = Vector2(240,50)
	close.pressed.connect(toggle)
	controls.add_child(close)
	layout.add_child(_label("F2 to open/close · Optional inference goes ONLY to 127.0.0.1:11434 · No model or responses sent to an Internet service.",12,Color("8ab2b6")))
	http = HTTPRequest.new()
	http.name = "OnlyLoopbackLocalOllama"
	http.timeout = 12
	http.request_completed.connect(_on_response)
	add_child(http)
	root_box.visible = false
	set_process_unhandled_input(true)

func toggle() -> void:
	active = not active
	root_box.visible = active
	if active:
		entry.grab_focus()
	else:
		mentor_closed.emit()

func set_guidance_context(summary: String) -> void:
	# Only public game facts. Never arbitrary filesystem/user data.
	current_context = summary.left(350)

func ask() -> void:
	if pending: return
	var question: String = entry.text.strip_edges().left(LIMIT_CHARS)
	if question.is_empty():
		output.text = "Ask me an engineering question first. Try: How does a lower gear help climbing?"
		return
	if not local_model_toggle.button_pressed:
		output.text = "ORBIT / OFFLINE GUIDE\n\n"+offline_answer(question)+"\n\nTo optionally try generative local inference, install Ollama and opt in above."
		return
	var instruction := "You are ORBIT in WonderForge, an experimental educational engineering adventure. Explain with short grounded steps and ask one good testable question. Context: %s. Never claim to perform real experiments, physics certification or safety screening. Do not offer to run programs, modify files or install software. Do not instruct children on mains voltage or hazardous machinery. If unsure, say so. Keep answer under 170 words." % current_context
	var payload := {
		"model":MODEL,"stream":false,
		"options":{"num_ctx":1024,"num_predict":180,"temperature":0.42},
		"messages":[{"role":"system","content":instruction},{"role":"user","content":question}],
	}
	var headers := PackedStringArray(["Content-Type: application/json"])
	var err := http.request(ENDPOINT,headers,HTTPClient.METHOD_POST,JSON.stringify(payload))
	if err != OK:
		output.text = "ORBIT / LOCAL MODEL UNAVAILABLE\n\n"+offline_answer(question)
		return
	pending = true
	ask_button.disabled = true
	output.text = "ORBIT / LOCAL MODEL THINKING…\n\nSmall models can be slow on CPU. The game does not pause or send this question online."

func offline_answer(question: String) -> String:
	var q := question.to_lower()
	if "gear" in q or "hill" in q or "climb" in q:
		return "Short gearing can provide more wheel force at low speed. Try the same hill with CLIMB and SPEED gearing, keeping tires and motor unchanged. Record time and charge remaining. A model can oversimplify real mechanics."
	if "tire" in q or "traction" in q or "grip" in q:
		return "Grip helps a wheel transmit force without excessive slip. Try ROAD and TRAIL tires on the exact same course. Record checkpoint time and remaining battery. Real grip also depends on the surface and tire properties."
	if "battery" in q or "power" in q or "motor" in q:
		return "Stronger motors can accelerate faster but may consume more energy. Compare ECONOMY and TORQUE motors while holding the battery and gearing constant. Which finishes with more charge?"
	if "bridge" in q or "beam" in q or "structure" in q:
		return "Triangular braces can restrict movement of a structure. Build two supported spans, one with and one without a diagonal brace. Compare observations; the current builder collision system is not a certified structural solver."
	if "orbit" in q or "planet" in q:
		return "Orbital motion combines forward velocity and gravitational acceleration. A satellite keeps missing the ground as it falls. Which variable would you change in a safe model to test this?"
	return "Start with a question you can test. Build a baseline, record the result, change one variable and repeat the same challenge. Your results are in-game observations, not laboratory measurements."

func _on_response(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	pending = false
	ask_button.disabled = false
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.size()>50000:
		output.text = "ORBIT / LOCAL MODEL NOT AVAILABLE\n\n"+offline_answer(entry.text)
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (parsed is Dictionary) or not (parsed.get("message",{}) is Dictionary):
		output.text = "ORBIT / UNREADABLE LOCAL RESPONSE\n\n"+offline_answer(entry.text)
		return
	var response: String = str(parsed["message"].get("content","")).strip_edges().left(1100)
	if response.is_empty():
		output.text = "ORBIT / EMPTY LOCAL RESPONSE\n\n"+offline_answer(entry.text)
	else:
		output.text = "ORBIT / OPTIONAL LOCAL MODEL · NOT A VERIFIED SOURCE\n\n"+response

func _unhandled_input(event: InputEvent) -> void:
	if active and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle()
		get_viewport().set_input_as_handled()
