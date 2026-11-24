extends RefCounted
class_name GenesisEngineeringJournal

# No claims of structural accuracy. Every trial record is observed game telemetry.
const SAVE_FILE := "user://genesis_engineering_journal_v1.json"
const SCHEMA := "wonderforge.genesis.journal.v1"
const MAX_HISTORY := 50
var records: Array[Dictionary] = []

func load_records() -> void:
	records.clear()
	if not FileAccess.file_exists(SAVE_FILE): return
	var json: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
	if not (json is Dictionary) or str(json.get("schema","")) != SCHEMA: return
	var items: Variant = json.get("trials",[])
	if not (items is Array): return
	for record in items:
		if valid_record(record):
			records.append(record.duplicate(true))
			if records.size()>=MAX_HISTORY: break

func valid_record(record: Variant) -> bool:
	if not (record is Dictionary): return false
	if record.get("schema","") != "wonderforge.genesis.trial.v1": return false
	if record.get("status","") != "course_completed": return false
	if not GenesisRoverBlueprint.strict_valid(record.get("blueprint",{})): return false
	for key in ["time_s", "peak_speed_kmh", "distance_m", "charge_percent"]:
		var value: Variant = record.get(key)
		if not (value is float or value is int): return false
		if not is_finite(float(value)) or float(value)<0.0 or float(value)>100000.0: return false
	if record.get("hypothesis","") is not String: return false
	return str(record.get("hypothesis","")).length()<=220

func add_result(value: Dictionary) -> bool:
	if not valid_record(value): return false
	records.push_front(value.duplicate(true))
	if records.size()>MAX_HISTORY: records.resize(MAX_HISTORY)
	return write_records()

func write_records() -> bool:
	var payload := {"schema":SCHEMA,"trials":records}
	var target := FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	if target == null: return false
	target.store_string(JSON.stringify(payload,"  "))
	target.close()
	return true

func latest() -> Dictionary:
	return records[0].duplicate(true) if not records.is_empty() else {}

func best() -> Dictionary:
	var record: Dictionary = {}
	for trial in records:
		if record.is_empty() or float(trial["time_s"]) < float(record["time_s"]):
			record = trial
	return record.duplicate(true)

func compare_last_two() -> String:
	if records.size()<2:
		return "One experiment is a start. Change one component, repeat the track and compare."
	var a: Dictionary = records[0]
	var b: Dictionary = records[1]
	var seconds: float = float(a["time_s"])-float(b["time_s"])
	var speed: float = float(a["peak_speed_kmh"])-float(b["peak_speed_kmh"])
	var changed: Array[String] = []
	for key in GenesisRoverBlueprint.SLOTS:
		if a["blueprint"][key]!=b["blueprint"][key]: changed.append(key)
	var experiment_control := "One design variable changed: "+changed[0] if changed.size()==1 else "%d design variables changed; results cannot isolate one cause." % changed.size()
	return "%s\nTIME %+0.2f s  •  PEAK SPEED %+0.1f km/h\nYour hypothesis: %s\nThese results are from this game model, not laboratory measurements." % [experiment_control, seconds,speed,str(a.get("hypothesis","(not recorded)"))]
