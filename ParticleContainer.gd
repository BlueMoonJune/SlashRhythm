extends Node2D

func _process(delta: float) -> void:
	for child in get_children():
		if child is CPUParticles2D and not child.emitting:
			child.queue_free()
			continue
