extends DirectionalLight3D
@onready var sun := $"."
@onready var env = $"../WorldEnvironment".environment
@onready var audio := $"../AudioStreamPlayer"

func _ready():
	print("🌍 ENVIRONMENT READY - registering...")
	Items.items["environment"] = self
	print("✅ Environment registered: ", Items.items["environment"])

func dayPosition():
	sun.rotation_degrees = Vector3(-44.4, 56.5, -13.2)
	sun.light_color = Color(0.87, 0.77, 0.70, 1.0)
	changeSky("res://Imports/Skybox/DAYSKY.hdr")
	env.volumetric_fog_density = 0.01
	env.volumetric_fog_albedo = Color(0.86, 0.60, 0.54, 1.00)
	
	
func afternoonPosition():
	sun.rotation_degrees = Vector3(-23.2, -134.1, 123.9)
	sun.light_color = Color(0.895, 0.662, 0.527, 1.0)
	audio.stream = load("res://Audio/bgm/forestAmbience.ogg")
	audio.play()

func cloudyAfternoonPosition():
	sun.rotation_degrees = Vector3(-23.2, -134.1, 123.9)
	sun.light_color = Color(0.623, 0.697, 0.694, 1.0)
	env.volumetric_fog_albedo = Color(0.819, 0.816, 0.824, 1.0)
	sun.shadow_blur = 2
	env.ambient_light_energy = 0.3
	audio.stream = load("res://Audio/bgm/forestAmbience.ogg")
	audio.play()
	
func nightPosition():
	sun.rotation_degrees = Vector3(73.9, 65.3, -8.5)
	sun.light_color = Color(0.534, 0.347, 0.502, 1.0)
	env.volumetric_fog_density = 0.06
	env.volumetric_fog_albedo = Color(0.819, 0.816, 0.824, 1.0)
	changeSky("res://Imports/Skybox/NIGHTSKY.hdr")
	audio.stream = load("res://Audio/bgm/nightAmbience.ogg")
	audio.play()
	
func changeSky(tex: String):
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = load(tex)

	var new_sky = Sky.new()
	new_sky.sky_material = sky_mat
	
	env.sky = new_sky
	
	env.background_mode = Environment.BG_SKY
