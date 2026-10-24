extends SceneTree
func _initialize() -> void:
	var notice=Engine.get_license_text()+"\n\nTHIRD-PARTY LIBRARY LICENSES\n"
	var libraries=Engine.get_license_info()
	for name in libraries:
		notice+="\n"+name+"\n"+libraries[name]+"\n"
	notice+="\nCOPYRIGHT INFORMATION\n"+JSON.stringify(Engine.get_copyright_info(),"\t")
	FileAccess.open("res://assets/ENGINE_LICENSES.txt",FileAccess.WRITE).store_string(notice)
	quit()
