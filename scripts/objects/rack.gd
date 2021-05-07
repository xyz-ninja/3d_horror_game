extends Spatial

export var is_open_by_default = false

var is_opened = false

func _ready():
	if is_open_by_default:
		switch_rack_door()

func switch_rack_door():
	if !$anim.is_playing():
		if is_opened:
			$anim.play_backwards("open")
			is_opened = false
		else:
			$anim.play("open")
			is_opened = true
