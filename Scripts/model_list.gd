extends Control

@export_group("DataRequest")
@export var mymodel_data_request: HTTPRequest
@export var mymodel_image_request: HTTPRequest
@export var favorite_data_request: HTTPRequest
@export var favorite_image_request: HTTPRequest

@export_group("BaseButton")
@export var mymodel_base_button: Button
@export var favorite_base_button: Button

const MYMODELAPI = "https://hub.vroid.com/api/account/character_models"
const FAVORITEAPI = "https://hub.vroid.com/api/hearts"

var mymodel_button_count: bool = false
var favorite_button_count: bool = false
var button_spacing = 10
var mymodel_count = 0
var favorite_count = 0
var mymodel_image_queue: Array = []
var favorite_image_queue: Array = []
var mymodel_current_request_index: int = 0
var favorite_current_request_index: int = 0
var mymodel_character_id: Array = []
var favorite_character_id: Array = []
var mymodel_character_spec: Array = []
var favorite_character_spec: Array = []

func _ready():
	var header = [
		"X-Api-Version: 11",
		"Authorization: Bearer " + Config.access_token
	]
	
	mymodel_data_request.request(MYMODELAPI, header)
	favorite_data_request.request(FAVORITEAPI, header)

func _on_mymodel_data_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	if response_code == 200:
		var response = json.parse_string(body.get_string_from_utf8())
		mymodel_count = 0
		if "data" in response:
			for model in response["data"]:
				if "portrait_image" in model and "sq150" in model["portrait_image"] and "url" in model["portrait_image"]["sq150"]:
					mymodel_image_queue.append(model["portrait_image"]["sq150"]["url"])
					mymodel_character_id.append(model["id"])
					mymodel_character_spec.append(model["latest_character_model_version"]["spec_version"])
				else:
					print("Image URL not Found for one of the models.")
			_request_next_mymodel_image()
	else:
		print("MymodelError: " + str(response_code))
		
func _on_favorite_data_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	if response_code == 200:
		var response = json.parse_string(body.get_string_from_utf8())
		print(response)
		favorite_count = 0
		if "data" in response:
			for model in response["data"]:
				if "portrait_image" in model and "sq150" in model["portrait_image"] and "url" in model["portrait_image"]["sq150"]:
					favorite_image_queue.append(model["portrait_image"]["sq150"]["url"])
					favorite_character_id.append(model["id"])
					favorite_character_spec.append(model["latest_character_model_version"]["spec_version"])
				else:
					print("Image URL not Found for one of the models.")
			_request_next_favorite_image()
	else:
		print("FavoriteError: " + str(response_code))		

func _request_next_mymodel_image():
	if mymodel_current_request_index < mymodel_image_queue.size():
		var image_url = mymodel_image_queue[mymodel_current_request_index]
		mymodel_image_request.request(image_url)

func _request_next_favorite_image():
	if favorite_current_request_index < favorite_image_queue.size():
		var image_url = favorite_image_queue[favorite_current_request_index]
		favorite_image_request.request(image_url)

func _on_mymodel_image_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if err == OK:
			if !DirAccess.dir_exists_absolute("user://btnicon"):
				DirAccess.make_dir_absolute("user://btnicon")
			img.save_jpg("user://btnicon/icon" + str(mymodel_current_request_index) + ".jpg")
			var btn = Button.new()
			btn.pressed.connect(_on_btn_pressed.bind("mymodel_button" + str(mymodel_current_request_index)))
			await(!FileAccess.file_exists("user://btnicon/icon" + str(mymodel_current_request_index) + ".jpg"))
			var timer = Timer.new()
			add_child(timer)
			timer.start(1)
			await(timer.timeout)
			remove_child(timer)
			var icon = FileAccess.open("user://btnicon/icon" + str(mymodel_current_request_index) + ".jpg", FileAccess.READ)
			var icon_data = icon.get_buffer(icon.get_length())
			icon.close()
			if img.load_jpg_from_buffer(icon_data) == OK:
				var tex = ImageTexture.new()
				btn.icon = tex.create_from_image(img)
			else:
				print("Error!")
				get_tree().quit()
			if mymodel_button_count == false:
				btn.position = Vector2(mymodel_base_button.position.x, mymodel_base_button.position.y)
				mymodel_base_button.visible = false
				mymodel_button_count = true
			else:
				btn.position = Vector2(mymodel_base_button.position.x + mymodel_base_button.size.x + button_spacing, mymodel_base_button.position.y)
			btn.size = mymodel_base_button.size
			var id = mymodel_character_id[mymodel_current_request_index]
			var spec = mymodel_character_spec[mymodel_current_request_index]
			if spec != "1.0":
				btn.set_meta("character_id", id)
				btn.name = "mymodel_button" + str(mymodel_current_request_index)
				add_child(btn)
			mymodel_base_button = btn
		mymodel_current_request_index += 1
		_request_next_mymodel_image()
	else:
		print("Failed to fetch image. Response Code:", str(response_code))

func _on_favorite_image_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if err == OK:
			if !DirAccess.dir_exists_absolute("user://btnicon/favorite"):
				DirAccess.make_dir_absolute("user://btnicon/favorite")
			img.save_jpg("user://btnicon/favorite/icon" + str(favorite_current_request_index) + ".jpg")
			var btn = Button.new()
			btn.pressed.connect(_on_btn_pressed.bind("favorite_button" + str(favorite_current_request_index)))
			await(!FileAccess.file_exists("user://btnicon/favorite/icon" + str(favorite_current_request_index) + ".jpg"))
			var timer = Timer.new()
			add_child(timer)
			timer.start(1)
			await(timer.timeout)
			remove_child(timer)
			var icon = FileAccess.open("user://btnicon/favorite/icon" + str(favorite_current_request_index) + ".jpg", FileAccess.READ)
			var icon_data = icon.get_buffer(icon.get_length())
			icon.close()
			if img.load_jpg_from_buffer(icon_data) == OK:
				var tex = ImageTexture.new()
				btn.icon = tex.create_from_image(img)
			else:
				print("Error!")
				get_tree().quit()
			if favorite_button_count == false:
				btn.position = Vector2(favorite_base_button.position.x, favorite_base_button.position.y)
				favorite_base_button.visible = false
				favorite_button_count = true
			else:
				btn.position = Vector2(favorite_base_button.position.x + favorite_base_button.size.x + button_spacing, favorite_base_button.position.y)
			btn.size = favorite_base_button.size
			var id = favorite_character_id[favorite_current_request_index]
			var spec = favorite_character_spec[favorite_current_request_index]
			if spec != "1.0":
				btn.set_meta("character_id", id)
				btn.name = "favorite_button" + str(favorite_current_request_index)
				add_child(btn)
			favorite_base_button = btn
		favorite_current_request_index += 1
		_request_next_favorite_image()
	else:
		print("Failed to fetch image. Response Code:", str(response_code))

func _on_btn_pressed(pressed_button):
	var btn = get_node("/root/ModelList/" + pressed_button)
	Config.character_id = btn.get_meta("character_id")
	get_tree().change_scene_to_file("res://Scene/model_loader.tscn")
