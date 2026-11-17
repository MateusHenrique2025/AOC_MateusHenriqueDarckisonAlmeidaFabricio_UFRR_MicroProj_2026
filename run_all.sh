#!/bin/bash
cd "$(dirname "$0")" || exit 1

echo "========================================"
echo " Limpando e preparando ambiente..."
echo "========================================"
rm -rf build
mkdir -p build/o1 build/o2
# Cria o arquivo CSV já com o cabeçalho exigido pelo testbench
echo "org;programa;ciclos;instrucoes;CPI;IPC;ocupacao;erros" > metricas.csv

echo -e "\n========================================"
echo " Compilando as Organizações O1 e O2..."
echo "========================================"
for d in o1 o2; do
  echo "-> Compilando ${d^^}..."
  ghdl -i --std=08 --workdir=build/$d $d/components/*.vhd $d/cpu_top.vhd tb/tb_cpu.vhd || exit 1
  ghdl -m --std=08 --workdir=build/$d tb_cpu || exit 1
done

echo -e "\n========================================"
echo " Executando Traço Limpo (T0)..."
echo "========================================"
ghdl -r --std=08 --workdir=build/o1 tb_cpu -gPROG_FILE=tracos/t0.hex -gESPERADO_FILE=tracos/t0_esperado.txt -gORG_NOME=O1 -gNUM_SLOTS=1 2>&1 | grep -v metavalue
ghdl -r --std=08 --workdir=build/o2 tb_cpu -gPROG_FILE=tracos/t0.hex -gESPERADO_FILE=tracos/t0_esperado.txt -gORG_NOME=O2 -gNUM_SLOTS=5 2>&1 | grep -v metavalue

echo -e "\n========================================"
echo " Executando Traços de Conflito (TD, TE, TC)..."
echo "========================================"
for t in "td 1" "te 2" "tc 3"; do set -- $t
  extra=""; [ "$1" = "te" ] && extra="-gMEM_UNIFICADA=true"
  echo "-> Rodando $1.hex..."
  ghdl -r --std=08 --workdir=build/o2 tb_cpu -gPROG_FILE=tracos/$1.hex -gESPERADO_FILE=tracos/$1_esperado.txt -gORG_NOME=O2 -gNUM_SLOTS=5 -gESPERA_ABORTO=true -gTIPO_ESPERADO=$2 $extra 2>&1 | grep -v metavalue
done

echo -e "\n========================================"
echo " Executando Série S (5, 10, 20, 50, 100, 200)..."
echo "========================================"
for n in 5 10 20 50 100 200; do
  echo "-> Rodando s_$n.hex..."
  ghdl -r --std=08 --workdir=build/o1 tb_cpu -gPROG_FILE=tracos/s_$n.hex -gESPERADO_FILE=tracos/s_esperado.txt -gORG_NOME=O1 -gNUM_SLOTS=1 2>&1 | grep -v metavalue
  ghdl -r --std=08 --workdir=build/o2 tb_cpu -gPROG_FILE=tracos/s_$n.hex -gESPERADO_FILE=tracos/s_esperado.txt -gORG_NOME=O2 -gNUM_SLOTS=5 2>&1 | grep -v metavalue
done

echo -e "\n========================================"
echo " Simulação concluída! Resultados gravados em metricas.csv"
echo "========================================"
cat metricas.csv
