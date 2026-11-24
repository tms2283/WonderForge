extends Node3D
class_name WFWorldForge
## Deterministic, authored/procedural world. All geometry is real 3D and rendered by Godot.
## These meshes are deliberately lightweight BLOCKOUT assets; replace with art-bible glTFs.

const TERRAIN_GRID: int = 69
const TERRAIN_STEP: float = 3.0
const SEED: int = 24527
const TRACK_CENTER := Vector3(23.0, 0.14, -4.0)
const TRACK_RADIUS: float = 24.0

var noise := FastNoiseLite.new()
var materials: Dictionary = {}
var landmark_positions := {
    "forge": Vector3(-10, 0, -20),
    "workshop": Vector3(-28, 0, 5),
    "race": Vector3(26, 0, 25),
    "forest": Vector3(-57, 0, 23),
    "crystal": Vector3(-65, 0, -61),
    "wind": Vector3(65, 0, 59),
    "observatory": Vector3(63, 0, -61)
}

func _ready() -> void:
    name = "The Aether Valley"
    noise.seed = SEED
    noise.frequency = 0.025
    noise.fractal_octaves = 3
    noise.fractal_gain = 0.53
    noise.fractal_type = FastNoiseLite.FRACTAL_FBM
    _setup_materials()
    _terrain()
    _water()
    _roads()
    _settlement()
    _forests()
    _rocks_and_crystals()
    _landmarks()
    _signage()

func _material(tint: Color, metallic: float = 0.0, glow: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = metallic
    mat.roughness = 0.72 if metallic < 0.5 else 0.33
    if glow:
        mat.emission_enabled = true
        mat.emission = tint
        mat.emission_energy_multiplier = 1.4
    return mat

func _setup_materials() -> void:
    materials = {
        "wood": _material(Color("916346")),
        "beam": _material(Color("b88b5f")),
        "slate": _material(Color("384c57")),
        "steel": _material(Color("637f86"), 0.64),
        "copper": _material(Color("c58651"), 0.56),
        "glass": _material(Color("83ccce"), 0.12),
        "cream": _material(Color("e8ca99")),
        "roof": _material(Color("a45e43")),
        "leaves": _material(Color("457d55")),
        "leaves2": _material(Color("66995c")),
        "trunk": _material(Color("69513c")),
        "light": _material(Color("f4bf70"), 0.0, true),
        "crystal": _material(Color("6dd9cb"), 0.12, true),
        "road": _material(Color("a47d52")),
        "wheel": _material(Color("1c2830")),
        "white": _material(Color("efe6d5"))
    }

func terrain_height(x: float, z: float) -> float:
    var d := Vector2(x, z).length()
    var hills: float = noise.get_noise_2d(x, z) * 6.2 + noise.get_noise_2d(x * 2.5, z * 2.5) * 1.2
    var border: float = smoothstep(55.0, 103.0, d)
    return hills * border + pow(border, 2.5) * 6.8

func _terrain() -> void:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for z in range(TERRAIN_GRID - 1):
        for x in range(TERRAIN_GRID - 1):
            var a := _terrain_point(x, z)
            var b := _terrain_point(x + 1, z)
            var c := _terrain_point(x + 1, z + 1)
            var d := _terrain_point(x, z + 1)
            for p in [a, c, b, a, d, c]:
                surface.set_color(_terrain_color(p))
                surface.add_vertex(p)
    surface.generate_normals()
    var mesh: ArrayMesh = surface.commit()
    var ground := MeshInstance3D.new()
    ground.name = "ErodedMeadowTerrain"
    ground.mesh = mesh
    var mat := _material(Color.WHITE)
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 0.96
    ground.material_override = mat
    add_child(ground)

    var map := HeightMapShape3D.new()
    map.map_width = TERRAIN_GRID
    map.map_depth = TERRAIN_GRID
    var heights := PackedFloat32Array()
    heights.resize(TERRAIN_GRID * TERRAIN_GRID)
    for z in range(TERRAIN_GRID):
        for x in range(TERRAIN_GRID):
            heights[z * TERRAIN_GRID + x] = _terrain_point(x, z).y
    map.map_data = heights
    var body := StaticBody3D.new()
    body.name = "WorldSurfaceCollision"
    body.collision_layer = 1
    body.collision_mask = 1
    add_child(body)
    var shape := CollisionShape3D.new()
    shape.shape = map
    shape.scale = Vector3(TERRAIN_STEP, 1, TERRAIN_STEP)
    body.add_child(shape)

func _terrain_point(x: int, z: int) -> Vector3:
    var half := float(TERRAIN_GRID - 1) / 2.0
    var xx := (float(x) - half) * TERRAIN_STEP
    var zz := (float(z) - half) * TERRAIN_STEP
    return Vector3(xx, terrain_height(xx, zz), zz)

func _terrain_color(pos: Vector3) -> Color:
    var n: float = noise.get_noise_2d(pos.x * 2.5, pos.z * 2.5)
    var green := Color("668a62").lerp(Color("839a66"), clampf(n * 0.8 + 0.5, 0, 1))
    if pos.y > 3:
        green = green.lerp(Color("9b927b"), clampf((pos.y - 3) / 10, 0, 0.9))
    return green

func add_box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, label: String = "") -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    var instance := MeshInstance3D.new()
    instance.name = label if label != "" else "ArchitecturalMesh"
    instance.mesh = mesh
    instance.material_override = mat
    instance.position = pos
    parent.add_child(instance)
    return instance

func add_cylinder(parent: Node3D, pos: Vector3, radii: Vector2, height: float, mat: Material, facets: int = 12) -> MeshInstance3D:
    var shape := CylinderMesh.new()
    shape.bottom_radius = radii.x
    shape.top_radius = radii.y
    shape.height = height
    shape.radial_segments = facets
    var m := MeshInstance3D.new()
    m.mesh = shape
    m.material_override = mat
    m.position = pos
    parent.add_child(m)
    return m

func _water() -> void:
    var river := MeshInstance3D.new()
    river.name = "GlitterwashRiver"
    var mesh := PlaneMesh.new()
    mesh.size = Vector2(28, 195)
    river.mesh = mesh
    river.position = Vector3(86, 0.15, 12)
    var water := _material(Color(0.18, 0.53, 0.59, 0.67), 0.2)
    water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    water.roughness = 0.19
    river.material_override = water
    add_child(river)
    for side in [-1, 1]:
        for z in range(-80, 80, 20):
            add_box(self, Vector3(86 + side * 14, 0.8, z), Vector3(1.8, 1.5, 9), materials["slate"])

func _roads() -> void:
    var road := SurfaceTool.new()
    road.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(80):
        var a := TAU * float(i) / 80.0
        var b := TAU * float(i + 1) / 80.0
        var p0 := TRACK_CENTER + Vector3(cos(a) * (TRACK_RADIUS - 3.2), 0, sin(a) * (TRACK_RADIUS - 3.2))
        var p1 := TRACK_CENTER + Vector3(cos(a) * (TRACK_RADIUS + 3.2), 0, sin(a) * (TRACK_RADIUS + 3.2))
        var p2 := TRACK_CENTER + Vector3(cos(b) * (TRACK_RADIUS - 3.2), 0, sin(b) * (TRACK_RADIUS - 3.2))
        var p3 := TRACK_CENTER + Vector3(cos(b) * (TRACK_RADIUS + 3.2), 0, sin(b) * (TRACK_RADIUS + 3.2))
        for p in [p0, p1, p2, p1, p3, p2]:
            road.set_normal(Vector3.UP)
            road.add_vertex(p)
    var road_surface := MeshInstance3D.new()
    road_surface.name = "CopperleafCircuitRaceway"
    road_surface.mesh = road.commit()
    road_surface.material_override = materials["road"]
    add_child(road_surface)
    for i in range(40):
        var a := TAU * float(i) / 40.0
        var edge := TRACK_CENTER + Vector3(cos(a) * (TRACK_RADIUS + 3.9), 0.52, sin(a) * (TRACK_RADIUS + 3.9))
        add_box(self, edge, Vector3(0.25, 0.95, 0.25), materials["wood"])
    for i in range(8):
        var theta := TAU * float(i) / 8
        var pos := TRACK_CENTER + Vector3(cos(theta) * (TRACK_RADIUS + 5.0), 0, sin(theta) * (TRACK_RADIUS + 5.0))
        _lamppost(pos)

func _lamppost(pos: Vector3) -> void:
    var pole := Node3D.new()
    pole.position = pos
    add_child(pole)
    add_cylinder(pole, Vector3(0, 2.0, 0), Vector2(0.11, 0.13), 4.0, materials["copper"], 8)
    add_box(pole, Vector3(0.0, 4.15, 0), Vector3(0.56, 0.45, 0.56), materials["light"])
    add_box(pole, Vector3(0, 4.45, 0), Vector3(0.75, 0.16, 0.75), materials["steel"])

func _settlement() -> void:
    _workshop(Vector3(-28, 0, 5))
    _house(Vector3(-47, 0, -11), 0.4, 1.15)
    _house(Vector3(-41, 0, -32), -0.4, 0.94)
    _house(Vector3(0, 0, -49), 1.7, 1.25)
    _house(Vector3(-59, 0, 4), -1.0, 0.8)
    _house(Vector3(-10, 0, 46), 0.2, 0.95)
    for i in range(17):
        var p := Vector3(-51 + (i % 6) * 5.2, 0.5, 19 + int(i / 6) * 4.5)
        add_box(self, p, Vector3(2.1, 1.0, 2.2), materials["wood"], "MarketCargo")
        add_box(self, p + Vector3(0, 0.55, 0), Vector3(2.3, 0.09, 2.4), materials["beam"])

func _house(pos: Vector3, yaw: float, scale_factor: float) -> void:
    var root := Node3D.new()
    root.name = "HandmadeWorkshopHouse"
    root.position = pos
    root.rotation.y = yaw
    root.scale = Vector3.ONE * scale_factor
    add_child(root)
    add_box(root, Vector3(0, 2.7, 0), Vector3(7, 5.3, 5.6), materials["cream"], "LimePlasterWalls")
    for x in [-3.4, 3.4]:
        for z in [-2.7, 2.7]:
            add_box(root, Vector3(x, 2.7, z), Vector3(0.4, 5.4, 0.45), materials["wood"])
    var roof := add_cylinder(root, Vector3(0, 6.3, 0), Vector2(5.6, 0.0), 3.1, materials["roof"], 4)
    roof.rotation.y = PI * 0.25
    add_box(root, Vector3(0, 1.15, 2.88), Vector3(1.65, 2.3, 0.2), materials["wood"])
    for x in [-2.3, 2.3]:
        add_box(root, Vector3(x, 3.6, 2.86), Vector3(1.25, 1.55, 0.22), materials["glass"])
        add_box(root, Vector3(x, 3.6, 3.0), Vector3(0.1, 1.67, 0.1), materials["steel"])
    add_cylinder(root, Vector3(2.2, 6.3, -1.6), Vector2(0.55, 0.55), 3.0, materials["slate"])

func _workshop(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "The Grand Atelier / Architectural Blockout"
    root.position = pos
    add_child(root)
    add_box(root, Vector3(0, 0.11, 0), Vector3(18, 0.22, 17), materials["slate"], "WorkshopStoneFoundation")
    for x in [-8.2, 8.2]:
        for z in [-7.8, 7.8]:
            add_box(root, Vector3(x, 4.8, z), Vector3(0.85, 9.5, 0.85), materials["steel"], "IronSupportPillar")
    add_box(root, Vector3(0, 9.7, 0), Vector3(19, 0.7, 18), materials["copper"], "CopperRoofRidge")
    add_box(root, Vector3(0, 10.6, -1), Vector3(10, 2.4, 7), materials["roof"])
    for z in [-6, -3, 0, 3, 6]:
        add_box(root, Vector3(-7.6, 2.0, z), Vector3(0.55, 3.7, 0.65), materials["beam"])
        add_box(root, Vector3(7.6, 2.0, z), Vector3(0.55, 3.7, 0.65), materials["beam"])
    add_box(root, Vector3(0, 3.5, -8.3), Vector3(15.5, 6, 0.55), materials["cream"])
    add_box(root, Vector3(0, 2.5, -8.0), Vector3(3.5, 4.4, 0.2), materials["wood"])
    for x in [-5, 5]:
        add_box(root, Vector3(x, 3.5, -7.8), Vector3(3.1, 2.9, 0.22), materials["glass"])
    add_box(root, Vector3(-5.8, 0.85, 3.7), Vector3(3.4, 1.5, 4.1), materials["wood"], "BlueprintDraftingTable")
    add_box(root, Vector3(5.6, 0.8, 3.7), Vector3(3.6, 1.3, 4.1), materials["steel"], "AnvilAssemblyBench")
    _hanging_gear(root, Vector3(-8.6, 8.2, -7.5), 2.4)
    _hanging_gear(root, Vector3(8.6, 7.3, -7.6), 1.7)
    for i in range(4):
        add_box(root, Vector3(-4 + i * 2.5, 7.9, 0), Vector3(1.0, 0.7, 0.65), materials["light"])
    add_box(root, Vector3(0, 0.4, 9.5), Vector3(16, 0.16, 3), materials["copper"], "WorkshopPorch")

func _hanging_gear(parent: Node3D, pos: Vector3, radius: float) -> void:
    var gear := Node3D.new()
    gear.position = pos
    parent.add_child(gear)
    var circle := add_cylinder(gear, Vector3.ZERO, Vector2(radius, radius), 0.25, materials["copper"], 16)
    circle.rotation.x = PI / 2.0
    for i in range(12):
        var a := TAU * float(i) / 12.0
        var tooth := add_box(gear, Vector3(cos(a) * radius, sin(a) * radius, 0), Vector3(0.52, 0.42, 0.35), materials["steel"])
        tooth.rotation.z = a

func _forests() -> void:
    # MultiMesh lets hundreds of authored-procedural trees render with very few draw calls.
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.bottom_radius = 0.32
    trunk_mesh.top_radius = 0.19
    trunk_mesh.height = 4.7
    trunk_mesh.radial_segments = 7
    var foliage_mesh := CylinderMesh.new()
    foliage_mesh.bottom_radius = 2.05
    foliage_mesh.top_radius = 0.04
    foliage_mesh.height = 5.1
    foliage_mesh.radial_segments = 8
    var foliage_alt := CylinderMesh.new()
    foliage_alt.bottom_radius = 1.43
    foliage_alt.top_radius = 0.0
    foliage_alt.height = 3.2
    foliage_alt.radial_segments = 8
    var trunks: Array[Transform3D] = []
    var canopies: Array[Transform3D] = []
    var upper: Array[Transform3D] = []
    var rng := RandomNumberGenerator.new()
    rng.seed = SEED
    for i in range(210):
        var px := rng.randf_range(-100, 100)
        var pz := rng.randf_range(-100, 100)
        var point := Vector2(px, pz)
        if point.length() < 52 or abs(px - 86) < 21:
            continue
        var height_scale := rng.randf_range(0.72, 1.44)
        var origin := Vector3(px, terrain_height(px, pz), pz)
        var basis := Basis(Vector3.UP, rng.randf_range(0, TAU)).scaled(Vector3.ONE * height_scale)
        trunks.append(Transform3D(basis, origin + Vector3(0, 2.3 * height_scale, 0)))
        canopies.append(Transform3D(basis, origin + Vector3(0, 5.1 * height_scale, 0)))
        upper.append(Transform3D(basis, origin + Vector3(0, 7.5 * height_scale, 0)))
    _multi("PineTrunks", trunk_mesh, materials["trunk"], trunks)
    _multi("PineCanopies", foliage_mesh, materials["leaves"], canopies)
    _multi("PineHighSprigs", foliage_alt, materials["leaves2"], upper)

func _multi(label: String, mesh: Mesh, mat: Material, transforms: Array[Transform3D]) -> void:
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.mesh = mesh
    mm.instance_count = transforms.size()
    for i in range(transforms.size()):
        mm.set_instance_transform(i, transforms[i])
    var inst := MultiMeshInstance3D.new()
    inst.name = label
    inst.multimesh = mm
    inst.material_override = mat
    add_child(inst)

func _rocks_and_crystals() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = SEED * 4
    for i in range(55):
        var a := rng.randf_range(0, TAU)
        var rr := rng.randf_range(53.0, 98.0)
        var p := Vector3(cos(a) * rr, 0, sin(a) * rr)
        p.y = terrain_height(p.x, p.z)
        var rock := add_cylinder(self, p + Vector3(0, 1.1, 0), Vector2(rng.randf_range(1.1, 3.3), 0.1), rng.randf_range(1.9, 4.0), materials["slate"], 7)
        rock.rotation.y = a
    for i in range(22):
        var p := Vector3(-65 + rng.randf_range(-11, 11), 0, -62 + rng.randf_range(-10, 10))
        p.y = terrain_height(p.x, p.z)
        var height := rng.randf_range(1.2, 5.5)
        var gem := add_cylinder(self, p + Vector3(0, height / 2, 0), Vector2(rng.randf_range(0.4, 1.2), 0.0), height, materials["crystal"], 5)
        gem.rotation.z = rng.randf_range(-0.18, 0.18)

func _landmarks() -> void:
    # These are spatial landmarks, not yet a complete empire simulation.
    _tower(landmark_positions["forge"], "FoundrySpire", 14, materials["copper"])
    _tower(landmark_positions["wind"], "WindwardBeacon", 21, materials["steel"])
    _tower(landmark_positions["observatory"], "ClockworkObservatory", 18, materials["slate"])
    for i in range(10):
        var x := 44.0 + float(i) * 3.6
        add_box(self, Vector3(x, 0.4, 30), Vector3(2.7, 0.8, 7.5), materials["wood"], "FoundryDock")
    for i in range(7):
        var z := 25.0 + float(i) * 5.0
        add_box(self, Vector3(67, 2.5, z), Vector3(1.0, 5, 1), materials["steel"], "WindwardHoist")

func _tower(pos: Vector3, label: String, height: float, metal: Material) -> void:
    var root := Node3D.new()
    root.name = label
    root.position = Vector3(pos.x, terrain_height(pos.x, pos.z), pos.z)
    add_child(root)
    add_cylinder(root, Vector3(0, height / 2, 0), Vector2(3.4, 2.7), height, materials["cream"], 10)
    add_cylinder(root, Vector3(0, height + 0.65, 0), Vector2(4.8, 0.2), 2.3, materials["roof"], 10)
    for i in range(4):
        var a := TAU * float(i) / 4.0
        add_box(root, Vector3(cos(a) * 2.9, height * 0.65, sin(a) * 2.9), Vector3(1, 1.8, 1), materials["glass"])
    add_box(root, Vector3(0, height + 2, 0), Vector3(1.1, 2.1, 1.1), metal)

func _signage() -> void:
    for key in landmark_positions.keys():
        var p: Vector3 = landmark_positions[key]
        p.y = terrain_height(p.x, p.z)
        var root := Node3D.new()
        root.name = "QuestBeacon_" + key
        root.position = p + Vector3(0, 0.5, 7.0)
        add_child(root)
        add_cylinder(root, Vector3(0, 1.7, 0), Vector2(0.12, 0.12), 3.1, materials["wood"], 7)
        add_box(root, Vector3(0, 3.1, 0), Vector3(2.2, 1.0, 0.28), materials["copper"])
        add_box(root, Vector3(0, 3.1, 0.16), Vector3(1.8, 0.66, 0.10), materials["glass"])
