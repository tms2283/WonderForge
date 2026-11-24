extends RefCounted
class_name GenesisQualityProfiles

# Identical game rules, save schema, quest state, assembly logic across all profiles.
# This governs only budgets and purely visual effects. Do not put progression flags here.
const PRESETS := {
	"explorer": {
		"label":"Explorer / Raspberry Pi 4B",
		"terrain_segments":56, "tree_instances":110,
		"camera_far":165.0, "shadow_distance":55.0,
		"fog_density":0.011, "sun_shadows":false, "fps_cap":30,
		"resolution_scale":0.75,
	},
	"creator": {
		"label":"Creator / Desktop & Laptop",
		"terrain_segments":82, "tree_instances":300,
		"camera_far":320.0, "shadow_distance":100.0,
		"fog_density":0.006, "sun_shadows":true, "fps_cap":60,
		"resolution_scale":1.0,
	},
	"ultra": {
		"label":"Ultra / Gaming PC",
		"terrain_segments":116, "tree_instances":600,
		"camera_far":450.0, "shadow_distance":160.0,
		"fog_density":0.004, "sun_shadows":true, "fps_cap":0,
		"resolution_scale":1.0,
	}
}

static func resolve_requested() -> String:
	var args := OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with("--quality="):
			var choice := arg.trim_prefix("--quality=").to_lower()
			if PRESETS.has(choice):
				return choice
	# Conservative profile on ARM32/ARM64, desktop default otherwise. User can override.
	var arch := Engine.get_architecture_name().to_lower()
	if OS.get_name() == "Linux" and (arch.contains("arm") or arch.contains("aarch64")):
		return "explorer"
	return "creator"

static func get_settings(name: String) -> Dictionary:
	return PRESETS.get(name, PRESETS["explorer"]).duplicate(true)
