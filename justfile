default:
    @just --list

# Auto-format the source tree
fmt:
    treefmt

# Run 'zig build run' on the project
run *ARGS:
    zig build run {{ARGS}}

# Run 'zig build test' on the project
test *ARGS:
    zig build test {{ARGS}}

