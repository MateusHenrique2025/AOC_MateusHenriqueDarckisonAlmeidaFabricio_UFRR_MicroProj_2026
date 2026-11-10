# Cria a pasta build se não existir
New-Item -ItemType Directory -Force -Path build/o1 | Out-Null

Write-Host "Compilando componentes..."
ghdl -a --std=08 --workdir=build/o1 o1/components/*.vhd

Write-Host "Compilando topo e testbench..."
ghdl -a --std=08 --workdir=build/o1 o1/cpu_top.vhd
ghdl -a --std=08 --workdir=build/o1 tb/tb_cpu.vhd

Write-Host "Elaborando..."
ghdl -e --std=08 --workdir=build/o1 tb_cpu

Write-Host "Simulando T0 (O1)..."
# Remove o metricas.csv antigo para não acumular lixo
if (Test-Path metricas.csv) { Remove-Item metricas.csv }

# Note que o T_CLK foi removido daqui!
ghdl -r --std=08 --workdir=build/o1 tb_cpu `
  "-gPROG_FILE=tracos\t0.hex" `
  "-gESPERADO_FILE=tracos\t0_esperado.txt" `
  "-gORG_NOME=O1" `
  "-gNUM_SLOTS=1" `
  "-gMEM_UNIFICADA=false" `
  "-gESPERA_ABORTO=false" `
  "-gMAX_CICLOS=1000" `
  --wave=build/o1_wave.ghw

Write-Host "Simulação concluída. Verifique o arquivo metricas.csv."