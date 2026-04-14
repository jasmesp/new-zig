//! Zig 0.16.0 I/O-as-an-Interface workbook.
//!
//! This file is intentionally shaped like a small workbook instead of a
//! scavenger hunt. Each exercise has a named `challenge_*` function, typed
//! arguments, and a comment prompt that tells you what to practice.
//!
//! The reference implementations are filled in so the project has a clean
//! baseline. To practice, pick a challenge, cover or delete the implementation
//! under the prompt, write your own version, and run `zig build test`.
//!
//! Big idea from the Zig 0.16.0 release notes: anything that may block, touch
//! the outside world, or introduce nondeterminism is routed through a `std.Io`
//! value chosen by the application.

const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

// Challenge 1: Write to an Io.Writer
//
// Write exactly this text into `writer`, using the provided name:
//
//   zig-0.16/io:writer
//
// Why this matters:
// Reusable Zig 0.16 code should usually accept `*Io.Writer` instead of
// reaching for a global stdout. The caller decides whether this writes to a
// terminal, file, socket, buffer, or test harness.
pub fn challenge_01_write_badge(writer: *Io.Writer, name: []const u8) Io.Writer.Error!void {
    try writer.print("zig-0.16/io:{s}", .{name});
}

test "01 write to an Io.Writer" {
    var buffer: [64]u8 = undefined;
    var writer: Io.Writer = .fixed(&buffer);

    try challenge_01_write_badge(&writer, "writer");

    try std.testing.expectEqualStrings("zig-0.16/io:writer", writer.buffered());
}

// Challenge 2: Fixed readers and fixed writers
//
// Read every byte from `reader`, uppercase ASCII letters, and write the result
// to `writer`.
//
// Expected behavior:
//
//   input:  "new io"
//   output: "NEW IO"
//
// Why this matters:
// Zig 0.16 removed old stream wrapper names such as FixedBufferStream,
// GenericReader, and AnyReader. Small in-memory examples now use
// `Io.Reader.fixed` and `Io.Writer.fixed` directly.
pub fn challenge_02_echo_upper(reader: *Io.Reader, writer: *Io.Writer) !void {
    while (true) {
        const byte = reader.takeByte() catch |err| switch (err) {
            error.EndOfStream => return,
            else => |e| return e,
        };
        try writer.writeByte(std.ascii.toUpper(byte));
    }
}

test "02 fixed reader plus fixed writer" {
    var reader: Io.Reader = .fixed("new io");
    var buffer: [16]u8 = undefined;
    var writer: Io.Writer = .fixed(&buffer);

    try challenge_02_echo_upper(&reader, &writer);

    try std.testing.expectEqualStrings("NEW IO", writer.buffered());
}

// Challenge 3: Use the test Io implementation
//
// Return the `std.Io` value that Zig provides inside tests.
//
// Expected behavior:
// The returned value can be passed to functions that require `Io`, such as a
// cancellation checkpoint.
//
// Why this matters:
// In Zig 0.16, library code takes an `Io` parameter. Tests can pass
// `std.testing.io` instead of building their own application runtime.
pub fn challenge_03_testing_io() Io {
    return std.testing.io;
}

fn cancellationCheckpoint(io: Io) Io.Cancelable!void {
    try io.checkCancel();
}

test "03 std.testing.io is a real Io" {
    try cancellationCheckpoint(challenge_03_testing_io());
}

// Challenge 4: Random bytes come from Io
//
// Fill `token` with random bytes using the provided `io`.
//
// Why this matters:
// The old mental model of "ask a global random source" is not the 0.16 shape.
// Randomness is nondeterministic, so it belongs to the selected `Io`
// implementation.
pub fn challenge_04_fill_token(io: Io, token: *[8]u8) void {
    io.random(token);
}

test "04 randomness comes from the selected Io implementation" {
    var token = [_]u8{0} ** 8;

    challenge_04_fill_token(std.testing.io, &token);

    var source: std.Random.IoSource = .{ .io = std.testing.io };
    const rng = source.interface();
    const random_byte = rng.int(u8);

    try std.testing.expect(token.len == 8);
    try std.testing.expect(random_byte <= std.math.maxInt(u8));
}

// Challenge 5: Read time through Io
//
// Return the elapsed awake-clock duration from `start` until now.
//
// Why this matters:
// Time is nondeterministic. Zig 0.16 makes that visible with `Io.Timestamp`,
// `Io.Duration`, and `Io.Clock`, all read through the selected `Io`.
pub fn challenge_05_elapsed_awake(io: Io, start: Io.Timestamp) Io.Duration {
    return start.untilNow(io, .awake);
}

test "05 time is read through Io" {
    const start = Io.Timestamp.now(std.testing.io, .awake);
    const elapsed = challenge_05_elapsed_awake(std.testing.io, start);

    const one_ms = Io.Duration.fromMilliseconds(1);
    try std.testing.expect(elapsed.toNanoseconds() >= 0);
    try std.testing.expectEqual(@as(i64, 1), one_ms.toMilliseconds());
}

fn addLater(a: u32, b: u32) u32 {
    return a + b;
}

// Challenge 6: Await a future
//
// Use `Io.async` to call `addLater` with `a` and `b`, then await the future and
// return the result.
//
// Expected behavior:
// Calling this with 19 and 23 returns 42.
//
// Why this matters:
// `Io.async` gives a function-level future. The work may run now or later; the
// future's `await(io)` is where you observe the result.
pub fn challenge_06_add_with_future(io: Io, a: u32, b: u32) u32 {
    var future = Io.async(io, addLater, .{ a, b });
    return future.await(io);
}

test "06 async returns a future that can be awaited" {
    try std.testing.expectEqual(@as(u32, 42), challenge_06_add_with_future(std.testing.io, 19, 23));
}

fn bumpCounter(counter: *std.atomic.Value(u32), amount: u32) Io.Cancelable!void {
    _ = counter.fetchAdd(amount, .monotonic);
}

// Challenge 7: Gather tasks with Io.Group
//
// Spawn two grouped tasks. Each task should add one amount to `counter`.
// Await the group before returning.
//
// Expected behavior:
// Calling this with 20 and 22 leaves the counter at 42.
//
// Why this matters:
// `std.Io.Group` is the 0.16 task-group / wait-group shape. A group is awaited
// or canceled as a whole, and the selected `Io` decides how waiting works.
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

test "07 groups gather independent tasks" {
    var counter: std.atomic.Value(u32) = .init(0);

    try challenge_07_bump_with_group(std.testing.io, &counter, 20, 22);

    try std.testing.expectEqual(@as(u32, 42), counter.load(.monotonic));
}

// Challenge 8: Round-trip one item through an Io.Queue
//
// Create a small `Io.Queue(u8)`, put `item` into it, get one item back, close
// the queue, and return the item you received.
//
// Why this matters:
// Queues can block when full or empty, so the queue operations take `io`.
pub fn challenge_08_round_trip_queue(io: Io, item: u8) !u8 {
    var storage: [2]u8 = undefined;
    var queue: Io.Queue(u8) = .init(&storage);

    try queue.putOne(io, item);
    const received = try queue.getOne(io);
    queue.close(io);
    return received;
}

test "08 queues coordinate through Io" {
    try std.testing.expectEqual(@as(u8, 'Z'), try challenge_08_round_trip_queue(std.testing.io, 'Z'));
}

// Challenge 9: Protect shared state, then signal an event
//
// Lock `mutex`, write `new_value` into `value`, unlock the mutex, set `event`,
// and wait for the event.
//
// Expected behavior:
// After this function returns, `value.*` equals `new_value` and the event is set.
//
// Why this matters:
// Zig 0.16 synchronization primitives such as `Io.Mutex`, `Io.Event`, and
// `Io.Condition` participate in the same blocking/cancellation model as I/O.
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

test "09 mutex and event operations participate in Io" {
    var mutex: Io.Mutex = .init;
    var event: Io.Event = .unset;
    var protected_value: u32 = 0;

    try challenge_09_set_value_and_signal(std.testing.io, &mutex, &event, &protected_value, 42);

    try std.testing.expect(event.isSet());
    try std.testing.expectEqual(@as(u32, 42), protected_value);
}

// Challenge 10: Filesystem APIs take Io
//
// Create or truncate `path` inside `dir`, write `contents`, flush the file
// writer, close the file, then read the file back into an allocated buffer.
//
// Expected behavior:
// The returned bytes match `contents`. The caller owns the returned allocation.
//
// Why this matters:
// In Zig 0.16, filesystem operations are explicit about I/O:
// `dir.createFile(io, ...)`, `file.close(io)`, `file.writer(io, ...)`,
// `dir.readFileAlloc(io, ...)`, and so on.
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

test "10 filesystem APIs receive Io explicitly" {
    const io = std.testing.io;
    const allocator = std.testing.allocator;
    const path = "zig-0.16-io-challenge.tmp";

    const cwd = Io.Dir.cwd();
    defer cwd.deleteFile(io, path) catch {};

    const bytes = try challenge_10_write_then_read_file(io, cwd, allocator, path, "explicit io everywhere");
    defer allocator.free(bytes);

    try std.testing.expectEqualStrings("explicit io everywhere", bytes);
}
