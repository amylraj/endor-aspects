load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//python/common:utils.bzl", "compute_package_version_name")

def _compute_package_version_name_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, "a_b_c", compute_package_version_name("@//a/b:c"))
    asserts.true(env, "a_b_d" == compute_package_version_name("@//a/b:c"))
    return unittest.end(env)

compute_package_version_name_test = unittest.make(_compute_package_version_name_test)
