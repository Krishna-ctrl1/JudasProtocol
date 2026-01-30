extends Node3D

@onready var glitch_mat = $CanvasLayer/ColorRect.material

func _input(event):
	# Using SPACEBAR (ui_accept) because it is reliable
	if event.is_action_pressed("ui_accept"):
		trigger_glitch()

func trigger_glitch():
	# Turn Glitch ON
	glitch_mat.set_shader_parameter("is_active", true)
	
	# Wait 0.2 seconds
	await get_tree().create_timer(0.2).timeout
	
	# Turn Glitch OFF
	glitch_mat.set_shader_parameter("is_active", false)
