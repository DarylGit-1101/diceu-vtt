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


func _ready() -> void:
	# Only initialize the root "user://campaigns/" folder on boot.
	# No specific campaign folder is created until they choose one!
	initialize_base_directories()


# Ensures the base system folder structure exists in AppData / local storage
func initialize_base_directories() -> void:
	var root_campaigns_path = "user://campaigns/"
	
	# Safely creates the root 'campaigns' folder if it doesn't exist yet.
	var error = DirAccess.make_dir_recursive_absolute(root_campaigns_path)
	
	if error == OK:
		print("--- VTT Initialization Successful ---")
		print("Base Campaigns Path: ", ProjectSettings.globalize_path(root_campaigns_path))
		print("-------------------------------------")
	else:
		printerr("Failed to initialize base directories! Error code: ", error)

# Scans user://campaigns/ and returns a list of existing campaign folder names for your UI
func get_campaign_list() -> Array[String]:
	var campaigns: Array[String] = []
	var path = "user://campaigns/"
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				campaigns.append(file_name)
			file_name = dir.get_next()
			
	return campaigns
