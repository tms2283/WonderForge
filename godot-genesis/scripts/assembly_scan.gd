extends RefCounted
class_name GenesisAssemblyScan

# Geometric contact estimation; this does NOT simulate joints, structural
# stability, load transfer or the real-world safety of any design.
const CONTACT_TOLERANCE_M := 0.26
const PENETRATION_TOLERANCE_M := 0.08
const READY_SPAN_M := 7.0
const MAX_PARTS := 300

static func _shape_rotated(size: Vector3, yaw: float) -> Vector3:
	if absi(roundi(yaw / (PI * 0.5))) % 2 == 1:
		return Vector3(size.z, size.y, size.x)
	return size

static func _touches(a: Vector3, sa: Vector3, b: Vector3, sb: Vector3) -> bool:
	var distances: Array[float] = [
		absf(a.x - b.x) - (sa.x + sb.x) * 0.5,
		absf(a.y - b.y) - (sa.y + sb.y) * 0.5,
		absf(a.z - b.z) - (sa.z + sb.z) * 0.5,
	]
	var face_axes := 0
	var shared_axes := 0
	for d in distances:
		if d > CONTACT_TOLERANCE_M: return false
		if d >= -PENETRATION_TOLERANCE_M:
			face_axes += 1
		else:
			shared_axes += 1
	return face_axes == 1 and shared_axes == 2

static func summarize(parts: Array, sizes: Array) -> Dictionary:
	var count := parts.size()
	var failure := {
		"valid":false, "total_parts":count, "components":0,
		"largest_connected":0, "horizontal_span_m":0.0,
		"contact_pairs":0, "design_ready":false,
	}
	if count > MAX_PARTS or sizes.is_empty(): return failure
	if count == 0:
		failure["valid"] = true
		return failure
	var points: Array[Vector3] = []
	var bounds: Array[Vector3] = []
	for part in parts:
		if not (part is Dictionary): return failure
		var kind := int(part.get("kind", -1))
		var xyz: Variant = part.get("p", [])
		if kind < 0 or kind >= sizes.size() or not (xyz is Array) or xyz.size() != 3: return failure
		for n in xyz:
			if not (n is float or n is int) or not is_finite(float(n)): return failure
		var yaw := float(part.get("rot", 0.0))
		if not is_finite(yaw) or absf(yaw) > 7.0: return failure
		points.append(Vector3(float(xyz[0]), float(xyz[1]), float(xyz[2])))
		var size: Vector3 = sizes[kind]
		bounds.append(_shape_rotated(size, yaw))
	var neighbors: Array = []
	for i in range(count): neighbors.append([])
	var contacts := 0
	for i in range(count):
		for j in range(i + 1, count):
			if _touches(points[i], bounds[i], points[j], bounds[j]):
				(neighbors[i] as Array).append(j)
				(neighbors[j] as Array).append(i)
				contacts += 1
	var seen: Dictionary = {}
	var groups := 0
	var largest := 0
	var longest := 0.0
	for start in range(count):
		if seen.has(start): continue
		groups += 1
		var stack: Array[int] = [start]
		var size := 0
		var min_x: float = INF
		var max_x: float = -INF
		var min_z: float = INF
		var max_z: float = -INF
		while not stack.is_empty():
			var idx: int = stack.pop_back()
			if seen.has(idx): continue
			seen[idx] = true
			size += 1
			var p: Vector3 = points[idx]
			var s: Vector3 = bounds[idx]
			min_x = minf(min_x, p.x - s.x * 0.5)
			max_x = maxf(max_x, p.x + s.x * 0.5)
			min_z = minf(min_z, p.z - s.z * 0.5)
			max_z = maxf(max_z, p.z + s.z * 0.5)
			for candidate in neighbors[idx]:
				if not seen.has(candidate): stack.append(int(candidate))
		var span := maxf(max_x - min_x, max_z - min_z)
		if size > largest or (size == largest and span > longest):
			largest = size
			longest = span
	return {
		"valid":true, "total_parts":count, "components":groups,
		"largest_connected":largest, "horizontal_span_m":snappedf(longest, 0.01),
		"contact_pairs":contacts, "design_ready":largest >= 3 and longest >= READY_SPAN_M,
	}
