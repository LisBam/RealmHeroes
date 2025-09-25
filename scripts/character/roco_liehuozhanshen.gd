extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "迸发魔焰，提高40点法强（至多叠加四层），然后造成300威力的火属性法伤。"
	skillb_description = "冲向敌人发起自爆式袭击。有30%的概率使敌方陷入灼烧状态持续3回合，造成800威力的火属性法伤，该伤害的10%会反弹给自己。"
	skillc_description = "向敌人投掷热力爆弹，有60%的概率使敌方陷入灼烧状态持续3回合，然后造成500威力的火属性法伤。"
	skilld_description = "划破空气攻击敌人，有20%的概率使敌方陷入晕眩持续1回合，然后造成500威力的火属性法伤。"
	skilla_short_desc = "提高法强 法伤"
	skillb_short_desc = "灼烧 法伤"
	skillc_short_desc = "灼烧 法伤"
	skilld_short_desc = "晕眩 法伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	var add_power = huobaolajiao_add_power.new()
	add_power.add_count = 40
	add_power.max_stacks = 4
	add_power.round_duration = -1
	add_power.init_round_duration = -1
	player.get_node("buff").add_buff(add_power)
	be_and_to_damage(damage(300,"mag",enemy,skilla_element),enemy,player,"mag",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	var burn_probability = 30;
	var random = randi_range(1,100);
	if random <= burn_probability:
		enemy.burn(3,self)
	be_and_to_damage(damage(800,"mag",enemy,skillb_element)*0.9,enemy,player,"mag",skillb_element)
	be_and_to_damage(damage(800,"mag",enemy,skillb_element)*0.1,player,player,"mag",skillb_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var burn_probability = 60;
	var random = randi_range(1,100);
	if random <= burn_probability:
		enemy.burn(3,self)
	be_and_to_damage(damage(500,"mag",enemy,skillb_element),enemy,player,"mag",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var stun_probability = 20;
	var random = randi_range(1,100);
	if random <= stun_probability:
		addlog(enemy.character_name+"被晕眩了！")
		enemy.stun_stacks += 1;
	be_and_to_damage(damage(500,"mag",enemy,skilld_element),enemy,player,"mag",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 300
	ai.skills[1].buff_value = 40 * 3
	ai.skills[1].buff_duration = 6
	var stacks = get_node("buff").get_buff_stacks("huobaolajiao_add_power")
	if stacks >= 4:
		ai.skills[1].buff_value = 0
		ai.skills[1].buff_duration = 1
	
	add_damage_element(2,skillb_element)
	ai.skills[2].damage_count = 720
	ai.skills[2].burning_phase = (3-enemy.burning_phase)*0.3;
	ai.skills[2].self_damage_count = 80
	
	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 500
	ai.skills[3].burning_phase = (3-enemy.burning_phase)*0.6;
	
	add_damage_element(4,skilld_element)
	ai.skills[4].damage_count = 500
	ai.skills[4].skip_enemy_phase_count = 1*0.2
