extends Node

@export_category('printing')
@export var print_main_events: bool

func _enter_tree() -> void:
	if print_main_events: print('enter Main')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if print_main_events: print('ready Main')
