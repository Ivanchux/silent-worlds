extends StaticBody3D

var noise = FastNoiseLite.new()
var resolution = 150
var size = 200

func _ready():
	noise.seed = randi()
	noise.frequency = 0.03
	
	var mesh_instance = $MeshInstance3D
	var collision = $CollisionShape3D
	
	# Altura
	var heights = []
	for z in resolution:
		for x in resolution:
			heights.append(noise.get_noise_2d(x, z) * 10.0)
	
	# Colision
	var hmap = HeightMapShape3D.new()
	hmap.map_width = resolution
	hmap.map_depth = resolution
	hmap.map_data = heights
	collision.shape = hmap
	collision.scale = Vector3(float(size)/resolution, 1.0, float(size)/resolution)
	collision.position = Vector3(0, 0, 0)
	
	# Malla visual
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in resolution:
		for x in resolution:
			var height = noise.get_noise_2d(x, z) * 10.0
			var color
			if height > 6.0:
				color = Color(0.9, 0.9, 0.95)
			elif height > 3.0:
				color = Color(0.5, 0.45, 0.4)
			elif height > 0.0:
				color = Color(0.2, 0.55, 0.2)
			else:
				color = Color(0.15, 0.35, 0.6)
			surface.set_color(color)
			surface.set_uv(Vector2(float(x)/resolution, float(z)/resolution))
			surface.add_vertex(Vector3(
				(x - resolution/2.0) * (float(size)/resolution),
				height,
				(z - resolution/2.0) * (float(size)/resolution)
			))
	
	for z in resolution - 1:
		for x in resolution - 1:
			var i = z * resolution + x
			surface.add_index(i)
			surface.add_index(i + 1)
			surface.add_index(i + resolution)
			surface.add_index(i + 1)
			surface.add_index(i + resolution + 1)
			surface.add_index(i + resolution)
	
	surface.generate_normals()
	mesh_instance.mesh = surface.commit()
	
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat
	
	# Estrellas
	var star_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 500.0
	sphere_mesh.height = 1000.0
	sphere_mesh.flip_faces = true
	star_sphere.mesh = sphere_mesh
	var star_shader_mat = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, cull_front;\nvoid fragment() {\nvec2 uv = UV * 200.0;\nvec2 grid = fract(uv);\nvec2 id = floor(uv);\nfloat r = fract(sin(dot(id, vec2(127.1, 311.7))) * 43758.5);\nfloat star = step(0.97, r) * step(0.4, grid.x) * step(0.4, grid.y);\nALBEDO = vec3(star);\nEMISSION = vec3(star) * 2.0;\n}"
	star_shader_mat.shader = shader
	star_sphere.material_override = star_shader_mat
	get_parent().add_child.call_deferred(star_sphere)
	
	# Cielo
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.02, 0.02, 0.08)
	sky_material.sky_horizon_color = Color(0.1, 0.15, 0.3)
	sky_material.ground_horizon_color = Color(0.1, 0.15, 0.3)
	sky_material.sun_angle_max = 30.0
	sky_material.sun_curve = 0.1
	var sky = Sky.new()
	sky.sky_material = sky_material
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.15, 0.3)
	env.fog_density = 0.008
	var world_env = get_parent().get_node("WorldEnvironment")
	world_env.environment = env
