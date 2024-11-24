extends CharacterBody3D

var speed:          float  = 0.75;
var aceleration:    float  = 5.0;
var nest_reference: Node3D = null;

var on_travel: bool;
var go_back_home: bool;
var traveling_home_timer: float;

var last_cookie_reference:  Node3D = null;
var cookie_reference_timer: float;

@onready var nav: NavigationAgent3D = $NavigationAgent3D;
@onready var COOKIE_POOL: Node3D    = $"/root/main_scene/gameplay/cookie_pool"
@onready var PARADISE_POOL: Node3D  = $"/root/main_scene/gameplay/paradise_pool"

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	on_travel = false;
	go_back_home = false;

func _physics_process(delta: float):
	var dir = Vector3();
	
	var is_a_cookie_nearby  = false;
	var new_target_position = nest_reference.global_position;
	var cookie_position;
	
	var cookies = Array();
	
	for it in COOKIE_POOL.get_children():
		if(it != null && it.global_position.distance_to(global_position) < 2.0):
			cookies.push_back(it);
	
	is_a_cookie_nearby = not cookies.is_empty();
	if(is_a_cookie_nearby):
		cookie_position = cookies[0].global_position;
		
		var nest_position = nest_reference.global_position;
		var distance_to_cookie = nest_position.distance_to(cookie_position);
		for it in cookies:
			var it_cookie_position = it.global_position;
			
			if(distance_to_cookie < nest_position.distance_to(it_cookie_position)):
				cookie_position = it_cookie_position;
	
	if(not go_back_home && is_a_cookie_nearby):
		new_target_position = cookie_position;
		on_travel = true;
	
	if(on_travel && not is_a_cookie_nearby):
		on_travel = false;
		go_back_home = true;
		new_target_position = nest_reference.global_position;
	
	nav.target_position = new_target_position;
	
	dir = nav.get_next_path_position() - global_position;
	dir = dir.normalized();
	
	velocity = velocity.lerp(dir * speed, aceleration * delta);
	
	if not is_on_floor():
		velocity.y -= gravity * delta;
		
	move_and_slide();

func _process(delta: float):
	if(last_cookie_reference != null):
		cookie_reference_timer += delta;
	
	if(go_back_home):
		traveling_home_timer += delta;
		
		if(traveling_home_timer > 2.5):
			traveling_home_timer = 0;
			go_back_home = false;
	
	
	for it in PARADISE_POOL.get_children():
		if(it != null && it.global_position.distance_to(global_position) < 0.5):
			nest_reference.ant_count -= 1;
			queue_free();
