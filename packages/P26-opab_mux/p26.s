# P26 program - see README.md for the task.
# Rules: start at the label p26_main and finish with ret; every label you
# create starts with p26_ ; save ra (and any s registers you use) on the stack.
# You may call the library routines in sw/lib/rcv_lib.s (rcv_puts, rcv_getc, ...).

                .text
p26_main:
        addi    sp, sp, -24
        sw      ra, 20(sp)
        sw      s0, 16(sp)
        sw      s1, 12(sp)
        sw      s2, 8(sp)
        sw      s3, 4(sp)
        sw      s4, 0(sp)

        # Read 32-bit hex input into s0
        call    rcv_read_hex
        mv      s0, a0

        # s1 = bit 11 of value
        srli    s1, s0, 11
        andi    s1, s1, 1

        # s2 = addi immediate (low 12 bits, sign-extended)
        slli    s2, s0, 20
        srai    s2, s2, 20

        # s3 = lui immediate ((value - addi_imm) >> 12)
        sub     s3, s0, s2
        srli    s3, s3, 12

        # s4 = rebuilt value ((lui_imm << 12) + addi_imm)
        slli    s4, s3, 12
        add     s4, s4, s2

        # Print: bit 11   = <0|1>
        la      a0, p26_str_bit11
        call    rcv_puts
        mv      a0, s1
        call    rcv_print_dec
        call    rcv_newline

        # Print: lui  imm = <8 hex digits>
        la      a0, p26_str_lui
        call    rcv_puts
        mv      a0, s3
        call    rcv_print_hex
        call    rcv_newline

        # Print: addi imm = <signed decimal>
        la      a0, p26_str_addi
        call    rcv_puts
        mv      a0, s2
        call    rcv_print_dec
        call    rcv_newline

        # Print: rebuilt  = <8 hex digits>
        la      a0, p26_str_rebuilt
        call    rcv_puts
        mv      a0, s4
        call    rcv_print_hex
        call    rcv_newline

        # Print: check: OK or check: FAIL
        bne     s4, s0, p26_print_fail
        la      a0, p26_str_ok
        call    rcv_puts
        j       p26_done

p26_print_fail:
        la      a0, p26_str_fail
        call    rcv_puts

p26_done:
        call    rcv_newline

        lw      s4, 0(sp)
        lw      s3, 4(sp)
        lw      s2, 8(sp)
        lw      s1, 12(sp)
        lw      s0, 16(sp)
        lw      ra, 20(sp)
        addi    sp, sp, 24
        ret

        .rodata
p26_str_bit11:
        .asciz  "bit 11   = "
p26_str_lui:
        .asciz  "lui  imm = "
p26_str_addi:
        .asciz  "addi imm = "
p26_str_rebuilt:
        .asciz  "rebuilt  = "
p26_str_ok:
        .asciz  "check: OK"
p26_str_fail:
        .asciz  "check: FAIL"
        .align  2

