extends Node3D

const ant_controller = preload("res://code/ant_controller.gd");

const can_interact_max_distance = 0.5;
const outline_width = 1.5;

@onready var ANT_CONTROLLER: ant_controller = $"/root/main_scene/ant_controller"
@onready var UI_CONTROLLER:  Control        = $"/root/main_scene/ui_controller"

func _ready():
	pass

func _process(delta):
	var outline_shader_reference = get_children()[0].material_override.next_pass;
	
	var distance = position.distance_to(ANT_CONTROLLER.position);
	if(distance < can_interact_max_distance):
		outline_shader_reference.set_shader_parameter("outline_width", outline_width);
		
		if Input.is_action_just_pressed("game_pickup"):
			queue_free();
			
			ANT_CONTROLLER.cookie_count += 1;
			UI_CONTROLLER.get_children()[0].text = "Galletas:\n" + str(ANT_CONTROLLER.cookie_count);
	else:
		outline_shader_reference.set_shader_parameter("outline_width", 0);
