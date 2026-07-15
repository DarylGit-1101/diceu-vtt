extends Node

const IP_ADDRESS: String = "127.0.0.1"
const PORT: int = 42069

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	var test_code = _generate_room_code(IP_ADDRESS)
	print("--- HOST SERVER LIVE ---")
	print("Your local testing Room Code is: ", test_code) # Will print: MTI3LjAuMC4x

func start_client(ip_address: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(_get_ip_from_room_code(ip_address), PORT)
	multiplayer.multiplayer_peer = peer

#encryption
func _generate_room_code(ip_address: String) -> String:
	return Marshalls.utf8_to_base64(ip_address).replace("=", "")

func _get_ip_from_room_code(room_code: String) -> String:
	var cleaned_code = room_code.strip_edges()
	while cleaned_code.length() % 4 != 0:
		cleaned_code += "="
	return Marshalls.base64_to_utf8(cleaned_code)
