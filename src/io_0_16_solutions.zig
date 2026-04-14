//! Reference implementations for `io_0_16_challenges.zig`.
//!
//! The workbook file intentionally contains stubs. This file keeps the answers
//! separate so the student-facing challenge prompts can stay clean.

const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub fn challenge_01_write_badge(writer: *Io.Writer, name: []const u8) Io.Writer.Error!void {
    try writer.print("zig-0.16/io:{s}", .{name});
}

pub fn challenge_02_echo_upper(reader: *Io.Reader, writer: *Io.Writer) !void {
    while (true) {
        const byte = reader.takeByte() catch |err| switch (err) {
            error.EndOfStream => return,
            else => |e| return e,
        };
        try writer.writeByte(std.ascii.toUpper(byte));
    }
}

pub fn challenge_03_testing_io() Io {
    return std.testing.io;
}

pub fn challenge_04_fill_token(io: Io, token: *[8]u8) void {
    io.random(token);
}

pub fn challenge_05_elapsed_awake(io: Io, start: Io.Timestamp) Io.Duration {
    return start.untilNow(io, .awake);
}

fn addLater(a: u32, b: u32) u32 {
    return a + b;
}

pub fn challenge_06_add_with_future(io: Io, a: u32, b: u32) u32 {
    var future = Io.async(io, addLater, .{ a, b });
    return future.await(io);
}

fn bumpCounter(counter: *std.atomic.Value(u32), amount: u32) Io.Cancelable!void {
    _ = counter.fetchAdd(amount, .monotonic);
}

pub fn challenge_07_bump_with_group(
    io: Io,
    counter: *std.atomic.Value(u32),
    first_amount: u32,
    second_amount: u32,
) Io.Cancelable!void {
    var group: Io.Group = .init;
    group.async(io, bumpCounter, .{ counter, first_amount });
    group.async(io, bumpCounter, .{ counter, second_amount });
    try group.await(io);
}

pub fn challenge_08_round_trip_queue(io: Io, item: u8) !u8 {
    var storage: [2]u8 = undefined;
    var queue: Io.Queue(u8) = .init(&storage);

    try queue.putOne(io, item);
    const received = try queue.getOne(io);
    queue.close(io);
    return received;
}

pub fn challenge_09_set_value_and_signal(
    io: Io,
    mutex: *Io.Mutex,
    event: *Io.Event,
    value: *u32,
    new_value: u32,
) Io.Cancelable!void {
    try mutex.lock(io);
    value.* = new_value;
    mutex.unlock(io);

    event.set(io);
    try event.wait(io);
}

pub fn challenge_10_write_then_read_file(
    io: Io,
    dir: Io.Dir,
    allocator: Allocator,
    path: []const u8,
    contents: []const u8,
) ![]u8 {
    var file = try dir.createFile(io, path, .{ .truncate = true });
    defer file.close(io);

    var write_buffer: [64]u8 = undefined;
    var file_writer = file.writer(io, &write_buffer);
    try file_writer.interface.writeAll(contents);
    try file_writer.interface.flush();

    return try dir.readFileAlloc(io, path, allocator, .limited(1024));
}
