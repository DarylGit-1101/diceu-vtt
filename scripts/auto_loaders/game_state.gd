extends Node

# --- Tool Modes ---
enum Tool { SELECT, PING, MEASURE }
var active_tool: Tool = Tool.SELECT

# --- Global Signals ---
signal map_changed(map_name: String, image_bytes: PackedByteArray)

# --- Global RAM Databases ---
var global_maps_library: Dictionary = {}
var global_tokens_library: Dictionary = {}
var active_map_name: String = ""

# --- Campaign Directory Trackers (Initialized Empty!) ---
var current_campaign_name: String = ""
var campaign_path: String = ""

# --- System Paths ---
const MY_CAMPAIGNS_PATH: String = "user://campaigns/my_campaigns/"
const JOINED_CAMPAIGNS_PATH: String = "user://campaigns/joined_campaigns/"


func _ready() -> void:
	# Verifies and builds the folder structure on launch
	initialize_base_directories()


# Ensures user://campaigns/my_campaigns/ and user://campaigns/joined_campaigns/ exist
func initialize_base_directories() -> void:
	var err_my = DirAccess.make_dir_recursive_absolute(MY_CAMPAIGNS_PATH)
	var err_joined = DirAccess.make_dir_recursive_absolute(JOINED_CAMPAIGNS_PATH)
	
	if err_my == OK and err_joined == OK:
		print("--- VTT Initialization Successful ---")
		print("Hosted Campaigns Path: ", ProjectSettings.globalize_path(MY_CAMPAIGNS_PATH))
		print("Joined Campaigns Path: ", ProjectSettings.globalize_path(JOINED_CAMPAIGNS_PATH))
		print("-------------------------------------")
	else:
		printerr("Failed to initialize base directories! Error codes - My: ", err_my, " Joined: ", err_joined)


# Scans user://campaigns/my_campaigns/ for your host page list
func get_campaign_list() -> Array[String]:
	var campaigns: Array[String] = []
	var dir = DirAccess.open(MY_CAMPAIGNS_PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				campaigns.append(file_name)
			file_name = dir.get_next()
			
	return campaigns

# Fetches a list of all campaigns with their details
func get_all_campaigns_details() -> Array[Dictionary]:
	var campaign_list: Array[Dictionary] = []
	var dir = DirAccess.open(MY_CAMPAIGNS_PATH)
	
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			if dir.current_is_dir() and not folder_name.begins_with("."):
				var full_folder_path = MY_CAMPAIGNS_PATH.path_join(folder_name)
				var info_file_path = full_folder_path.path_join("campaign_info.json")
				
				# Default fallback values if no info file exists yet
				var details = {
					"folder_name": folder_name,
					"title": folder_name,
					"description": "No description provided.",
					"path": full_folder_path
				}
				
				# Load custom title & description if json file exists
				if FileAccess.file_exists(info_file_path):
					var file = FileAccess.open(info_file_path, FileAccess.READ)
					if file:
						var json = JSON.new()
						if json.parse(file.get_as_text()) == OK:
							var data = json.data
							details["titles"] = data.get("title", folder_name)
							details["description"] = data.get("description", "No description provided.")
						file.close()
					campaign_list.append(details)
				folder_name = dir.get_next()
	return campaign_list

# Helper function to create a new campaign with all subfolders and info file
func create_new_campaign(campaign_title: String, description: String) -> void:
	var safe_folder_name = campaign_title.validate_node_name()
	var new_campaign_path = MY_CAMPAIGNS_PATH.path_join("safe_folder_name")
	
	# Build sub-directories
	DirAccess.make_dir_recursive_absolute(new_campaign_path.path_join("maps"))
	DirAccess.make_dir_recursive_absolute(new_campaign_path.path_join("tokens"))
	DirAccess.make_dir_recursive_absolute(new_campaign_path.path_join("character_sheets"))
	DirAccess.make_dir_recursive_absolute(new_campaign_path.path_join("notes"))
	
	# Save metadata JSON
	var info_data = {
		"title": campaign_title,
		"description": description,
		"created_date": Time.get_date_string_from_system()
	}
	var info_file = FileAccess.open(new_campaign_path.path_join("campaign_info.json"), FileAccess.WRITE)
	if info_file:
		info_file.store_string(JSON.stringify(info_data, "\t"))
		info_file.close()
	
	# Create an empty world_state JSON
	var world_data = {
		"active_map": "",
		"maps": {} # Format: "map_name": { "tokens": [...] }
	}
	var world_file = FileAccess.open(new_campaign_path.path_join("world_state.json"), FileAccess.WRITE)
	if world_file:
		world_file.store_string(JSON.stringify(world_data, "\t"))
		world_file.close()
		
	print("New Campaign Created Successfully at: ", new_campaign_path)
