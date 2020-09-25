extends Tree

enum State { WORKING, DONE }

# const Cache := preload("res://Cache.gd")

export (String) var path := "" setget set_path

var cache: Cache = Singletons.fetch(Cache)


func _ready():
	assert(OK == connect("item_activated", self, "_on_item_activated"))
	update_tree()


func _on_item_activated():
	var item := get_selected()
	if not item || not item.has_meta("path"):
		return
	call_deferred("readdir", item.get_meta("path"), item)


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
		entries = cache.get_item(dir_path)
	else:
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
