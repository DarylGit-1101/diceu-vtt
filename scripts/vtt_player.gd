extends Node2D

@onready var camera: Camera2D = $Camera2D

# Zoom boundaries
const MIN_ZOOM: Vector2 = Vector2(0.2, 0.2)
const MAX_ZOOM: Vector2 = Vector2(3.0, 3.0)
const ZOOM_SPEED: float = 0.10

var target_zoom: Vector2 = Vector2(1.0, 1.0)
@export var zoom_smoothness: float = 5.0

# Tracks the exact world coordinate beneath the mouse at the split second of scrolling
var zoom_anchor_world: Vector2 = Vector2.ZERO

func _ready() -> void:
	if not is_multiplayer_authority():
		camera.enabled = false
		set_process_unhandled_input(false)
		set_process(false)
	else:
		target_zoom = camera.zoom
		zoom_anchor_world = position

func _process(delta: float) -> void:
	# If we're already basically at our target zoom, don't calculate minor sub-pixel adjustments
	if camera.zoom.is_equal_approx(target_zoom):
		return
	
	var old_zoom: Vector2 = camera.zoom
	
	camera.zoom = camera.zoom.lerp(target_zoom, zoom_smoothness * delta)

	# This formula scales the distance to the anchor perfectly without checking where the mouse moved.
	var old_offset: Vector2 = zoom_anchor_world - position
	var new_offset: Vector2 = old_offset * (old_zoom / camera.zoom)
	
	position = zoom_anchor_world - new_offset

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	# Panning (Middle Mouse Button)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= event.relative / camera.zoom
		# Update anchor while panning so sudden scroll entries don't snap to an old coordinate
		zoom_anchor_world = get_global_mouse_position()

	# Zooming (Mouse Scroll Wheel)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			
			zoom_anchor_world = get_global_mouse_position()
			
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom = (target_zoom + Vector2(ZOOM_SPEED, ZOOM_SPEED)).clamp(MIN_ZOOM, MAX_ZOOM)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom = (target_zoom - Vector2(ZOOM_SPEED, ZOOM_SPEED)).clamp(MIN_ZOOM, MAX_ZOOM)
