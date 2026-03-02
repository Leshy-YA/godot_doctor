## [ValidationSuite] that returns
class_name DirectoryValidationSuite extends ValidationSuite

# ============================================================================
# HELPER TYPES
# ============================================================================

## Enum defining what kind of files are to be found in the set directories.
enum FileType {
	RESOURCE,  ## The suite will list resources from the set directories.
	SCENE,  ##The suite will list scenes from the set directories.
}

# ============================================================================
# EXPORTED PROPERTIES
# ============================================================================

## What kind of files are to be found in the set directories.
@export var file_type: FileType = FileType.SCENE

## Paths to directories containing files that are to be validated.
@export_dir var directories: Array[String]

# ============================================================================
# ABSTRACT INTERFACE
# ============================================================================


## Returns list of files in the set [directories] of the set [file_type] that are to be validated.
func get_files() -> Array[String]:
	var files: Array[String]

	# Go through all the directories and look for relevant files.
	for dir: String in directories:
		files.append_array(_list_files(dir))

	return files


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================


## Goes through the input directory, as well as recursivelly through its sub-directories and finds
## files of [file_type].
func _list_files(directory_path: String) -> Array[String]:
	var files: Array[String] = []

	if DirAccess.dir_exists_absolute(directory_path):
		for dir_name: String in DirAccess.get_directories_at(directory_path):
			_list_files(directory_path.path_join(dir_name))

		for file_name: String in DirAccess.get_files_at(directory_path):
			if (
				file_type == FileType.SCENE
				and (file_name.ends_with(".tscn") or file_name.ends_with(".scn"))
			):
				files.append(directory_path + "/" + file_name)
			elif (
				file_type == FileType.RESOURCE
				and (file_name.ends_with(".tres") or file_name.ends_with(".res"))
			):
				files.append(directory_path + "/" + file_name)

	return files
