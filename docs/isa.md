# ISA implementada (MIPS32, subconjunto mínimo)

Formatos: R = `opcode(6) rs(5) rt(5) rd(5) shamt(5) funct(6)`; I = `opcode(6) rs(5) rt(5) imm(16)`.
Escritas em `$zero` são ignoradas e não geram dependência.

| Mnemônico | Formato | Opcode | Funct | Operação (RTL) |
|---|---|---|---|---|
| add  rd, rs, rt  | R | 0x00 | 0x20 | R[rd] <- R[rs] + R[rt] |
| sub  rd, rs, rt  | R | 0x00 | 0x22 | R[rd] <- R[rs] - R[rt] |
| and  rd, rs, rt  | R | 0x00 | 0x24 | R[rd] <- R[rs] & R[rt] |
| or   rd, rs, rt  | R | 0x00 | 0x25 | R[rd] <- R[rs] \| R[rt] |
| slt  rd, rs, rt  | R | 0x00 | 0x2A | R[rd] <- (R[rs] < R[rt], com sinal) ? 1 : 0 |
| addi rt, rs, imm | I | 0x08 | —    | R[rt] <- R[rs] + SignExt(imm) |
| lw   rt, off(rs) | I | 0x23 | —    | R[rt] <- Mem[R[rs] + SignExt(off)] |
| sw   rt, off(rs) | I | 0x2B | —    | Mem[R[rs] + SignExt(off)] <- R[rt] |
| beq  rs, rt, off | I | 0x04 | —    | se R[rs] == R[rt]: PC <- (PC + 4) + (SignExt(off) << 2); senão PC <- PC + 4 |
| break            | R | 0x00 | 0x0D | fim de programa (`done` = 1; não conta no CPI) |

Passos de verificação com o `t0.hex`:

- `20080005` = `001000 00000 01000 0000000000000101` -> addi $t0, $zero, 5 (opcode 0x08, rs=0, rt=8, imm=5).
- `0000000d` = break.

Instruções extras (bne, j, andi, ori) não foram implementadas; se forem, acrescentar nesta tabela.
