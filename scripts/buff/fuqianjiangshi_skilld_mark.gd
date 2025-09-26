extends Buff

class_name fuqianjiangshi_skilld_mark

var damage:int = 400

func _init() -> void:
	super._init()
	buff_id = "fuqianjiangshi_skilld_mark"
# Buff施加时触发
func _on_apply():
	addlog(source.character_name+" 对 "+target.character_name+" 激起暗流！",true)
	
func round_start():
	if not source.is_die:
		addlog(target.character_name+" 被暗流袭击",true)
		source.be_and_to_damage(source.damage(damage,"phy",target,"water"),target,source,"phy","water")
	
# Buff移除时触发
func _on_remove():
	if not target.is_die:
		addlog(source.character_name+" 的暗流平息了",true)
