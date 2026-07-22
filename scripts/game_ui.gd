extends Control

@onready var battle_tracker: PanelContainer = $BattleTracker
@onready var asset_file_dialog: FileDialog = $AssetFileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if asset_file_dialog:
		asset_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
		asset_file_dialog.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp ; Supported Images"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_initiative_button_pressed() -> void:
	battle_tracker.visible = !battle_tracker.visible


func _on_measure_button_pressed() -> void:
	GameState.active_tool = GameState.Tool.MEASURE
	print("Tool: " + str(GameState.active_tool))


func _on_ping_button_pressed() -> void:
	GameState.active_tool = GameState.Tool.PING
	print("Tool: " + str(GameState.active_tool))


func _on_select_button_pressed() -> void:
	GameState.active_tool = GameState.Tool.SELECT
	print("Tool: " + str(GameState.active_tool))


func _on_asset_file_dialog_file_selected(path: String) -> void:
	pass # Replace with function body.


func _on_map_add_pressed() -> void:
	if asset_file_dialog:
		asset_file_dialog.popup_centered(Vector2i(800,600))


func _on_map_list_pressed() -> void:
	pass # Replace with function body.


func _on_token_add_pressed() -> void:
	pass # Replace with function body.


func _on_token_list_pressed() -> void:
	pass # Replace with function body.

func _on_asset_file_dialog_files_selected(paths: PackedStringArray) -> void:
	for path: String in paths:
		var imported_name: String = GameState.import_map_to_campaign(path)
		if not imported_name.is_empty():
			print("Loaded map into campaign: ", imported_name)
