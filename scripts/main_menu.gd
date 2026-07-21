extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_pressed() -> void:
	print("Hosting selected. Moving to campaign list...")
	# Soon: get_tree().change_scene_to_file("res://scenes/campaign_selection.tscn")


func _on_join_pressed() -> void:
	print("Join selected. Opening player connection panel...")


func _on_exit_pressed() -> void:
	get_tree().quit()
