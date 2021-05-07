extends Node

# максимальная заполненность шкалы
var type 
export var init_points = 100
export var points = 50

var step_time = 0
var step = 0

# sprites
onready var bg = get_node("bg")
onready var bar = get_node("bar")

var autodestroy_when_empty = false

var init_bar_tex_size
var init_bar_width
var init_bar_height

func _ready():
	init_bar_tex_size = SYS.get_sprite_texture_size_in_pixels(bar)
	init_bar_width = init_bar_tex_size.x
	init_bar_height = init_bar_tex_size.y

func setup_progressbar(_init_points):
	if init_points != _init_points:
		init_points = _init_points
		points = init_points

func update(_points):
	points = _points

	# init_points = 100%
	# points = x
	# points * 100.0 / init_points

	var coef = points * 100.0 / init_points
	var change_percents = coef / 100.0 # 100 => 1.0

	var bar_tex_new_width = init_bar_width * change_percents
	
	SYS.change_sprite_texture_size_pixels(bar, Vector2(bar_tex_new_width, init_bar_height))

	if has_node("val"):
		#get_node("val").set_text(str(points)+"/"+str(init_points))
		get_node("val").set_text(str(points))

	if autodestroy_when_empty:
		if points <= 0:
			queue_free()

func set_autodestroy_when_empty(_bool):
	autodestroy_when_empty = _bool

func set_bar_color(_color):
	bar.set_modulate(_color)
