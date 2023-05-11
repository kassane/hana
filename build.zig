const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Option
    const tests = b.option(bool, "Tests", "Build all tests [default: false]") orelse false;
    const examples = b.option(bool, "Examples", "Build all examples [default: false]") orelse false;

    const lib = b.addStaticLibrary(.{
        .name = "hana",
        .target = target,
        .optimize = optimize,
    });

    lib.installHeadersDirectory("include/boost", "");

    if (tests) {
        buildTest(b, .{
            .lib = lib,
            .path = "test/builtin_array.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/comparable.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/lazy.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/logical.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/functional.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/group.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/index_if.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/minimal_product.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/monoid.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/orderable.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/searchable.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/repeat.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/euclidean_ring.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/ring.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/range/at.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/range/back.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/range/contains.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/range/laws.cpp",
        });
    }

    if (examples) {
        buildTest(b, .{
            .lib = lib,
            .path = "example/accessors.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/all.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/append.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/any.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/ap.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/cartesian_product.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/chain.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/cycle.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/lexicographical_compare.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/unpack.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/then.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/wandbox.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/zero.cpp",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "example/zip.cpp",
        });
    }
}

fn buildTest(b: *std.Build, info: BuildInfo) void {
    const test_exe = b.addExecutable(.{
        .name = info.filename(),
        .optimize = info.lib.optimize,
        .target = info.lib.target,
    });
    test_exe.addIncludePath("include");
    test_exe.addIncludePath("benchmark");
    test_exe.addIncludePath("test/_include");
    test_exe.addCSourceFile(info.path, cxxFlags);
    test_exe.linkLibCpp();
    b.installArtifact(test_exe);

    const run_cmd = b.addRunArtifact(test_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(
        b.fmt("{s}", .{info.filename()}),
        b.fmt("Run the {s} test", .{info.filename()}),
    );
    run_step.dependOn(&run_cmd.step);
}

const cxxFlags: []const []const u8 = &.{
    "-Wall",
    "-Wextra",
};

const BuildInfo = struct {
    lib: *std.Build.CompileStep,
    path: []const u8,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.split(u8, std.fs.path.basename(self.path), ".");
        return split.first();
    }
};
