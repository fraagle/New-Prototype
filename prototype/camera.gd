extends Camera2D
	
# Camera should know where the player is.
	
var last_position = position
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func change_camera_position(room):
	print('moving camera \n')
	position.x = lerp(last_position.x, room.position.x, 1)
	position.y = lerp(last_position.y, room.position.y, 1)
	
func follow_player_position():
	position = Player.position
	
