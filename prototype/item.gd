extends StaticBody2D

class_name Item

## Check if player has entered or left dink radius
signal player_entered_item_radius
signal player_left_item_radius

var item_id: int
var item_hitbox_radius: float

func _on_detection_body_entered(body: Node2D) -> void:
	print(self)
	if body is Player:
		print('player entered item radius with id {item_id}')
		player_entered_item_radius.emit(self)

func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		print('player left item radius with id {item_id}')
		player_left_item_radius.emit(self)
