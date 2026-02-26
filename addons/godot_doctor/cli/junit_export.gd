## Class exporting Validation Results to a JUnit compliant XML file
class_name JUnitExport extends RefCounted


# ============================================================================
# HELPER TYPES
# ============================================================================


enum Status { PASS , IGNORE , FAIL }


# ============================================================================
# PRIVATE PROPERTIES
# ============================================================================


var _test_results : Array[Dictionary]
# format: {"name": "test_failing", "classname": "MyTestSuite", "time": 0.078, "status": "failed", "message": "Expected true, but got false", "details" : "list stuff"}

var _fail_count : int
var _total_time : int

var _suite_times : Dictionary[String, int]


# ============================================================================
# CORE IMPLEMENTATION
# ============================================================================


func _generate_junit_xml() -> String:
	var xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
	xml += '<testsuites name="Godot Doctor Validation" failures="' + str(_fail_count) +'" tests="' + str(_test_results.size()) +'" time="' + str((float(_total_time)* 0.000001)) +'">\n'

	# Group tests by classname (test suite)
	var suites = {}
	for test in _test_results:
		var classname = test["classname"]
		if not suites.has(classname):
			suites[classname] = []

		suites[classname].append(test)

	# Generate XML for each test suite
	for classname in suites:
		var suite_tests = suites[classname]
		var total_tests = suite_tests.size()
		var failures = 0
		var errors = 0
		var skipped = 0
		
		var total_time = (float(_suite_times[classname]) * 0.000001)

		for test in suite_tests:
			if test["status"] == "failed":
				failures += 1
			elif test["status"] == "skipped":
				skipped += 1

		xml += '    <testsuite name="' + classname + '" tests="' + str(total_tests) + '" failures="' + str(failures) + '" errors="' + str(errors) + '" skipped="' + str(skipped) + '" time="' + str(total_time) + '">\n'

		# Add test cases
		for test in suite_tests:
			xml += '        <testcase name="' + test["name"] + '" classname="' + classname + '" time="' + str(test["time"]) + '">\n'
			if test["status"] == "failed":
				xml += '            <failure message="' + _xml_escape(test["message"]) + '">' + _xml_escape(test["details"]) + '</failure>\n'
			elif test["status"] == "skipped":
				xml += '            <skipped message="' + _xml_escape(test["message"]) + '">' + _xml_escape(test["details"]) + '</skipped>\n'
			xml += '        </testcase>\n'

		xml += '    </testsuite>\n'

	xml += '</testsuites>'
	return xml
	
	
# ============================================================================
# HELPER FUNCTIONS
# ============================================================================


func _xml_escape(text: String) -> String:
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")


func _get_details(results : Array[ValidatorCLIOutput.Result]) -> String :
	var ret : String = ""
	
	
	for idx : int in range(results.size()) :
		
		var result : ValidatorCLIOutput.Result = results[idx]
		
		ret += result.message
		
		if idx < results.size() - 1 :
			ret += "\n"
	
	return ret
	
	
# ============================================================================
# INTERFACE
# ============================================================================


func add_result(suite : ValidationSuite, name : String, results : Array[ValidatorCLIOutput.Result], message : String, status : Status) -> void :
	
	var status_str : String
	
	if status == Status.PASS :
		status_str = "passed"
	elif status == Status.IGNORE :
		status_str = "skipped"
	elif status == Status.FAIL :
		status_str = "failed"
		_fail_count += 1
		
	var info : Dictionary = {
		
			"name": name,
			"classname": suite.name,
			"status": status_str,
			"message" : message,
			"details": _get_details(results),
			"time" : 0.0
		}
		
	_test_results.append(info)
	
	
func add_time_to_last_result(time : int) -> void :
	
	var t_sec : float = (float(time)* 0.000001)
	
	_test_results.back().set("time", t_sec)


func add_suite_time(suite : ValidationSuite, time : int) -> void :
	 
	if _suite_times.has(suite.name) :
		_suite_times[suite.name] += time
	else :
		_suite_times.set(suite.name, time)
	
	_total_time += time 
	
	
func save_junit_xml(file_path: String) -> void:
	
	var xml_content: String = _generate_junit_xml()
	
	print(file_path.get_base_dir())
	
	DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(xml_content)
		file.close()
		print_rich("[color=blue]JUnit XML report saved to: [/color]", file_path)
		
	else:
		push_error("Failed to save JUnit XML report: " + file_path)
