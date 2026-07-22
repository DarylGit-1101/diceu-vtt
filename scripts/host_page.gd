extends Control

const CAMPAIGN_CARD_SCENE: PackedScene = preload("res://scenes/campaign_card.tscn")

@onready var campaign_list_container: VBoxContainer = $TextureRect/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var title_input: LineEdit = $TextureRect/MarginContainer/VBoxContainer/NewCampaignName
@onready var desc_input: LineEdit = $TextureRect/MarginContainer/VBoxContainer/NewCampaignDescription

@onready var warning_dialog: AcceptDialog = $WarningDialog
@onready var delete_dialog: ConfirmationDialog = $DeleteConfirmationDialog

var campaign_to_delete: Dictionary = {}

func _ready() -> void:
	refresh_campaign_list()


func refresh_campaign_list() -> void:
	# Clear existing card nodes
	for child: Node in campaign_list_container.get_children():
		child.queue_free()
	
	# Fetch campaigns array typed as Array[Dictionary]
	var campaigns: Array[Dictionary] = GameState.get_all_campaigns_details()
	
	for campaign: Dictionary in campaigns:
		# Explicitly type card_instance to your panel/node or Control type
		var card_instance: PanelContainer = CAMPAIGN_CARD_SCENE.instantiate() as PanelContainer
		campaign_list_container.add_child(card_instance)
		
		# Set data and pass Callable references (without parentheses!)
		card_instance.setup(campaign)
		card_instance.launch_requested.connect(_on_campaign_launched)
		card_instance.delete_requested.connect(_on_campaign_deleted)

func _on_new_campaign_button_pressed() -> void:
	var new_title: String = title_input.text.strip_edges()
	var new_desc: String = desc_input.text.strip_edges()
	
	if new_title.is_empty():
		warning_dialog.popup_centered()
		return
		
	GameState.create_new_campaign(new_title, new_desc)
	
	title_input.text = ""
	desc_input.text = ""
	refresh_campaign_list()

func _on_campaign_launched(data: Dictionary) -> void:
	print("Launching Campaign: ", data.get("title", "Untitled"))
	
	var folder_name: String = data.get("folder_name", "")
	GameState.set_active_campaign(folder_name)
	# Next step: get_tree().change_scene_to_file("res://scenes/vtt_player.tscn")

func _on_campaign_deleted(data: Dictionary) -> void:
	campaign_to_delete = data
	var title_name: String = data.get("title", "this campaign")
	
	# Dynamically update the confirmation text so it mentions the specific campaign name
	delete_dialog.dialog_text = "Are you sure you want to delete '" + title_name + "'? This action cannot be undone."
	delete_dialog.popup_centered()

func _on_delete_confirmed() -> void:
	var folder_name: String = campaign_to_delete.get("folder_name", "")
	if not folder_name.is_empty():
		GameState.delete_campaign(folder_name)
		campaign_to_delete.clear()
		refresh_campaign_list()
