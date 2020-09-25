extends Tree

enum State { WORKING, DONE }

export (String) var path := "" setget set_path

var cache: Cache = Singletons.fetch(Cache)

var tasks := []
var can_run_task := true


func _ready():
	assert(OK == connect("item_activated", self, "_on_item_activated"))
	assert(OK == connect("multi_selected", self, "_on_multi_selected"))
	update_tree()
	prints(name, 'ready')


func _process(_delta):
	if tasks.empty() || not can_run_task:
		return
	can_run_task = false

	var task = tasks.pop_front()
	task.fn.call_func(task.arg)
	yield(get_tree().create_timer(0.08), "timeout")

	can_run_task = true


func get_all_selected() -> Array:
	prints('get all selected')
	var last_item = get_selected()
	if not last_item:
		return []
	var results = [last_item]
	while true:
		var item := get_next_selected(last_item)
		if item:
			results.append(item)
		last_item = item
	return results


func _handle_selected_item(item: TreeItem):
	readdir(item.get_meta("path"), item)
	item.collapsed = true


func _on_multi_selected(item: TreeItem, column: int, is_selected: bool):
	if column != 0 || not is_selected:
		return
	if not item.has_meta("path"):
		return

	tasks.append(
		{
			"fn": funcref(self, "_handle_selected_item"),
			"arg": item,
		}
	)


func _on_item_activated():
	prints('on item activated')
	for item in get_all_selected():
		if not item.has_meta("path"):
			continue
		item.collapsed = false


func set_path(value: String) -> void:
	if value == path:
		return
	path = value
	update_tree()


func update_tree():
	clear()
	if not path:
		return

	var root = create_item()
	root.set_text(0, path)

	readdir(path, root)


func readdir(dir_path: String, root: TreeItem) -> void:
	var dir := Directory.new()

	var entries := []
	if cache.has_item(dir_path):
		Logger.trace('cache hit')
		entries = cache.get_item(dir_path)
	else:
		Logger.trace('cache miss')
		if dir.open(dir_path) != OK:
			return
		if dir.list_dir_begin(true, false) != OK:
			return

		var current := dir.get_next()
		while current:
			entries.append(
				{
					"name": current,
					"dir": dir.current_is_dir(),
				}
			)
			current = dir.get_next()
		entries.sort_custom(EntrySorter, "sort_by_type")
		cache.store_item(dir_path, entries)

	for entry in entries:
		var item = create_item(root)
		item.set_meta("path", "%s/%s" % [dir_path, entry.name])
		item.set_text(0, entry.name)
		if entry.dir:
			item.set_text(1, 'dir')


class EntrySorter:
	static func sort_by_type(a, b):
		return a.dir > b.dir
