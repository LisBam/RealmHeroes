extends character_base

func _ready() -> void:
	super._ready()
	tags.append("亡灵生物")
	skilla_description = "冲向敌人造成致命伤害。对敌人造成600威力的金属性物伤，若你为先手，则额外造成400威力的伤害。"
	skillb_description = "它不是一个人！队伍里每有一只亡灵生物，都会提供持续3轮的20点物攻。该效果不可叠加。"
	skillc_description = "身披坚硬的橄榄球护具，能承受高额伤害。提高60点物抗持续3轮，重复释放可延长持续时间。"
	skilld_description = "先行冲锋，轻而易举地突破防线。对敌人造成200威力的金属性物伤，自身血量每比对方多5点，威力提高1点。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "根据亡灵生物数提升物攻"
	skillc_short_desc = "加双抗"
	skilld_short_desc = "血量越高物伤越高"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	if Global.curr_phase_count % 2 != 0:
		be_and_to_damage(damage(1000,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	else:
		be_and_to_damage(damage(600,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	var putongjiangshi_phy_power = putongjiangshi_phy_power.new()
	putongjiangshi_phy_power.add_count = 0
	putongjiangshi_phy_power.round_duration = 3
	putongjiangshi_phy_power.init_round_duration = 3
	for character in player_team:
		if character and character.has_tag("亡灵生物"):
			putongjiangshi_phy_power.add_count += 20
	player.get_node("buff").add_buff(putongjiangshi_phy_power)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var add = quanmingxingjiangshi_add_phy_def.new()
	add.add_count = 60
	add.round_duration = 3
	add.init_round_duration = 3
	player.get_node("buff").add_buff(add)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var damage = 200
	damage += (max(curr_hp - enemy.curr_hp,0))/5
	be_and_to_damage(damage(damage,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 600
	#若为先手
	if Global.curr_phase_count % 2 != 0:
		ai.skills[1].damage_count += 400
	
	ai.skills[2].buff_value = 0
	for character in player_team:
		if character and character.has_tag("亡灵生物"):
			ai.skills[2].buff_value += 20 * 8 #每点物攻大概8点伤害
	ai.skills[2].buff_duration = 3-1
	if get_node("buff").has_buff("putongjiangshi_phy_power"):
		ai.skills[2].buff_value = 0

	#根据对方物伤占比提供收益
	ai.skills[3].buff_value = 60*8*(enemy.damage_phy_ratio/100.0)
	#先手多生效一回合
	if Global.curr_phase_count % 2 != 0:
		ai.skills[3].buff_duration = 3
	else:
		ai.skills[3].buff_duration = 3-1
	#若已拥有buff则降低收益（能延长时间）
	if get_node("buff").has_buff("quanmingxingjiangshi_add_phy_def"):
		ai.skills[3].buff_value = 60*2*(enemy.damage_phy_ratio/100.0)
	add_damage_element(4,skilld_element)
	var damage = 200
	damage += (max(curr_hp - enemy.curr_hp,0))/5
	ai.skills[4].damage_count = damage
