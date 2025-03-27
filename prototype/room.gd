extends Node2D

class_name Room

signal player_entered_room  # Room should be aware that a player has entered it.

@export_category("Enabled Doors")
@export var left_door_state: bool
@export var right_door_state: bool
@export var top_door_state: bool
@export var bottom_door_state: bool

@export_category("room events")
@export var print_room_events: bool

var doors = {"DoorLeft": left_door_state,"DoorRight": right_door_state,"DoorTop": top_door_state,"DoorBottom": bottom_door_state}

func _enter_tree() -> void:
	if print_room_events: print('enter room tree \n')
			
# Check if player has entered a room
func _on_room_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if print_room_events: print('player has entered room', self)
		player_entered_room.emit(self)
