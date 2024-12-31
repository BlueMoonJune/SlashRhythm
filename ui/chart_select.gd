extends Control

var targ : float = 0

const CHART_DIR = "res://charts/"
const SONG_LIST_ENTRY = preload("res://ui/SongListEntry.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for dir in DirAccess.open(CHART_DIR).get_directories():
		var entry = SONG_LIST_ENTRY.instantiate()
		entry.chart_dir = CHART_DIR + dir
		$SongList.add_child(entry)

func clamp_mid(v, min, max):
	if min > max: return (min + max) / 2
	return clamp(v, min, max)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	targ = clamp_mid(targ, -$SongList.size.y + size.y, 0)
	$SongList.offset_top = lerp(targ, $SongList.offset_top, 0.1 ** delta)
	$SongList.offset_left = -$SongList.factor * $SongList.offset_top
	$SongList.offset_right = $SongList.offset_left
	
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			targ += 100
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			targ -= 100
