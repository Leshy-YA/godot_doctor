## [ValidationSuite] that returns explicitly a list of resource files that are to be validated.
class_name ResourceValidationSuite extends ValidationSuite


# ============================================================================
# EXPORTED PROPERTIES
# ============================================================================


## Paths to resources that are to be validated.
@export_file("*.tres", "*.res") var resources : Array[String]


# ============================================================================
# ABSTRACT INTERFACE
# ============================================================================


## Returns list of resources that are to be validated.
func get_files() -> Array[String] :
	return resources
