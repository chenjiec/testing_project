#include "riscv_test.h"

.global main
main:

// only execute on first core
csrr x1, mhartid
andi x1, x1, 0x1f
bnez x1, finish

// the test pass/fail logic depends on the bne instruction only, so do a quick check first
addi x5, x0, 1
addi x6, x0, 1
bne x5, x6, fail
bne x5, x0, bne_ok
fail: // also catches remaining branches/jumps to the fail label in the tests
.byte 0,0,0,0
bne_ok:


// source files

#undef  TESTSUITE
#define TESTSUITE simple
TEST(simple);
#include "tests/simple.S"

// if you add other tests, remember to add them here!

//#undef  TESTSUITE
//#define TESTSUITE mytest2
//TEST(mytest2);
//#include "tests/mytest2.S"



  .text
finish:
  FIX_STACK;

  // synch barrier
  //li x10, 0
  //jal x1, wait_barrier_event_buff

  jal print_test_summary
  jal x0, (. - 4)
