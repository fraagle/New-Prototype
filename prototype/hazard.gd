extends Node2D

class_name Hazard

signal player_hit




func _on_hazard_area_body_entered(body: Node2D) -> void:
	if body is Player:
		print('player hit')
		player_hit.emit()
		
