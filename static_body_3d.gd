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
	
	# Colision con HeightMapShape3D
	var hmap = HeightMapShape3D.new()
	hmap.map_width = resolution
	hmap.map_depth = resolution
	hmap.map_data = heights
	collision.shape = hmap
	
	# Malla visual
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in resolution:
		for x in resolution:
			var height = noise.get_noise_2d(x, z) * 10.0
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
	mat.albedo_color = Color(0.2, 0.6, 0.2)
	mesh_instance.material_override = mat
