extends Node
class_name FightingAI

# 收益系数（常量）
const DAMAGE_VALUE = 1.0       # 1伤害的收益
const HEAL_VALUE = 1.0         # 1回血的收益
const SHIELD_VALUE = 1.1       # 1护盾的收益
const ENERGY_VALUE = 5.0      # 1能量的收益
const BUFF_VALUE = 0.8      # 增益收益
const DEBUFF_VALUE = 0.7    # 减益收益
const ENERGY_RESERVE_BONUS = 0.3  # 每点能量储备奖励
const KILL_VALUE = 5.0

#buff_value 按照每回合收益来算，1伤害为1收益，1回血为1.2收益，1盾为1收益，1能量为50收益

#角色参数
var curr_energy :int
var max_energy :int
var curr_hp :int
var max_hp : int
var enemy
var player
var enemy_team
var player_team

var skills = [
	{
		id = "attack",
		energy_cost = 0,
		skill_element = null,
		damage_type = [],
		damage_element = [],
		damage_count = 0,
		damage_times = 1,#伤害段数
		damage_aoe_count = 0,
		damage_aoe_justone_count = 0, #aoe对场上主目标的伤害
		recover_hp = 0,
		recover_shield = 0,
		recover_energy = 10,
		buff_value = 0,
		buff_duration = 1,
		debuff_value = 0,
		debuff_duration = 1,
		can_continue = false,	#发动后不结束回合
		to_die_value = 1,	#自爆技能收益倍率
		strategy_value_mul = 1.0, #战略价值倍率，手动为ai提供策略
		strategy_value_count = 0,
		change_energy = 0, #本次伤害让对方获取的能量改变的值，例如有的不获取能量则为-damage_count/100
		skip_phase_count = 0.0, #跳过回合数
		skip_enemy_phase_count = 0.0, #令对手跳过回合数
		damage_reduction = 0, #免伤值
		damage_reduction_round_duration = 0, #免伤时长
		burning_phase = 0,#灼烧时长
		self_damage_count = 0,#自己受到伤害
		parasitism_phase = 0,#寄生时长
		
		value = 0,
	},
	{
		id = "skilla",
		energy_cost = 0,
		skill_element = null,
		damage_type = [],
		damage_element = [],
		damage_count = 0,
		damage_times = 1,
		damage_aoe_count = 0,
		damage_aoe_justone_count = 0, #aoe对场上主目标的伤害
		recover_hp = 0,
		recover_shield = 0,
		recover_energy = 0,
		buff_value = 0,
		buff_duration = 1,
		debuff_value = 0,
		debuff_duration = 1,
		can_continue = false,	#发动后不结束回合
		to_die_value = 1,	#自爆技能收益倍率
		strategy_value_mul = 1.0, #战略价值倍率，手动为ai提供策略
		strategy_value_count = 0,
		change_energy = 0, #本次伤害让对方获取的能量改变的值，例如有的不获取能量则为-damage_count/100
		skip_phase_count = 0.0, #跳过回合数
		skip_enemy_phase_count = 0.0, #令对手跳过回合数
		damage_reduction = 0, #免伤值
		damage_reduction_round_duration = 0, #免伤时长
		burning_phase = 0,#灼烧时长
		self_damage_count = 0,#自己受到伤害
		parasitism_phase = 0,#寄生时长
		
		value = 0,
	},
	{
		id = "skillb",
		energy_cost = 0,
		skill_element = null,
		damage_type = [],
		damage_element = [],
		damage_count = 0,
		damage_times = 1,
		damage_aoe_count = 0,
		damage_aoe_justone_count = 0,
		recover_hp = 0,
		recover_shield = 0,
		recover_energy = 0,
		buff_value = 0,
		buff_duration = 1,
		debuff_value = 0,
		debuff_duration = 1,
		can_continue = false,
		to_die_value = 1,
		strategy_value_mul = 1.0,
		strategy_value_count = 0,
		change_energy = 0,
		skip_phase_count = 0.0,
		skip_enemy_phase_count = 0.0,
		damage_reduction = 0,
		damage_reduction_round_duration = 0,
		burning_phase = 0,#灼烧时长
		self_damage_count = 0,#自己受到伤害
		parasitism_phase = 0,#寄生时长
		
		value = 0,
	},
	{
		id = "skillc",
		energy_cost = 0,
		skill_element = null,
		damage_type = [],
		damage_element = [],
		damage_count = 0,
		damage_times = 1,
		damage_aoe_count = 0,
		damage_aoe_justone_count = 0,
		recover_hp = 0,
		recover_shield = 0,
		recover_energy = 0,
		buff_value = 0,
		buff_duration = 1,
		debuff_value = 0,
		debuff_duration = 1,
		can_continue = false,
		to_die_value = 1,
		strategy_value_mul = 1.0,
		strategy_value_count = 0,
		change_energy = 0,
		skip_phase_count = 0.0,
		skip_enemy_phase_count = 0.0,
		damage_reduction = 0,
		damage_reduction_round_duration = 0,
		burning_phase = 0,#灼烧时长
		self_damage_count = 0,#自己受到伤害
		parasitism_phase = 0,#寄生时长
		
		value = 0,
	},
	{
		id = "skilld",
		energy_cost = 0,
		skill_element = null,
		damage_type = [],
		damage_element = [],
		damage_count = 0,
		damage_times = 1,
		damage_aoe_count = 0,
		damage_aoe_justone_count = 0,
		recover_hp = 0,
		recover_shield = 0,
		recover_energy = 0,
		buff_value = 0,
		buff_duration = 1,
		debuff_value = 0,
		debuff_duration = 1,
		can_continue = false,
		to_die_value = 1,
		strategy_value_mul = 1.0,
		strategy_value_count = 0,
		change_energy = 0,
		skip_phase_count = 0.0,
		skip_enemy_phase_count = 0.0,
		damage_reduction = 0,
		damage_reduction_round_duration = 0,
		burning_phase = 0,#灼烧时长
		self_damage_count = 0,#自己受到伤害
		parasitism_phase = 0,#寄生时长
		
		value = 0,
	},
]

var enable_skills: Array = []

# 筛选出能量足够发动的技能，加入enable_skills
var is_calculate_refresh_enable_skills = false #防止无限递归
func refresh_enable_skills(add_energy:int = 0):
	if not (enemy and player and enemy_team and player_team):
		return -999
	if is_calculate_refresh_enable_skills:
		return
	is_calculate_refresh_enable_skills = true
	#若为特殊能量角色，则令增加能量参数无效
	if player.is_special_energy:
		add_energy = 0
	enable_skills.clear()  # 先清空现有数据
	for skill in skills:
		skill.value = calculate_value(skill)  # 新增当前价值字段
		# 检查技能能量消耗是否小于等于当前能量
		#add_energy用于判断对手技能时加上本次技能的伤害
		if skill.energy_cost <= (curr_energy + add_energy):
			enable_skills.append(skill)
			
	# 增加对高耗能技能的储存能量机制
	var has_high_value_skill = false
	for skill in skills:
		if skill.energy_cost > curr_energy*1.5 and is_highest_value(skill):
			has_high_value_skill = true
			break
	if has_high_value_skill:
		for skill in enable_skills:
			if skill.energy_cost <= (max_energy * 0.2):
				skill.value *= 1.2  # 低耗技能价值提升
	
	is_calculate_refresh_enable_skills = false
	## 只输出技能id——————————————
	#var skill_ids = []
	#for skill in enable_skills:
		#skill_ids.append(skill.id)  # 收集所有可使用技能的id
	#print("可使用技能id：", skill_ids)  # 输出id列表
	##——————————————————————————

func calculate_value(skill):
	if not (enemy and player and enemy_team and player_team):
		return -999
	var total_value = 0.0
	#伤害价值,乘以伤害段数
	var damage_value = get_final_damage(skill) * skill.damage_times
	#若目标处于睡眠，则降低价值
	if enemy.sleep_type == 1:
		var the_skip_phase_value = 0
		if enemy:#只是保证不为空值
			the_skip_phase_value = skill.skip_phase_count * get_a_phase_value(enemy)
		damage_value -= (enemy.sleep_probability/100.0)*the_skip_phase_value
	#若伤害足以致命，则伤害价值变为目标生命值并乘以击杀价值
	if get_final_damage(skill) >= enemy.curr_hp:
		damage_value = enemy.curr_hp * KILL_VALUE
		#防止生命值过低导致价值过低而不使用伤害技能
		damage_value = max(damage_value,800 * KILL_VALUE)
		#若目标有致命伤害保留1点HP,则不计算击杀价值
		if enemy.not_die_to_one_hp:
			damage_value = enemy.curr_hp
	#若目标拥有卖血收益，则降低伤害价值
	if enemy.be_damage_to_benefit_mul > 1:
		#若伤害足以致命，且目标没有锁血，则无视卖血
		if get_final_damage(skill) >= enemy.curr_hp and not enemy.not_die_to_one_hp:
			damage_value *= 1/enemy.be_damage_to_benefit_mul
	#根据嘲讽值提高伤害价值
	damage_value *= enemy.taunt_value
	
	#将最终伤害乘以伤害价值
	total_value += damage_value * DAMAGE_VALUE
	#aoe收益(比单体价值略高),乘以伤害段数
	total_value += get_final_damage(skill,skill.damage_aoe_count) * skill.damage_times * 1.1 * DAMAGE_VALUE
	#治疗收益
	var lost_hp = max_hp - curr_hp
	var recover_hp_value = min(skill.recover_hp,lost_hp)
	total_value += recover_hp_value * HEAL_VALUE
	#护盾收益
	#根据对方真伤占比减少护盾收益
	total_value += skill.recover_shield * SHIELD_VALUE * (1-(enemy.damage_real_ratio/100))
	#能量恢复收益
	var energy_ratio = float(curr_energy) / max_energy #能量紧缺度
	var new_ENERGY_VALUE = (ENERGY_VALUE*(1.5 - energy_ratio))
	var lost_energy = max_energy - curr_energy
	var recover_energy_value = min(skill.recover_energy,lost_energy)
	total_value += recover_energy_value * new_ENERGY_VALUE
	#能量成本
	total_value -= skill.energy_cost * new_ENERGY_VALUE
	#灼烧收益
	total_value += skill.burning_phase * player.damage(player.magical_power,"mag",enemy,"fire",false) * 0.85#灼烧延迟伤害收益打折
	#自己掉血成本
	total_value -=  player.damage(skill.self_damage_count,"mag",player,"fire",false)
	#寄生收益，简单地将回血并入伤害收益了
	total_value += skill.parasitism_phase * player.damage(player.physical_power*1.6,"phy",enemy,"wood",false) * 0.85#延迟收益打折
	total_value += skill.parasitism_phase * 4 * 0.85#能量收益，延迟收益打折
	#buff收益
	if not enemy.be_damage_to_benefit_mul > 1:
		#增益收益
		total_value += skill.buff_value * skill.buff_duration * BUFF_VALUE
		#减益收益
		total_value += skill.debuff_value * skill.debuff_duration * DEBUFF_VALUE
	#如果对方有卖血技能，则增益与减益的价值提高
	else:
		total_value += 1.2 * skill.buff_value * skill.buff_duration * BUFF_VALUE
		total_value += 1.2 * skill.debuff_value * skill.debuff_duration * DEBUFF_VALUE
	
	#战略价值
	total_value += skill.strategy_value_count
	
	#减少跳过回合的收益
	if player:#只是保证不为空值
		total_value -= skill.skip_phase_count * get_a_phase_value(player)
	
	#增加令对手跳过回合的收益
	if enemy:#只是保证不为空值
		total_value += skill.skip_enemy_phase_count * get_a_phase_value(enemy)
	
	#增加免伤收益：对方最大可能伤害可被免伤的伤害值*可能被攻击的次数（减去跳过回合）
	#减少的伤害值
	var reduction_count = enemy.ai.get_enable_max_damage()*(skill.damage_reduction/100.0)
	var enable_phase = skill.damage_reduction_round_duration
	if enemy.skip_next_phase:
		enable_phase -= 1
	if (player.speed < enemy.speed) :
		enable_phase -= 1
	#如果当前为偶数回合，那么是后手，持续回合-1
	if (player.speed == enemy.speed) and Global.curr_phase_count%2 == 0:
		enable_phase -= 1
	total_value += reduction_count*enable_phase
	
	# 新增能量储备奖励（剩余能量越多奖励越高）
	var remaining_energy = (curr_energy + skill.recover_energy) - skill.energy_cost
	total_value += remaining_energy * ENERGY_RESERVE_BONUS * new_ENERGY_VALUE
	
	# 新增能量消耗惩罚（按消耗比例计算）
	var energy_consume_ratio = skill.energy_cost / max_energy
	total_value *= 1.0 - (energy_consume_ratio * 0.2)  # 最高20%的消耗惩罚
	
	# 预测后续回合价值
	if remaining_energy >= (max_energy * 0.6):
		total_value *= 1.2  # 保留充足能量时的收益加成
	
	total_value *= skill.strategy_value_mul
	
	#连续发动类技能
	if skill.can_continue:
		total_value *= curr_energy/skill.energy_cost
	
	#死亡价值
	total_value *= skill.to_die_value
	
	#若本次伤害将解锁对方足以杀死自己的技能，则减低技能价值
	if not enemy.is_special_energy:
		for a_skill in enemy.ai.skills:
			if a_skill.energy_cost < enemy.curr_energy:
				if get_final_damage(a_skill) >= player.curr_hp:
					for has_skill in skills:
						if enemy.curr_energy+(get_final_damage(has_skill)/100 - has_skill.change_energy)>=a_skill.energy_cost:
							#但如果这次伤害足够击杀目标，则无视风险，提高收益
							if not get_final_damage(has_skill) >= enemy.curr_hp:
								has_skill.value *= 0.4
							else:
								has_skill.value *= 1.2
	
	return total_value

# 从可用技能中选择价值最高的技能
func choose_skill():
	if enable_skills.size() == 0:
		return 0
		
	var best_skill = enable_skills[0]
	var max_value = best_skill.value
	
	for skill in enable_skills:
		if skill.value > max_value:
			max_value = skill.value
			best_skill = skill
			
	#输出可发动技能的技能价值
	for skill in skills:
		if skill in enable_skills:
			print(skill.id,"技能价值：",skill.value)
		else:
			print(skill.id,"技能价值：",skill.value,"，能量不足！")
	
	#若最终得出的价值小于普攻，则输出普攻
	#if best_skill.value < 5*ENERGY_VALUE + 120:
		#return	"attack"
	#若得出结果小于切换角色，则切换角色
	if best_skill.value < change_character_value():
		print("AI被克制，切换角色！")
		return	"change_character"
	
	return best_skill

# 读取可用技能中最高伤害的值
func get_enable_max_damage(add_energy:int = 0):
	refresh_enable_skills(add_energy)
	if enable_skills.size() == 0:
		return 0  # 没有可用技能时返回0
	var max_damage = 0.0
	for skill in enable_skills:
		var total_damage = max(get_final_damage(skill) * DAMAGE_VALUE,get_final_damage(skill,skill.damage_aoe_justone_count) * DAMAGE_VALUE)
		if total_damage > max_damage:
			max_damage = total_damage
	return max_damage
	
# 读取所有技能中最高伤害的技能
func get_max_damage_skill():
	if skills.size() == 0:
		printerr("读取最高伤害的技能时，目标没有技能！")
		return null  # 没有可用技能时返回0
	var max_damage = 0.0
	var max_damage_skill = skills[0]
	for skill in skills:
		var total_damage = max(get_final_damage(skill) * DAMAGE_VALUE,get_final_damage(skill,skill.damage_aoe_justone_count) * DAMAGE_VALUE)
		if total_damage > max_damage:
			max_damage = total_damage
			max_damage_skill = skill
	#print("伤害最高的技能为",max_damage_skill.id)
	return max_damage_skill

func is_highest_value(skill):
	for have_skill in skills:
		if have_skill.value > skill.value:
			return false
	return true

#若伤害低于aoe对主目标的伤害，则视为为主目标伤害。
func get_final_damage(skill,damage_count = max(skill.damage_count,skill.damage_aoe_justone_count)):
	if not (enemy and player and enemy_team and player_team):
		return 0
	#return damage_count
	var final_damage = 0
	for element in skill.damage_element:
		for type in skill.damage_type:
			var has_damage = player.damage(damage_count,type,enemy,element,false)
			#printerr(damage_count,"最终计算数值为",has_damage)
			if final_damage < has_damage:
				final_damage = has_damage
			#printerr(damage_count,"最终计算数值为",has_damage,"返回值为",final_damage)
	return final_damage

#计算切换角色价值
func change_character_value():
	if not (enemy and player and enemy_team and player_team):
		return -999
	if player_team:
		if player_team.size() <= 1:
			return -999
	var value = -9999
	#在被克制时才思考切换角色
	if player.get_element_multiplier(player.element,enemy.element) < 1:
		print("思考得出：AI被克制")
		#根据队友中是否存在克制提高价值
		var a_character_value
		for has_character in player_team:
			a_character_value = 0
			#若为站场角色，不计算
			if has_character.is_curr:
				continue
			if not has_character.is_die:
				if has_character.get_element_multiplier(has_character.element,enemy.element) == 1:
					a_character_value += 700
					#根据角色血量的降低减少价值
					a_character_value *= has_character.curr_hp / has_character.max_hp
				elif has_character.get_element_multiplier(has_character.element,enemy.element) > 1:
					a_character_value += 1200
					a_character_value *= has_character.curr_hp / has_character.max_hp
				#若对方出现过克制角色，则降低价值
				for appear_character in enemy_team:
					if not appear_character.is_die:
						if appear_character.have_appear:
							if appear_character.get_element_multiplier(appear_character.element,has_character.element) == 1:
								a_character_value -= 100
							elif appear_character.get_element_multiplier(appear_character.element,has_character.element) > 1:
								a_character_value -= 600
			if a_character_value > value:
				value = a_character_value
	print("切换角色的价值为：",value)
	return value

#计算一个回合所有可用技能的平均收益，用于得出跳过回合的收益
func get_a_phase_value(who):
	refresh_enable_skills(10)
	var first_value = -999
	var second_value = -999
	for skill in who.ai.enable_skills:
		if skill.value > first_value:
			second_value = first_value
			first_value = skill.value
		elif skill.value > second_value:
			second_value = skill.value
	#若价值差值过大则只计算首个
	if first_value/max(second_value,1) >= 2:
		second_value = first_value
		
	return ((first_value+second_value)/2)
