extends Area

var player
var gui

func _ready():
	player = $'../../';

func _on_cast_body_entered(body):
	if body != player and player.cast_action_object == null and !body.is_in_group("disable_ray_pick"):
		if gui == null:
			gui = player.gui
		
		var is_body_entered = true
		
		var custom_tip_text
		
		if body.get_name() == 'wardrobe_key' :
			if body.is_available_to_pick():
				custom_tip_text = "Взять ключик от гардероба"
			else:
				is_body_entered = false

		elif body.is_in_group('prop_paper'):
			custom_tip_text = "Убрать"

		elif body.is_in_group('cloth_slippers'):
			custom_tip_text = "Надеть тапочек"

		# CLOTHES CONTAINER
		elif body.get_name() == 'cloth_container_upper':
			if player.is_has_item_with_key("REMOVED_CLOTH_UPPER"):
				is_body_entered = false
			else:
				custom_tip_text = "Сложить верхнюю одежду"
		elif body.get_name() == 'cloth_container_legs':
			if player.is_has_item_with_key("REMOVED_CLOTH_LEGS"):
				is_body_entered = false
			else:
				custom_tip_text = "Сложить штаны"
		elif body.get_name() == 'cloth_container_shoe':
			if player.is_has_item_with_key("REMOVED_CLOTH_SHOE_1") and player.is_has_item_with_key("REMOVED_CLOTH_SHOE_2"):
				is_body_entered = false
			else:
				custom_tip_text = "Сложить ботинок"
		elif body.get_name() == 'cloth_container_other':
			if player.is_has_item_with_key("REMOVED_CLOTH_OTHER"):
				is_body_entered = false
			else:
				custom_tip_text = "Сложить мелочи"

		elif body.get_name() == 'shower_crane':
			if player.is_has_item_with_key("CLEAN_BODY") or body.get_parent().is_water_on:
				is_body_entered = false
			else:
				custom_tip_text = "Принять душ"

		elif body.get_name() == "beer_mexico_monkey":
			custom_tip_text = "Отдохнуть - Выпить"

		elif body.get_name() == "ashtray":
			custom_tip_text = "Отдохнуть - Покурить"

		elif body.get_name() == "dish_with_cocaine":
			custom_tip_text = "Отдохнуть - Нюхать кокаин"

		if is_body_entered:
			#gui.get_node("use_tip").set_text(body.get_name())

			if body.is_in_group("show_use_tip"):
				gui.get_node("use_tip").set_text('Использовать')
				gui.get_node("use_tip").show()

			elif custom_tip_text != null:
				gui.get_node("use_tip").set_text(custom_tip_text)
				gui.get_node("use_tip").show()

			else:
				gui.get_node("use_tip").hide()

			player.cast_action_object = body

func _on_cast_body_exited(body):
	if player.cast_action_object == body:
		player.cast_action_object = null
		gui.get_node("use_tip").hide()
