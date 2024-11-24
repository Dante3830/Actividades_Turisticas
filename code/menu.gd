extends Control

func _ready() -> void:
	$VBoxContainer/start.grab_focus();

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scene.tscn");

func _on_options_pressed() -> void:
	var options = load("res://ui/options.tscn").instantiate();
	get_tree().get_current_scene().add_child(options);

func _on_quit_pressed() -> void:
	get_tree().quit();
