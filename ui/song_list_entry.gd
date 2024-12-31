extends Control

@export var chart_dir : String = ""
var chart_data : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chart_data = JSON.parse_string(FileAccess.open(chart_dir + "/meta.json", FileAccess.READ).get_as_text())
	%Title.text = chart_data.artist + " - " + chart_data.track
	%Charter.text = chart_data.charter

func _draw() -> void:
	var difs = chart_data.difficulties.map(func(a): return a.difficulty)
	var hardest = difs.reduce(max)
	var easiest = difs.reduce(min)
	if not hardest: return
	hardest = floor(hardest)
	easiest = floor(easiest)
	var s = $Panel/HBoxContainer.get_child(0).size.x / (hardest - easiest + 1)
	for dif in difs:
		var x = s * dif - s * (easiest - 0.5) - 8
		draw_line(Vector2(x, size.y), Vector2(x, size.y - 10), Color.WHITE)
	for dif in range(easiest, hardest + 1):
		var x = s * dif - s * (easiest - 0.5) - 8
		draw_line(Vector2(x - s * 0.4, size.y - 5), Vector2(x + s * 0.4, size.y - 5), 
			Color.from_hsv((7 - dif) / 12.0, 0.7, 1.0)
		)


func _on_button_pressed() -> void:
	var node = load("res://Game.tscn").instantiate()
	get_tree().root.add_child(node)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = node
	node.load_chart(chart_dir)
