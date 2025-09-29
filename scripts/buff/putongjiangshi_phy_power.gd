extends Buff

class_name putongjiangshi_phy_power

var add_count:int = 10

func _init() -> void:
	super._init()
	buff_id = "putongjiangshi_phy_power"
	
func _on_stack_increased(new_stacks: int):
	target.physical_power_add += add_count
	
func _on_stack_removed(new_stacks: int):
	target.physical_power_add -= add_count
	
# Buff施加时触发
func _on_apply():
	target.physical_power_add += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物攻",true)
	
# Buff移除时触发
func _on_remove():
	target.physical_power_add -= add_count
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点物攻加成",true)
