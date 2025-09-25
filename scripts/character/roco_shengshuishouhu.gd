extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "施展缓冲，稳步攻击敌方，造成600威力的水属性物伤，有70%概率提高30点物抗与法抗（至多叠加4层）。"
	skillb_description = "施展水之护盾，保护自身，释放后的5轮内，每轮开始时，获得200点护盾并回复10点能量。"
	skillc_description = "驾驭狂暴水元素，吞噬敌方，有50%概率造成1400威力的水属性物伤。"
	skilld_description = "召唤祭祀之雨袭击敌方，造成1800威力的水属性法伤。"
	skilla_short_desc = "物伤 提高双抗"
	skillb_short_desc = "持续护盾"
	skillc_short_desc = "物伤"
	skilld_short_desc = "高额法伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(600,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	var buff_probability = 70;
	var random = randi_range(1,100);
	if random <= buff_probability:
		var add_buff = shengshuishouhu_add_buff.new()
		add_buff.add_count = 30
		add_buff.max_stacks = 4
		add_buff.round_duration = -1
		add_buff.init_round_duration = -1
		player.get_node("buff").add_buff(add_buff)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	var mark = shengshuishouhu_skillb_mark.new()
	mark.count = 200
	mark.round_duration = 5
	mark.init_round_duration = 5
	mark.source = player
	player.get_node("buff").add_buff(mark)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var probability = 50;
	var random = randi_range(1,100);
	if random <= probability:
		be_and_to_damage(damage(1400,"phy",enemy,skillc_element),enemy,player,"phy",skillc_element)
		attack_skill_animation()
	else:
		tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1800,"mag",enemy,skilld_element),enemy,player,"mag",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 600
	ai.skills[1].buff_value = 30 * 12
	ai.skills[1].buff_duration = 7
	var stacks = get_node("buff").get_buff_stacks("shengshuishouhu_add_buff")
	if stacks >= 4:
		ai.skills[1].buff_value = 0
		ai.skills[1].buff_duration = 1
	
	add_damage_element(2,skillb_element)
	ai.skills[2].recover_shield = 1000
	ai.skills[2].recover_energy = 50
	ai.skills[2].strategy_value_count = -210 #不是一次性，价值打折
	if enemy.get_node("buff").has_buff("shengshuishouhu_skillb_mark"):
		ai.skills[2].recover_shield = 200
		ai.skills[2].strategy_value_count = 0
	
	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 1400
	ai.skills[3].strategy_value_count = -700
	
	add_damage_element(4,skilld_element)
	ai.skills[4].damage_count = 1800
