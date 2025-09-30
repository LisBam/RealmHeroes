extends Node

func _ready() -> void:
	#连接信号
	Signals.round_start.connect(round_start)
	Signals.phase_begin.connect(phase_begin)
	Signals.to_damage.connect(to_damage)

# 存储Buff
var buff_list: Dictionary = {}

# 添加Buff
func add_buff(buff: Buff):
	if buff.target == null:
		buff.target = get_parent()
		
	# 存在相同BUFF时的处理
	if buff.buff_id in buff_list:
		var existing = buff_list[buff.buff_id]
		
		#重置时长或延长时间
		match existing.stack_policy:
			Buff.StackPolicy.RESET_DURATION:
				print("已重置buff时长")
				existing.round_duration = buff.init_round_duration
			Buff.StackPolicy.ADD_DURATION:
				print("已延长buff时长")
				existing.round_duration += buff.init_round_duration
		#叠层
		if existing.current_stacks < existing.max_stacks:
			existing.current_stacks += 1
			existing._on_stack_increased(existing.current_stacks)
			print("层数增加到：%d" % existing.current_stacks)
		else:
			print("已达最大层数 %d" % existing.max_stacks)
		return
	else:
		buff_list[buff.buff_id] = buff
		buff._on_apply()

# 移除Buff
func remove_buff(buff_id: String):
	if buff_id in buff_list:
		buff_list[buff_id]._on_remove()
		buff_list.erase(buff_id)
		print(get_parent().character_name + "移除了buff：" + buff_id)

# 每轮更新Buff
func round_start():
	#若不是站场角色，则停止更新
	if not get_parent().is_curr:
		return
	var to_update = []
	for buff_id in buff_list:
		var buff = buff_list[buff_id]
		print("buff初始时长：",buff.init_round_duration)
		print("buff剩余时长：",buff.round_duration)
		buff.round_start()
		buff.round_duration -= 1
		if buff.round_duration == 0:
			if buff.current_stacks > 1:  # 多层处理
				buff.current_stacks -= 1
				buff._on_stack_removed(buff.current_stacks)
				buff.round_duration = buff.init_round_duration
			else:
				to_update.append(buff_id)
			
	# 移除已结束的BUFF
	for id in to_update:
		remove_buff(id)
		
#入场触发
func enter_buff():
	print("buff管理器的入场函数触发")
	#print("buff_list长度：", buff_list.size())
	for buff_id in buff_list.keys():
		var buff = buff_list[buff_id]
		buff.enter_buff()
		
# 每回合开始时更新Buff
func phase_begin():
	#若不是站场角色，则停止更新
	if not get_parent().is_curr:
		return
	var to_update = []
	for buff_id in buff_list:
		var buff = buff_list[buff_id]
		#判断自己或AI的回合
		if not buff.is_all_phase and get_tree() and get_tree().current_scene:
			if get_parent().is_ai and get_tree().current_scene.curr_phase == "player":
				return
			if not get_parent().is_ai and get_tree().current_scene.curr_phase == "enemy":
				return
		print("buff初始时长：",buff.init_phase_duration)
		print("buff剩余时长：",buff.phase_duration)
		buff.phase_begin()
		buff.phase_duration -= 1
		if buff.phase_duration == 0:
			if buff.current_stacks > 1:  # 多层处理
				buff.current_stacks -= 1
				buff._on_stack_removed(buff.current_stacks)
				buff.phase_duration = buff.init_phase_duration
			else:
				to_update.append(buff_id)
			
	# 移除已结束的BUFF
	for id in to_update:
		remove_buff(id)

# 检测是否存在某个buff
func has_buff(buff_id: String) -> bool:
	return buff_id in buff_list
	
#返回buff层数
func get_buff_stacks(buff_id: String) -> int:
	# 检查Buff是否存在
	if buff_id in buff_list:
		return buff_list[buff_id].current_stacks
	# 不存在时返回0
	return 0

#造成伤害时触发
func to_damage(damage,target,damage_type:String,damage_element:String,is_extra:bool = false,energy = 0,source = get_parent()):
	for buff_id in buff_list:
		var buff = buff_list[buff_id]
		buff.to_damage(damage,target,damage_type,damage_element,is_extra,energy,source)
