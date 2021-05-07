extends Node

var tex = self

# animation
var init_anim_time = 0.12
var anim_timer = TIME.create_new_timer("frame_animated_sprite_timer", init_anim_time)
var cur_anim_frame_num = 0
var is_anim_loop_backwards = false # когда анимация проигралась, она начинает играть задом наперед
var is_anim_now_loop_backwards = false

export var is_autoplay = false
export var autoplay_frames_count = 0
export var autoplay_start_from_frame_num = 0
export var autoplay_anim_speed = 0.2

func _process(delta):
	if is_autoplay:
		play_frame_animation(
			autoplay_frames_count, autoplay_start_from_frame_num, autoplay_anim_speed)

func play_frame_animation(_frames_count = 6, _start_from_frame = 0, _anim_speed = init_anim_time):
	var frames_count = _frames_count
	var from_frame = _start_from_frame

	if frames_count == 0 or frames_count == 1:
		cur_anim_frame_num = 0
		is_anim_now_loop_backwards = false
	else:
		if cur_anim_frame_num >= frames_count :
			cur_anim_frame_num = 0

	# изменяем скорость анимации по таймеру если она отличается от изначальной
	if anim_timer.init_time != _anim_speed:
		anim_timer.change_init_time(_anim_speed)

	if anim_timer.is_finish():
		# loop backward mode
		if is_anim_loop_backwards:
			if frames_count > 1:
				if is_anim_now_loop_backwards:
					if cur_anim_frame_num - 1 == 0:
						cur_anim_frame_num = 0
						is_anim_now_loop_backwards = false
					else:
						cur_anim_frame_num -= 1
				else:
					if cur_anim_frame_num + 1 == frames_count:
						cur_anim_frame_num -= 1
						is_anim_now_loop_backwards = true
					else:
						cur_anim_frame_num += 1
		else:
			if cur_anim_frame_num + 1 == frames_count:
				cur_anim_frame_num = 0
			else:
				cur_anim_frame_num += 1

		var prev_rect2 = tex.get_region_rect()

		# ставим нужный кадр из текстуры
		tex.set_region_rect(Rect2(Vector2(
			prev_rect2.size.x * (cur_anim_frame_num + from_frame), prev_rect2.position.y),
			prev_rect2.size)
		)

		if has_node("tex1"):
			get_node("tex1").set_region_rect(tex.get_region_rect())

		anim_timer.reload()
