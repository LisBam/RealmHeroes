extends Buff

class_name putongjiangshi_add_speed

var add_count:int = 10

func _init() -> void:
	super._init()
	buff_id = "putongjiangshi_add_speed"
	stack_policy = StackPolicy.ADD_DURATION
# Buff施加时触发
func _on_apply():
	target.speed_add += add_count
	addlog(target.character_name+" 提高"+str(add_count)+"点速度",true)
	
# Buff移除时触发
func _on_remove():
	target.speed_add -= add_count
	if not target.is_die:
		addlog(target.character_name+" 失去"+str(add_count)+"点速度加成",true)
