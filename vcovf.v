module vcovf

import rand
import time
import strconv

// vcovf: PoC code coverage micro-framework
// MIT Licensed - 2021 SheatNoisette

__global (
	vcovf_contexts VConverageContainer
)

struct VConverageContext {
pub mut:
	name                     string
	id                       i64
	coverage_points_called   int
	expected_coverage_points int
	line_tested              map[int]bool
}

struct VConverageContainer {
pub mut:
	// Name of the context -> Context
	contexts map[string]&VConverageContext
}

// Inside a convered function, the profiling context
[inline]
pub fn get_coverage_context(function_ptr voidptr) &VConverageContext {
	$if test || vcovf ? {
		if function_ptr.str() !in vcovf_contexts.contexts {
			panic('vcovf: Unknown function context')
		}
		return vcovf_contexts.contexts[function_ptr.str()]
	} $else {
		return voidptr(0)
	}
}

// Create a unique coverage context
pub fn create_coverage_context(function_ptr voidptr) &VConverageContext {
	// Create a ID
	random_id := ((rand.int() & 0xff) + time.now().unix_time())

	context := VConverageContext{
		id: random_id
		coverage_points_called: 0
		expected_coverage_points: -1
		name: function_ptr.str()
	}

	// Register global context
	vcovf_contexts.contexts[context.name] = &context

	return vcovf_contexts.contexts[context.name]
}

// Add a coverage point into your function
[if test || vcovf ?]
pub fn (vc &VConverageContext) add_coverage_point(line string) {
	line_number := strconv.atoi(line) or { panic("Invalid line number '$line' - $err") }

	// Tests are multi-threaded, lock the increments to avoid undefined behaviours
	lock  {
		mut context := vcovf_contexts.contexts[vc.name]
		if line_number !in vc.line_tested {
			context.coverage_points_called += 1
			context.line_tested[line_number] = true
		}
	}
}

// Set a coverage objective which would be used to know if every coverage
// Points are been reached
[if test]
pub fn (mut vc VConverageContext) set_coverage_points(number u32) {
	vc.expected_coverage_points = int(number)
}

// Create a new coverage context
[inline]
pub fn new_coverage(function_name voidptr) &VConverageContext {
	return create_coverage_context(function_name)
}

// End the coverage test
pub fn (vc &VConverageContext) end_coverage() {
	// TODO: Free
	vcovf_contexts.contexts.delete(vc.name)
}

// Get the number of coverage point executed
[inline]
pub fn (vc &VConverageContext) get_coverage_points() int {
	return vc.coverage_points_called
}

// Check if the function is covered based on the set_coverage_points() value
[inline]
pub fn (vc &VConverageContext) is_covered() bool {
	if vc.expected_coverage_points == -1 {
		eprintln('vcovf: Expected coverage objective not set')
		return false
	}
	return vc.expected_coverage_points == vc.coverage_points_called
}

// Not recommended: Check if a line is covered manually
[inline]
pub fn (vc &VConverageContext) is_line_covered(line int) bool {
	if line !in vc.line_tested {
		return false
	}
	return true
}
