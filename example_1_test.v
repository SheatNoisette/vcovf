module vcovf

fn my_function_1(a int, b int) bool {
	mut cov := get_coverage_context(@FN)

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

fn test_my_function_1_coverage() {
	mut function_cov := new_coverage('my_function_1')

	assert my_function_1(-1, -1) == true
	assert my_function_1(1, -1) == false
	assert my_function_1(1, 1) == false

	function_cov.end_coverage()


	assert function_cov.is_line_covered(9) == true
	assert function_cov.is_line_covered(7) == true
	assert function_cov.is_line_covered(12) == true
	assert function_cov.is_line_covered(16) == true
}

fn test_my_function_1_no_fully_covered() {
	mut function_cov := new_coverage('my_function_1')

	assert my_function_1(1, -1) == false
	assert my_function_1(1, 1) == false

	function_cov.end_coverage()

	assert function_cov.is_line_covered(9) == false
}