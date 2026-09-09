## 主菜单的手机竖屏布局组件。
##
## 本组件只负责重排主菜单的背景与入口按钮，不修改随机模式或队伍模式的业务逻辑。
class_name MobileMainMenuLayout
extends Node


## 当需要在编辑器或桌面端调试手机菜单时设为 true；正式版本自动识别 Android 与 iOS。
@export var force_mobile_ui: bool = false
## 菜单按钮相对于安全内容区宽度的横向边距比例。
@export_range(0.03, 0.16, 0.005) var horizontal_padding_ratio: float = 0.07
## 菜单按钮之间的垂直间距比例。
@export_range(0.01, 0.08, 0.005) var button_gap_ratio: float = 0.025
## 单个菜单按钮相对于安全内容区高度的比例。
@export_range(0.06, 0.18, 0.005) var button_height_ratio: float = 0.10
## 主菜单 UI 根节点路径；此 Control 必须覆盖当前窗口。
@export var ui_root_path: NodePath
## 主菜单背景 Sprite2D 路径；移动端会按覆盖方式铺满全屏。
@export var background_path: NodePath

## 当前是否启用手机主菜单布局，供主菜单控制器或调试代码查询。
var mobile_ui_active: bool = false
## 主菜单 UI 根节点缓存，避免每次尺寸变更重复解析路径。
var ui_root: Control
## 主菜单背景节点缓存，用于适配超长比例手机屏幕。
var menu_background: Sprite2D


func _ready() -> void:
	ui_root = get_node_or_null(ui_root_path) as Control
	menu_background = get_node_or_null(background_path) as Sprite2D
	if ui_root == null:
		push_error("MobileMainMenuLayout 未找到 ui_root_path 指向的 Control 节点。")
		return
	ui_root.resized.connect(_on_ui_root_resized)
	apply_layout()
	call_deferred("apply_layout")


## 仅在 Android/iOS 的竖屏环境使用此布局，避免影响桌面横屏主菜单。
func should_use_mobile_ui() -> bool:
	# 当前逻辑画布尺寸用于判断竖屏状态。
	var viewport_size := _get_ui_size()
	# 同时兼容 Godot mobile 特性标签与 Android、iOS 平台名称。
	var is_mobile_platform := OS.has_feature("mobile") or OS.get_name() == "Android" or OS.get_name() == "iOS"
	if force_mobile_ui:
		return true
	return is_mobile_platform and viewport_size.y > viewport_size.x


## 依据安全区域重新摆放背景、队伍模式和随机模式入口。
func apply_layout() -> void:
	if ui_root == null:
		return
	mobile_ui_active = should_use_mobile_ui()
	if not mobile_ui_active:
		return
	# 当前完整画布尺寸，用于让背景真正延伸到屏幕边缘。
	var viewport_size := _get_ui_size()
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	# 可放置交互控件的安全区域，避开打孔摄像头和系统手势区。
	var safe_content_rect := _get_safe_content_rect(viewport_size)
	_layout_background(viewport_size)
	_layout_menu_buttons(safe_content_rect)


## 返回主菜单 UI 的逻辑尺寸；节点尚未完成布局时使用 Viewport 后备值。
func _get_ui_size() -> Vector2:
	if ui_root != null and ui_root.size.x > 0.0 and ui_root.size.y > 0.0:
		return ui_root.size
	return get_viewport().get_visible_rect().size


## 将 Android/iOS 的物理像素安全区域转换为当前菜单的逻辑坐标。
func _get_safe_content_rect(viewport_size: Vector2) -> Rect2:
	# 系统返回的无遮挡显示区域，单位为物理像素。
	var display_safe_area := DisplayServer.get_display_safe_area()
	# 屏幕物理像素尺寸，用来计算逻辑坐标转换比例。
	var display_size := DisplayServer.screen_get_size()
	if display_safe_area.size.x <= 0 or display_safe_area.size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	if display_size.x <= 0 or display_size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	# 物理像素到逻辑画布的横纵缩放比例。
	var display_to_viewport_scale := Vector2(viewport_size.x / float(display_size.x), viewport_size.y / float(display_size.y))
	# 转换后的安全区域左上角。
	var safe_position := Vector2(display_safe_area.position.x, display_safe_area.position.y) * display_to_viewport_scale
	# 转换后的安全区域尺寸。
	var safe_size := Vector2(display_safe_area.size.x, display_safe_area.size.y) * display_to_viewport_scale
	# 截取到当前画布内的有效安全区域。
	var safe_content_rect := Rect2(safe_position, safe_size).intersection(Rect2(Vector2.ZERO, viewport_size))
	if safe_content_rect.size.x < viewport_size.x * 0.5 or safe_content_rect.size.y < viewport_size.y * 0.5:
		return Rect2(Vector2.ZERO, viewport_size)
	return safe_content_rect


## 将主菜单背景按覆盖方式缩放，填满超长全面屏的整个显示区域。
func _layout_background(viewport_size: Vector2) -> void:
	if menu_background == null or menu_background.texture == null:
		return
	# 背景纹理原始尺寸，用于计算覆盖缩放比例。
	var texture_size := menu_background.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	# 横纵方向中较大的缩放值，可避免屏幕出现空白边。
	var cover_scale := maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	menu_background.position = viewport_size * 0.5
	menu_background.scale = Vector2.ONE * cover_scale


## 将两个菜单入口固定在安全区域下半部，保证不出屏且便于单手点击。
func _layout_menu_buttons(safe_content_rect: Rect2) -> void:
	# 菜单按钮的横向边距，限制最小值以避免贴边。
	var horizontal_padding := maxf(safe_content_rect.size.x * horizontal_padding_ratio, 20.0)
	# 两个菜单按钮间的垂直间距。
	var button_gap := maxf(safe_content_rect.size.y * button_gap_ratio, 16.0)
	# 单个大按钮高度，限制范围可确保小屏和大屏都容易点击。
	var button_height := clampf(safe_content_rect.size.y * button_height_ratio, 76.0, 148.0)
	# 两个按钮共用的宽度。
	var button_width := safe_content_rect.size.x - horizontal_padding * 2.0
	# 两个按钮组的总高度。
	var button_group_height := button_height * 2.0 + button_gap
	# 按钮组起点，固定在安全区域底部以上，贴近单手拇指可触及位置。
	var button_group_top := safe_content_rect.end.y - horizontal_padding - button_group_height
	# 队伍模式按钮节点。
	var team_mode_button := ui_root.get_node_or_null("button/team_mode") as Button
	# 随机模式按钮节点。
	var random_mode_button := ui_root.get_node_or_null("button/random_mode") as Button
	# 菜单按钮文字的响应式字号。
	var menu_font_size := int(clampf(safe_content_rect.size.x * 0.052, 28.0, 44.0))
	_layout_menu_button(team_mode_button, Vector2(safe_content_rect.position.x + horizontal_padding, button_group_top), Vector2(button_width, button_height), menu_font_size)
	_layout_menu_button(random_mode_button, Vector2(safe_content_rect.position.x + horizontal_padding, button_group_top + button_height + button_gap), Vector2(button_width, button_height), menu_font_size)


## 设置单个菜单按钮与其文字标签的最终位置、尺寸和字体大小。
func _layout_menu_button(menu_button: Button, button_position: Vector2, button_size: Vector2, font_size: int) -> void:
	if menu_button == null:
		return
	menu_button.position = button_position
	menu_button.size = button_size
	# 菜单按钮内部的标题标签节点。
	var word_label := menu_button.get_node_or_null("word") as Label
	if word_label == null:
		return
	word_label.position = Vector2(8.0, button_size.y * 0.29)
	word_label.size = Vector2(button_size.x - 16.0, button_size.y * 0.42)
	word_label.add_theme_font_size_override("font_size", font_size)
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## 窗口尺寸或安全区域发生变化后，重新计算主菜单控件位置。
func _on_ui_root_resized() -> void:
	apply_layout()
