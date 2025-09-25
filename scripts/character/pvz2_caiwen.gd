extends character_base

func _ready() -> void:
	super._ready()
	tags.append("植物")
	skilla_description = "菜问重拳出击，狠狠攻击敌方，造成1000威力的木属性物伤。"
	skillb_description = "菜问强健体魄，提高20点物攻以及20点物抗，该效果最多叠加6层。"
	skillc_description = "菜问对奄奄一息的目标使出强力一击，造成500威力的木属性物伤，并有15%的概率使目标陷入晕眩持续1回合。若目标当前血量低于其已损失血量，则威力与晕眩概率均翻倍。"
	skilld_description = "菜问使出致命一击，造成1250威力的木属性物伤，对场下的所有敌方造成150威力的木属性物伤。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "提高物抗物攻"
	skillc_short_desc = "物伤 晕眩"
	skilld_short_desc = "群体物伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1000,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	var add_buff = caiwen_add_buff.new()
	add_buff.round_duration = -1
	add_buff.init_round_duration = -1
	player.get_node("buff").add_buff(add_buff)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team);
	var skillc_damage = 500;
	var stun_probability = 15;
	if enemy.curr_hp < (enemy.max_hp - enemy.curr_hp):
		skillc_damage = 1000;
		stun_probability = 30;
	be_and_to_damage(damage(skillc_damage,"phy",enemy,skilla_element),enemy,player,"phy",skillc_element);
	var random = randi_range(1,100);
	if random <= stun_probability:
		addlog(enemy.character_name+"被晕眩了！")
		enemy.stun_stacks += 1;
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1250,"phy",enemy,skillc_element),enemy,player,"phy",skilld_element)
	for character in enemy_team:
		if character and not character.is_die and character != enemy:
			be_and_to_damage(damage(150,"phy",character,skillc_element),character,player,"phy",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 1000
	
	ai.skills[2].buff_value = 20 * 10 + 20 * 10
	ai.skills[2].buff_duration = 7
	var stacks = get_node("buff").get_buff_stacks("caiwen_add_buff")
	if stacks >= 6:
		ai.skills[2].buff_value = 0
		ai.skills[2].buff_duration = 1
	
	add_damage_element(3,skillc_element)
	var stun_probability = 15;
	var skillc_damage = 500;
	if enemy.curr_hp < (enemy.max_hp - enemy.curr_hp):
		stun_probability = 30;
		skillc_damage = 1000;
	ai.skills[3].skip_enemy_phase_count = 1*(float(stun_probability)/100)
	ai.skills[3].damage_count = skillc_damage
	
	add_damage_element(4,skillc_element)
	ai.skills[4].damage_aoe_count = 150 * enemy_team.size()-1
	ai.skills[4].damage_aoe_justone_count = 1250
