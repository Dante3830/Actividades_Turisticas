extends Control

func _ready() -> void:
	$VBoxContainer/back.grab_focus();

func _on_back_pressed() -> void:
	queue_free();
