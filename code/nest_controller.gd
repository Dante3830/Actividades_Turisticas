extends Node3D

const ant_controller = preload("res://code/ant_controller.gd");
var   ant_factory    = preload("res://gameplay/bot_ant.tscn");

const max_ant_count: int = 5;
var ant_count:     int   = 0;
var elapsed:       float = 0;

func _process(delta: float):
	elapsed += delta;
	
	if(elapsed > 1.25):
		elapsed = 0;
		
		if(ant_count < max_ant_count):
			ant_count += 1;
			
			var instance = ant_factory.instantiate();
			instance.nest_reference = self;
			
			get_tree().root.add_child(instance);
			instance.global_position = self.global_position;
