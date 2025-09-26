extends Buff

class_name huangjiashijiu_skillc_mark

var add_count:int = 100
var damage:int = 1800

func _init() -> void:
	super._init()
	buff_id = "huangjiashijiu_skillc_mark"
# Buff施加时触发
func _on_apply():
	source.damage_reduction += add_count
	addlog(source.character_name+" 提高"+str(add_count)+"%免伤",true)
	
# Buff移除时触发
func _on_remove():
	source.damage_reduction -= add_count
	source.damage_reduction = max(source.damage_reduction,0)
	if not source.is_die:
		addlog(source.character_name+" 失去"+str(add_count)+"%免伤加成",true)

#回合开始时触发
func phase_begin():
	if not source.is_die:
		addlog(target.character_name+" 被皇家狮鹫袭击",true)
		source.attack_skill_animation();
		source.be_and_to_damage(source.damage(damage,"mag",target,"water"),target,source,"mag","water")
