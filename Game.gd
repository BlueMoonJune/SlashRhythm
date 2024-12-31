extends Node2D

var BPM
var SPB
const chartsPath = "res://charts/"

var volume = 0.5
var indExp = 4.0
var indDist = 2.0
var indDur = 0.5
var startBeat = -0x2
var hitWindowAlpha = 0.5

var cur_beat = 0
var time = 0

var objs = []
var typeList = []

var energy : float = 100
var score = 0
var raw_score = 0
var max_score = 0
var combo = 0

var objTypes = {
	"std" : load("res://objects/std/object.tscn")
}

var lastMouse

var length
var chartdir : String
var chartname : String

func parse_fracstr(s: String) -> float:
	var i = s.find('/')
	if i == -1: return s.to_float()
	return s.substr(0, i).to_float() / s.substr(i + 1).to_float()

func load_chart(dir, chart = "chart"):
	energy = 100
	score = 0
	add_score(0)
	raw_score = 0
	max_score = 0
	combo = 0
	objs = []
	chartdir = dir
	chartname = chart
	$Song.stream = load(dir + "/audio.ogg")
	var file = FileAccess.open(dir + "/" + chart + ".ch", FileAccess.READ)
	var line1 = file.get_line().rsplit(" ", false)
	BPM = line1[0].to_float()
	SPB = 60 / BPM
	var lines = []
	var time = 0
	while not file.eof_reached():
		var line = file.get_line()
		if line != "" and line[0] != "#":
			line = line.rsplit(" ", false)
			time += line[0].to_float() * SPB
			if time / SPB >= %Start.value:
				var node : Node = objTypes[line[1]].instantiate()
				node.time = time
				add_child(node)
				node.ctor(line.slice(2))
			
	var start = %Start.value + startBeat
	if start < 0:
		$Timer.start(-start * SPB)
	else:
		$Song.play(start * SPB)
	length = time
	%Start.max_value = length / SPB
	%End.max_value = %Start.max_value
	if %End.value == 0:
		%End.value = %End.max_value

var paused_media = false
func _ready():
	assert(parse_fracstr("2/3") == 2.0/3.0)
	get_tree().set_auto_accept_quit(false)
	var out = []
	OS.execute("playerctl", ["status"], out)
	if out[0] == "Playing\n":
		OS.execute("playerctl", ["pause"])
		paused_media = true
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if paused_media:
			OS.execute("playerctl", ["play"])
		get_tree().quit()


func _physics_process(delta):
	if $Song.stream_paused: return
	if not lastMouse:
		lastMouse = get_local_mouse_position()
	var col = $MouseRay/CollisionShape2D.shape as SegmentShape2D
	col.a = get_local_mouse_position()
	col.b = lastMouse
	lastMouse = get_local_mouse_position()
	$Trail.add_point(col.a)
	if len($Trail.points) >= 5:
		$Trail.remove_point(0)

func _process(delta: float) -> void:
	if not $Timer.is_stopped():
		time = -$Timer.time_left
	else:
		var ttime = $Song.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		if ttime > time: time = ttime
	
	var beat = time / SPB
	
	if beat > %End.value:
		load_chart(chartdir)
		time = 0
	
	var dtExp = 1 - 0.01 ** delta
	energy = clamp(energy, 0, 100)
	$UI/UI/EnergyL.anchor_top = lerp($UI/UI/EnergyL.anchor_top, 1 - energy / 100, dtExp)
	$UI/UI/EnergyR.anchor_bottom = lerp($UI/UI/EnergyR.anchor_bottom, energy / 100, dtExp)
	if energy == 0:
		#get_tree().change_scene_to_file("res://ui/ChartSelect.tscn")
		pass
		

	$UI/UI/EnergyL.color.g = max($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20 + 1
	$UI/UI/EnergyL.color.r = 1 - min($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20
	$UI/UI/EnergyR.color.g = max($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20 + 1
	$UI/UI/EnergyR.color.r = 1 - min($UI/UI/EnergyL.anchor_top - 1 + energy / 100, 0) * 20
	
	$UI/UI/TimeT.anchor_right = time / length 
	$UI/UI/TimeB.anchor_left = 1 - time / length

	$UI/UI/Score.scale = lerp($UI/UI/Score.scale, Vector2.ONE, dtExp)
	
	$UI/UI/Multiplier/Fill.texture.gradient.offsets[1] = fmod(combo / 20.0, 1) if get_mult() != 8 else 1
	$UI/UI/Combo.text = str(combo)
	$UI/UI/MultText.text = "x" + str(get_mult())
	$UI/UI/Accuracy.text = str(raw_score * 100.0 / max_score).pad_decimals(1) + "%"
	

func get_mult():
	return min(combo / 20 + 1, 8)

func add_score(amount: int) -> void:
	raw_score += amount
	amount *= get_mult()
	score += amount
	$UI/UI/Score.text = str(score)
	$UI/UI/Points.text = str(amount)
	$UI/UI/Score.scale = Vector2.ONE * 1.5
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed() == true and !$Song.stream_paused:
		$Song.stream_paused = true
		$UI/Pause.show()
		$UI/Pause/Button.position = $UI/Pause.get_local_mouse_position() - Vector2.ONE * 20


func _on_button_pressed() -> void:
	$Song.stream_paused = false
	$UI/Pause.hide()


func _on_timer_timeout() -> void:
	$Song.play()


func _on_restart_pressed() -> void:
	load_chart(chartdir, chartname)
	$UI/Pause.hide()
	


func _on_exit_pressed() -> void:
	#get_tree().change_scene_to_file("res://ui/ChartSelect.tscn")
	pass


func _on_start_drag_ended(value_changed: bool) -> void:
	$Song.play(%Start.value * SPB)


func _on_end_drag_ended(value_changed: bool) -> void:
	$Song.play(%End.value * SPB - 5)
