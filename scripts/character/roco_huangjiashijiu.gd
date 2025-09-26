extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "狮鹫御风打击敌方，造成600威力的水属性法伤，然后提高40点法强（至多叠加4层）。"
	skillb_description = "强大的魔法攻击，附带随机效果。造成固定（400+法强*2）点水属性真伤，并有40%概率对目标施加一层冰冻、一回合晕眩或者三回合灼烧状态。"
	skillc_description = "狮鹫跃起至高处，俯冲袭击敌方。本回合获得100%免伤，并于你的下回合开始时跳过回合并造成1600威力的水属性法伤。"
	skilld_description = "飓风的力量，对流体效果显著。造成600威力的水属性法伤，若目标为水属性，则威力翻倍。"
	skilla_short_desc = "法伤 提高法强"
	skillb_short_desc = "固定真伤 随机效果"
	skillc_short_desc = "无敌 法伤"
	skilld_short_desc = "法伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(600,"mag",enemy,skilla_element),enemy,player,"mag",skilla_element)
	var add_power = huobaolajiao_add_power.new()
	add_power.add_count = 40;
	add_power.max_stacks = 4;
	add_power.round_duration = -1;
	add_power.init_round_duration = -1;
	player.get_node("buff").add_buff(add_power)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team);
	var real_damage = 400 + (magical_power*2);
	be_and_to_damage(real_damage,enemy,player,"real",skillb_element);
	var probability = 40;
	var random = randi_range(1,100);
	if random <= probability:
		var buff = randi_range(1,3);
		if buff == 1:
			addlog(enemy.character_name+"被冰冻了！")
			enemy.ice_stacks += 1
		elif buff == 2:
			enemy.burn(3,self)
		elif buff == 3:
			addlog(enemy.character_name+"被晕眩了！")
			enemy.stun_stacks += 1;
	attack_skill_animation();
	Signals.to_next_phase.emit();
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var mark = huangjiashijiu_skillc_mark.new()
	mark.add_count = 100
	mark.damage = 1600
	mark.source = player
	mark.target = enemy
	mark.phase_duration = 1
	mark.init_phase_duration = 1
	player.get_node("buff").add_buff(mark)
	player.skip_next_phase = true
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var final_damage = 600;
	if enemy.element == "water":
		final_damage *= 2;
	be_and_to_damage(damage(final_damage,"mag",enemy,skilld_element),enemy,player,"mag",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skillc_element)
	ai.skills[1].damage_count = 600
	ai.skills[1].buff_value = 40 * 5.5
	ai.skills[1].buff_duration = 5
	var stacks = get_node("buff").get_buff_stacks("huobaolajiao_add_power")
	if stacks >= 4:
		ai.skills[1].buff_value = 0
		ai.skills[1].buff_duration = 1
		
	add_damage_element(2,skillc_element)
	ai.skills[2].let_lose_hp_count = 400+(magical_power*2)
	#冰冻价值
	if enemy.ice_stacks <=0:
		ai.skills[2].skip_enemy_phase_count = 1*0.4*0.33
	elif enemy.ice_stacks >=0:
		ai.skills[2].skip_enemy_phase_count = 1*0.4*0.33*(enemy.ice_stacks/10.0)
	if enemy.element == "fire":
		ai.skills[2].skip_enemy_phase_count = 0
	#晕眩价值
	ai.skills[2].skip_enemy_phase_count += 1*0.4*0.33
	#灼烧价值
	ai.skills[2].burning_phase = (3-enemy.burning_phase)*0.4*0.33;
	
	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 1600
	ai.skills[3].skip_phase_count = 1
	if not get_node("buff").has_buff("huangjiashijiu_skillc_mark"):
		ai.skills[3].buff_duration = 1
		ai.skills[3].damage_reduction = 100
		ai.skills[3].damage_reduction_phase_duration = 1 
	else:
		ai.skills[3].buff_duration = 0
		ai.skills[3].damage_reduction = 0
		ai.skills[3].damage_reduction_phase_duration = 0
		
	add_damage_element(4,skilld_element)
	ai.skills[4].damage_count = 600;
	if enemy.element == "water":
		ai.skills[4].damage_count *= 2;
