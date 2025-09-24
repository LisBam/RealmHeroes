extends Buff

class_name caiwen_add_buff

var add_count:int = 20

func _init() -> void:
	super._init()
	buff_id = "caiwen_add_buff"
	max_stacks = 6
	
func _on_stack_increased(new_stacks: int):
	target.physical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物攻",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大物攻加成",true)
		
	target.physical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大物抗加成",true)
	
func _on_stack_removed(new_stacks: int):
	target.physical_power -= add_count
	target.physical_power = max(target.magical_power,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点物攻加成",true)
		
	target.physical_defense -= add_count
	target.physical_defense = max(target.magical_power,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点物抗加成",true)
	
# Buff施加时触发
func _on_apply():
	target.physical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物攻",true)
	
	target.physical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
	
# Buff移除时触发
func _on_remove():
	target.physical_power -= add_count
	target.physical_power = max(target.physical_power,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点物攻加成",true)
		
	target.physical_defense -= add_count
	target.physical_defense = max(target.physical_defense,0)
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点物抗加成",true)
