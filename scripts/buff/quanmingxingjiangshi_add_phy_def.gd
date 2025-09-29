extends Buff

class_name quanmingxingjiangshi_add_phy_def

var add_count:int = 60

func _init() -> void:
	super._init()
	buff_id = "quanmingxingjiangshi_add_phy_def"
	stack_policy = StackPolicy.ADD_DURATION
# Buff施加时触发
func _on_apply():
	target.physical_defense_add += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
	
# Buff移除时触发
func _on_remove():
	target.physical_defense_add -= add_count
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点物抗加成",true)
