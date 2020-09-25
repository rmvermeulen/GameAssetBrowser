extends Control

export (Array, String) var root_folders := []

onready var add_folder_button: Button = find_node("AddFolder")
onready var folder_name_edit: LineEdit = find_node("FolderName")
onready var edit_confirm: Button = find_node("Confirm")

onready var entry_tabs: TabContainer = find_node("FolderEntry")
onready var dir_tabs: TabContainer = find_node("DirTabs")


func _ready():
	assert(OK == add_folder_button.connect("pressed", self, "_on_add_folder_pressed"))
	assert(OK == folder_name_edit.connect("text_entered", self, "_on_folder_name_entered"))
	assert(OK == edit_confirm.connect("pressed", self, "_on_edit_confirm_pressed"))
	_update_dir_tabs()


func _update_dir_tabs():
	while dir_tabs.get_child_count() > root_folders.size():
		var child := dir_tabs.get_child(-1)
		child.queue_free()
		dir_tabs.remove_child(child)

	while dir_tabs.get_child_count() < root_folders.size():
		var child := Tree.new()
		dir_tabs.add_child(child)

	for i in dir_tabs.get_child_count():
		var tree: Tree = dir_tabs.get_child(i)
		tree.clear()
		tree.name = root_folders[i]

		var item := tree.create_item()
		item.set_text(0, tree.name)


func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE && event.pressed:
			if folder_name_edit.visible:
				entry_tabs.current_tab = 0


func _on_add_folder_pressed():
	entry_tabs.current_tab = 1
	folder_name_edit.grab_focus()


func _on_folder_name_entered(folder_name: String):
	if folder_name.empty():
		entry_tabs.current_tab = 0
		return
	# if is_valid(folder_name)
	folder_name_edit.clear()
	root_folders.append(folder_name)
	entry_tabs.current_tab = 0
	_update_dir_tabs()


func _on_edit_confirm_pressed():
	_on_folder_name_entered(folder_name_edit.text)
