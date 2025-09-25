extends Buff

class_name shengshuishouhu_add_buff

var add_count:int = 30

func _init() -> void:
	super._init()
	buff_id = "shengshuishouhu_add_buff"
	max_stacks = 4
	
func _on_stack_increased(new_stacks: int):
	target.magical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法抗",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大法抗加成",true)
		
	target.physical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大物抗加成",true)
	
# Buff施加时触发
func _on_apply():
	target.magical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点法抗",true)
	
	target.physical_defense += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点物抗",true)
