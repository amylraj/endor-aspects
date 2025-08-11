"""Provider definitions for Endor Python dependency information."""

EndorPythonDependencyInfo = provider(
    doc = "Provider for Endor Python dependency information",
    fields = {
        "original_label": "The original label of the target",
        "name": "The name of the Package or Dependency",
        "version": "The version of the Package or Dependency",
        "dependencies": "A List of Direct Dependencies",
        "internal": "bool: Is Internal or External Dep",
    },
)
