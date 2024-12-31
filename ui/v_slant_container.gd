@tool
extends VBoxContainer

@export var factor : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
 

func _on_sort_children() -> void:
	for child in get_children():
		child.position.x -= child.position.y * factor
