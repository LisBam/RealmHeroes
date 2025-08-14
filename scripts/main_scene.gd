extends Node

#随机模式
func _to_random_fighting() -> void:
	#随机配置敌人
	Global.set_random_enemy()
	#随机己方阵容
	Global.set_random_team()
	
	get_tree().change_scene_to_file("uid://j1a0qbv7it4k")
	
#队伍模式
func _to_team_fighting() -> void:
	#随机配置敌人
	Global.set_random_enemy()
	
	get_tree().change_scene_to_file("uid://j1a0qbv7it4k")
