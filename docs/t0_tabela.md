# Tabela do traço T0

Distância = número de instruções entre o consumidor e o produtor mais próximo de qualquer registrador lido (em O2 sem forwarding é preciso distância >= 3, com escrita na 1ª metade e leitura na 2ª metade do ciclo). "—" = lê só $zero.

| # | Endereço | Instrução | Lê | Escreve | Distância |
|---|---|---|---|---|---|
| 0 | 0x00 | addi $t0,$zero,5 | $zero | $t0 | — |
| 1 | 0x04 | addi $t1,$zero,10 | $zero | $t1 | — |
| 2 | 0x08 | addi $t2,$zero,15 | $zero | $t2 | — |
| 3 | 0x0c | addi $s0,$zero,0x2000 | $zero | $s0 | — |
| 4 | 0x10 | add $t3,$t0,$t1 | $t0,$t1 | $t3 | 3 |
| 5 | 0x14 | sub $t4,$t2,$t0 | $t2,$t0 | $t4 | 3 |
| 6 | 0x18 | and $t5,$t1,$t2 | $t1,$t2 | $t5 | 4 |
| 7 | 0x1c | or $t6,$t0,$t1 | $t0,$t1 | $t6 | 6 |
| 8 | 0x20 | slt $t7,$t0,$t1 | $t0,$t1 | $t7 | 7 |
| 9 | 0x24 | sw $t3,0($s0) | $t3,$s0 | memória | 5 |
| 10 | 0x28 | sw $t4,4($s0) | $t4,$s0 | memória | 5 |
| 11 | 0x2c | addi $t0,$t0,1 | $t0 | $t0 | 11 |
| 12 | 0x30 | lw $t8,0($s0) | $s0 | $t8 | 9 |
| 13 | 0x34 | lw $t9,4($s0) | $s0 | $t9 | 10 |
| 14 | 0x38 | add $s1,$t3,$t4 | $t3,$t4 | $s1 | 9 |
| 15 | 0x3c | sub $s2,$t5,$t6 | $t5,$t6 | $s2 | 8 |
| 16 | 0x40 | addi $s3,$t7,100 | $t7 | $s3 | 8 |
| 17 | 0x44 | add $t1,$t8,$t9 | $t8,$t9 | $t1 | 4 |
| 18 | 0x48 | and $t2,$t8,$t9 | $t8,$t9 | $t2 | 5 |
| 19 | 0x4c | or $t3,$t8,$t9 | $t8,$t9 | $t3 | 6 |
| 20 | 0x50 | slt $t4,$t9,$t8 | $t9,$t8 | $t4 | 7 |
| 21 | 0x54 | beq $t8,$t9,fim | $t8,$t9 | — (não tomado) | 8 |
| 22 | 0x58 | addi $t5,$t0,2 | $t0 | $t5 | 11 |
| 23 | 0x5c | add $t6,$t1,$t2 | $t1,$t2 | $t6 | 5 |
| 24 | 0x60 | sub $t7,$t1,$t2 | $t1,$t2 | $t7 | 6 |
| 25 | 0x64 | add $s1,$s1,$s3 | $s1,$s3 | $s1 | 9 |
| 26 | 0x68 | sw $t5,12($s0) | $t5,$s0 | memória | 4 |
| 27 | 0x6c | sw $t6,8($s0) | $t6,$s0 | memória | 4 |
| 28 | 0x70 | lw $s2,8($s0) | $s0 | $s2 | 25 |
| 29 | 0x74 | add $t0,$t7,$t5 | $t7,$t5 | $t0 | 5 |
| 30 | 0x78 | slt $t1,$t5,$t7 | $t5,$t7 | $t1 | 6 |
| 31 | 0x7c | and $t2,$t6,$t7 | $t6,$t7 | $t2 | 7 |
| 32 | 0x80 | or $t3,$t6,$t7 | $t6,$t7 | $t3 | 8 |
| 33 | 0x84 | sub $t4,$t6,$t5 | $t6,$t5 | $t4 | 10 |
| 34 | 0x88 | beq $t5,$t7,fim | $t5,$t7 | — (não tomado) | 10 |
| — | 0x8c | break | — | — | fim (não conta no CPI) |

Observações:

- Menor distância: 3 (instruções 4 e 5), suficiente para O2 sem forwarding.
- A instrução 28 lê da memória o que a 27 escreveu: dependência por memória, correta em O1 e O2 (MEM em ciclos consecutivos). Não é conflito de dados de registrador.
- Os dois `beq` são não tomados; buscar sequencialmente depois deles não é conflito de controle.
- Sem NOPs: CPI com e sem NOPs é o mesmo.
