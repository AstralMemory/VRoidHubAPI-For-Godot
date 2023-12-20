extends Node3D

@onready var model_request = $ModelRequest
@onready var license_request = $LicenseRequest
const gltf_document_extension_class = preload("res://addons/vrm/vrm_extension.gd")
const SAVE_DEBUG_GLTFSTATE_RES: bool = false
@export var ModelLight: bool = true

const API_ENDPOINT = "https://hub.vroid.com/api/download_licenses"

var header = [
	"X-Api-Version: 11",
	"Authorization: Bearer " + Config.access_token,
	"Content-Type: application/x-www-form-urlencoded"
	#"Content-Type': 'application/json"
]


func _ready():
	if Config.character_id != "":
		modelload()
	else:
		if FileAccess.file_exists("user://model.vrm"):
			load_model()
#		print("Load Error!")
	
	if ModelLight:
		$DirectionalLight3D.visible = true
	else:
		$DirectionalLight3D.visible = false
	

func modelload():
	var chara_post: String = "character_model_id=" + Config.character_id
	license_request.request(API_ENDPOINT, header, HTTPClient.METHOD_POST, chara_post)

func _on_license_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	if response_code == 200:
		var response = json.parse_string(body.get_string_from_utf8())
		var download_license_id = response["data"]["id"]
		model_request.set_download_file("user://model.vrm")
		model_request.request(API_ENDPOINT + "/" + str(download_license_id) + "/download", header, HTTPClient.METHOD_GET)
	else:
		print("Failed Get License! Response Code:", str(response_code))

func _on_model_request_request_completed(result, response_code, headers, body):
	if response_code == 302:
		var url_pattern = RegEx.new()
		url_pattern.compile('<a href="(.+?)">')
		url_pattern.search(body)
		
		var redirect_url = url_pattern.get_string(1)
		
		if redirect_url:
			model_request.request(redirect_url)
	elif response_code == 200:
		load_model()
	else:
		print("Failed to download file. Response Code:", str(response_code), body)
		
func load_model():
	var path = "user://model.vrm"
	var flags = 1
	var gltf: GLTFDocument = GLTFDocument.new()
	flags |= EditorSceneFormatImporter.IMPORT_USE_NAMED_SKIN_BINDS
	var vrm_extension: GLTFDocumentExtension = gltf_document_extension_class.new()
	gltf.register_gltf_document_extension(vrm_extension, true)
	var state: GLTFState = GLTFState.new()
	# HANDLE_BINARY_EMBED_AS_BASISU crashes on some files in 4.0 and 4.1
	state.handle_binary_image = GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED
	var err = gltf.append_from_file(path, state, flags)
	if err != OK:
		gltf.unregister_gltf_document_extension(vrm_extension)
		return null
	var generated_scene = gltf.generate_scene(state)
	if SAVE_DEBUG_GLTFSTATE_RES and path != "":
		if !ResourceLoader.exists(path + ".res"):
			state.take_over_path(path + ".res")
			ResourceSaver.save(state, path + ".res")
	gltf.unregister_gltf_document_extension(vrm_extension)
	generated_scene.name = "Model"
	add_child(generated_scene)
		
	var animlib = load("res://Locomotion-Library.res")
	$Model/AnimationPlayer.add_animation_library("Locomotion-Library", animlib)
	animlib = load("res://Default.res")
	$Model/AnimationPlayer.add_animation_library("Default", animlib)

	


func _on_walk_pressed():
	$Model/AnimationPlayer.play("Locomotion-Library/walk")

func _on_run_pressed():
	$Model/AnimationPlayer.play("Locomotion-Library/run")

func _on_kick_pressed():
	$Model/AnimationPlayer.play("Locomotion-Library/kick1")

func _on_default_pressed():
	$Model/AnimationPlayer.play("Default/Pose")
