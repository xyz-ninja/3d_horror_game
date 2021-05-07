extends WorldEnvironment

var player
var gui

var is_started = false

func _process(delta):
	var is_need_start = true

	var player_gr = get_tree().get_nodes_in_group('player')
	if player_gr.size() > 0:
		player = player_gr[0]
		player.cur_game_level = self
	else:
		is_need_start = false

	var gui_gr = get_tree().get_nodes_in_group('gui')
	if gui_gr.size() > 0:
		gui = gui_gr[0]
	else:
		is_need_start = false

	if is_need_start:
		start()

func create_object_by_scn(_scn, _translation, _parent = null):
	var new_obj = _scn.instance()
	var p = _parent
	if p == null:
		add_child(new_obj)
	else:
		p.add_child(new_obj)

	new_obj.set_translation(_translation)

	return new_obj

# эта функция вызывается у дочеоних объектов этого скрипта
func start():
	is_started = true
