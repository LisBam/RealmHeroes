extends Node

func _to_fighting() -> void:
	#随机配置敌人
	Global.set_random_enemy()
	#随机己方阵容
	Global.set_random_team()
	
	get_tree().change_scene_to_file("uid://j1a0qbv7it4k")
