## Class exporting Validation Results to a JUnit compliant XML file
class_name JUnitExport extends RefCounted

# ============================================================================
# HELPER TYPES
# ============================================================================

## Enum defining the status of a test result.
enum Status { PASS, IGNORE, FAIL }

# ============================================================================
# PRIVATE PROPERTIES
# ============================================================================

## Dictionary holding validation results that will be put into the xml file.
## Format:
##	"name": String - test name
##	"classname": String - validation suite name
##	"time": float - test duration in seconds
##	"status": Status - test result status
##	"message": String - the message attached to the result
##	"details" : String - detailed information abou the result.
var _validation_resutls: Array[Dictionary]

## The number of failed validations.
var _fail_count: int

## The total time the whole validation process took, in seconds.
var _total_time: int

## Dictionary holding validation durations of individual Validation Suites.
var _suite_times: Dictionary[String, int]

# ============================================================================
# CORE IMPLEMENTATION
# ============================================================================


## Generated the JUnit compliant xml file content based on [_validation_resutls].
func _generate_junit_xml() -> String:
	# Construct the xml header.
	var xml = '<?xml version="1.0" encoding="UTF-8"?>\n'

	# Add information about the whole validation process.
	xml += (
		'<testsuites name="Godot Doctor Validation" failures="'
		+ str(_fail_count)
		+ '" tests="'
		+ str(_validation_resutls.size())
		+ '" time="'
		+ str(float(_total_time) * 0.000001)
		+ '">\n'
	)

	# Group tests by classname - validation suite name.
	var suites: Dictionary[String, Array] = {}

	# Go through all the result and group them in the dictionary by ValidationSuite name.
	for result in _validation_resutls:
		var classname = result["classname"]

		if not suites.has(classname):
			suites.set(classname, [] as Array[Dictionary])

		suites[classname].append(result)

	# Generate XML for each validation suite
	for classname: String in suites.keys():
		# Grab the results for the current suite.
		var validations: Array[Dictionary] = suites[classname]

		# Get the total amount of validations.
		var validation_count: int = validations.size()

		# Here we will store how many validations in the current suite have failed or been ignored.
		var failures: int = 0
		var skipped: int = 0

		# Get the total time for suite in seconds.
		var total_time = float(_suite_times[classname]) * 0.000001

		# Go through all the validations in the suite.
		for test: Dictionary in validations:
			# Count the failers/ignores.
			if test["status"] == Status.FAIL:
				failures += 1
			elif test["status"] == Status.IGNORE:
				skipped += 1

		# Add the Validaton Suite info to the xml data.
		xml += (
			'    <testsuite name="'
			+ classname
			+ '" tests="'
			+ str(validation_count)
			+ '" failures="'
			+ str(failures)
			+ '" skipped="'
			+ str(skipped)
			+ '" time="'
			+ str(total_time)
			+ '">\n'
		)

		# Add validation data.
		for validation in validations:
			# Add base validation info.
			xml += (
				'        <testcase name="'
				+ validation["name"]
				+ '" classname="'
				+ classname
				+ '" time="'
				+ str(validation["time"])
				+ '">\n'
			)

			# Add any messages if failed/ignored.
			if validation["status"] == Status.FAIL:
				xml += (
					'            <failure message="'
					+ _xml_escape(validation["message"])
					+ '">'
					+ _xml_escape(validation["details"])
					+ "</failure>\n"
				)
			elif validation["status"] == Status.IGNORE:
				xml += (
					'            <skipped message="'
					+ _xml_escape(validation["message"])
					+ '">'
					+ _xml_escape(validation["details"])
					+ "</skipped>\n"
				)

			# Validation info added.
			xml += "        </testcase>\n"

		# Validation Suite info added.
		xml += "    </testsuite>\n"

	# All info added.
	xml += "</testsuites>"

	# The xml data is ready, we can return it now.
	return xml


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================


## Helper function that makes sure xml scape characters are processed correctly.
func _xml_escape(text: String) -> String:
	return (
		text
		. replace("&", "&amp;")
		. replace("<", "&lt;")
		. replace(">", "&gt;")
		. replace('"', "&quot;")
		. replace("'", "&apos;")
	)


## Converts input [param results] into string containg relevant detailes about the validation.
func _get_details(results: Array[ValidatorCLIOutput.Result]) -> String:
	# This will hold the string with the validation details.
	var ret: String = ""

	# Go through all the results.
	for idx: int in range(results.size()):
		# Grab the result.
		var result: ValidatorCLIOutput.Result = results[idx]

		# Add the result message to the output details string.
		ret += result.message

		# Make sure the messages are listed in a collumn.
		if idx < results.size() - 1:
			ret += "\n"

	# Detail string is constructed, ready to be returned.
	return ret


# ============================================================================
# INTERFACE
# ============================================================================


## Add a validation result to be saved in the xml file.
## [param suite] the Validation Suite the validation is part of.
## [param name] the name of the object that is being validated.
## [param results] the results of the validation.
## [param message] the general message associated with the validation.
## [param status] the status of the validation result.
func add_result(
	suite: ValidationSuite,
	name: String,
	results: Array[ValidatorCLIOutput.Result],
	message: String,
	status: Status
) -> void:
	# If the validation has failed, increment the fail counter.
	if status == Status.FAIL:
		_fail_count += 1

	# Construct the data based on the input.
	var info: Dictionary = {
		"name": name,
		"classname": suite.name,
		"status": status,
		"message": message,
		"details": _get_details(results),
		"time": 0.0
	}

	# Store the result data in the dictionary in order to be saved later.
	_validation_resutls.append(info)


## Add input [param time] in microseconds to the data about last validation result.
func add_time_to_last_result(time: int) -> void:
	# Convert the time from microsecnds to seconds.
	var t_sec: float = float(time) * 0.000001
	_validation_resutls.back().set("time", t_sec)


## Increment the stored duration of the input [param suite] by the input [param time]
func add_suite_time(suite: ValidationSuite, time: int) -> void:
	# Find the suite in the dictionary.
	if _suite_times.has(suite.name):
		_suite_times[suite.name] += time
	else:
		_suite_times.set(suite.name, time)

	# Adjust the time.
	_total_time += time


## Parses the collected validation data and saves it to a JUnit compliant xml file
## at the input [param file_path].
func save_junit_xml(file_path: String) -> void:
	# Generate the xml file data.
	var xml_content: String = _generate_junit_xml()

	# Make sure the target directory exists.
	DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())

	# Open the file for writing.
	var file = FileAccess.open(file_path, FileAccess.WRITE)

	# If for some reason opening of the file failed, show an error.
	if file == null:
		push_error("Failed to save JUnit XML report: " + file_path)
		return

	# Save the xml file.
	file.store_string(xml_content)
	file.close()

	# Notify the console the file has been saved.
	print_rich("[color=blue]JUnit XML report saved to: [/color]", file_path)
