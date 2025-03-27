extends CharacterBody2D

class_name Player

## Exports
@export var movement_data: PlayerMovementData

## Onready timers
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var wall_slide_timer: Timer = $WallSlideTimer

# The item the player is currently targeting/handling
var item_target: Item

## variables
var dink_target: Dink
var can_execute_dink: bool = false
var has_executed_dink: bool
var dink_direction: Vector2
var dink_input_axis: int

var grapple_target: Grapple
var has_executed_grapple: bool = false
var grapple_direction: Vector2


var jump_buffered: bool 

var just_wall_jumped = false
var was_wall_normal = Vector2.ZERO

var wall_slide_timer_running: bool = false
## Features
@export_category("Movement") 
@export var enable_jump: bool
@export var enable_walking: bool
@export var enable_jump_buffer: bool

@export_category("other")
@export var print_movement: bool
@export var print_action: bool


func _ready():
	var parent = get_parent()
	connect_children(parent)
	
func connect_children(parent):
	for child in parent.get_children():
		
		if child is DinkHitBox:
			print('initialized hitbox')
			child.player_dink_hit.connect(execute_dink)
		
		if child is Dink:
			print('initialized dinks')
			child.player_entered_item_radius.connect(player_within_dink_radius)
			child.player_left_item_radius.connect(player_outside_dink_radius)
		
		if child is Grapple:
			print('initialized grapples')
			child.player_entered_item_radius.connect(player_within_grapple_radius)
			child.player_left_item_radius.connect(player_outside_grapple_radius)
		#
		# Recursively check the children of each node
		if child.has_method("get_children"):
			connect_children(child)
	
	
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	var input_axis := Input.get_axis("move_left", "move_right")
	input_axis = sign(input_axis)
	control_movement(input_axis, delta)
	perform_actions(input_axis)
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	if was_on_wall:
		was_wall_normal = get_wall_normal()


	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#print("Collided with: ", collision.get_collider().name)

	
	move_and_slide()
	
	wall_jump_grace(was_on_wall)
	coyote_grace(was_on_floor)
	
	jump_buffer(was_on_floor)
	handle_wall_jump_buffer(was_on_wall, was_on_floor)

## Environment
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * movement_data.gravity_scale * delta
	

## Movement
func control_movement(input_axis,delta):
	
	
	process_jump_input()
	handle_floor_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	
	#handle_wall_slide(input_axis)
	#handle_wall_jump(input_axis)
	
	
	#execute_dink(input_axis)
	

## Acceleration
func handle_floor_acceleration(input_axis, delta):
	#if print_movement: print('acceleration')
	if not is_on_floor(): return
	if input_axis == 0:
		# Friction
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
	else:
		# Acceleration
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, (movement_data.acceleration) * delta)
	
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	# Acceleration
	velocity.x = move_toward(velocity.x, input_axis * movement_data.air_velocity, movement_data.air_acceleration * delta)
	velocity.y = move_toward(velocity.y, movement_data.speed, movement_data.air_acceleration * delta)
	# Friction
	velocity.x = move_toward(velocity.x, 0.0, movement_data.air_resistance * delta)
	velocity.y = move_toward(velocity.y, 0.0, movement_data.air_resistance * delta)
	

	
func execute_jump():
	if print_movement: print('jump')
	velocity.y = movement_data.jump_velocity	
	
## Jumping
func process_jump_input():
	if Input.is_action_just_pressed("jump"):
		
		check_jump_buffer()
		
		#if is_on_wall_only():
			#print('jump')
			#execute_wall_jump()
		
		# Wall jump
		if can_perform_wall_jump() and not is_on_floor():
			execute_wall_jump()
		
		# Normal jump / coyote jump
		if is_on_floor() or check_coyote_jump():
			if not is_on_floor():
				if print_movement: print('coyote jump')
			execute_jump()
		
	
func check_coyote_jump():
	return coyote_jump_timer.time_left > 0.0
	
func jump_buffer(was_on_floor):
	# Jump buffer
	if not enable_jump_buffer: return
	if not was_on_floor and is_on_floor():
		if jump_buffered:
			if print_movement: print('jump buffered')
			execute_jump()
			jump_buffered = false
	
func can_perform_wall_jump():  # Problem: if i let go even though im next to the wall, i cannot jump
	if is_on_wall_only()  or wall_jump_timer.time_left > 0.0:
		if print_movement: print('can_wall_jump')
		return true
	
func execute_wall_jump():
	if print_movement: print('wall-jump')
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	velocity.x = wall_normal.x * movement_data.wall_jump_velocity_x
	velocity.y = movement_data.jump_velocity
	#velocity.y = -movement_data.wall_jump_velocity_x
	just_wall_jumped = true
	
func handle_wall_jump_buffer(was_on_wall, was_on_floor):
	# Wall-jump buffer
	if not was_on_wall and is_on_wall() and not was_on_floor:
		if jump_buffered:
			if print_movement: print('wall-jump buffered')
			execute_wall_jump()
			jump_buffered = false	
	
# Jump buffer, used by jump & wall-jump
func check_jump_buffer():
	if not is_on_floor() and not jump_buffered:
		jump_buffered = true
		jump_buffer_timer.start()
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false

## Grace period stuff
func coyote_grace(was_on_floor):
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
		
func wall_jump_grace(was_on_wall):
	# Wall jump grace period
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()
	
	
	
## WALL SLIDE (could be more efficient)
func handle_wall_slide(input_axis):
	if is_on_wall_only() and input_axis != 0.0:
		if not wall_slide_timer_running:
		#print('started_timer')
			wall_slide_timer.start()
			wall_slide_timer_running = true
		
		if velocity.y > 0 and wall_slide_timer_running and input_axis != 0.0:
			#print(wall_slide_timer.time_left)
			if wall_slide_timer.time_left > 0.0:
				# Hold on
				#velocity.y = move_toward(velocity.y, 0.0, movement_data.friction)
				velocity.y = 0.0
			else:
				# start to slide
				velocity.y = movement_data.slide_velocity
		
	if not is_on_wall_only() and wall_slide_timer_running:
		#print('stopped timer')
		wall_slide_timer_running = false
	
## ACTIONS
func perform_actions(input_axis):
	handle_dink(input_axis)
	handle_grapple(input_axis)

func item_vector(it: Item) -> Vector2:
	return (it.global_position - global_position).normalized()

## Grapple
func handle_grapple(input_axis):
	if grapple_target != null: # and not has_executed_grapple:
		# Updated with process!
		grapple_direction = item_vector(grapple_target)
		
		var player_detector = grapple_target.get_node("PlayerDetector/CollisionShape2D")
		var radius = player_detector.shape.radius
		
		if Input.is_action_just_pressed('dink') and not is_on_floor() and not is_on_wall():
			dink_input_axis = input_axis
			
			# Desired distance to follow the grapple target
			print(radius)
			
			
func player_within_grapple_radius(grapple):
	if print_action: print('player within grapple radius')
	#can_execute_dink = true
	grapple_target = grapple
	
func player_outside_grapple_radius():
	if print_action: print('player outside grapple radius')
	grapple_target = null
	#has_executed_grapple = false
	
	
	
### Dink
	
func handle_dink(input_axis):
	
	if dink_target != null and not has_executed_dink:
		# Updated with process!
		dink_direction = item_vector(dink_target)
		
		if Input.is_action_just_pressed('dink') and not is_on_floor() and not is_on_wall():
			dink_input_axis = input_axis
			velocity = dink_direction * movement_data.dink_speed
			can_execute_dink = true
			has_executed_dink = true
			
func execute_dink():
	if can_execute_dink:
		if print_action: print('execute dink')
		velocity.x = dink_input_axis * movement_data.dink_speed / 1.5
		velocity.y = -movement_data.dink_speed
		can_execute_dink = false
		has_executed_dink = true
	
func player_within_dink_radius(dink):
	if print_action: print('player within dink radius')
	#can_execute_dink = true
	dink_target = dink
	
func player_outside_dink_radius():
	if print_action: print('player outside dink radius')
	dink_target = null
	has_executed_dink = false
