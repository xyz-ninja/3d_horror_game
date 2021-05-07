extends KinematicBody

var gui

export var is_in_water = false

# movement
var dir
var vel  = Vector3()

var standard_move_speed = 250
var running_move_speed = 400

var gravity_strength = -20
var rot_speed_mul = 0.005
var jump_strength = 7.55

# for mouse view
var rot_x = 0
var rot_y = 0

var camera_shake_val

var cast
var cast_action_object # текущий объект из луча

var is_running = false
var move_camera_shake_timer = TIME.create_new_timer("player_move_camera_shake", 0.5)
var move_up_in_water_timer = TIME.create_new_timer("player_move_up_in_water", 0.01)

var cam

var cur_items = []
var cur_game_level

enum PROGRESS_ACTION_TYPE {
	TAKE_OFF_CLOTH, TAKE_ON_SLIPPER, USE_SHOWER, RELAX_BEFORE_POOL
}

class ProgressAction:
	var player
	var type
	var addit_code

	var progress_timer
	var progress_bar

	var is_lock_camera = false
	var is_lock_movement = false

	var is_finished = false

	func _init(_player, _type, _addit_code = null):
		player = _player
		type = _type
		addit_code = _addit_code

		var action_time

		if type == PROGRESS_ACTION_TYPE.USE_SHOWER:
			action_time = 5
			is_lock_movement = true
		elif type == PROGRESS_ACTION_TYPE.TAKE_OFF_CLOTH:
			action_time = 2
			is_lock_movement = true
			is_lock_camera = true
		elif type == PROGRESS_ACTION_TYPE.TAKE_ON_SLIPPER:
			action_time = 1
			is_lock_movement = true
			is_lock_camera = true
		elif type == PROGRESS_ACTION_TYPE.RELAX_BEFORE_POOL:
			action_time = 2
			is_lock_camera = true
			is_lock_movement = true

		progress_timer = TIME.create_new_timer("progress_action_timer", action_time)
		progress_bar = player.gui.get_node("action_progressbar")

		progress_bar.setup_progressbar(action_time)

		if is_lock_camera:
			player.is_camera_locked = true
		if is_lock_movement:
			player.is_movement_locked = true

		progress_bar.show()

	func update():
		if progress_timer.is_finish():
			finish()
		else:
			progress_bar.update(progress_timer.check_time())

	func finish():
		if is_lock_camera:
			player.is_camera_locked = false
		if is_lock_movement:
			player.is_movement_locked = false

		progress_bar.hide()

		TIME.destroy_timer(progress_timer)

		if type == PROGRESS_ACTION_TYPE.USE_SHOWER:
			var negative_lamps = player.get_tree().get_nodes_in_group("negative_lamps")
			for l in negative_lamps:
				l.light_negative = true

			var showers = player.get_tree().get_nodes_in_group("showers")
			for shower in showers:
				shower.turn_off_water()

			player.cam.fov = player.cam.fov_strange

			player.add_item_by_key("CLEAN_BODY")

		# кидаемся одеждой
		elif type == PROGRESS_ACTION_TYPE.TAKE_OFF_CLOTH:
			if addit_code == 'cloth_container_upper':
				var obj_tr = player.get_translation() + SYS.get_dir_between_objects_normalized(player, player.cast_action_object) * 1.2
				obj_tr.y += 0.6
				var new_obj = player.cur_game_level.create_object_by_scn(
					player.cur_game_level.scn_player_cloth_upper, obj_tr,
					player.get_tree().get_nodes_in_group('wardrobe_props')[0]
				)
				new_obj.rotation.y = 180
				new_obj.apply_impulse(Vector3(), SYS.get_dir_between_objects_normalized(player, new_obj) * 6)
				
				player.add_item_by_key("REMOVED_CLOTH_UPPER")

			elif addit_code == 'cloth_container_legs': 
				var obj_tr = player.get_translation() + SYS.get_dir_between_objects_normalized(player, player.cast_action_object) * 1.2
				obj_tr.y += 0.6
				var new_obj = player.cur_game_level.create_object_by_scn(
					player.cur_game_level.scn_player_cloth_legs, obj_tr,
					player.get_tree().get_nodes_in_group('wardrobe_props')[0]
				)
				new_obj.rotation.y = 180
				new_obj.apply_impulse(Vector3(), SYS.get_dir_between_objects_normalized(player, new_obj) * 5)
				
				player.add_item_by_key("REMOVED_CLOTH_LEGS")

			player.cast_action_object = null

		elif type == PROGRESS_ACTION_TYPE.TAKE_ON_SLIPPER:
			if player.is_has_item_with_key("CLOTH_SLIPPER_1"):
				player.add_item_by_key("CLOTH_SLIPPER_2")
			else:
				player.add_item_by_key("CLOTH_SLIPPER_1")
			
			player.cast_action_object.queue_free()
			player.cast_action_object = null

		# отдыхаем на первом уровне
		elif type == PROGRESS_ACTION_TYPE.RELAX_BEFORE_POOL:
			# bool: true = 1 false = 0
			var relax_level = int(player.is_has_item_with_key("RELAX_LVL1")) + int(player.is_has_item_with_key("RELAX_LVL2"))

			# если выбран один из объектов, остальные уничтожаются
			if addit_code == "beer_mexico_monkey":
				if relax_level == 0:
					player.get_tree().get_nodes_in_group("relax_ashtray")[0].queue_free()
					player.get_tree().get_nodes_in_group("relax_cocaine")[0].queue_free()

					player.cam.fov = player.cam.fov_very_strange

					player.add_item_by_key("RELAX_LVL1")
				
				elif relax_level == 1:
					# на время появляются собутыльники которые хлопают по столу
					
					player.cam.fov = player.cam.fov_absolute_strange
					player.cam.far = player.cam.far_close

					player.restore_default_state_in_time(4)

					player.add_item_by_key("RELAX_LVL2")

			elif addit_code == "ashtray":
				if relax_level == 0:
					player.get_tree().get_nodes_in_group("relax_beer")[0].queue_free()
					player.get_tree().get_nodes_in_group("relax_cocaine")[0].queue_free()

					player.restore_default_state_in_time(3)

					player.cam.fov = player.cam.fov_strange - 10

					# блюет кровью
					player.get_node("p_vomit_blood").show()
					player.get_node("p_vomit_blood").set_emitting(true)

					player.add_item_by_key("RELAX_LVL1")
				
				elif relax_level == 1:
					player.restore_default_state_in_time(4)
					player.is_movement_locked = true

					var negative_lamps = player.get_tree().get_nodes_in_group("negative_lamps")
					for l in negative_lamps:
						l.light_negative = true

					player.cam.fov = player.cam.fov_strange - 20

					# появляется странное дымящееся лицо
					player.get_tree().get_nodes_in_group("smoking_face")[0].show()

					player.add_item_by_key("RELAX_GOOD_SMOKE")
					player.add_item_by_key("RELAX_LVL2")

			elif addit_code == "dish_with_cocaine":
				if relax_level == 0:
					player.get_tree().get_nodes_in_group("relax_beer")[0].queue_free()
					player.get_tree().get_nodes_in_group("relax_ashtray")[0].queue_free()

					player.cam.fov = player.cam.fov_wide

					var negative_lamps = player.get_tree().get_nodes_in_group("negative_lamps")
					for l in negative_lamps:
						l.light_energy *= 2.5

					player.add_item_by_key("RELAX_LVL1")

				elif relax_level == 1:
					player.cam.fov = player.cam.fov_very_wide
					player.restore_default_state_in_time(4)

					var negative_lamps = player.get_tree().get_nodes_in_group("negative_lamps")
					for l in negative_lamps:
						l.light_negative = true

					player.add_item_by_key("RELAX_LVL2")
					player.add_item_by_key("RELAX_COCAINE_TRIP")

		is_finished = true

var cur_progress_action

var is_camera_locked = false
var is_movement_locked = false

# нужно ли восстановить нормальные значения камеры и тд (убрать эффект действия кокаина и тд)
var is_need_restore_default_state = false
var restote_default_state_timer = TIME.create_new_timer("player_restore_default_state", 1.0)

func _ready():
	gui = get_tree().get_nodes_in_group("gui")[0]
	
	cam = get_node("cam_pos/cam")
	cast = get_node("cam_pos/cast")
	
	check_cast_action()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	add_item_by_key('WARDROBE_KEY')

	restore_default_state_in_time(0.01)

func _process(delta):
	if cur_progress_action != null:
		if cur_progress_action.is_finished:
			cur_progress_action = null
		else:
			cur_progress_action.update()

	# вовзращаем нормальную камеру если нужно
	if is_need_restore_default_state:
		if restote_default_state_timer.is_finish():
			cam.fov = cam.fov_init
			cam.far = cam.far_init

			# убираем блевание кровью
			get_node("p_vomit_blood").hide()
			get_node("p_vomit_blood").set_emitting(false)

			if is_has_item_with_key("RELAX_COCAINE_TRIP") or is_has_item_with_key("RELAX_GOOD_SMOKE"):
				var negative_lamps = get_tree().get_nodes_in_group("negative_lamps")
				for l in negative_lamps:
					l.light_negative = false

				if is_has_item_with_key("RELAX_GOOD_SMOKE"):
					get_tree().get_nodes_in_group("smoking_face")[0].queue_free()

			is_camera_locked = false
			is_movement_locked = false

			is_need_restore_default_state = false

func _physics_process(delta):
	dir = Vector3()

	# CHECK INPUT
	if Input.is_action_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# CLOSE GAME
		get_tree().quit()
	
	if Input.is_action_pressed("ui_left"):
		#rotate_y(rot_speed * delta)
		dir.x = -1
	elif Input.is_action_pressed("ui_right"):
		#rotate_y(-rot_speed * delta)
		dir.x = 1	
	if Input.is_action_pressed("ui_up"):
		dir.z = -1
	elif Input.is_action_pressed("ui_down"):
		dir.z = 1
	if Input.is_action_just_released("key_f"):
		# FULLSCREEN MODE
		OS.window_fullscreen = !OS.window_fullscreen

	if Input.is_action_pressed("k_shift"):
		is_running = true
		move_camera_shake_timer.change_init_time(0.32)
	else:
		is_running = false
		move_camera_shake_timer.change_init_time(0.5)

	# MOVEMENT
	if !is_movement_locked:
		var move_speed
		if is_running:
			move_speed = running_move_speed
			
		else:
			move_speed = standard_move_speed
		
		if dir:
			dir *= move_speed * delta
			# поворачиваем ось направлений что бы правильно двигать игрока вперед-назад
			dir = dir.rotated(Vector3(0, 1, 0), rotation.y)
			
			if move_camera_shake_timer.is_finish():
				if is_running:
					cam.shake(0.5, 10, 0.1, true)
				else:
					cam.shake(0.45, 4, 0.21, true)
				move_camera_shake_timer.reload()
		
		vel.x = dir.x
		vel.z = dir.z
		
		if is_in_water:
			vel.y += gravity_strength / 3 * delta
		else:
			vel.y += gravity_strength * delta

		if Input.is_action_just_pressed("ui_select"):
			if is_in_water and move_up_in_water_timer.is_finish():
				vel.y = jump_strength / 1.3
				move_up_in_water_timer.reload()
			else:
				if is_on_floor():
					vel.y = jump_strength
	
		move_and_slide(vel, Vector3(0,1,0))

# ОБРАБОТКА МЫШИ
func _input(event):
	# MOUSE MOTION
	if event is InputEventMouseMotion and !is_camera_locked:
		# event.relative - смещение координат относительно изначального значения
		rot_x -= event.relative.x * rot_speed_mul
		rot_y -= event.relative.y * rot_speed_mul
	
		# ограничиваем движение мыши по y
		if rot_y < -1:
			rot_y = -1
		elif rot_y > 1:
			rot_y = 1
	
		# transform содержит позицию и вращение объекта
		transform.basis = Basis(Vector3(0,1,0), rot_x)
		$cam_pos.transform.basis = Basis(Vector3(1,0,0), rot_y)
		
	# MOUSE PRESSED
	if event is InputEventMouse:
		if event.is_pressed():
			check_cast_action()

# ПРОВЕРЯЕТ ДЕЙСТВИЯ ОБЪЕКТА ПРИ КЛИКЕ ПО НЕМУ И ПРИ НАВЕДЕННОМ ЛУЧЕ КАМЕРЫ ИГРОКА  
func check_cast_action():
	if cast_action_object != null:
		#print(cast_action_object.name)
		var is_need_shake_cam = true
		
		if cast_action_object.name == 'pixel_door':
			cast_action_object.get_parent().switch_door()
		elif cast_action_object.name == 'rack_door':
			cast_action_object.get_parent().get_parent().switch_rack_door()
		elif cast_action_object.name == 'wardrobe_key' and cast_action_object.is_available_to_pick():
			add_item_by_key('WARDROBE_KEY')
			cast_action_object.queue_free()
			cast_action_object = null
			gui.get_node("use_tip").hide()
		elif cast_action_object.is_in_group('prop_paper'):
			var vec3_impulse = SYS.get_dir_between_objects_normalized(self, cast_action_object) * 16
			cast_action_object.apply_impulse(Vector3(0, 0, 0), vec3_impulse)
			#cast_action_object = null
			gui.get_node("use_tip").hide()

			#cast.emit_signal('_on_cast_body_entered')
		
		# WARDROBE CLOTHES
		elif cast_action_object.get_name() == 'cloth_container_upper':
			add_progress_action(PROGRESS_ACTION_TYPE.TAKE_OFF_CLOTH, 'cloth_container_upper')

			gui.get_node("use_tip").hide()

		elif cast_action_object.get_name() == 'cloth_container_legs':
			add_progress_action(PROGRESS_ACTION_TYPE.TAKE_OFF_CLOTH, 'cloth_container_legs')

			gui.get_node("use_tip").hide()

		elif cast_action_object.get_name() == 'cloth_container_shoe':
			var obj_tr = get_translation() + SYS.get_dir_between_objects_normalized(self, cast_action_object) * 1.2
			obj_tr.y += 0.94
			var new_obj = cur_game_level.create_object_by_scn(
				cur_game_level.scn_player_cloth_shoe, obj_tr,
				get_tree().get_nodes_in_group('wardrobe_props')[0]
			)
			new_obj.rotation.y = 180
			new_obj.apply_impulse(Vector3(), SYS.get_dir_between_objects_normalized(self, new_obj) * 5)
			
			if is_has_item_with_key("REMOVED_CLOTH_SHOE_1"):
				add_item_by_key("REMOVED_CLOTH_SHOE_2")
				gui.get_node("use_tip").hide()
				cast_action_object = null
			else:
				add_item_by_key("REMOVED_CLOTH_SHOE_1")
		
		elif cast_action_object.get_name() == 'cloth_container_other':
			var obj_tr = get_translation() + SYS.get_dir_between_objects_normalized(self, cast_action_object) * 1.2
			obj_tr.y += 1.3
			var new_obj = cur_game_level.create_object_by_scn(
				cur_game_level.scn_player_cloth_gun, obj_tr,
				get_tree().get_nodes_in_group('wardrobe_props')[0]
			)
			new_obj.rotation.y = 180
			new_obj.rotation.x = -90
			new_obj.apply_impulse(Vector3(), SYS.get_dir_between_objects_normalized(self, new_obj) * 5)
			
			add_item_by_key("REMOVED_CLOTH_OTHER")
			gui.get_node("use_tip").hide()
			cast_action_object = null

		# SLIPPERS PICK UP
		elif cast_action_object.is_in_group('cloth_slippers'):
			add_progress_action(PROGRESS_ACTION_TYPE.TAKE_ON_SLIPPER)

			gui.get_node("use_tip").hide()

		# SHOWER
		elif cast_action_object.get_name() == 'shower_crane':
			cast_action_object.get_parent().turn_on_water()
			
			add_progress_action(PROGRESS_ACTION_TYPE.USE_SHOWER)

			cast_action_object = null
			
		# POOL
		elif cast_action_object.get_name() == "beer_mexico_monkey":
			add_progress_action(PROGRESS_ACTION_TYPE.RELAX_BEFORE_POOL, "beer_mexico_monkey")

		elif cast_action_object.get_name() == "ashtray":
			add_progress_action(PROGRESS_ACTION_TYPE.RELAX_BEFORE_POOL, "ashtray")

		elif cast_action_object.get_name() == "dish_with_cocaine":
			add_progress_action(PROGRESS_ACTION_TYPE.RELAX_BEFORE_POOL, "dish_with_cocaine")
		
		else:
			is_need_shake_cam = false
		
		if is_need_shake_cam:
			#cam.shake(0.2, 20, 0.3)
			pass

func activate_trigger(_trigger_name):
	var trigger_name = _trigger_name
	
	# возвращаем нормальный свет и туман в локацию
	if trigger_name == 'tr_return_normal_light':
		var negative_lamps = get_tree().get_nodes_in_group("negative_lamps")
		for l in negative_lamps:
			l.light_negative = false
		
		get_tree().get_nodes_in_group("smoking_face")[0].hide()
		restore_default_state_in_time(0.05)
		
	elif trigger_name == 'tr_show_stage_1_1_monsters':
		cur_game_level.show_monsters()

# вернуть нормальное состояние камеры и тд спустя заданное время
func restore_default_state_in_time(_time):
	restote_default_state_timer.change_init_time(_time)
	is_need_restore_default_state = true

func add_progress_action(_type, _addit_code = null):
	if cur_progress_action == null:
		cur_progress_action = ProgressAction.new(self, _type, _addit_code)

func add_item_by_key(_item_key):
	var item = ITEMS.get_new_item_by_key(_item_key)
	
	if !cur_items.has(item):
		cur_items.append(item)

func is_has_item_with_key(_item_key):
	for item in cur_items:
		if item.key == _item_key:
			return true
	return false
