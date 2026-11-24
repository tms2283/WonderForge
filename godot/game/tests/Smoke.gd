extends Node
## CI entry point: godot --headless --path game --script res://tests/Smoke.gd

var failure_count: int = 0

func _ready() -> void:
    call_deferred("run_test")

func expect(condition: bool, label: String) -> void:
    if not condition:
        failure_count += 1
        push_error("AETHERWORKS HEADLESS FAIL: " + label)
    else:
        print("AETHERWORKS PASS: " + label)

func run_test() -> void:
    var menu_scene: PackedScene = load("res://scenes/menu.tscn")
    expect(menu_scene != null, "Main menu scene imports")
    if menu_scene != null:
        var menu: Node = menu_scene.instantiate()
        get_tree().root.add_child(menu)
        await process_frame
        expect(menu.get_node_or_null(".") != null, "Native menu instance created")
        menu.queue_free()
        await process_frame
    var adventure_scene: PackedScene = load("res://scenes/world.tscn")
    expect(adventure_scene != null, "3D adventure scene imports")
    if adventure_scene != null:
        var scene: Node = adventure_scene.instantiate()
        get_tree().root.add_child(scene)
        await process_frame
        await process_frame
        expect(scene.get_node_or_null("The Aether Valley") != null, "Procedural valley generated")
        expect(scene.get_node_or_null("AtelierBlueprintEditor") != null, "Builder is attached")
        expect(scene.get_node_or_null("GameHUDLayer") == null, "HUD is CanvasLayer and not an in-world mesh")
        var builder: WFBuildSystem = scene.get_node_or_null("AtelierBlueprintEditor") as WFBuildSystem
        if builder != null:
            var data: Dictionary = builder.stats()
            expect(data.has("parts") and data.has("wheels"), "Builder mechanic data exists")
            expect(builder.selected == 0, "Builder starts on timber tool")
        expect(scene.quest_catalog.size() >= 8, "Opening campaign quest data loaded")
        scene.queue_free()
        await process_frame
    expect(GameState._valid_part({"type":"motor","x":1,"y":0,"z":0,"r":0}), "Saved part schema accepts valid motor")
    expect(not GameState._valid_part({"type":"__shell__","x":1,"y":0,"z":0,"r":0}), "Saved part schema rejects foreign module")
    print("AETHERWORKS RESULT: ", failure_count, " failures")
    get_tree().quit(1 if failure_count > 0 else 0)
