class_name Hud
extends CanvasLayer

signal action_selected(action_name: String)

func _ready() -> void:
	$MarginContainer/HBox_Actions/Btn_Move.pressed.connect(_on_move_pressed)

func _on_move_pressed() -> void:
	action_selected.emit("move")
	get_viewport().set_input_as_handled()
