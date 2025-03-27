extends Area2D

class_name Door

# Signal if player enters a door
signal player_entered_door

@export var bottom_door: bool
@export var top_door: bool


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered_door.emit(self)
	
