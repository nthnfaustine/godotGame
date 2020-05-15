extends Area2D

signal full_orbit

onready var orbit_position = get_node("Pivot/OrbitPosition")
onready var anim_player = $AnimationPlayer
onready var move_tween = $MoveTween

enum MODES {STATIC, LIMITED}

export var radius = 100		# ukuran dari circle
var rotation_speed = PI
var mode = MODES.STATIC
var move_range = 0
var move_speed = 10.0
var num_orbits = 3 
var current_orbits = 0
var orbit_start = null		# posisi awal orbit
var jumper = null
var level_cap = 5

# fungsi untuk inisiasi circle (jalan saat circle dibentuk)
func init(_position, level=1):
	set_shader_param(Settings.color_schemes[Settings.tema]["speed_param"],Settings.color_schemes[Settings.tema]["radius_param"],Settings.color_schemes[Settings.tema]["width_param"])
	var _mode = Settings.rand_weighted([10, level-1])
	set_mode(_mode)
	set_speed(level)
	position = _position
	var move_chance = clamp(level-10, 0, 3) / 10.0
	if randf() < move_chance:
		move_range = max(25, 100 * rand_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
		move_speed = max(2.5 - ceil(level/5) * 0.25, 0.75)
	var small_chance = min(0.9, max(0, (level-10) / 20.0))
	if randf() < small_chance:
		radius = max(50, radius - level * rand_range(0.75, 1.25))
	$Sprite.material = $Sprite.material.duplicate()
	$Sprite2.material = $Sprite.material
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape.radius = radius
	var img_size = $Sprite.texture.get_size().x / 2
	$Sprite.scale = Vector2(1,1) * radius / img_size
	orbit_position.position.x = radius + 25
	rotation_speed *= pow(-1, randi() % 2)			# ini buat random arah dari circle (cw/ccw)
	set_tween()
	
func set_mode(_mode):
	mode = _mode
	var color
	match mode:
		MODES.STATIC:
			$Label.hide()
			color = Settings.theme["circle_static"]
		MODES.LIMITED:
			$Label.text = str(num_orbits)
			$Label.show()
			color = Settings.theme["circle_limited"]
	$Sprite.material.set_shader_param("color", color)

# fungsi yang loop saat game dijalankan
func _process(delta: float) -> void:
	$Pivot.rotation += rotation_speed * delta	# untuk merubah orbit dari circle (biar muter)
	if jumper:
		check_orbit()
		update()

# fungsi untuk countdown orbit dan gambar lingkaran dalam
func check_orbit():
	if abs($Pivot.rotation - orbit_start) > 2 * PI:
		current_orbits += 1
		emit_signal("full_orbit")
		if mode == MODES.LIMITED:
			if Settings.enable_sound:
				$Beep.play()
			$Label.text = str(num_orbits - current_orbits)
			if current_orbits >= num_orbits:
				jumper.die()
				jumper = null
				implode()
		orbit_start = $Pivot.rotation

# fungsi saat circle mati
func implode():
	jumper = null
	anim_player.play("implode")
	yield(anim_player,"animation_finished")
	queue_free()

# fungsi saat jumper masuk ke circle
func blink(target):
	current_orbits = 0
	jumper = target 
	anim_player.play("blink")
	get_node("Pivot").rotation = (jumper.position - position).angle()
	orbit_start = $Pivot.rotation

# fungsi buat gambar lingkaran dalem
func _draw() -> void:
	if mode != MODES.LIMITED:
		return
	if jumper:
		var r = ((radius - 50) / num_orbits) * (1 + current_orbits)
		draw_circle_arc_poly(Vector2.ZERO, r + 10, orbit_start + PI/2, $Pivot.rotation + PI/2, Settings.theme["circle_fill"])
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI/2
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

# fungsi untuk ngebuat lingkarannya bergerak
func set_tween(_object=null, _key=null):
	if move_range==0:
		return
	move_range *= -1
	move_tween.interpolate_property(self, "position:x", position.x, position.x+move_range, move_speed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	move_tween.start()
	
func set_speed(_level):
	var lvl = _level
	if lvl % level_cap == 0:
		rotation_speed *= 1.5
		move_speed *= 1.5
	
func set_shader_param(_speed, _radius, _width):
	var spd = _speed
	var rad = _radius
	var wd = _width
	$Sprite.get_material().set_shader_param("speed", spd)
	$Sprite.get_material().set_shader_param("radius", rad)
	$Sprite.get_material().set_shader_param("width", wd)
