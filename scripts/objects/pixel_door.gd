extends Spatial

var player

export var is_rotated_door = false
export var item_to_open_key = ""

var is_opened = false

func switch_door():
	player = get_tree().get_nodes_in_group("player")[0]
	if item_to_open_key == "" or player.is_has_item_with_key(item_to_open_key):
		if !$anim.is_playing():
			if is_opened:
				if is_rotated_door:
					$anim.play_backwards("open_rotated")
				else:
					$anim.play_backwards("open")
				is_opened = false
			else:
				if is_rotated_door:
					$anim.play("open_rotated")
				else:
					$anim.play("open")
				is_opened = true
