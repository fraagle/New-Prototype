extends StaticBody2D

class_name Dink

## Check if player has entered or left dink radius
signal player_entered_dink_radius
signal player_left_dink_radius

# RADIUS
func _on_detection_body_entered(body: Node2D) -> void:
	print(self)
	if body is Player:
		print('player entered dink radius')
		player_entered_dink_radius.emit(self)

func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		print('player left dink radius')
		player_left_dink_radius.emit()
