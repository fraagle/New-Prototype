extends StaticBody2D
class_name Grapple

## Check if player has entered or left dink radius

signal player_entered_grapple_radius
signal player_left_grapple_radius

func _on_player_detector_body_entered(body: Node2D) -> void:
	print(self)
	if body is Player:
		print('player entered grapple radius')
		player_entered_grapple_radius.emit(self)


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player:
		print('player left grapple radius')
		player_left_grapple_radius.emit()
