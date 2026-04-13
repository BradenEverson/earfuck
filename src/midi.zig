//! Minimal midi file parser to support just enough for reading our BF instructions
const std = @import("std");

pub const MidiError = error{
    InvalidMidi,
    NoTrack,
    EndOfBuffer,
};

/// Parse the MIDI pitch events for our earfuck commands!
pub fn parseEvents(alloc: std.mem.Allocator, path: []const u8, instructions: *std.ArrayList(u8)) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var i: usize = 0;

    if (buf.len < 14 or !std.mem.eql(u8, buf[0..4], "MThd")) return error.InvalidMidi;
    i += 14;

    if (!std.mem.eql(u8, buf[i .. i + 4], "MTrk")) return error.NoTrack;
    i += 4;
    const track_len = std.mem.readInt(u32, buf[i .. i + 4][0..4], .big);
    i += 4;

    const track_end = i + track_len;
    var running_status: u8 = 0;

    while (i < track_end) {
        _ = readVlq(buf, &i);

        if (i < track_end) {
            var status = buf[i];
            i += 1;

            if (status < 0x80) {
                const note = status;
                status = running_status;
                try handleNote(alloc, status, note, instructions);
                if (status >= 0x80 and status < 0xC0) i += 1;
            } else {
                running_status = status;
                const note = buf[i];
                i += 1;
                try handleNote(alloc, status, note, instructions);

                if (status >= 0x80 and status < 0xC0) i += 1;
            }
        }
    }
}

fn readVlq(buf: []const u8, i: *usize) u32 {
    var val: u32 = 0;
    while (true) {
        const b = buf[i.*];
        i.* += 1;
        val = (val << 7) | (b & 0x7F);
        if (b < 0x80) break;
    }
    return val;
}

const PITCH_OPEN_BRACKET: u8 = 35;
const PITCH_CLOSE_BRACKET: u8 = 36;
const PITCH_MINUS: u8 = 48;
const PITCH_PLUS: u8 = 59;
const PITCH_DOT: u8 = 53;
const PITCH_LEFT: u8 = 65;
const PITCH_RIGHT: u8 = 67;

fn pitchToInstruction(pitch: u8) u8 {
    return switch (pitch) {
        PITCH_OPEN_BRACKET => '[',
        PITCH_CLOSE_BRACKET => ']',
        PITCH_MINUS => '-',
        PITCH_PLUS => '+',
        PITCH_DOT => '.',
        PITCH_LEFT => '<',
        PITCH_RIGHT => '>',

        else => ' ', // ignore notes not included in the earfuck range, allowing extra notes for songs
    };
}

fn handleNote(alloc: std.mem.Allocator, status: u8, note: u8, instructions: *std.ArrayList(u8)) !void {
    if ((status & 0xF0) == 0x90) {
        const instr = pitchToInstruction(note);
        try instructions.append(alloc, instr);
    }
}
