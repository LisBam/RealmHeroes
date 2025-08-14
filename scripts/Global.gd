extends Node

@export var team_character_1_scene:PackedScene = load(AllCharacter.pvz2_fuqianjiangshi)
@export var team_character_2_scene:PackedScene = load(AllCharacter.pvz2_xiangrikui)
@export var team_character_3_scene:PackedScene = load(AllCharacter.pvz2_huobaolajiao)
@export var team_character_4_scene:PackedScene = load(AllCharacter.pvz2_dubaojiangshi)

@export var enemy_character_1_scene:PackedScene = load(AllCharacter.pvz2_wandousheshou)
@export var enemy_character_2_scene:PackedScene = load(AllCharacter.pvz2_jianguo)
@export var enemy_character_3_scene:PackedScene = load(AllCharacter.pvz2_wandousheshou)
@export var enemy_character_4_scene:PackedScene = load(AllCharacter.pvz2_huobaolajiao)

#播放动画时长
var playing_animation_time:float = 0.0

#回合数与轮次
var curr_phase_count:int
var curr_round_count:int

#局内技能描述
var fighting_skilla_description:String = "暂未获取技能一局内描述"
var fighting_skillb_description:String = "暂未获取技能二局内描述"
var fighting_skillc_description:String = "暂未获取技能三局内描述"
var fighting_skilld_description:String = "暂未获取技能四局内描述"

func _process(delta: float):
	if playing_animation_time >0:
		playing_animation_time -= delta
	
#随机配置敌人
func set_random_enemy():
	enemy_character_1_scene = load(AllCharacter.get_random_character())
	enemy_character_2_scene = load(AllCharacter.get_random_character())
	enemy_character_3_scene = load(AllCharacter.get_random_character())
	enemy_character_4_scene = load(AllCharacter.get_random_character())

#随机配置己方阵容
func set_random_team():
	team_character_1_scene = load(AllCharacter.get_random_character())
	team_character_2_scene = load(AllCharacter.get_random_character())
	team_character_3_scene = load(AllCharacter.get_random_character())
	team_character_4_scene = load(AllCharacter.get_random_character())
