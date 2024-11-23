extends Node3D

const ant_controller    = preload("res://code/ant_controller.gd");
const camera_controller = preload("res://code/camera_controller.gd");
const cookie_controller = preload("res://code/cookie.gd");

@onready var ANT_CONTROLLER:    ant_controller    = $"/root/main_scene/ant_controller"
@onready var GROUND_POINT:      Node3D            = $"/root/main_scene/ant_controller/ground_point"
@onready var CAMERA_MOUNT:      Node3D            = $"/root/main_scene/ant_controller/camera_mount_controller"
@onready var CAMERA_CONTROLLER: camera_controller = $"/root/main_scene/ant_controller/camera_mount_controller/camera_controller"
@onready var UI_CONTROLLER:     Control           = $"/root/main_scene/ui_controller"

var max_walk_speed: float = 4.5;
var max_back_speed: float = 2.5;
var max_side_speed: float = 3.0;
var max_run_power: float  = 2.0;
var current_speed: float;

# @NOTE(Liman1): Utility variables used for movement.
var target_direction: Vector3;

# @NOTE(Liman1): This variables will be used by others scripts.
var ignore_movement: bool = false;

# @NOTE(Liman1): Cookie Clicker!
var cookie_count: int = 3;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	current_speed    = max_walk_speed;
	target_direction = ANT_CONTROLLER.rotation;
	
	UI_CONTROLLER.get_children()[0].text = "x" + str(ANT_CONTROLLER.cookie_count);

func _physics_process(delta):
	if ignore_movement:
		return;
	
	# @NOTE(Liman1):
	# This code for the player_movement is temporary, with the porpurse of 
	# 'getting something moving'.
	# Is not even close to the final code. So be kind with it <3
	
	if Input.is_action_just_pressed("game_drop"):
		if ANT_CONTROLLER.cookie_count > 0:
			ANT_CONTROLLER.cookie_count-=1;
			UI_CONTROLLER.get_children()[0].text = "x" + str(ANT_CONTROLLER.cookie_count);
			
			var cookie = load("res://gameplay/cookie.tscn");
			var instance = cookie.instantiate();
			get_tree().root.add_child(instance);
			
			instance.get_children()[0].material_override.set_local_to_scene(true);
			instance.get_children()[0].material_override.next_pass.set_local_to_scene(true);
			instance.global_position = GROUND_POINT.global_position;
	
	var do_move = false;
	
	var velocity = Vector2(
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"),
		Input.get_action_strength("move_left")    - Input.get_action_strength("move_right"),
	).limit_length(1.0);
	
	if velocity.x != 0 || velocity.y != 0:
		do_move = true;
		if(velocity.x > 0): 
			current_speed = max_walk_speed; 
		else: 
			current_speed = max_back_speed;
	
	#if Input.is_action_pressed("move_run") && velocity.x > 0:
	#	velocity.x *= 2.0;
	#	current_speed *= max_run_power;
	
	var current_velocity = velocity;
	
	var origin     = ANT_CONTROLLER.global_position;
	var dir_vector = Vector3.DOWN;
	var end = origin + dir_vector*0.75;
	
	var query  = PhysicsRayQueryParameters3D.create(origin, end);
	var result = get_world_3d().direct_space_state.intersect_ray(query);
	
	if do_move:
		var camera_yaw = CAMERA_MOUNT.rotation.y;
		ANT_CONTROLLER.get_children()[0].rotation.y = camera_yaw;
		
		var rotation_speed = 10;
		var value = lerpf(ANT_CONTROLLER.get_children()[0].rotation.y, camera_yaw, delta * rotation_speed);
		ANT_CONTROLLER.get_children()[0].rotation.y = value;
		
		var move = current_speed * delta;
		var facing_direction = ANT_CONTROLLER.get_children()[0].transform.basis.z;
		
		ANT_CONTROLLER.global_translate(facing_direction.rotated(Vector3.UP, velocity.angle()) * move);
