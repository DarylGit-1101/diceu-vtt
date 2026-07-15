extends Control

@onready var battle_tracker: PanelContainer = $BattleTracker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
