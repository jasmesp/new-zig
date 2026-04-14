/*
Rapid-Fire C Challenges Workbook

How to use this file:
1. Open this file and work inside the challenge functions.
2. Read the commented prompt at the top of each function.
3. Write your solution below that prompt.
4. Compile and run this file with cc.
5. Compare the "Expected" section to the "Actual" section.

This file compiles before you start. The challenge functions are stubs so you
can fill them in one at a time without reorganizing anything.
*/

#include <stdio.h>

void challenge_01(void) {
  /* Challenge 1: Hello, stdout
     Write code that prints exactly:
     Hello, world!
  */

  /* TODO: write your solution here */
}

void challenge_02(void) {
  /* Challenge 2: Two lines
     Write code that prints exactly:
     C is fun
     Let's build
  */

  /* TODO: write your solution here */
}

void challenge_03(void) {
  /* Challenge 3: Simple math
     Store 17 and 25 in variables, add them, and print exactly:
     42
  */

  /* TODO: write your solution here */
}

void challenge_04(void) {
  /* Challenge 4: Integer division
     Using variables, divide 29 by 5 with integer division and print exactly:
     5
  */

  /* TODO: write your solution here */
}

void challenge_05(void) {
  /* Challenge 5: Remainder
     Using variables, compute 29 % 5 and print exactly:
     4
  */

  /* TODO: write your solution here */
}

void challenge_06(void) {
  /* Challenge 6: Floating output
     Store 7 and 2, divide them as floating-point values, and print exactly:
     3.50
  */

  /* TODO: write your solution here */
}

void challenge_07(void) {
  /* Challenge 7: Character basics
     Store the character 'Z' in a variable and print exactly:
     Z
  */

  /* TODO: write your solution here */
}

void challenge_08(void) {
  /* Challenge 8: ASCII value
     Store the character 'A' and print its integer ASCII value exactly:
     65
  */

  /* TODO: write your solution here */
}

void challenge_09(void) {
  /* Challenge 9: If statement
     Store 12 in a variable. If it is greater than 10, print YES; otherwise
     print NO. Required output: YES
  */

  /* TODO: write your solution here */
}

void challenge_10(void) {
  /* Challenge 10: Even or odd
     Store 19 in a variable and print exactly:
     odd
  */

  /* TODO: write your solution here */
}

void challenge_11(void) {
  /* Challenge 11: For loop count
     Use a for loop to print the numbers 1 through 5 on one line exactly like
     this: 1 2 3 4 5
  */

  /* TODO: write your solution here */
}

void challenge_12(void) {
  /* Challenge 12: While loop sum
     Use a while loop to add the numbers 1 through 10 and print exactly:
     55
  */

  /* TODO: write your solution here */
}

void challenge_13(void) {
  /* Challenge 13: Countdown
     Use a loop to print exactly:
     5 4 3 2 1
  */

  /* TODO: write your solution here */
}

void challenge_14(void) {
  /* Challenge 14: Multiplication table row
     Print the 7 times table from 7 x 1 through 7 x 5 exactly like this:
     7 14 21 28 35
  */

  /* TODO: write your solution here */
}

void challenge_15(void) {
  /* Challenge 15: Star line
     Use a loop to print exactly 8 stars on one line:
     ********
  */

  /* TODO: write your solution here */
}

void challenge_16(void) {
  /* Challenge 16: Sum an array
     Create an int array with these values: 3, 1, 4, 1, 5
     Add them with a loop and print exactly:
     14
  */

  /* TODO: write your solution here */
}

void challenge_17(void) {
  /* Challenge 17: Find the largest
     Create an int array with these values: 8, 2, 9, 4, 7
     Find the largest value and print exactly:
     9
  */

  /* TODO: write your solution here */
}

void challenge_18(void) {
  /* Challenge 18: Reverse an array
     Create an int array with these values: 1, 2, 3, 4, 5
     Print the values in reverse order on one line exactly like this:
     5 4 3 2 1
  */

  /* TODO: write your solution here */
}

void challenge_19(void) {
  /* Challenge 19: C string length
     Store the string "banana" and, without hard-coding the answer, print its
     length exactly:
     6
  */

  /* TODO: write your solution here */
}

void challenge_20(void) {
  /* Challenge 20: Count vowels
     Store the string "Education" and count the vowels (a, e, i, o, u,
     case-insensitive). Print exactly:
     5
  */

  /* TODO: write your solution here */
}

void challenge_21(void) {
  /* Challenge 21: Uppercase conversion
     Store the string "codex" and convert it to uppercase without changing the
     printed text by hand. Print exactly: CODEX
  */

  /* TODO: write your solution here */
}

void challenge_22(void) {
  /* Challenge 22: Function with return
     Write a function that takes two ints and returns the larger one.
     Call it with 14 and 9, then print exactly:
     14
  */

  /* TODO: write your solution here */
}

void challenge_23(void) {
  /* Challenge 23: Swap with pointers
     Create two ints: 3 and 8. Write a function that swaps them using pointers.
     After swapping, print exactly:
     8 3
  */

  /* TODO: write your solution here */
}

void challenge_24(void) {
  /* Challenge 24: Struct total
     Create a struct named Item with fields: name and price.
     Make two items priced 12 and 18, add the prices, and print exactly:
     30
  */

  /* TODO: write your solution here */
}

void challenge_25(void) {
  /* Challenge 25: File + dynamic memory
     Create a program that:
     - uses malloc to allocate space for 5 ints
     - stores 2, 4, 6, 8, 10
     - writes them to a text file, one line as: 2 4 6 8 10
     - reopens the file, reads the numbers back, sums them, and prints exactly:
     30
  */

  /* TODO: write your solution here */
}

static void print_separator(int number) {
  printf("\n===== Challenge %d =====\n", number);
}

int main(void) {
  print_separator(1);
  printf("Expected:\nHello, world!\n");
  printf("Actual:\n");
  challenge_01();
  printf("\n");

  print_separator(2);
  printf("Expected:\nC is fun\nLet's build\n");
  printf("Actual:\n");
  challenge_02();
  printf("\n");

  print_separator(3);
  printf("Expected:\n42\n");
  printf("Actual:\n");
  challenge_03();
  printf("\n");

  print_separator(4);
  printf("Expected:\n5\n");
  printf("Actual:\n");
  challenge_04();
  printf("\n");

  print_separator(5);
  printf("Expected:\n4\n");
  printf("Actual:\n");
  challenge_05();
  printf("\n");

  print_separator(6);
  printf("Expected:\n3.50\n");
  printf("Actual:\n");
  challenge_06();
  printf("\n");

  print_separator(7);
  printf("Expected:\nZ\n");
  printf("Actual:\n");
  challenge_07();
  printf("\n");

  print_separator(8);
  printf("Expected:\n65\n");
  printf("Actual:\n");
  challenge_08();
  printf("\n");

  print_separator(9);
  printf("Expected:\nYES\n");
  printf("Actual:\n");
  challenge_09();
  printf("\n");

  print_separator(10);
  printf("Expected:\nodd\n");
  printf("Actual:\n");
  challenge_10();
  printf("\n");

  print_separator(11);
  printf("Expected:\n1 2 3 4 5\n");
  printf("Actual:\n");
  challenge_11();
  printf("\n");

  print_separator(12);
  printf("Expected:\n55\n");
  printf("Actual:\n");
  challenge_12();
  printf("\n");

  print_separator(13);
  printf("Expected:\n5 4 3 2 1\n");
  printf("Actual:\n");
  challenge_13();
  printf("\n");

  print_separator(14);
  printf("Expected:\n7 14 21 28 35\n");
  printf("Actual:\n");
  challenge_14();
  printf("\n");

  print_separator(15);
  printf("Expected:\n********\n");
  printf("Actual:\n");
  challenge_15();
  printf("\n");

  print_separator(16);
  printf("Expected:\n14\n");
  printf("Actual:\n");
  challenge_16();
  printf("\n");

  print_separator(17);
  printf("Expected:\n9\n");
  printf("Actual:\n");
  challenge_17();
  printf("\n");

  print_separator(18);
  printf("Expected:\n5 4 3 2 1\n");
  printf("Actual:\n");
  challenge_18();
  printf("\n");

  print_separator(19);
  printf("Expected:\n6\n");
  printf("Actual:\n");
  challenge_19();
  printf("\n");

  print_separator(20);
  printf("Expected:\n5\n");
  printf("Actual:\n");
  challenge_20();
  printf("\n");

  print_separator(21);
  printf("Expected:\nCODEX\n");
  printf("Actual:\n");
  challenge_21();
  printf("\n");

  print_separator(22);
  printf("Expected:\n14\n");
  printf("Actual:\n");
  challenge_22();
  printf("\n");

  print_separator(23);
  printf("Expected:\n8 3\n");
  printf("Actual:\n");
  challenge_23();
  printf("\n");

  print_separator(24);
  printf("Expected:\n30\n");
  printf("Actual:\n");
  challenge_24();
  printf("\n");

  print_separator(25);
  printf("Expected:\n30\n");
  printf("Actual:\n");
  challenge_25();
  printf("\n");

  return 0;
}
