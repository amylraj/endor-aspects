# Todo: Add Unit Tests for this

def _get_external_target_details(tags):
    name = ""
    version = ""
    for tag in tags:
        if tag.startswith("pypi_name="):
            name = tag.split("=")[1]
        if tag.startswith("pypi_version="):
            version = tag.split("=")[1]
    return name, version

def _get_internal_target_details(ctx):
    name = ctx.rule.attr.name
    version = "bazel-internal"  # Will be replaced in Endorctl
    if hasattr(ctx.attr, "ref"):
        version = ctx.attr.ref
    return name, version

def _get_pip_name_and_version(ctx):
    is_internal_target = str(ctx.label).startswith("@//")
    if not is_internal_target and hasattr(ctx.rule.attr, "tags"):
        return _get_external_target_details(ctx.rule.attr.tags)

    return _get_internal_target_details(ctx)

def _get_dependency_labels(deps):
    labels = []
    for dep in deps:
        if PyInfo in dep:
            dep_label = str(dep.label) if hasattr(dep, "label") else ""
            labels.append(dep_label)
    return labels

def _compute_package_version_name(target):
    target_path = target.replace("@//", "_")
    target_path = target_path.replace("@", "")
    target_path = target_path.replace("//:", "_")
    target_path = target_path.replace("/", "_")
    target_path = target_path.replace(":", "_")
    if target_path.startswith("_"):
        target_path = target_path[1:]
    return target_path

compute_package_version_name = _compute_package_version_name
get_pip_name_and_version = _get_pip_name_and_version
get_dependency_labels = _get_dependency_labels
