extends Control

# --- NODES ---
@onready var background = $Background
@onready var title = $TitleImage
@onready var play_btn = $play
@onready var quit_btn = $quit
@onready var loading_layer = $LoadingLayer
@onready var loading_text = $LoadingLayer/LoadingText

const GAME_SCENE_PATH = "res://dev_gym.tscn" 

# --- COLORS ---
@export var play_hover_color : Color = Color(0.2, 1.0, 1.0) # Electric Cyan
@export var quit_hover_color : Color = Color(1.0, 0.0, 0.3) # Neon Red

var glitch_chars = ["★", "☾", "✦", "⚡", "⚠", "0", "1", "X", "∑", "Ω", "§", "⫷", "⫸"]
var title_final_pos : Vector2
var original_pos : Vector2 

func _ready():
	loading_layer.visible = false
	original_pos = position 
	
	# 1. SETUP POSITIONS
	title_final_pos = title.position
	title.position.y = get_viewport_rect().size.y / 2 - (title.size.y / 2)
	title.position.x = get_viewport_rect().size.x / 2 - (title.size.x / 2)
	
	# 2. THE VOID (Hide everything)
	background.modulate = Color(0, 0, 0) 
	title.modulate.a = 0.0 
	play_btn.modulate.a = 0.0
	quit_btn.modulate.a = 0.0
	
	# 3. SETUP BUTTONS
	play_btn.pressed.connect(_on_play_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	setup_themed_button(play_btn, play_hover_color)
	setup_themed_button(quit_btn, quit_hover_color) 
	
	# 4. START
	start_cinematic_intro()

func start_cinematic_intro():
	var tween = create_tween()
	
	# PHASE 1: GHOST TEXT
	tween.tween_property(title, "modulate:a", 1.0, 2.0)
	tween.tween_interval(0.5) 
	
	# PHASE 2: THE ASCENSION
	tween.tween_property(title, "position", title_final_pos, 1.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	# PHASE 3: THE DROP
	tween.tween_callback(trigger_system_breach)

func trigger_system_breach():
	# --- 1. SCREEN SHAKE ---
	var shake = create_tween()
	for i in range(10): 
		shake.tween_property(self, "position", original_pos + Vector2(randf_range(-10,10), randf_range(-10,10)), 0.02)
	shake.tween_property(self, "position", original_pos, 0.05) 
	
	# --- 2. VIOLENT TITLE GLITCH ---
	var mat = title.material as ShaderMaterial
	if mat:
		var glitch = create_tween()
		glitch.tween_callback(func(): 
			mat.set_shader_parameter("shake_power", 1.0)
			mat.set_shader_parameter("color_rate", 1.0)
		)
		glitch.tween_method(func(v): mat.set_shader_parameter("shake_power", v), 1.0, 0.0, 0.5)
		glitch.tween_method(func(v): mat.set_shader_parameter("color_rate", v), 1.0, 0.0, 0.5)

	# --- 3. ROBOT STROBE ---
	var bg_tween = create_tween()
	bg_tween.tween_property(background, "modulate", Color(2, 0, 0), 0.05) # Flash Red
	bg_tween.tween_property(background, "modulate", Color(0, 2, 2), 0.05) # Flash Cyan
	bg_tween.tween_property(background, "modulate", Color(2, 2, 2), 0.1)  # Flash White
	bg_tween.tween_property(background, "modulate", Color(1, 1, 1), 0.2)  # Normal
	
	# --- 4. BUTTONS DECRYPT ---
	play_btn.modulate.a = 1.0
	quit_btn.modulate.a = 1.0
	decrypt_text(play_btn, "INITIATE PROTOCOL")
	decrypt_text(quit_btn, "ABORT")
	
	# --- 5. START CONTINUOUS GLITCH LOOP ---
	var loop = create_tween()
	loop.tween_interval(1.0) # Wait for dust to settle
	loop.tween_callback(start_shader_loop)

func decrypt_text(btn: Button, final_text: String):
	var tween = create_tween()
	var steps = 15 
	for i in range(steps):
		tween.tween_callback(func():
			var txt = ""
			for c in range(final_text.length()):
				txt += glitch_chars.pick_random()
			btn.text = txt
			btn.modulate = Color(randf(), randf(), randf()) 
		)
		tween.tween_interval(0.03) 
	tween.tween_callback(func(): 
		btn.text = final_text
		btn.modulate = Color(1,1,1)
	)

func start_shader_loop():
	# --- CONSTANT 0.5s GLITCH LOOP ---
	var mat = title.material as ShaderMaterial
	if not mat: return 
	
	var tween = create_tween().set_loops()
	
	# 1. Wait exactly 0.5 seconds
	tween.tween_interval(0.5) 
	
	# 2. Perform sharp glitch twitch
	tween.tween_callback(func():
		var glitch = create_tween()
		# Quick twitch (0.4 shake power is visible but sharp)
		glitch.tween_method(func(v): mat.set_shader_parameter("shake_power", v), 0.0, 0.4, 0.05)
		glitch.tween_method(func(v): mat.set_shader_parameter("color_rate", v), 0.0, 0.5, 0.05)
		glitch.tween_interval(0.05) # Hold for a tiny moment
		# Snap back to 0
		glitch.tween_method(func(v): mat.set_shader_parameter("shake_power", v), 0.4, 0.0, 0.05)
	)

func _on_play_pressed():
	loading_layer.visible = true
	loading_layer.move_to_front()
	loading_text.text = "" 
	
	var sequence = ["INITIALIZING NEURAL LINK...", "CONNECTING TO SECTOR 7...", "SYSTEM READY."]
	var tween = create_tween()
	for line in sequence:
		tween.tween_callback(func(): loading_text.text = "")
		tween.tween_method(func(val): loading_text.text = line.left(val), 0, line.length(), 0.5) 
		tween.tween_interval(0.2)
	tween.tween_callback(func(): get_tree().change_scene_to_file(GAME_SCENE_PATH))

func _on_quit_pressed():
	get_tree().quit()

# --- BUTTON INTERACTION ---
func setup_themed_button(btn: Button, hover_color: Color):
	var my_original_text = btn.text
	btn.pivot_offset = btn.size / 2
	btn.mouse_entered.connect(func():
		if btn.modulate.a < 0.9: return
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
			else: scrambler.kill(); btn.text = my_original_text
		).set_delay(0.04)
	)
	btn.mouse_exited.connect(func():
		if btn.modulate.a < 0.9: return
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(btn, "modulate", Color(1,1,1), 0.2)
		btn.text = my_original_text
	)
