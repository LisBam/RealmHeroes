extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "使用藤鞭打击敌人，造成500威力的木属性法伤，然后提高20点法强（至多叠加4层）。"
	skillb_description = "暴力汲取敌人的生机，造成600威力的木属性法伤，然后回复等量的血量。"
	skillc_description = "投掷寄生种子，尝试寄生敌方，90%的概率使对方陷入寄生状态持续5回合。"
	skilld_description = "播撒使人昏睡的催眠粉末，60%的概率使对方陷入睡眠状态。"
	skilla_short_desc = "提高法强 法伤"
	skillb_short_desc = "法伤 回血"
	skillc_short_desc = "寄生"
	skilld_short_desc = "睡眠"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	var add_power = huobaolajiao_add_power.new()
	add_power.add_count = 20
	add_power.max_stacks = 4
	add_power.round_duration = -1
	add_power.init_round_duration = -1
	player.get_node("buff").add_buff(add_power)
	be_and_to_damage(damage(500,"mag",enemy,skilla_element),enemy,player,"mag",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(600,"mag",enemy,skillb_element),enemy,player,"mag",skillb_element)
	recover(damage(600,"mag",enemy,skillb_element))
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var parasitism_probability = 90
	var random = randi_range(1,100)
	if random <= parasitism_probability:
		enemy.parasitism(5,self)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var parasitism_probability = 60
	var random = randi_range(1,100)
	if random <= parasitism_probability:
		enemy.sleep()
	tool_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 500
	ai.skills[1].buff_value = 20 * 3
	ai.skills[1].buff_duration = 8
	var stacks = get_node("buff").get_buff_stacks("huobaolajiao_add_power")
	if stacks >= 4:
		ai.skills[1].buff_value = 0
		ai.skills[1].buff_duration = 1
	
	ai.skills[2].damage_count = 600
	ai.skills[2].recover_hp = damage(800,"mag",enemy,skillb_element)
	
	add_damage_element(3,skilld_element)
	ai.skills[3].parasitism_phase = (5-enemy.parasitism_phase)*0.9;#0.9为寄生概率
	
	var the_sleep_probability = 0.6
	if enemy.sleep_type <=0:
		ai.skills[4].skip_enemy_phase_count = the_sleep_probability*2.6*0.5 #2.6为平均睡眠回合，0.5为平衡系数(不可造成伤害且自身只能放寄生与切换角色）)
	else:
		ai.skills[4].skip_enemy_phase_count = 0;
