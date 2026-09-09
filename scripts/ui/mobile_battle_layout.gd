## 手机战斗界面的响应式布局组件。
##
## 本组件只负责视觉节点的重排与战斗记录视图切换，不处理伤害、回合或按钮业务逻辑。
## 将其作为战斗场景根节点的子节点使用，并把 ui_root_path 指向战斗 UI 的根 Control。
class_name MobileBattleLayout
extends Node


## 当在编辑器或桌面端调试手机布局时设为 true；正式版本会自动依据 mobile 特性启用。
@export var force_mobile_ui: bool = false
## 战斗显示区占纵向可用高度的比例；其余空间留给技能与底部操作按钮。
@export_range(0.42, 0.68, 0.01) var battle_area_height_ratio: float = 0.52
## UI 两侧与上下边缘的内边距比例；比例布局能同时覆盖常规手机和高屏占比机型。
@export_range(0.015, 0.08, 0.005) var screen_padding_ratio: float = 0.032
## 技能格之间的间距比例，避免单手触控时误触相邻技能。
@export_range(0.01, 0.06, 0.005) var control_gap_ratio: float = 0.022
## 底部五个操作按钮占用的高度比例；实际值会被最小值限制以保证触控面积。
@export_range(0.055, 0.13, 0.005) var bottom_action_height_ratio: float = 0.078
## 移动端角色卡牌相对于屏幕宽度的基础缩放系数。
@export_range(0.3, 1.2, 0.01) var character_scale_ratio: float = 0.85
## 移动端 HUD 相对于 1280 设计宽度的缩放系数上限，避免超大屏幕的血条过宽。
@export_range(0.7, 1.4, 0.01) var hud_scale_maximum: float = 1.15
## 本组件所属战斗场景的 UI 根节点路径；该节点必须覆盖整个可视区域。
@export var ui_root_path: NodePath
## 战斗背景 Sprite2D 的路径；背景会被缩放到完整的竖屏区域。
@export var background_path: NodePath

## 供战斗控制器监听：重新布局后需把实际角色 Sprite 同步到新的占位位置。
signal battle_layout_changed

## 当前是否已经启用手机竖屏布局；桌面端始终为 false。
var mobile_ui_active: bool = false
## 当前战斗显示区是否替换为战斗记录；仅在手机布局启用时有意义。
var battle_log_visible: bool = false
## UI 根节点的缓存，避免每次窗口尺寸变化时重复解析 NodePath。
var ui_root: Control
## 战斗背景节点的缓存，用于在移动端填满屏幕。
var battle_background: Sprite2D


func _ready() -> void:
	ui_root = get_node_or_null(ui_root_path) as Control
	battle_background = get_node_or_null(background_path) as Sprite2D
	if ui_root == null:
		push_error("MobileBattleLayout 未找到 ui_root_path 指向的 Control 节点。")
		return
	ui_root.resized.connect(_on_ui_root_resized)
	apply_layout()
	call_deferred("apply_layout")


## 根据设备特性与当前屏幕方向决定是否启用手机专属布局。
## 设备必须是 mobile 平台且处于竖屏，避免平板横屏错误套用手机操作区。
func should_use_mobile_ui() -> bool:
	# 当前可用画布尺寸用于区分竖屏与横屏设备。
	var viewport_size := _get_ui_size()
	# 同时兼容 Godot mobile 特性标签与 Android、iOS 平台名称，避免自定义导出特性遗漏标签。
	var is_mobile_platform := OS.has_feature("mobile") or OS.get_name() == "Android" or OS.get_name() == "iOS"
	if force_mobile_ui:
		return true
	return is_mobile_platform and viewport_size.y > viewport_size.x


## 重新计算所有移动端节点的位置与尺寸；窗口尺寸变化时可安全重复调用。
func apply_layout() -> void:
	if ui_root == null:
		return
	mobile_ui_active = should_use_mobile_ui()
	if not mobile_ui_active:
		return
	# 当前可用画布尺寸是全部比例计算的基准。
	var viewport_size := _get_ui_size()
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	# 系统安全区域会避开打孔摄像头、状态栏和手势导航区，背景仍会铺满完整屏幕。
	var safe_content_rect := _get_safe_content_rect(viewport_size)
	# 战斗区域的底边纵坐标，同时也是操作区域的起点。
	var battle_height := safe_content_rect.position.y + safe_content_rect.size.y * battle_area_height_ratio
	# 统一的屏幕内边距，避免控件贴近圆角与边缘。
	var padding := maxf(safe_content_rect.size.x * screen_padding_ratio, 12.0)
	# 相邻控件的最小间距，防止触控区域相连。
	var gap := maxf(safe_content_rect.size.x * control_gap_ratio, 8.0)
	_layout_background(viewport_size)
	_layout_battle_separator(viewport_size, battle_height)
	_layout_combat_visuals(safe_content_rect, battle_height, padding)
	_layout_skill_buttons(safe_content_rect, battle_height, padding, gap)
	_layout_character_selectors(safe_content_rect, battle_height, padding, gap)
	_layout_bottom_actions(safe_content_rect, padding, gap)
	_layout_battle_log(safe_content_rect, battle_height, padding)
	set_battle_log_visible(battle_log_visible)
	battle_layout_changed.emit()


## 返回当前 UI 的逻辑尺寸。Control 尚未完成布局时改用 Viewport 可视矩形作为后备。
func _get_ui_size() -> Vector2:
	if ui_root != null and ui_root.size.x > 0.0 and ui_root.size.y > 0.0:
		return ui_root.size
	return get_viewport().get_visible_rect().size


## 将 Android/iOS 返回的物理像素安全区域映射为当前逻辑画布坐标。
## 非移动端或读取到异常尺寸时，回退到完整画布，保证编辑器预览不受影响。
func _get_safe_content_rect(viewport_size: Vector2) -> Rect2:
	# 系统报告的无遮挡显示区域，单位为物理像素。
	var display_safe_area := DisplayServer.get_display_safe_area()
	# 当前屏幕物理像素尺寸，用于将安全区域转换到逻辑画布。
	var display_size := DisplayServer.screen_get_size()
	if display_safe_area.size.x <= 0 or display_safe_area.size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	if display_size.x <= 0 or display_size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	# 物理像素到逻辑画布的横纵缩放比例。
	var display_to_viewport_scale := Vector2(viewport_size.x / float(display_size.x), viewport_size.y / float(display_size.y))
	# 映射后的安全区域左上角。
	var safe_position := Vector2(display_safe_area.position.x, display_safe_area.position.y) * display_to_viewport_scale
	# 映射后的安全区域宽高。
	var safe_size := Vector2(display_safe_area.size.x, display_safe_area.size.y) * display_to_viewport_scale
	# 与当前画布相交后的有效安全区域，避免多窗口环境的越界坐标。
	var safe_content_rect := Rect2(safe_position, safe_size).intersection(Rect2(Vector2.ZERO, viewport_size))
	if safe_content_rect.size.x < viewport_size.x * 0.5 or safe_content_rect.size.y < viewport_size.y * 0.5:
		return Rect2(Vector2.ZERO, viewport_size)
	return safe_content_rect


## 把背景按“覆盖”方式铺满竖屏窗口，避免高比例屏幕出现黑边或空白区域。
func _layout_background(viewport_size: Vector2) -> void:
	if battle_background == null or battle_background.texture == null:
		return
	# 背景原始纹理尺寸用于计算覆盖全屏所需的缩放。
	var texture_size := battle_background.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	# 覆盖缩放比例取横纵两个方向中较大的值，以消除空白边缘。
	var cover_scale := maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	battle_background.position = viewport_size * 0.5
	battle_background.scale = Vector2.ONE * cover_scale


## 显示战斗区与操作区之间的分隔线，使上下两个区域在深色背景中保持清晰层次。
func _layout_battle_separator(viewport_size: Vector2, battle_height: float) -> void:
	# 上下区域间的细分隔线节点。
	var separator := ui_root.get_node_or_null("mobile_battle_separator") as ColorRect
	if separator == null:
		return
	separator.visible = true
	separator.position = Vector2(0.0, battle_height - 1.0)
	separator.size = Vector2(viewport_size.x, 2.0)
	# 下半部操作区的深色背景节点。
	var operation_background := ui_root.get_node_or_null("mobile_operation_background") as ColorRect
	if operation_background != null:
		operation_background.visible = true
		operation_background.position = Vector2(0.0, battle_height)
		operation_background.size = Vector2(viewport_size.x, viewport_size.y - battle_height)


## 重排角色、HUD 与回合信息：敌方位于右上、我方位于左下，HUD 则对角摆放。
func _layout_combat_visuals(safe_content_rect: Rect2, battle_height: float, padding: float) -> void:
	# 角色卡牌缩放会随屏幕宽度变化，并限制在可读范围内。
	var character_scale := clampf(safe_content_rect.size.x / 1280.0 * character_scale_ratio, 0.48, 0.9)
	# 卡牌半尺寸用于把中心点精确放入左右对角的位置。
	var card_half_size := Vector2(310.0, 410.0) * character_scale * 0.5
	# 我方角色的布局占位 Sprite，战斗控制器会将其数据同步给实际角色。
	var player_placeholder := ui_root.get_node_or_null("player_sprite") as Sprite2D
	# 敌方角色的布局占位 Sprite，战斗控制器会将其数据同步给实际角色。
	var enemy_placeholder := ui_root.get_node_or_null("enemy_sprite") as Sprite2D
	if player_placeholder != null:
		player_placeholder.scale = Vector2.ONE * character_scale
		player_placeholder.position = Vector2(safe_content_rect.position.x + padding + card_half_size.x, battle_height - padding - card_half_size.y)
	if enemy_placeholder != null:
		enemy_placeholder.scale = Vector2.ONE * character_scale
		enemy_placeholder.position = Vector2(safe_content_rect.end.x - padding - card_half_size.x, safe_content_rect.position.y + padding + card_half_size.y)
	# HUD 以原 1280 宽度为基准等比缩放，保持血条内容清晰。
	var hud_scale := clampf(safe_content_rect.size.x / 1280.0, 0.7, hud_scale_maximum)
	# 我方 HUD 节点，移动端放到战斗区右下角。
	var player_hud := ui_root.get_node_or_null("player1_stat") as Control
	# 敌方 HUD 节点，移动端放到战斗区左上角。
	var enemy_hud := ui_root.get_node_or_null("player2_stat") as Control
	if player_hud != null:
		player_hud.scale = Vector2.ONE * hud_scale
		player_hud.position = Vector2(safe_content_rect.end.x - 512.0 * hud_scale - padding, battle_height - 118.0 * hud_scale - padding)
	if enemy_hud != null:
		enemy_hud.scale = Vector2.ONE * hud_scale
		enemy_hud.position = Vector2(safe_content_rect.position.x + padding - 768.0 * hud_scale, safe_content_rect.position.y + padding)
	# 回合提示标签节点。
	var phase_label := ui_root.get_node_or_null("curr_phase") as Label
	# 轮次提示标签节点。
	var round_label := ui_root.get_node_or_null("curr_round_count") as Label
	# 回合提示的响应式字体大小。
	var phase_font_size := int(clampf(safe_content_rect.size.x * 0.035, 24.0, 42.0))
	# 轮次提示的响应式字体大小。
	var round_font_size := int(clampf(safe_content_rect.size.x * 0.029, 20.0, 32.0))
	if phase_label != null:
		phase_label.position = Vector2(safe_content_rect.get_center().x - 90.0, safe_content_rect.position.y + (battle_height - safe_content_rect.position.y) * 0.46)
		phase_label.size = Vector2(180.0, 42.0)
		phase_label.add_theme_font_size_override("font_size", phase_font_size)
		phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if round_label != null:
		round_label.position = Vector2(safe_content_rect.get_center().x - 90.0, safe_content_rect.position.y + (battle_height - safe_content_rect.position.y) * 0.46 + 40.0)
		round_label.size = Vector2(180.0, 34.0)
		round_label.add_theme_font_size_override("font_size", round_font_size)


## 在下方操作区排布四个技能按钮为两行两列，按钮文字根据格子尺寸同步缩放。
func _layout_skill_buttons(safe_content_rect: Rect2, battle_height: float, padding: float, gap: float) -> void:
	# 四个技能按钮的父容器。
	var skill_container := ui_root.get_node_or_null("button/skill") as Control
	if skill_container == null:
		return
	# 最底部操作栏的高度，为技能区预留空间。
	var bottom_height := maxf(safe_content_rect.size.y * bottom_action_height_ratio, 56.0)
	# 技能区域的顶部纵坐标。
	var skill_top := battle_height + padding
	# 技能区域的底部纵坐标。
	var skill_bottom := safe_content_rect.end.y - padding - bottom_height - gap
	# 单个技能格的响应式宽高。
	var skill_size := Vector2((safe_content_rect.size.x - padding * 2.0 - gap) * 0.5, (skill_bottom - skill_top - gap) * 0.5)
	# 技能节点名称顺序，对应两行两列的阅读顺序。
	var skill_names := ["skilla", "skillb", "skillc", "skilld"]
	for index in skill_names.size():
		# 当前技能按钮节点。
		var skill_button := skill_container.get_node_or_null(skill_names[index]) as Button
		if skill_button == null:
			continue
		# 当前技能在两列网格中的列索引。
		var column := index % 2
		# 当前技能在两行网格中的行索引。
		var row := index / 2
		skill_button.position = Vector2(safe_content_rect.position.x + padding + column * (skill_size.x + gap), skill_top + row * (skill_size.y + gap))
		skill_button.size = skill_size
		_layout_skill_button_text(skill_button, skill_size, safe_content_rect.size.x)


## 设置单个技能按钮内标题与消耗文字的触控友好字号和可用宽度。
func _layout_skill_button_text(skill_button: Button, button_size: Vector2, viewport_width: float) -> void:
	# 按钮内部留白，避免文字贴近边框。
	var inner_padding := maxf(button_size.x * 0.05, 8.0)
	# 技能名称标签节点。
	var title := skill_button.get_node_or_null("name") as Label
	# 技能消耗与伤害类型标签节点。
	var detail := skill_button.get_node_or_null("other") as Label
	# 技能名称的响应式字体大小。
	var title_font_size := int(clampf(viewport_width * 0.040, 24.0, 42.0))
	# 技能说明的响应式字体大小。
	var detail_font_size := int(clampf(viewport_width * 0.032, 19.0, 34.0))
	if title != null:
		title.position = Vector2(inner_padding, button_size.y * 0.18)
		title.size = Vector2(button_size.x - inner_padding * 2.0, button_size.y * 0.32)
		title.add_theme_font_size_override("font_size", title_font_size)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if detail != null:
		detail.position = Vector2(inner_padding, button_size.y * 0.55)
		detail.size = Vector2(button_size.x - inner_padding * 2.0, button_size.y * 0.25)
		detail.add_theme_font_size_override("font_size", detail_font_size)
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## 将五名角色选择按钮置于同一操作区，使用三列两行确保第五名角色也有足够的点击面积。
func _layout_character_selectors(safe_content_rect: Rect2, battle_height: float, padding: float, gap: float) -> void:
	# 主动换人与技能选目标共用的两个角色选择容器。
	var selector_names := ["button/change_character", "button/choose_player_character"]
	# 最底部操作栏的高度，为角色网格预留空间。
	var bottom_height := maxf(safe_content_rect.size.y * bottom_action_height_ratio, 56.0)
	# 角色选择网格的顶部纵坐标。
	var selector_top := battle_height + padding
	# 角色选择网格的底部纵坐标。
	var selector_bottom := safe_content_rect.end.y - padding - bottom_height - gap
	# 三列两行角色选择网格的单元尺寸。
	var cell_size := Vector2((safe_content_rect.size.x - padding * 2.0 - gap * 2.0) / 3.0, (selector_bottom - selector_top - gap) * 0.5)
	for selector_name in selector_names:
		# 当前角色选择容器节点。
		var selector := ui_root.get_node_or_null(selector_name) as Control
		if selector == null:
			continue
		for index in 5:
			# 当前角色选择按钮节点。
			var character_button := selector.get_node_or_null("character" + str(index + 1)) as Button
			if character_button == null:
				continue
			# 当前角色在三列网格中的列索引。
			var column := index % 3
			# 当前角色在两行网格中的行索引。
			var row := index / 3
			# 当前角色按钮的横坐标，第五名角色会在第二行居中。
			var x_position := safe_content_rect.position.x + padding + column * (cell_size.x + gap)
			if row == 1 and index == 4:
				x_position += (cell_size.x + gap) * 0.5
			character_button.position = Vector2(x_position, selector_top + row * (cell_size.y + gap))
			character_button.size = cell_size
			# 角色名称标签节点。
			var name_label := character_button.get_node_or_null("name") as Label
			if name_label != null:
				name_label.position = Vector2(6.0, cell_size.y * 0.34)
				name_label.size = Vector2(cell_size.x - 12.0, cell_size.y * 0.32)
				name_label.add_theme_font_size_override("font_size", int(clampf(safe_content_rect.size.x * 0.035, 22.0, 36.0)))
				name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## 将“角色、战斗、普攻、逃跑、记录”固定为最底部的一行，符合单手拇指操作习惯。
func _layout_bottom_actions(safe_content_rect: Rect2, padding: float, gap: float) -> void:
	# 底部单手操作栏的高度。
	var bottom_height := maxf(safe_content_rect.size.y * bottom_action_height_ratio, 56.0)
	# 五个操作按钮均分后得到的单个按钮宽度。
	var button_width := (safe_content_rect.size.x - padding * 2.0 - gap * 4.0) / 5.0
	# 底部操作栏的顶部纵坐标。
	var bottom_y := safe_content_rect.end.y - padding - bottom_height
	# 底部按钮从左到右的固定功能顺序。
	var action_paths := [
		"button/extend/character",
		"button/extend/fight",
		"button/extend/attack",
		"button/extend/run",
		"button/log/log",
	]
	for index in action_paths.size():
		# 当前底部操作按钮节点。
		var action_button := ui_root.get_node_or_null(action_paths[index]) as Button
		if action_button == null:
			continue
		action_button.position = Vector2(safe_content_rect.position.x + padding + index * (button_width + gap), bottom_y)
		action_button.size = Vector2(button_width, bottom_height)
		action_button.scale = Vector2.ONE
		# 当前操作按钮的文字标签节点。
		var name_label := action_button.get_node_or_null("name") as Label
		if name_label != null:
			name_label.position = Vector2(4.0, bottom_height * 0.29)
			name_label.size = Vector2(button_width - 8.0, bottom_height * 0.42)
			name_label.add_theme_font_size_override("font_size", int(clampf(safe_content_rect.size.x * 0.028, 17.0, 30.0)))
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## 把战斗记录限制在上方战斗显示区中，避免覆盖底部仍可操作的按钮。
func _layout_battle_log(safe_content_rect: Rect2, battle_height: float, padding: float) -> void:
	# 战斗记录的根节点，尺寸限制在上方战斗区内。
	var log_control := ui_root.get_node_or_null("log") as Control
	if log_control == null:
		return
	log_control.position = Vector2(safe_content_rect.position.x, safe_content_rect.position.y)
	log_control.size = Vector2(safe_content_rect.size.x, battle_height - safe_content_rect.position.y)
	# 记录文本外层容器，用于控制内容边距。
	var log_container := log_control.get_node_or_null("VBoxContainer") as VBoxContainer
	if log_container == null:
		return
	log_container.position = Vector2(padding, padding)
	log_container.size = Vector2(safe_content_rect.size.x - padding * 2.0, battle_height - safe_content_rect.position.y - padding * 2.0)
	# 可自动滚动的战斗记录文本节点。
	var rich_text := log_container.get_node_or_null("PanelContainer/MarginContainer/RichTextLabel") as RichTextLabel
	if rich_text != null:
		rich_text.custom_minimum_size = Vector2(0.0, battle_height - safe_content_rect.position.y - padding * 2.0 - 20.0)
		rich_text.add_theme_font_size_override("normal_font_size", int(clampf(safe_content_rect.size.x * 0.031, 18.0, 32.0)))


## 切换上方战斗区在“实时战斗”与“战斗记录”之间的显示状态。
func toggle_battle_log() -> void:
	if not mobile_ui_active:
		return
	set_battle_log_visible(not battle_log_visible)


## 显示或隐藏战斗记录，并同步隐藏或恢复战斗角色、HUD 与回合信息。
func set_battle_log_visible(should_show_log: bool) -> void:
	if not mobile_ui_active:
		return
	battle_log_visible = should_show_log
	# 战斗记录根节点，用于显示或隐藏完整记录面板。
	var log_control := ui_root.get_node_or_null("log") as Control
	if log_control != null:
		log_control.visible = should_show_log
	# 记录模式下需要被替换掉的战斗 HUD 与占位 Sprite 节点路径。
	var combat_node_paths := ["player_sprite", "enemy_sprite", "player1_stat", "player2_stat", "curr_phase", "curr_round_count"]
	for combat_node_path in combat_node_paths:
		# 当前需要切换可见性的战斗节点。
		var combat_node := ui_root.get_node_or_null(combat_node_path) as CanvasItem
		if combat_node != null:
			combat_node.visible = not should_show_log
	# 记录按钮文字节点，用于提示下一次点击将返回的页面。
	var record_label := ui_root.get_node_or_null("button/log/log/name") as Label
	if record_label != null:
		record_label.text = "战斗" if should_show_log else "记录"


## 手机端窗口尺寸变化时重新布局；桌面端不会改动已有 UI 坐标。
func _on_ui_root_resized() -> void:
	apply_layout()
