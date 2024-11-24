extends CharacterBody3D

const ant_controller    = preload("res://code/ant_controller.gd");
const camera_controller = preload("res://code/camera_controller.gd");
const cookie_controller = preload("res://code/cookie.gd");

const cookie = preload("res://gameplay/cookie.tscn");

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

static var VOLUME:   float = 1.0;
static var ON_PAUSE: bool  = false;

@onready var AUDIO_CONTROLLER:  AudioStreamPlayer3D = $"/root/main_scene/AudioStreamPlayer3D"
@onready var ANT_CONTROLLER:    ant_controller    = $"/root/main_scene/ant_controller"
@onready var GROUND_POINT:      Node3D            = $"/root/main_scene/ant_controller/model/ground_point"
@onready var CAMERA_MOUNT:      Node3D            = $"/root/main_scene/ant_controller/camera_mount_controller"
@onready var CAMERA_CONTROLLER: camera_controller = $"/root/main_scene/ant_controller/camera_mount_controller/camera_controller"
@onready var UI_CONTROLLER:     Control           = $"/root/main_scene/ui_controller"

@onready var COOKIE_POOL: Node3D = $"/root/main_scene/gameplay/cookie_pool"

@onready var ANIMATION_TREE: AnimationTree      = $"/root/main_scene/ant_controller/model/AnimationTree"
@onready var ANIMATION_PLAYER: AnimationPlayer  = $"/root/main_scene/ant_controller/model/AnimationPlayer"

var max_walk_speed: float = 40.0;
var max_back_speed: float = 30.0;
var max_side_speed: float = 35.0;
var max_jump_power: float = 5.0;

var max_box_push_force: float = 25.0;
var max_ant_push_force: float = 5.0;

var current_speed:  float;
var current_jump:   int;

# @NOTE(Liman1): Utility variables used for movement.
var target_direction: Vector3;

# @NOTE(Liman1): This variables will be used by others scripts.
var ignore_movement: bool = false;

# @NOTE(Liman1): Cookie Clicker!
var cookie_count: int = 0;
var stored_gravity: float;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	current_speed    = max_walk_speed;
	target_direction = ANT_CONTROLLER.rotation;
	
	UI_CONTROLLER.get_children()[0].text = "Galletas:\n" + str(ANT_CONTROLLER.cookie_count);
	
	stored_gravity = ANT_CONTROLLER.gravity;
	AUDIO_CONTROLLER.play();

func _process(delta: float):
	AUDIO_CONTROLLER.volume_db = log(VOLUME) * 8.6858896380650365530225783783321;
	
	if not ON_PAUSE && Input.is_action_just_pressed("pause"):
		ON_PAUSE = true;
		
		var pause = load("res://ui/pause.tscn").instantiate();
		get_tree().get_current_scene().add_child(pause);
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	
	if ON_PAUSE:
		return;
	
	if Input.is_action_pressed("hack"):
		cookie_count += 1;
		UI_CONTROLLER.get_children()[0].text = "Galletas:\n" + str(ANT_CONTROLLER.cookie_count);
	
	
	if Input.is_action_just_pressed("game_pickup"):
		var facing_direction = ANT_CONTROLLER.get_children()[0].transform.basis.z;
		
		var origin = ANT_CONTROLLER.global_position;
		var target = GROUND_POINT.global_position;
		var distance = target.distance_to(origin);
		
		var dir_vector = (target - origin).normalized();
		var end = origin + dir_vector * distance;
		
		var query  = PhysicsRayQueryParameters3D.create(origin, end);
		var result = get_world_3d().direct_space_state.intersect_ray(query);
		
		if(result):
			var other = result.collider;
			if(other is CharacterBody3D):
				other.velocity = facing_direction.normalized() * max_ant_push_force;
			elif(other is RigidBody3D):
				other.apply_force(facing_direction.normalized() * max_box_push_force);
			
			return;
		
	if Input.is_action_just_pressed("game_drop"):
		var facing_direction = ANT_CONTROLLER.get_children()[0].transform.basis.z;
		
		var origin = ANT_CONTROLLER.global_position;
		var target = GROUND_POINT.global_position;
		var distance = target.distance_to(origin);
		
		var dir_vector = (target - origin).normalized();
		var end = origin + dir_vector * distance;
		
		var query  = PhysicsRayQueryParameters3D.create(origin, end);
		var result = get_world_3d().direct_space_state.intersect_ray(query);
		
		if(result):
			return;
		
		if ANT_CONTROLLER.cookie_count > 0:
			ANT_CONTROLLER.cookie_count-=1;
			UI_CONTROLLER.get_children()[0].text = "Galletas:\n" + str(ANT_CONTROLLER.cookie_count);
			
			var instance = cookie.instantiate();
			COOKIE_POOL.add_child(instance);
			
			instance.get_children()[0].material_override.set_local_to_scene(true);
			instance.get_children()[0].material_override.next_pass.set_local_to_scene(true);
			instance.global_position = GROUND_POINT.global_position;

func _physics_process(delta):
	
	if ON_PAUSE:
		return;
	
	# @NOTE(Liman1):
	# This code for the player_movement is temporary, with the porpurse of 
	# 'getting something moving'.
	# Is not even close to the final code. So be kind with it <3
	
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
	
	if not is_on_floor():
		ANT_CONTROLLER.velocity.y -= gravity * delta;
	else: 
		current_jump = 2;
		ANT_CONTROLLER.gravity = stored_gravity;
	
	if Input.is_action_just_pressed("move_jump"):
		if current_jump > 0:
			current_jump -= 1;
			ANT_CONTROLLER.velocity = Vector3.UP * max_jump_power;
	
	if ANT_CONTROLLER.velocity.y < 0 && current_jump == 0:
		ANT_CONTROLLER.gravity = stored_gravity * 0.25;
	
	ANIMATION_TREE["parameters/movements/conditions/land"] =  is_on_floor();
	ANIMATION_TREE["parameters/movements/conditions/fall"] = !is_on_floor();
	ANIMATION_TREE["parameters/movements/idle_to_fall/blend_position"] = ANT_CONTROLLER.velocity.y;
	
	if do_move:
		var camera_yaw = CAMERA_MOUNT.rotation.y;
		ANT_CONTROLLER.get_children()[0].rotation.y = camera_yaw;
		
		var rotation_speed = 10;
		var value = lerpf(ANT_CONTROLLER.get_children()[0].rotation.y, camera_yaw, delta * rotation_speed);
		ANT_CONTROLLER.get_children()[0].rotation.y = value;
		
		var move = current_speed * delta;
		var facing_direction = ANT_CONTROLLER.get_children()[0].transform.basis.z;
		
		ANT_CONTROLLER.move_and_collide(facing_direction.rotated(Vector3.UP, velocity.angle()) * move);
		
		ANIMATION_TREE["parameters/movements/idle_to_walk/blend_position"] = move;
	else:
		ANIMATION_TREE["parameters/movements/idle_to_walk/blend_position"] = 0;
	
	move_and_slide()
