module vcovf

import rand
import time
import strconv

__global (
	vcovf_contexts VConverageContainer
)

struct VConverageContext {
pub mut:
	name                   string
	id                     i64
	coverage_points_called int
	line_tested            map[int]bool
}

struct VConverageContainer {
pub mut:
	// Name of the context -> Context
	contexts map[string]&VConverageContext
}

pub fn get_coverage_context(context_name string) &VConverageContext {
	if context_name !in vcovf_contexts.contexts {
		panic('Unknown context')
	}
	return vcovf_contexts.contexts[context_name]
}

pub fn create_coverage_context(context_name string) &VConverageContext {
	// Create a ID
	random_id := ((rand.int() & 0xff) + time.now().unix_time())

	context := VConverageContext{
		id: random_id
		coverage_points_called: 0
		name: context_name
	}

	// Register global context
	vcovf_contexts.contexts[context.name] = &context

	return vcovf_contexts.contexts[context.name]
}

[inline]
pub fn (vc &VConverageContext) add_coverage_point(line string) {
	line_number := strconv.atoi(line) or { panic("Invalid line number '$line' - $err") }

	mut context := vcovf_contexts.contexts[vc.name]

	if line_number !in vc.line_tested {
		context.coverage_points_called += 1
		context.line_tested[line_number] = true
	}
}

pub fn (vc &VConverageContext) end_coverage() {
	// TODO: Free
	vcovf_contexts.contexts.delete(vc.name)
}

[inline]
pub fn new_coverage(function_name string) &VConverageContext {
	return create_coverage_context(function_name)
}


// Fancy gets

[inline]
pub fn (vc &VConverageContext) get_coverage_points() int
{
	return vc.coverage_points_called
}

[inline]
pub fn (vc &VConverageContext) is_line_covered(line int) bool {
	if line !in vc.line_tested {
		return false
	}
	return true
}