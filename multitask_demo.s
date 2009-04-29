# Steve Johnson
# simple demo for multitasking

.data
count_string_1: .asciiz "Process 1 count: "
count_string_2: .asciiz "                      Process 2 count: "

.text
    .globl main
main:
{
    #the load_process procedure simply takes a label address
    la $a0 process_1
    call load_process
    
    la $a0 process_2
    call load_process
    
    #take this process out of the process list and free its PCB and stack
    exit
}

.text
#print_test(n, prefix_string)
#   note that this function is called by two separate processes
#   and yet nothing conflicts, it all works fine
print_test:
{
    addu $s0 $a0 $zero
    addu $a0 $a1 $zero
    call print
    addu $a0 $s0 $zero
    call print_int
    li $a0 10
    call print_char
    return
}

.text
#counts from 0 to 2 and then exits
process_1:
{
    @loopvar = $s0
    li @loopvar 0
    loop:
        addu $a0 @loopvar $zero
        la $a1 count_string_1
        call print_test
        addi @loopvar @loopvar 1
        wait
        li $a0 3
        beq @loopvar $a0 killme
    b loop
    
    killme:
    exit
}

.text
#counts from 0 to 9 and then exits
process_2:
{
    @loopvar = $s0
    li @loopvar 0
    loop:
        addu $a0 @loopvar $zero
        la $a1 count_string_2
        call print_test
        addi @loopvar @loopvar 1
        wait
        li $a0 10
        beq @loopvar $a0 killme
    b loop
    
    killme:
    exit
}
