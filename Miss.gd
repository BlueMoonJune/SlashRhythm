extends Sprite2D

var lifetime
var age = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2.ZERO
	lifetime = $"../..".indDur
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	age += delta
	modulate.a = 1 - (age / lifetime)
	scale = scale.lerp(Vector2.ONE, 0.1)
	if age > lifetime: queue_free()
