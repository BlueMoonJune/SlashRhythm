extends Node2D

var BPM
var SPB
const chartsPath = "res://charts/"

var volume = 0.5
var indExp = 4.0
var indDist = 2.0
var indDur = 0.5
var startBeat = -0x10

var cur_beat = 0
var time = 0

var objs = []

var objTypes = {
	"std" : "res://note.tscn"
}

func load_chart(dir):
	$Song.stream = load(chartsPath + dir + "/audio.ogg")
	$Song.play()
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

func _ready():
	get_tree().set_auto_accept_quit(false)
	OS.execute("playerctl", ["pause"])
	load_chart("heracles")
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		OS.execute("playerctl", ["play"])
		get_tree().quit()


func _process(delta):
	time = $Song.get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	#print("Time is: ", time)
	
	var beat = time / SPB
	if floor(beat) > cur_beat:
		cur_beat = floor(beat)
		print(cur_beat)
	
