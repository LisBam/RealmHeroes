extends Buff

class_name putongjiangshi_not_die

var add_count:int = 1

func _init() -> void:
	super._init()
	buff_id = "putongjiangshi_not_die"
# Buff施加时触发
func _on_apply():
	target.not_die_to_one_hp += add_count
	target.addlog("施加buff")
	
# Buff移除时触发
func _on_remove():
	target.not_die_to_one_hp -= add_count
	target.not_die_to_one_hp = max(target.not_die_to_one_hp,0)
	target.addlog("buff结束")
