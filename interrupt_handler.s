# Tim Henderson & Steve Johnson
# interrupt handler
# This is where the magic happens

    .data
__save_gp:  .word 0
__save_sp:  .word 0
__save_fp:  .word 0
__save_ra:  .word 0
__save_t0:  .word 0
__save_t1:  .word 0
__save_t2:  .word 0
__save_t3:  .word 0
__save_t4:  .word 0
__save_t5:  .word 0
__save_t6:  .word 0
__save_t7:  .word 0
__save_t8:  .word 0
__save_t9:  .word 0
__save_s0:  .word 0
__save_s1:  .word 0
__save_s2:  .word 0
__save_s3:  .word 0
__save_s4:  .word 0
__save_s5:  .word 0
__save_s6:  .word 0
__save_s7:  .word 0
__save_HCB_ADDR: .word 0

__k_HCB_ADDR: .word 0


    .text
save_state:
{
    sw      $gp __save_gp       # save the pointer registers
    sw      $sp __save_sp
    sw      $fp __save_fp
    sw      $ra __save_ra
    
    sw      $t0 __save_t0       # save $t0 - $t3
    sw      $t1 __save_t1
    sw      $t2 __save_t2
    sw      $t3 __save_t3
    sw      $t4 __save_t4
    sw      $t5 __save_t5
    sw      $t6 __save_t6
    sw      $t7 __save_t7
    sw      $t8 __save_t8
    sw      $t9 __save_t9
    sw      $s0 __save_s0       # save $s0 - $s3
    sw      $s1 __save_s1
    sw      $s2 __save_s2
    sw      $s3 __save_s3
    sw      $s4 __save_s4       # save $s0 - $s3
    sw      $s5 __save_s5
    sw      $s6 __save_s6
    sw      $s7 __save_s7
    
    j       save_state_return
}
    .text
restore_state:
{
    lw      $t0 __save_t0       # load $t0 - $t3
    lw      $t1 __save_t1
    lw      $t2 __save_t2
    lw      $t3 __save_t3
    lw      $t4 __save_t4
    lw      $t5 __save_t5
    lw      $t6 __save_t6
    lw      $t7 __save_t7
    lw      $t8 __save_t8
    lw      $t9 __save_t9
    lw      $s0 __save_s0       # load $s0 - $s3
    lw      $s1 __save_s1
    lw      $s2 __save_s2
    lw      $s3 __save_s3
    lw      $s4 __save_s4
    lw      $s5 __save_s5
    lw      $s6 __save_s6
    lw      $s7 __save_s7
    
    lw      $gp __save_gp       # load the pointer registers
    lw      $sp __save_sp
    lw      $fp __save_fp
    lw      $ra __save_ra
    
    j       restore_state_return
}

    .data
__int_msg: .asciiz "interrupt handler entered\n"

    .text
interrupt_handler:
    j       save_state
save_state_return:
{
    la $a0 current_pcb
    lw $a0 0($a0)
    li $a1 0
    call save_proc
    
    ######### SAVE THE STACK #########
    {
        @hcb_addr = $s1
        @pcb_id = $s2
        @sp = $s3
        @error = $s4
        @stack_id = $s5
        @stackheap = $s6
        
        @curpcb_addr = $t0
        
        khcb_getaddr @hcb_addr
        la @curpcb_addr current_pcb
        lw @pcb_id      0(@curpcb_addr)
        geti    7 @pcb_id @hcb_addr @sp @error
        addu    $a0 @sp $zero
        call save_stack
        addu    @stack_id $v0 $zero
        
        puti    4 @pcb_id @hcb_addr @stack_id @error
        
    }
    ######### SAVE THE STACK #########
    
    ######### PERFORM MAGIC #########
    
    #Check kernel message sent to interrupt handler
    la $a0 KMSG
    lw $a0 0($a0)
    beqz $a0 km_clock_interrupt
    li $a1 1
    beq $a0 $a1 km_wait
    li $a1 2
    beq $a0 $a1 km_exit
    b reset_kmsg #default: do nothing
    
    km_wait:
        {
            @khcb_addr = $s0
            @h = $s1
            @err = $s2
            @pid = $s3
            @pcb = $s4
            @mem_id = $s5
            khcb_getaddr @khcb_addr
            
            #Load the head of the process linked list
            geti 1 $zero @khcb_addr @h @err
            bnez @err ch_err
            
            #Load the currently active process's PID
            la $a0 current_pid
            lw @pid 0($a0)
            
            #Linear search for the current node
            #Note: this is stupid and inefficient. We should just be storing the node mem_id.
            #However, we already gave the demo and wrote the report, and I'm busy.
            addu $a0 @h $zero
            addu $a1 @pid $zero #this is the old pid
            call ll_find_pid
            addu @mem_id $v0 $zero
            
            #Get the next node in the list (i.e. next process)
            addu $a0 @h $zero
            addu $a1 @mem_id $zero  #where mem_id is a list node
            call ll_next
            addu @mem_id $v0 $zero
            
            #Load the new PID and PCB ID
            geti 1 @mem_id @khcb_addr @pid @err
            bnez @err ch_err
            geti 2 @mem_id @khcb_addr @pcb @err
            bnez @err ch_err
            
            #Save the current PID and current PCB back to kernel data
            la $a0 current_pid
            sw @pid 0($a0)
            la $a0 current_pcb
            sw @pcb 0($a0)
            
            b noerr
                ch_err:
                    println errmsg
                    kill_jist
                .data
                    errmsg: .asciiz "error in cmgr_wait"
                .text
            noerr:
        }
        b reset_kmsg
    km_exit:
        {
            #This does pretty much the same thing as km_wait with a few notable differences
            @khcb_addr = $s0
            @h = $s1
            @err = $s2
            @pid = $s3
            @pcb = $s4
            @mem_id = $s5
            khcb_getaddr @khcb_addr
            
            geti 1 $zero @khcb_addr @h @err
            bnez @err ex_err
            
            la $a0 current_pid
            lw @pid 0($a0)
            
            addu $a0 @h $zero
            addu $a1 @pid $zero #this is the old pid
            call ll_find_pid
            addu @mem_id $v0 $zero
            
            #Remove the current process!
            addu $a0 @h $zero
            addu $a1 @mem_id $zero  #where mem_id is the list node to remove
            call ll_remove
            addu @h $v0 $zero
            
            #Write the (possibly) new address of the list head back to kernel data
            khcb_getaddr @khcb_addr
            puti 1 $zero @khcb_addr @h @err
            
            #Go back to list head
            addu @mem_id @h $zero
            geti 1 @mem_id @khcb_addr @pid @err
            bnez @err ex_err
            geti 2 @mem_id @khcb_addr @pcb @err
            bnez @err ex_err
            
            la $a0 current_pid
            sw @pid 0($a0)
            la $a0 current_pcb
            sw @pcb 0($a0)
            
            b noerr
                ex_err:
                    println errmsg
                    li $v0 10
                    syscall
                .data
                    errmsg: .asciiz "error in cmgr_exit"
                .text
            noerr:
        }
        b reset_kmsg
    km_clock_interrupt:
        #do nothing
        b reset_kmsg
    reset_kmsg:
    la $a0 KMSG
    sw $zero 0($a0)
    
    la $a0 current_pcb
    lw $a0 0($a0)
    call restore_proc
    
    ######### RESTORE THE STACK ##########
    {
        @hcb_addr = $s1
        @pcb_id = $s2
        @error = $s3
        @curpcb_addr = $s4
        @stack_id = $s5
        @sp = $s6
        
        khcb_getaddr @hcb_addr
        la @curpcb_addr current_pcb
        lw @pcb_id      0(@curpcb_addr)
        geti    7 @pcb_id @hcb_addr @sp @error
        
        geti    4 @pcb_id @hcb_addr @stack_id @error
        
        addu    $a0 @stack_id $0
        addu    $a1 @sp $0
        call    restore_stack
    }

    ######### RESTORE THE STACK ##########
}
    j       restore_state
restore_state_return:
    la      $a0 interrupt_return
    jr      $a0

.data
rstr: .asciiz "Loading stack_id "
sstr: .asciiz "Saving stack_id "
memid_msg: .asciiz "mem_id: "
.text