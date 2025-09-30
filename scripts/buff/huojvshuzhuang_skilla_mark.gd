extends Buff

class_name huojvshuzhuang_skilla_mark

var count:int = 4

func _init() -> void:
	buff_id = "huojvshuzhuang_skilla_mark"
	super._init()

func to_damage(func_damage,func_target,damage_type:String,damage_element:String,is_extra:bool = false,energy = 0,func_source = target):
	if not damage_type == "phy":
		return
	if not target.is_curr:
		return
	if func_source != target:
		return
	target.be_and_to_damage(target.damage(source.get_magical_power()*5,"mag",func_target,"fire"),func_target,target,"mag","fire")
	count -= 1;
	if count <= 0:
		var buff_manager = target.get_node("buff")
		buff_manager.remove_buff(self.buff_id)

# Buff移除时触发
func _on_remove():
	addlog(target.character_name+" 物攻不再附加伤害。",true)
