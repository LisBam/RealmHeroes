extends Buff

class_name shengshuishouhu_skillb_mark

var count:int = 200

func _init() -> void:
	super._init()
	buff_id = "shengshuishouhu_skillb_mark"
# Buff施加时触发
func _on_apply():
	addlog(source.character_name+" 施展水之护盾",true)
	
func round_start():
	if not source.is_die:
		source.add_shield(count,source);
		source.recover_energy(10);
	
# Buff移除时触发
func _on_remove():
	if not target.is_die:
		addlog(source.character_name+" 的水之护盾消失了",true)
