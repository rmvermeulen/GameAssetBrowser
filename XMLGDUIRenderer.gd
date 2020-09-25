extends Control

export (Array, String) var root_folders := []


func _ready():
	render_file("res://ui.xml")


func render_string(gdx: String) -> Control:
	var parser := XMLParser.new()
	assert(OK == parser.open_buffer(gdx.to_utf8()))
	return create_ui(parser)


func render_file(file: String) -> Control:
	var parser := XMLParser.new()
	assert(OK == parser.open(file))
	return create_ui(parser)


func create_ui(parser: XMLParser) -> Control:
	var node = null
	while parser.read() == OK:
		var type := parser.get_node_type()
		if type == XMLParser.NODE_ELEMENT_END:
			break
		var name := get_node_type_name(type)
		prints(
			(
				'<%s> [%s] attrs=%d data="%s"'
				% [
					parser.get_node_name(),
					get_node_type_name(parser.get_node_type()),
					parser.get_attribute_count(),
					parser.get_node_data() if parser.get_node_type() == XMLParser.NODE_TEXT else ""
				]
			)
		)
	return node


func _render_node(_parser: XMLParser) -> Control:
	var node = Control.new()
	# for child in XMLParser.children
	# node.add_child(_render_node(parser))
	return node


static func get_node_type_name(type: int) -> String:
	match type:
		XMLParser.NODE_NONE:
			return "There's no node (no file or buffer opened)."

		XMLParser.NODE_ELEMENT:
			return "Element (tag)."

		XMLParser.NODE_ELEMENT_END:
			return "End of element."

		XMLParser.NODE_TEXT:
			return "Text node."

		XMLParser.NODE_COMMENT:
			return "Comment node."

		XMLParser.NODE_CDATA:
			return "CDATA content."

		XMLParser.NODE_UNKNOWN:
			return "Unknown node."

		_:
			assert(false, "Invalid node type")
			return ""
