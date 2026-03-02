## [ValidationSuite] that returns explicitly a list of scene files that are to be validated.
class_name SceneValidationSuite extends ValidationSuite

# ============================================================================
# EXPORTED PROPERTIES
# ============================================================================

## Paths to scenes that are to be validated.
@export_file("*.tscn", "*.scn") var scenes: Array[String]

# ============================================================================
# ABSTRACT INTERFACE
# ============================================================================


## Returns list of scenes that are to be validated.
func get_files() -> Array[String]:
	return scenes
