extends CanvasLayer

var score = 0

func _ready():
	$Message.rect_pivot_offset = $Message.rect_size / 2

func show_message(text):
	$Message.text = text
	$MessageAnimation.play("show_message")
	
func hide():
	$ScoreBox.hide()
	$BonusContainer.hide()
	
func show():
	$ScoreBox.show()
	$BonusContainer.show()
	
func update_score(score, value):
	$Tween.interpolate_property(self, "score", score, value, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$ScoreAnimation.play("score")
	# $ScoreBox/HBoxContainer/Score.text = str(value)
	
func update_bonus(value):
	$BonusContainer/Bonus.text = str(value) + "x"
	if value > 1:
		$BonusAnimation.play("bonus")


func _on_Tween_tween_step(_object, _key, _elapsed, value) -> void:
	$ScoreBox/HBoxContainer/Score.text = str(int(value))
