extends Area2D

signal captured						# inisiasi sinyal captured
signal died

onready var trail = $Trail/Points
var velocity = Vector2(100,0)
var jump_speed = 1000				# kecepatan ngeluncur
var target = null					# target itu si circlenya
var trail_length = 25

func _ready():
	$Sprite.material.set_shader_param("color", Settings.color_schemes[Settings.tema]["player_body"])
	var trail_color = Settings.color_schemes[Settings.tema]["player_trail"]
	trail.gradient.set_color(1, trail_color)
	trail.gradient.set_color(0, trail_color)

# func init():
	# $Sprite.material.set_shader_param("color", Settings.color_schemes[Settings.tema]["player_body"])
	# var trail_color = Settings.color_schemes[Settings.tema]["player_trail"]
	# trail.gradient.set_color(1, trail_color)
	# trail.gradient.set_color(0, trail_color)

# fungsi untuk nerima touch input
func _unhandled_input(event: InputEvent) -> void:
	if target and event is InputEventScreenTouch and event.pressed:
		jump()

# fungsi buat loncat, dipanggil di _unhandled_input(). target di hilangkan dan velocity disesuaikan dgn speed
func jump():
	target.implode()
	target = null
	velocity = transform.x * jump_speed
	if Settings.enable_sound:
		$Jump.play()

# fungsi saat ada yang masuk ke node jumper (yang masuk adalah area)
func _on_Jumper_area_entered(area: Area2D) -> void:
	target = area					# target di set sebagai area (circle)
	velocity = Vector2.ZERO			# kecepatan dari jumper di set 0 agar diam
	emit_signal("captured",area)	# mengirimkan sinyal "captured" dengan param area
	if Settings.enable_sound:
		$Capture.play()
		
# ini fungsi yang jalan secara loop selama game berjalan. Semua berjalan disini
func _physics_process(delta: float) -> void:
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position)
	if target:
		transform = target.orbit_position.global_transform   # buat letakin jumper di orbit circle
	else:
		position += velocity * delta						# apabila tidak ada ditarget, dia loncat

func die():
	target = null
	queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	emit_signal("died")
	if !target:
		die()
