extends Node3D

const ant_controller    = preload("res://code/ant_controller.gd");
const camera_controller = preload("res://code/camera_controller.gd");

@onready var ANT_CONTROLLER:    ant_controller    = $"/root/main_scene/ant_controller"
@onready var CAMERA_MOUNT:      Node3D            = $"/root/main_scene/ant_controller/camera_mount_controller"
@onready var CAMERA_CONTROLLER: camera_controller = $"/root/main_scene/ant_controller/camera_mount_controller/camera_controller"

# @NOTE(Liman1): Configurable values.
var body_height_offset: float;
var distance_from_player: float;
var angle_around_player: float;

var on_shoulders_position: Vector3;

# @NOTE(Liman1): Dinamyc values.
var normal_offset: Vector3;

var mouse_motion: Vector2;
var last_mouse_motion: Vector2;

var camera_angles: Vector2;

func _ready():
	body_height_offset    = 1.5;
	angle_around_player   = 0;
	on_shoulders_position = CAMERA_CONTROLLER.position;
	
	distance_from_player = ANT_CONTROLLER.global_position.distance_to(CAMERA_CONTROLLER.global_position);

func _physics_process(delta):
	CAMERA_MOUNT.rotation.x = deg_to_rad(camera_angles.x);
	CAMERA_MOUNT.rotation.y = deg_to_rad(camera_angles.y);
	
	var origin = CAMERA_MOUNT.global_position;
	var camera_origin =  CAMERA_CONTROLLER.global_position - normal_offset;
	
	var dir_vector = (camera_origin - origin).normalized();
	var end = origin + dir_vector * distance_from_player;
	
	var query  = PhysicsRayQueryParameters3D.create(origin, end);
	var result = get_world_3d().direct_space_state.intersect_ray(query);
	
	CAMERA_CONTROLLER.position = on_shoulders_position;
	
	# @NOTE(Liman1): Temporary ignore collisions.
	# return;
	
	if(!result):
		normal_offset = Vector3(0, 0, 0);
		CAMERA_CONTROLLER.position = on_shoulders_position;
	else:
		normal_offset = result.normal * 0.05;
		#normal_offset = Vector3(0, 0, 0);
		CAMERA_CONTROLLER.global_position = result.position + normal_offset;
	
	return;

func _process(delta):	#@NOTE(Liman1): Temporary joystick handle. 
	var velocity = Vector2(
		Input.get_action_strength("cursor_right") - Input.get_action_strength("cursor_left"),
		Input.get_action_strength("cursor_back") - Input.get_action_strength("cursor_forward")
	).limit_length(1.0);
	
	# @NOTE(Liman1): Use configurable sensibilities.
	var joy_sensibility = 250.0;
	
	var new_pitch = camera_angles.x + velocity.y * joy_sensibility * delta;
	if new_pitch > -90 && new_pitch < 90:
		camera_angles.x = new_pitch;
		
	camera_angles.y -= velocity.x * joy_sensibility * delta;

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			last_mouse_motion = mouse_motion;
			mouse_motion += event.relative;
			
			# @NOTE(Liman1): Use configurable sensibilities.
			var x_sens = 0.25;
			var y_sens = 0.25;
			
			camera_angles.y += (last_mouse_motion.x - mouse_motion.x) * x_sens;
			
			var new_pitch = camera_angles.x - (last_mouse_motion.y - mouse_motion.y) * y_sens;
			if new_pitch > -90 && new_pitch < 90:
				camera_angles.x = new_pitch;
