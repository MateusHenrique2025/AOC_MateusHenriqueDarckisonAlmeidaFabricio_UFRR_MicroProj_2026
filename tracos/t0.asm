# T0: traço limpo, 35 instruções úteis + break
        addi $t0, $zero, 5        # 0
        addi $t1, $zero, 10       # 1
        addi $t2, $zero, 15       # 2
        addi $s0, $zero, 0x2000   # 3  base de dados
        add  $t3, $t0, $t1        # 4
        sub  $t4, $t2, $t0        # 5
        and  $t5, $t1, $t2        # 6
        or   $t6, $t0, $t1        # 7
        slt  $t7, $t0, $t1        # 8
        sw   $t3, 0($s0)          # 9
        sw   $t4, 4($s0)          # 10
        addi $t0, $t0, 1          # 11
        lw   $t8, 0($s0)          # 12
        lw   $t9, 4($s0)          # 13
        add  $s1, $t3, $t4        # 14
        sub  $s2, $t5, $t6        # 15
        addi $s3, $t7, 100        # 16
        add  $t1, $t8, $t9        # 17
        and  $t2, $t8, $t9        # 18
        or   $t3, $t8, $t9        # 19
        slt  $t4, $t9, $t8        # 20
        beq  $t8, $t9, fim        # 21 não tomado
        addi $t5, $t0, 2          # 22
        add  $t6, $t1, $t2        # 23
        sub  $t7, $t1, $t2        # 24
        add  $s1, $s1, $s3        # 25
        sw   $t5, 12($s0)         # 26
        sw   $t6, 8($s0)          # 27
        lw   $s2, 8($s0)          # 28
        add  $t0, $t7, $t5        # 29
        slt  $t1, $t5, $t7        # 30
        and  $t2, $t6, $t7        # 31
        or   $t3, $t6, $t7        # 32
        sub  $t4, $t6, $t5        # 33
        beq  $t5, $t7, fim        # 34 não tomado
fim:    break                     # fim, não conta no CPI