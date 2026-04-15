class_name Timeline
extends CanvasLayer

@onready var portrait_list: HBoxContainer = $MarginContainer/HBox_Timeline
@export var item_scene: PackedScene 

func generate_visuals(turn_order: Array) -> void:
	for child in portrait_list.get_children():
		child.queue_free()
		
	for pawn in turn_order:
		var new_item = item_scene.instantiate() as TimelineItem
		
		portrait_list.add_child(new_item)
		
		if pawn.data:
			new_item.setup(pawn.data)
			
