extends StaticBody3D

var noise = FastNoiseLite.new()
var resolution = 100
var size = 100

func _ready():
	noise.seed = randi()
	noise.frequency = 0.03
	
	var mesh_instance = $MeshInstance3D
	var collision = $CollisionShape3D
	
	# Generar datos de altura
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
	
	# Malla visual con color por altura
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in resolution:
		for x in resolution:
			var height = noise.get_noise_2d(x, z) * 10.0
			
			# Color segun altura
			var color
			if height > 6.0:
				color = Color(0.9, 0.9, 0.95) # nieve
			elif height > 3.0:
				color = Color(0.5, 0.45, 0.4) # roca
			elif height > 0.0:
				color = Color(0.2, 0.55, 0.2) # hierba
			else:
				color = Color(0.15, 0.35, 0.6) # agua
			
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
	
	# Material que usa el color de vertices
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat
	
	# Cielo
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.05, 0.05, 0.2)
	sky_material.sky_horizon_color = Color(0.3, 0.4, 0.6)
	sky_material.ground_horizon_color = Color(0.3, 0.4, 0.6)
	
	var sky = Sky.new()
	sky.sky_material = sky_material
	
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	
	var world_env = get_parent().get_node("WorldEnvironment")
	world_env.environment = env
