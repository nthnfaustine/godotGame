extends Node

signal start_game

var sound_buttons = {true: preload("res://assets/images/buttons/audioOn.png"),
					false: preload("res://assets/images/buttons/audioOff.png")}
var music_buttons = {true: preload("res://assets/images/buttons/musicOn.png"),
					false: preload("res://assets/images/buttons/musicOff.png")}
var theme_buttons = {"NEON_unselected": preload("res://assets/images/neon.png"),
					"NEON": preload("res://assets/images/neon_selected.png"),
					"not_neon_unselected": preload("res://assets/images/non-neon.png"),
					"not_neon": preload("res://assets/images/non-neon_selected.png")}

var current_screen = null

func _ready() -> void:
	register_button()
	change_screen($TitleScreen)

# fungsi buat regist button yang masuk dalam grup "buttons"
func register_button():
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])
		
func _on_button_pressed(button):
	if Settings.enable_sound:
		$Click.play()
	match button.name:
		"Home":
			change_screen($TitleScreen)
		"Play":
			change_screen(null)
			yield(get_tree().create_timer(0.5), "timeout")
			emit_signal("start_game")
		"Setting":
			change_screen($SettingScreen)
		"Sound":
			Settings.enable_sound = !Settings.enable_sound
			button.texture_normal = sound_buttons[Settings.enable_sound]
		"Music":
			Settings.enable_music = !Settings.enable_music
			button.texture_normal = music_buttons[Settings.enable_music]
		"Not_neon":
			Settings.tema = "not_neon"
			button.texture_normal = theme_buttons[Settings.tema]
			$SettingScreen/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Neon.texture_normal = theme_buttons["NEON_unselected"]
		"Neon":
			Settings.tema = "NEON"
			button.texture_normal = theme_buttons[Settings.tema]
			$SettingScreen/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Not_neon.texture_normal = theme_buttons["not_neon_unselected"]


# fungsi untuk ganti screen, kodenya ada di BaseScreen.gd
func change_screen(new_screen):
	if current_screen:
		current_screen.disappear()
		yield(current_screen.tween, "tween_completed")
	current_screen = new_screen
	if new_screen:
		current_screen.appear()
		yield(new_screen.tween, "tween_completed")

func game_over(score, highscore):
	var score_box = $GameoverScreen/MarginContainer/VBoxContainer/Nilai
	score_box.get_node("Score").text = "Score : %s" % score
	score_box.get_node("Best").text = "Best : %s" %highscore 
	change_screen($GameoverScreen)
