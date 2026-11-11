# TD - Conflito de Dados (RAW)
addi $t0, $zero, 5     # Escreve em $t0 (Estágio WB)
add  $t1, $t0, $t2     # Tenta ler $t0 imediatamente (Estágio ID) -> Vai gerar conflito!
break