extends Node

var Items = [
	{key = "WARDROBE_KEY", name = "Ключ от гардероба"},	 # нужен что бы попасть в раздевалку
	{key = "POOL_PASS", name = "Пропуск в бассейн"}, 		 # нужен что бы попасть в бассейн
	{key = "REMOVED_CLOTH_UPPER", name = "Снятая одежда"},
	{key = "REMOVED_CLOTH_LEGS", name = "Снятые штаны"},
	{key = "REMOVED_CLOTH_SHOE_1", name = "Снятый левый ботинок"},
	{key = "REMOVED_CLOTH_SHOE_2", name = "Снятый правый ботинок"},
	{key = "REMOVED_CLOTH_OTHER", name = "Снятые мелочи"},
	{key = "CLOTH_SLIPPER_1", name = "Левый тапочек"},
	{key = "CLOTH_SLIPPER_2", name = "Правый тапочек"},
	{key = "CLEAN_BODY", name = "Чистота"},
	{key = "RELAX_LVL1", name = "Лёгкий отдых"},
	{key = "RELAX_LVL2", name = "Достаточный отдых"},
	{key = "RELAX_COCAINE_TRIP", name = "Кокаиновый трип"},
	{key = "RELAX_GOOD_SMOKE", name = "Хорошенько покурил"}
]

func get_new_item_by_key(_key):
	for item in Items:
		if item.key == _key:
			return item
	return null
