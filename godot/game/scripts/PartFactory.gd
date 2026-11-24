extends RefCounted
class_name WFPartFactory
## Modular authored prototypes. Production meshes follow docs/VISUAL_ART_BIBLE.md.

const GRID: float = 1.35
const CATALOG := ["timber", "steel", "glass", "copper", "stone", "wheel", "motor", "hinge", "spring", "seat"]
const COLORS := {
    "timber": Color("bc895b"), "steel": Color("8eaab2"),
    "glass": Color("81d1d7"), "copper": Color("d69b57"),
    "stone": Color("a0a2a0"), "wheel": Color("232d37"),
    "motor": Color("cd7754"), "hinge": Color("aeb6b2"),
    "spring": Color("b9ccd0"), "seat": Color("796354")
}

static func material_for(kind: String, transparent: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = COLORS.get(kind, Color.WHITE)
    if transparent:
        m.albedo_color.a = 0.43
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        m.no_depth_test = false
    else:
        m.roughness = 0.54
        m.metallic = 0.6 if kind in ["steel", "copper", "hinge", "spring"] else 0.08
    return m

static func add_shape(parent: Node3D, form: PrimitiveMesh, location: Vector3, mat: Material, rotate: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.mesh = form
    node.material_override = mat
    node.position = location
    node.rotation = rotate
    parent.add_child(node)
    return node

static func box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
    var m := BoxMesh.new()
    m.size = size
    return add_shape(parent, m, pos, mat)

static func cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, mat: Material, sides: int = 12, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var m := CylinderMesh.new()
    m.top_radius = radius
    m.bottom_radius = radius
    m.height = height
    m.radial_segments = sides
    return add_shape(parent, m, pos, mat, rot)

static func create_part(kind: String, ghost: bool = false) -> Node3D:
    var root := Node3D.new()
    root.name = "Module_" + kind
    var mat := material_for(kind, ghost)
    var dark := material_for("wheel", ghost)
    var metal := material_for("steel", ghost)
    var accent := material_for("copper", ghost)
    match kind:
        "timber":
            box(root, Vector3(GRID * 0.98, 0.30, GRID * 0.98), Vector3.ZERO, mat)
            for x in [-0.50, 0.50]:
                box(root, Vector3(0.15, 0.34, GRID), Vector3(x, 0, 0), dark)
        "steel":
            box(root, Vector3(GRID, 0.20, GRID), Vector3.ZERO, mat)
            for x in [-0.51, 0.51]:
                for z in [-0.52, 0.52]:
                    cylinder(root, 0.11, 0.15, Vector3(x, 0.19, z), accent, 8)
        "glass":
            box(root, Vector3(GRID * 0.94, 1.15, 0.15), Vector3(0, 0.35, 0), mat)
            for x in [-0.60, 0.60]:
                box(root, Vector3(0.08, 1.20, 0.19), Vector3(x, 0.34, 0), metal)
        "copper":
            cylinder(root, 0.48, 0.42, Vector3.ZERO, mat, 14)
            cylinder(root, 0.20, 0.53, Vector3.ZERO, metal, 12)
            for i in range(10):
                var theta := TAU * float(i) / 10.0
                box(root, Vector3(0.22, 0.31, 0.20), Vector3(cos(theta) * 0.53, 0, sin(theta) * 0.53), mat)
        "stone":
            box(root, Vector3(GRID * 0.98, GRID * 0.97, GRID * 0.98), Vector3.ZERO, mat)
            box(root, Vector3(GRID * 0.87, 0.10, GRID * 0.87), Vector3(0, 0.68, 0), metal)
        "wheel":
            cylinder(root, 0.67, 0.34, Vector3.ZERO, dark, 16, Vector3(0, 0, PI / 2))
            cylinder(root, 0.31, 0.37, Vector3.ZERO, accent, 14, Vector3(0, 0, PI / 2))
            cylinder(root, 0.12, 0.45, Vector3.ZERO, metal, 10, Vector3(0, 0, PI / 2))
        "motor":
            box(root, Vector3(1.08, 0.72, 0.90), Vector3.ZERO, mat)
            cylinder(root, 0.15, 1.02, Vector3(0.30, 0.47, 0), metal, 10, Vector3(0, 0, PI / 2))
            box(root, Vector3(0.72, 0.16, 0.36), Vector3(0, 0.47, 0), accent)
        "hinge":
            cylinder(root, 0.30, 0.90, Vector3.ZERO, mat, 12, Vector3(0, 0, PI / 2))
            box(root, Vector3(0.26, 0.65, 0.76), Vector3(0, 0, 0), metal)
        "spring":
            cylinder(root, 0.19, 0.92, Vector3.ZERO, metal)
            for i in range(7):
                var ring := TorusMesh.new()
                ring.inner_radius = 0.20
                ring.outer_radius = 0.39
                add_shape(root, ring, Vector3(0, -0.39 + i * 0.13, 0), mat)
        "seat":
            box(root, Vector3(0.99, 0.18, 1.0), Vector3(0, -0.12, 0), mat)
            box(root, Vector3(0.99, 1.15, 0.21), Vector3(0, 0.42, 0.50), mat)
            box(root, Vector3(0.99, 0.14, 0.20), Vector3(0, 1.03, 0.50), metal)
        _:
            box(root, Vector3.ONE, Vector3.ZERO, mat)
    return root
