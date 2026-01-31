extends Node3D

# --- NODES ---
@onready var glitch_mat = $CanvasLayer/ColorRect.material
@onready var label = $Label3D
@onready var env = $WorldEnvironment.environment 
@onready var enemy_robot = $Robo 

# --- PLAYER PARTS (CONFIRMED FROM IMAGE) ---
@onready var player_root = $Player
@onready var player_human = $Player/PlayerHuman

# This matches your screenshot exactly:
@onready var player_robot_skin = $Player/PlayerModel 

var glitch_triggered = false

func _ready():
	# 1. SETUP WORLD
	Engine.time_scale = 1.0
	if env: 
		env.volumetric_fog_density = 0.0
		env.volumetric_fog_albedo = Color(1, 1, 1)
	
	if label: label.visible = false
	if glitch_mat: glitch_mat.set_shader_parameter("is_active", false)
	
	# INITIAL STATE: Human Hidden, Robot Visible
	if is_instance_valid(player_human): player_human.visible = false
	if is_instance_valid(player_robot_skin): player_robot_skin.visible = true

	# 2. CONNECT TO ROBOT
	if is_instance_valid(enemy_robot):
		if not enemy_robot.is_connected("exploded", _on_robot_death):
			enemy_robot.connect("exploded", _on_robot_death)

func _on_robot_death():
	if not glitch_triggered:
		start_cinematic_glitch()

func start_cinematic_glitch():
	glitch_triggered = true
	print("GLITCH STARTED: ROBOT <-> HUMAN SWAP")
	
	# === PHASE 1: FOG & SHAKE ===
	if glitch_mat:
		glitch_mat.set_shader_parameter("is_active", true)
		glitch_mat.set_shader_parameter("shake_power", 0.03)
	
	if env:
		var fog_tween = create_tween()
		fog_tween.tween_property(env, "volumetric_fog_density", 0.05, 1.0)
	
	# === PHASE 2: RED TEXT ===
	if label:
		label.text = "FALSE REALITY"
		label.modulate = Color(1, 0, 0) # Red
		label.visible = true
		label.no_depth_test = true 

	# === PHASE 3: THE SWAP (5 Seconds) ===
	var is_human_turn = false
	
	# 50 loops * 0.1s = 5.0 Seconds
	var flicker = create_tween()
	flicker.set_loops(50) 
	flicker.tween_callback(func(): 
		is_human_turn = not is_human_turn # Flip the switch
		
		# LOGIC: 
		# If Human is ON, Robot is OFF.
		# If Human is OFF, Robot is ON.
		if is_instance_valid(player_human):
			player_human.visible = is_human_turn
			
		if is_instance_valid(player_robot_skin):
			player_robot_skin.visible = not is_human_turn
	)
	flicker.tween_interval(0.1) 
	
	# === PHASE 4: CLEANUP (Back to Normal) ===
	flicker.finished.connect(func():
		print("GLITCH ENDED")
		
		# 1. Stop Shader
		if glitch_mat: glitch_mat.set_shader_parameter("is_active", false)
		
		# 2. Force Final State: Robot Visible, Human Hidden
		if is_instance_valid(player_human): player_human.visible = false 
		if is_instance_valid(player_robot_skin): player_robot_skin.visible = true
			
		# 3. Change Text
		if label:
			label.text = "FIND THE MASK"
			label.modulate = Color(1, 1, 0) # Yellow
	)
