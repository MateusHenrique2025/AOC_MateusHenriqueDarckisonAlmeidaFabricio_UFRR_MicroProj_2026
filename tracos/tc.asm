# TC - Conflito de Controle (Branch tomado)
addi $t0, $zero, 10
addi $t1, $zero, 10
addi $zero, $zero, 0   # NOP para evitar conflito de dados
addi $zero, $zero, 0   # NOP para evitar conflito de dados
beq  $t0, $t1, fim     # Agora sim, só vai gerar conflito de controle
addi $t2, $zero, 1
fim:
break