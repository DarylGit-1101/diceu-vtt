extends Control

@onready var line_edit: LineEdit = $VBoxContainer/HBoxContainer/LineEdit

func _on_host_pressed() -> void:
	NetworkHandler.start_server()


func _on_client_pressed() -> void:
	var entered_code: String = line_edit.text
	entered_code = entered_code.strip_edges()
	
	if entered_code.is_empty():
		print("Please enter a room code before connecting!")
		return
	
	NetworkHandler.start_client(entered_code)
