//! Zig 0.16.0 I/O-as-an-Interface challenges.
//!
//! How to use this like Rustlings:
//! 1. Run `zig build test` once. Everything should pass.
//! 2. Change `show_answer_key` below to `false`.
//! 3. Run `zig build test` again.
//! 4. Replace each `hole(...)` call with your own code, one exercise at a time.
//!
//! The release-note idea to keep in your head: in Zig 0.16, anything that may
//! block, touch the outside world, or introduce nondeterminism is routed through
//! a `std.Io` value chosen by the application.

const std = @import("std");
const Io = std.Io;

pub const show_answer_key = true;

fn hole(comptime T: type, answer: T, comptime hint: []const u8) T {
    if (show_answer_key) return answer;
    @compileError("challenge hole: " ++ hint);
}

// Exercise 01: pass writers, not globals.
//
// Before 0.16, many examples reached for global stdout-ish helpers. The 0.16
// shape is: reusable code accepts an `*Io.Writer`; the application decides
// whether that writer points at stdout, a file, a buffer, a socket, or a test.
pub fn writeBadge(writer: *Io.Writer, name: []const u8) Io.Writer.Error!void {
    try writer.print("zig-0.16/io:{s}", .{name});
}

test "01 writer interfaces make output testable" {
    const name = hole([]const u8, "writer", "pass the badge name as a slice");

    var buffer: [64]u8 = undefined;
    var writer: Io.Writer = .fixed(&buffer);
    try writeBadge(&writer, name);

    try std.testing.expectEqualStrings("zig-0.16/io:writer", writer.buffered());
}

// Exercise 02: fixed readers and writers replace old stream wrappers.
//
// The release notes call out that GenericReader, AnyReader, and
// FixedBufferStream are gone. The tiny in-memory examples now use
// `Io.Reader.fixed` and `Io.Writer.fixed` directly.
pub fn echoUpper(reader: *Io.Reader, writer: *Io.Writer) !void {
    while (true) {
        const byte = reader.takeByte() catch |err| switch (err) {
            error.EndOfStream => return,
            else => |e| return e,
        };
        try writer.writeByte(std.ascii.toUpper(byte));
    }
}

test "02 fixed reader plus fixed writer" {
    var reader: Io.Reader = .fixed(hole([]const u8, "new io", "feed the fixed reader"));

    var buffer: [16]u8 = undefined;
    var writer: Io.Writer = .fixed(&buffer);
    try echoUpper(&reader, &writer);

    try std.testing.expectEqualStrings("NEW IO", writer.buffered());
}

// Exercise 03: `std.testing.io` is a real `std.Io`.
//
// Unit tests in 0.16 get an initialized threaded I/O implementation from
// `std.testing.io`. That makes tests able to exercise APIs that require `Io`
// without inventing an application `main`.
pub fn cancellationCheckpoint(io: Io) Io.Cancelable!void {
    try io.checkCancel();
}

test "03 test code can accept std.Io too" {
    const io = hole(Io, std.testing.io, "use std.testing.io inside tests");
    try cancellationCheckpoint(io);
}

// Exercise 04: entropy is owned by Io.
//
// `std.crypto.random.bytes(&buf)` becomes `io.random(&buf)`. If you need the
// `std.Random` interface, adapt the same `Io` with `std.Random.IoSource`.
pub fn fillToken(io: Io, token: *[8]u8) void {
    io.random(token);
}

test "04 entropy comes from the selected Io implementation" {
    var token = hole([8]u8, [_]u8{0} ** 8, "initialize the token buffer");
    fillToken(std.testing.io, &token);

    var source: std.Random.IoSource = .{ .io = std.testing.io };
    const rng = source.interface();
    const random_byte = rng.int(u8);

    try std.testing.expect(token.len == 8);
    try std.testing.expect(random_byte <= std.math.maxInt(u8));
}

// Exercise 05: clocks and durations moved under Io.
//
// The new names are deliberately explicit: `Io.Timestamp`, `Io.Duration`,
// and `Io.Clock`. Wall-clock timestamps are nondeterministic, so they are read
// through the chosen `Io` implementation.
pub fn elapsedAwake(io: Io, start: Io.Timestamp) Io.Duration {
    return start.untilNow(io, .awake);
}

test "05 time is read through Io" {
    const start = hole(Io.Timestamp, Io.Timestamp.now(std.testing.io, .awake), "capture an Io timestamp");
    const elapsed = elapsedAwake(std.testing.io, start);

    const one_ms = Io.Duration.fromMilliseconds(1);
    try std.testing.expect(elapsed.toNanoseconds() >= 0);
    try std.testing.expectEqual(@as(i64, 1), one_ms.toMilliseconds());
}

// Exercise 06: futures are function-level async.
//
// `Io.async` may run the function now or later; `future.await(io)` is the point
// where you commit to observing the result. Use this for ergonomic task-level
// independence. Reach for `Io.Batch` later when you need lower overhead over
// raw operations.
fn addLater(a: u32, b: u32) u32 {
    return a + b;
}

test "06 async returns a future that must be awaited" {
    var future = Io.async(std.testing.io, addLater, .{
        hole(u32, 19, "first addend"),
        hole(u32, 23, "second addend"),
    });

    try std.testing.expectEqual(@as(u32, 42), future.await(std.testing.io));
}

// Exercise 07: groups are wait-groups with Io semantics.
//
// The 0.16 replacement for `std.Thread.WaitGroup` is `std.Io.Group`. It can be
// awaited or canceled as a whole, and the chosen `Io` implementation decides
// what "blocking" means.
fn bumpCounter(counter: *std.atomic.Value(u32), amount: u32) Io.Cancelable!void {
    _ = counter.fetchAdd(amount, .monotonic);
}

test "07 groups gather independent tasks" {
    var counter: std.atomic.Value(u32) = .init(0);
    var group: Io.Group = .init;

    group.async(std.testing.io, bumpCounter, .{ &counter, hole(u32, 20, "first task amount") });
    group.async(std.testing.io, bumpCounter, .{ &counter, hole(u32, 22, "second task amount") });
    try group.await(std.testing.io);

    try std.testing.expectEqual(@as(u32, 42), counter.load(.monotonic));
}

// Exercise 08: queues are typed, blocking, cancelable coordination points.
//
// `Io.Queue(T)` is many-producer/many-consumer. Even in this tiny test, notice
// that the queue methods take `io`; a full or empty queue may need to block.
test "08 queues coordinate through Io" {
    var storage: [2]u8 = undefined;
    var queue: Io.Queue(u8) = .init(&storage);

    try queue.putOne(std.testing.io, hole(u8, 'Z', "queue one byte"));
    try std.testing.expectEqual(@as(u8, 'Z'), try queue.getOne(std.testing.io));

    queue.close(std.testing.io);
    try std.testing.expectError(error.Closed, queue.getOne(std.testing.io));
}

// Exercise 09: sync primitives moved under Io.
//
// `std.Io.Mutex`, `std.Io.Event`, `std.Io.Condition`, `std.Io.Semaphore`, and
// friends integrate with the same blocking/cancelation model as the rest of
// I/O. Lock-free atomics still do not need `Io`.
test "09 mutex and event operations participate in Io" {
    var mutex: Io.Mutex = .init;
    var protected_value: u32 = 0;

    try mutex.lock(std.testing.io);
    protected_value = hole(u32, 42, "write the protected value while locked");
    mutex.unlock(std.testing.io);

    var event: Io.Event = .unset;
    try std.testing.expect(!event.isSet());
    event.set(std.testing.io);
    try event.wait(std.testing.io);

    try std.testing.expect(event.isSet());
    try std.testing.expectEqual(@as(u32, 42), protected_value);
}

// Exercise 10: filesystem calls now take Io.
//
// The release-note migration pattern is intentionally repetitive:
// `file.close()` becomes `file.close(io)`, opening/creating/deleting via
// `Io.Dir` takes `io`, and file readers/writers are also bound to `io`.
pub fn writeThenReadFile(
    io: Io,
    dir: Io.Dir,
    allocator: std.mem.Allocator,
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

test "10 fs APIs receive Io explicitly" {
    const io = std.testing.io;
    const allocator = std.testing.allocator;
    const path = hole([]const u8, "zig-0.16-io-challenge.tmp", "choose a temp file name");

    const cwd = Io.Dir.cwd();
    defer cwd.deleteFile(io, path) catch {};

    const bytes = try writeThenReadFile(io, cwd, allocator, path, "explicit io everywhere");
    defer allocator.free(bytes);

    try std.testing.expectEqualStrings("explicit io everywhere", bytes);
}
