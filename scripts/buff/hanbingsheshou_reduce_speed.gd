extends Buff

class_name hanbingsheshou_reduce_speed

var count:int = 3

func _init() -> void:
	super._init()
	buff_id = "hanbingsheshou_reduce_speed"
	max_stacks = 5
	
func _on_stack_increased(new_stacks: int):
	target.speed -= count
	target.speed = max(target.speed,0)
	addlog(target.character_name+" 降低"+str(count)+"点速度",true)
	if current_stacks == max_stacks:
		addlog(target.character_name+" 已达该效果的最大减速",true)
	
func _on_stack_removed(new_stacks: int):
	target.speed += count
	if not target.is_die:
		addlog(target.character_name+" 恢复"+str(count)+"点速度",true)
	
# Buff施加时触发
func _on_apply():
	target.speed -= count
	target.speed = max(target.speed,0)
	addlog(target.character_name+" 降低"+str(count)+"点速度",true)
	
# Buff移除时触发
func _on_remove():
	target.speed += count
	if not target.is_die:
		addlog(target.character_name+" 恢复"+str(count)+"点速度",true)
