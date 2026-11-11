Write-Host "Compilando O2..."
New-Item -ItemType Directory -Force -Path build/o2 | Out-Null
ghdl -a --std=08 --workdir=build/o2 o2/components/*.vhd
ghdl -a --std=08 --workdir=build/o2 o2/cpu_top.vhd
ghdl -a --std=08 --workdir=build/o2 tb/tb_cpu.vhd
ghdl -e --std=08 --workdir=build/o2 tb_cpu

Write-Host "`n--- Teste TD (Dados) ---"
ghdl -r --std=08 --workdir=build/o2 tb_cpu `
  "-gPROG_FILE=tracos\td.hex" "-gESPERADO_FILE=tracos\td_esperado.txt" `
  "-gORG_NOME=O2" "-gESPERA_ABORTO=true" "-gTIPO_ESPERADO=1" "-gMEM_UNIFICADA=false"

Write-Host "`n--- Teste TE (Estrutural) ---"
ghdl -r --std=08 --workdir=build/o2 tb_cpu `
  "-gPROG_FILE=tracos\te.hex" "-gESPERADO_FILE=tracos\te_esperado.txt" `
  "-gORG_NOME=O2" "-gESPERA_ABORTO=true" "-gTIPO_ESPERADO=2" "-gMEM_UNIFICADA=true"

Write-Host "`n--- Teste TC (Controle) ---"
ghdl -r --std=08 --workdir=build/o2 tb_cpu `
  "-gPROG_FILE=tracos\tc.hex" "-gESPERADO_FILE=tracos\tc_esperado.txt" `
  "-gORG_NOME=O2" "-gESPERA_ABORTO=true" "-gTIPO_ESPERADO=3" "-gMEM_UNIFICADA=false"