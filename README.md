# Zig 0.16 I/O Challenges

This project contains a Rustlings-style tutorial for the Zig 0.16.0
`std.Io` changes. The exercises live in `src/io_0_16_challenges.zig` and run
through the normal Zig test command.

## How To Use It

1. Run the full test suite once:

   ```sh
   zig build test
   ```

2. Open `src/io_0_16_challenges.zig`.

3. Change:

   ```zig
   pub const show_answer_key = true;
   ```

   to:

   ```zig
   pub const show_answer_key = false;
   ```

4. Run the tests again:

   ```sh
   zig build test
   ```

5. Replace each `hole(...)` call with your own code, one exercise at a time.

6. Keep rerunning `zig build test` until the suite passes.

## What The Exercises Cover

- Passing `*std.Io.Writer` instead of writing to globals.
- Using `std.Io.Reader.fixed` and `std.Io.Writer.fixed`.
- Using `std.testing.io` inside tests.
- Getting randomness from `io.random`.
- Adapting `std.Io` into `std.Random` with `std.Random.IoSource`.
- Reading time with `std.Io.Timestamp`, `std.Io.Duration`, and `std.Io.Clock`.
- Spawning and awaiting function-level futures with `Io.async`.
- Managing task sets with `std.Io.Group`.
- Coordinating producers and consumers with `std.Io.Queue`.
- Using `std.Io.Mutex` and `std.Io.Event`.
- Calling filesystem APIs with an explicit `io` parameter.

The core idea from Zig 0.16.0 is that work which may block, touch the outside
world, or introduce nondeterminism is routed through an application-selected
`std.Io` implementation.

