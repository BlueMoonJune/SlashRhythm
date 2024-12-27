extends Node2D

@export var color : Color = Color.BLACK

var time : float
var target : Vector2 = Vector2.ZERO
var parent : Node2D

var enter : Vector2
var exit : Vector2
var cut : float = -1

func ctor(args: Array):
	parent = get_parent()
	var vals = args.map(func(n): return n.to_float())
	position.x = vals[0] * 256 - 1280
	position.y = vals[1] * 256 - 1280
	rotation_degrees = vals[2]
	
	color = Color.from_hsv(time / parent.SPB / 6, 1, 1)

func _process(delta):
	var fdt = (parent.time - time) / parent.indDur
	var dt = min(fdt, 0)
	var dtExp = (1 - (1 + dt) ** parent.indExp) * parent.indDist
	var invDtExp = (1 - dt ** parent.indExp)
	color.a = 1 - abs(fdt)
	(material as ShaderMaterial).set_shader_parameter("color", color)
	$Indicator.position.x = -dtExp * 128 * parent.indDist
	$Note.global_position = position * invDtExp
	if cut > -1:
		cut += delta / parent.indDur * 2
		(material as ShaderMaterial).set_shader_parameter("sliceDist", cut)
	

func _on_area_2d_mouse_entered() -> void:
	if -0.2 < (parent.time - time) and (parent.time - time) < 0.2:
		enter = get_local_mouse_position()
	
func _on_area_2d_mouse_exited() -> void:
	if not enter || cut != -1: return
	exit = get_local_mouse_position()
	(material as ShaderMaterial).set_shader_parameter("slicePoint", enter / 256)
	(material as ShaderMaterial).set_shader_parameter("sliceDir", (enter - exit))
	(material as ShaderMaterial).set_shader_parameter("sliceDist", 0)
	cut = 0
	$Indicator.hide()
	$"../Kick".play()
