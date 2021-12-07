module vcovf_tests

import vcovf

fn my_function_1(a int, b int) bool {
	mut cov := vcovf.get_coverage_context(my_function_1)
	cov.set_coverage_points(4)

	if a == b {
		cov.add_coverage_point(@LINE)
		if a < 0 {
			cov.add_coverage_point(@LINE)
			return true
		} else {
			cov.add_coverage_point(@LINE)
			return false
		}
	}
	cov.add_coverage_point(@LINE)
	return false
}

// -----------------------------------------------------------------------------
// TESTS
// -----------------------------------------------------------------------------

fn test_my_function_1_coverage() {
	mut function_cov := vcovf.new_coverage(my_function_1)

	assert my_function_1(-1, -1) == true
	assert my_function_1(1, -1) == false
	assert my_function_1(1, 1) == false

	function_cov.end_coverage()

	// Not recommended
	assert function_cov.is_line_covered(10) == true
	assert function_cov.is_line_covered(12) == true
	assert function_cov.is_line_covered(15) == true
	assert function_cov.is_line_covered(19) == true
}

fn test_my_function_1_is_covered() {
	mut function_cov := vcovf.new_coverage(my_function_1)

	assert my_function_1(-1, -1) == true
	assert my_function_1(1, -1) == false
	assert my_function_1(1, 1) == false

	function_cov.end_coverage()

	assert function_cov.is_covered() == true
}

fn test_my_function_1_no_fully_covered() {
	mut function_cov := vcovf.new_coverage(my_function_1)

	assert my_function_1(1, -1) == false
	assert my_function_1(1, 1) == false

	function_cov.end_coverage()

	assert function_cov.is_line_covered(12) == false
}
