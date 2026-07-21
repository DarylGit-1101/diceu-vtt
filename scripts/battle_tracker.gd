extends PanelContainer

const INITIATIVE_CARD_SCENE = preload("res://scenes/UI/initiative_card.tscn")

@onready var list_container: VBoxContainer = $MarginContainer/ScrollContainer/ListContainer

func _on_plus_pressed() -> void:
	var new_card = INITIATIVE_CARD_SCENE.instantiate()
	list_container.add_child(new_card)
	new_card.initiative_changed.connect(resort_initiative_order)

func resort_initiative_order() -> void:
	var cards = list_container.get_children()
	cards.sort_custom(func(card_a, card_b):
		return card_a.get_initiative_value() > card_b.get_initiative_value()
	)
	
	for i in range(cards.size()):
		list_container.move_child(cards[i], i)
