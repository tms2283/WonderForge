extends CanvasLayer
class_name GenesisHUD

signal restart_requested

var mission_label: Label
var hint_label: Label
var status_label: Label
var coords_label: Label
var build_label: Label
var splash: PanelContainer
var footer: Label
var toast_label: Label
var banner_label: Label
var collapsed: bool = false

const PAPER := Color("eff7f1")
const MINT := Color("9ff3cf")
const GOLD := Color("f0c77e")
const SLATE := Color(0.035, 0.09, 0.13, 0.90)

func _style(bg: Color, border: Color = Color("608b8c"), roundness: int = 13) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(roundness)
	s.set_content_margin_all(13)
	return s

func _label(txt: String, size: int, color: Color, strong: bool = false) -> Label:
	var n := Label.new()
	n.text = txt
	n.add_theme_font_size_override("font_size", size)
	n.add_theme_color_override("font_color", color)
	if strong:
		n.add_theme_color_override("font_shadow_color", Color(0,0,0,0.6))
		n.add_theme_constant_override("shadow_offset_x", 1)
		n.add_theme_constant_override("shadow_offset_y", 1)
	return n

func _ready() -> void:
	var root := Control.new()
	root.name = "ExplorerHUD"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top := PanelContainer.new()
	top.name = "TopNavigation"
	top.position = Vector2(22, 22)
	top.custom_minimum_size = Vector2(410, 118)
	top.add_theme_stylebox_override("panel", _style(SLATE, Color("537a7d")))
	root.add_child(top)
	var top_v := VBoxContainer.new()
	top_v.add_theme_constant_override("separation", 5)
	top.add_child(top_v)
	top_v.add_child(_label("✦ WONDERFORGE   /   THE INVENTOR'S FRONTIER", 13, MINT, true))
	mission_label = _label("ACT I  ·  THE FOUNDER'S TRIAL", 23, PAPER, true)
	top_v.add_child(mission_label)
	hint_label = _label("Explore the courtyard. Press E near a beacon.", 13, Color("bcd7d3"))
	top_v.add_child(hint_label)
	var right := PanelContainer.new()
	right.name = "Resources"
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.position = Vector2(-345,22)
	right.custom_minimum_size = Vector2(323,112)
	right.add_theme_stylebox_override("panel", _style(SLATE, Color("537a7d")))
	root.add_child(right)
	var resources := VBoxContainer.new()
	resources.add_theme_constant_override("separation", 8)
	right.add_child(resources)
	resources.add_child(_label("INVENTOR'S INVENTORY", 12, MINT, true))
	status_label = _label("TIMBER 12   •   STONE 8   •   ALLOY 4", 14, PAPER)
	resources.add_child(status_label)
	coords_label = _label("COORDINATES  0 · 0", 12, GOLD)
	resources.add_child(coords_label)
	var bottom := PanelContainer.new()
	bottom.anchor_top = 1.0
	bottom.anchor_bottom = 1.0
	bottom.anchor_left = 0.5
	bottom.anchor_right = 0.5
	bottom.position = Vector2(-320,-104)
	bottom.custom_minimum_size = Vector2(640,78)
	bottom.add_theme_stylebox_override("panel", _style(SLATE, Color("537a7d"),16))
	root.add_child(bottom)
	var bottom_v := VBoxContainer.new()
	bottom_v.add_theme_constant_override("separation", 6)
	bottom.add_child(bottom_v)
	build_label = _label("EXPLORATION MODE", 15, MINT, true)
	build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_v.add_child(build_label)
	footer = _label("WASD move · SHIFT sprint · RMB orbit · B build · E interact · F1 help", 12, PAPER)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_v.add_child(footer)
	var sidebar := PanelContainer.new()
	sidebar.position = Vector2(22,160)
	sidebar.custom_minimum_size = Vector2(380,0)
	sidebar.add_theme_stylebox_override("panel", _style(Color(0.035, 0.09, 0.13,0.83),Color("345d62")))
	root.add_child(sidebar)
	var sidebar_v := VBoxContainer.new()
	sidebar_v.add_theme_constant_override("separation",8)
	sidebar.add_child(sidebar_v)
	sidebar_v.add_child(_label("QUEST LOG    /    TRACKED OBJECTIVES",12,GOLD,true))
	banner_label = _label("01   Locate the Founders' Workshop\n02   Activate an invention beacon\n03   Place three structural pieces\n04   Drive the ForgeRover",14,PAPER)
	sidebar_v.add_child(banner_label)
	toast_label = _label("",17,GOLD,true)
	toast_label.position = Vector2(30, 440)
	root.add_child(toast_label)
	_make_help(root)

func _make_help(root: Control) -> void:
	splash = PanelContainer.new()
	splash.anchor_left = 0.5
	splash.anchor_right = 0.5
	splash.anchor_top = 0.5
	splash.anchor_bottom = 0.5
	splash.position = Vector2(-385,-235)
	splash.custom_minimum_size = Vector2(770, 470)
	splash.add_theme_stylebox_override("panel",_style(Color("092331"),Color("a9caa9"),23))
	root.add_child(splash)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",18)
	splash.add_child(col)
	col.add_child(_label("✦    WONDERFORGE : GENESIS",37,MINT,true))
	col.add_child(_label("EXPLORE  ·  INVENT  ·  BUILD  ·  RACE  ·  LEARN",18,GOLD,true))
	col.add_child(_label("A new world of living engineering awaits. Wander through the Founders' Valley, visit its five invention guilds, collect materials, construct machines, and test your first rover.",17,PAPER))
	col.add_child(_label("MOVEMENT: WASD / arrow keys, SHIFT sprint, SPACE jump\nCAMERA: hold right mouse button, move mouse; scroll to zoom\nBUILDING: B toggle, 1–6 select parts, Q rotate, left click place\nINTERACTION: E near a crystal beacon or rover\nMISSIONS: M toggle quest details; F1 show/hide this guide\nSAVING: F5 save; F9 load your inventions",15,Color("bcd6d5")))
	col.add_child(_label("PRESS F1 TO BEGIN EXPLORING",20,MINT,true))

func toggle_help() -> void:
	splash.visible = not splash.visible

func set_resources(amounts: Dictionary) -> void:
	status_label.text = "TIMBER %d   •   STONE %d   •   ALLOY %d" % [amounts.get("timber",0),amounts.get("stone",0),amounts.get("alloy",0)]

func set_mode(building: bool, kind: String, count: int) -> void:
	if building:
		build_label.text = "BUILD MODE    /    %s    /    %d STRUCTURAL PIECES" % [kind.to_upper(),count]
		footer.text = "1–6 material · Q rotate · click construct · B exit · F5 save"
	else:
		build_label.text = "EXPLORATION MODE    /    DISCOVER THE VALLEY"
		footer.text = "WASD move · SHIFT sprint · RMB orbit · B build · E interact · F1 help"

func notice(value: String) -> void:
	toast_label.text = value
	var tween := create_tween()
	tween.tween_interval(3.5)
	tween.tween_callback(_clear_toast.bind(value))

func _clear_toast(value: String) -> void:
	if is_instance_valid(toast_label) and toast_label.text == value:
		toast_label.text = ""
