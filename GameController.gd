extends Node2D

var BPM
var SPB
const chartsPath = "res://charts/"

var volume = 0.5
var indExp = 4.0
var indDist = 2.0
var indDur = 0.5
var startBeat = -0x10
var hitWindowAlpha = 0.5

var cur_beat = 0
var time = 0

var objs = []
var typeList = []

var energy : float = 100
var score = 0
var combo = 0

var objTypes = {
	"std" : "res://note.tscn"
}

var lastMouse

var length

func load_chart(dir):
	$Song.stream = load(chartsPath + dir + "/audio.ogg")
	var file = FileAccess.open(chartsPath + dir + "/chart.ch", FileAccess.READ)
	var line1 = file.get_line().rsplit(" ", false)
	BPM = line1[0].to_float()
	SPB = 60 / BPM
	var lines = []
	var time = 0
	while not(file.eof_reached()):
		var line = file.get_line()
		
		if line != "" and line[0] != "#":
			line = line.rsplit(" ", false)
			var node : Node = load(objTypes[line[1]]).instantiate()
			time += line[0].to_float() * SPB
			node.time = time
			add_child(node)
			node.ctor(line.slice(2))
			
	$Song.play()
	length = time

func _ready():
	get_tree().set_auto_accept_quit(false)
	OS.execute("playerctl", ["pause"])
	load_chart("heracles")
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		OS.execute("playerctl", ["play"])
		get_tree().quit()


func _physics_process(delta):
	if not lastMouse:
		lastMouse = get_local_mouse_position()
	var col = $MouseRay/CollisionShape2D.shape as SegmentShape2D
	col.a = get_local_mouse_position()
	col.b = lastMouse
	lastMouse = get_local_mouse_position()

func _process(delta: float) -> void:
	time = $Song.get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	#print("Time is: ", time)q
	
	var beat = time / SPB
	var dtExp = 1 - 0.1 ** delta
	energy = clamp(energy, 0, 100)
	$UI/UI/EnergyL.anchor_top = lerp($UI/UI/EnergyL.anchor_top, 1 - energy / 100, dtExp)
	$UI/UI/EnergyR.anchor_bottom = lerp($UI/UI/EnergyR.anchor_bottom, energy / 100, dtExp)
	print(energy)
	$UI/UI/EnergyL.color.g = max($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20 + 1
	$UI/UI/EnergyL.color.r = 1 - min($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20
	$UI/UI/EnergyR.color.g = max($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20 + 1
	$UI/UI/EnergyR.color.r = 1 - min($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20
	
	$UI/UI/TimeT.anchor_right = time / length 
	$UI/UI/TimeB.anchor_left = 1 - time / length

	$UI/UI/Score.scale = lerp($UI/UI/Score.scale, Vector2.ONE, dtExp)
	
	$UI/UI/Multiplier/Fill.texture.gradient.offsets[1] = fmod(combo / 20.0, 1)
	$UI/UI/Combo.text = str(combo)
	$UI/UI/MultText.text = "x" + str(get_mult())
	

func get_mult():
	return min(combo / 20 + 1, 8)

func add_score(amount: int) -> void:
	amount *= get_mult()
	score += amount
	$UI/UI/Score.text = str(score)
	$UI/UI/Points.text = str(amount)
	$UI/UI/Score.scale = Vector2.ONE * 1.5
