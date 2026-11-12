# Limpa o arquivo de métricas antigo
if (Test-Path metricas.csv) { Remove-Item metricas.csv }

# Compila O1
Write-Host "Compilando O1..."
New-Item -ItemType Directory -Force -Path build/o1 | Out-Null
ghdl -a --std=08 --workdir=build/o1 o1/components/*.vhd
ghdl -a --std=08 --workdir=build/o1 o1/cpu_top.vhd
ghdl -a --std=08 --workdir=build/o1 tb/tb_cpu.vhd
ghdl -e --std=08 --workdir=build/o1 tb_cpu

# Compila O2
Write-Host "Compilando O2..."
New-Item -ItemType Directory -Force -Path build/o2 | Out-Null
ghdl -a --std=08 --workdir=build/o2 o2/components/*.vhd
ghdl -a --std=08 --workdir=build/o2 o2/cpu_top.vhd
ghdl -a --std=08 --workdir=build/o2 tb/tb_cpu.vhd
ghdl -e --std=08 --workdir=build/o2 tb_cpu

$tamanhos = @(5, 10, 20, 50, 100, 200)

foreach ($t in $tamanhos) {
    Write-Host "Rodando Série S com $t instruções..."
    
    # O1
    ghdl -r --std=08 --workdir=build/o1 tb_cpu `
      "-gPROG_FILE=tracos\s_$t.hex" "-gESPERADO_FILE=tracos\s_esperado.txt" `
      "-gORG_NOME=O1_S$t" "-gMEM_UNIFICADA=false" "-gESPERA_ABORTO=false" | Out-Null
      
    # O2
    ghdl -r --std=08 --workdir=build/o2 tb_cpu `
      "-gPROG_FILE=tracos\s_$t.hex" "-gESPERADO_FILE=tracos\s_esperado.txt" `
      "-gORG_NOME=O2_S$t" "-gMEM_UNIFICADA=false" "-gESPERA_ABORTO=false" | Out-Null
}

Write-Host "Concluído! Verifique o arquivo metricas.csv."