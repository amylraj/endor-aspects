load("@rules_python//python:defs.bzl", "py_binary", "py_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:util.bzl", "util")
load("//python/version-0.16.0:py_binary.bzl", "internal_endor_py_binary_resolve_dependencies")

endor_py_binary_test_aspect = util.make_testing_aspect(
    aspects = [internal_endor_py_binary_resolve_dependencies],
)

def _impl(env, target):
    env.expect.target(target).has_provider("PyInfo")

def py_binary_test(name):
    # Non Python Target
    util.empty_file("main.txt")
    util.helper_target(
        native.filegroup,  # for non-python dependency
        name = "random",
        srcs = ["main.txt"],
    )

    # Python Library
    util.empty_file("liba.py")
    util.empty_file("libb.py")
    util.helper_target(py_library, name = "lib", srcs = ["liba.py", "libb.py"])

    # Python Binary
    util.empty_file("main.py")
    util.helper_target(
        py_binary,
        name = "binary",
        srcs = ["main.py"],
        deps = [":lib", ":random"],
    )

    analysis_test(
        name = name,
        target = ":binary",
        impl = _impl,
        testing_aspect = endor_py_binary_test_aspect,
        attrs = {
            "ref": attr.string(),
            "target_name": attr.string(),
        },
    )
