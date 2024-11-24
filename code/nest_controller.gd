extends Node3D

const ant_controller = preload("res://code/ant_controller.gd");
var   ant_factory    = preload("res://gameplay/bot_ant.tscn");

@onready var COOKIE_POOL: Node3D = $"/root/main_scene/gameplay/cookie_pool";

const max_ant_count: int = 5;

var has_visitors: bool;
var last_visitor_timer: float;

var ant_count:     int   = 0;
var elapsed:       float = 0;

func _process(delta: float):
	elapsed += delta;
	
	if has_visitors:
		last_visitor_timer += delta;
		has_visitors = last_visitor_timer < 2.5;
	
	
	var cookies_nearby = false;
	for it in COOKIE_POOL.get_children():
		if(it != null && it.global_position.distance_to(global_position) < 2.0):
			cookies_nearby = true;
	
	if not cookies_nearby:
		return;
	
	if(elapsed > 1.25):
		elapsed = 0;
		
		if(ant_count < max_ant_count):
			ant_count += 1;
			
			var instance = ant_factory.instantiate();
			instance.nest_reference = self;
			
			get_tree().root.add_child(instance);
			instance.global_position = self.global_position;
