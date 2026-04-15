class_name ActionsHUD
extends CanvasLayer

signal action_selected(action_name: String)

func _ready() -> void:
	$MarginContainer/HBox_Actions/Btn_Move.pressed.connect(_on_move_pressed)
	$MarginContainer/HBox_Actions/Btn_Melee.pressed.connect(_on_melee_pressed)
	$MarginContainer/HBox_Actions/Btn_Range.pressed.connect(_on_range_pressed)

func _on_move_pressed() -> void:
	action_selected.emit("move")

func _on_melee_pressed() -> void:
	action_selected.emit("melee")

func _on_range_pressed() -> void:
	action_selected.emit("range")
