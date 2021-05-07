extends Camera

var shake_timer = TIME.create_new_timer("cam_shake_timer", 0.1)

var shake_range
var shake_speed
var shake_lock_x
var shake_lock_y

var is_shaking = false

var init_translation

var fov_init
var fov_absolute_strange = 25
var fov_very_strange = 35
var fov_strange = 50
var fov_wide = 125
var fov_very_wide = 170

var far_init = 215
var far_close = 30

func _ready():
	init_translation = get_translation()
	
	fov_init = self.fov

	set_process(true)

var gain_val = 0
func _process(delta):
	if is_shaking:
		gain_val += shake_speed * delta

		var cur_translation = Vector3()
		if !shake_lock_x:
			cur_translation.x = init_translation.x + shake_range * cos(gain_val)
		if !shake_lock_y:
			cur_translation.y = init_translation.y + shake_range * sin(gain_val)
		
		set_translation(cur_translation)

		if shake_timer.is_finish() and floor(cur_translation.x) == 0 and floor(cur_translation.y) == 0:
			is_shaking = false

	else:
		shake_timer.reload()
	
func shake(_shake_range, _shake_speed, _shake_duration, _lock_x = false, _lock_y = false):
	if !is_shaking:
		shake_range = _shake_range
		shake_speed = _shake_speed

		shake_timer.change_init_time(_shake_duration)
		
		shake_lock_x = _lock_x
		shake_lock_y = _lock_y

		gain_val = 0

		is_shaking = true
