extends Spatial

var player

var is_activated = false

func _ready():
	get_node("visual_cube").queue_free()

	player = get_tree().get_nodes_in_group('player')[0]

func _process(delta):
	if !is_activated and SYS.get_3d_dist_between_translates(get_translation(), player.get_translation()) < 11:
		player.activate_trigger(get_name())
		is_activated = true
		queue_free()
