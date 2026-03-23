extends CharacterBody3D

const SPEED = 6.0
const JUMP_VELOCITY = 5.0
const JETPACK_FORCE = 8.0
const JETPACK_MAX = 3.0
const MOUSE_SENSITIVITY = 0.003

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jetpack_fuel = JETPACK_MAX
var using_jetpack = false
var is_crouching = false
var is_prone = false
var fading = false
var fade_alpha = 0.0
var fade_target_scene = ""

@onready var camera = $Camera3D
@onready var jetpack_bar = $"../CanvasLayer/Control/ProgressBar"
@onready var fade_rect = $"../CanvasLayer/Control2/ColorRect"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fade_rect.modulate.a = 0.0
	
	var bar = $"../CanvasLayer/Control/ProgressBar"
	var label = $"../CanvasLayer/Control/Label"
	
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0, 0.1, 0.05)
	style_bg.border_color = Color(0, 1, 0.5)
	style_bg.set_border_width_all(1)
	
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = Color(0, 1, 0.5)
	
	bar.add_theme_stylebox_override("background", style_bg)
	bar.add_theme_stylebox_override("fill", style_fill)
	label.add_theme_color_override("font_color", Color(0, 1, 0.5))

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			if is_crouching:
				is_crouching = false
				camera.position.y = 1.0
			else:
				is_crouching = true
				is_prone = false
				camera.position.y = 0.5
		if event.keycode == KEY_Z:
			if is_prone:
				is_prone = false
				camera.position.y = 1.0
			else:
				is_prone = true
				is_crouching = false
				camera.position.y = 0.1
		if event.keycode == KEY_T:
			start_fade("res://space.tscn")

func start_fade(scene_path):
	fading = true
	fade_target_scene = scene_path

func _process(delta):
	if fading:
		fade_alpha += delta * 2.0
		fade_rect.modulate.a = fade_alpha
		if fade_alpha >= 1.0:
			get_tree().change_scene_to_file(fade_target_scene)

func _physics_process(delta):
	if is_on_floor():
		jetpack_fuel = min(jetpack_fuel + delta * 1.5, JETPACK_MAX)
		if Input.is_key_pressed(KEY_SPACE):
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= gravity * delta
		if Input.is_key_pressed(KEY_SPACE) and jetpack_fuel > 0:
			velocity.y += JETPACK_FORCE * delta
			jetpack_fuel -= delta
			jetpack_fuel = max(jetpack_fuel, 0)

	var current_speed = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPEED * 2.2
	elif is_prone:
		current_speed = SPEED * 0.2
	elif is_crouching:
		current_speed = SPEED * 0.4

	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	jetpack_bar.value = jetpack_fuel
	move_and_slide()
