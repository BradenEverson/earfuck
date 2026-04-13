const std = @import("std");
const preprocess = @import("preprocessor.zig");
const midi = @import("midi.zig");

pub fn main() void {}

pub fn exit_err(msg: []const u8) noreturn {
    std.debug.print("{s}\n", .{msg});
    std.process.exit(1);
}
