extends SceneTree

const PREVIEW_SCENE := preload("res://scenes/ui/role_differences_preview.tscn")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var preview := PREVIEW_SCENE.instantiate()
	root.add_child(preview)
	await process_frame
	assert(preview.get_node("PreviewMargins/PreviewLayout/FeatureTabs").get_child_count() == 6)
	preview._assign_roles()
	assert(preview._role_output.text.contains("HOST ACEPTÓ"))
	preview._capture_papa()
	assert(preview._papa.carrier_id == 1)
	preview._sprint_papa()
	assert(preview._papa.immobilized_remaining < 20.0)
	preview._advance_beast()
	assert(preview._beast.appeared)
	preview._beast_basic()
	assert(preview._beast.last_attack.target_id == 1)
	preview._inspect_passives()
	assert(preview._abilities_output.text.contains("Tanque"))
	preview._complete_cooking()
	assert(preview._abilities.beast_enraged)
	preview._try_client_roles()
	assert(preview._authority_output.text.contains("RECHAZADO"))
	print("ROLE_DIFFERENCES_PREVIEW_TEST: PASS — 6 interactive tabs")
	quit(0)
