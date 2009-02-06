# Daniel J. Ellard -- 02/21/94
# add2.asm-- A program that computes and prints the sum
#       of two numbers specified at runtime by the user.
# Registers used:
#       $t0     - used to hold the first number.
#       $t1     - used to hold the second number.
#       $t2     - used to hold the sum of the $t1 and $t2.
#       $v0     - syscall parameter and return value.
#       $a0     - syscall parameter.
    .globl main
    .text
main:
        ## Get first number from user, put into $t0.
        li      $v0, 5          # load syscall read_int into $v0.
        syscall                 # make the syscall.
        move    $t0, $v0        # move the number read into $t0.
        ## Get second number from user, put into $t1.
        li      $v0, 5          # load syscall read_int into $v0.
        syscall                 # make the syscall.
        move    $t1, $v0        # move the number read into $t1.
        add     $t2, $t0, $t1   # compute the sum.
        ## Print out $t2.
        
        
        
        li      $t0, 0x0054
        sw      $t0, ($gp)
        li      $t0, 0x0049
        sw      $t0, 4($gp)
        sw      $t2, 8($gp)
        li      $t0, 10
        sw      $t0, 12($gp)
        
        li      $t0, 0
        li      $t1, 4
loop:   
        
        add     $a0, $gp, $t0
        li      $v0, 4          # load syscall print_int into $v0.
        syscall                 # make the syscall.
        addi    $t0, $t0, 4
        addi    $t1, $t1, -1
        bgez    $t1, loop
        
        li      $v0, 10         # syscall code 10 is for exit.
        syscall                 # make the syscall.
# end of add2.asm.
