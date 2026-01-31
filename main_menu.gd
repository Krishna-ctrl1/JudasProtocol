extends Control

# --- NODES ---
@onready var title = $TitleImage
@onready var play_btn = $play
@onready var quit_btn = $quit

const GAME_SCENE_PATH = "res://dev_gym.tscn" 

# --- SPACE THEME COLORS ---
# Default Text Color (Starlight White)
@export var normal_text_color : Color = Color(0.9, 0.95, 1.0) 

# INITIATE: "Supernova Blue" (Deep, electric space blue)
@export var play_hover_color : Color = Color(0.2, 0.6, 1.0) 

# ABORT: "Nebula Pink" (Deep cosmic magenta)
@export var quit_hover_color : Color = Color(1.0, 0.0, 0.6)

# Glitch Characters (Added Stars and Moons for Space vibe)
var glitch_chars = ["★", "☾", "✦", "☄", "⚡", "⚠", "0", "1", "X", "∑", "Ω"]

func _ready():
	# 1. Apply Initial Colors
	play_btn.modulate = normal_text_color
	quit_btn.modulate = normal_text_color
	
	# 2. Connect Actions
	play_btn.pressed.connect(_on_play_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# 3. Setup Animations
	setup_themed_button(play_btn, play_hover_color)
	setup_themed_button(quit_btn, quit_hover_color) 
	
	# 4. Start Title Chaos
	start_title_chaos()

func _on_play_pressed():
	# --- THE SPACE STORM LIGHTNING ---
	var flash = ColorRect.new()
	# Lightning matches the "Supernova Blue" of the button
	flash.color = Color(0.6, 0.9, 1.0) 
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	flash.modulate.a = 0.0 
	
	# Violent Strobe Animation
	var tween = create_tween()
	
	# Strike 1 (Massive Flash)
	tween.tween_property(flash, "modulate:a", 1.0, 0.05) 
	tween.tween_property(flash, "modulate:a", 0.0, 0.05) 
	
	# Strike 2 (Quick Flicker)
	tween.tween_interval(0.05)
	tween.tween_property(flash, "modulate:a", 0.6, 0.03)
	tween.tween_property(flash, "modulate:a", 0.0, 0.03)
	
	# Strike 3 (Final Explosion into Game)
	tween.tween_interval(0.1)
	tween.tween_property(flash, "modulate:a", 1.0, 0.1) # Fade to Full Light
	tween.tween_callback(func():
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
	)

func _on_quit_pressed():
	get_tree().quit()

# --- ANIMATIONS ---

func start_title_chaos():
	var tween = create_tween().set_loops()
	tween.tween_interval(randf_range(0.5, 2.5)) 
	tween.tween_callback(func():
		var base_pos = title.position
		
		# Shake
		var shake = create_tween()
		for i in range(12): 
			shake.tween_property(title, "position", base_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.03)
		shake.tween_property(title, "position", base_pos, 0.05)
		
		# Color Strobe (Flashes between Blue and Pink)
		var color = create_tween()
		color.tween_property(title, "modulate", play_hover_color, 0.05) # Blue
		color.tween_property(title, "modulate", quit_hover_color, 0.05) # Pink
		color.tween_property(title, "modulate", Color(1,1,1), 0.05) 
	)

func setup_themed_button(btn: Button, hover_color: Color):
	var my_original_text = btn.text
	btn.pivot_offset = btn.size / 2
	
	# HOVER
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		# Scale Up + Apply Space Color
		tween.tween_property(btn, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(btn, "modulate", hover_color, 0.1)
		
		# Space Scramble
		var scrambler = create_tween().set_loops()
		scrambler.tween_callback(func():
			if btn.is_hovered():
				var txt = ""
				for i in range(my_original_text.length()):
					if randf() > 0.5: 
						txt += glitch_chars.pick_random()
					else:
						txt += my_original_text[i]
				btn.text = txt
				btn.position += Vector2(randf_range(-2, 2), randf_range(-2, 2))
			else:
				scrambler.kill()
				btn.text = my_original_text
		).set_delay(0.04)
	)
	
	# EXIT
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(btn, "modulate", normal_text_color, 0.2)
		btn.text = my_original_text
	)
