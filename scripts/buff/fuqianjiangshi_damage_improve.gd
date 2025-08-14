extends Buff

class_name fuqianjiangshi_damage_improve

var add_count:int = 30

func _init() -> void:
	super._init()
	buff_id = "fuqianjiangshi_damage_improve"
# Buff施加时触发
func _on_apply():
	target.damage_improve += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"%增伤",true)
	
# Buff移除时触发
func _on_remove():
	target.damage_improve -= add_count
	target.damage_improve = max(target.damage_improve,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"%增伤加成",true)
