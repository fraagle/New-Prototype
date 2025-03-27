extends StaticBody2D

 #AnchorPoint

class_name AnchorPoint

## Check if player has entered or left dink radius

enum ItemType { NONE, DINK, GRAPPLE }

@export_category("Type")
@export var anchor_type: ItemType = ItemType.NONE


signal player_entered_anchor_radius
signal player_left_anchor_radius

# RADIUS Detection
func _on_player_detection_body_entered(body: Node2D) -> void:
	print(self)
	if body is Player:
		print('player entered dink radius')
		player_entered_anchor_radius.emit(self)

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		print('player left dink radius')
		player_left_anchor_radius.emit()
