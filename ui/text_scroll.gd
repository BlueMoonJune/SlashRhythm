extends ScrollContainer

var scroll_dir = 1
var scroll_wait = 1
var scroll_acc = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if size.x < get_child(0).size.x:
		if scroll_wait <= 0:
			scroll_wait += 1
			scroll_dir *= -1
		else:
			scroll_acc += scroll_dir * delta * 100
			var intScroll = int(scroll_acc)
			var oldScroll = scroll_horizontal
			scroll_horizontal += intScroll
			if abs(scroll_acc) > 1 and scroll_horizontal == oldScroll:
				scroll_wait -= delta
			scroll_acc -= intScroll
