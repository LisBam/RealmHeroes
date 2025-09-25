extends Buff

class_name add_all_stats

var add_count:int = 20

func _init() -> void:
	super._init()
	buff_id = "add_all_stats"
	max_stacks = 6
	
func _on_stack_increased(new_stacks: int):
	target.physical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物攻",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大物攻加成",true)
		
	target.magical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法强",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大法强加成",true)
	
	target.magical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法抗",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大法抗加成",true)
		
	target.physical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大物抗加成",true)
		
	target.speed += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点速度",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大速度加成",true)
	
# Buff施加时触发
func _on_apply():
	target.physical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物攻",true)
		
	target.magical_power += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法强",true)
	
	target.magical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法抗",true)
		
	target.physical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
		
	target.speed += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点速度",true)
