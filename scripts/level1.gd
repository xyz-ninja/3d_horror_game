extends "res://scripts/level_base.gd"

var init_fog_depth_end = 45
var darker_fog_depth_end = 15

var scn_player_cloth_upper = load("res://objects/player_objects/cloth_upper.tscn")
var scn_player_cloth_legs = load("res://objects/player_objects/cloth_legs.tscn")
var scn_player_cloth_shoe = load("res://objects/player_objects/cloth_shoe.tscn")
var scn_player_cloth_gun = load("res://objects/player_objects/cloth_gun.tscn")

func start():
	gui.show_effect("noise")
