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
		
		verify_and_repair_campaigns()
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
							details["title"] = data.get("title", folder_name)
							details["description"] = data.get("description", "No description provided.")
						file.close()
				campaign_list.append(details)
			folder_name = dir.get_next()
	return campaign_list

# Helper function to create a new campaign with all subfolders and info file
func create_new_campaign(campaign_title: String, description: String) -> void:
	var safe_folder_name = campaign_title.validate_node_name()
	var new_campaign_path = MY_CAMPAIGNS_PATH.path_join(safe_folder_name)
	
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

func verify_and_repair_campaigns() -> void:
	var dir: DirAccess = DirAccess.open(MY_CAMPAIGNS_PATH)
	if not dir:
		return
	
	dir.list_dir_begin()
	var folder_name: String = dir.get_next()
	
	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			var campaign_dir_path: String = MY_CAMPAIGNS_PATH.path_join(folder_name)
			_repair_single_campaign(campaign_dir_path, folder_name)
		
		folder_name = dir.get_next()

func _repair_single_campaign(path: String, folder_name: String) -> void:
	# Ensure subfolders exists
	var subfolders: Array[String] = ["maps", "tokens", "character_sheets", "notes"]
	for folder: String in subfolders:
		var sub_path: String = path.path_join(folder)
		if not DirAccess.dir_exists_absolute(sub_path):
			DirAccess.make_dir_recursive_absolute(sub_path)
			print("Repaired missing folders/files: ", sub_path)
	
	var info_path: String = path.path_join("campaign_info.json")
	if not FileAccess.file_exists(info_path):
		var fallback_info: Dictionary = {
			"title": folder_name,
			"description": "No description provided.",
			"created_date": Time.get_date_string_from_system()
		}
		var file: FileAccess = FileAccess.open(info_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(fallback_info, "\t"))
			file.close()
			print("Repaired missing campaign_info.json in: ", folder_name)
	
	var world_path: String = path.path_join("world_state.json")
	if not FileAccess.file_exists(world_path):
		var fallback_world: Dictionary = {
			"active_map": "",
			"maps": {}
		}
		var file: FileAccess = FileAccess.open(world_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(fallback_world, "\t"))
			file.close()
			print("Repaired missing world_state.json in: ", folder_name)

func import_map_to_campaign(source_path: String) -> String:
	if campaign_path.is_empty():
		printerr("Cannot import map: No active campaign loaded!")
		return ""
	
	var file_name: String = source_path.get_file()
	var destination_path: String = campaign_path.path_join("maps").path_join(file_name)
	
	var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(source_path)
	if file_bytes.is_empty():
		printerr("Failed to read image file at: ", source_path)
		return ""
	
	var write_file: FileAccess = FileAccess.open(destination_path, FileAccess.WRITE)
	if write_file:
		write_file.store_buffer(file_bytes)
		write_file.close()
		print("Map saved to campaign: ", destination_path)
		return file_name
	
	printerr("Failed to write map to: ", destination_path)
	return ""

# Sets the active campaign globally so the main VTT screen knows what to load
func set_active_campaign(folder_name: String) -> void:
	current_campaign_name = folder_name
	campaign_path = MY_CAMPAIGNS_PATH.path_join(folder_name)
	_repair_single_campaign(campaign_path, folder_name)
	print("Active campaign set to: ", current_campaign_name)

# Safely moves a campaign folder to the operating system's trash bin
func delete_campaign(folder_name: String) -> void:
	var target_path: String = MY_CAMPAIGNS_PATH.path_join(folder_name)
	var global_target: String = ProjectSettings.globalize_path(target_path)
	
	var err: Error = OS.move_to_trash(global_target)
	if err == OK:
		print("Successfully moved campaign to trash: ", folder_name)
	else:
		printerr("Failed to trash campaign folder. Error code: ", err)
