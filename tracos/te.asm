# TE - Conflito Estrutural
lw $t0, 0($zero)       # Acessa a memória (vai dar conflito com IF se MEM_UNIFICADA=true)
addi $t1, $zero, 5
break