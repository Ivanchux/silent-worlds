extends RigidBody3D

const THRUST = 20.0
const ROTATION_SPEED = 1.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity_scale = 0
	linear_damp = 1.0
	angular_damp = 2.0
	
	# Material nave
	var mesh = $MeshInstance3D
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.6, 0.7)
	mat.metallic = 0.8
	mesh.material_override = mat
	
	# Luz
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	get_parent().add_child.call_deferred(light)
	
	# Fondo
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.0, 0.0, 0.05)
	var world_env = get_parent().get_node("WorldEnvironment")
	world_env.environment = env

func _physics_process(delta):
	if Input.is_key_pressed(KEY_W):
		apply_central_force(-transform.basis.z * THRUST)
	if Input.is_key_pressed(KEY_S):
		apply_central_force(transform.basis.z * THRUST)
	if Input.is_key_pressed(KEY_A):
		apply_torque(Vector3(0, ROTATION_SPEED, 0))
	if Input.is_key_pressed(KEY_D):
		apply_torque(Vector3(0, -ROTATION_SPEED, 0))
	if Input.is_key_pressed(KEY_SPACE):
		apply_central_force(transform.basis.y * THRUST)
	if Input.is_key_pressed(KEY_SHIFT):
		apply_central_force(-transform.basis.y * THRUST)
		
		# Transicion al planeta
	if global_position.y < -50:
		get_tree().change_scene_to_file("res://main.tscn")
		
		# Transicion al espacio
	if global_position.y > 30:
		get_tree().change_scene_to_file("res://space.tscn")
	
	# Camara sigue la nave desde fuera
	var cam = get_parent().get_node("Camera3D")
	var target_pos = global_position + Vector3(0, 5, 10)
	cam.global_position = cam.global_position.lerp(target_pos, delta * 5)
	cam.look_at(global_position, Vector3.UP)
