load("//.endorctl/aspects/oss/python/common:utils.bzl", "compute_package_version_name", "get_dependency_labels", "get_pip_name_and_version")
load("//.endorctl/aspects/oss/python/provider:endor_python_dependency_info.bzl", "EndorPythonDependencyInfo")

def _endor_py_library_resolve_dependencies(target, ctx):
    if PyInfo not in target and not hasattr(ctx, "attr"):
        return [OutputGroupInfo(endor_python_info = depset([]))]

    name = ""
    version = ""
    deps = []
    is_internal_target = str(ctx.label).startswith("@//")

    # Defaults
    if hasattr(ctx.rule.attr, "name") and name == "":
        name = ctx.rule.attr.name
    if hasattr(ctx.rule.attr, "version") and version == "":
        version = ctx.rule.attr.version
    if hasattr(ctx.rule.attr, "deps"):
        deps = ctx.rule.attr.deps

    if hasattr(ctx.rule.attr, "generator_function") and ctx.rule.attr.generator_function == "py_library":
        name, version = get_pip_name_and_version(ctx)

    ## Todo, Handle Default Target Version Detail, Maybe Not
    ## Handle bazel-internal Targets
    provider = EndorPythonDependencyInfo(
        original_label = str(ctx.label),
        name = name,
        version = version,
        dependencies = get_dependency_labels(deps),
        internal = is_internal_target,
    )

    output_json = ctx.actions.declare_file("pre_merge_{}_resolved_dependencies.json".format(compute_package_version_name(str(ctx.label))))
    ctx.actions.write(
        output = output_json,
        content = "{\"nodes\": [" + provider.to_json() + "]}",
    )

    outputs_to_merge = [output_json]
    for dep in deps:
        if OutputGroupInfo in dep and hasattr(dep[OutputGroupInfo], "endor_python_info"):
            children = dep[OutputGroupInfo].endor_python_info.to_list()
            for child in children:
                outputs_to_merge.append(child)

    merged_json = ctx.actions.declare_file("endor_{}_resolved_dependencies.json".format(compute_package_version_name(str(ctx.label))))
    ctx.actions.run(
        outputs = [merged_json],
        inputs = outputs_to_merge,
        executable = "python3",
        arguments = [
            "-c",
            """
import sys, json
from collections import OrderedDict
out = sys.argv[1]
files = sys.argv[2:]
seen = OrderedDict()
for fname in files:
    with open(fname) as f:
        data = json.load(f)
        objs = data.get("nodes", [])
        for obj in objs:
            key = obj.get("original_label")
            if key and key not in seen:
                seen[key] = obj
with open(out, "w") as f:
    json.dump({"nodes": list(seen.values())}, f)
""",
            merged_json.path,
        ] + [f.path for f in outputs_to_merge],
        use_default_shell_env = True,
    )

    return [OutputGroupInfo(endor_python_info = depset([merged_json]))]

internal_endor_py_library_resolve_dependencies = aspect(
    attr_aspects = ["deps"],
    implementation = _endor_py_library_resolve_dependencies,
    attrs = {
        "ref": attr.string(),
        "target_name": attr.string(),
    },
)

def _endor_py_library_get_callgraph_metadata(target, ctx):
    return [OutputGroupInfo(endor_python_info = depset([]))]

internal_endor_py_library_generate_callgraph_metadata = aspect(
    attr_aspects = ["deps"],
    implementation = _endor_py_library_get_callgraph_metadata,
    attrs = {
        "ref": attr.string(),
        "target_name": attr.string(),
    },
)
