extends Control

var grab_point = null
var local_pos = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				grab_point = position - get_global_mouse_position()
			else:
				grab_point = null
	elif event is InputEventMouseMotion:
		print("motion")
		if %Rotate.button_pressed:
			var rel = get_global_mouse_position() - position
			rotation = atan2(rel.y, rel.x)
			rotation_degrees = round(rotation_degrees / 15) * 15
		elif %Origin.button_pressed:
			print("Note pressed")
			var pos = get_global_mouse_position()
			pos = round(pos / 128.0) * 128
			offset_left = pos.x
			offset_top = pos.y
			offset_right = pos.x
			offset_bottom = pos.y
			print(offset_left, " ", offset_top)
		elif %Note.button_pressed:
			print("Note pressed")
			var pos = get_local_mouse_position()
			pos = round(pos / 128.0) * 128
			%Note.offset_left = pos.x
			%Note.offset_top = pos.y
			%Note.offset_right = pos.x
			%Note.offset_bottom = pos.y
			print(%Note.offset_left, " ", %Note.offset_top)
