# VCovf

Proof-of-concept of function coverage micro-framework made in V.
It is not recommended to use this module in production.

As the 7-dec-2021, no native code coverage tool exists in the V compiler.

One way to get a program coverage is to export a C file with V, build it
with GCC using coverage/profiling flags and view the result using gcov:
```bash
v . -o yourapp.c
gcc -fprofile-arcs -ftest-coverage -g -o app.elf
./app.elf
gcov yourapp.c
```
Sadly, you won't get the exact code coverage of your app using this method.

# Quick start

```v
import vcovf

fn my_function(a int) {

    // Get the coverage context
    mut cov := vcovf.get_coverage_context(my_function)

    // Set a coverage objective - No automatic way to do it
    cov.set_coverage_points(4)

    // Add a coverage point - @LINE is important (Limitation of V)
    cov.add_coverage_point(@LINE)

    if a == 0 {
        cov.add_coverage_point(@LINE)
        return
    }

    if a == 2 {
        cov.add_coverage_point(@LINE)
    }

    cov.add_coverage_point(@LINE)
}

fn my_function_coverage_test() {
    // Create a function
	mut function_cov := vcovf.new_coverage(my_function)

	my_function(0)
	my_function(1)
	my_function(2)

	function_cov.end_coverage()

    assert function_cov.is_covered() == true
}
```

As the library uses a global variable to keep track of the function coverage
status, you need to add `-enable-globals` to use it:
```
v -enable-globals -stats test .
```

The VCovf library calls are automatically removed if the `test` or `vcovf`
macros are not set.
# Run example

Run the integrated example (examples_test.v):
```
v -enable-globals -stats test .
```

# License
Licensed under the MIT license, see ```LICENSE``` for more details.