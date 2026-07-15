extends PanelContainer

signal initiative_changed

@onready var name_edit: LineEdit = $MarginContainer/HBoxContainer/NameEdit
@onready var init_edit: LineEdit = $MarginContainer/HBoxContainer/InitEdit

func _ready() -> void:
	# Connect the input fields to trigger sorting when changed
	init_edit.text_submitted.connect(_on_init_submitted)
	init_edit.focus_exited.connect(_on_init_focus_exited)

# Helper function used by the master tracker to sort cards numerically
func get_initiative_value() -> int:
	if init_edit.text.is_empty():
		return 0
	return int(init_edit.text)

func _on_init_submitted(_new_text: String) -> void:
	initiative_changed.emit()

func _on_init_focus_exited() -> void:
	initiative_changed.emit()


func _on_delete_button_pressed() -> void:
	queue_free()
	initiative_changed.emit()
