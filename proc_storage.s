# Tim Henderson
# proc_storage.s handles storing proccess in PCBs

# Proccess Control Block Structure:
# --------------------
# | Nice   | State   | 1
# --------------------
# | Process Number   | 2
# --------------------
# | Program Counter  | 3
# --------------------
# | Base Address     | 4
# | Top Address      | 5
# --------------------
# | at               | 6
# | sp               | 7
# | fp               | 8
# | gp               | 9
# | ra               | 10
# | v0               | 11
# | v1               | 12
# | a0               | 13
# | ...              |
# | a3               | 16
# | t0               | 17
# | ...              |
# | t9               | 26
# | s0               | 27
# | ...              |
# | s7               | 34
# --------------------

# states:
# 0 -> new
# 1 -> ready
# 2 -> running
# 3 -> waiting
# 4 -> halted
# 5 -> marked for clean up

    .kdata
pcb_size: .word 0x88            # 136 = 34 * 4
next_proc_num: .word 0x0        # start proccess number at 0

    .ktext
    # create_pcb() return $v0 -> addr of pcb
create_pcb:
    li      $v0, 9              # system call code for sbrk
    lw      $a0, pcb_size       # amount
    syscall                     # make the call
    
    jr      $ra

    # save_proc(pcb_address, program_start, program_len) -> Null
save_proc:    
    addu    $t0, $a0, 0         # move the address of the PCB to $t0
    lui     $t1, 5              # set the default nice level to 5
    ori     $t1, $t1, 0         # load the state "new" into the lower part of $t1
    sw      $t1, 0($t0)         # save the nice and state into the pcb
    
    lw      $t1, next_proc_num  # load the next proccess number into $t1
    sw      $t1, 4($t0)         # save the proc number in the pcb
    
    mfc0    $t1, $14            # get the EPC register
    sw      $t1, 8($t0)         # save the program counter number in the pcb
    
    sw      $a1, 12($t0)        # save the start of the program in the pcb
    
    addu    $t1, $a1, $a2       # add the length of the program to where it starts
    sw      $t1, 16($t0)        # save the end of the program in the pcb
    
    sw      $k1, 20($t0)        # save $at into the PCB ($at is saved to $k1
                                #   at the start of the interrupt)
    
    lw      $t1, __save_sp      # load the saved stack pointer
    sw      $t1, 24($t0)        # save it in the PCB
    
    lw      $t1, __save_fp      # load the saved frame pointer
    sw      $t1, 28($t0)        # save it in the PCB
    
    lw      $t1, __save_gp      # load the saved global pointer
    sw      $t1, 32($t0)        # save it in the PCB
    
    lw      $t1, __save_ra      # load the saved return address pointer
    sw      $t1, 36($t0)        # save it in the PCB
    
    lw      $t1, __save_v0      # load the saved $v0
    sw      $t1, 40($t0)        # save it in the PCB
    
    lw      $t1, __save_v1      # load the saved $v1
    sw      $t1, 44($t0)        # save it in the PCB
    
    lw      $t1, __save_a0      # load the saved $a0
    sw      $t1, 48($t0)        # save it in the PCB
    
    lw      $t1, __save_a1      # load the saved $a1
    sw      $t1, 52($t0)        # save it in the PCB
    
    lw      $t1, __save_a2      # load the saved $a2
    sw      $t1, 56($t0)        # save it in the PCB
    
    lw      $t1, __save_a3      # load the saved $a3
    sw      $t1, 60($t0)        # save it in the PCB
    
    lw      $t1, __save_t0      # load the saved $t0
    sw      $t1, 64($t0)        # save it in the PCB
    
    lw      $t1, __save_t1      # load the saved $t1
    sw      $t1, 68($t0)        # save it in the PCB
    
    lw      $t1, __save_t2      # load the saved $t2
    sw      $t1, 72($t0)        # save it in the PCB
    
    lw      $t1, __save_t3      # load the saved $t3
    sw      $t1, 76($t0)        # save it in the PCB
    
    sw      $t4, 80($t0)        # save $t4 in the PCB
    sw      $t5, 84($t0)        # save $t5 in the PCB
    sw      $t6, 88($t0)        # save $t6 in the PCB
    sw      $t7, 92($t0)        # save $t7 in the PCB
    sw      $t8, 96($t0)        # save $t8 in the PCB
    sw      $t9, 100($t0)       # save $t9 in the PCB
    
    lw      $t1, __save_s0      # load the saved $s0
    sw      $t1, 104($t0)       # save it in the PCB
    
    lw      $t1, __save_s1      # load the saved $s1
    sw      $t1, 108($t0)       # save it in the PCB
    
    lw      $t1, __save_s2      # load the saved $s2
    sw      $t1, 112($t0)       # save it in the PCB
    
    lw      $t1, __save_s3      # load the saved $s3
    sw      $t1, 116($t0)       # save it in the PCB
    
    sw      $s4, 120($t0)       # save $s4 in the PCB
    sw      $s5, 124($t0)       # save $s5 in the PCB
    sw      $s6, 128($t0)       # save $s6 in the PCB
    sw      $s7, 132($t0)       # save $s7 in the PCB
    
    jr      $ra
    
    # restore_proc(pcb_address) -> $v0 = program_start, $v1 = program_end
restore_proc:
    addu    $t0, $a0, 0         # move the address of the PCB to $t0
    
    sw      $t1, 8($t0)         # get the program counter from pcb
    mtc0    $t1, $14            # save it in the EPC register in the co-proc
    
    lw      $v0, 12($t0)        # load the start of the program from the pcb
    lw      $v1, 16($t0)        # load the end of the program from the pcb
    
    lw      $k1, 20($t0)        # load $at from the PCB ($at will be restored from
                                #       $k1 at the end of the exception_handler)
    
    lw      $t1, 24($t0)        # load the saved stack pointer
    sw      $t1, __save_sp      # save it into its imm location
    
    lw      $t1, 28($t0)        # load the saved frame pointer
    sw      $t1, __save_fp      # save it into its imm location
    
    lw      $t1, 32($t0)        # load the saved global pointer
    sw      $t1, __save_gp      # 
    
    lw      $t1, 36($t0)        # load the saved return address pointer
    sw      $t1, __save_ra      # 
    
    lw      $t1, 40($t0)        # load the saved $v0
    sw      $t1, __save_v0      # 
    
    lw      $t1, 44($t0)        # load the saved $v1
    sw      $t1, __save_v1      # 
    
    lw      $t1, 48($t0)        # load the saved $a0
    sw      $t1, __save_a0      # 
    
    lw      $t1, 52($t0)        # load the saved $a1
    sw      $t1, __save_a1      # 
    
    lw      $t1, 56($t0)        # load the saved $a2
    sw      $t1, __save_a2      # 
    
    lw      $t1, 60($t0)        # load the saved $a3
    sw      $t1, __save_a3      # 
    
    lw      $t1, 64($t0)        # load the saved $t0
    sw      $t1, __save_t0      #
    
    lw      $t1, 68($t0)        # load the saved $t1
    sw      $t1, __save_t1      # 
    
    lw      $t1, 72($t0)        # load the saved $t2
    sw      $t1, __save_t2      #
    
    lw      $t1, 76($t0)        # load the saved $t3
    sw      $t1, __save_t3      # 
    
    lw      $t4, 80($t0)        # load $t4 from the PCB
    lw      $t5, 84($t0)        # load $t5 from the PCB
    lw      $t6, 88($t0)        # load $t6 from the PCB
    lw      $t7, 92($t0)        # load $t7 from the PCB
    lw      $t8, 96($t0)        # load $t8 from the PCB
    lw      $t9, 100($t0)       # load $t9 from the PCB
    
    lw      $t1, 104($t0)       # load the saved $s0
    sw      $t1, __save_s0      # 
    
    lw      $t1, __save_s1      # load the saved $s1
    sw      $t1, 108($t0)       #
    
    lw      $t1, 112($t0)       # load the saved $s2
    sw      $t1, __save_s2      # 
    
    lw      $t1, 116($t0)       # load the saved $s3
    sw      $t1, __save_s3      # 
    
    lw      $s4, 120($t0)       # load $s4 from the PCB
    lw      $s5, 124($t0)       # load $s5 from the PCB
    lw      $s6, 128($t0)       # load $s6 from the PCB
    lw      $s7, 132($t0)       # load $s7 from the PCB
    
    jr      $ra


proc_status:
    nop
proc_nice:
    nop