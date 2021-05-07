extends Node

const Colors = {
	OBJ_original 	= Color(1,1,1,1),
	white 			= "#ffffff",
	black 			= "#000000",
	gray 			= "#696B6E",
	dark_gray 		= "#202020",
	red 			= "#D73030",
	green 			= "#54D830",
	light_yellow 	= "#E9E747",
	yellow 			= "#C9C708",
	light_blue 		= "#1E90FF",
	blue 			= "#0000FF",
	plum 			= "#DDA0DD"
}

var InitValues = {
	dist_collide = 75
}

enum DIR {LEFT, RIGHT, UP, DOWN}
enum ISOM_WALL_DIR {FRONT, BACK, LEFT, RIGHT}
enum ONTILE_OBJ_TYPE {UNIT, FUR, MOUSE_CURSOR} # need in isometric_tile show/hide around tiles funcs

var astar = null

var tms_last_id = 0

func _ready():
	astar = AStar.new()

func start_setup():
	.start_setup()

func is_pos_inside_rect(_pos , _rect):
	if (_pos.x >= _rect.pos.x and 
		_pos.x <= _rect.size.width and
		_pos.y >= _rect.pos.y and
		_pos.y <= _rect.size.height ):
		return true
	else:
		return false

func is_spr_collide_other_spr(_spr , _other_spr):
	var spr = _spr
	var other_spr = _other_spr

	var t_spr = get_true_sprite_rect2(spr)
	var t_other_spr = get_true_sprite_rect2(other_spr)

	if (t_spr.pos.x >= t_other_spr.pos.x and
		t_spr.pos.x + t_spr.size.width <= t_other_spr.pos.x + t_other_spr.size.width  or
		t_spr.pos.y >= t_other_spr.pos.y and
		t_spr.pos.y + t_spr.size.height <= t_other_spr.pos.y + t_other_spr.size.height):
		return true
	else:
		return false

func get_dist_between_points(_p1, _p2):
	var p1 = _p1
	var p2 = _p2

	var dist = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
	return dist

func get_dist_between_points_in_detail(_p1, _p2):
	var p1 = _p1
	var p2 = _p2

	var dist = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
	var dist_x = sqrt(pow(p2.x - p1.x, 2))
	var dist_y = sqrt(pow(p2.y - p1.y, 2))

	return {common = dist, horizontal = dist_x, vertical = dist_y}

func get_dist_between_sprites(_spr, _other_spr):
	var spr = _spr
	var other_spr = _other_spr

	# ищем центральные точки спрайтов
	var c_pos1 = get_sprite_center_pos(spr)
	var c_pos2 = get_sprite_center_pos(other_spr)

	var dist = sqrt(pow(c_pos2.x - c_pos1.x,2) + pow(c_pos2.y - c_pos1.y, 2))

	return dist

func get_angle_between_positions(_pos1, _pos2):
	var pos1 = _pos1
	var pos2 = _pos2

	var angle = rad2deg(atan2(pos1.y - pos2.y, pos1.x - pos2.x))
	if angle < 0:
		angle += 360

	return angle

# позиция и настоящие размеры спрайта с учётом region_rect.size * scale
func get_true_sprite_rect2(_spr):
	var spr = _spr
	var true_rect = Rect2(
		spr.get_global_pos(),
		Vector2(
			spr.get_region_rect().size.width * spr.get_scale().x,
			spr.get_region_rect().size.height * spr.get_scale().y 
		)
	)
	return true_rect

func get_random_int(_min, _max):
	randomize()
	return int(rand_range(_min, _max))

func get_random_float(_min, _max):
	randomize()
	return rand_range(_min, _max)

func get_random_percent_0_to_100():
	randomize()
	return int(rand_range(0, 100.1))

func get_random_arr_item(_arr):
	var cur_arr = _arr
	if cur_arr != null and cur_arr.size() > 0:
		randomize()
		var rand_index = int(rand_range(0, cur_arr.size()))
		return cur_arr[rand_index]
	else:
		return null

func get_random_enum_item(_enum):
	var cur_enum = _enum
	randomize()
	var rand_index = int(rand_range(0, cur_enum.size()))
	for key in cur_enum.keys():
		if cur_enum[key] == rand_index:
			return cur_enum[key]

func get_random_dict_item(_dict):
	var cur_dict = _dict
	randomize()
	var rand_index = int(rand_range(0, cur_dict.size()))
	
	var cur_item_index = 0
	for key in cur_dict.keys():
		if cur_item_index == rand_index:
			return cur_dict[key]
		else:
			cur_item_index += 1		

func get_enum_key_by_value(_enum, _enum_value):
	var cur_enum = _enum
	var search_v = _enum_value
	if search_v == null:
		return null
	for k in cur_enum.keys():
		if cur_enum[k] == search_v:
			return k
	print("get_enum_value_key() error, returned null")
	return null

func get_sprite_center_pos(_spr):
	var spr = _spr
	var gl_pos = spr.get_global_pos()
	return Vector2(
		gl_pos.x + (spr.get_region_rect().size.width * spr.get_scale().x / 2),
		gl_pos.y + (spr.get_region_rect().size.height * spr.get_scale().y / 2)
	)

# получает текстовое значение ключа из dict по его значению
func get_dict_key_by_value(_dict, _val):
	var cur_dict = _dict
	var v = _val

	for k in cur_dict.keys():
		if cur_dict[k] == v:
			return k

	return null

# сортировки
# сортирует массив параметров(dict) по значению ключа
func sort_params_arr_by_key_value(_params_arr, _param_key):
	var sorted_params = _params_arr + []
	var param_key = _param_key

	# алгоритм: сортировка перемешиванием

	var left = 0
	var right = sorted_params.size() - 1

	while left <= right:
		for i in range(left, right, 1):
			var cur_param = sorted_params[i]
			var next_param = sorted_params[i + 1]

			var cur_val = cur_param[param_key]
			var next_val = next_param[param_key]

			if cur_val > next_val:
				var buff = sorted_params[i]
				sorted_params[i] = sorted_params[i + 1]
				sorted_params[i + 1] = buff
		
		right -= 1

		for i in range(right, left, -1):
			var cur_param = sorted_params[i]
			var prev_param = sorted_params[i - 1]

			var cur_val = cur_param[param_key]
			var prev_val = prev_param[param_key]
			
			if prev_val < cur_val:
				var buff = sorted_params[i]
				sorted_params[i] = sorted_params[i - 1]
				sorted_params[i - 1] = buff
		
		left += 1

	# возвращаем отсортированный массив
	return sorted_params

# ДОП ФУНКЦИИ ДЛЯ GODOT 3

# выдаёт в каком направлении от объекта находится другой, возвращает нормализованный (значения приводятся к диапазону 0..1) вектор3
func get_dir_between_objects_normalized(_obj1, _obj2):
	var dir_vec3 = -(_obj1.translation - _obj2.translation).normalized()
	#print(dir_vec3)
	return dir_vec3

func get_sprite_texture_size_in_pixels(_sprite):
	var tex_size = _sprite.get_texture().get_size()
	var spr_scale = _sprite.get_scale()

	var size_x = tex_size.x * spr_scale.x
	var size_y = tex_size.y * spr_scale.y

	return Vector2(size_x, size_y)

# поменять размер спрайта (его текстуры) до определенного в пикселях
func change_sprite_texture_size_pixels(_sprite, _v2_new_pixels_size):
	var spr = _sprite
	var tex = spr.get_texture()
	var new_size = _v2_new_pixels_size

	var tex_size = tex.get_size()
	var target_h = new_size.y
	var target_w = new_size.x
	var new_scale = Vector2((tex_size.x/(tex_size.x/target_w)) / 100, (tex_size.y/(tex_size.y/target_h)) / 100)

	spr.set_scale(new_scale)

func get_3d_dist_between_translates(_p1_translate, _p2_translate):
	var p1_tr = _p1_translate
	var p2_tr = _p2_translate

	var dist = pow(p2_tr.x - p1_tr.x, 2) + pow(p2_tr.y - p1_tr.y, 2) + pow(p2_tr.z - p1_tr.z, 2)
	return dist
