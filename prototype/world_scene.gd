extends Node

## Handle what happens between sibling nodes
# player enters room, room signals to world, world calls to camera.

@onready var last_position = $Player.position
@onready var dink_direction: Vector2 = Vector2.ZERO
@onready var current_dink: Dink

@export_category("printing")
@export var print_world_events: bool


func _enter_tree() -> void:
	if print_world_events: print('enter world 1 scene')

func _ready():
	if print_world_events: print('ready_world_scene')
	connect_children(self)
	
func connect_children(parent):
	for child in parent.get_children():
		if child is Room and is_instance_valid(child):
			child.player_entered_room.connect(room_entered)
			if print_world_events: print('room connected')
			
			# Check doors inside the room
			for door in child.get_children():
				if door is Door and is_instance_valid(door):
					door.player_entered_door.connect(door_entered)
					if print_world_events: print('door connected')

		elif child is Hazard and is_instance_valid(child):
			child.player_hit.connect(respawn_player)
			if print_world_events: print('player in hazard')

		# Recursively check the children of each node
		if child.has_method("get_children"):
			connect_children(child)
	
func room_entered(room):
	if print_world_events: print('player entered room', room.name)
	
	# Move camera to new room
	if has_node("Camera"):
		$Camera.call('change_camera_position', room)
		#print($Camera.position)
			
func door_entered(door) -> void:
	# Setting velocity to zero so that player doesnt fly through both collision boxes
	$Player.velocity = Vector2.ZERO
	
	# Move player to marker position
	for child in door.get_children():
		if child is Marker2D:
			var floor_offset = 20
			
			if door.bottom_door:
				$Player.position = Vector2(child.global_position.x, child.global_position.y + 30)
			elif door.top_door:
				$Player.position = Vector2(child.global_position.x, child.global_position.y - 30)
			
			else:
				print('normal_door')
				$Player.position = Vector2(child.global_position.x, child.global_position.y + floor_offset)
			
			last_position = child.global_position
			
			if print_world_events: print("marker:",child.name)
			if print_world_events: print("position:",child.global_position)
	
	
func respawn_player(): 
	# Respawn at last door marker
	$Player.position = last_position
