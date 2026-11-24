extends RefCounted
class_name GenesisRoverBlueprint

# Authoritative small-vehicle sandbox. These are *gameplay models*, not certified
# vehicle-engineering predictions; all numbers use documented units.
const SCHEMA := "wonderforge.genesis.rover-blueprint.v1"
const SLOTS := ["frame", "motor", "tire", "suspension", "gearbox", "battery"]
const OPTIONS := {
	"frame": ["scout", "utility", "racer"],
	"motor": ["economy", "balanced", "torque"],
	"tire": ["road", "trail", "mud"],
	"suspension": ["comfort", "allterrain", "sport"],
	"gearbox": ["climb", "balanced", "speed"],
	"battery": ["light", "standard", "extended"],
}
const LABELS := {
	"frame": ["Scout / agile", "Utility / stable", "Racer / light"],
	"motor": ["Economy / efficient", "Balanced / versatile", "Torque / hill climber"],
	"tire": ["Road / rolling", "Trail / versatile", "Mud / maximum grip"],
	"suspension": ["Comfort / soft", "All-terrain / balanced", "Sport / firm"],
	"gearbox": ["Climb / power", "Balanced / general", "Speed / long ratio"],
	"battery": ["Light / low mass", "Standard / general", "Extended / longer range"],
}
const DESCRIPTIONS := {
	"frame": "Wheelbase and chassis mass influence stability and turning. A lightweight frame is not always fastest on rough ground.",
	"motor": "Motor force increases acceleration but also consumes energy. Compare a climb with a flat track.",
	"tire": "Ground grip is modeled by wheel friction. A grippier tire helps on slopes, but the model is intentionally simplified.",
	"suspension": "Spring stiffness changes how readily the wheels follow bumps. Try the same course with different settings.",
	"gearbox": "Shorter gearing trades top-speed potential for launch force. The game uses a simplified speed-dependent motor model.",
	"battery": "Extra battery stores more energy but adds mass. Compare distance and speed before judging a design.",
}
const DEFAULT := {
	"schema": SCHEMA,
	"frame": "utility", "motor": "balanced", "tire": "trail",
	"suspension": "allterrain", "gearbox": "balanced", "battery": "standard",
}
const FRAME_SPECS := {
	"scout": {"mass": 440.0, "length": 3.25, "width": 1.92, "turn": 0.51},
	"utility": {"mass": 650.0, "length": 3.9, "width": 2.24, "turn": 0.44},
	"racer": {"mass": 370.0, "length": 3.65, "width": 1.98, "turn": 0.55},
}
const MOTOR_SPECS := {
	"economy": {"force": 200.0, "drain": 0.85},
	"balanced": {"force": 365.0, "drain": 1.0},
	"torque": {"force": 560.0, "drain": 1.46},
}
const TIRE_SPECS := {
	"road": {"radius": 0.48, "grip": 2.45, "mass": 12.0},
	"trail": {"radius": 0.56, "grip": 3.35, "mass": 17.0},
	"mud": {"radius": 0.64, "grip": 4.25, "mass": 24.0},
}
const SUSPENSION_SPECS := {
	"comfort": {"stiffness": 19.0, "rest": 0.36, "damping": 0.68},
	"allterrain": {"stiffness": 31.0, "rest": 0.29, "damping": 0.78},
	"sport": {"stiffness": 48.0, "rest": 0.19, "damping": 0.87},
}
const GEAR_SPECS := {
	"climb": {"force_multiplier": 1.55, "speed_limit": 14.0},
	"balanced": {"force_multiplier": 1.0, "speed_limit": 24.0},
	"speed": {"force_multiplier": 0.66, "speed_limit": 35.0},
}
const BATTERY_SPECS := {
	"light": {"energy": 90.0, "mass": 28.0},
	"standard": {"energy": 180.0, "mass": 55.0},
	"extended": {"energy": 330.0, "mass": 115.0},
}

static func clean(value: Variant) -> Dictionary:
	var out: Dictionary = DEFAULT.duplicate(true)
	if not (value is Dictionary):
		return out
	for slot in SLOTS:
		var candidate: String = str(value.get(slot, DEFAULT[slot]))
		if OPTIONS[slot].has(candidate):
			out[slot] = candidate
	return out

static func strict_valid(value: Variant) -> bool:
	if not (value is Dictionary): return false
	if value.get("schema", "") != SCHEMA: return false
	for slot in SLOTS:
		if not value.has(slot) or not OPTIONS[slot].has(value[slot]): return false
	return true

static func stats(value: Variant) -> Dictionary:
	var c := clean(value)
	var frame: Dictionary = FRAME_SPECS[c["frame"]]
	var motor: Dictionary = MOTOR_SPECS[c["motor"]]
	var tire: Dictionary = TIRE_SPECS[c["tire"]]
	var sus: Dictionary = SUSPENSION_SPECS[c["suspension"]]
	var gear: Dictionary = GEAR_SPECS[c["gearbox"]]
	var battery: Dictionary = BATTERY_SPECS[c["battery"]]
	var weight: float = frame["mass"] + 4.0 * tire["mass"] + battery["mass"] + 40.0
	return {
		"mass_kg": weight,
		"engine_force": float(motor["force"]) * float(gear["force_multiplier"]),
		"battery_units": float(battery["energy"]),
		"drain_factor": float(motor["drain"]),
		"tire_grip": float(tire["grip"]),
		"wheel_radius_m": float(tire["radius"]),
		"chassis_length_m": float(frame["length"]),
		"chassis_width_m": float(frame["width"]),
		"turn_limit_rad": float(frame["turn"]),
		"suspension_stiffness": float(sus["stiffness"]),
		"suspension_rest_m": float(sus["rest"]),
		"damping": float(sus["damping"]),
		"speed_cap_mps": float(gear["speed_limit"]),
	}

static func tradeoff(value: Variant) -> String:
	var c := clean(value)
	var s := stats(c)
	var hints: Array[String] = []
	if c["motor"] == "torque" and c["battery"] == "light":
		hints.append("Strong motor + small battery: excellent launch, limited range.")
	if c["frame"] == "racer" and c["tire"] == "mud":
		hints.append("Heavy tires reduce the mass advantage of your racer frame.")
	if c["suspension"] == "sport" and c["tire"] == "road":
		hints.append("Firm suspension and road tires favor smooth terrain.")
	if hints.is_empty():
		hints.append("Change ONE part at a time, run the same course, and compare evidence.")
	return "MASS %.0f kg   •   POWER %.0f   •   CHARGE %.0f units\n%s" % [s["mass_kg"], s["engine_force"], s["battery_units"], hints[0]]
