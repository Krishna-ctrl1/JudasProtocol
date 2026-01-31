extends Control

# --- NODES ---
@onready var title = $TitleImage
@onready var play_btn = $play
@onready var quit_btn = $quit
@onready var loading_layer = $LoadingLayer
@onready var loading_text = $LoadingLayer/LoadingText

const GAME_SCENE_PATH = "res://dev_gym.tscn" 

# --- CONFIG ---
@export var normal_text_color : Color = Color(0.9, 0.95, 1.0) 
@export var play_hover_color : Color = Color(0.2, 0.6, 1.0) # Supernova Blue
@export var quit_hover_color : Color = Color(1.0, 0.0, 0.6) # Nebula Pink

var glitch_chars = ["★", "☾", "✦", "⚡", "⚠", "0", "1", "X", "∑", "Ω"]

func _ready():
	loading_layer.visible = false 
	loading_layer.modulate.a = 1.0
	
	play_btn.pressed.connect(_on_play_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	setup_themed_button(play_btn, play_hover_color)
	setup_themed_button(quit_btn, quit_hover_color) 
	
	# Start the NEW Shader Glitch loop
	start_shader_glitch()

func _on_play_pressed():
	loading_layer.visible = true
	loading_layer.move_to_front()
	loading_text.text = "" 
	
	var sequence = [
		"INITIALIZING NEURAL LINK...",
		"CONNECTING TO SECTOR 7...",
		"DOWNLOADING SIMULATION DATA...",
		"SYSTEM READY."
	]
	
	var tween = create_tween()
	for line in sequence:
		tween.tween_callback(func(): loading_text.text = "")
		tween.tween_method(func(val): loading_text.text = line.left(val), 0, line.length(), 0.5) 
		tween.tween_interval(0.2)
	
	tween.tween_callback(func():
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
	)

func _on_quit_pressed():
	get_tree().quit()

# --- NEW SHADER GLITCH ---

func start_shader_glitch():
	# We need to access the material we just made
	var mat = title.material as ShaderMaterial
	
	var tween = create_tween().set_loops()
	# Random pauses between glitches
	tween.tween_interval(randf_range(0.5, 3.0)) 
	
	tween.tween_callback(func():
		# 1. Glitch ON (High distortion)
		var glitch = create_tween()
		# Rapidly change values 3 times
		for i in range(3):
			glitch.tween_method(func(v): mat.set_shader_parameter("shake_power", v), 0.0, 0.8, 0.05)
			glitch.tween_method(func(v): mat.set_shader_parameter("color_rate", v), 0.0, 0.5, 0.05)
			glitch.tween_interval(0.02)
			glitch.tween_method(func(v): mat.set_shader_parameter("shake_power", v), 0.8, 0.0, 0.05)
			
		# Ensure it turns OFF completely at the end
		var reset = create_tween()
		reset.tween_method(func(v): mat.set_shader_parameter("shake_power", v), 0.1, 0.0, 0.1)
		reset.tween_method(func(v): mat.set_shader_parameter("color_rate", v), 0.1, 0.0, 0.1)
	)

func setup_themed_button(btn: Button, hover_color: Color):
	var my_original_text = btn.text
	btn.pivot_offset = btn.size / 2
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(btn, "modulate", hover_color, 0.1)
		var scrambler = create_tween().set_loops()
		scrambler.tween_callback(func():
			if btn.is_hovered():
				var txt = ""
				for i in range(my_original_text.length()):
					if randf() > 0.5: txt += glitch_chars.pick_random()
					else: txt += my_original_text[i]
				btn.text = txt
				btn.position += Vector2(randf_range(-2, 2), randf_range(-2, 2))
			else:
				scrambler.kill()
				btn.text = my_original_text
		).set_delay(0.04)
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(btn, "modulate", normal_text_color, 0.2)
		btn.text = my_original_text
	)
