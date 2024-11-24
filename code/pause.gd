extends Control

const ant_controller    = preload("res://code/ant_controller.gd");

func _on_back_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	ant_controller.ON_PAUSE = false;
	queue_free();

func _on_quit_pressed() -> void:
	get_tree().quit();

func _on_ready() -> void:
	$PanelContainer/VBoxContainer/HSlider.value = ant_controller.VOLUME;
	#$PanelContainer/VBoxContainer/CheckButton.toggle_mode = get_viewport().get_window().mode == DisplayServer.WINDOW_MODE_FULLSCREEN;

func _on_h_slider_value_changed(value: float) -> void:
	ant_controller.VOLUME = value;

func _on_check_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

func _on_menu_pressed() -> void:
	ant_controller.ON_PAUSE = false;
	get_tree().change_scene_to_file("res://ui/menu.tscn");
