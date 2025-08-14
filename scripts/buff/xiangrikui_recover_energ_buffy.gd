extends Buff

class_name xiangrikui_recover_energy_buff

var recover_energy_count:int = 10

func _init() -> void:
	buff_id = "xiangrikui_recover_energy_buff"
	super._init()
	
func enter_buff():
	print("触发入场buff")
	target.recover_energy(recover_energy_count)
	print(target.get_parent())
	#不是ai则清空我方所有该buff
	if not target.is_ai:
		for character in target.get_parent().player_team:
			if character:
				if character.get_node("buff").has_buff("xiangrikui_recover_energy_buff"):
					character.get_node("buff").remove_buff("xiangrikui_recover_energy_buff")
	#是ai则清空敌方所有该buff
	else:
		for character in target.get_parent().enemy_team:
			if character:
				if character.get_node("buff").has_buff("xiangrikui_recover_energy_buff"):
					character.get_node("buff").remove_buff("xiangrikui_recover_energy_buff")
