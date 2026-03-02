## Resource used by the CLI interface, used by [BatchValidationSettings].
## It mainly returns a list of files that are to go through validation.
@abstract class_name ValidationSuite extends Resource


# ============================================================================
# HELPER TYPES
# ============================================================================

## Enum defining how Warnings in the validation process should be treated.
## INHERIT: Will use the settings in the parent [CLIValidationSettings].
## IGNORE_WARNINGS: Warnings will be reported, but will not fail validation.
## FAIL_ON_WARNINGS: Warning will be reported and treated as errors, therefore will fail validation.
enum WarningBehaviourOverride { INHERIT, IGNORE_WARNINGS, FAIL_ON_WARNINGS }

# ============================================================================
# EXPORTED PROPERTIES
# ============================================================================

## The human readable name of this suite. Used for reporting.
@export var name: String

## Defines how validation of this suite should deal with Warnings.
@export var warning_behaviour_override: WarningBehaviourOverride

## Paths to scenes that are to be validated.
@export_file("*.tscn", "*.scn") var scenes: Array[String]

# ============================================================================
# ABSTRACT INTERFACE
# ============================================================================

## Returns list of files that contain object that are to be validated - scenes or resources.
@abstract func get_files() -> Array[String]
