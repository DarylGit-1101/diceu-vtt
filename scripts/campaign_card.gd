extends PanelContainer

signal launch_requested(campaign_data: Dictionary)
signal delete_requested(campaign_data: Dictionary)

@onready var title_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/CampaignTitle
@onready var desc_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/CampaignDesc

var campaign_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	campaign_data = data
	if not is_node_ready():
		await ready
	
	title_label.text = data.get("title", "Untitled")
	desc_label.text = data.get("description", "")

func _on_launch_button_pressed() -> void:
	launch_requested.emit(campaign_data)


func _on_delete_button_pressed() -> void:
	delete_requested.emit(campaign_data)
