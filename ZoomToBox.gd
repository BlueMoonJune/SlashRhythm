extends Camera2D

@export var size : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var winres = get_tree().root.size
	var winasp = winres.x/float(winres.y)
	var boxasp = size.x/size.y
	if winasp > boxasp:
		zoom.y = winres.y / size.y
		zoom.x = zoom.y
	else:
		zoom.y = winres.x / size.x
		zoom.x = zoom.y
