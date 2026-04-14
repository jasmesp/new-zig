# Zig 0.16 I/O Challenges

This project contains a small workbook for the Zig 0.16.0 `std.Io` changes.
The exercises live in `src/io_0_16_challenges.zig` and run through the normal
Zig test command.

The style is intentionally plain: each exercise is a named `challenge_*`
function with typed arguments, a short tutorial comment, and a test that shows
the expected behavior.

## How To Use It

1. Run the full test suite once:

   ```sh
   zig build test
   ```

2. Open `src/io_0_16_challenges.zig`.

3. Pick one `challenge_*` function.

4. Read the comment above it. The comment explains:

   - what to write
   - what output or behavior is expected
   - why the API matters in Zig 0.16

5. Cover, delete, or ignore the reference implementation inside that function.

6. Write your own implementation using the function name and arguments already
   provided.

7. Run the tests again:

   ```sh
   zig build test
   ```

8. Keep iterating until the test for that challenge passes, then move to the
   next one.

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

## Style Reference

`examples/c_workbook_style_guide.c` is the C workbook example that inspired the
shape of these Zig challenges: clear prompts, named challenge functions, and a
simple expected-behavior harness.

