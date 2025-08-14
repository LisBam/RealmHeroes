extends Buff

class_name dubaojiangshi_extra_mag_damage

func _init() -> void:
	super._init()
	buff_id = "dubaojiangshi_extra_mag_damage"
# Buff施加时触发
func _on_apply():
	target.be_damage_to_benefit_mul += 3
	addlog(target.character_name+" 攻击会附加伤害",true)
	
# Buff移除时触发
func _on_remove():
	target.be_damage_to_benefit_mul -= 3
	target.be_damage_to_benefit_mul = max(target.be_damage_to_benefit_mul,1)
	if not target.is_die:
		addlog(target.character_name+" 攻击不再附加伤害",true)
