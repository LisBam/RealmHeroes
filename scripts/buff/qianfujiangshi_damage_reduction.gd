extends Buff

class_name qianfujiangshi_damage_reduction

var add_count:int = 50

func _init() -> void:
	super._init()
	buff_id = "qianfujiangshi_damage_reduction"
# Buff施加时触发
func _on_apply():
	target.damage_reduction += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"%免伤",true)
	
# Buff移除时触发
func _on_remove():
	target.damage_reduction -= add_count
	target.damage_reduction = max(target.damage_reduction,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"%免伤加成",true)
