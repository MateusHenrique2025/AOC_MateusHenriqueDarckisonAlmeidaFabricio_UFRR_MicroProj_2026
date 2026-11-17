#!/bin/bash

echo "========================================"
echo " Limpando e preparando ambiente..."
echo "========================================"
mkdir -p build/o2
# Cria o arquivo CSV já com o cabeçalho exigido pelo testbench
echo "org;programa;ciclos;instrucoes;CPI;IPC;ocupacao;erros" > metricas.csv

echo -e "\n========================================"
echo " Compilando a Organização O2..."
echo "========================================"
ghdl -i --std=08 --workdir=build/o2 o2/components/*.vhd o2/cpu_top.vhd tb/tb_cpu.vhd
ghdl -m --std=08 --workdir=build/o2 tb_cpu

echo -e "\n========================================"
echo " Executando Traço Limpo (T0)..."
echo "========================================"
ghdl -r --std=08 --workdir=build/o2 tb_cpu -gPROG_FILE=tracos/t0.hex -gESPERADO_FILE=tracos/t0_esperado.txt -gORG_NOME=O2 -gNUM_SLOTS=5

echo -e "\n========================================"
echo " Executando Traços de Conflito (TD, TE, TC)..."
echo "========================================"
for t in "td 1" "te 2" "tc 3"; do set -- $t
  extra=""; [ "$1" = "te" ] && extra="-gMEM_UNIFICADA=true"
  echo "-> Rodando $1.hex..."
  ghdl -r --std=08 --workdir=build/o2 tb_cpu -gPROG_FILE=tracos/$1.hex -gESPERADO_FILE=tracos/$1_esperado.txt -gORG_NOME=O2 -gNUM_SLOTS=5 -gESPERA_ABORTO=true -gTIPO_ESPERADO=$2 $extra 2>&1 | grep -v metavalue
done

echo -e "\n========================================"
echo " Simulação concluída! Resultados gravados em metricas.csv"
echo "========================================"