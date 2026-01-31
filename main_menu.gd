extends Control

# --- NODES ---
@onready var title = $TitleImage
@onready var play_btn = $play
@onready var quit_btn = $quit

# LOADING SCREEN NODES
@onready var loading_layer = $LoadingLayer
@onready var loading_text = $LoadingLayer/LoadingText

const GAME_SCENE_PATH = "res://dev_gym.tscn" 

# --- CONFIG ---
@export var normal_text_color : Color = Color(0.9, 0.95, 1.0) 
@export var play_hover_color : Color = Color(0.2, 0.6, 1.0) # Deep Blue
@export var quit_hover_color : Color = Color(1.0, 0.0, 0.6) # Nebula Pink

var glitch_chars = ["★", "☾", "✦", "⚡", "⚠", "0", "1", "X", "∑", "Ω"]

func _ready():
	# 1. Setup
	play_btn.modulate = normal_text_color
	quit_btn.modulate = normal_text_color
	loading_layer.visible = false # Ensure hidden at start
	
	# 2. Connect
	play_btn.pressed.connect(_on_play_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# 3. Animations
	setup_themed_button(play_btn, play_hover_color)
	setup_themed_button(quit_btn, quit_hover_color) 
	start_title_chaos()

func _on_play_pressed():
	# 1. ACTIVATE LOADING SCREEN
	loading_layer.visible = true
	loading_text.text = "" # Start empty
	
	# 2. TYPEWRITER SEQUENCE
	# We simulate a "System Boot" text sequence
	var sequence = [
		"INITIALIZING NEURAL LINK...",
		"CONNECTING TO SECTOR 7...",
		"DOWNLOADING SIMULATION DATA...",
		"SYSTEM READY."
	]
	
	# Create a timeline for the text
	var tween = create_tween()
	
	for line in sequence:
		# clear text
		tween.tween_callback(func(): loading_text.text = "")
		# type out line fast (0.05s per char)
		tween.tween_method(func(val): loading_text.text = line.left(val), 0, line.length(), 1.0)
		# wait a tiny bit to read it
		tween.tween_interval(0.3)
	
	# 3. LOAD GAME
	tween.tween_callback(func():
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
	)

func _on_quit_pressed():
	get_tree().quit()

# --- ANIMATIONS (Standard Glitch) ---

func start_title_chaos():
	var tween = create_tween().set_loops()
	tween.tween_interval(randf_range(0.5, 2.5)) 
	tween.tween_callback(func():
		var base_pos = title.position
		var shake = create_tween()
		for i in range(12): 
			shake.tween_property(title, "position", base_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.03)
		shake.tween_property(title, "position", base_pos, 0.05)
		
		var color = create_tween()
		color.tween_property(title, "modulate", play_hover_color, 0.05)
		color.tween_property(title, "modulate", quit_hover_color, 0.05)
		color.tween_property(title, "modulate", Color(1,1,1), 0.05) 
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
