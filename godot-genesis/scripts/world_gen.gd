extends Node3D
class_name GenesisLandscape

# Richly organized graybox terrain. Production asset replacement is specified
# in docs/ART_BIBLE.md; this file deliberately ships without external dependencies.
const EXTENT := 95.0
var terrain_segments: int = 82
var tree_instances: int = 300
var art_profile: String = "creator"

var terrain_collision: StaticBody3D
var landmarks: Array[Dictionary] = []

func height_at(x: float, z: float) -> float:
	var base := sin(x * 0.055) * 1.6 + cos(z * 0.06) * 1.4
	base += sin((x + z) * 0.12) * cos((z - x) * 0.074) * 0.45
	var north_ridge := smoothstep(4.0, 40.0, -z) * 9.0 * absf(sin(x * 0.055))
	var east_highland := smoothstep(19.0, 75.0, x) * 5.5
	var meadow := 1.0 - smoothstep(14.0, 40.0, Vector2(x, z).length())
	return lerpf(base + north_ridge + east_highland, 0.0, meadow)

func _ready() -> void:
	_build_terrain()
	_build_lakes()
	_build_stone_roads()
	_build_landmarks()
	_build_forest()
	_build_cloud_islands()

func _terrain_color(x: float, z: float, y: float) -> Color:
	if y > 11.0: return Color("82918c")
	if y > 7.0: return Color("8b977a")
	var meadow := Color("76a284")
	var wild := Color("4b877e")
	var warm := Color("9da77b")
	var blend := clampf((sin(x * 0.13) + cos(z * 0.16) + 2.0) * 0.24, 0, 1)
	var out := meadow.lerp(wild, blend)
	return out.lerp(warm, clampf((x + 15) / 180.0, 0, 0.42))

func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for iz in range(terrain_segments):
		for ix in range(terrain_segments):
			var x0 := lerpf(-EXTENT, EXTENT, float(ix) / terrain_segments)
			var x1 := lerpf(-EXTENT, EXTENT, float(ix + 1) / terrain_segments)
			var z0 := lerpf(-EXTENT, EXTENT, float(iz) / terrain_segments)
			var z1 := lerpf(-EXTENT, EXTENT, float(iz + 1) / terrain_segments)
			var a := Vector3(x0, height_at(x0, z0), z0)
			var b := Vector3(x1, height_at(x1, z0), z0)
			var c := Vector3(x0, height_at(x0, z1), z1)
			var d := Vector3(x1, height_at(x1, z1), z1)
			for vert in [a, c, b, b, c, d]:
				st.set_color(_terrain_color(vert.x, vert.z, vert.y))
				st.add_vertex(vert)
	st.generate_normals()
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.97
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var visual := MeshInstance3D.new()
	visual.name = "Landscape_Main_Playable"
	visual.mesh = mesh
	visual.material_override = mat
	add_child(visual)
	terrain_collision = StaticBody3D.new()
	terrain_collision.name = "TerrainCollision"
	var collision := CollisionShape3D.new()
	collision.shape = mesh.create_trimesh_shape()
	terrain_collision.add_child(collision)
	add_child(terrain_collision)

func _material(color: Color, metallic: float = 0.0, rough: float = 0.82) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = rough
	return m

func _object(mesh: Mesh, at: Vector3, color: Color, label: String, parent: Node3D = self) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _material(color)
	node.position = at
	node.name = label
	parent.add_child(node)
	return node

func _box(at: Vector3, dims: Vector3, color: Color, label: String) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = dims
	return _object(box, at, color, label)

func _cylinder(at: Vector3, radius: float, height: float, color: Color, label: String, sides: int = 10) -> MeshInstance3D:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = sides
	return _object(cylinder, at, color, label)

func _build_lakes() -> void:
	var lake := CylinderMesh.new()
	lake.top_radius = 18.0
	lake.bottom_radius = 18.0
	lake.height = 0.05
	lake.radial_segments = 32
	var lake_body := _object(lake, Vector3(-54, -1.2, 44), Color("468b9d"), "ReflectingLake")
	var water := _material(Color("4f9aaa"), 0.25, 0.18)
	water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.albedo_color.a = 0.77
	lake_body.material_override = water
	for i in range(8):
		var angle := float(i) * TAU / 8.0
		var x := -54 + cos(angle) * 19.5
		var z := 44 + sin(angle) * 19.5
		_box(Vector3(x, height_at(x, z) + 0.1, z), Vector3(5, 0.34, 2), Color("a3a995"), "LakePebbleBank")

func _build_stone_roads() -> void:
	for i in range(24):
		var t := float(i) / 23.0
		var x := lerpf(0, -66, t)
		var z := lerpf(6, -34, t)
		var y := height_at(x, z)
		_box(Vector3(x, y + 0.10, z), Vector3(3.5, 0.14, 2.1), Color("b5ae8b"), "StoneRoad_Windward")
	for i in range(20):
		var t := float(i) / 19.0
		var x := lerpf(0, 66, t)
		var z := lerpf(5, -38, t)
		var y := height_at(x, z)
		_box(Vector3(x, y + 0.09, z), Vector3(3, 0.12, 2), Color("a8ab91"), "StoneRoad_Ridge")

func _build_landmarks() -> void:
	_make_workshop(Vector2(3, 4))
	_make_observatory(Vector2(-59, -41))
	_make_foundry(Vector2(64, -39))
	_make_engineering_arena(Vector2(28, 50))
	_make_grove(Vector2(-38, 36))

func _register(name: String, x: float, z: float, kind: String, description: String, reward: String) -> void:
	landmarks.append({"name": name, "position": Vector3(x, height_at(x, z) + 1.2, z), "kind": kind, "description": description, "reward": reward})

func _place_original_model(stem: String, at: Vector3) -> bool:
	# Signed-off original glTF model assets, with independent low/desktop mesh
	# variants. Godot imports these GLBs as PackedScenes at editor import time.
	var tier := "explorer" if art_profile == "explorer" else "creator"
	var path := "res://assets/models/%s_%s.glb" % [stem,tier]
	if not ResourceLoader.exists(path): return false
	var scene: PackedScene = load(path) as PackedScene
	if scene == null: return false
	var art: Node3D = scene.instantiate() as Node3D
	if art == null: return false
	art.name = "OriginalArt_%s_%s" % [stem,tier]
	art.position = at
	add_child(art)
	return true

func _sign(text_value: String, at: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text_value
	label.font_size = 33
	label.pixel_size = 0.009
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.position = at
	add_child(label)

func _make_workshop(where: Vector2) -> void:
	var x := where.x; var z := where.y; var y := height_at(x, z)
	if not _place_original_model("founders_workshop",Vector3(x,y,z)):
		# Editor import unavailable: blockout falls back without crashing.
		_box(Vector3(x,y+0.28,z),Vector3(14,0.6,11),Color("aab0a2"),"WorkshopFallbackFoundation")
		_box(Vector3(x,y+3.2,z-4.6),Vector3(12,6,1.4),Color("d4c2a2"),"WorkshopFallbackWall")
	_sign("FOUNDERS' WORKSHOP  /  G: ENGINEER A ROVER",Vector3(x,y+9.8,z+5.5),Color("ebdbb0"))
	_make_beacon(x - 7.5, z + 7.4, Color("ffcf7b"))
	_register("The Founders' Workshop", x, z + 7.3, "workshop", "Design your first working bridge. Collect parts, test a prototype, and revise your design.", "Timber x12")

func _make_observatory(where: Vector2) -> void:
	var x := where.x; var z := where.y; var y := height_at(x, z)
	if not _place_original_model("astral_observatory",Vector3(x,y,z)):
		_cylinder(Vector3(x,y+2.0,z),7.2,4,Color("d6c9b0"),"AstralLibraryFallback",24)
		var ring := TorusMesh.new()
		ring.inner_radius = 4.3
		ring.outer_radius = 4.9
		var portal := _object(ring,Vector3(x,y+12,z),Color("efd19a"),"CelestialOrreryFallback")
		portal.rotation.x = PI*0.52
	_sign("ASTRAL OBSERVATORY  /  LOOK UP",Vector3(x,y+15,z),Color("d5c1f3"))
	_make_beacon(x + 8, z + 4, Color("c0a1ff"))
	_register("Celestial Observatory", x + 8, z + 4, "astronomy", "Map a star path. Use angles, observation, and logic to guide a skyship.", "Stardust x6")

func _make_foundry(where: Vector2) -> void:
	var x := where.x; var z := where.y; var y := height_at(x, z)
	for i in range(4):
		var xx := x - 6 + float(i) * 3.5
		_box(Vector3(xx, y + 2.7, z), Vector3(2.6, 5.5, 9.5), Color("6b7f84"), "IronFoundryVats")
		_cylinder(Vector3(xx, y + 6.3, z - 1.3), 0.8, 2.3, Color("bd895e"), "CopperExhaust")
	_make_beacon(x, z + 8, Color("f3ad5d"))
	_register("Copperglass Foundry", x, z + 8, "industry", "Experiment with force, mass, and machine efficiency.", "Alloy x8")

func _make_engineering_arena(where: Vector2) -> void:
	var x := where.x; var z := where.y; var y := height_at(x, z)
	_box(Vector3(x, y + 0.25, z), Vector3(24, 0.5, 19), Color("9fa99d"), "TrialArena")
	for side in [-1, 1]:
		for i in range(5):
			var xx := x - 9 + i * 4.5
			_box(Vector3(xx, y + 0.7, z + side * 8.8), Vector3(0.4, 1.3, 0.4), Color("e6c47b"), "TrialBoundaryPost")
	_make_beacon(x + 13, z, Color("77f0da"))
	_register("The Trial Grounds", x + 13, z, "challenge", "Build machines and race across terrain. More physics stages are specified in the production bible.", "Blueprint Token x1")

func _make_grove(where: Vector2) -> void:
	var x := where.x; var z := where.y
	_cylinder(Vector3(x, height_at(x,z) + 0.2, z), 9, 0.4, Color("b3ba87"), "GroveSanctuary")
	_make_beacon(x + 8, z - 3, Color("96f3b2"))
	_register("Verdant Living Laboratory", x + 8, z - 3, "ecology", "Create renewable machines and study living systems without harming them.", "Seedglass x8")

func _make_beacon(x: float, z: float, color: Color) -> void:
	var y := height_at(x,z)
	_cylinder(Vector3(x,y + 1.05,z), 0.65, 2.1, Color("445963"), "QuestBeaconPedestal", 12)
	var core := SphereMesh.new()
	core.radius = 0.65
	core.height = 1.3
	var crystal := _object(core, Vector3(x,y + 2.6,z), color, "QuestBeaconCrystal")
	var mat := _material(color, 0.15, 0.25)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.2
	crystal.material_override = mat

func _build_forest() -> void:
	var seeded := RandomNumberGenerator.new()
	seeded.seed = 20271123
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.21
	trunk.bottom_radius = 0.46
	trunk.height = 3.1
	trunk.radial_segments = 6
	var crown := SphereMesh.new()
	crown.radius = 1.6
	crown.height = 3.0
	crown.radial_segments = 8
	crown.rings = 4
	var trunks := MultiMesh.new(); var crowns := MultiMesh.new()
	trunks.transform_format = MultiMesh.TRANSFORM_3D
	crowns.transform_format = MultiMesh.TRANSFORM_3D
	trunks.mesh = trunk; crowns.mesh = crown
	trunks.instance_count = tree_instances; crowns.instance_count = tree_instances
	for i in range(tree_instances):
		var x := seeded.randf_range(-88, 88)
		var z := seeded.randf_range(-88, 88)
		if Vector2(x,z).length() < 24 or Vector2(x,z).distance_to(Vector2(-54,44)) < 23:
			x += 24; z += 20
		var y := height_at(x,z)
		var scale := seeded.randf_range(0.75, 1.65)
		trunks.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(scale,scale,scale)),Vector3(x,y + 1.55 * scale,z)))
		crowns.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(scale,scale,scale)),Vector3(x,y + 3.8 * scale,z)))
	var base := MultiMeshInstance3D.new();base.name = "Instanced_Forest_Trunks";base.multimesh = trunks;base.material_override = _material(Color("715b51"));add_child(base)
	var leaves := MultiMeshInstance3D.new();leaves.name = "Instanced_Forest_Canopies";leaves.multimesh = crowns;leaves.material_override = _material(Color("397b73"));add_child(leaves)

func _build_cloud_islands() -> void:
	for i in range(7):
		var theta := float(i) * 2.35
		var x := cos(theta) * 75
		var z := sin(theta) * 75
		var y := 24 + float(i % 4) * 5
		var rock := CylinderMesh.new()
		rock.top_radius = 9 + float(i % 3) * 2
		rock.bottom_radius = 5
		rock.height = 5
		rock.radial_segments = 10
		_object(rock, Vector3(x,y,z), Color("889d9e"), "DistantSkyIslandPrevis")
		var grass := CylinderMesh.new();grass.top_radius = rock.top_radius;grass.bottom_radius = rock.top_radius;grass.height = 0.55;grass.radial_segments = 10
		_object(grass,Vector3(x,y + 2.8,z),Color("83ac87"),"SkyIslandCanopy")
