extends Node

class_name Buff

@export var buff_id: String = "" ## Buff唯一标识
var source: Node = null ##伤害来源
var target: Node = null ## 作用目标节点
@export var max_stacks := 1  ## 最大叠加层数
@export var stack_policy := StackPolicy.RESET_DURATION  ## 堆叠策略
var current_stacks := 1      ## 当前层数
@export var init_round_duration: float = 0 ##buff初始轮次持续时间
@export var init_phase_duration: float = 0 ##buff初始回合持续时间
@export var is_all_phase:bool = false ##是否为所有角色的回合开始

var log:RichTextLabel

# 剩余持续时间
var round_duration: float = 0
var phase_duration: int = 0

# 新增堆叠策略枚举
enum StackPolicy {
	RESET_DURATION,  # 叠加时重置持续时间
	ADD_DURATION,    # 叠加时累加持续时间
	#ADD_EFFECT  # 叠加时增强效果
}

func _init():
	pass

# 层数增加
func _on_stack_increased(new_stacks: int):
	pass
	
# 层数减少
func _on_stack_removed(new_stacks: int):
	pass

# Buff施加时触发
func _on_apply():
	pass

# 每轮开始时触发
func round_start():
	pass

# Buff移除时触发
func _on_remove():
	pass

#入场时触发
func enter_buff():
	pass
	
#回合开始时触发
func phase_begin():
	pass

#造成伤害时触发
func to_damage(func_damage,func_target,damage_type:String,damage_element:String,is_extra:bool = false,energy = 0,func_source = target):
	pass

func addlog(text,is_gray = false):
	target.addlog(text,is_gray)
