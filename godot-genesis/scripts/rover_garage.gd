extends CanvasLayer
class_name GenesisRoverGarage

signal trial_requested(configuration: Dictionary, hypothesis: String)
signal build_applied(configuration: Dictionary)
signal garage_closed

const MODEL := preload("res://scripts/rover_blueprint.gd")
const INK := Color("e7f6f1")
const MINT := Color("83e8c7")
const MUTED := Color("a5c6cd")
const GOLD := Color("f1c88e")
var active: bool = false
var config: Dictionary = {}
var selectors: Dictionary = {}
var stats_label: RichTextLabel
var advice_label: Label
var hypothesis: LineEdit
var history: Label
var focus_button: Button
var main_panel: PanelContainer

func _style(color: Color, border: Color, radius: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(16)
	return s

func _title(value: String, size: int, color: Color = INK) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_font_size_override("font_size",size)
	l.add_theme_color_override("font_color",color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _button(label: String, color: Color, dark: bool = false) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(0,48)
	b.add_theme_font_size_override("font_size",15)
	b.add_theme_color_override("font_color",Color("102f3c") if dark else INK)
	b.add_theme_stylebox_override("normal",_style(color, color.lightened(0.15),9))
	b.add_theme_stylebox_override("hover",_style(color.lightened(0.15),MINT,9))
	b.add_theme_stylebox_override("pressed",_style(color.darkened(0.12),MINT,9))
	return b

func _ready() -> void:
	name = "InventorGarage_Interface"
	layer = 15
	config = MODEL.DEFAULT.duplicate(true)
	var shade := ColorRect.new()
	shade.name = "WorkshopBackdrop"
	shade.color = Color(0.028,0.064,0.083,0.95)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.add_theme_constant_override("margin_left",32)
	pad.add_theme_constant_override("margin_right",32)
	pad.add_theme_constant_override("margin_top",24)
	pad.add_theme_constant_override("margin_bottom",24)
	add_child(pad)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation",18)
	pad.add_child(columns)
	main_panel = PanelContainer.new()
	main_panel.name = "RoverEngineeringWorkbench"
	main_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel.add_theme_stylebox_override("panel",_style(Color("12313e"),Color("315966"),15))
	columns.add_child(main_panel)
	var left_scroll := ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel.add_child(left_scroll)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation",10)
	left_scroll.add_child(left)
	left.add_child(_title("✦  THE INVENTORS' GARAGE",17,MINT))
	left.add_child(_title("Design it. Drive it. Improve it.",29,INK))
	left.add_child(_title("Six physical choices affect the same rover. Change one at a time, run a trial, then compare evidence.",13,MUTED))
	left.add_child(HSeparator.new())
	for slot in MODEL.SLOTS:
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation",12)
		left.add_child(line)
		var lab := _title(slot.capitalize(),14,GOLD)
		lab.custom_minimum_size.x = 115
		line.add_child(lab)
		var choice := OptionButton.new()
		choice.name = slot.capitalize()+"Selector"
		choice.custom_minimum_size = Vector2(230,42)
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice.add_theme_color_override("font_color",INK)
		choice.add_theme_stylebox_override("normal",_style(Color("234c56"),Color("438a86"),7))
		for label in MODEL.LABELS[slot]:
			choice.add_item(label)
		choice.item_selected.connect(_changed.bind(slot))
		line.add_child(choice)
		selectors[slot] = choice
	left.add_child(HSeparator.new())
	left.add_child(_title("BUILDING TIP",12,MINT))
	advice_label = _title("Change one part. Predict the result.",13,MUTED)
	left.add_child(advice_label)
	var right := PanelContainer.new()
	right.name = "ExperimentBriefing"
	right.custom_minimum_size.x = 370
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_stylebox_override("panel",_style(Color("0c2632"),Color("315966"),15))
	columns.add_child(right)
	var right_v := VBoxContainer.new()
	right_v.add_theme_constant_override("separation",15)
	right.add_child(right_v)
	right_v.add_child(_title("02  /  ENGINEERING ANALYSIS",12,MINT))
	right_v.add_child(_title("Performance is a trade-off.",24,INK))
	stats_label = RichTextLabel.new()
	stats_label.name = "RoverTelemetryBeforeTrial"
	stats_label.bbcode_enabled = false
	stats_label.fit_content = false
	stats_label.scroll_active = false
	stats_label.custom_minimum_size.y = 178
	stats_label.add_theme_font_size_override("normal_font_size",15)
	stats_label.add_theme_color_override("default_color",INK)
	right_v.add_child(stats_label)
	right_v.add_child(HSeparator.new())
	right_v.add_child(_title("YOUR HYPOTHESIS",12,GOLD))
	right_v.add_child(_title("What will happen when you run this design? Be specific.",13,MUTED))
	hypothesis = LineEdit.new()
	hypothesis.name = "ExperimentHypothesis"
	hypothesis.placeholder_text = "Example: trail tires will improve grip on the hill"
	hypothesis.max_length = 220
	hypothesis.custom_minimum_size.y = 45
	right_v.add_child(hypothesis)
	right_v.add_child(HSeparator.new())
	history = _title("No trials recorded yet. Choose a design and drive.",14,MUTED)
	right_v.add_child(history)
	var grow := Control.new()
	grow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_v.add_child(grow)
	var apply := _button("APPLY BUILD", Color("285965"))
	apply.pressed.connect(_apply)
	right_v.add_child(apply)
	focus_button = _button("▶  RUN THE PROVING GROUNDS",MINT,true)
	focus_button.pressed.connect(_run_trial)
	right_v.add_child(focus_button)
	var close := _button("RETURN TO ADVENTURE  /  ESC",Color("284451"))
	close.pressed.connect(close_garage)
	right_v.add_child(close)
	visible = false
	set_process_unhandled_input(true)
	_sync_choices()

func _sync_choices() -> void:
	for slot in MODEL.SLOTS:
		var options: Array = MODEL.OPTIONS[slot]
		(selectors[slot] as OptionButton).select(options.find(config[slot]))
	_update_stats("frame")

func _changed(index: int, slot: String) -> void:
	config[slot] = MODEL.OPTIONS[slot][index]
	_update_stats(slot)

func _update_stats(slot: String) -> void:
	if stats_label == null: return
	var s := MODEL.stats(config)
	stats_label.text = "ESTIMATED DRY MASS         %.0f kg\nMOTOR FORCE                 %.0f game-N\nBATTERY CAPACITY         %.0f units\nWHEEL GRIP                   %.2f model factor\nWHEEL RADIUS                %.2f m\nSUSPENSION STIFFNESS  %.0f\nGEAR SPEED CEILING      %.0f km/h" % [s["mass_kg"],s["engine_force"],s["battery_units"],s["tire_grip"],s["wheel_radius_m"],s["suspension_stiffness"],float(s["speed_cap_mps"])*3.6]
	advice_label.text = MODEL.DESCRIPTIONS[slot]+"\n\n"+MODEL.tradeoff(config)

func open_garage(current: Dictionary, previous: Dictionary = {}) -> void:
	config = MODEL.clean(current)
	_sync_choices()
	if not previous.is_empty():
		history.text = "LAST TRIAL  /  %.1f s  •  PEAK %.1f km/h  •  CHARGE %.0f%%\nCompare the same course after changing one part." % [float(previous.get("time_s",0)),float(previous.get("peak_speed_kmh",0)),float(previous.get("charge_percent",0))]
	else:
		history.text = "No trials yet. Every run can teach you something."
	active = true
	visible = true
	focus_button.grab_focus()

func close_garage() -> void:
	active = false
	visible = false
	garage_closed.emit()

func _apply() -> void:
	build_applied.emit(config.duplicate(true))
	history.text = "Design applied. The actual rover mass and wheel settings have changed."

func _run_trial() -> void:
	var expected: String = hypothesis.text.strip_edges()
	trial_requested.emit(config.duplicate(true),expected)
	close_garage()

func _unhandled_input(event: InputEvent) -> void:
	if not active: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_G:
			close_garage()
			get_viewport().set_input_as_handled()
