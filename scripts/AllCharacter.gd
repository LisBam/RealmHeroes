extends Node

#定义所有路径

#region PVZ2
#pvz植物
const pvz2_wandousheshou = "res://scenes/character/pvz2_wandousheshou.tscn"
const pvz2_xiangrikui = "res://scenes/character/pvz2_xiangrikui.tscn"
const pvz2_jianguo = "res://scenes/character/pvz2_jianguo.tscn"
const pvz2_huobaolajiao = "res://scenes/character/pvz2_huobaolajiao.tscn"
const pvz2_hanbingsheshou = "res://scenes/character/pvz2_hanbingsheshou.tscn"
const pvz2_caiwen = "res://scenes/character/pvz2_caiwen.tscn"
const pvz2_huojvshuzhuang = "res://scenes/character/pvz2_huojvshuzhuang.tscn"
#pvz僵尸
const pvz2_putongjiangshi = "res://scenes/character/pvz2_putongjiangshi.tscn"
const pvz2_dubaojiangshi = "res://scenes/character/pvz2_dubaojiangshi.tscn"
const pvz2_fuqianjiangshi = "res://scenes/character/pvz2_fuqianjiangshi.tscn"
const pvz2_quanmingxingjiangshi = "res://scenes/character/pvz2_quanmingxingjiangshi.tscn"
const pvz2_xiaoguijiangshi = "res://scenes/character/pvz2_xiaoguijiangshi.tscn"
#洛克王国
const roco_liehuozhanshen = "res://scenes/character/roco_liehuozhanshen.tscn"
const roco_wudoukumao = "res://scenes/character/roco_wudoukumao.tscn"
const roco_shengshuishouhu = "res://scenes/character/roco_shengshuishouhu.tscn"
const roco_paersasi = "res://scenes/character/roco_paersasi.tscn"
const roco_huangjiashijiu = "res://scenes/character/roco_huangjiashijiu.tscn"

#endregion

#可随机到的角色场景路径
var can_random_character = [
	pvz2_wandousheshou,
	pvz2_xiangrikui,
	pvz2_jianguo,
	pvz2_huobaolajiao,
	pvz2_putongjiangshi,
	pvz2_dubaojiangshi,
	pvz2_fuqianjiangshi,
	pvz2_quanmingxingjiangshi,
	pvz2_hanbingsheshou,
	pvz2_xiaoguijiangshi,
	pvz2_caiwen,
	roco_liehuozhanshen,
	roco_wudoukumao,
	roco_shengshuishouhu,
	roco_paersasi,
	roco_huangjiashijiu,
	pvz2_huojvshuzhuang,
]

#获取随机一个角色的场景路径
func get_random_character():
	var random_index = randi_range(0,can_random_character.size()-1)
	return can_random_character[random_index]
