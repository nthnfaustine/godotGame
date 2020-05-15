extends Node

var score_file = "user://highscore.save"
var enable_sound = true
var enable_music = true
var tema = "NEON"

var circle_per_level = 5

var color_schemes = {
	"NEON": {
		'background': Color8(0, 0, 0),
		'background_circle': Color8(255,255,255),
		'player_body': Color8(255, 0, 187),
		'player_trail': Color8(255, 148, 0),
		'circle_fill': Color8(255, 148, 0),
		'circle_static': Color8(170, 255, 0),
		'circle_limited': Color8(204, 0, 255),
		'speed_param': 4.138,
		'radius_param': 0.356,
		'width_param': 0.218
	},
	"not_neon": {
		'background': Color8(0, 48, 73),
		'background_circle': Color8(214, 40, 40),
		'player_body': Color8(233, 217, 143),
		'player_trail': Color8(252, 191, 73),
		'circle_fill': Color8(247, 127, 0),
		'circle_static': Color8(214, 40, 40),
		'circle_limited': Color8(214, 40, 40),
		'speed_param': 0,
		'radius_param': 0,
		'width_param': 0
	}
}

var theme = color_schemes[tema]

# fungsi dari weighted random numbers. 
static func rand_weighted(weights):
	var sum = 0
	for weight in weights:
		sum += weight
	var num = rand_range(0, sum)
	for i in weights.size():
		if num < weights[i]:
			return i
		num -= weights[i]
