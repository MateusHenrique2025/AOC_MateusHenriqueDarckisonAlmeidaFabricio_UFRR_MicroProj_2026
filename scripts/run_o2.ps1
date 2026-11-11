Write-Host "Compilando O2..."
New-Item -ItemType Directory -Force -Path build/o2 | Out-Null
ghdl -a --std=08 --workdir=build/o2 o2/components/*.vhd
ghdl -a --std=08 --workdir=build/o2 o2/cpu_top.vhd
ghdl -a --std=08 --workdir=build/o2 tb/tb_cpu.vhd
ghdl -e --std=08 --workdir=build/o2 tb_cpu

Write-Host "Simulando T0 (O2)..."
ghdl -r --std=08 --workdir=build/o2 tb_cpu `
  "-gPROG_FILE=tracos\t0.hex" `
  "-gESPERADO_FILE=tracos\t0_esperado.txt" `
  "-gORG_NOME=O2" `
  "-gNUM_SLOTS=1" `
  "-gMEM_UNIFICADA=false" `
  "-gESPERA_ABORTO=false" `
  "-gMAX_CICLOS=1000" `
  --wave=build/o2_wave.ghw