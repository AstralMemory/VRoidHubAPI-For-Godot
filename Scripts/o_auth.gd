extends Control

@onready var http_request = $HTTPRequest

const TOKEN_ENDPOINT = "https://hub.vroid.com/oauth/token"
const CLIENT_ID = "xYCidTjkM6Xv-4urNAyeE_7AsKrZAf0JQCHI0Wx6XcM"
const CLIENT_SECRET = "oZgbJC4rwcURcVQvEAso7LgqWJRJxLCJiFRlXUZo4mY"
const REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
const GRANT_TYPE = "authorization_code"

var auth: bool = false

func _ready():
	if OS.get_name() == "ANDROID":
		OS.request_permissions()
		$AuthPanel/Paste.visible = true
	if FileAccess.file_exists("user://model.vrm"):
		DirAccess.remove_absolute("user://model.vrm")
#		get_tree().change_scene_to_file("res://Scene/model_loader.tscn")

func _process(delta):
	var viewport_size = get_viewport_rect().size
	$SignIn.global_position =  viewport_size / 2 - $SignIn.size / 1
	$AuthPanel.global_position = viewport_size / 2 - $AuthPanel.size / 2

func _request_access_token(auth_code):
	var post_data = "client_id=" + CLIENT_ID + "&"
	post_data += "client_secret=" + CLIENT_SECRET + "&"
	post_data += "redirect_uri=" + REDIRECT_URI + "&"
	post_data += "grant_type=" + GRANT_TYPE + "&"
	post_data += "code=" + auth_code
	
	http_request.request(TOKEN_ENDPOINT, ["X-Api-Version: 11"], HTTPClient.METHOD_POST, post_data)
	


func _on_sign_in_pressed():
	OS.shell_open("https://hub.vroid.com/oauth/authorize?response_type=code&client_id=xYCidTjkM6Xv-4urNAyeE_7AsKrZAf0JQCHI0Wx6XcM&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=default")
	$AuthPanel.visible = true
	$SignIn.visible = false
	

func _on_auth_button_pressed():
	var auth_code = $AuthPanel/InputCode.text
	_request_access_token(auth_code)
	
func _on_http_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	if response_code == 200:
		var response = json.parse_string(body.get_string_from_utf8())
		var access_token = response.access_token
		Config.access_token = access_token
		$AuthPanel.visible = false
		auth = true
		$AcceptDialog.title = "Success!"
		$AcceptDialog.dialog_text = "Authorized!"
		$AcceptDialog.popup_centered()
	else:
		$AcceptDialog.title = "Not Authorized!"
		$AcceptDialog.dialog_text = "Authorize Failed.\nError: " + str(response_code)
		$AcceptDialog.popup_centered()
		

func _on_accept_dialog_confirmed():
	if auth:
		get_tree().change_scene_to_file("res://Scene/model_list.tscn")


func _on_paste_pressed():
	var clipboard_plugin = Engine.get_singleton("ClipBoardPlugin")
	var text = clipboard_plugin.getClipboardText()
	if text != null:
		$AuthPanel/InputCode.text = text
