extends Node2D

var Circle = preload("res://Objects/Circle.tscn")
var Jumper = preload("res://Objects/Jumper.tscn")

var player
var score = 0 setget set_score
var highscore = 0
var new_highscore = false
var level = 0
var bonus = 0 setget set_bonus

func _ready() -> void:
	randomize()
	load_score()
	$HUD.hide()
	
func new_game():
	$Background/ColorRect.set_frame_color(Settings.color_schemes[Settings.tema]["background"])
	$Background/CPUParticles2D.set_color(Settings.color_schemes[Settings.tema]["background_circle"])
	var new_highscore = false
	self.score = 0
	self.bonus = 0
	level = 1
	$HUD.update_score(score, 0)
	$Camera2D.position = $StartingPosition.position			# ubah posisi kamera ke starting pos
	player = Jumper.instance()
	player.position = $StartingPosition.position
	add_child(player)
	player.connect("captured", self, "on_Jumper_captured")
	player.connect("died", self, "on_jumper_died")
	spawn_circle($StartingPosition.position)
	$HUD.show()
	$HUD.show_message("Go!")
	if Settings.enable_music:
		$Music.volume_db = 0
		$Music.play()

# fungsi untuk munculin lingkarang	
func spawn_circle(_position=null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150,150)
		var y = rand_range(-500, -400)
		_position = player.target.position + Vector2(x,y)
	add_child(c)
	c.connect("full_orbit", self, "set_bonus", [1])
	c.init(_position, level)

func on_Jumper_captured(object):
	$Camera2D.position = object.position
	object.blink(player)
	call_deferred("spawn_circle")
	self.score += 1 * bonus
	self.bonus += 1
	if score > 0 and score % Settings.circle_per_level == 0:
		level += 1
		$HUD.show_message("Level %s" % str(level))
	
func set_score(value):
	$HUD.update_score(score, value)
	score = value
	if score > highscore and !new_highscore:
		$HUD.show_message("New Record!")
		new_highscore = true
	
	
func on_jumper_died():
	if score > highscore:
		highscore = score
		save_score()
	get_tree().call_group("circles", "implode")
	$Screens.game_over(score, highscore)
	$HUD.hide()
	if Settings.enable_music:
		fade_music()
		
func load_score():
	var f = File.new()
	if f.file_exists(Settings.score_file):
		f.open(Settings.score_file, File.READ)
		highscore = f.get_var()
		f.close()
	
func save_score():
	var f = File.new()
	f.open(Settings.score_file, File.WRITE)
	f.store_var(highscore)
	f.close()
	
func fade_music():
	$MusicFade.interpolate_property($Music, "volume_db", 0, -50, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$MusicFade.start()
	yield($MusicFade, "tween_all_completed")
	$Music.stop()

func set_bonus(value):
	bonus = value
	$HUD.update_bonus(bonus)
