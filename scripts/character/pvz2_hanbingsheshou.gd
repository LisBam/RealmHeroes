extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "发射寒冰豌豆攻击对方，造成600威力的水属性法伤，并使目标速度减少3点，该效果最多叠加5层。"
	skillb_description = "进行光合作用，立即恢复10点能量，并回复100点HP。"
	skillc_description = "冰冷气息使敌人举步维艰，30%的概率冻结对方。每层“寒冰豌豆”的减速会使冰冻概率提高5%。"
	skilld_description = "发射锋利的冰锥攻击敌人，造成1000威力的水属性法伤。若目标已被冰冻，则额外提高500点威力。"
	skilla_short_desc = "法伤"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "冰冻"
	skilld_short_desc = "法伤 冰冻增伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(600,"mag",enemy,skilla_element),enemy,player,"mag",skilla_element)
	var reduce_speed = hanbingsheshou_reduce_speed.new()
	reduce_speed.count = 3
	enemy.get_node("buff").add_buff(reduce_speed)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	recover_energy(10)
	recover(100)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var ice_probability = 30 + 5* enemy.get_node("buff").get_buff_stacks("hanbingsheshou_reduce_speed")
	var random = randi_range(1,100)
	if random <= ice_probability:
		addlog(enemy.character_name+"被冰冻了！")
		enemy.ice_stacks += 1
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	if enemy.ice_stacks<=0:
		be_and_to_damage(damage(1000,"mag",enemy,skilld_element),enemy,player,"mag",skilld_element)
	else:
		be_and_to_damage(damage(1500,"mag",enemy,skilld_element),enemy,player,"mag",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 600
	ai.skills[1].debuff_duration = 5
	#对方的减速层数
	var stacks = enemy.get_node("buff").get_buff_stacks("hanbingsheshou_reduce_speed")
	#对方原速度
	var origin_speed = enemy.speed +3*enemy.get_node("buff").get_buff_stacks("hanbingsheshou_reduce_speed")
	#所需层数使自身超过敌方
	var need_stacks = max(ceil((origin_speed - speed)/3), 0)
	#还需要的层数
	var lack_stacks = need_stacks-stacks
	#若可以超过敌方，则增加价值倍率
	#if need_stacks < 5:
		#ai.skills[1].strategy_value_mul = 2
	#if need_stacks == 5:
		#ai.skills[1].strategy_value_mul = 1.3
	#if need_stacks > 5:
		#ai.skills[1].strategy_value_mul = 0.8
	#若减速叠满也不能反超或速度已经反超，则收益降低
	if speed + 3*(5 - enemy.get_node("buff").get_buff_stacks("hanbingsheshou_reduce_speed")) < enemy.speed or speed > enemy.speed:
		ai.skills[1].debuff_value = 100
	else:
		#叠层越高价值越高
		ai.skills[1].debuff_value = 300*(6-lack_stacks)
	#对三技能概率增加的价值
	ai.skills[1].strategy_value_count = 360
	if stacks>=5:
		ai.skills[1].debuff_value = 0
		ai.skills[1].strategy_value_count = 0
		ai.skills[1].debuff_duration = 1
	
	ai.skills[2].recover_hp = 100
	ai.skills[2].recover_energy = 10
	
	var ice_probability = 0.01*(30 + 5* enemy.get_node("buff").get_buff_stacks("hanbingsheshou_reduce_speed"))
	if enemy.ice_stacks <=0:
		ai.skills[3].skip_enemy_phase_count = ice_probability*1.5 #1.5为平均冻结回合，0.5为平衡系数
	elif enemy.ice_stacks >=0:
		ai.skills[3].skip_enemy_phase_count = ice_probability*1.5*(enemy.ice_stacks/10.0)
	if enemy.element == "fire":
		ai.skills[3].skip_enemy_phase_count = 0
	
	add_damage_element(4,skilld_element)
	if enemy.ice_stacks<=0:
		ai.skills[4].damage_count = 1000
	else:
		ai.skills[4].damage_count = 1500
