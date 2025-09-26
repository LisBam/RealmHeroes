extends Buff

class_name huobaolajiao_add_power

var add_count:int = 50

func _init() -> void:
	super._init()
	buff_id = "huobaolajiao_add_power"
	max_stacks = 3
	
func _on_stack_increased(new_stacks: int):
	target.magical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法强",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大法强加成",true)
	
func _on_stack_removed(new_stacks: int):
	target.magical_power -= add_count
	target.magical_power = max(target.magical_power,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点法强加成",true)
	
# Buff施加时触发
func _on_apply():
	target.magical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法强",true)
	
# Buff移除时触发
func _on_remove():
	target.magical_power -= add_count
	target.magical_power = max(target.magical_power,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点法强加成",true)
