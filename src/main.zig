const std = @import("std");
const preprocess = @import("preprocessor.zig");
const midi = @import("midi.zig");
const Runtime = @import("interp.zig").InterprettedRuntime;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();

    var instructions: std.ArrayList(u8) = .{};
    defer instructions.deinit(alloc);

    if (args.next()) |file_path| {
        midi.parseEvents(alloc, file_path, &instructions) catch |err| {
            std.debug.print("Midi Parse Error: {any}\n", .{err});
            std.process.exit(1);
        };
    } else {
        std.debug.print("Usage: earfuck [file].mid\n", .{});
        std.process.exit(1);
    }

    std.debug.print("{s}\n", .{instructions.items});

    var ops: std.ArrayList(preprocess.Op) = .{};
    defer ops.deinit(alloc);

    preprocess.preproccess(alloc, instructions.items[0..instructions.items.len], &ops) catch |err| {
        std.debug.print("EarFuck Parse Error: {any}\n", .{err});
        std.process.exit(1);
    };

    std.debug.print("{any}\n", .{ops.items});

    var rt = Runtime.new(ops.items[0..ops.items.len]);
    defer rt.deinit();
    rt.run();
}

pub fn exit_err(msg: []const u8) noreturn {
    std.debug.print("{s}\n", .{msg});
    std.process.exit(1);
}
