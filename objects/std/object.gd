extends Node2D

@export var color : Color = Color.BLACK

const missIndicator = preload("res://Miss.tscn")

var time : float
var target : Vector2 = Vector2.ZERO
var parent

var enter : Vector2
var exit : Vector2
var cut : float = -1

func ctor(args: Array):
	parent = get_parent()
	var vals = args.map(func(n): return n.to_float())
	position.x = vals[0] * 256 - 256 * 5
	position.y = vals[1] * 256 - 256 * 5
	rotation_degrees = vals[2]
	
	color = Color.from_hsv(time / parent.SPB / 6, 1, 1)

func _process(delta):
	var fdt = (parent.time - time) / parent.indDur
	visible = fdt > -1
	var dt = min(fdt, 0)
	var dtExp = (1 - (1 + dt) ** parent.indExp) * parent.indDist
	var invDtExp = (1 - dt ** parent.indExp)
	color.a = 1 - abs(fdt)
	if abs(parent.time - time) > 0.2:
		color.a *= parent.hitWindowAlpha
	(material as ShaderMaterial).set_shader_parameter("color", color)
	$Indicator.position.x = -dtExp * 128 * parent.indDist
	$Note.global_position = position * invDtExp
	if cut > -1:
		cut += delta / parent.indDur * 2
		(material as ShaderMaterial).set_shader_parameter("sliceDist", 2 - (1 - cut / 2) ** parent.indExp * 2)
	if cut > 2 or fdt > 1:
		queue_free()
	if (parent.time - time) > 0.2 and cut == -1:
		var node = missIndicator.instantiate()
		node.position = position
		node.modulate = color * 4 + 0.5 * Color.WHITE
		$"../VFXParent".add_child(node)
		assert(node.get_parent() == $"../VFXParent")
		cut = -2
		parent.energy -= 8
		parent.combo = 0
		parent.max_score += 150
	
	
func _on_area_2d_mouse_exited() -> void:
	if not enter || cut >= 0: return
	#exit = get_local_mouse_position()
	var dif = exit - enter
	var angle = atan2(dif.y, dif.x)
	if abs(angle) > PI / 4: return
	(material as ShaderMaterial).set_shader_parameter("slicePoint", enter / 256)
	(material as ShaderMaterial).set_shader_parameter("sliceDir", (enter - exit))
	(material as ShaderMaterial).set_shader_parameter("sliceDist", 0)
	cut = 0
	$Particles.position = exit
	$Particles.rotation = angle
	$Particles.emitting = true
	$Particles.color = color * 4 + Color.WHITE * 0.5
	$Particles.orbit_velocity_min += exit.y / 256
	$Particles.orbit_velocity_max += exit.y / 256
	$Indicator.hide()
	$"../Kick".play()
	parent.energy += 1
	parent.combo += 1
	parent.add_score(int(dif.normalized().x ** 4 * 100 + 50 - 50 ** -(dif.length() / 10)))
	parent.max_score += 150


func _on_area_2d_area_entered(area: Area2D) -> void:
	if abs(parent.time - time) > 0.2 or area != $"../MouseRay": return
	enter = $"../MouseRay/CollisionShape2D".shape.b * transform
	exit = $"../MouseRay/CollisionShape2D".shape.a * transform
	_on_area_2d_mouse_exited()
